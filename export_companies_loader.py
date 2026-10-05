"""
export_companies_loader.py
Parses ALL exporting company data from two sources:

1. 'Export data Main' folder — CSV files per product:
   - Pattern A: Table_1.csv, Table_3.csv ... (odd = data, even = headers)
   - Pattern B: 'Table_1 (2).csv' variant (same data, deduplicated)
   - Pattern C: 'Trade_Map_-_List_of_exporting_companies...' files (header-only stubs, skip)

2. 'CSV_Data/01_Master_Companies.csv' — covers HSNs whose Export data Main
   files are stubs (e.g. 290220 Benzene, 290230 Toluene, 290531 Ethylene Glycol).

Both are merged and deduplicated to produce one unified companies DataFrame.
"""

import os
import re
import warnings
import pandas as pd
import logging

warnings.filterwarnings("ignore")
logger = logging.getLogger(__name__)

EXPORT_COMPANIES_PATH = os.path.join(os.path.dirname(__file__), "Export data Main")
MASTER_CSV_PATH       = os.path.join(os.path.dirname(__file__), "CSV_Data", "01_Master_Companies.csv")

# Additional HSN codes from the Export data Main folder not in trademap_data_loader
EXTRA_MARKET_PRICES = {
    '283325': {'name': 'Copper Sulphate',                        'price': 1400,  'unit': 'MT'},
    '283650': {'name': 'Calcium Carbonate',                      'price': 130,   'unit': 'MT'},
    '291122': {'name': 'Silicon Dioxide (Silica)',                'price': 875,   'unit': 'MT'},
    '321590': {'name': 'Ink',                                    'price': 3500,  'unit': 'MT'},
    '350691': {'name': 'Adhesives Based on Polymers',            'price': 2200,  'unit': 'MT'},
    '381400': {'name': 'Organic Composite Solvents & Thinners',  'price': 1100,  'unit': 'MT'},
    '390120': {'name': 'Polyethylene HDPE',                      'price': 1100,  'unit': 'MT'},
    '390730': {'name': 'Epoxide Resins',                         'price': 2200,  'unit': 'MT'},
    '390750': {'name': 'Alkyd Resins',                           'price': 1800,  'unit': 'MT'},
    '390940': {'name': 'Phenolic Resins',                        'price': 1900,  'unit': 'MT'},
    '390950': {'name': 'Polyurethanes',                          'price': 2400,  'unit': 'MT'},
    '391231': {'name': 'Carboxymethylcellulose & Salts',         'price': 2800,  'unit': 'MT'},
}

_RENAME = {
    "Company name": "company_name",
    "Number of product or service categories traded": "num_categories",
    "Number of employees": "num_employees",
    "Turnover (USD)": "turnover_usd",
    "Country": "country",
    "City": "city",
    "Website": "website",
}
_KEEP = ["hsn_code", "product_name", "company_name", "country", "city",
         "website", "num_categories", "num_employees", "turnover_usd", "trade_side"]


def _canonical_name(hsn: str) -> str:
    """Return canonical product name for an HSN code."""
    try:
        from trademap_data_loader import MARKET_PRICES
        if hsn in MARKET_PRICES:
            return MARKET_PRICES[hsn]['name']
    except ImportError:
        pass
    if hsn in EXTRA_MARKET_PRICES:
        return EXTRA_MARKET_PRICES[hsn]['name']
    return f"Product {hsn}"


def _is_data_csv(fpath: str) -> bool:
    """Return True if CSV contains real company data (has 'Company name' column)."""
    try:
        df = pd.read_csv(fpath, nrows=2, on_bad_lines="skip")
        return "Company name" in df.columns
    except Exception:
        return False


def _parse_table_folder(folder_path: str, hsn: str, product_name: str) -> pd.DataFrame:
    """
    Parse a folder containing Table_N.csv files (odd = data, even = header).
    Also handles 'Table_N (2).csv' duplicates — deduplicated by company name.
    """
    frames = []
    seen_tnums: set[int] = set()
    for fname in sorted(os.listdir(folder_path)):
        if not fname.endswith(".csv"):
            continue
        # Match Table_N.csv or Table_N (2).csv
        m = re.match(r"Table_(\d+)(?:\s*\(\d+\))?\.csv$", fname)
        if not m:
            continue
        tnum = int(m.group(1))
        if tnum % 2 == 0:           # even = header/metadata
            continue
        if tnum in seen_tnums:       # already processed base file
            continue
        seen_tnums.add(tnum)
        fpath = os.path.join(folder_path, fname)
        if not _is_data_csv(fpath):
            continue
        try:
            df = pd.read_csv(fpath, encoding="utf-8", on_bad_lines="skip")
            if not df.empty and "Company name" in df.columns:
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
    combined["trade_side"]   = "Exporter"
    return combined[[c for c in _KEEP if c in combined.columns]]


def _load_from_export_main() -> pd.DataFrame:
    """Load all exporting companies from 'Export data Main' folder."""
    if not os.path.exists(EXPORT_COMPANIES_PATH):
        logger.warning(f"'Export data Main' folder not found: {EXPORT_COMPANIES_PATH}")
        return pd.DataFrame()

    # Group folders by HSN (handle duplicates like 281700 Zinc Oxide + 281700 Zinc Peroxide)
    hsn_folders: dict[str, list] = {}
    hsn_names:   dict[str, str]  = {}
    for entry in sorted(os.listdir(EXPORT_COMPANIES_PATH)):
        full = os.path.join(EXPORT_COMPANIES_PATH, entry)
        if not os.path.isdir(full):
            continue
        m = re.match(r"^(\d{5,6})", entry)
        if not m:
            continue
        hsn = m.group(1)
        if hsn not in hsn_names:
            hsn_names[hsn] = _canonical_name(hsn)
        hsn_folders.setdefault(hsn, []).append(full)

    frames = []
    stub_hsns: set[str] = set()   # HSNs whose folders have no real company data

    for hsn, folders in sorted(hsn_folders.items()):
        product_name = hsn_names[hsn]
        got_data = False
        for folder_path in folders:
            df = _parse_table_folder(folder_path, hsn, product_name)
            if not df.empty:
                frames.append(df)
                got_data = True
                logger.info(f"  Loaded {len(df):,} exporters for HSN {hsn} from {os.path.basename(folder_path)}")
        if not got_data:
            stub_hsns.add(hsn)

    if stub_hsns:
        logger.info(f"  HSNs with stub-only folders (will use master CSV): {sorted(stub_hsns)}")

    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame(), stub_hsns


def _load_from_master_csv(hsn_filter: set[str] | None = None) -> pd.DataFrame:
    """
    Load exporting companies from 01_Master_Companies.csv.
    If hsn_filter is provided, only load those HSN codes.
    """
    if not os.path.exists(MASTER_CSV_PATH):
        logger.warning(f"Master companies CSV not found: {MASTER_CSV_PATH}")
        return pd.DataFrame()
    try:
        df = pd.read_csv(MASTER_CSV_PATH, on_bad_lines="skip", low_memory=False)
        df.columns = [c.lower().strip() for c in df.columns]
        if "hsn_code" not in df.columns:
            return pd.DataFrame()
        df["hsn_code"] = df["hsn_code"].astype(str)
        if hsn_filter:
            df = df[df["hsn_code"].isin(hsn_filter)]
        if df.empty:
            return pd.DataFrame()
        # Standardise columns
        col_map = {
            "company_name": "company_name",
            "country": "country",
            "city": "city",
            "website": "website",
            "number of employees": "num_employees",
            "quantity_units": "num_categories",
            "source_file": "source_file",
        }
        # Only rename turnover if not already named turnover_usd
        if "turnover_calculated" in df.columns and "turnover_usd" not in df.columns:
            col_map["turnover_calculated"] = "turnover_usd"
        elif "turnover_usd" not in df.columns and "turnover_calculated" in df.columns:
            col_map["turnover_calculated"] = "turnover_usd"
        df = df.rename(columns={k: v for k, v in col_map.items() if k in df.columns})
        # Override product_name with canonical
        df["product_name"] = df["hsn_code"].apply(_canonical_name)
        df["trade_side"]   = "Exporter"
        return df[[c for c in _KEEP if c in df.columns]]
    except Exception as e:
        logger.error(f"Error loading master CSV: {e}")
        return pd.DataFrame()


def load_export_companies() -> pd.DataFrame:
    """
    Load ALL exporting company records, merging:
      - Export data Main folder (Table_N.csv pattern)
      - 01_Master_Companies.csv (for HSNs whose folders are header-only stubs)

    Returns unified DataFrame with columns:
      hsn_code, product_name, company_name, country, city,
      website, num_categories, num_employees, turnover_usd, trade_side
    """
    # Step 1: Load from Export data Main
    result = _load_from_export_main()
    if isinstance(result, tuple):
        main_df, stub_hsns = result
    else:
        main_df, stub_hsns = result, set()

    # Step 2: Fill stub HSNs from master CSV
    master_df = _load_from_master_csv(stub_hsns) if stub_hsns else pd.DataFrame()

    # Step 3: Merge
    frames = [df for df in [main_df, master_df] if not df.empty]
    if not frames:
        return pd.DataFrame()

    all_companies = pd.concat(frames, ignore_index=True, sort=False)

    # Deduplicate: same HSN + same company name → keep once
    all_companies = all_companies.drop_duplicates(subset=["hsn_code", "company_name"])
    all_companies["country"]  = all_companies["country"].astype(str).str.strip()
    all_companies["hsn_code"] = all_companies["hsn_code"].astype(str)
    all_companies = all_companies[
        all_companies["country"].notna() &
        (all_companies["country"] != "") &
        (all_companies["country"] != "nan")
    ]

    logger.info(
        f"Total export companies: {len(all_companies):,} | "
        f"Unique: {all_companies['company_name'].nunique():,} | "
        f"HSNs: {all_companies['hsn_code'].nunique()} | "
        f"Countries: {all_companies['country'].nunique()}"
    )
    return all_companies


# ── Singleton cache ──────────────────────────────────────────────────────────
_cache: dict = {}

def get_export_companies() -> pd.DataFrame:
    if "df" not in _cache:
        _cache["df"] = load_export_companies()
    return _cache["df"]


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    df = load_export_companies()
    print(f"\n{'='*50}")
    print(f"Total rows:        {len(df):,}")
    print(f"Unique companies:  {df['company_name'].nunique():,}")
    print(f"HSN codes:         {df['hsn_code'].nunique()}")
    print(f"Countries:         {df['country'].nunique()}")
    print(f"\nTop 10 HSNs by company count:")
    print(df.groupby(["hsn_code","product_name"])["company_name"].count().nlargest(10).to_string())
    print(f"\nTop 10 exporting countries:")
    print(df["country"].value_counts().head(10).to_string())
