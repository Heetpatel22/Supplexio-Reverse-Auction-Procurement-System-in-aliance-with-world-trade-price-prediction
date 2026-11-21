"""
Project-local Hadoop/Spark bootstrap and storage helpers.

This module keeps the application self-contained on Windows:
  - picks a valid Java 17 runtime if the machine-level JAVA_HOME is outdated
  - points Spark at the bundled PySpark distribution if SPARK_HOME is broken
  - stores curated datasets in a Hadoop-style local warehouse (Parquet)
"""

from __future__ import annotations

import json
import os
import shutil
import stat
import time
from pathlib import Path
from typing import Iterable

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent
BIGDATA_ROOT = PROJECT_ROOT / "bigdata_platform"
HADOOP_HOME = BIGDATA_ROOT / "hadoop"
WAREHOUSE_ROOT = BIGDATA_ROOT / "hadoop_warehouse"
RAW_ZONE = WAREHOUSE_ROOT / "raw"
PROCESSED_ZONE = WAREHOUSE_ROOT / "processed"
METADATA_ZONE = WAREHOUSE_ROOT / "metadata"

_SPARK = None


def _ensure_dirs() -> None:
    for path in (BIGDATA_ROOT, HADOOP_HOME, HADOOP_HOME / "bin", RAW_ZONE, PROCESSED_ZONE, METADATA_ZONE):
        path.mkdir(parents=True, exist_ok=True)


def _version_tuple(name: str) -> tuple[int, ...]:
    digits = []
    current = []
    for char in name:
        if char.isdigit():
            current.append(char)
        elif current:
            digits.append(int("".join(current)))
            current = []
    if current:
        digits.append(int("".join(current)))
    return tuple(digits)


def _java_major_version(java_home: Path) -> int:
    release_file = java_home / "release"
    if release_file.exists():
        for line in release_file.read_text(encoding="utf-8", errors="ignore").splitlines():
            if line.startswith("JAVA_VERSION="):
                raw = line.split("=", 1)[1].strip().strip('"')
                if raw.startswith("1."):
                    parts = raw.split(".")
                    return int(parts[1]) if len(parts) > 1 else 0
                return int(raw.split(".", 1)[0])
    return 0


def _find_java_home() -> Path | None:
    env_java = os.environ.get("JAVA_HOME")
    if env_java and (Path(env_java) / "bin" / "java.exe").exists():
        env_path = Path(env_java)
        if _java_major_version(env_path) >= 17:
            return env_path

    candidates: list[Path] = []
    search_roots = [
        Path(r"C:\Program Files\Microsoft"),
        Path(r"C:\Program Files\Eclipse Adoptium"),
        Path(r"C:\Program Files\Java"),
    ]
    for root in search_roots:
        if not root.exists():
            continue
        candidates.extend(
            path for path in root.iterdir()
            if path.is_dir() and path.name.lower().startswith(("jdk-", "microsoft", "temurin"))
            and (path / "bin" / "java.exe").exists()
        )

    if not candidates:
        return None
    valid = [candidate for candidate in candidates if _java_major_version(candidate) >= 17]
    if valid:
        return sorted(valid, key=lambda item: _version_tuple(item.name), reverse=True)[0]
    return sorted(candidates, key=lambda item: _version_tuple(item.name), reverse=True)[0]


def _find_spark_home() -> Path | None:
    env_spark = os.environ.get("SPARK_HOME")
    if env_spark:
        env_path = Path(env_spark)
        if (env_path / "bin" / "spark-submit.cmd").exists() and (env_path / "jars").exists():
            return env_path

    try:
        import pyspark
        return Path(pyspark.__file__).resolve().parent
    except ImportError:
        return None


def configure_bigdata_env() -> dict[str, str]:
    _ensure_dirs()
    return {
        "warehouse_root": str(WAREHOUSE_ROOT),
    }


def get_spark_session(app_name: str = "PaintTradeStorage"):
    """Spark runtime is disabled; system operates via high-speed pure Pandas & Parquet storage."""
    return None


def _dataset_path(relative_path: str) -> Path:
    return PROCESSED_ZONE / relative_path


def _on_rm_error(func, path, exc_info) -> None:
    os.chmod(path, stat.S_IWRITE)
    func(path)


def _reset_dataset_dir(target: Path) -> None:
    if not target.exists():
        target.mkdir(parents=True, exist_ok=True)
        return

    last_error = None
    for _ in range(5):
        try:
            shutil.rmtree(target, onexc=_on_rm_error)
            last_error = None
            break
        except OSError as exc:
            last_error = exc
            time.sleep(0.5)
    if last_error is not None:
        raise last_error
    target.mkdir(parents=True, exist_ok=True)


def dataset_exists(relative_path: str) -> bool:
    path = _dataset_path(relative_path)
    return path.exists() and any(path.iterdir())


def write_parquet_dataset(df: pd.DataFrame, relative_path: str) -> Path:
    target = _dataset_path(relative_path)
    _reset_dataset_dir(target)

    if df.empty:
        target.mkdir(parents=True, exist_ok=True)
        (target / "_EMPTY").write_text("", encoding="utf-8")
        return target

    file_path = target / "part-00000.parquet"
    df.to_parquet(file_path, index=False)
    return target


def write_parquet_dataset_chunks(chunks: Iterable[pd.DataFrame], relative_path: str) -> Path:
    target = _dataset_path(relative_path)
    _reset_dataset_dir(target)

    wrote_any = False
    part_index = 0
    for chunk in chunks:
        if chunk is None or chunk.empty:
            continue
        file_path = target / f"part-{part_index:05d}.parquet"
        chunk.to_parquet(file_path, index=False)
        part_index += 1
        wrote_any = True

    if not wrote_any:
        (target / "_EMPTY").write_text("", encoding="utf-8")
    return target


def read_parquet_dataset(relative_path: str) -> pd.DataFrame:
    target = _dataset_path(relative_path)
    if not target.exists():
        return pd.DataFrame()
    if (target / "_EMPTY").exists():
        return pd.DataFrame()

    parquet_files = sorted(target.glob("*.parquet"))
    if not parquet_files:
        return pd.DataFrame()
    frames = [pd.read_parquet(file_path) for file_path in parquet_files]
    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


def write_json_metadata(payload: dict, filename: str) -> Path:
    target = METADATA_ZONE / filename
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return target


def read_json_metadata(filename: str, default=None):
    target = METADATA_ZONE / filename
    if not target.exists():
        return {} if default is None else default
    return json.loads(target.read_text(encoding="utf-8"))


def sync_raw_sources(paths: Iterable[Path | str], zone_name: str) -> Path:
    zone_root = RAW_ZONE / zone_name
    zone_root.mkdir(parents=True, exist_ok=True)

    for source in paths:
        source_path = Path(source)
        if not source_path.exists():
            continue
        destination = zone_root / source_path.name
        if source_path.is_dir():
            if not destination.exists():
                shutil.copytree(source_path, destination)
        else:
            if not destination.exists() or source_path.stat().st_mtime > destination.stat().st_mtime:
                shutil.copy2(source_path, destination)
    return zone_root
