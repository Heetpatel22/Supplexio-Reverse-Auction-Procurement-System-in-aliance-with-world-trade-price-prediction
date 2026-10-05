"""
trademap_data_loader.py
Loads and parses ALL Trademap XLS files:

IMPORT data  → Trademap_files/{HSN_CODE} {Name}/Trade_Map_-_List_of_importers_*.xls
EXPORT data  → Trademap_files/{HSN_CODE}.xls   (new — loose files named by HSN code)

Both are ITC TradeMap HTML exports with monthly values in USD thousands.
"""

import os
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
import warnings
import pandas as pd
import numpy as np
import logging

from bigdata_platform import (
    configure_bigdata_env,
    dataset_exists,
    get_spark_session,
    read_json_metadata,
    read_parquet_dataset,
    write_json_metadata,
    write_parquet_dataset,
)

warnings.filterwarnings("ignore")
logger = logging.getLogger(__name__)

configure_bigdata_env()

TRADEMAP_PATH = os.path.join(os.path.dirname(__file__), "Export")

MARKET_PRICES = {
    # ── Minerals & Inorganic Raw Materials ──
    '250510': {'name': 'Silica Sands & Quartz Sands',            'price': 55,    'unit': 'MT'},
    '250700': {'name': 'Kaolin & Kaolinic Clays',                'price': 180,   'unit': 'MT'},
    '251990': {'name': 'Fused / Dead-Burned Magnesia',           'price': 320,   'unit': 'MT'},
    '252620': {'name': 'Natural Steatite & Talc (Powdered)',     'price': 160,   'unit': 'MT'},
    '253010': {'name': 'Vermiculite, Perlite & Chlorites',       'price': 220,   'unit': 'MT'},
    # ── Petroleum / Hydrocarbon Solvents ──
    '270730': {'name': 'Xylol (Xylene) - Mixed Isomers',        'price': 750,   'unit': 'MT'},
    '271012': {'name': 'Light Petroleum Oils & Preparations',   'price': 680,   'unit': 'MT'},
    # ── Inorganic Chemicals ──
    '280300': {'name': 'Carbon Black',                           'price': 1100,  'unit': 'MT'},
    '281121': {'name': 'Carbon Dioxide',                         'price': 120,   'unit': 'MT'},
    '281122': {'name': 'Silicon Dioxide (Precipitated Silica)',  'price': 875,   'unit': 'MT'},
    '281700': {'name': 'Zinc Oxide',                             'price': 1800,  'unit': 'MT'},
    '281820': {'name': 'Aluminium Oxide (excl. Corundum)',       'price': 450,   'unit': 'MT'},
    '282110': {'name': 'Iron Oxides & Hydroxides',               'price': 950,   'unit': 'MT'},
    '282300': {'name': 'Titanium Oxides',                        'price': 2500,  'unit': 'MT'},
    '282732': {'name': 'Aluminium Chloride',                     'price': 350,   'unit': 'MT'},
    '283919': {'name': 'Sodium Silicates',                       'price': 430,   'unit': 'MT'},
    '284150': {'name': 'Chromates & Dichromates',                'price': 1200,  'unit': 'MT'},
    # ── Aromatic & Aliphatic Solvents ──
    '290220': {'name': 'Benzene',                                'price': 810,   'unit': 'MT'},
    '290230': {'name': 'Toluene',                                'price': 865,   'unit': 'MT'},
    '290241': {'name': 'o-Xylene',                               'price': 862,   'unit': 'MT'},
    '290243': {'name': 'p-Xylene',                               'price': 955,   'unit': 'MT'},
    '290244': {'name': 'Mixed Xylene Isomers',                   'price': 800,   'unit': 'MT'},
    # ── Alcohols & Glycols ──
    '290511': {'name': 'Methanol',                               'price': 370,   'unit': 'MT'},
    '290512': {'name': 'Propan-1-ol (IPA)',                      'price': 1200,  'unit': 'MT'},
    '290513': {'name': 'n-Butyl Alcohol',                        'price': 1150,  'unit': 'MT'},
    '290522': {'name': 'Acyclic Terpene Alcohols',               'price': 1800,  'unit': 'MT'},
    '290531': {'name': 'Ethylene Glycol',                        'price': 560,   'unit': 'MT'},
    '290711': {'name': 'Phenol & Salts',                         'price': 1050,  'unit': 'MT'},
    # ── Ketones & Esters (Solvents) ──
    '291411': {'name': 'Acetone',                                'price': 740,   'unit': 'MT'},
    '291412': {'name': 'MEK (Methyl Ethyl Ketone)',              'price': 1350,  'unit': 'MT'},
    '291413': {'name': 'MIBK (Methyl Isobutyl Ketone)',          'price': 1500,  'unit': 'MT'},
    '291531': {'name': 'Ethyl Acetate',                          'price': 1000,  'unit': 'MT'},
    '291533': {'name': 'n-Butyl Acetate',                        'price': 1150,  'unit': 'MT'},
    # ── Acrylates & Specialty Monomers ──
    '291612': {'name': 'Esters of Acrylic Acid',                 'price': 1650,  'unit': 'MT'},
    '291614': {'name': 'Esters of Methacrylic Acid',             'price': 1800,  'unit': 'MT'},
    '291615': {'name': 'Oleic / Linoleic / Linolenic Esters',   'price': 1400,  'unit': 'MT'},
    '291739': {'name': 'Aromatic Polycarboxylic Acids & Anhydrides', 'price': 1550, 'unit': 'MT'},
    '292119': {'name': 'Acyclic Monoamines & Derivatives',       'price': 1700,  'unit': 'MT'},
    '292910': {'name': 'Isocyanates (MDI/TDI)',                  'price': 1900,  'unit': 'MT'},
    # ── Pigments & Dyes ──
    '320417': {'name': 'Synthetic Organic Pigments',             'price': 4500,  'unit': 'MT'},
    '320611': {'name': 'Titanium Dioxide (TiO2)',                'price': 2800,  'unit': 'MT'},
    '320619': {'name': 'Other TiO2 Pigments',                   'price': 2600,  'unit': 'MT'},
    '320641': {'name': 'Ultramarine Blue Pigments',              'price': 3200,  'unit': 'MT'},
    '320642': {'name': 'Lithopone / Zinc Sulphide Pigments',    'price': 2200,  'unit': 'MT'},
    '320710': {'name': 'Vitrifiable Pigments',                   'price': 3000,  'unit': 'MT'},
    '320890': {'name': 'Paints & Varnishes (Synthetic Polymer)', 'price': 2200,  'unit': 'MT'},
    '321100': {'name': 'Prepared Driers',                        'price': 2500,  'unit': 'MT'},
    '321290': {'name': 'Aluminium Paste or Leaf',                'price': 5500,  'unit': 'MT'},
    # ── Surfactants & Additives ──
    '340213': {'name': 'Non-ionic Surfactants',                  'price': 1800,  'unit': 'MT'},
    '380991': {'name': 'Finishing Agents',                       'price': 2200,  'unit': 'MT'},
    '381090': {'name': 'Fluxes & Auxiliary Welding Preparations','price': 1500,  'unit': 'MT'},
    '381121': {'name': 'Prepared Additives for Lubricant Oils',  'price': 2800,  'unit': 'MT'},
    '381210': {'name': 'Prepared Rubber Accelerators',           'price': 2400,  'unit': 'MT'},
    '381511': {'name': 'Nickel-Based Supported Catalysts',       'price': 8500,  'unit': 'MT'},
    '382440': {'name': 'Cement Additives',                       'price': 1200,  'unit': 'MT'},
    '382499': {'name': 'Biocides / Fungicides',                  'price': 3500,  'unit': 'MT'},
    # ── Polymers & Resins ──
    '390110': {'name': 'Polyethylene LDPE',                      'price': 1150,  'unit': 'MT'},
    '390210': {'name': 'Polypropylene',                          'price': 1100,  'unit': 'MT'},
    '390311': {'name': 'Expansible Polystyrene',                 'price': 1375,  'unit': 'MT'},
    '390390': {'name': 'Styrene-Acrylic Emulsions',              'price': 1600,  'unit': 'MT'},
    '390512': {'name': 'Poly Vinyl Acetate',                     'price': 1275,  'unit': 'MT'},
    '390521': {'name': 'Vinyl Acetate Copolymers',               'price': 1400,  'unit': 'MT'},
    '390610': {'name': 'PMMA',                                   'price': 1375,  'unit': 'MT'},
    '390690': {'name': 'Other Acrylic Polymers',                 'price': 1500,  'unit': 'MT'},
    '390791': {'name': 'Unsaturated Polyesters',                 'price': 1800,  'unit': 'MT'},
    '390810': {'name': 'Polyamides',                             'price': 2200,  'unit': 'MT'},
    '391110': {'name': 'Petroleum Resins',                       'price': 1700,  'unit': 'MT'},
    # ── Additional products from Export data Main ──
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

# Product category mapping — updated for all 79 HSN codes
PRODUCT_CATEGORIES = {
    'Minerals & Inorganic Raw Materials': [
        '250510','250700','251990','252620','253010',
        '281121','281122','281820','282110','282300','282732',
        '283325','283650','283919','284150','291122',
    ],
    'Petroleum & Hydrocarbon Solvents': [
        '270730','271012','381400',
    ],
    'Aromatic & Aliphatic Solvents': [
        '290220','290230','290241','290243','290244',
        '290511','290512','290513','290522','290531','290711',
        '291411','291412','291413','291531','291533',
    ],
    'Monomers, Acrylates & Specialty Chemicals': [
        '291612','291614','291615','291739','292119','292910',
    ],
    'Pigments, Dyes & Paints': [
        '280300','281700','320417','320611','320619','320641','320642',
        '320710','320890','321100','321290','321590',
    ],
    'Surfactants, Additives & Catalysts': [
        '340213','350691','380991','381090','381121','381210',
        '381511','382440','382499',
    ],
    'Polymers & Resins': [
        '390110','390120','390210','390311','390390','390512','390521',
        '390610','390690','390730','390750','390791','390810',
        '390940','390950','391110','391231',
    ],
}


def parse_month_column(col_name):
    """Extract year and month from a period string like '...in YYYY-MM'"""
    m = re.search(r'(\d{4})-M(\d{2})', str(col_name))
    if m:
        return int(m.group(1)), int(m.group(2))
    return None, None


def _parse_xls_file(xls_path, hsn_code, product_name, trade_type):
    """
    Generic parser for both import and export XLS files.
    trade_type: 'import' or 'export'
    Country column header: 'Importers' or 'Exporters'
    Value column keyword: 'Imported value' or 'Exported value'
    Returns long-format DataFrame.
    """
    try:
        tables = pd.read_html(xls_path)
        if len(tables) < 4:
            return pd.DataFrame()

        df = tables[3]
        if df.empty:
            return pd.DataFrame()

        # Detect country column (Importers or Exporters)
        country_col = None
        for candidate in ['Importers', 'Exporters']:
            if candidate in df.columns:
                country_col = candidate
                break
        if country_col is None:
            return pd.DataFrame()

        # Detect value columns
        kw = 'Imported value' if trade_type == 'import' else 'Exported value'
        month_cols = [c for c in df.columns if kw in str(c)]
        if not month_cols:
            return pd.DataFrame()

        df_clean = df[[country_col] + month_cols].copy()
        df_clean = df_clean.rename(columns={country_col: 'country'})
        df_clean['country'] = df_clean['country'].astype(str).str.strip()

        # Drop world/aggregate rows
        exclude = {'World', 'world', 'WORLD', 'nan', ''}
        df_clean = df_clean[~df_clean['country'].isin(exclude)]

        # Melt to long format
        df_melted = df_clean.melt(id_vars='country', var_name='period', value_name='value_usd_k')

        # Parse year / month
        parsed = df_melted['period'].apply(lambda x: pd.Series(parse_month_column(x)))
        df_melted[['year', 'month']] = parsed
        df_melted = df_melted.dropna(subset=['year', 'month'])
        df_melted['year']  = df_melted['year'].astype(int)
        df_melted['month'] = df_melted['month'].astype(int)

        # Convert USD thousands → USD
        value_col = 'import_value_usd' if trade_type == 'import' else 'export_value_usd'
        df_melted[value_col] = pd.to_numeric(df_melted['value_usd_k'], errors='coerce').fillna(0) * 1000

        df_melted['hsn_code']     = hsn_code
        df_melted['product_name'] = product_name
        df_melted['trade_type']   = trade_type

        keep_cols = ['hsn_code', 'product_name', 'trade_type', 'country', 'year', 'month', value_col]
        result = df_melted[keep_cols].copy()
        result = result[result[value_col] >= 0]
        return result

    except Exception as e:
        logger.warning(f"Error parsing {xls_path}: {e}")
        return pd.DataFrame()


def load_all_trademap_data():
    """
    Loads both import and export data.

    Returns a dict with keys:
      hsn_mapping       – {hsn_code: product_name}
      import_monthly    – long-format import DataFrame
      export_monthly    – long-format export DataFrame
      import_country_totals – aggregated import by (hsn, country)
      export_country_totals – aggregated export by (hsn, country)
      import_hsn_totals – aggregated import by hsn
      export_hsn_totals – aggregated export by hsn
      # legacy aliases kept for backward compat:
      monthly_df        → import_monthly
      country_totals    → import_country_totals
      hsn_totals        → import_hsn_totals
    """
    if not os.path.exists(TRADEMAP_PATH):
        logger.error(f"Trademap path not found: {TRADEMAP_PATH}")
        empty = pd.DataFrame()
        return dict(hsn_mapping={}, import_monthly=empty, export_monthly=empty,
                    import_country_totals=empty, export_country_totals=empty,
                    import_hsn_totals=empty, export_hsn_totals=empty,
                    monthly_df=empty, country_totals=empty, hsn_totals=empty)

    write_json_metadata(
        {
            "source_path": TRADEMAP_PATH,
            "storage_mode": "curated_parquet_in_local_hadoop_warehouse",
        },
        "trademap_source.json",
    )

    cached_tables = {
        "import_monthly": "trademap/import_monthly",
        "export_monthly": "trademap/export_monthly",
        "import_country_totals": "trademap/import_country_totals",
        "export_country_totals": "trademap/export_country_totals",
        "import_hsn_totals": "trademap/import_hsn_totals",
        "export_hsn_totals": "trademap/export_hsn_totals",
    }
    cached_mapping = read_json_metadata("trademap_hsn_mapping.json", default={})
    if cached_mapping and all(dataset_exists(path) for path in cached_tables.values()):
        import_monthly = read_parquet_dataset(cached_tables["import_monthly"])
        export_monthly = read_parquet_dataset(cached_tables["export_monthly"])
        import_country_totals = read_parquet_dataset(cached_tables["import_country_totals"])
        export_country_totals = read_parquet_dataset(cached_tables["export_country_totals"])
        import_hsn_totals = read_parquet_dataset(cached_tables["import_hsn_totals"])
        export_hsn_totals = read_parquet_dataset(cached_tables["export_hsn_totals"])
        return dict(
            hsn_mapping=cached_mapping,
            import_monthly=import_monthly,
            export_monthly=export_monthly,
            import_country_totals=import_country_totals,
            export_country_totals=export_country_totals,
            import_hsn_totals=import_hsn_totals,
            export_hsn_totals=export_hsn_totals,
            monthly_df=import_monthly,
            country_totals=import_country_totals,
            hsn_totals=import_hsn_totals,
        )

    # ── Helper: extract product name from XLS table[0] header row ──
    def _extract_product_name_from_xls(xls_path):
        """Reads the ITC TradeMap XLS header to get 'Product: XXXXXX Name...' string."""
        try:
            tables = pd.read_html(xls_path)
            if not tables:
                return None
            t0 = tables[0]
            raw = str(t0.iloc[1, 0]) if t0.shape[0] > 1 else str(t0.iloc[0, 0])
            m = re.search(r'Product:\s*\d+\s+(.+)', raw)
            if m:
                name = m.group(1).strip()
                # Truncate overly long auto-generated names
                if len(name) > 55:
                    name = name[:52].rstrip() + '...'
                return name
        except Exception:
            pass
        return None

    # ── Build HSN mapping — fully auto-discovers ALL HSN codes ──
    # Priority: MARKET_PRICES canonical name > named-folder suffix > XLS header
    # Bare-numbered subfolders (e.g. "270730/") are skipped for naming but still
    # scanned for data. Named subfolders (e.g. "270730 Xylol.../") and root XLS
    # files carry the authoritative product name.
    hsn_mapping = {}

    # Pass 1: seed from MARKET_PRICES (covers all 67 known codes)
    hsn_mapping.update({k: v['name'] for k, v in MARKET_PRICES.items()})

    # Pass 2: named subfolders — override if name not yet set, skip bare folders
    for entry in sorted(os.listdir(TRADEMAP_PATH)):
        entry_path = os.path.join(TRADEMAP_PATH, entry)
        if not os.path.isdir(entry_path):
            continue
        parts = entry.split(' ', 1)
        if len(parts) < 2:
            continue  # bare numbered folder — no name info
        hsn_code = parts[0].strip()
        if not re.match(r'^\d{5,6}$', hsn_code):
            continue
        if hsn_code not in hsn_mapping:
            # Use folder name suffix as fallback
            hsn_mapping[hsn_code] = MARKET_PRICES.get(hsn_code, {}).get('name', parts[1].strip())

    # Pass 3: scan ALL root XLS files — discover any HSN not yet registered
    for fname in sorted(os.listdir(TRADEMAP_PATH)):
        if not fname.endswith('.xls'):
            continue
        bare = re.sub(r'\s+[A-Za-z].*$', '', fname.replace('.xls', '')).strip()
        hsn_code = re.sub(r'\(\d+\)$', '', bare).strip()
        if not re.match(r'^\d{5,6}$', hsn_code):
            continue
        if hsn_code not in hsn_mapping:
            # Try to read the product name from the XLS header
            xls_path = os.path.join(TRADEMAP_PATH, fname)
            xls_name = _extract_product_name_from_xls(xls_path)
            hsn_mapping[hsn_code] = xls_name or f'Product {hsn_code}'
            logger.info(f"Auto-discovered HSN {hsn_code}: {hsn_mapping[hsn_code]}")

    # ── Helper: load all XLS files from a directory, auto-detect trade type ──
    def _load_dir(dir_path, hsn_code, product_name, import_frames, export_frames):
        for xls_fname in sorted(f for f in os.listdir(dir_path) if f.endswith('.xls')):
            xls_path = os.path.join(dir_path, xls_fname)
            try:
                tables = pd.read_html(xls_path)
                if len(tables) < 4:
                    continue
                df_raw = tables[3]
                if 'Exporters' in df_raw.columns:
                    trade_type = 'export'
                elif 'Importers' in df_raw.columns:
                    trade_type = 'import'
                else:
                    continue
            except Exception:
                continue
            df = _parse_xls_file(xls_path, hsn_code, product_name, trade_type)
            if not df.empty:
                if trade_type == 'import':
                    import_frames.append(df)
                else:
                    export_frames.append(df)
                logger.info(f"  {trade_type.upper()} {hsn_code} [{xls_fname}]: {len(df)} records")

    import_frames = []
    export_frames = []
    root_xls_files = sorted(fname for fname in os.listdir(TRADEMAP_PATH) if fname.endswith('.xls'))
    root_hsns = set()

    def _process_root_file(fname):
        xls_path = os.path.join(TRADEMAP_PATH, fname)
        bare = re.sub(r'\s+[A-Za-z].*$', '', fname.replace('.xls', '')).strip()
        hsn_code = re.sub(r'\(\d+\)$', '', bare).strip()
        if hsn_code not in hsn_mapping:
            return None

        product_name = hsn_mapping[hsn_code]
        try:
            tables = pd.read_html(xls_path)
            if len(tables) < 4:
                return None
            df_raw = tables[3]
            if 'Exporters' in df_raw.columns:
                detected_type = 'export'
            elif 'Importers' in df_raw.columns:
                detected_type = 'import'
            else:
                return None
        except Exception:
            return None

        df = _parse_xls_file(xls_path, hsn_code, product_name, detected_type)
        return detected_type, hsn_code, product_name, fname, df

    with ThreadPoolExecutor(max_workers=min(12, (os.cpu_count() or 4))) as executor:
        futures = [executor.submit(_process_root_file, fname) for fname in root_xls_files]
        for future in as_completed(futures):
            result = future.result()
            if not result:
                continue
            detected_type, hsn_code, product_name, fname, df = result
            root_hsns.add(hsn_code)
            if df.empty:
                continue
            if detected_type == 'export':
                export_frames.append(df)
            else:
                import_frames.append(df)
            logger.info(f"ROOT {detected_type.upper()} {hsn_code} ({product_name}) [{fname}]: {len(df)} records")

    # Only use subfolders as a fallback for HSN codes that do not have root files.
    for entry in sorted(e for e in os.listdir(TRADEMAP_PATH) if os.path.isdir(os.path.join(TRADEMAP_PATH, e))):
        entry_path = os.path.join(TRADEMAP_PATH, entry)
        hsn_code = entry.split(' ', 1)[0].strip()
        if hsn_code not in hsn_mapping or hsn_code in root_hsns:
            continue
        product_name = hsn_mapping[hsn_code]
        logger.info(f"SUBDIR FALLBACK {entry}")
        _load_dir(entry_path, hsn_code, product_name, import_frames, export_frames)

    def _pandas_transform(records_df, value_col):
        if records_df.empty:
            empty = pd.DataFrame()
            return empty, empty, empty
        df = records_df.sort_values(value_col, ascending=False).drop_duplicates(subset=["hsn_code", "country", "year", "month"]).copy()
        df["year_month"] = df["year"].astype(str) + "-" + df["month"].astype(str).str.zfill(2)
        df["date"] = pd.to_datetime(df["year_month"], format="%Y-%m")

        country_totals = df.groupby(["hsn_code", "product_name", "country"]).agg(
            total_val=(value_col, "sum"),
            avg_monthly_value=(value_col, "mean"),
            num_months=(value_col, "count"),
            latest_month_value=(value_col, "last")
        ).reset_index().rename(columns={"total_val": f"total_{value_col}"})

        hsn_totals = df.groupby(["hsn_code", "product_name"]).agg(
            total_val=(value_col, "sum"),
            num_countries=("country", "nunique"),
            num_months_data=("year_month", "nunique")
        ).reset_index().rename(columns={"total_val": f"total_{value_col}"})
        hsn_totals["price_per_mt"] = hsn_totals["hsn_code"].map(lambda x: MARKET_PRICES.get(x, {}).get("price"))
        hsn_totals["unit"] = hsn_totals["hsn_code"].map(lambda x: MARKET_PRICES.get(x, {}).get("unit"))

        monthly_pd = df.sort_values(["hsn_code", "country", "date"]).reset_index(drop=True)
        country_pd = country_totals.sort_values(["hsn_code", f"total_{value_col}"], ascending=[True, False]).reset_index(drop=True)
        hsn_pd = hsn_totals.sort_values(f"total_{value_col}", ascending=False).reset_index(drop=True)
        return monthly_pd, country_pd, hsn_pd

    def _spark_transform(records_df, value_col):
        if records_df.empty:
            empty = pd.DataFrame()
            return empty, empty, empty

        try:
            spark = get_spark_session("PaintTradeTrademap")
            sdf = spark.createDataFrame(records_df)

            from pyspark.sql import functions as F
            from pyspark.sql.window import Window
        except Exception as err:
            logger.warning(f"Spark unavailable ({err}), falling back to Pandas transformation.")
            return _pandas_transform(records_df, value_col)

        dedup_window = Window.partitionBy("hsn_code", "country", "year", "month").orderBy(F.desc(value_col))
        sdf = (
            sdf.withColumn("row_num", F.row_number().over(dedup_window))
               .filter(F.col("row_num") == 1)
               .drop("row_num")
               .withColumn("year_month", F.concat_ws("-", F.col("year").cast("string"), F.lpad(F.col("month").cast("string"), 2, "0")))
               .withColumn("date", F.to_date(F.col("year_month"), "yyyy-MM"))
        )

        latest_struct = F.max(F.struct(F.col("date"), F.col(value_col))).alias("latest_struct")
        country_totals = (
            sdf.groupBy("hsn_code", "product_name", "country")
               .agg(
                   F.sum(value_col).alias(f"total_{value_col}"),
                   F.avg(value_col).alias("avg_monthly_value"),
                   F.count(value_col).alias("num_months"),
                   latest_struct,
               )
               .withColumn("latest_month_value", F.col("latest_struct")[value_col])
               .drop("latest_struct")
        )

        hsn_totals = (
            sdf.groupBy("hsn_code", "product_name")
               .agg(
                   F.sum(value_col).alias(f"total_{value_col}"),
                   F.countDistinct("country").alias("num_countries"),
                   F.countDistinct("year_month").alias("num_months_data"),
               )
        )

        monthly_pd = sdf.toPandas().sort_values(["hsn_code", "country", "date"]).reset_index(drop=True)
        country_pd = country_totals.toPandas().sort_values(["hsn_code", f"total_{value_col}"], ascending=[True, False]).reset_index(drop=True)
        hsn_pd = hsn_totals.toPandas().sort_values(f"total_{value_col}", ascending=False).reset_index(drop=True)
        hsn_pd["price_per_mt"] = hsn_pd["hsn_code"].map(lambda x: MARKET_PRICES.get(x, {}).get("price"))
        hsn_pd["unit"] = hsn_pd["hsn_code"].map(lambda x: MARKET_PRICES.get(x, {}).get("unit"))
        return monthly_pd, country_pd, hsn_pd

    import_input = pd.concat(import_frames, ignore_index=True) if import_frames else pd.DataFrame()
    export_input = pd.concat(export_frames, ignore_index=True) if export_frames else pd.DataFrame()
    import_monthly, import_country_totals, import_hsn_totals = _spark_transform(import_input, "import_value_usd")
    export_monthly, export_country_totals, export_hsn_totals = _spark_transform(export_input, "export_value_usd")

    write_json_metadata(hsn_mapping, "trademap_hsn_mapping.json")
    write_parquet_dataset(import_monthly, cached_tables["import_monthly"])
    write_parquet_dataset(export_monthly, cached_tables["export_monthly"])
    write_parquet_dataset(import_country_totals, cached_tables["import_country_totals"])
    write_parquet_dataset(export_country_totals, cached_tables["export_country_totals"])
    write_parquet_dataset(import_hsn_totals, cached_tables["import_hsn_totals"])
    write_parquet_dataset(export_hsn_totals, cached_tables["export_hsn_totals"])

    logger.info(
        f"Loaded {len(hsn_mapping)} products | "
        f"Import: {len(import_monthly)} records, {import_monthly['country'].nunique() if not import_monthly.empty else 0} countries | "
        f"Export: {len(export_monthly)} records, {export_monthly['country'].nunique() if not export_monthly.empty else 0} countries"
    )

    return dict(
        hsn_mapping=hsn_mapping,
        import_monthly=import_monthly,
        export_monthly=export_monthly,
        import_country_totals=import_country_totals,
        export_country_totals=export_country_totals,
        import_hsn_totals=import_hsn_totals,
        export_hsn_totals=export_hsn_totals,
        # Legacy aliases
        monthly_df=import_monthly,
        country_totals=import_country_totals,
        hsn_totals=import_hsn_totals,
    )


# ── Singleton cache ──
_cache = {}

def get_trademap_data():
    if 'loaded' not in _cache:
        _cache.update(load_all_trademap_data())
        _cache['loaded'] = True
    return _cache


if __name__ == '__main__':
    data = get_trademap_data()
    print(f"HSN codes: {len(data['hsn_mapping'])}")
    print(f"Import monthly records: {len(data['import_monthly'])}")
    print(f"Export monthly records: {len(data['export_monthly'])}")
    print(f"\nTop Carbon Black (280300) IMPORTERS:")
    ct = data['import_country_totals']
    cb = ct[ct['hsn_code'] == '280300'].sort_values('total_import_value_usd', ascending=False).head(5)
    print(cb[['country', 'total_import_value_usd']].to_string())
    print(f"\nTop Carbon Black (280300) EXPORTERS:")
    et = data['export_country_totals']
    cb_e = et[et['hsn_code'] == '280300'].sort_values('total_export_value_usd', ascending=False).head(5)
    print(cb_e[['country', 'total_export_value_usd']].to_string())
