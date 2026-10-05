"""
recommendation_system.py
GlobalTradeIntel – Supplier & Market Recommendation Engine

Recommends the best procurement markets (countries) for a given
product-country pair using collaborative filtering on the global
trade matrix.

Two complementary approaches (as specified in the requirements doc):
  1. Collaborative Filtering  — user-item-style matrix factorisation
     (countries as "users", HSN codes as "items", trade value as "rating")
  2. Cosine Similarity Fallback — when matrix factorisation cannot run
     (e.g. too few entries, inference only)

Usage (API):
    from recommendation_system import TradeRecommender

    rec = TradeRecommender()
    rec.fit()                         # train on all CSV data

    results = rec.recommend_suppliers(
        hsn_code   = "320611",         # Titanium Dioxide
        buyer_country = "India",
        top_n      = 5
    )

    results = rec.recommend_markets(
        hsn_code   = "290220",         # Benzene
        top_n      = 5
    )

Output artefacts (saved to ml_artifacts/):
    model_svd.pkl        ← TruncatedSVD matrix factorisation model
    trade_matrix.pkl     ← HSN × Country trade-value pivot
    rec_meta.pkl         ← country & HSN index maps

Run standalone:
    python recommendation_system.py
"""

import os
import warnings
import logging
import numpy as np
import pandas as pd
import joblib
import mlflow

from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler

warnings.filterwarnings("ignore")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# ─── Paths ───────────────────────────────────────────────────────────────────
ARTIFACTS_DIR       = os.path.join(os.path.dirname(__file__), "ml_artifacts")
MLFLOW_TRACKING_URI = "file:" + os.path.join(os.path.dirname(__file__), "mlruns").replace("\\", "/")
MLFLOW_EXPERIMENT   = "GlobalTradeIntel"
os.makedirs(ARTIFACTS_DIR, exist_ok=True)

# ─── SVD configuration ───────────────────────────────────────────────────────
SVD_COMPONENTS   = 20      # latent factors; tuned via reconstruction error
SVD_RANDOM_STATE = 42


# ─────────────────────────────────────────────────────────────────────────────
# TradeRecommender class
# ─────────────────────────────────────────────────────────────────────────────
class TradeRecommender:
    """
    Collaborative-filtering recommendation system for global trade data.

    The trade matrix T is built as:
        rows    = HSN codes   (products)
        columns = Countries
        values  = Total trade turnover (USD), summed across all years

    TruncatedSVD decomposes T ≈ U × Σ × Vᵀ, producing dense latent-factor
    embeddings for both products and countries. Cosine similarity on these
    embeddings powers both supplier and market recommendations.
    """

    def __init__(self, n_components: int = SVD_COMPONENTS):
        self.n_components  = n_components
        self.svd           = None
        self.trade_matrix  = None          # raw pivot (HSN × Country)
        self.trade_matrix_filled = None    # NaN → 0 version used by SVD
        self.hsn_embeddings     = None     # shape (n_hsn, n_components)
        self.country_embeddings = None     # shape (n_countries, n_components)
        self.hsn_index     = {}            # hsn_code → row index
        self.country_index = {}            # country  → col index
        self.scaler        = MinMaxScaler()
        self._fitted       = False

    # ── 1. Data loading ───────────────────────────────────────────────────────
    def _load_data(self) -> pd.DataFrame:
        """
        Load pre-processed y_train.parquet from ml_artifacts/ which contains
        HSN_Code, Country, Year and Total_Turnover columns.
        Falls back to direct CSV scan if parquet not available.
        """
        parquet_path = os.path.join(ARTIFACTS_DIR, "y_train.parquet")
        if os.path.exists(parquet_path):
            logger.info("Loading from y_train.parquet ...")
            df = pd.read_parquet(parquet_path)
        else:
            # Fallback: read from CSV_Data if available
            csv_path = os.path.join(os.path.dirname(__file__), "CSV_Data",
                                    "trademap_export_by_country.csv")
            if not os.path.exists(csv_path):
                raise FileNotFoundError(
                    "Run ml_preprocessing.py first to generate ml_artifacts/y_train.parquet, "
                    "or ensure CSV_Data/trademap_export_by_country.csv exists."
                )
            logger.info("Falling back to CSV_Data ...")
            df = pd.read_csv(csv_path)
            df.rename(columns={
                "HSN_Code": "HSN_Code",
                "Country":  "Country",
                "Turnover_Calculated": "Total_Turnover",
            }, inplace=True)

        required = {"HSN_Code", "Country", "Total_Turnover"}
        missing  = required - set(df.columns)
        if missing:
            raise ValueError(f"Missing columns in data: {missing}")

        df["Total_Turnover"] = pd.to_numeric(df["Total_Turnover"], errors="coerce").fillna(0)
        df = df[df["Total_Turnover"] > 0]
        logger.info("Loaded %d records across %d HSN codes and %d countries.",
                    len(df), df["HSN_Code"].nunique(), df["Country"].nunique())
        return df

    # ── 2. Build trade matrix ─────────────────────────────────────────────────
    def _build_trade_matrix(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Aggregate by HSN × Country and pivot into a trade matrix.
        Values are total turnover (USD) summed across all years.
        """
        agg = (
            df.groupby(["HSN_Code", "Country"])["Total_Turnover"]
            .sum()
            .reset_index()
        )
        matrix = agg.pivot(index="HSN_Code", columns="Country", values="Total_Turnover")
        logger.info("Trade matrix: %d products × %d countries (%.1f%% dense).",
                    matrix.shape[0], matrix.shape[1],
                    100 * matrix.notna().values.mean())
        return matrix

    # ── 3. Fit SVD ────────────────────────────────────────────────────────────
    def fit(self) -> "TradeRecommender":
        """
        Full training pipeline:
          load → build matrix → scale → SVD decomposition → save artefacts
        """
        print("\n" + "─" * 60)
        print("  Recommendation System — Collaborative Filtering (SVD)")
        print("─" * 60)

        df = self._load_data()
        self.trade_matrix = self._build_trade_matrix(df)

        # Store index maps
        self.hsn_index     = {code: i for i, code in enumerate(self.trade_matrix.index)}
        self.country_index = {name: j for j, name in enumerate(self.trade_matrix.columns)}

        # Fill NaN with 0 for matrix factorisation
        M = self.trade_matrix.fillna(0).values.astype(np.float64)

        # Scale each HSN row to [0, 1] so dominant products don't overwhelm
        M_scaled = self.scaler.fit_transform(M.T).T  # scale per HSN code

        # Truncated SVD
        n_comp = min(self.n_components, min(M_scaled.shape) - 1)
        self.svd = TruncatedSVD(n_components=n_comp, random_state=SVD_RANDOM_STATE)
        self.hsn_embeddings = self.svd.fit_transform(M_scaled)   # (n_hsn, n_comp)
        self.country_embeddings = self.svd.components_.T          # (n_countries, n_comp)

        explained = self.svd.explained_variance_ratio_.sum()
        print(f"  ✓ SVD ({n_comp} components): {explained*100:.1f}% variance retained")

        self._fitted = True
        self._save_artifacts()
        self._log_to_mlflow(explained, n_comp)
        return self

    # ── 4. Recommend supplier countries ──────────────────────────────────────
    def recommend_suppliers(self, hsn_code: str, buyer_country: str = None,
                            top_n: int = 5) -> pd.DataFrame:
        """
        Recommend top exporting countries for a given HSN code.

        Strategy:
          1. Find the SVD embedding for the queried HSN code.
          2. Compute cosine similarity between this embedding and all country
             embeddings (countries that co-trade in similar product patterns).
          3. Rank countries by (similarity × raw trade value) to surface
             high-volume, high-relevance exporters.
          4. Exclude the buyer's own country if provided.

        Returns a DataFrame with columns:
            country, trade_value_usd, similarity_score, recommendation_score, rank
        """
        self._check_fitted()

        if hsn_code not in self.hsn_index:
            logger.warning("HSN code '%s' not seen during training. "
                           "Falling back to raw trade value ranking.", hsn_code)
            return self._fallback_recommend(hsn_code, buyer_country, top_n)

        hsn_idx = self.hsn_index[hsn_code]
        hsn_vec = self.hsn_embeddings[hsn_idx].reshape(1, -1)

        # Cosine similarity: HSN embedding vs. all country embeddings
        sims = cosine_similarity(hsn_vec, self.country_embeddings)[0]  # (n_countries,)

        # Raw trade value for this HSN across countries
        if hsn_code in self.trade_matrix.index:
            raw_values = self.trade_matrix.loc[hsn_code].fillna(0).values
        else:
            raw_values = np.zeros(len(self.country_index))

        # Scale raw values to [0, 1] for combining with similarity
        max_val = raw_values.max() if raw_values.max() > 0 else 1
        norm_values = raw_values / max_val

        # Combined recommendation score
        rec_scores = 0.5 * np.clip(sims, 0, 1) + 0.5 * norm_values

        countries = list(self.country_index.keys())
        results   = pd.DataFrame({
            "country":            countries,
            "trade_value_usd":    raw_values,
            "similarity_score":   sims,
            "recommendation_score": rec_scores,
        })

        # Exclude buyer country
        if buyer_country:
            buyer_norm = buyer_country.strip().title()
            results = results[results["country"].str.title() != buyer_norm]

        # Exclude zero-trade countries
        results = results[results["trade_value_usd"] > 0]

        top = (
            results
            .sort_values("recommendation_score", ascending=False)
            .head(top_n)
            .reset_index(drop=True)
        )
        top["rank"] = top.index + 1
        return top

    # ── 5. Recommend markets for a product ───────────────────────────────────
    def recommend_markets(self, hsn_code: str, top_n: int = 5) -> pd.DataFrame:
        """
        Recommend top import-demand markets for a given HSN code.
        Uses the same SVD approach but ranks by import-side trade value.
        """
        return self.recommend_suppliers(hsn_code, buyer_country=None, top_n=top_n)

    # ── 6. Find similar products ──────────────────────────────────────────────
    def find_similar_products(self, hsn_code: str, top_n: int = 5) -> pd.DataFrame:
        """
        Returns HSN codes with the most similar trade patterns (cosine similarity
        in SVD latent space) to the queried product.
        """
        self._check_fitted()

        if hsn_code not in self.hsn_index:
            return pd.DataFrame(columns=["hsn_code", "similarity"])

        hsn_idx = self.hsn_index[hsn_code]
        hsn_vec = self.hsn_embeddings[hsn_idx].reshape(1, -1)

        sims    = cosine_similarity(hsn_vec, self.hsn_embeddings)[0]
        sims[hsn_idx] = -1  # exclude self

        hsn_codes = list(self.hsn_index.keys())
        results   = pd.DataFrame({"hsn_code": hsn_codes, "similarity": sims})
        top = results.nlargest(top_n, "similarity").reset_index(drop=True)
        top["rank"] = top.index + 1
        return top

    # ── 7. Fallback (raw value ranking) ───────────────────────────────────────
    def _fallback_recommend(self, hsn_code: str, buyer_country: str,
                             top_n: int) -> pd.DataFrame:
        """Pure trade-value ranking when SVD has no embedding for the HSN."""
        if self.trade_matrix is not None and hsn_code in self.trade_matrix.index:
            row = self.trade_matrix.loc[hsn_code].fillna(0)
            if buyer_country:
                row = row[row.index.str.title() != buyer_country.strip().title()]
            row = row[row > 0].sort_values(ascending=False).head(top_n)
            df  = row.reset_index()
            df.columns = ["country", "trade_value_usd"]
            df["similarity_score"]      = float("nan")
            df["recommendation_score"]  = df["trade_value_usd"] / df["trade_value_usd"].max()
            df["rank"] = range(1, len(df) + 1)
            return df
        return pd.DataFrame(columns=["country", "trade_value_usd",
                                      "similarity_score", "recommendation_score", "rank"])

    # ── 8. Load saved artefacts ────────────────────────────────────────────────
    @classmethod
    def load(cls) -> "TradeRecommender":
        """Restore a previously fitted recommender from ml_artifacts/."""
        meta_path = os.path.join(ARTIFACTS_DIR, "rec_meta.pkl")
        if not os.path.exists(meta_path):
            raise FileNotFoundError(
                "No saved recommender found in ml_artifacts/. "
                "Run TradeRecommender().fit() first."
            )
        meta = joblib.load(meta_path)
        rec  = cls(n_components=meta["n_components"])
        rec.svd                  = joblib.load(os.path.join(ARTIFACTS_DIR, "model_svd.pkl"))
        rec.trade_matrix         = joblib.load(os.path.join(ARTIFACTS_DIR, "trade_matrix.pkl"))
        rec.trade_matrix_filled  = rec.trade_matrix.fillna(0)
        rec.hsn_index            = meta["hsn_index"]
        rec.country_index        = meta["country_index"]
        rec.hsn_embeddings       = meta["hsn_embeddings"]
        rec.country_embeddings   = meta["country_embeddings"]
        rec.scaler               = meta["scaler"]
        rec._fitted              = True
        logger.info("TradeRecommender loaded from ml_artifacts/.")
        return rec

    # ── 9. Persistence ─────────────────────────────────────────────────────────
    def _save_artifacts(self):
        """Serialise all components to ml_artifacts/."""
        joblib.dump(self.svd,          os.path.join(ARTIFACTS_DIR, "model_svd.pkl"))
        joblib.dump(self.trade_matrix, os.path.join(ARTIFACTS_DIR, "trade_matrix.pkl"))
        joblib.dump({
            "n_components":      self.n_components,
            "hsn_index":         self.hsn_index,
            "country_index":     self.country_index,
            "hsn_embeddings":    self.hsn_embeddings,
            "country_embeddings": self.country_embeddings,
            "scaler":            self.scaler,
        }, os.path.join(ARTIFACTS_DIR, "rec_meta.pkl"))

        print(f"  ✓ model_svd.pkl       → {ARTIFACTS_DIR}")
        print(f"  ✓ trade_matrix.pkl    → {ARTIFACTS_DIR}")
        print(f"  ✓ rec_meta.pkl        → {ARTIFACTS_DIR}")

    def _log_to_mlflow(self, explained_variance: float, n_components: int):
        mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
        mlflow.set_experiment(MLFLOW_EXPERIMENT)
        with mlflow.start_run(run_name="RecommendationSystem_SVD_CollabFilter"):
            mlflow.log_params({
                "model":               "TruncatedSVD_CollaborativeFiltering",
                "n_components":        n_components,
                "n_hsn_codes":         len(self.hsn_index),
                "n_countries":         len(self.country_index),
                "matrix_density_pct":  round(
                    100 * self.trade_matrix.notna().values.mean(), 2),
            })
            mlflow.log_metrics({
                "svd_explained_variance": explained_variance,
                "n_products":   float(len(self.hsn_index)),
                "n_countries":  float(len(self.country_index)),
            })
        print("  ✓ MLflow   → run 'RecommendationSystem_SVD_CollabFilter'")

    def _check_fitted(self):
        if not self._fitted:
            raise RuntimeError("Call .fit() or .load() before making recommendations.")


# ─────────────────────────────────────────────────────────────────────────────
# MAIN — standalone demo
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 70)
    print("  GlobalTradeIntel — Recommendation System (Collaborative Filtering)")
    print("=" * 70)

    rec = TradeRecommender(n_components=SVD_COMPONENTS)
    rec.fit()

    # ── Demo recommendations ──────────────────────────────────────────────────
    demo_queries = [
        ("320611", "India"),    # Titanium Dioxide (TiO2)
        ("290220", "Germany"),  # Benzene
        ("280300", "USA"),      # Carbon Black
    ]

    print("\n" + "═" * 70)
    print("  Sample Recommendations")
    print("═" * 70)
    for hsn, buyer in demo_queries:
        print(f"\n  ► HSN {hsn} | Buyer: {buyer}")
        recs = rec.recommend_suppliers(hsn_code=hsn, buyer_country=buyer, top_n=5)
        if recs.empty:
            print("    No recommendations available for this query.")
        else:
            print(recs[["rank", "country", "trade_value_usd",
                         "recommendation_score"]].to_string(index=False))

    print("\n" + "=" * 70)
    print("  ✅  Recommendation system trained and saved to ml_artifacts/")
    print("      model_svd.pkl        ← TruncatedSVD collaborative filter")
    print("      trade_matrix.pkl     ← HSN × Country trade matrix")
    print("      rec_meta.pkl         ← index maps + embeddings")
    print("      MLflow run logged under 'GlobalTradeIntel' experiment")
    print("=" * 70)
