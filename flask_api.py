"""
flask_api.py
GlobalTradeIntel - Phase 4: Flask REST API for Model Serving

Exposes five prediction endpoints:
  POST /predict/price          → Market price benchmark (XGBoost regression)
  POST /classify/trend         → Trade growth classification (XGBoost + SMOTE)
  POST /recommend/suppliers    → Top supplier clusters (PCA + K-Means)
  POST /recommend/collab       → Top supplier countries (collaborative filtering SVD)
  POST /forecast/lstm          → Multi-step trade value forecast (LSTM)
  GET  /health                 → Liveness probe

Run locally:
    python flask_api.py

Docker build & run:
    docker build -t globaltradeintel-api .
    docker run -p 5000:5000 globaltradeintel-api

MLflow model registry integration:
    Set MLFLOW_TRACKING_URI env var to point at your MLflow server.

── Dockerfile (save as Dockerfile in project root) ──────────────────────
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
ENV FLASK_ENV=production
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "flask_api:app"]
──────────────────────────────────────────────────────────────────────────
"""

import os
import logging
import numpy as np
import pandas as pd
import joblib

from flask import Flask, request, jsonify, abort
from functools import lru_cache

# ─────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────
ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "ml_artifacts")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

app = Flask(__name__)


# ─────────────────────────────────────────────
# MODEL LOADING  (cached — loaded once on first request)
# ─────────────────────────────────────────────
@lru_cache(maxsize=1)
def load_models():
    """Load all serialised models and preprocessing artifacts from disk."""
    logger.info("Loading models from %s ...", ARTIFACTS_DIR)

    try:
        artifacts = joblib.load(os.path.join(ARTIFACTS_DIR, "preprocessing_artifacts.pkl"))
        reg_model = joblib.load(os.path.join(ARTIFACTS_DIR, "model_regression.pkl"))
        cls_model = joblib.load(os.path.join(ARTIFACTS_DIR, "model_classification.pkl"))
        pca_model = joblib.load(os.path.join(ARTIFACTS_DIR, "model_pca.pkl"))
        km_model  = joblib.load(os.path.join(ARTIFACTS_DIR, "model_kmeans.pkl"))
    except FileNotFoundError as e:
        logger.error("Core model files not found: %s  —  Run ml_preprocessing.py and train_models.py first.", e)
        return None

    bundle = {
        "artifacts":      artifacts,
        "regression":     reg_model,
        "classification": cls_model,
        "pca":            pca_model,
        "kmeans":         km_model,
        "recommender":    None,
        "lstm":           None,
        "lstm_scaler":    None,
        "lstm_meta":      None,
    }

    # ── Collaborative-filtering recommender (optional) ────────────────────────
    try:
        from recommendation_system import TradeRecommender
        bundle["recommender"] = TradeRecommender.load()
        logger.info("Recommendation system loaded.")
    except Exception as e:
        logger.warning("Collaborative-filtering recommender not available: %s", e)

    # ── LSTM model (optional — requires TensorFlow) ───────────────────────────
    lstm_path  = os.path.join(ARTIFACTS_DIR, "model_lstm.keras")
    scaler_path = os.path.join(ARTIFACTS_DIR, "lstm_scaler.pkl")
    meta_path   = os.path.join(ARTIFACTS_DIR, "lstm_meta.pkl")
    if os.path.exists(lstm_path):
        try:
            from tensorflow import keras as tf_keras
            bundle["lstm"]        = tf_keras.models.load_model(lstm_path)
            bundle["lstm_scaler"] = joblib.load(scaler_path)
            bundle["lstm_meta"]   = joblib.load(meta_path)
            logger.info("LSTM model loaded.")
        except Exception as e:
            logger.warning("LSTM model not available: %s", e)

    logger.info("All core models loaded successfully.")
    return bundle


def build_feature_vector(hsn_code: str, country: str, year: int, quantity: float, models: dict) -> pd.DataFrame:
    """
    Constructs a single-row feature DataFrame matching the training schema.
    Fills unknown countries with 0 in one-hot columns; uses frequency encoding for HSN.
    """
    artifacts = models["artifacts"]
    feature_cols = artifacts["feature_columns"]
    hsn_freq = artifacts["hsn_freq"]
    robust_scaler = models["artifacts"]["robust_scaler"] if "robust_scaler" in artifacts else None
    mm_scaler = artifacts.get("minmax_scaler")
    minmax_cols = artifacts.get("minmax_cols", [])
    robust_cols = artifacts.get("robust_cols", [])

    row = {col: 0.0 for col in feature_cols}

    # Numeric features
    row["Total_Quantity"]   = float(quantity)
    row["Avg_Price"]        = float(models["artifacts"].get("hsn_freq", {}).get(hsn_code, 0)) * 1000  # rough proxy
    row["Year"]             = float(year)
    row["HSN_Freq_Encoded"] = float(hsn_freq.get(hsn_code, 0))

    # One-hot country
    country_col = f"Country_{country.title()}"
    if country_col in row:
        row[country_col] = 1.0

    df = pd.DataFrame([row])[feature_cols]

    # Apply scalers (fitted on training data)
    try:
        if mm_scaler and minmax_cols:
            present_mm = [c for c in minmax_cols if c in df.columns]
            if present_mm:
                df[present_mm] = mm_scaler.transform(df[present_mm])
        if robust_scaler and robust_cols:
            present_rb = [c for c in robust_cols if c in df.columns]
            if present_rb:
                df[present_rb] = robust_scaler.transform(df[present_rb])
    except Exception as e:
        logger.warning("Scaler transform failed (non-fatal): %s", e)

    return df


# ─────────────────────────────────────────────
# HEALTH CHECK
# ─────────────────────────────────────────────
@app.route("/health", methods=["GET"])
def health():
    """Simple liveness probe for Docker/Kubernetes."""
    models = load_models()
    status = "ok" if models else "model_load_failed"
    return jsonify({"status": status, "service": "GlobalTradeIntel API"}), 200


# ─────────────────────────────────────────────
# ENDPOINT 1: /predict/price
# ─────────────────────────────────────────────
@app.route("/predict/price", methods=["POST"])
def predict_price():
    """
    Predicts the market price benchmark (Total Trade Turnover proxy) for a
    given HSN code, country, and trade quantity.

    Request JSON:
    {
        "hsn_code":  "290220",
        "country":   "China",
        "year":      2024,
        "quantity":  5000.0
    }

    Response JSON:
    {
        "hsn_code": "290220",
        "country":  "China",
        "year":     2024,
        "predicted_market_value_usd": 4050000.0,
        "predicted_price_per_unit_usd": 810.0,
        "model": "XGBoost Regressor"
    }
    """
    models = load_models()
    if models is None:
        abort(503, description="Models not loaded. Run preprocessing and training scripts first.")

    data = request.get_json(force=True)
    required = ["hsn_code", "country", "year", "quantity"]
    missing = [k for k in required if k not in data]
    if missing:
        abort(400, description=f"Missing required fields: {missing}")

    hsn_code = str(data["hsn_code"])
    country  = str(data["country"])
    year     = int(data["year"])
    quantity = float(data["quantity"])

    try:
        feature_df = build_feature_vector(hsn_code, country, year, quantity, models)
        predicted_value = float(models["regression"].predict(feature_df)[0])
        price_per_unit  = predicted_value / quantity if quantity > 0 else 0.0

        logger.info("predict/price  HSN=%s  Country=%s  Year=%d  Predicted=%.2f",
                    hsn_code, country, year, predicted_value)

        return jsonify({
            "hsn_code": hsn_code,
            "country":  country,
            "year":     year,
            "predicted_market_value_usd": round(predicted_value, 2),
            "predicted_price_per_unit_usd": round(price_per_unit, 4),
            "model": "XGBoost Regressor",
        })
    except Exception as e:
        logger.error("Prediction error: %s", e)
        abort(500, description=f"Prediction failed: {str(e)}")


# ─────────────────────────────────────────────
# ENDPOINT 2: /classify/trend
# ─────────────────────────────────────────────
@app.route("/classify/trend", methods=["POST"])
def classify_trend():
    """
    Classifies the trade growth trend for a given HSN code and country.

    Request JSON:
    {
        "hsn_code": "290230",
        "country":  "India",
        "year":     2024,
        "quantity": 3000.0
    }

    Response JSON:
    {
        "hsn_code":      "290230",
        "country":       "India",
        "trend_label":   "High Growth",
        "trend_code":    3,
        "probabilities": {"Declining": 0.02, "Stable": 0.10, "Moderate Growth": 0.25, "High Growth": 0.63},
        "model": "XGBoost Classifier + SMOTE"
    }
    """
    models = load_models()
    if models is None:
        abort(503, description="Models not loaded.")

    data = request.get_json(force=True)
    required = ["hsn_code", "country", "year", "quantity"]
    missing = [k for k in required if k not in data]
    if missing:
        abort(400, description=f"Missing required fields: {missing}")

    hsn_code = str(data["hsn_code"])
    country  = str(data["country"])
    year     = int(data["year"])
    quantity = float(data["quantity"])

    try:
        feature_df   = build_feature_vector(hsn_code, country, year, quantity, models)
        cls_model    = models["classification"]
        trend_code   = int(cls_model.predict(feature_df)[0])
        trend_proba  = cls_model.predict_proba(feature_df)[0]

        le           = models["artifacts"]["label_encoder"]
        trend_label  = le.inverse_transform([trend_code])[0]
        proba_dict   = {cls: round(float(p), 4) for cls, p in zip(le.classes_, trend_proba)}

        logger.info("classify/trend  HSN=%s  Country=%s  Year=%d  Trend=%s",
                    hsn_code, country, year, trend_label)

        return jsonify({
            "hsn_code":      hsn_code,
            "country":       country,
            "trend_label":   trend_label,
            "trend_code":    trend_code,
            "probabilities": proba_dict,
            "model": "XGBoost Classifier + SMOTE",
        })
    except Exception as e:
        logger.error("Classification error: %s", e)
        abort(500, description=f"Classification failed: {str(e)}")


# ─────────────────────────────────────────────
# ENDPOINT 3: /recommend/suppliers
# ─────────────────────────────────────────────
@app.route("/recommend/suppliers", methods=["POST"])
def recommend_suppliers():
    """
    Recommends top supplier country clusters for a given HSN code
    by finding the cluster with the highest average predicted market value
    and returning all countries in that cluster.

    Request JSON:
    {
        "hsn_code": "390110",
        "top_n":    5
    }

    Response JSON:
    {
        "hsn_code":           "390110",
        "recommended_cluster": 2,
        "cluster_countries":  ["China", "Germany", "United States", ...],
        "top_n":              5,
        "model": "PCA + K-Means"
    }
    """
    models = load_models()
    if models is None:
        abort(503, description="Models not loaded.")

    data = request.get_json(force=True)
    if "hsn_code" not in data:
        abort(400, description="Missing required field: hsn_code")

    hsn_code = str(data["hsn_code"])
    top_n    = int(data.get("top_n", 5))

    try:
        artifacts      = models["artifacts"]
        country_features = artifacts.get("country_features", [])

        if not country_features:
            abort(500, description="Country features not found in preprocessing artifacts.")

        # Build a feature matrix with one row per country for this HSN
        country_names = [c.replace("Country_", "") for c in country_features]
        rows = []
        for i, country in enumerate(country_names):
            feature_df = build_feature_vector(hsn_code, country, 2024, 1000.0, models)
            rows.append(feature_df.values[0])

        X_countries = np.array(rows)

        # PCA transform → K-Means predict
        pca    = models["pca"]
        kmeans = models["kmeans"]
        X_pca  = pca.transform(X_countries)
        cluster_labels = kmeans.predict(X_pca)

        # Score each cluster by average regression prediction
        reg_preds = []
        for i, country in enumerate(country_names):
            feature_df = build_feature_vector(hsn_code, country, 2024, 1000.0, models)
            pred = float(models["regression"].predict(feature_df)[0])
            reg_preds.append(pred)

        reg_preds = np.array(reg_preds)

        cluster_scores = {}
        for cluster_id in np.unique(cluster_labels):
            mask = cluster_labels == cluster_id
            cluster_scores[int(cluster_id)] = float(reg_preds[mask].mean())

        best_cluster = max(cluster_scores, key=cluster_scores.get)
        best_mask    = cluster_labels == best_cluster
        best_countries = [country_names[i] for i, m in enumerate(best_mask) if m]

        # Sort by predicted value desc and take top_n
        country_preds = [(country_names[i], reg_preds[i])
                         for i, m in enumerate(best_mask) if m]
        country_preds.sort(key=lambda x: x[1], reverse=True)
        top_countries = [cp[0] for cp in country_preds[:top_n]]

        logger.info("recommend/suppliers  HSN=%s  BestCluster=%d  Top=%s",
                    hsn_code, best_cluster, top_countries[:3])

        return jsonify({
            "hsn_code":            hsn_code,
            "recommended_cluster": best_cluster,
            "cluster_countries":   top_countries,
            "cluster_score_usd":   round(cluster_scores[best_cluster], 2),
            "all_cluster_scores":  {str(k): round(v, 2) for k, v in cluster_scores.items()},
            "top_n":               top_n,
            "model": "PCA + K-Means",
        })
    except Exception as e:
        logger.error("Recommendation error: %s", e)
        abort(500, description=f"Recommendation failed: {str(e)}")


# ─────────────────────────────────────────────
# ENDPOINT 4: /recommend/collab
# ─────────────────────────────────────────────
@app.route("/recommend/collab", methods=["POST"])
def recommend_collab():
    """
    Recommends top supplier countries for an HSN code using the
    collaborative-filtering SVD model (TradeRecommender).

    Request JSON:
    {
        "hsn_code":      "320611",
        "buyer_country": "India",
        "top_n":         5
    }

    Response JSON:
    {
        "hsn_code":       "320611",
        "buyer_country":  "India",
        "recommendations": [
            {"rank": 1, "country": "China",   "trade_value_usd": 1200000, "recommendation_score": 0.92},
            ...
        ],
        "model": "SVD Collaborative Filtering"
    }
    """
    models = load_models()
    if models is None:
        abort(503, description="Models not loaded.")

    rec = models.get("recommender")
    if rec is None:
        abort(503, description="Collaborative-filtering recommender not available. "
              "Run recommendation_system.py first.")

    data = request.get_json(force=True)
    if "hsn_code" not in data:
        abort(400, description="Missing required field: hsn_code")

    hsn_code      = str(data["hsn_code"])
    buyer_country = data.get("buyer_country")
    top_n         = int(data.get("top_n", 5))

    try:
        results_df = rec.recommend_suppliers(
            hsn_code=hsn_code,
            buyer_country=buyer_country,
            top_n=top_n,
        )
        recs = results_df.to_dict(orient="records")

        logger.info("recommend/collab  HSN=%s  Buyer=%s  TopN=%d  Results=%d",
                    hsn_code, buyer_country, top_n, len(recs))

        return jsonify({
            "hsn_code":       hsn_code,
            "buyer_country":  buyer_country,
            "recommendations": recs,
            "model": "SVD Collaborative Filtering",
        })
    except Exception as e:
        logger.error("Collab recommendation error: %s", e)
        abort(500, description=f"Recommendation failed: {str(e)}")


# ─────────────────────────────────────────────
# ENDPOINT 5: /forecast/lstm
# ─────────────────────────────────────────────
@app.route("/forecast/lstm", methods=["POST"])
def forecast_lstm():
    """
    Produces a multi-step trade value forecast using the trained LSTM model.
    Accepts a sequence of recent trade values and returns predictions for the
    next `steps` periods.

    Request JSON:
    {
        "hsn_code":         "290220",
        "country":          "India",
        "recent_values":    [120000, 135000, 142000, 155000, 168000],
        "steps":            3
    }

    `recent_values` must contain at least `look_back` values (default 5).

    Response JSON:
    {
        "hsn_code":     "290220",
        "country":      "India",
        "look_back":    5,
        "steps":        3,
        "forecasts_usd": [178500.0, 192300.0, 205100.0],
        "model": "Stacked LSTM (TensorFlow/Keras)"
    }
    """
    models = load_models()
    if models is None:
        abort(503, description="Models not loaded.")

    lstm       = models.get("lstm")
    scaler     = models.get("lstm_scaler")
    lstm_meta  = models.get("lstm_meta")

    if lstm is None or scaler is None:
        abort(503, description="LSTM model not available. "
              "Run lstm_model.py first (requires TensorFlow).")

    data = request.get_json(force=True)
    required = ["recent_values"]
    missing  = [k for k in required if k not in data]
    if missing:
        abort(400, description=f"Missing required fields: {missing}")

    recent_values = data["recent_values"]
    steps         = int(data.get("steps", 1))
    hsn_code      = str(data.get("hsn_code", "unknown"))
    country       = str(data.get("country", "unknown"))
    look_back     = lstm_meta.get("look_back", 5) if lstm_meta else 5

    if len(recent_values) < look_back:
        abort(400, description=f"recent_values must contain at least {look_back} values "
              f"(look_back window = {look_back}).")

    try:
        import numpy as np
        vals = np.array(recent_values, dtype=np.float32).reshape(-1, 1)
        vals_scaled = scaler.transform(vals).flatten()

        window     = list(vals_scaled[-look_back:])
        forecasts  = []

        for _ in range(steps):
            x_input = np.array(window[-look_back:], dtype=np.float32).reshape(1, look_back, 1)
            pred_scaled = float(lstm.predict(x_input, verbose=0)[0, 0])
            pred_actual = float(scaler.inverse_transform([[pred_scaled]])[0, 0])
            forecasts.append(round(pred_actual, 2))
            window.append(pred_scaled)

        logger.info("forecast/lstm  HSN=%s  Country=%s  Steps=%d  Forecasts=%s",
                    hsn_code, country, steps, forecasts)

        return jsonify({
            "hsn_code":      hsn_code,
            "country":       country,
            "look_back":     look_back,
            "steps":         steps,
            "forecasts_usd": forecasts,
            "model": "Stacked LSTM (TensorFlow/Keras)",
        })
    except Exception as e:
        logger.error("LSTM forecast error: %s", e)
        abort(500, description=f"Forecast failed: {str(e)}")


# ─────────────────────────────────────────────
# ERROR HANDLERS
# ─────────────────────────────────────────────
@app.errorhandler(400)
def bad_request(e):
    return jsonify({"error": "Bad Request", "message": str(e.description)}), 400

@app.errorhandler(500)
def internal_error(e):
    return jsonify({"error": "Internal Server Error", "message": str(e.description)}), 500

@app.errorhandler(503)
def service_unavailable(e):
    return jsonify({"error": "Service Unavailable", "message": str(e.description)}), 503


# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────
if __name__ == "__main__":
    logger.info("Starting GlobalTradeIntel Flask API on port 5000 ...")
    logger.info("Endpoints: /health  /predict/price  /classify/trend  "
                "/recommend/suppliers  /recommend/collab  /forecast/lstm")
    app.run(host="0.0.0.0", port=5000, debug=False)
