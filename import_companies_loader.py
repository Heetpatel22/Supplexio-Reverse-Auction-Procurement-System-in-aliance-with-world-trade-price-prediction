"""
import_companies_loader.py
Parses ALL importing company CSV files from 'Import data main' folder.

Structure per product:
  Import data main/{HSN} {Product Name}_import/
      Trade_Map_-_List_of_importing_companies_in_India_for_the_following_product N_Table_1.csv
      Trade_Map_-_List_of_importing_companies_in_India_for_the_following_product_Table_1.csv

All files have consistent columns:
  Company name, Number of product or service categories traded,
  Number of employees, Turnover (USD), Country, City, Website

All companies are India-based (Indian importers of paint/chemical raw materials).
"""

import os
import re
import warnings
import pandas as pd
import logging

warnings.filterwarnings("ignore")
logger = logging.getLogger(__name__)

IMPORT_COMPANIES_PATH = os.path.join(os.path.dirname(__file__), "Import data main")

_RENAME = {
    "Company name":                                          "company_name",
    "Number of product or service categories traded":        "num_categories",
    "Number of employees":                                   "num_employees",
    "Turnover (USD)":                                        "turnover_usd",
    "Country":                                               "country",
    "City":                                                  "city",
    "Website":                                               "website",
}
_KEEP = ["hsn_code", "product_name", "company_name", "country", "city",
         "website", "num_categories", "num_employees", "turnover_usd", "trade_side"]


def _canonical_name(hsn: str) -> str:
    try:
        from trademap_data_loader import MARKET_PRICES
        if hsn in MARKET_PRICES:
            return MARKET_PRICES[hsn]["name"]
    except ImportError:
        pass
    return f"Product {hsn}"


def _parse_import_folder(folder_path: str, hsn: str, product_name: str) -> pd.DataFrame:
    """Parse all CSV files in one import product folder."""
    frames = []
    for fname in sorted(os.listdir(folder_path)):
        if not fname.endswith(".csv"):
            continue
        fpath = os.path.join(folder_path, fname)
        try:
            df = pd.read_csv(fpath, encoding="utf-8", on_bad_lines="skip")
            if df.empty or "Company name" not in df.columns:
                continue
            frames.append(df)
        except Exception as e:
            logger.debug(f"Skip {fpath}: {e}")

    if not frames:
        return pd.DataFrame()

    combined = pd.concat(frames, ignore_index=True)
    combined = combined.drop_duplicates(subset=["Company name"])
    combined = combined.rename(columns=_RENAME)
    combined["hsn_code"]     = hsn
    combined["product_name"] = product_name
    combined["trade_side"]   = "Importer"
    return combined[[c for c in _KEEP if c in combined.columns]]


def load_import_companies() -> pd.DataFrame:
    """
    Load all importing company records from 'Import data main'.
    These are Indian companies that import each product.

    Returns DataFrame with columns:
      hsn_code, product_name, company_name, country, city,
      website, num_categories, num_employees, turnover_usd, trade_side
    """
    if not os.path.exists(IMPORT_COMPANIES_PATH):
        logger.error(f"Import companies path not found: {IMPORT_COMPANIES_PATH}")
        return pd.DataFrame()

    frames = []
    for folder in sorted(os.listdir(IMPORT_COMPANIES_PATH)):
        full_path = os.path.join(IMPORT_COMPANIES_PATH, folder)
        if not os.path.isdir(full_path):
            continue
        # Extract HSN from folder name (strip dash or space variants)
        m = re.match(r"^(\d{5,6})", folder)
        if not m:
            continue
        hsn = m.group(1)
        product_name = _canonical_name(hsn)
        df = _parse_import_folder(full_path, hsn, product_name)
        if not df.empty:
            frames.append(df)
            logger.info(f"  Loaded {len(df):,} importers for HSN {hsn} — {os.path.basename(full_path)}")

    if not frames:
        return pd.DataFrame()

    all_companies = pd.concat(frames, ignore_index=True)
    all_companies = all_companies.drop_duplicates(subset=["hsn_code", "company_name"])
    all_companies["country"]  = all_companies["country"].astype(str).str.strip()
    all_companies["hsn_code"] = all_companies["hsn_code"].astype(str)
    all_companies = all_companies[
        all_companies["country"].notna() &
        (all_companies["country"] != "") &
        (all_companies["country"] != "nan")
    ]

    logger.info(
        f"Total import companies: {len(all_companies):,} | "
        f"Unique: {all_companies['company_name'].nunique():,} | "
        f"HSNs: {all_companies['hsn_code'].nunique()}"
    )
    return all_companies


# ── Singleton cache ──────────────────────────────────────────────────────────
_cache: dict = {}

def get_import_companies() -> pd.DataFrame:
    if "df" not in _cache:
        _cache["df"] = load_import_companies()
    return _cache["df"]


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    df = load_import_companies()
    print(f"\n{'='*50}")
    print(f"Total rows:        {len(df):,}")
    print(f"Unique companies:  {df['company_name'].nunique():,}")
    print(f"HSN codes:         {df['hsn_code'].nunique()}")
    print(f"Countries:         {df['country'].unique()}")
    print(f"\nTop 10 HSNs by importer count:")
    print(df.groupby(["hsn_code","product_name"])["company_name"].count().nlargest(10).to_string())
    print(f"\nTop 20 importing companies (by products imported):")
    print(df.groupby("company_name")["hsn_code"].nunique().nlargest(20).to_string())
