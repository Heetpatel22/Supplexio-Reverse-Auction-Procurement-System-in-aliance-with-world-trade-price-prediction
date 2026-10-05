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
    get_spark_session,
    read_json_metadata,
    read_parquet_dataset,
    write_json_metadata,
    write_parquet_dataset,
    write_parquet_dataset_chunks,
)

configure_bigdata_env()

BASE_DOCS = Path(r"C:\Users\vaibh\Documents")
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


def _projection_schema():
    from pyspark.sql.types import (
        BooleanType,
        DoubleType,
        IntegerType,
        StringType,
        StructField,
        StructType,
    )

    return StructType([
        StructField("hsn_code", StringType(), False),
        StructField("product_name", StringType(), True),
        StructField("year", IntegerType(), False),
        StructField("total_value_usd", DoubleType(), True),
        StructField("total_quantity_mt", DoubleType(), True),
        StructField("exporter_countries", DoubleType(), True),
        StructField("importer_countries", DoubleType(), True),
        StructField("avg_unit_price_usd_per_mt", DoubleType(), True),
        StructField("is_estimated", BooleanType(), False),
        StructField("is_projection", BooleanType(), False),
    ])


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


def _write_streamed_spark_dataset(
    spark_df,
    relative_path: str,
    *,
    chunk_size: int = 100_000,
    repartitions: int = 32,
    finalize=None,
) -> pd.DataFrame:
    columns = list(spark_df.columns)
    streamed_df = spark_df.repartition(repartitions)

    def _chunks():
        rows = []
        for row in streamed_df.toLocalIterator(prefetchPartitions=False):
            rows.append(row.asDict(recursive=True))
            if len(rows) >= chunk_size:
                chunk = pd.DataFrame.from_records(rows, columns=columns)
                if finalize is not None:
                    chunk = finalize(chunk)
                yield chunk
                rows = []
        if rows:
            chunk = pd.DataFrame.from_records(rows, columns=columns)
            if finalize is not None:
                chunk = finalize(chunk)
            yield chunk

    write_parquet_dataset_chunks(_chunks(), relative_path)
    return read_parquet_dataset(relative_path)


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
    saved_signature = read_json_metadata("global_trade_sources.json", default={})

    if (
        not force_refresh
        and signature == saved_signature
        and all(dataset_exists(path) for path in cache_paths.values())
    ):
        product_index = read_parquet_dataset(cache_paths["product_index"])
        product_year = read_parquet_dataset(cache_paths["product_year"])
        world_year = read_parquet_dataset(cache_paths["world_year"])
        exporters = read_parquet_dataset(cache_paths["exporters"])
        importers = read_parquet_dataset(cache_paths["importers"])
        exporter_year = read_parquet_dataset(cache_paths["exporter_year"])
        importer_year = read_parquet_dataset(cache_paths["importer_year"])
        return {
            "product_index": product_index,
            "product_year": product_year,
            "world_year": world_year,
            "exporters": exporters,
            "importers": importers,
            "exporter_year": exporter_year,
            "importer_year": importer_year,
        }

    try:
        spark = get_spark_session("GlobalTradeWarehouse")
        from pyspark.sql import functions as F
        spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "false")
    except Exception as err:
        logger.warning(f"Spark is unavailable ({err}); skipping PySpark global warehouse aggregation.")
        empty = pd.DataFrame()
        return {
            "product_index": empty,
            "product_year": empty,
            "world_year": empty,
            "exporters": empty,
            "importers": empty,
            "exporter_year": empty,
            "importer_year": empty,
        }

    def _safe_double(col_name: str):
        raw = F.trim(F.col(col_name))
        cleaned = F.when(
            raw.isNull() | (raw == "") | (F.lower(raw) == "na"),
            F.lit(None),
        ).otherwise(F.regexp_replace(raw, ",", ""))
        return cleaned.cast("double")

    source_files = [str(path) for path in YEARLY_SOURCES.values() if path.exists()]
    if not source_files or not PRODUCT_CODES_PATH.exists() or not COUNTRY_CODES_PATH.exists():
        empty = pd.DataFrame()
        return {
            "product_index": empty,
            "product_year": empty,
            "world_year": empty,
            "exporters": empty,
            "importers": empty,
            "exporter_year": empty,
            "importer_year": empty,
        }

    trade_df = (
        spark.read.option("header", True).csv(source_files)
        .select("t", "i", "j", "k", "v", "q")
        .withColumn("year", F.col("t").cast("int"))
        .withColumn("exporter_code", F.col("i").cast("int"))
        .withColumn("importer_code", F.col("j").cast("int"))
        .withColumn("hsn_code", F.lpad(F.col("k").cast("string"), 6, "0"))
        .withColumn("value_usd", F.coalesce(_safe_double("v"), F.lit(0.0)) * F.lit(1000.0))
        .withColumn("quantity_mt", F.coalesce(_safe_double("q"), F.lit(0.0)))
        .drop("t", "i", "j", "k", "v", "q")
        .filter(F.col("year").isNotNull() & F.col("hsn_code").isNotNull())
    )

    product_df = (
        spark.read.option("header", True).csv(str(PRODUCT_CODES_PATH))
        .select(
            F.lpad(F.col("code").cast("string"), 6, "0").alias("hsn_code"),
            F.col("description").alias("product_name"),
        )
        .dropDuplicates(["hsn_code"])
    )

    country_df = (
        spark.read.option("header", True).csv(str(COUNTRY_CODES_PATH))
        .select(
            F.col("country_code").cast("int").alias("country_code"),
            F.col("country_name_full").alias("country_name"),
            F.col("iso_3digit_alpha").alias("iso3"),
        )
        .dropDuplicates(["country_code"])
    )

    exporters_lookup = country_df.select(
        F.col("country_code").alias("exporter_code"),
        F.col("country_name").alias("exporter_country"),
        F.col("iso3").alias("exporter_iso3"),
    )
    importers_lookup = country_df.select(
        F.col("country_code").alias("importer_code"),
        F.col("country_name").alias("importer_country"),
        F.col("iso3").alias("importer_iso3"),
    )

    enriched = (
        trade_df.join(product_df, on="hsn_code", how="left")
        .join(exporters_lookup, on="exporter_code", how="left")
        .join(importers_lookup, on="importer_code", how="left")
        .withColumn("product_name", F.coalesce(F.col("product_name"), F.concat(F.lit("Product "), F.col("hsn_code"))))
        .withColumn("exporter_country", F.coalesce(F.col("exporter_country"), F.lit("Unknown")))
        .withColumn("importer_country", F.coalesce(F.col("importer_country"), F.lit("Unknown")))
        .withColumn("exporter_iso3", F.coalesce(F.col("exporter_iso3"), F.lit("---")))
        .withColumn("importer_iso3", F.coalesce(F.col("importer_iso3"), F.lit("---")))
    )

    product_index = (
        enriched.select("hsn_code", "product_name")
        .dropDuplicates(["hsn_code"])
        .toPandas()
        .sort_values("hsn_code")
        .reset_index(drop=True)
    )

    actual_product_year = (
        enriched.groupBy("hsn_code", "product_name", "year")
        .agg(
            F.sum("value_usd").alias("total_value_usd"),
            F.sum("quantity_mt").alias("total_quantity_mt"),
            F.countDistinct("exporter_iso3").alias("exporter_countries"),
            F.countDistinct("importer_iso3").alias("importer_countries"),
        )
    )

    actual_product_year_pd = actual_product_year.toPandas().sort_values(["hsn_code", "year"]).reset_index(drop=True)
    product_year = (
        actual_product_year_pd.groupby("hsn_code", group_keys=False)[actual_product_year_pd.columns]
        .apply(_project_product_group)
        .sort_values(["hsn_code", "year"])
        .reset_index(drop=True)
    )

    exporters = (
        enriched.groupBy("hsn_code", "product_name", "exporter_country", "exporter_iso3")
        .agg(
            F.sum("value_usd").alias("total_value_usd"),
            F.sum("quantity_mt").alias("total_quantity_mt"),
            F.countDistinct("year").alias("years_present"),
        )
    )

    importers = (
        enriched.groupBy("hsn_code", "product_name", "importer_country", "importer_iso3")
        .agg(
            F.sum("value_usd").alias("total_value_usd"),
            F.sum("quantity_mt").alias("total_quantity_mt"),
            F.countDistinct("year").alias("years_present"),
        )
    )

    exporter_year = (
        enriched.groupBy("hsn_code", "product_name", "exporter_country", "exporter_iso3", "year")
        .agg(
            F.sum("value_usd").alias("total_value_usd"),
            F.sum("quantity_mt").alias("total_quantity_mt"),
        )
    )

    importer_year = (
        enriched.groupBy("hsn_code", "product_name", "importer_country", "importer_iso3", "year")
        .agg(
            F.sum("value_usd").alias("total_value_usd"),
            F.sum("quantity_mt").alias("total_quantity_mt"),
        )
    )

    world_year_input = product_year.copy()
    world_year = (
        world_year_input.groupby(["year", "is_estimated", "is_projection"], as_index=False)
        .agg(
            total_value_usd=("total_value_usd", "sum"),
            total_quantity_mt=("total_quantity_mt", "sum"),
            products_active=("hsn_code", "nunique"),
        )
    )
    world_year = world_year.sort_values("year").reset_index(drop=True)

    write_parquet_dataset(product_index, cache_paths["product_index"])
    write_parquet_dataset(product_year, cache_paths["product_year"])
    write_parquet_dataset(world_year, cache_paths["world_year"])
    exporters = _write_streamed_spark_dataset(
        exporters,
        cache_paths["exporters"],
        chunk_size=75_000,
        repartitions=24,
        finalize=lambda df: df.sort_values(["hsn_code", "total_value_usd"], ascending=[True, False]).reset_index(drop=True),
    )
    importers = _write_streamed_spark_dataset(
        importers,
        cache_paths["importers"],
        chunk_size=75_000,
        repartitions=32,
        finalize=lambda df: df.sort_values(["hsn_code", "total_value_usd"], ascending=[True, False]).reset_index(drop=True),
    )
    exporter_year = _write_streamed_spark_dataset(
        exporter_year,
        cache_paths["exporter_year"],
        chunk_size=75_000,
        repartitions=24,
        finalize=lambda df: (
            df.assign(
                year=df["year"].astype(int),
                date=pd.to_datetime(df["year"].astype(int).astype(str) + "-01-01"),
                year_month=df["year"].astype(int).astype(str) + "-01",
            )
            .sort_values(["hsn_code", "exporter_country", "year"])
            .reset_index(drop=True)
        ),
    )
    importer_year = _write_streamed_spark_dataset(
        importer_year,
        cache_paths["importer_year"],
        chunk_size=50_000,
        repartitions=40,
        finalize=lambda df: (
            df.assign(
                year=df["year"].astype(int),
                date=pd.to_datetime(df["year"].astype(int).astype(str) + "-01-01"),
                year_month=df["year"].astype(int).astype(str) + "-01",
            )
            .sort_values(["hsn_code", "importer_country", "year"])
            .reset_index(drop=True)
        ),
    )
    write_json_metadata(signature, "global_trade_sources.json")

    return {
        "product_index": product_index,
        "product_year": product_year,
        "world_year": world_year,
        "exporters": exporters,
        "importers": importers,
        "exporter_year": exporter_year,
        "importer_year": importer_year,
    }


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
