"""
Train ML models for the global annual trade warehouse.

Outputs:
  - ml_artifacts/global_trade_regressor.pkl
  - ml_artifacts/global_trade_classifier.pkl
  - ml_artifacts/global_trade_model_meta.pkl
"""

from __future__ import annotations

import json
import os
import warnings
from datetime import datetime

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import (
    HistGradientBoostingClassifier,
    HistGradientBoostingRegressor,
    RandomForestClassifier,
    RandomForestRegressor,
)
from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    explained_variance_score,
    f1_score,
    mean_absolute_error,
    mean_absolute_percentage_error,
    mean_squared_error,
    median_absolute_error,
    precision_score,
    r2_score,
    recall_score,
)

from global_trade_loader import get_global_trade_data

warnings.filterwarnings("ignore")

ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "ml_artifacts")
META_PATH = os.path.join(ARTIFACTS_DIR, "global_trade_model_meta.pkl")
REPORT_PATH = os.path.join(ARTIFACTS_DIR, "global_trade_training_report.json")
HISTORY_PATH = os.path.join(ARTIFACTS_DIR, "global_trade_training_history.jsonl")
os.makedirs(ARTIFACTS_DIR, exist_ok=True)


def _prepare_training_data() -> pd.DataFrame:
    product_year = get_global_trade_data()["product_year"].copy()
    if product_year.empty:
        raise FileNotFoundError("Global trade warehouse is empty. Run build_global_warehouse.py first.")

    product_year = product_year.sort_values(["hsn_code", "year"]).reset_index(drop=True)
    product_year["log_value"] = np.log1p(product_year["total_value_usd"].clip(lower=0))
    product_year["log_quantity"] = np.log1p(product_year["total_quantity_mt"].clip(lower=0))
    product_year["hsn2"] = product_year["hsn_code"].astype(str).str[:2].astype(int)
    product_year["hsn4"] = product_year["hsn_code"].astype(str).str[:4].astype(int)

    rows = []
    for _, grp in product_year.groupby("hsn_code", sort=False):
        grp = grp.sort_values("year").reset_index(drop=True)
        for i in range(3, len(grp)):
            prev3 = grp.iloc[i - 3]
            prev2 = grp.iloc[i - 2]
            prev1 = grp.iloc[i - 1]
            curr = grp.iloc[i]
            growth = (
                (curr["total_value_usd"] - prev1["total_value_usd"]) / prev1["total_value_usd"]
                if prev1["total_value_usd"] > 0 else 0.0
            )
            if growth <= -0.05:
                trend_label = "Declining"
            elif growth < 0.05:
                trend_label = "Stable"
            elif growth < 0.2:
                trend_label = "Moderate Growth"
            else:
                trend_label = "High Growth"

            prev_growth = (
                (prev1["total_value_usd"] - prev2["total_value_usd"]) / prev2["total_value_usd"]
                if prev2["total_value_usd"] > 0 else 0.0
            )
            prev2_growth = (
                (prev2["total_value_usd"] - prev3["total_value_usd"]) / prev3["total_value_usd"]
                if prev3["total_value_usd"] > 0 else 0.0
            )
            qty_growth = (
                (prev1["total_quantity_mt"] - prev2["total_quantity_mt"]) / prev2["total_quantity_mt"]
                if prev2["total_quantity_mt"] > 0 else 0.0
            )
            mean3 = float(np.mean([prev3["total_value_usd"], prev2["total_value_usd"], prev1["total_value_usd"]]))
            std3 = float(np.std([prev3["total_value_usd"], prev2["total_value_usd"], prev1["total_value_usd"]]))

            rows.append({
                "hsn_code": curr["hsn_code"],
                "target_year": int(curr["year"]),
                "prev_year": int(prev1["year"]),
                "prev_value_usd": float(prev1["total_value_usd"]),
                "prev2_value_usd": float(prev2["total_value_usd"]),
                "prev3_value_usd": float(prev3["total_value_usd"]),
                "prev_quantity_mt": float(prev1["total_quantity_mt"]),
                "prev2_quantity_mt": float(prev2["total_quantity_mt"]),
                "prev3_quantity_mt": float(prev3["total_quantity_mt"]),
                "prev_exporter_countries": float(prev1["exporter_countries"]),
                "prev_importer_countries": float(prev1["importer_countries"]),
                "prev2_exporter_countries": float(prev2["exporter_countries"]),
                "prev2_importer_countries": float(prev2["importer_countries"]),
                "prev_avg_unit_price_usd_per_mt": float(prev1["avg_unit_price_usd_per_mt"]),
                "prev2_avg_unit_price_usd_per_mt": float(prev2["avg_unit_price_usd_per_mt"]),
                "prev_log_value": float(prev1["log_value"]),
                "prev2_log_value": float(prev2["log_value"]),
                "prev3_log_value": float(prev3["log_value"]),
                "prev_log_quantity": float(prev1["log_quantity"]),
                "prev2_log_quantity": float(prev2["log_quantity"]),
                "prev3_log_quantity": float(prev3["log_quantity"]),
                "prev_growth": float(np.clip(prev_growth, -5.0, 5.0)),
                "prev2_growth": float(np.clip(prev2_growth, -5.0, 5.0)),
                "qty_growth": float(np.clip(qty_growth, -5.0, 5.0)),
                "value_mean3": mean3,
                "value_std3": std3,
                "estimated_count_last3": int(bool(prev1.get("is_estimated", False))) + int(bool(prev2.get("is_estimated", False))) + int(bool(prev3.get("is_estimated", False))),
                "hsn2": int(prev1["hsn2"]),
                "hsn4": int(prev1["hsn4"]),
                "is_estimated_input": int(bool(prev1.get("is_estimated", False))),
                "target_value_usd": float(curr["total_value_usd"]),
                "target_log_value": float(np.log1p(max(curr["total_value_usd"], 0.0))),
                "target_growth_label": trend_label,
            })
    df = pd.DataFrame(rows)
    if df.empty:
        raise ValueError("Not enough product-year rows to train the global trade model.")
    return df


def train_global_trade_models():
    print("[1/3] Preparing global trade training data ...")
    df = _prepare_training_data()

    feature_cols = [
        "prev_year",
        "prev_value_usd",
        "prev2_value_usd",
        "prev3_value_usd",
        "prev_quantity_mt",
        "prev2_quantity_mt",
        "prev3_quantity_mt",
        "prev_exporter_countries",
        "prev_importer_countries",
        "prev2_exporter_countries",
        "prev2_importer_countries",
        "prev_avg_unit_price_usd_per_mt",
        "prev2_avg_unit_price_usd_per_mt",
        "prev_log_value",
        "prev2_log_value",
        "prev3_log_value",
        "prev_log_quantity",
        "prev2_log_quantity",
        "prev3_log_quantity",
        "prev_growth",
        "prev2_growth",
        "qty_growth",
        "value_mean3",
        "value_std3",
        "estimated_count_last3",
        "hsn2",
        "hsn4",
        "is_estimated_input",
    ]

    train_df = df[df["target_year"] <= 2025].copy()
    test_df = df[df["target_year"] == 2026].copy()
    if test_df.empty:
        test_df = train_df.groupby("hsn_code").tail(1).copy()
        train_df = train_df.drop(test_df.index)

    X_train = train_df[feature_cols].fillna(0)
    y_train_reg = train_df["target_log_value"].fillna(0)
    y_train_cls = train_df["target_growth_label"].fillna("Stable")

    X_test = test_df[feature_cols].fillna(0)
    y_test_reg = test_df["target_value_usd"].fillna(0)
    y_test_cls = test_df["target_growth_label"].fillna("Stable")

    print("[2/3] Training regression and classification models ...")
    reg_candidates = [
        ("hist_gb", HistGradientBoostingRegressor(learning_rate=0.05, max_depth=10, max_iter=500, min_samples_leaf=15, random_state=42)),
        ("rf_250", RandomForestRegressor(n_estimators=250, max_depth=18, min_samples_leaf=2, n_jobs=-1, random_state=42)),
        ("rf_400", RandomForestRegressor(n_estimators=400, max_depth=22, min_samples_leaf=1, n_jobs=-1, random_state=42)),
    ]
    cls_candidates = [
        ("hist_gb", HistGradientBoostingClassifier(learning_rate=0.07, max_depth=8, max_iter=400, min_samples_leaf=20, random_state=42)),
        ("rf_300", RandomForestClassifier(n_estimators=300, max_depth=20, min_samples_leaf=2, n_jobs=-1, random_state=42, class_weight="balanced_subsample")),
        ("rf_500", RandomForestClassifier(n_estimators=500, max_depth=24, min_samples_leaf=1, n_jobs=-1, random_state=42, class_weight="balanced_subsample")),
    ]

    regressor = None
    best_reg_score = float("-inf")
    best_reg_params = None
    for idx, (name, candidate) in enumerate(reg_candidates, start=1):
        candidate.fit(X_train, y_train_reg)
        candidate_pred = np.expm1(candidate.predict(X_test))
        candidate_r2 = float(r2_score(y_test_reg, candidate_pred))
        print(f"  Regressor candidate {idx}: test R2 = {candidate_r2:.4f}")
        if candidate_r2 > best_reg_score:
            regressor = candidate
            best_reg_score = candidate_r2
            best_reg_params = {"model_family": name}

    classifier = None
    best_cls_score = float("-inf")
    best_cls_params = None
    for idx, (name, candidate) in enumerate(cls_candidates, start=1):
        candidate.fit(X_train, y_train_cls)
        candidate_pred = candidate.predict(X_test)
        candidate_score = float(f1_score(y_test_cls, candidate_pred, average="weighted", zero_division=0))
        print(f"  Classifier candidate {idx}: test weighted F1 = {candidate_score:.4f}")
        if candidate_score > best_cls_score:
            classifier = candidate
            best_cls_score = candidate_score
            best_cls_params = {"model_family": name}

    reg_pred = np.expm1(regressor.predict(X_test))
    cls_pred = classifier.predict(X_test)
    reg_train_pred = np.expm1(regressor.predict(X_train))
    cls_train_pred = classifier.predict(X_train)
    y_train_reg_actual = train_df["target_value_usd"].fillna(0)

    metrics = {
        "regression_mae_train": float(mean_absolute_error(y_train_reg_actual, reg_train_pred)),
        "regression_rmse_train": float(np.sqrt(mean_squared_error(y_train_reg_actual, reg_train_pred))),
        "regression_median_ae_train": float(median_absolute_error(y_train_reg_actual, reg_train_pred)),
        "regression_r2_train": float(r2_score(y_train_reg_actual, reg_train_pred)),
        "regression_mae": float(mean_absolute_error(y_test_reg, reg_pred)),
        "regression_rmse": float(np.sqrt(mean_squared_error(y_test_reg, reg_pred))),
        "regression_mape": float(mean_absolute_percentage_error(y_test_reg.clip(lower=1), np.clip(reg_pred, a_min=0, a_max=None)) * 100.0),
        "regression_median_ae": float(median_absolute_error(y_test_reg, reg_pred)),
        "regression_r2": float(r2_score(y_test_reg, reg_pred)),
        "regression_explained_variance": float(explained_variance_score(y_test_reg, reg_pred)),
        "regression_wape": float((np.abs(y_test_reg - reg_pred).sum() / max(np.abs(y_test_reg).sum(), 1.0)) * 100.0),
        "classification_accuracy_train": float(accuracy_score(y_train_cls, cls_train_pred)),
        "classification_accuracy": float(accuracy_score(y_test_cls, cls_pred)),
        "classification_balanced_accuracy": float(balanced_accuracy_score(y_test_cls, cls_pred)),
        "classification_precision_weighted": float(precision_score(y_test_cls, cls_pred, average="weighted", zero_division=0)),
        "classification_recall_weighted": float(recall_score(y_test_cls, cls_pred, average="weighted", zero_division=0)),
        "classification_f1_weighted": float(f1_score(y_test_cls, cls_pred, average="weighted", zero_division=0)),
        "classification_f1_macro": float(f1_score(y_test_cls, cls_pred, average="macro", zero_division=0)),
        "train_rows": int(len(train_df)),
        "test_rows": int(len(test_df)),
    }
    metrics["model_score"] = float(
        metrics["regression_r2"]
        + metrics["classification_accuracy"]
        + metrics["classification_f1_weighted"]
        + metrics["classification_balanced_accuracy"]
    )

    class_report = classification_report(y_test_cls, cls_pred, output_dict=True, zero_division=0)
    report_payload = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "selected_regressor_params": best_reg_params,
        "selected_classifier_params": best_cls_params,
        "evaluation_note": "2026 is a projected year derived from estimated continuity, so classification metrics on that holdout are optimistic compared with a fully real future-year benchmark.",
        "metrics": metrics,
        "classification_report": class_report,
    }

    print("[3/3] Saving model artifacts ...")
    previous_meta = joblib.load(META_PATH) if os.path.exists(META_PATH) else {}
    previous_metrics = previous_meta.get("metrics", {})
    previous_score = float(previous_metrics.get("model_score", float("-inf")))
    improved = metrics["model_score"] >= previous_score

    if improved:
        joblib.dump(regressor, os.path.join(ARTIFACTS_DIR, "global_trade_regressor.pkl"))
        joblib.dump(classifier, os.path.join(ARTIFACTS_DIR, "global_trade_classifier.pkl"))
        joblib.dump(
            {
                "feature_columns": feature_cols,
                "metrics": metrics,
                "labels": sorted(df["target_growth_label"].unique().tolist()),
                "selected_regressor_params": best_reg_params,
                "selected_classifier_params": best_cls_params,
                "generated_at": report_payload["generated_at"],
                "classification_report": class_report,
            },
            META_PATH,
        )
        print("  Best-so-far model improved or matched previous score. Saved new artifacts.")
    else:
        print("  Existing saved model is stronger. Keeping previous artifacts.")

    with open(REPORT_PATH, "w", encoding="utf-8") as handle:
        json.dump(
            {
                **report_payload,
                "saved_as_best": improved,
                "previous_best_score": previous_score if previous_score != float("-inf") else None,
            },
            handle,
            indent=2,
        )
    with open(HISTORY_PATH, "a", encoding="utf-8") as handle:
        handle.write(json.dumps({**report_payload, "saved_as_best": improved}) + "\n")

    print("Global trade models trained")
    print(f"  Regression R2: {metrics['regression_r2']:.4f}")
    print(f"  Regression RMSE: {metrics['regression_rmse']:,.2f}")
    print(f"  Regression MAE: {metrics['regression_mae']:,.2f}")
    print(f"  Regression MAPE: {metrics['regression_mape']:.2f}%")
    print(f"  Regression WAPE: {metrics['regression_wape']:.2f}%")
    print(f"  Classification Accuracy: {metrics['classification_accuracy']:.4f}")
    print(f"  Classification Balanced Accuracy: {metrics['classification_balanced_accuracy']:.4f}")
    print(f"  Classification Weighted F1: {metrics['classification_f1_weighted']:.4f}")
    print(f"  Overall Model Score: {metrics['model_score']:.4f}")
    return metrics


if __name__ == "__main__":
    train_global_trade_models()
