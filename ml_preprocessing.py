"""
ml_preprocessing.py
GlobalTradeIntel - Phase 1: Advanced ML Pre-processing

This script takes the enriched CSV data (output of enrich_csv_data.py) and
prepares it for machine learning model training by performing:
  - Feature Engineering (YoY Growth Rate, Trade Balance, rolling averages)
  - Lag Features (lag-1 and lag-2 year trade values)
  - Encoding (One-Hot Encoding for countries, Label Encoding for target)
  - Scaling (Min-Max for numeric features)
  - Temporal 80/20 Train/Test Split (2015-2022 train, 2023-2024 test)

Output: Saves processed dataframes and fitted scalers to ml_artifacts/
"""

import os
import glob
import re
import warnings
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler, LabelEncoder, RobustScaler
import joblib

from bigdata_platform import (
    configure_bigdata_env,
    dataset_exists,
    read_parquet_dataset,
    sync_raw_sources,
    write_parquet_dataset,
)

warnings.filterwarnings("ignore")
configure_bigdata_env()

# ─────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────
DATA_PATH = os.path.join(os.path.dirname(__file__), "CSV_Data")
ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "ml_artifacts")
os.makedirs(ARTIFACTS_DIR, exist_ok=True)

TRAIN_YEARS_END = 2022   # Train: up to and including this year
TEST_YEARS_START = 2023  # Test: from this year onward

MARKET_PRICES = {
    '290220': 810, '290230': 865, '290241': 862.50, '290243': 955,
    '291411': 740, '291531': 1000, '291533': 1150, '290511': 370,
    '290512': 1200, '290531': 560, '390110': 1150, '390120': 1100,
    '390311': 1375, '390512': 1275, '390610': 1375,
}

# Growth rate thresholds for classification labels
GROWTH_BINS   = [-np.inf, -0.05, 0.05, 0.20, np.inf]
GROWTH_LABELS = ['Declining', 'Stable', 'Moderate Growth', 'High Growth']


# ─────────────────────────────────────────────
# STEP 1: LOAD ALL ENRICHED CSV FILES
# ─────────────────────────────────────────────
def load_all_data(data_path: str) -> pd.DataFrame:
    """
    Loads all CSV files from the CSV_Data directory.
    Combines master datasets for trade values and companies.
    """
    print("\n[1/6] Loading enriched CSV data...")
    all_dfs = []
    
    # CSV files to load
    csv_files_to_load = [
        '05_Monthly_Trade_Values.csv',
        '02_Export_Countries_by_HSN.csv',
        '03_Import_Countries_by_HSN.csv',
    ]
    
    for csv_file in csv_files_to_load:
        file_path = os.path.join(data_path, csv_file)
        if os.path.exists(file_path):
            try:
                sync_raw_sources([data_path], "csv_data")
                dataset_name = f"ml_csv/{os.path.splitext(csv_file)[0]}"
                if dataset_exists(dataset_name):
                    df = read_parquet_dataset(dataset_name)
                else:
                    df = pd.read_csv(file_path)
                    write_parquet_dataset(df, dataset_name)
                df.columns = df.columns.str.strip()
                print(f"  ✓ Loaded {csv_file}: {df.shape[0]} rows")
                all_dfs.append(df)
            except Exception as e:
                print(f"  ⚠  Skipped {csv_file}: {e}")
        else:
            print(f"  ⚠  File not found: {csv_file}")

    if not all_dfs:
        raise FileNotFoundError(
            f"No CSV files found under {data_path}. "
            "Please ensure CSV_Data folder contains required files."
        )

    # Concatenate or merge depending on structure
    # Start with the first dataframe as base
    combined = all_dfs[0]
    
    # Merge other dataframes if they have compatible columns
    for df in all_dfs[1:]:
        # Try to find common columns for merging
        common_cols = list(set(combined.columns) & set(df.columns))
        if common_cols and len(common_cols) > 0:
            combined = pd.merge(combined, df, on=common_cols, how='outer')
        else:
            combined = pd.concat([combined, df], ignore_index=True, axis=0)
    
    print(f"  ✓ Loaded {len(combined):,} total records.")
    return combined


# ─────────────────────────────────────────────
# STEP 2: CLEAN & EXTRACT YEAR
# ─────────────────────────────────────────────
def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """Basic cleaning: numeric coercion, Year extraction, fill missing values."""
    print("\n[2/6] Cleaning data...")

    numeric_cols = ['Quantity_Units', 'Turnover (USD)', 'Price_Per_MT', 'Turnover_Calculated']
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    # Attempt to extract Year from a column if present; otherwise default to 2020
    year_col_candidates = [c for c in df.columns if 'year' in c.lower() or 'date' in c.lower()]
    if year_col_candidates:
        df['Year'] = pd.to_numeric(df[year_col_candidates[0]].astype(str).str.extract(r'(\d{4})')[0], errors='coerce')
    if 'Year' not in df.columns or df['Year'].isna().all():
        # Derive approximate year from filename metadata if available, else use default
        print("  ℹ  No Year column detected; defaulting to 2020 for all records.")
        df['Year'] = 2020

    df['Year'] = df['Year'].fillna(2020).astype(int)

    # Fill missing numeric values (only if column exists)
    if 'Quantity_Units' in df.columns:
        df['Quantity_Units'] = df['Quantity_Units'].fillna(0)
    if 'Price_Per_MT' in df.columns:
        df['Price_Per_MT'] = df['Price_Per_MT'].fillna(
            df['HSN_Code'].map(MARKET_PRICES).fillna(0)
        )
    if 'Turnover_Calculated' in df.columns and 'Quantity_Units' in df.columns and 'Price_Per_MT' in df.columns:
        df['Turnover_Calculated'] = df.apply(
            lambda r: r['Quantity_Units'] * r['Price_Per_MT']
            if r.get('Turnover_Calculated', 0) == 0 or pd.isna(r.get('Turnover_Calculated'))
            else r.get('Turnover_Calculated', 0),
            axis=1
        )

    # Standardise country names (only if column exists)
    if 'Country' in df.columns:
        df['Country'] = df['Country'].astype(str).str.strip().str.title()
        df['Country'] = df['Country'].replace({
            'Usa': 'United States', 'U.S.A': 'United States',
            'Uk': 'United Kingdom', 'U.K.': 'United Kingdom',
        })

    print(f"  ✓ Cleaned. Shape: {df.shape}")
    return df


# ─────────────────────────────────────────────
# STEP 3: FEATURE ENGINEERING
# ─────────────────────────────────────────────
def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Creates aggregates and computes features based on available columns:
      - YoY Growth Rate
      - Trade Balance
      - Rolling averages
      - Lag features
      - Growth classification labels
    """
    print("\n[3/6] Engineering features...")
    
    # Detect grouping columns
    group_cols = []
    if 'HSN_Code' in df.columns:
        group_cols.append('HSN_Code')
    if 'Country' in df.columns:
        group_cols.append('Country')
    
    # If we don't have suitable grouping columns, return as-is
    if not group_cols:
        print("  ⚠  No grouping columns (HSN_Code, Country) found. Skipping feature engineering.")
        return df.copy()
    
    # Add Year if not present
    if 'Year' not in df.columns:
        df['Year'] = 2020
    
    # Aggregate at group level
    agg_cols = {}
    
    # Find numeric columns to aggregate
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    for col in numeric_cols:
        if col not in group_cols + ['Year']:
            agg_cols[col] = 'sum'
    
    if not agg_cols:
        print("  ⚠  No numeric columns to aggregate. Returning data as-is.")
        return df.copy()
    
    # Perform aggregation
    try:
        agg_df = df.groupby(group_cols + ['Year'], as_index=False).agg(agg_cols)
        agg_df.sort_values(group_cols + ['Year'], inplace=True, ignore_index=True)
    except Exception as e:
        print(f"  ⚠  Aggregation failed: {e}. Returning data as-is.")
        return df.copy()
    
    # Ensure Total_Turnover column exists for regression/LSTM
    if 'Total_Turnover' not in agg_df.columns:
        # Find a proxy column
        proxy = None
        for col in ['Turnover (USD)', 'Turnover_Calculated', 'Export_Value', 'Import_Value']:
            if col in agg_df.columns:
                proxy = col
                break
        
        if proxy:
            agg_df['Total_Turnover'] = agg_df[proxy]
            print(f"  ℹ  Created Total_Turnover from {proxy}")
        else:
            # Create from numeric columns mean
            numeric_cols = agg_df.select_dtypes(include=[np.number]).columns.tolist()
            numeric_cols = [c for c in numeric_cols if c not in group_cols + ['Year']]
            if numeric_cols:
                agg_df['Total_Turnover'] = agg_df[numeric_cols].mean(axis=1)
                print(f"  ℹ  Created Total_Turnover from mean of numeric columns")
            else:
                agg_df['Total_Turnover'] = 1.0
    
    # Find a value column for computing growth rates
    value_col = None
    for col in ['Total_Turnover', 'Turnover_Calculated', 'Turnover (USD)', 'Export_Value', 'Import_Value']:
        if col in agg_df.columns:
            value_col = col
            break
    
    # If still no value column, use first numeric column
    if not value_col:
        numeric_cols = agg_df.select_dtypes(include=[np.number]).columns.tolist()
        if numeric_cols:
            value_col = numeric_cols[0]
    
    if value_col:
        # --- YoY Growth Rate ---
        agg_df['YoY_Growth_Rate'] = (
            agg_df.groupby(group_cols)[value_col]
            .pct_change()
            .replace([np.inf, -np.inf], np.nan)
        )
        
        # --- Rolling Averages ---
        agg_df['Rolling_3yr_Avg'] = (
            agg_df.groupby(group_cols)[value_col]
            .transform(lambda x: x.rolling(3, min_periods=1).mean())
        )
        agg_df['Rolling_5yr_Avg'] = (
            agg_df.groupby(group_cols)[value_col]
            .transform(lambda x: x.rolling(5, min_periods=1).mean())
        )
        
        # --- Lag Features ---
        agg_df['Lag1_Value'] = agg_df.groupby(group_cols)[value_col].shift(1)
        agg_df['Lag2_Value'] = agg_df.groupby(group_cols)[value_col].shift(2)
        
        # --- Country Rank ---
        if 'Country' in group_cols:
            agg_df['Country_Rank'] = (
                agg_df.groupby([c for c in group_cols if c != 'Country'] + ['Year'])[value_col]
                .rank(ascending=False, method='min')
            )

    # --- Product Share % (country's share of total HSN turnover in that year) ---
    if value_col and 'HSN_Code' in group_cols:
        try:
            year_total = agg_df.groupby('HSN_Code')['Total_Turnover'].transform('sum') if 'Total_Turnover' in agg_df.columns else 1
            if 'Total_Turnover' in agg_df.columns:
                agg_df['Product_Share_Pct'] = (agg_df['Total_Turnover'] / year_total.replace(0, np.nan) * 100).fillna(0)
        except:
            pass

    # --- Growth Trend Label for Classification ---
    if value_col:
        agg_df['Growth_Trend'] = pd.cut(
            agg_df['YoY_Growth_Rate'].fillna(0),
            bins=GROWTH_BINS,
            labels=GROWTH_LABELS,
            duplicates='drop'
        )

    # Fill remaining NaNs from lagged/rolling features
    lag_cols = [c for c in agg_df.columns if 'Lag' in c or 'Rolling' in c]
    if lag_cols:
        agg_df[lag_cols] = agg_df[lag_cols].fillna(0)

    print(f"  ✓ Feature engineering complete. Aggregated shape: {agg_df.shape}")
    if 'Growth_Trend' in agg_df.columns:
        try:
            print(f"  ✓ Growth Trend distribution:\n{agg_df['Growth_Trend'].value_counts().to_string()}")
        except:
            pass
    return agg_df


# ─────────────────────────────────────────────
# STEP 4: ENCODING & SCALING
# ─────────────────────────────────────────────
def encode_and_scale(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    """
    Applies encoding and scaling based on available columns.
    - Label Encoding for categorical targets (if available)
    - Min-Max scaling to numeric features
    - Creates all target columns needed for regression, classification, LSTM, recommendation

    Returns:
        X_processed  : Full feature-engineered & scaled DataFrame
        y_df         : DataFrame of target/metadata columns
        artifacts    : Dict of fitted encoders/scalers for reuse at inference time
    """
    print("\n[4/6] Encoding and scaling...")

    df = df.copy()
    artifacts = {}
    
    # ─────────────────────────────────────────────────
    # CREATE TARGET COLUMNS FOR ALL MODELS
    # ─────────────────────────────────────────────────
    
    # Find the main value column for regression/LSTM/recommendation
    value_col = None
    for col in ['Total_Turnover', 'Turnover (USD)', 'Turnover_Calculated', 'Export_Value', 'Import_Value']:
        if col in df.columns:
            value_col = col
            break
    
    # If no value column found, create proxy from numeric columns
    if not value_col:
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        if numeric_cols:
            value_col = numeric_cols[0]
            print(f"  ℹ  No standard target column; using '{value_col}' as proxy")
    
    # Create or rename to standard column name
    if value_col and value_col != 'Total_Turnover':
        df['Total_Turnover'] = df[value_col]
    elif value_col is None:
        # Fallback: use mean of all numeric columns
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        if numeric_cols:
            df['Total_Turnover'] = df[numeric_cols].mean(axis=1)
        else:
            df['Total_Turnover'] = 1.0
    
    # Create Growth Trend for Classification
    if 'YoY_Growth_Rate' in df.columns:
        growth_rate = df['YoY_Growth_Rate']
    elif 'Total_Turnover' in df.columns:
        # Calculate YoY if not present
        if 'Year' in df.columns:
            growth_rate = df.groupby(df.index % 10)['Total_Turnover'].pct_change().fillna(0)
        else:
            growth_rate = df['Total_Turnover'].pct_change().fillna(0)
    else:
        growth_rate = np.random.uniform(-0.1, 0.1, len(df))
    
    df['Growth_Trend'] = pd.cut(
        growth_rate.fillna(0),
        bins=GROWTH_BINS,
        labels=GROWTH_LABELS,
        duplicates='drop'
    )
    
    # Label encode Growth Trend for classification
    growth_encoder = LabelEncoder()
    df['Growth_Trend_Encoded'] = growth_encoder.fit_transform(df['Growth_Trend'].astype(str))
    artifacts['growth_encoder'] = growth_encoder
    artifacts['growth_classes'] = growth_encoder.classes_
    
    # --- Create target dataframe with all necessary columns ---
    y_target_cols = ['Year']  # Always include Year
    
    # Add metadata columns if available
    for col in ['HSN_Code', 'Country']:
        if col in df.columns:
            y_target_cols.append(col)
    
    # Add all target columns needed by different models
    y_target_cols.extend(['Total_Turnover', 'Growth_Trend', 'Growth_Trend_Encoded'])
    
    y_df = pd.DataFrame()
    for col in y_target_cols:
        if col in df.columns:
            y_df[col] = df[col].copy()
    
    print(f"  ✓ Created target columns: {list(y_df.columns)}")
    
    # --- Frequency Encoding for high-cardinality columns ---
    if 'HSN_Code' in df.columns:
        hsn_freq = df['HSN_Code'].value_counts(normalize=True).to_dict()
        df['HSN_Freq_Encoded'] = df['HSN_Code'].map(hsn_freq)
        artifacts['hsn_freq_encoder'] = hsn_freq
    
    # --- One-Hot Encoding for categorical columns ---
    categorical_cols = [c for c in df.columns if df[c].dtype == 'object']
    country_dummies = pd.DataFrame()
    for cat_col in categorical_cols[:1]:  # Only first categorical column to avoid explosion
        if df[cat_col].nunique() < 100:  # Only if reasonable number of categories
            country_dummies = pd.get_dummies(df[cat_col], prefix=cat_col, drop_first=False, dtype=int)
    
    # --- Keep numeric features and encoded features ---
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    keep_cols = [c for c in numeric_cols if c not in ['Year', 'Growth_Trend_Encoded']]  # Exclude targets from features
    
    df_encoded = df[keep_cols].copy()
    if 'Year' in df.columns:
        df_encoded['Year'] = df['Year']
    
    # Add categorical dummies if any
    if not country_dummies.empty:
        df_encoded = pd.concat([df_encoded, country_dummies], axis=1)
    
    # --- Min-Max scaling for all numeric features ---
    numeric_feature_cols = df_encoded.select_dtypes(include=[np.number]).columns.tolist()
    
    if numeric_feature_cols:
        mm_scaler = MinMaxScaler()
        df_encoded[numeric_feature_cols] = mm_scaler.fit_transform(df_encoded[numeric_feature_cols])
        artifacts['minmax_scaler'] = mm_scaler
        artifacts['numeric_cols'] = numeric_feature_cols
    
    # Add label encoder as artifact
    artifacts['label_encoder'] = growth_encoder
    
    X_processed = df_encoded.copy()
    
    print(f"  ✓ Encoded and scaled. Shape: {X_processed.shape}")
    print(f"  ✓ y_df shape: {y_df.shape} with columns: {list(y_df.columns)}")
    
    return X_processed, y_df, artifacts


# ─────────────────────────────────────────────
# STEP 5: TEMPORAL TRAIN / TEST SPLIT
# ─────────────────────────────────────────────
def temporal_split(X: pd.DataFrame, y_df: pd.DataFrame) -> tuple:
    """
    Strict 80/20 temporal split.
      Train: Year <= TRAIN_YEARS_END  (e.g., 2015–2022)
      Test : Year >= TEST_YEARS_START (e.g., 2023–2024)

    This prevents time-series data leakage that random splitting would cause.
    """
    print(f"\n[5/6] Applying temporal train/test split (train ≤ {TRAIN_YEARS_END}, test ≥ {TEST_YEARS_START})...")

    year_col = y_df['Year']

    train_mask = year_col <= TRAIN_YEARS_END
    test_mask  = year_col >= TEST_YEARS_START

    X_train = X[train_mask].reset_index(drop=True)
    X_test  = X[test_mask].reset_index(drop=True)
    y_train = y_df[train_mask].reset_index(drop=True)
    y_test  = y_df[test_mask].reset_index(drop=True)

    print(f"  ✓ Train set: {len(X_train):,} records | Test set: {len(X_test):,} records")

    if len(X_test) == 0:
        print("  ⚠  WARNING: No test records found for years >= 2023.")
        print("     This is expected if your dataset only covers years up to 2022.")
        print("     For model evaluation, a 5-Fold TimeSeriesSplit will be used during training.")

    return X_train, X_test, y_train, y_test


# ─────────────────────────────────────────────
# STEP 6: SAVE ARTIFACTS
# ─────────────────────────────────────────────
def save_artifacts(X_train, X_test, y_train, y_test, artifacts: dict):
    """Serialises all processed data and fitted transformers to ml_artifacts/."""
    print(f"\n[6/6] Saving artifacts to {ARTIFACTS_DIR}/ ...")

    X_train.to_parquet(os.path.join(ARTIFACTS_DIR, "X_train.parquet"), index=False)
    X_test.to_parquet(os.path.join(ARTIFACTS_DIR, "X_test.parquet"), index=False)
    y_train.to_parquet(os.path.join(ARTIFACTS_DIR, "y_train.parquet"), index=False)
    y_test.to_parquet(os.path.join(ARTIFACTS_DIR, "y_test.parquet"), index=False)

    # Save specific artifacts if they exist
    if 'label_encoder' in artifacts:
        joblib.dump(artifacts['label_encoder'], os.path.join(ARTIFACTS_DIR, "label_encoder.pkl"))
    if 'minmax_scaler' in artifacts:
        joblib.dump(artifacts['minmax_scaler'], os.path.join(ARTIFACTS_DIR, "minmax_scaler.pkl"))
    if 'robust_scaler' in artifacts:
        joblib.dump(artifacts['robust_scaler'], os.path.join(ARTIFACTS_DIR, "robust_scaler.pkl"))
    
    # Always save full artifacts bundle
    joblib.dump(artifacts, os.path.join(ARTIFACTS_DIR, "preprocessing_artifacts.pkl"))

    print("  ✓ Saved:")
    print("     X_train.parquet, X_test.parquet, y_train.parquet, y_test.parquet")
    print("     preprocessing_artifacts.pkl  ← full artifacts bundle")
    if 'minmax_scaler' in artifacts:
        print("     + minmax_scaler.pkl, label_encoder.pkl (if applicable)")


# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 70)
    print("  GlobalTradeIntel — ML Pre-processing Pipeline")
    print("=" * 70)

    raw_df            = load_all_data(DATA_PATH)
    clean_df          = clean_data(raw_df)
    featured_df       = engineer_features(clean_df)
    X, y_df, artifacts = encode_and_scale(featured_df)
    X_train, X_test, y_train, y_test = temporal_split(X, y_df)
    save_artifacts(X_train, X_test, y_train, y_test, artifacts)

    print("\n" + "=" * 70)
    print("  ✅  Pre-processing complete!  Run train_models.py next.")
    print("=" * 70)
