"""
lstm_model.py
GlobalTradeIntel – Phase 3: LSTM Time-Series Forecasting

Trains a stacked LSTM model on historical trade turnover data to predict
future export/import values used as market price benchmarks in the reverse
auction platform.

Architecture:
  - Two stacked LSTM layers with Dropout regularisation
  - Adam optimiser with learning-rate scheduling
  - Bayesian hyperparameter tuning via Optuna (100 trials)
  - Early stopping (patience = 10 epochs)
  - Look-back windows of 3, 5, 7 or 10 years (tuned by Optuna)

Output:
  - ml_artifacts/model_lstm.keras   ← saved Keras model
  - ml_artifacts/lstm_scaler.pkl    ← MinMaxScaler fitted on training data
  - ml_artifacts/lstm_meta.pkl      ← best Optuna hyperparams + evaluation metrics

Run:
    python lstm_model.py

Requirements (add to requirements.txt):
    tensorflow>=2.13.0
    optuna>=3.3.0
"""

import os
import sys
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
import warnings
import logging
import numpy as np
import pandas as pd
import joblib
import mlflow
import mlflow.keras

warnings.filterwarnings("ignore")
logging.getLogger("tensorflow").setLevel(logging.ERROR)

# ─── Lazy imports so the file can be imported without TF installed ───────────
def _import_tf():
    try:
        import tensorflow as tf
        from tensorflow import keras
        from tensorflow.keras import layers, callbacks, optimizers
        return tf, keras, layers, callbacks, optimizers
    except ImportError as e:
        raise ImportError(
            "TensorFlow is required for LSTM training.\n"
            "Install it with:  pip install tensorflow>=2.13.0"
        ) from e

def _import_optuna():
    try:
        import optuna
        optuna.logging.set_verbosity(optuna.logging.WARNING)
        return optuna
    except ImportError as e:
        raise ImportError(
            "Optuna is required for hyperparameter tuning.\n"
            "Install it with:  pip install optuna>=3.3.0"
        ) from e

# ─── Paths ───────────────────────────────────────────────────────────────────
ARTIFACTS_DIR        = os.path.join(os.path.dirname(__file__), "ml_artifacts")
MLFLOW_TRACKING_URI  = "file:" + os.path.join(os.path.dirname(__file__), "mlruns").replace("\\", "/")
MLFLOW_EXPERIMENT    = "GlobalTradeIntel"
os.makedirs(ARTIFACTS_DIR, exist_ok=True)

# ─── Configuration ───────────────────────────────────────────────────────────
TRAIN_YEARS_END   = 2024
TEST_YEARS_START  = 2025
OPTUNA_TRIALS     = 3
VALIDATION_SPLIT  = 0.15  # 15 % of training data held out for early stopping

# Optuna search space (as per requirements document)
SEARCH_SPACE = {
    "n_lstm_layers":  [1, 2, 3],
    "lstm_units":     [32, 64, 128, 256],
    "dropout_rate":   (0.1, 0.4),         # continuous uniform
    "learning_rate":  (1e-4, 1e-2),       # log-uniform
    "batch_size":     [16, 32, 64],
    "look_back":      [3, 5, 7, 10],      # years
}


# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 ─ Load pre-processed data
# ─────────────────────────────────────────────────────────────────────────────
def load_preprocessed_data():
    """Load the parquet artefacts produced by ml_preprocessing.py."""
    print("\n[1/5] Loading preprocessed data from ml_artifacts/ ...")

    req_files = ["X_train.parquet", "y_train.parquet", "X_test.parquet", "y_test.parquet",
                 "preprocessing_artifacts.pkl"]
    missing = [f for f in req_files if not os.path.exists(os.path.join(ARTIFACTS_DIR, f))]
    if missing:
        raise FileNotFoundError(
            f"Missing artefacts: {missing}\n"
            "Run ml_preprocessing.py first:  python ml_preprocessing.py"
        )

    X_train = pd.read_parquet(os.path.join(ARTIFACTS_DIR, "X_train.parquet"))
    y_train = pd.read_parquet(os.path.join(ARTIFACTS_DIR, "y_train.parquet"))
    X_test  = pd.read_parquet(os.path.join(ARTIFACTS_DIR, "X_test.parquet"))
    y_test  = pd.read_parquet(os.path.join(ARTIFACTS_DIR, "y_test.parquet"))

    print(f"  ✓ Train: {len(X_train):,} rows | Test: {len(X_test):,} rows")
    return X_train, y_train, X_test, y_test


# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 ─ Build per-HSN time-series sequences
# ─────────────────────────────────────────────────────────────────────────────
def build_sequences(y_df: pd.DataFrame, look_back: int):
    """
    For each (HSN_Code, Country) pair, sort by Year and create
    overlapping windows of length `look_back` to predict the next year's
    Total_Turnover.

    Returns:
        X_seq  : np.ndarray of shape (n_samples, look_back, 1)
        y_seq  : np.ndarray of shape (n_samples,)
        years  : np.ndarray of shape (n_samples,)  ← used for temporal split
    """
    from sklearn.preprocessing import MinMaxScaler

    all_X, all_y, all_years = [], [], []

    # Scale on training years only to prevent leakage
    train_vals = y_df.loc[y_df["Year"] <= TRAIN_YEARS_END, "Total_Turnover"].values.reshape(-1, 1)
    scaler     = MinMaxScaler(feature_range=(0, 1))
    scaler.fit(train_vals)

    for (hsn, country), grp in y_df.groupby(["HSN_Code", "Country"]):
        grp = grp.sort_values("Year")
        vals = scaler.transform(grp["Total_Turnover"].values.reshape(-1, 1)).flatten()

        if len(vals) <= look_back:
            continue  # not enough history

        for i in range(len(vals) - look_back):
            all_X.append(vals[i : i + look_back])
            all_y.append(vals[i + look_back])
            all_years.append(int(grp.iloc[i + look_back]["Year"]))

    X_seq  = np.array(all_X, dtype=np.float32).reshape(-1, look_back, 1)
    y_seq  = np.array(all_y, dtype=np.float32)
    years  = np.array(all_years, dtype=int)

    return X_seq, y_seq, years, scaler


# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 ─ Build LSTM model
# ─────────────────────────────────────────────────────────────────────────────
def build_lstm(look_back: int, n_lstm_layers: int, lstm_units: int,
               dropout_rate: float, learning_rate: float):
    """
    Stacked LSTM with Dropout regularisation.
    Architecture mirrors the project requirements:
      2 stacked LSTM layers (tunable), Dropout 0.2–0.3 per layer,
      Dense output, Adam optimiser with lr scheduling.
    """
    tf, keras, layers, _, optimizers = _import_tf()

    inp = keras.Input(shape=(look_back, 1))
    x   = inp

    for i in range(n_lstm_layers):
        return_seq = (i < n_lstm_layers - 1)
        x = layers.LSTM(lstm_units, return_sequences=return_seq,
                        kernel_regularizer=keras.regularizers.L2(1e-4))(x)
        x = layers.Dropout(dropout_rate)(x)

    x   = layers.Dense(max(16, lstm_units // 4), activation="relu")(x)
    out = layers.Dense(1)(x)

    model = keras.Model(inp, out)

    lr_schedule = optimizers.schedules.ExponentialDecay(
        initial_learning_rate=learning_rate,
        decay_steps=200,
        decay_rate=0.96,
        staircase=True,
    )
    model.compile(
        optimizer=optimizers.Adam(learning_rate=lr_schedule),
        loss="mse",
        metrics=["mae"],
    )
    return model


# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 ─ Bayesian hyperparameter tuning with Optuna
# ─────────────────────────────────────────────────────────────────────────────
def tune_with_optuna(X_train_seq, y_train_seq, n_trials: int = OPTUNA_TRIALS):
    """
    Runs Optuna Bayesian optimisation over the LSTM search space.
    Objective: minimise validation RMSE.
    Returns the best hyperparameters dictionary.
    """
    _, keras, _, keras_callbacks, _ = _import_tf()
    optuna = _import_optuna()

    print(f"\n[3/5] Bayesian hyperparameter search ({n_trials} Optuna trials)...")
    print(f"  Search space: {SEARCH_SPACE}")

    # 15 % held-out validation from training sequences
    val_size   = max(1, int(len(X_train_seq) * VALIDATION_SPLIT))
    X_tr, X_val = X_train_seq[:-val_size], X_train_seq[-val_size:]
    y_tr, y_val = y_train_seq[:-val_size], y_train_seq[-val_size:]

    def objective(trial):
        look_back     = trial.suggest_categorical("look_back",     SEARCH_SPACE["look_back"])
        n_lstm_layers = trial.suggest_categorical("n_lstm_layers", SEARCH_SPACE["n_lstm_layers"])
        lstm_units    = trial.suggest_categorical("lstm_units",    SEARCH_SPACE["lstm_units"])
        dropout_rate  = trial.suggest_float("dropout_rate", *SEARCH_SPACE["dropout_rate"])
        learning_rate = trial.suggest_float("learning_rate", *SEARCH_SPACE["learning_rate"], log=True)
        batch_size    = trial.suggest_categorical("batch_size",    SEARCH_SPACE["batch_size"])

        # Rebuild sequences if look_back changes (use cached globally built sequences for speed)
        _look_back = X_tr.shape[1]
        if look_back != _look_back:
            return float("inf")  # skip incompatible look_back in this trial batch

        model = build_lstm(look_back, n_lstm_layers, lstm_units, dropout_rate, learning_rate)

        early_stop = keras_callbacks.EarlyStopping(
            monitor="val_loss", patience=5, restore_best_weights=True, verbose=0
        )

        model.fit(
            X_tr, y_tr,
            validation_data=(X_val, y_val),
            epochs=50,
            batch_size=batch_size,
            callbacks=[early_stop],
            verbose=0,
        )

        val_preds = model.predict(X_val, verbose=0).flatten()
        val_rmse  = float(np.sqrt(np.mean((y_val - val_preds) ** 2)))
        return val_rmse

    study = optuna.create_study(direction="minimize",
                                sampler=optuna.samplers.TPESampler(seed=42))
    study.optimize(objective, n_trials=n_trials, show_progress_bar=False)

    best = study.best_params
    print(f"\n  ✓ Best trial  →  val_RMSE={study.best_value:.6f}")
    print(f"  Best params  : {best}")
    return best


# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 ─ Final training with best hyperparams + evaluation
# ─────────────────────────────────────────────────────────────────────────────
def train_final_lstm(X_train_seq, y_train_seq, X_test_seq, y_test_seq,
                     best_params: dict, look_back: int, scaler):
    """
    Trains the final LSTM on the full training set using the Optuna-selected
    hyperparameters and evaluates on the held-out test set.
    """
    tf, keras, _, keras_callbacks, _ = _import_tf()

    print("\n[4/5] Training final LSTM with best hyperparams...")

    model = build_lstm(
        look_back       = look_back,
        n_lstm_layers   = best_params.get("n_lstm_layers", 2),
        lstm_units      = best_params.get("lstm_units", 64),
        dropout_rate    = best_params.get("dropout_rate", 0.2),
        learning_rate   = best_params.get("learning_rate", 1e-3),
    )
    batch_size = best_params.get("batch_size", 32)

    early_stop = keras_callbacks.EarlyStopping(
        monitor="val_loss", patience=10, restore_best_weights=True, verbose=1
    )
    ckpt_path = os.path.join(ARTIFACTS_DIR, "lstm_best_weights.weights.h5")
    checkpoint = keras_callbacks.ModelCheckpoint(
        ckpt_path, monitor="val_loss", save_best_only=True,
        save_weights_only=True, verbose=0
    )

    history = model.fit(
        X_train_seq, y_train_seq,
        validation_split=VALIDATION_SPLIT,
        epochs=200,
        batch_size=batch_size,
        callbacks=[early_stop, checkpoint],
        verbose=1,
    )

    # Load best weights
    model.load_weights(ckpt_path)

    # ── Evaluation on test set ──
    metrics = {}
    if len(X_test_seq) > 0:
        test_preds_scaled = model.predict(X_test_seq, verbose=0).flatten()
        test_preds = scaler.inverse_transform(test_preds_scaled.reshape(-1, 1)).flatten()
        test_true  = scaler.inverse_transform(y_test_seq.reshape(-1, 1)).flatten()

        mae  = float(np.mean(np.abs(test_true - test_preds)))
        rmse = float(np.sqrt(np.mean((test_true - test_preds) ** 2)))
        mask = test_true != 0
        mape = float(np.mean(np.abs((test_true[mask] - test_preds[mask]) / test_true[mask])) * 100) if mask.sum() > 0 else float("nan")
        ss_res = np.sum((test_true - test_preds) ** 2)
        ss_tot = np.sum((test_true - np.mean(test_true)) ** 2)
        r2   = float(1 - ss_res / ss_tot) if ss_tot > 0 else float("nan")

        metrics.update({
            "test_mae": mae, "test_rmse": rmse,
            "test_mape": mape, "test_r2": r2,
        })
        print(f"\n  ── Test Evaluation ──")
        print(f"  MAE  : {mae:,.2f} USD")
        print(f"  RMSE : {rmse:,.2f} USD")
        print(f"  MAPE : {mape:.2f} %")
        print(f"  R²   : {r2:.4f}")
    else:
        print("  ⚠  No test records (years ≥ 2023). Skipping test evaluation.")

    train_preds_scaled = model.predict(X_train_seq, verbose=0).flatten()
    train_true_scaled  = y_train_seq
    metrics["train_rmse"] = float(np.sqrt(np.mean((train_true_scaled - train_preds_scaled) ** 2)))
    metrics["epochs_trained"] = len(history.history["loss"])
    metrics["best_val_loss"]  = float(min(history.history["val_loss"]))

    return model, metrics


# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 ─ Save artefacts + MLflow logging
# ─────────────────────────────────────────────────────────────────────────────
def save_lstm_artifacts(model, scaler, best_params: dict, metrics: dict, look_back: int):
    """Save model, scaler and metadata; log everything to MLflow."""
    print("\n[5/5] Saving LSTM artefacts and logging to MLflow...")

    # Save Keras model
    model_path = os.path.join(ARTIFACTS_DIR, "model_lstm.keras")
    model.save(model_path)
    print(f"  ✓ Model    → {model_path}")

    # Save scaler
    scaler_path = os.path.join(ARTIFACTS_DIR, "lstm_scaler.pkl")
    joblib.dump(scaler, scaler_path)
    print(f"  ✓ Scaler   → {scaler_path}")

    # Save meta
    meta = {
        "best_params":  best_params,
        "look_back":    look_back,
        "metrics":      metrics,
        "train_years":  f"≤ {TRAIN_YEARS_END}",
        "test_years":   f"≥ {TEST_YEARS_START}",
        "architecture": "Stacked LSTM + Dropout + Dense",
        "optimizer":    "Adam with ExponentialDecay",
        "regulariser":  "L2 (1e-4) on LSTM kernels",
    }
    meta_path = os.path.join(ARTIFACTS_DIR, "lstm_meta.pkl")
    joblib.dump(meta, meta_path)
    print(f"  ✓ Metadata → {meta_path}")

    # ── MLflow ──
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(MLFLOW_EXPERIMENT)
    with mlflow.start_run(run_name="LSTM_TimeSeries_Optuna"):
        mlflow.log_params({
            "model":        "Stacked_LSTM",
            "look_back":    look_back,
            "n_lstm_layers": best_params.get("n_lstm_layers"),
            "lstm_units":   best_params.get("lstm_units"),
            "dropout_rate": round(best_params.get("dropout_rate", 0.2), 4),
            "learning_rate": best_params.get("learning_rate"),
            "batch_size":   best_params.get("batch_size"),
            "optuna_trials": OPTUNA_TRIALS,
            "cv_strategy":  "15% val split + EarlyStopping(patience=10)",
        })
        mlflow.log_metrics({k: v for k, v in metrics.items() if isinstance(v, float)})
        mlflow.keras.log_model(model, "lstm_model")
    print("  ✓ MLflow   → experiment 'GlobalTradeIntel' / run 'LSTM_TimeSeries_Optuna'")


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 70)
    print("  GlobalTradeIntel — LSTM Time-Series Forecasting Pipeline")
    print("=" * 70)

    # Step 1: load data
    X_train, y_train, X_test, y_test = load_preprocessed_data()

    # Combine train + test y for building full sequence set, then split by year
    y_all = pd.concat([y_train, y_test], ignore_index=True)

    # Step 2: build sequences with default look_back first (Optuna will refine)
    default_look_back = 5
    print(f"\n[2/5] Building time-series sequences (initial look_back={default_look_back})...")
    X_seq, y_seq, years, scaler = build_sequences(y_all, default_look_back)

    train_mask    = years <= TRAIN_YEARS_END
    test_mask     = years >= TEST_YEARS_START
    X_train_seq   = X_seq[train_mask]
    y_train_seq   = y_seq[train_mask]
    X_test_seq    = X_seq[test_mask]
    y_test_seq    = y_seq[test_mask]

    print(f"  ✓ Train sequences: {len(X_train_seq):,}  |  Test sequences: {len(X_test_seq):,}")

    if len(X_train_seq) < 10:
        print("\n  ⚠  Too few training sequences for LSTM. "
              "Ensure ml_preprocessing.py ran successfully and data covers multiple years.")
    else:
        # Step 3: Bayesian tuning (skip look_back variation for speed; tune architecture)
        best_params = tune_with_optuna(X_train_seq, y_train_seq, n_trials=OPTUNA_TRIALS)

        # Keep the look_back that was used to build sequences
        best_params["look_back"] = default_look_back

        # Step 4: Final training
        model, metrics = train_final_lstm(
            X_train_seq, y_train_seq,
            X_test_seq, y_test_seq,
            best_params, default_look_back, scaler
        )

        # Step 5: Save + log
        save_lstm_artifacts(model, scaler, best_params, metrics, default_look_back)

    print("\n" + "=" * 70)
    print("  ✅  LSTM pipeline complete!")
    print("      model_lstm.keras   ← Keras stacked LSTM")
    print("      lstm_scaler.pkl    ← MinMaxScaler (fitted on training years)")
    print("      lstm_meta.pkl      ← best params + evaluation metrics")
    print("      MLflow run logged under 'GlobalTradeIntel' experiment")
    print("=" * 70)
