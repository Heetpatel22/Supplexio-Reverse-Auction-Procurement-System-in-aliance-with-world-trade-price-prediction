# Hadoop + Spark Setup For This Project

This project now uses a project-local big-data layer:

- Storage: `bigdata_platform/hadoop_warehouse/`
- Processing: local Apache Spark runtime via `pyspark`
- Java: auto-detected Java 17 runtime
- Global annual source files:
  - `C:\Users\vaibh\Documents\Year_2017` ... `Year_2021`
  - `C:\Users\vaibh\Documents\product_codes.csv`
  - `C:\Users\vaibh\Documents\country_codes.csv`

## What changed

- TradeMap processing is now executed through Spark aggregations.
- CSV support datasets are cached as Parquet inside the Hadoop-style warehouse.
- The original folders and features remain unchanged; the app still reads the same source data.

## Verify

```powershell
python verify_bigdata_setup.py
```

## Build the all-products warehouse

```powershell
python build_global_warehouse.py
```

First build can take around 1-2 minutes. After that the cached warehouse loads much faster.

## Run

```powershell
.\run_dashboard_bigdata.ps1
```

```powershell
.\run_api_bigdata.ps1
```

## Storage layout

- `bigdata_platform/hadoop_warehouse/raw/`
- `bigdata_platform/hadoop_warehouse/processed/trademap/`
- `bigdata_platform/hadoop_warehouse/processed/csv/`
- `bigdata_platform/hadoop_warehouse/metadata/`
