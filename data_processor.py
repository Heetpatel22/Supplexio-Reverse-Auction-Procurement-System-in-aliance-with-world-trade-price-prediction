"""
data_processor.py  –  Paint & Chemicals Trade Intelligence
Loads import AND export data from ITC TradeMap XLS files + CSV supplements.
"""

import os
import warnings
import pandas as pd
import numpy as np
import logging

from bigdata_platform import (
    configure_bigdata_env,
    dataset_exists,
    read_parquet_dataset,
    sync_raw_sources,
    write_parquet_dataset,
)

warnings.filterwarnings("ignore")
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

configure_bigdata_env()

CSV_DATA_PATH = os.path.join(os.path.dirname(__file__), "CSV_Data")

try:
    from trademap_data_loader import get_trademap_data, MARKET_PRICES, PRODUCT_CATEGORIES
except ImportError:
    MARKET_PRICES = {}
    PRODUCT_CATEGORIES = {}
    def get_trademap_data():
        empty = pd.DataFrame()
        return dict(hsn_mapping={}, import_monthly=empty, export_monthly=empty,
                    import_country_totals=empty, export_country_totals=empty,
                    import_hsn_totals=empty, export_hsn_totals=empty,
                    monthly_df=empty, country_totals=empty, hsn_totals=empty)

try:
    from global_trade_loader import get_global_trade_data
except ImportError:
    def get_global_trade_data(force_refresh=False):
        empty = pd.DataFrame()
        return dict(product_index=empty, product_year=empty, world_year=empty, exporters=empty, importers=empty)


class TradeDataProcessor:

    def __init__(self):
        self._tm = None
        self._global = None
        self.companies_both = None
        self.annual_values  = None
        self.hsn_codes = {}

    # ── Core ──────────────────────────────────────────────────────────
    def _tm_data(self):
        if self._tm is None:
            self._tm = get_trademap_data()
        return self._tm

    def _global_data(self):
        if self._global is None:
            self._global = get_global_trade_data()
        return self._global

    def _csv(self, filename):
        path = os.path.join(CSV_DATA_PATH, filename)
        if os.path.exists(path):
            try:
                sync_raw_sources([CSV_DATA_PATH], "csv_data")
                dataset_name = f"csv/{os.path.splitext(filename)[0]}"
                if dataset_exists(dataset_name):
                    df = read_parquet_dataset(dataset_name)
                else:
                    df = pd.read_csv(path)
                    write_parquet_dataset(df, dataset_name)
                df.columns = [c.lower() for c in df.columns]
                return df
            except Exception as e:
                logger.warning(f"CSV load failed ({filename}): {e}")
        return pd.DataFrame()

    def load_all_data(self):
        tm = self._tm_data()
        self._global_data()
        self.hsn_codes      = tm['hsn_mapping']
        self.companies_both = self._csv("10_Companies_Both_Sides.csv")
        self.annual_values  = self._csv("11_Annual_Trade_Values.csv")
        return {}

    # ── Global annual trade warehouse ────────────────────────────────
    def load_global_product_index(self):
        return self._global_data()["product_index"]

    def load_global_trade_product_year(self):
        return self._global_data()["product_year"]

    def load_global_trade_world_year(self):
        return self._global_data()["world_year"]

    def load_global_exporters(self):
        return self._global_data()["exporters"]

    def load_global_importers(self):
        return self._global_data()["importers"]

    def load_global_exporter_year(self):
        return self._global_data().get("exporter_year", pd.DataFrame())

    def load_global_importer_year(self):
        return self._global_data().get("importer_year", pd.DataFrame())

    def get_all_hsn_mapping(self):
        mapping = {}
        mapping.update({str(k): v for k, v in self.load_global_product_index().set_index("hsn_code")["product_name"].to_dict().items()} if not self.load_global_product_index().empty else {})
        mapping.update({str(k): v for k, v in self._tm_data()["hsn_mapping"].items()})
        return mapping

    def get_product_name(self, hsn_code):
        mapping = self.get_all_hsn_mapping()
        return mapping.get(str(hsn_code), str(hsn_code))

    def search_global_products(self, query=None, limit=50):
        df = self.load_global_product_index()
        if df.empty:
            return df
        if query:
            q = str(query).strip().lower()
            if q:
                mask = df["hsn_code"].astype(str).str.contains(q, case=False, na=False) | df["product_name"].astype(str).str.lower().str.contains(q, na=False)
                df = df[mask]
        return df.sort_values("hsn_code").head(limit).reset_index(drop=True)

    def get_global_product_trend(self, hsn_code):
        df = self.load_global_trade_product_year()
        if df.empty:
            return df
        return df[df["hsn_code"].astype(str) == str(hsn_code)].sort_values("year").reset_index(drop=True)

    def get_global_exporters_by_hsn(self, hsn_code, top_n=20):
        df = self.load_global_exporters()
        if df.empty:
            return df
        subset = df[df["hsn_code"].astype(str) == str(hsn_code)].copy()
        return subset.sort_values("total_value_usd", ascending=False).head(top_n).reset_index(drop=True)

    def get_global_importers_by_hsn(self, hsn_code, top_n=20):
        df = self.load_global_importers()
        if df.empty:
            return df
        subset = df[df["hsn_code"].astype(str) == str(hsn_code)].copy()
        return subset.sort_values("total_value_usd", ascending=False).head(top_n).reset_index(drop=True)

    def get_global_trade_stats(self):
        idx = self.load_global_product_index()
        world = self.load_global_trade_world_year()
        exp = self.load_global_exporters()
        imp = self.load_global_importers()
        latest = world.sort_values("year").iloc[-1] if not world.empty else {}
        return {
            "total_products": int(idx["hsn_code"].nunique()) if not idx.empty else 0,
            "exporter_countries": int(exp["exporter_country"].nunique()) if not exp.empty and "exporter_country" in exp.columns else 0,
            "importer_countries": int(imp["importer_country"].nunique()) if not imp.empty and "importer_country" in imp.columns else 0,
            "latest_year": int(latest["year"]) if len(latest) else None,
            "latest_total_value_usd": float(latest["total_value_usd"]) if len(latest) else 0.0,
            "latest_total_quantity_mt": float(latest["total_quantity_mt"]) if len(latest) else 0.0,
            "latest_is_estimated": bool(latest["is_estimated"]) if len(latest) and "is_estimated" in latest else False,
            "latest_is_projection": bool(latest["is_projection"]) if len(latest) and "is_projection" in latest else False,
        }

    def _format_global_trade_side(self, df, country_col, total_col):
        if df.empty:
            return pd.DataFrame()
        result = df.copy()
        result = result.rename(columns={country_col: "country", total_col: total_col})
        if "years_present" in result.columns:
            result["num_months"] = result["years_present"]
        else:
            result["num_months"] = 0
        result["avg_monthly_value"] = np.where(result["num_months"] > 0, result[total_col] / result["num_months"], result[total_col])
        result["latest_month_value"] = result[total_col]
        keep_cols = ["hsn_code", "product_name", "country", total_col, "avg_monthly_value", "num_months", "latest_month_value"]
        return result[[c for c in keep_cols if c in result.columns]]

    # ── HSN mapping ───────────────────────────────────────────────────
    def get_hsn_product_mapping(self):
        return self.get_all_hsn_mapping()

    # ── Import helpers ────────────────────────────────────────────────
    def load_import_countries(self):
        tm = self._tm_data()['import_country_totals']
        if not tm.empty:
            return tm
        return self._format_global_trade_side(self.load_global_importers(), "importer_country", "total_value_usd").rename(columns={"total_value_usd": "total_import_value_usd"})

    def get_import_countries_by_hsn(self, hsn_code):
        df = self.load_import_countries()
        if df.empty or 'hsn_code' not in df.columns:
            return pd.DataFrame()
        subset = df[df['hsn_code'].astype(str) == str(hsn_code)].copy()
        if subset.empty:
            gdf = self._format_global_trade_side(self.get_global_importers_by_hsn(hsn_code, top_n=100000), "importer_country", "total_value_usd")
            if not gdf.empty:
                gdf = gdf.rename(columns={"total_value_usd": "total_import_value_usd"})
                return gdf
        return subset

    def get_top_importing_countries(self, hsn_code, top_n=15):
        df = self.get_import_countries_by_hsn(hsn_code)
        if df.empty:
            return pd.DataFrame()
        val_col = 'total_import_value_usd'
        if val_col in df.columns:
            return df.nlargest(top_n, val_col)
        return df.head(top_n)

    def get_monthly_import_data(self, hsn_code, country=None):
        df = self._tm_data()['import_monthly']
        if not df.empty:
            result = df[df['hsn_code'].astype(str) == str(hsn_code)].copy()
            if country and country != 'All':
                result = result[result['country'] == country]
            if not result.empty:
                return result
        gdf = self.load_global_importer_year()
        if gdf.empty:
            return pd.DataFrame()
        result = gdf[gdf['hsn_code'].astype(str) == str(hsn_code)].copy()
        result = result.rename(columns={"importer_country": "country", "total_value_usd": "import_value_usd"})
        result["month"] = 1
        if country and country != 'All':
            result = result[result['country'] == country]
        return result

    def get_monthly_import_totals(self, hsn_code):
        df = self.get_monthly_import_data(hsn_code)
        if df.empty:
            return pd.DataFrame()
        return df.groupby(['year','month','year_month','date'])['import_value_usd'].sum().reset_index().sort_values('date')

    # ── Export helpers ────────────────────────────────────────────────
    def load_export_countries(self):
        tm = self._tm_data()['export_country_totals']
        if not tm.empty:
            return tm
        return self._format_global_trade_side(self.load_global_exporters(), "exporter_country", "total_value_usd").rename(columns={"total_value_usd": "total_export_value_usd"})

    def get_export_countries_by_hsn(self, hsn_code):
        df = self.load_export_countries()
        if df.empty or 'hsn_code' not in df.columns:
            return pd.DataFrame()
        subset = df[df['hsn_code'].astype(str) == str(hsn_code)].copy()
        if subset.empty:
            gdf = self._format_global_trade_side(self.get_global_exporters_by_hsn(hsn_code, top_n=100000), "exporter_country", "total_value_usd")
            if not gdf.empty:
                gdf = gdf.rename(columns={"total_value_usd": "total_export_value_usd"})
                return gdf
        return subset

    def get_top_exporting_countries(self, hsn_code, top_n=15):
        df = self.get_export_countries_by_hsn(hsn_code)
        if df.empty:
            return pd.DataFrame()
        val_col = 'total_export_value_usd'
        if val_col in df.columns:
            return df.nlargest(top_n, val_col)
        return df.head(top_n)

    def get_monthly_export_data(self, hsn_code, country=None):
        df = self._tm_data()['export_monthly']
        if not df.empty:
            result = df[df['hsn_code'].astype(str) == str(hsn_code)].copy()
            if country and country != 'All':
                result = result[result['country'] == country]
            if not result.empty:
                return result
        gdf = self.load_global_exporter_year()
        if gdf.empty:
            return pd.DataFrame()
        result = gdf[gdf['hsn_code'].astype(str) == str(hsn_code)].copy()
        result = result.rename(columns={"exporter_country": "country", "total_value_usd": "export_value_usd"})
        result["month"] = 1
        if country and country != 'All':
            result = result[result['country'] == country]
        return result

    def get_monthly_export_totals(self, hsn_code):
        df = self.get_monthly_export_data(hsn_code)
        if df.empty:
            return pd.DataFrame()
        return df.groupby(['year','month','year_month','date'])['export_value_usd'].sum().reset_index().sort_values('date')

    # ── Combined trade balance ────────────────────────────────────────
    def get_trade_balance_by_country(self, hsn_code):
        """Returns per-country export minus import value for a product."""
        imp_df = self.get_import_countries_by_hsn(hsn_code)
        exp_df = self.get_export_countries_by_hsn(hsn_code)
        imp = imp_df[['country','total_import_value_usd']].copy() if not imp_df.empty else pd.DataFrame(columns=['country','total_import_value_usd'])
        exp = exp_df[['country','total_export_value_usd']].copy() if not exp_df.empty else pd.DataFrame(columns=['country','total_export_value_usd'])
        merged = pd.merge(exp, imp, on='country', how='outer').fillna(0)
        merged['trade_balance'] = merged['total_export_value_usd'] - merged['total_import_value_usd']
        merged['net_status'] = merged['trade_balance'].apply(lambda x: 'Net Exporter' if x > 0 else 'Net Importer')
        return merged.sort_values('trade_balance', ascending=False)

    # ── Company / CSV helpers ─────────────────────────────────────────
    def load_companies_both_sides(self):
        """Legacy: returns original CSV (one side per HSN). Use load_companies_unified() instead."""
        if self.companies_both is None:
            self.companies_both = self._csv("10_Companies_Both_Sides.csv")
        return self.companies_both

    def load_companies_unified(self):
        """
        Returns a unified country-level trade table with BOTH importers and exporters
        for every HSN code that has the data, built from the actual XLS trademap files.
        Columns: hsn_code, product_name, country, trade_side, total_value_usd,
                 avg_monthly_value, num_months, latest_month_value
        """
        tm = self._tm_data()
        frames = []

        exp_ct = tm['export_country_totals']
        if not exp_ct.empty:
            df = exp_ct.copy()
            df = df.rename(columns={'total_export_value_usd': 'total_value_usd',
                                    'avg_monthly_value': 'avg_monthly_value',
                                    'num_months': 'num_months',
                                    'latest_month_value': 'latest_month_value'})
            df['trade_side'] = 'Exporter'
            frames.append(df[['hsn_code','product_name','country','trade_side',
                               'total_value_usd','avg_monthly_value','num_months','latest_month_value']])

        imp_ct = tm['import_country_totals']
        if not imp_ct.empty:
            df = imp_ct.copy()
            df = df.rename(columns={'total_import_value_usd': 'total_value_usd',
                                    'avg_monthly_value': 'avg_monthly_value',
                                    'num_months': 'num_months',
                                    'latest_month_value': 'latest_month_value'})
            df['trade_side'] = 'Importer'
            frames.append(df[['hsn_code','product_name','country','trade_side',
                               'total_value_usd','avg_monthly_value','num_months','latest_month_value']])

        if not frames:
            return pd.DataFrame()

        unified = pd.concat(frames, ignore_index=True)
        unified['total_value_usd'] = unified['total_value_usd'].fillna(0)
        unified = unified.sort_values(['hsn_code','trade_side','total_value_usd'], ascending=[True,True,False])
        return unified

    def load_master_company_data(self):
        return self._csv("01_Master_Companies.csv")

    def load_price_per_unit(self):
        df = self._csv("04_Price_Per_Unit_by_Product.csv")
        if not df.empty:
            return df
        rows = [{'hsn_code': k, 'product_name': v['name'], 'avg_price': v['price'], 'unit': v['unit'], 'currency': 'USD'}
                for k, v in sorted(MARKET_PRICES.items())]
        return pd.DataFrame(rows)

    def load_monthly_trade_by_country(self):          # import – legacy alias
        return self._tm_data()['import_monthly']

    def load_annual_trade_values(self):
        if self.annual_values is None:
            self.annual_values = self._csv("11_Annual_Trade_Values.csv")
        if self.annual_values is not None and not self.annual_values.empty:
            return self.annual_values
        monthly = self._tm_data()['import_monthly']
        if monthly.empty:
            return pd.DataFrame()
        ann = monthly.groupby('year')['import_value_usd'].sum().reset_index()
        ann.columns = ['Year', 'Trade_Value']
        return ann

    # ── Summary stats ─────────────────────────────────────────────────
    def get_statistics_summary(self):
        tm = self._tm_data()
        imp_monthly = tm['import_monthly']
        exp_monthly = tm['export_monthly']
        imp_ct = tm['import_country_totals']
        exp_ct = tm['export_country_totals']

        summary = {
            'total_hsn_codes':       len(tm['hsn_mapping']),
            'import_countries':      imp_ct['country'].nunique() if not imp_ct.empty else 0,
            'export_countries':      exp_ct['country'].nunique() if not exp_ct.empty else 0,
            'total_import_value':    imp_monthly['import_value_usd'].sum() if not imp_monthly.empty else 0,
            'total_export_value':    exp_monthly['export_value_usd'].sum() if not exp_monthly.empty else 0,
            'total_companies':       0,
        }
        comp = self.load_companies_both_sides()
        if not comp.empty:
            nc = next((c for c in comp.columns if 'company' in c.lower()), None)
            if nc:
                summary['total_companies'] = comp[nc].nunique()
        return summary

    # ── Legacy aliases ────────────────────────────────────────────────
    def get_monthly_data_by_hsn(self, hsn_code, country=None):
        return self.get_monthly_import_data(hsn_code, country)

    def get_monthly_totals_by_hsn(self, hsn_code):
        return self.get_monthly_import_totals(hsn_code)

    def _ensure_trademap(self):
        return self._tm_data()


def get_processor():
    if not hasattr(get_processor, '_instance'):
        get_processor._instance = TradeDataProcessor()
    return get_processor._instance


if __name__ == '__main__':
    p = TradeDataProcessor()
    p.load_all_data()
    stats = p.get_statistics_summary()
    print('Stats:', stats)
    print('\nTop TiO2 (320611) exporters:')
    print(p.get_top_exporting_countries('320611')[['country','total_export_value_usd']].head(5).to_string())
