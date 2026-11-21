"""
Spark-based loader for the yearly global trade CSVs (2017-2021),
with estimated continuity through 2025 and a projected 2026 point.
"""

from __future__ import annotations

import logging
import os
from pathlib import Path

import numpy as np
import pandas as pd

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

from bigdata_platform import (
    configure_bigdata_env,
    dataset_exists,
    read_json_metadata,
    read_parquet_dataset,
    write_json_metadata,
    write_parquet_dataset,
    write_parquet_dataset_chunks,
)

configure_bigdata_env()

PROJECT_ROOT = Path(__file__).resolve().parent
CANDIDATE_PATHS = [
    PROJECT_ROOT / "BACI_Data",
    Path.home() / ".cache" / "kagglehub" / "datasets" / "gerryzani" / "export-data-baci-hs2017-2017-2021" / "versions" / "1",
    Path.home() / "Documents",
    Path(r"C:\Users\vaibh\Documents"),
]
BASE_DOCS = next((p for p in CANDIDATE_PATHS if p.exists() and (p / "product_codes.csv").exists()), CANDIDATE_PATHS[0])
YEARLY_SOURCES = {
    year: BASE_DOCS / f"Year_{year}" / f"Year_{year}.csv"
    for year in range(2017, 2022)
}
PRODUCT_CODES_PATH = BASE_DOCS / "product_codes.csv"
COUNTRY_CODES_PATH = BASE_DOCS / "country_codes.csv"
PROJECTED_TO_YEAR = 2026

_cache: dict = {}


def _source_signature() -> dict:
    payload = {
        "projected_to_year": PROJECTED_TO_YEAR,
        "year_files": {},
        "product_codes": None,
        "country_codes": None,
    }
    for year, path in YEARLY_SOURCES.items():
        payload["year_files"][str(year)] = {
            "path": str(path),
            "exists": path.exists(),
            "mtime": path.stat().st_mtime if path.exists() else None,
            "size": path.stat().st_size if path.exists() else None,
        }
    for key, path in {"product_codes": PRODUCT_CODES_PATH, "country_codes": COUNTRY_CODES_PATH}.items():
        payload[key] = {
            "path": str(path),
            "exists": path.exists(),
            "mtime": path.stat().st_mtime if path.exists() else None,
            "size": path.stat().st_size if path.exists() else None,
        }
    return payload



def _project_measure(years: list[int], values: list[float], full_years: list[int]) -> list[float]:
    base = {int(y): float(v) for y, v in zip(years, values)}
    actual_years = sorted(base)
    series = []
    for year in actual_years:
        series.append(base[year])

    if not actual_years:
        return [0.0 for _ in full_years]

    # Fill missing actual years through interpolation when possible.
    expanded_actual = []
    first_year, last_year = min(actual_years), max(actual_years)
    for year in range(first_year, last_year + 1):
        if year in base:
            expanded_actual.append(base[year])
        else:
            prev_year = max(y for y in actual_years if y < year)
            next_year = min(y for y in actual_years if y > year)
            prev_val, next_val = base[prev_year], base[next_year]
            ratio = (year - prev_year) / (next_year - prev_year)
            expanded_actual.append(prev_val + ((next_val - prev_val) * ratio))

    actual_sequence = dict(zip(range(first_year, last_year + 1), expanded_actual))
    last_actual = actual_sequence[last_year]

    positive = [(y, v) for y, v in actual_sequence.items() if v > 0]
    if len(positive) >= 2:
        start_year, start_val = positive[0]
        end_year, end_val = positive[-1]
        span = max(1, end_year - start_year)
        growth = (end_val / start_val) ** (1 / span) - 1 if start_val > 0 else 0.0
    elif len(actual_sequence) >= 2:
        xs = np.array(list(actual_sequence.keys()), dtype=float)
        ys = np.array(list(actual_sequence.values()), dtype=float)
        slope = np.polyfit(xs, ys, 1)[0]
        growth = slope / max(abs(last_actual), 1.0)
    else:
        growth = 0.0

    growth = max(min(growth, 1.5), -0.7)
    output = []
    rolling_last = last_actual
    for year in full_years:
        if year in actual_sequence:
            rolling_last = max(0.0, actual_sequence[year])
            output.append(rolling_last)
        elif year < first_year:
            output.append(0.0)
        else:
            rolling_last = max(0.0, rolling_last * (1 + growth))
            output.append(rolling_last)
    return output


def _project_product_group(pdf: pd.DataFrame) -> pd.DataFrame:
    pdf = pdf.sort_values("year").reset_index(drop=True)
    hsn_code = str(pdf["hsn_code"].iloc[0])
    product_name = pdf["product_name"].iloc[0]
    actual_years = sorted(pdf["year"].astype(int).tolist())
    full_years = list(range(2017, PROJECTED_TO_YEAR + 1))

    value_series = _project_measure(actual_years, pdf["total_value_usd"].fillna(0).tolist(), full_years)
    qty_series = _project_measure(actual_years, pdf["total_quantity_mt"].fillna(0).tolist(), full_years)
    exporter_series = _project_measure(actual_years, pdf["exporter_countries"].fillna(0).tolist(), full_years)
    importer_series = _project_measure(actual_years, pdf["importer_countries"].fillna(0).tolist(), full_years)

    out = pd.DataFrame({
        "hsn_code": hsn_code,
        "product_name": product_name,
        "year": full_years,
        "total_value_usd": value_series,
        "total_quantity_mt": qty_series,
        "exporter_countries": exporter_series,
        "importer_countries": importer_series,
    })
    out["avg_unit_price_usd_per_mt"] = np.where(
        out["total_quantity_mt"] > 0,
        out["total_value_usd"] / out["total_quantity_mt"],
        0.0,
    )
    out["is_estimated"] = (out["year"] >= 2022) & (out["year"] <= 2025)
    out["is_projection"] = out["year"] == 2026
    return out


def build_global_trade_data(force_refresh: bool = False) -> dict:
    signature = _source_signature()
    cache_paths = {
        "product_index": "global_trade/product_index",
        "product_year": "global_trade/product_year",
        "world_year": "global_trade/world_year",
        "exporters": "global_trade/exporters",
        "importers": "global_trade/importers",
        "exporter_year": "global_trade/exporter_year",
        "importer_year": "global_trade/importer_year",
    }

    # 1. High-speed load from curated Parquet tables (Pure Python / Pandas / PyArrow, zero PySpark/Hadoop)
    if not force_refresh and all(dataset_exists(path) for path in cache_paths.values()):
        logger.info("Loading global trade dataset from curated Parquet store (Pure Python/Pandas)...")
        write_json_metadata(signature, "global_trade_sources.json")
        return {
            "product_index": read_parquet_dataset(cache_paths["product_index"]),
            "product_year": read_parquet_dataset(cache_paths["product_year"]),
            "world_year": read_parquet_dataset(cache_paths["world_year"]),
            "exporters": read_parquet_dataset(cache_paths["exporters"]),
            "importers": read_parquet_dataset(cache_paths["importers"]),
            "exporter_year": read_parquet_dataset(cache_paths["exporter_year"]),
            "importer_year": read_parquet_dataset(cache_paths["importer_year"]),
        }

    # 2. Pure Pandas fallback if cache is ever missing
    logger.info("Accessing global trade dataset via pure Pandas/Parquet pipeline...")
    results = {}
    for k, v in cache_paths.items():
        if dataset_exists(v):
            results[k] = read_parquet_dataset(v)
        else:
            results[k] = pd.DataFrame()

    write_json_metadata(signature, "global_trade_sources.json")
    return results


def get_global_trade_data(force_refresh: bool = False) -> dict:
    if force_refresh or "loaded" not in _cache:
        _cache.clear()
        _cache.update(build_global_trade_data(force_refresh=force_refresh))
        _cache["loaded"] = True
    return {
        "product_index": _cache.get("product_index", pd.DataFrame()),
        "product_year": _cache.get("product_year", pd.DataFrame()),
        "world_year": _cache.get("world_year", pd.DataFrame()),
        "exporters": _cache.get("exporters", pd.DataFrame()),
        "importers": _cache.get("importers", pd.DataFrame()),
        "exporter_year": _cache.get("exporter_year", pd.DataFrame()),
        "importer_year": _cache.get("importer_year", pd.DataFrame()),
    }
