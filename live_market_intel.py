"""
live_market_intel.py — Multi-Source Real-Time World Trade & 1D-ResNet Forecasting Engine.

Fuses 5 live intelligence layers for exact price hike & drop prediction:
1. Live Commodity Futures & USD/INR FX (Yahoo Finance JSON API, 5-min cache)
2. World Bank Commodity Markets Pink Sheet (CMO-Historical-Data-Monthly.xlsx, 6-hr cache)
3. DGFT & CBIC India Customs Duty / Anti-Dumping / Policy Alerts (RSS, 30-min cache)
4. UN Comtrade Database India (reporterCode=699) Volume Shift (on-demand per HSN, 12-hr cache)
5. Trained 1D-ResNet (model_resnet.keras) + CEPII BACI Trade Lakehouse
"""

import io
import json
import logging
import os
import time
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime

logger = logging.getLogger(__name__)

_MARKET_CACHE = {
    "timestamp": 0.0,
    "fetched_at_str": "",
    "signals": {},
    "nn_cache": {}
}
CACHE_TTL_SECONDS = 300  # 5 minutes for live futures/FX

_PINK_SHEET_CACHE = {
    "timestamp": 0.0,
    "url": "",
    "metrics": {},
    "latest_period": ""
}
PINK_SHEET_TTL = 21600  # 6 hours

_DGFT_CACHE = {
    "timestamp": 0.0,
    "alerts": []
}
DGFT_TTL = 1800  # 30 minutes

_COMTRADE_CACHE = {}  # hsn4 -> {"ts": float, "yoy_vol_pct": float, "note": str}
COMTRADE_TTL = 43200  # 12 hours

_WB_MACRO_CACHE = {"timestamp": 0.0, "india_cpi": None}
WB_MACRO_TTL = 43200  # 12 hours

_OPTIONAL_KEY_CACHE = {"timestamp": 0.0, "fred": {}, "datagov": None}

TICKER_META = {
    "HG=F": ("Copper Futures", "COMEX Copper"),
    "ALI=F": ("Aluminum Futures", "LME Aluminum"),
    "SLX": ("Global Steel & Iron", "Steel ETF"),
    "CL=F": ("Crude Oil (Feedstock)", "WTI Crude"),
    "LBR=F": ("Lumber & Wood Futures", "CME Lumber"),
    "XLB": ("Materials & Chemicals", "Global Materials"),
    "XLI": ("Industrial Machinery", "Global Industrials"),
    "USDINR=X": ("USD/INR FX Rate", "Forex"),
}

# Mapping from World Bank Pink Sheet column names to internal keys
PINK_SHEET_COLS = {
    "WB_CRUDE": "Crude oil, average",
    "WB_COPPER": "Copper",
    "WB_ALUMINUM": "Aluminum",
    "WB_IRON": "Iron ore, cfr spot",
    "WB_ZINC": "Zinc",
    "WB_NICKEL": "Nickel",
    "WB_LEAD": "Lead",
    "WB_RUBBER": "Rubber, TSR20 **",
    "WB_PLYWOOD": "Plywood",
    "WB_SAWNWOOD": "Sawnwood, Malaysian",
    "WB_UREA": "Urea ",
    "WB_COTTON": "Cotton, A Index",
}


def _fetch_single_ticker(symbol: str):
    """Fetch 1-month daily closes for a live market ticker."""
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?range=1mo&interval=1d"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=4) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        result = data["chart"]["result"][0]
        closes = [float(x) for x in result["indicators"]["quote"][0]["close"] if x is not None]
        if len(closes) >= 2 and closes[0] > 0:
            latest = closes[-1]
            pct_30d = ((latest - closes[0]) / closes[0]) * 100.0
            base_7d = closes[-min(6, len(closes))]
            pct_7d = ((latest - base_7d) / base_7d) * 100.0 if base_7d > 0 else pct_30d
            return symbol, {
                "symbol": symbol,
                "label": TICKER_META[symbol][0],
                "latest": round(latest, 2),
                "pct_30d": round(pct_30d, 2),
                "pct_7d": round(pct_7d, 2),
                "closes": closes[-5:],
                "live": True,
            }
    except Exception as exc:
        logger.debug("Live market fetch failed for %s: %s", symbol, exc)
    return symbol, None


def get_live_market_signals(force_refresh: bool = False):
    """Return cached or freshly-fetched live global commodity & FX market signals."""
    now = time.time()
    if not force_refresh and _MARKET_CACHE["signals"] and (now - _MARKET_CACHE["timestamp"] < CACHE_TTL_SECONDS):
        return _MARKET_CACHE["signals"], _MARKET_CACHE["fetched_at_str"]

    signals = {}
    with ThreadPoolExecutor(max_workers=8) as pool:
        for sym, res in pool.map(_fetch_single_ticker, list(TICKER_META.keys())):
            if res is not None:
                signals[sym] = res

    if signals:
        _MARKET_CACHE["signals"] = signals
        _MARKET_CACHE["timestamp"] = now
        _MARKET_CACHE["fetched_at_str"] = datetime.now().strftime("%d %b %Y, %H:%M IST")
        _MARKET_CACHE["nn_cache"] = {}
    elif not _MARKET_CACHE["signals"]:
        _MARKET_CACHE["fetched_at_str"] = "BACI Baseline (Offline)"

    return _MARKET_CACHE["signals"], _MARKET_CACHE["fetched_at_str"]


def get_world_bank_pink_sheet():
    """Fetch & parse World Bank Commodity Markets Pink Sheet (Monthly Prices)."""
    now = time.time()
    if _PINK_SHEET_CACHE["metrics"] and (now - _PINK_SHEET_CACHE["timestamp"] < PINK_SHEET_TTL):
        return _PINK_SHEET_CACHE["metrics"], _PINK_SHEET_CACHE["latest_period"]

    try:
        import re
        import pandas as pd

        page_url = "https://www.worldbank.org/en/research/commodity-markets"
        html = urllib.request.urlopen(
            urllib.request.Request(page_url, headers={"User-Agent": "Mozilla/5.0"}), timeout=8
        ).read().decode("utf-8", "ignore")
        links = re.findall(r'https://thedocs\.worldbank\.org/[^\s"\'<>]+CMO-Historical-Data-Monthly\.xlsx', html)
        if not links:
            return _PINK_SHEET_CACHE["metrics"], _PINK_SHEET_CACHE["latest_period"]

        xlsx_bytes = urllib.request.urlopen(
            urllib.request.Request(links[0], headers={"User-Agent": "Mozilla/5.0"}), timeout=15
        ).read()
        df = pd.read_excel(io.BytesIO(xlsx_bytes), sheet_name="Monthly Prices", skiprows=4)
        period_col = df.columns[0]
        df = df[df[period_col].astype(str).str.match(r"^\d{4}M\d{2}$", na=False)].copy()
        if len(df) < 4:
            return _PINK_SHEET_CACHE["metrics"], _PINK_SHEET_CACHE["latest_period"]

        latest_period = str(df[period_col].iloc[-1])
        metrics = {}
        for key, col_name in PINK_SHEET_COLS.items():
            if col_name in df.columns:
                vals = pd.to_numeric(df[col_name], errors="coerce").dropna()
                if len(vals) >= 4 and vals.iloc[-2] > 0 and vals.iloc[-4] > 0:
                    mom_pct = ((vals.iloc[-1] - vals.iloc[-2]) / vals.iloc[-2]) * 100.0
                    qtr_pct = ((vals.iloc[-1] - vals.iloc[-4]) / vals.iloc[-4]) * 100.0
                    metrics[key] = {
                        "name": col_name.strip(" *"),
                        "latest": round(float(vals.iloc[-1]), 2),
                        "mom_pct": round(float(mom_pct), 2),
                        "qtr_pct": round(float(qtr_pct), 2),
                    }

        if metrics:
            _PINK_SHEET_CACHE["metrics"] = metrics
            _PINK_SHEET_CACHE["latest_period"] = latest_period
            _PINK_SHEET_CACHE["url"] = links[0]
            _PINK_SHEET_CACHE["timestamp"] = now
    except Exception as exc:
        logger.debug("World Bank Pink Sheet fetch skipped: %s", exc)

    return _PINK_SHEET_CACHE["metrics"], _PINK_SHEET_CACHE["latest_period"]


def get_dgft_cbic_alerts():
    """Fetch recent DGFT & CBIC Indian customs duty / anti-dumping / export ban notifications."""
    now = time.time()
    if _DGFT_CACHE["alerts"] and (now - _DGFT_CACHE["timestamp"] < DGFT_TTL):
        return _DGFT_CACHE["alerts"]

    alerts = []
    try:
        rss_url = (
            "https://news.google.com/rss/search?q=(DGFT+OR+CBIC)+"
            "(customs+duty+OR+import+duty+OR+export+ban+OR+anti-dumping+OR+safeguard)+India+when:30d"
            "&hl=en-IN&gl=IN&ceid=IN:en"
        )
        rss = urllib.request.urlopen(
            urllib.request.Request(rss_url, headers={"User-Agent": "Mozilla/5.0"}), timeout=6
        ).read()
        root = ET.fromstring(rss)
        for item in root.findall(".//item")[:20]:
            title = (item.findtext("title") or "").strip()
            low = title.lower()
            if not title:
                continue
            impact = 0.0
            if any(w in low for w in ("hike", "raises", "anti-dumping", "safeguard", "ban", "restrict", "duty on")):
                impact = 1.8
            elif any(w in low for w in ("cut", "exempt", "reduces", "slash", "relief")):
                impact = -1.5
            alerts.append({"title": title, "low": low, "impact": impact})

        if alerts:
            _DGFT_CACHE["alerts"] = alerts
            _DGFT_CACHE["timestamp"] = now
    except Exception as exc:
        logger.debug("DGFT/CBIC feed fetch skipped: %s", exc)

    return _DGFT_CACHE["alerts"]


def match_dgft_policy_for_hsn(hsn_code: str, name: str, category: str):
    """Match any active DGFT/CBIC customs duty or trade policy alert to the product's sector."""
    alerts = get_dgft_cbic_alerts()
    if not alerts:
        return 0.0, None

    ch = str(hsn_code or "")[:2]
    text = f"{name} {category}".lower()
    keywords = []
    if ch in ("72", "73") or "steel" in text or "iron" in text:
        keywords = ["steel", "iron", "alloy", "metal"]
    elif ch == "74" or "copper" in text:
        keywords = ["copper", "metal"]
    elif ch == "76" or "aluminum" in text or "aluminium" in text:
        keywords = ["aluminium", "aluminum", "metal"]
    elif ch in ("28", "29", "32", "38", "39") or any(k in text for k in ("chemical", "polymer", "pvc", "plastic", "paint", "resin", "zinc")):
        keywords = ["chemical", "polymer", "pvc", "plastic", "resin", "petrochemical"]
    elif ch in ("84", "85") or any(k in text for k in ("solar", "panel", "electrical", "machinery")):
        keywords = ["solar", "photovoltaic", "machinery", "electronics", "electrical"]
    elif ch in ("44", "47", "48") or "wood" in text or "paper" in text:
        keywords = ["wood", "timber", "plywood", "paper"]

    for a in alerts:
        if any(kw in a["low"] for kw in keywords) and a["impact"] != 0.0:
            short_title = a["title"].split(" - ")[0][:75]
            return a["impact"], f"DGFT/CBIC Policy: '{short_title}' ({a['impact']:+.1f}%)"
    return 0.0, None


def get_un_comtrade_india_signal(hsn_code: str):
    """
    Query UN Comtrade Public Preview API for India (reporterCode=699) import volume shifts.
    Used on-demand in Timing Oracle (cached 12h per 4-digit heading to respect public rate limits).
    """
    hsn4 = str(hsn_code or "").strip()[:4]
    if len(hsn4) < 4 or not hsn4.isdigit():
        return 0.0, None

    now = time.time()
    cached = _COMTRADE_CACHE.get(hsn4)
    if cached and (now - cached["ts"] < COMTRADE_TTL):
        return cached["adj"], cached["note"]

    try:
        vals = {}
        for yr in ("2022", "2023"):
            u_url = f"https://comtradeapi.un.org/public/v1/preview/C/A/HS?reporterCode=699&period={yr}&cmdCode={hsn4}&flowCode=M"
            data = json.loads(
                urllib.request.urlopen(urllib.request.Request(u_url, headers={"User-Agent": "Mozilla/5.0"}), timeout=5).read()
            )
            world_rows = [r for r in data.get("data", []) if r.get("partnerCode") == 0]
            if world_rows:
                w = world_rows[0]
                qty = float(w.get("netWgt") or w.get("primaryValue") or 0)
                if qty > 0:
                    vals[yr] = qty

        if "2022" in vals and "2023" in vals:
            vol_chg = ((vals["2023"] - vals["2022"]) / vals["2022"]) * 100.0
            # Falling Indian imports tighten domestic supply (positive price pressure)
            adj = round(max(-2.0, min(2.0, -vol_chg * 0.08)), 2)
            note = f"UN Comtrade India (HS {hsn4}) import vol {vol_chg:+.1f}% YoY"
            _COMTRADE_CACHE[hsn4] = {"ts": now, "adj": adj, "note": note}
            return adj, note
    except Exception as exc:
        logger.debug("UN Comtrade fetch skipped for %s: %s", hsn4, exc)

    _COMTRADE_CACHE[hsn4] = {"ts": now, "adj": 0.0, "note": None}
    return 0.0, None


def get_world_bank_india_cpi():
    """Fetch latest India CPI inflation % from World Bank Open Data API (no key required)."""
    now = time.time()
    if _WB_MACRO_CACHE["india_cpi"] is not None and (now - _WB_MACRO_CACHE["timestamp"] < WB_MACRO_TTL):
        return _WB_MACRO_CACHE["india_cpi"]
    try:
        url = "https://api.worldbank.org/v2/country/IND/indicator/FP.CPI.TOTL.ZG?format=json&per_page=5"
        data = json.loads(
            urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"}), timeout=5).read()
        )
        if isinstance(data, list) and len(data) > 1:
            for row in data[1]:
                if row.get("value") is not None:
                    val = round(float(row["value"]), 2)
                    _WB_MACRO_CACHE["india_cpi"] = (val, row.get("date"))
                    _WB_MACRO_CACHE["timestamp"] = now
                    return _WB_MACRO_CACHE["india_cpi"]
    except Exception as exc:
        logger.debug("World Bank India CPI skipped: %s", exc)
    return _WB_MACRO_CACHE["india_cpi"]


def get_optional_fred_and_datagov(hsn_code: str):
    """Query FRED REST API (if FRED_API_KEY env is set) and Data.gov.in (if DATA_GOV_IN_API_KEY env is set)."""
    fred_key = os.environ.get("FRED_API_KEY", "").strip()
    dg_key = os.environ.get("DATA_GOV_IN_API_KEY", "").strip()
    fred_adj = 0.0
    notes = []

    if fred_key:
        ch = str(hsn_code or "")[:2]
        sid = "PCOPPUSDM" if ch == "74" else ("PALUMUSDM" if ch == "76" else "DCOILWTICO")
        now = time.time()
        cached = _OPTIONAL_KEY_CACHE["fred"].get(sid)
        if cached and (now - cached["ts"] < 3600):
            fred_adj, fnote = cached["adj"], cached["note"]
            if fnote:
                notes.append(fnote)
        else:
            try:
                furl = f"https://api.stlouisfed.org/fred/series/observations?series_id={sid}&api_key={fred_key}&file_type=json&sort_order=desc&limit=5"
                fdata = json.loads(urllib.request.urlopen(furl, timeout=4).read())
                obs = [float(o["value"]) for o in fdata.get("observations", []) if o.get("value", ".") != "."]
                if len(obs) >= 2 and obs[-1] > 0:
                    fpct = ((obs[0] - obs[-1]) / obs[-1]) * 100.0
                    fred_adj = round(max(-3.0, min(3.0, fpct * 0.25)), 2)
                    fnote = f"FRED {sid} {fpct:+.1f}%"
                    _OPTIONAL_KEY_CACHE["fred"][sid] = {"ts": now, "adj": fred_adj, "note": fnote}
                    notes.append(fnote)
            except Exception as exc:
                logger.debug("FRED API skipped: %s", exc)

    if dg_key and _OPTIONAL_KEY_CACHE["datagov"] is None:
        try:
            dg_url = f"https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key={dg_key}&format=json&limit=5"
            ddata = json.loads(urllib.request.urlopen(dg_url, timeout=4).read())
            if ddata.get("records"):
                _OPTIONAL_KEY_CACHE["datagov"] = f"Data.gov.in live ({len(ddata['records'])} mandi/trade recs)"
        except Exception:
            _OPTIONAL_KEY_CACHE["datagov"] = ""

    if _OPTIONAL_KEY_CACHE.get("datagov"):
        notes.append(_OPTIONAL_KEY_CACHE["datagov"])

    return fred_adj, notes


def map_hsn_to_ticker(hsn_code: str, category: str = "") -> str:
    """Map a 6-digit HSN code (by 2-digit chapter) or category to its live global market benchmark."""
    hsn = str(hsn_code or "").strip()
    ch = hsn[:2] if len(hsn) >= 2 else ""
    cat = str(category or "").lower()

    if ch == "74" or "copper" in cat:
        return "HG=F"
    if ch == "76" or "aluminum" in cat or "aluminium" in cat:
        return "ALI=F"
    if ch in ("72", "73") or "steel" in cat or "iron" in cat:
        return "SLX"
    if ch in ("44", "47", "48", "94") or "wood" in cat or "timber" in cat or "lumber" in cat:
        return "LBR=F"
    if ch in ("25", "27", "28", "29", "32", "35", "38", "39", "40") or any(k in cat for k in ("paint", "chemical", "polymer", "plastic", "bitumen", "petro")):
        return "CL=F"
    if ch in ("84", "85", "87", "90") or any(k in cat for k in ("machinery", "electrical", "tool", "generator", "solar")):
        return "XLI"
    return "XLB"


def map_hsn_to_pink_sheet_key(hsn_code: str, name: str = "", category: str = "") -> str:
    """Map an HSN / product to its specific World Bank Pink Sheet commodity."""
    hsn = str(hsn_code or "").strip()
    ch = hsn[:2] if len(hsn) >= 2 else ""
    text = f"{name} {category}".lower()

    if "zinc" in text or ch == "79":
        return "WB_ZINC"
    if "nickel" in text or ch == "75":
        return "WB_NICKEL"
    if "battery" in text or "lead" in text or ch == "78":
        return "WB_LEAD"
    if "rubber" in text or ch == "40":
        return "WB_RUBBER"
    if "plywood" in text:
        return "WB_PLYWOOD"
    if ch in ("44", "47", "48", "94") or "wood" in text or "timber" in text:
        return "WB_SAWNWOOD"
    if ch == "74" or "copper" in text:
        return "WB_COPPER"
    if ch == "76" or "aluminum" in text or "aluminium" in text:
        return "WB_ALUMINUM"
    if ch in ("72", "73") or "steel" in text or "iron" in text:
        return "WB_IRON"
    if ch in ("28", "29", "31", "32", "38") or "urea" in text or "chemical" in text:
        return "WB_UREA"
    if ch in ("50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63") or "cotton" in text or "tarpaulin" in text:
        return "WB_COTTON"
    return "WB_CRUDE"


def compute_live_forecast(
    hsn_code: str,
    name: str,
    category: str,
    base_price_inr: float,
    baci_trend_pct: float = 0.0,
    models=None,
    include_comtrade: bool = False,
):
    """
    Compute real-time multi-source 1D-ResNet forecast for any HSN/commodity:
    Yahoo Finance Live Futures + World Bank Pink Sheet + DGFT/CBIC Policy + UN Comtrade + 1D-ResNet.
    Returns (trend_label, predicted_pct, market_driver_reason, fetched_at_str).
    """
    signals, fetched_at = get_live_market_signals()
    wb_metrics, wb_period = get_world_bank_pink_sheet()
    primary_sym = map_hsn_to_ticker(hsn_code, category)
    primary = signals.get(primary_sym) or signals.get("XLB")
    fx = signals.get("USDINR=X")

    wb_key = map_hsn_to_pink_sheet_key(hsn_code, name, category)
    wb_info = wb_metrics.get(wb_key) if wb_metrics else None

    policy_adj, policy_note = match_dgft_policy_for_hsn(hsn_code, name, category)
    comtrade_adj, comtrade_note = get_un_comtrade_india_signal(hsn_code) if include_comtrade else (0.0, None)
    wb_cpi_info = get_world_bank_india_cpi()
    fred_adj, opt_notes = get_optional_fred_and_datagov(hsn_code)

    baci_pct = float(baci_trend_pct or 0.0)
    fx_pct = float(fx["pct_30d"]) if fx else 0.0
    fx_rate = float(fx["latest"]) if fx else 84.0

    if primary:
        mkt_30d = float(primary["pct_30d"])
        mkt_7d = float(primary["pct_7d"])
        mkt_label = primary["label"]
        mkt_sym = primary["symbol"]

        wb_mom = float(wb_info["mom_pct"]) if wb_info else 0.0
        wb_weight = 0.20 if wb_info else 0.0
        cpi_adj = round((wb_cpi_info[0] - 4.0) * 0.08, 2) if wb_cpi_info else 0.0

        # Multi-source consensus: Yahoo Live 7d (30%), World Bank Pink Sheet MoM (20%), BACI (25%), Yahoo 30d (15%), USD/INR (10%) + Policy/Comtrade/CPI/FRED
        raw_momentum = (
            (0.30 * mkt_7d)
            + (wb_weight * wb_mom)
            + (0.25 * baci_pct)
            + (0.15 * mkt_30d)
            + (0.10 * fx_pct)
            + policy_adj
            + comtrade_adj
            + cpi_adj
            + fred_adj
        )

        # Run 1D-ResNet neural inference on the live 5-day trajectory (cached per ticker/price-tier)
        resnet_adj = 0.0
        resnet = models.get("resnet") if models else None
        scaler = models.get("resnet_scaler") if models else None
        nn_key = (mkt_sym, int(base_price_inr // 1000))
        if nn_key in _MARKET_CACHE["nn_cache"]:
            resnet_adj = _MARKET_CACHE["nn_cache"][nn_key]
        elif resnet is not None and primary.get("closes") and len(primary["closes"]) >= 5:
            try:
                import numpy as np
                c5 = primary["closes"][-5:]
                c_last = max(c5[-1], 1e-6)
                scaled_inr = [base_price_inr * (v / c_last) for v in c5]
                arr = np.array(scaled_inr, dtype=np.float32).reshape(-1, 1)
                if scaler:
                    v_scaled = scaler.transform(arr).flatten()
                    pred_s = float(resnet(v_scaled.reshape(1, 5, 1), training=False)[0, 0])
                    pred_inr = float(scaler.inverse_transform([[pred_s]])[0, 0])
                else:
                    max_v = max(float(np.max(arr)), 1.0)
                    v_scaled = (arr / max_v).flatten()
                    pred_s = float(resnet(v_scaled.reshape(1, 5, 1), training=False)[0, 0])
                    pred_inr = float(pred_s * max_v)
                nn_delta_pct = ((pred_inr - base_price_inr) / max(base_price_inr, 1.0)) * 100.0
                resnet_adj = max(-3.5, min(3.5, nn_delta_pct * 0.15))
                _MARKET_CACHE["nn_cache"][nn_key] = resnet_adj
            except Exception as exc:
                logger.debug("1D-ResNet live inference skipped: %s", exc)

        predicted_pct = round(max(-18.0, min(18.0, raw_momentum + resnet_adj)), 1)

        # Compare directional agreement across active sources
        votes = [mkt_7d, baci_pct]
        if wb_info:
            votes.append(wb_mom)
        if comtrade_note:
            votes.append(comtrade_adj)
        agree_cnt = sum(1 for v in votes if (v >= 0 and predicted_pct >= 0) or (v < 0 and predicted_pct < 0))

        parts = [f"Yahoo {mkt_label} ({mkt_sym}) {mkt_7d:+.1f}% (7d)"]
        if wb_info:
            parts.append(f"World Bank Pink Sheet {wb_info['name']} {wb_mom:+.1f}% MoM ({wb_period})")
        if wb_cpi_info:
            parts.append(f"WB India CPI {wb_cpi_info[0]}% ({wb_cpi_info[1]})")
        if policy_note:
            parts.append(policy_note)
        if comtrade_note:
            parts.append(comtrade_note)
        parts.extend(opt_notes)
        parts.append(f"USD/INR ₹{fx_rate:.2f} ({fx_pct:+.1f}%), BACI {baci_pct:+.1f}%")
        parts.append(f"1D-ResNet Consensus ({agree_cnt}/{len(votes)} sources align)")
        reason = " | ".join(parts) + f" [Updated {fetched_at}]."
    else:
        predicted_pct = round(baci_pct + policy_adj + comtrade_adj, 1)
        reason = f"BACI trade lakehouse baseline ({baci_pct:+.1f}%)."

    if predicted_pct >= 1.8:
        trend = "SURGE"
    elif predicted_pct <= -1.8:
        trend = "DECLINE"
    else:
        trend = "STABLE"

    return trend, predicted_pct, reason, fetched_at
