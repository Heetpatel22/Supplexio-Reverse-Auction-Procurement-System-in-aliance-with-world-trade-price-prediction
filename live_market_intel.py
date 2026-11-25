"""
live_market_intel.py — Real-Time World Market Feed & 1D-ResNet Forecasting Engine.

Fetches live commodity futures & FX rates (Yahoo Finance JSON API, 5-min TTL cache)
and combines them with BACI structural trade baselines + 1D-ResNet neural inference
to produce dynamic, time-varying price surge/decline forecasts with explicit drivers.
"""

import json
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

_MARKET_CACHE = {
    "timestamp": 0.0,
    "fetched_at_str": "",
    "signals": {},
    "nn_cache": {}
}
CACHE_TTL_SECONDS = 300  # Refresh live global market feeds every 5 minutes

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


def _fetch_single_ticker(symbol: str):
    """Fetch 1-month daily closes for a market ticker."""
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


def compute_live_forecast(hsn_code: str, name: str, category: str, base_price_inr: float, baci_trend_pct: float = 0.0, models=None):
    """
    Compute real-time 1D-ResNet + Live World Market forecast for any HSN/commodity.
    Returns (trend_label, predicted_pct, market_driver_reason, fetched_at_str).
    """
    signals, fetched_at = get_live_market_signals()
    primary_sym = map_hsn_to_ticker(hsn_code, category)
    primary = signals.get(primary_sym) or signals.get("XLB")
    fx = signals.get("USDINR=X")

    baci_pct = float(baci_trend_pct or 0.0)
    fx_pct = float(fx["pct_30d"]) if fx else 0.0
    fx_rate = float(fx["latest"]) if fx else 84.0

    if primary:
        mkt_30d = float(primary["pct_30d"])
        mkt_7d = float(primary["pct_7d"])
        mkt_label = primary["label"]
        mkt_sym = primary["symbol"]

        # Blend live 7d market momentum (40%), BACI structural trade trend (35%), 30d market trend (15%), and USD/INR FX (10%)
        raw_momentum = (0.40 * mkt_7d) + (0.35 * baci_pct) + (0.15 * mkt_30d) + (0.10 * fx_pct)

        # Run 1D-ResNet neural inference on the live 5-day price trajectory (cached per ticker/price-tier for 5 mins)
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
        reason = (
            f"Live {mkt_label} ({mkt_sym}) {mkt_30d:+.1f}% (30d) & {mkt_7d:+.1f}% (7d), "
            f"USD/INR ₹{fx_rate:.2f} ({fx_pct:+.1f}%), BACI baseline {baci_pct:+.1f}% "
            f"[Updated {fetched_at}]."
        )
    else:
        predicted_pct = round(baci_pct, 1)
        reason = f"BACI trade lakehouse baseline ({baci_pct:+.1f}%). Live market feed unavailable."

    if predicted_pct >= 1.8:
        trend = "SURGE"
    elif predicted_pct <= -1.8:
        trend = "DECLINE"
    else:
        trend = "STABLE"

    return trend, predicted_pct, reason, fetched_at

