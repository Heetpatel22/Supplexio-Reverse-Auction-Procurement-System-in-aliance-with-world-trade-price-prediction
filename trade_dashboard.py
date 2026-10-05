"""
trade_dashboard.py  –  Paint & Chemicals Trade Intelligence Dashboard
Source: ITC TradeMap  |  40 products  |  110+ countries  |  Jun 2024 – Jan 2026
Run:  streamlit run trade_dashboard.py
"""

import os, warnings
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
from trend_analysis import TrendAnalyzer
from data_processor import TradeDataProcessor

warnings.filterwarnings("ignore")

# ── Page config ───────────────────────────────────────────────────────
st.set_page_config(
    page_title="Paint & Chemicals Trade Intelligence",
    layout="wide", page_icon="🎨",
    initial_sidebar_state="expanded"
)

st.markdown("""
<style>
  .main-title  { font-size:2.2em; font-weight:700; color:#1a5276; text-align:center; margin-bottom:18px; }
  .sec-hdr     { font-size:1.25em; font-weight:700; color:#1a5276;
                 border-bottom:2px solid #1a5276; padding-bottom:6px; margin:22px 0 12px; }
  .kpi-note    { font-size:.78em; color:#999; margin-top:-10px; }
  .tag-imp     { background:#d6eaf8; color:#154360; border-radius:4px; padding:2px 8px; font-size:.8em; }
  .tag-exp     { background:#d5f5e3; color:#145a32; border-radius:4px; padding:2px 8px; font-size:.8em; }
</style>
""", unsafe_allow_html=True)

# ── Load data (cached) ────────────────────────────────────────────────
@st.cache_resource
def load_processor():
    p = TradeDataProcessor()
    p.load_all_data()
    return p

proc        = load_processor()
hsn_map     = proc.get_hsn_product_mapping()
stats       = proc.get_statistics_summary()
tm          = proc._ensure_trademap()
global_idx  = proc.load_global_product_index()
global_stats = proc.get_global_trade_stats()
global_world = proc.load_global_trade_world_year()
global_hsn_map = dict(zip(global_idx['hsn_code'], global_idx['product_name'])) if not global_idx.empty else {}

sorted_hsn  = sorted(hsn_map.keys())
HSN_FMT     = lambda x: f"{x} — {hsn_map.get(x, x)}"
GLOBAL_HSN_FMT = lambda x: f"{x} — {global_hsn_map.get(x, x)}"

IMP_COL     = '#2980b9'
EXP_COL     = '#27ae60'
BAL_POS     = '#1abc9c'
BAL_NEG     = '#e74c3c'


def is_annual_series(df: pd.DataFrame) -> bool:
    if df is None or df.empty or "date" not in df.columns:
        return False
    if "year" in df.columns and df["year"].nunique() == len(df):
        return True
    if "month" in df.columns and df["month"].nunique() == 1 and int(df["month"].iloc[0]) == 1:
        return True
    return False

# ── Sidebar ───────────────────────────────────────────────────────────
st.sidebar.markdown("# 🎨 Trade Intelligence")
st.sidebar.markdown("**Global Trade + Paint Intelligence**")
st.sidebar.markdown("*Spark processing + Hadoop warehouse storage*")
st.sidebar.markdown("---")

hsn_search_query = st.sidebar.text_input("🔎 Search HSN / Product", placeholder="e.g. 320611 or titanium")

page = st.sidebar.radio("Navigate", [
    "📊 Dashboard Overview",
    "🔎 Global Trade Search",
    "📤 Export Analysis",
    "📥 Import Analysis",
    "🔄 Trade Balance",
    "📈 Monthly Trends",
    "🔮 Forecast",
    "💰 Pricing",
    "🏢 Companies",
    "📋 Data Export",
])

st.sidebar.markdown("---")
st.sidebar.markdown("### 📌 Global Summary")
st.sidebar.metric("Products (HSN)", global_stats['total_products'])
st.sidebar.metric("Exporter Countries", global_stats['exporter_countries'])
st.sidebar.metric("Importer Countries", global_stats['importer_countries'])
st.sidebar.metric(
    f"Trade Value ({global_stats['latest_year']})" if global_stats['latest_year'] else "Trade Value",
    f"${global_stats['latest_total_value_usd']/1e12:.2f}T"
)
st.sidebar.markdown('<p class="kpi-note">Actual: 2017–2021 | Estimated: 2022–2025 | Projected: 2026</p>', unsafe_allow_html=True)

# ═══════════════════════════════════════════════════════════════════════
# PAGE 1 — DASHBOARD OVERVIEW
# ═══════════════════════════════════════════════════════════════════════
if page == "📊 Dashboard Overview":
    st.markdown('<div class="main-title">🌍 Global Trade Intelligence Dashboard</div>', unsafe_allow_html=True)
    st.markdown("All-products world trade warehouse built from the yearly CSVs using Spark processing and Hadoop-style storage, plus the original paint and chemicals TradeMap modules.")

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Products Tracked", global_stats['total_products'])
    c2.metric("Exporter Countries", global_stats['exporter_countries'])
    c3.metric("Importer Countries", global_stats['importer_countries'])
    c4.metric(
        f"Latest Trade Value ({global_stats['latest_year']})" if global_stats['latest_year'] else "Latest Trade Value",
        f"${global_stats['latest_total_value_usd']/1e12:.2f}T"
    )

    st.markdown("---")

    st.markdown('<div class="sec-hdr">🔎 Quick Product Search</div>', unsafe_allow_html=True)
    overview_matches = proc.search_global_products(hsn_search_query, limit=100)
    if overview_matches.empty:
        overview_matches = proc.search_global_products(limit=100)
    selected_global_hsn = None
    if not overview_matches.empty:
        selected_global_hsn = st.selectbox(
            "Search and select a product",
            overview_matches["hsn_code"].tolist(),
            format_func=GLOBAL_HSN_FMT,
            index=0,
        )
    else:
        st.info("No HSN/product matched the current search.")
    if selected_global_hsn:
        trend = proc.get_global_product_trend(selected_global_hsn)
        if not trend.empty:
            latest_row = trend.sort_values("year").iloc[-1]
            actual_row = trend[~trend["is_projection"]].sort_values("year").iloc[-1] if not trend[~trend["is_projection"]].empty else latest_row
            c1, c2, c3 = st.columns(3)
            c1.metric("Selected HSN", selected_global_hsn)
            c2.metric(f"Actual Trade ({int(actual_row['year'])})", f"${actual_row['total_value_usd']/1e9:.2f}B")
            c3.metric(f"Projected Trade ({int(latest_row['year'])})", f"${latest_row['total_value_usd']/1e9:.2f}B")

    st.markdown("---")

    st.markdown('<div class="sec-hdr">📅 Global Annual Trade Trend</div>', unsafe_allow_html=True)
    if not global_world.empty:
        world_plot = global_world.sort_values("year").copy()
        world_plot["Series"] = np.where(
            world_plot["is_projection"], "Projected",
            np.where(world_plot["is_estimated"], "Estimated", "Actual")
        )
        fig = px.bar(
            world_plot, x="year", y="total_value_usd", color="Series",
            barmode="group",
            color_discrete_map={"Actual": "#1a5276", "Estimated": "#f39c12", "Projected": "#48a868"},
            title="Global Trade Value by Year",
            labels={"total_value_usd": "Trade Value (USD)", "year": "Year"}
        )
        fig.update_layout(height=420)
        fig.update_yaxes(tickformat='$,.0f')
        st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    st.markdown('<div class="sec-hdr">🏆 Top Products In Latest Year</div>', unsafe_allow_html=True)
    product_year = proc.load_global_trade_product_year()
    latest_year = global_stats['latest_year']
    latest_products = product_year[product_year['year'] == latest_year].copy() if not product_year.empty and latest_year else pd.DataFrame()

    c1, c2 = st.columns(2)
    with c1:
        if not latest_products.empty:
            top_value = latest_products.nlargest(15, 'total_value_usd').sort_values('total_value_usd')
            fig = px.bar(top_value, x='total_value_usd', y='product_name', orientation='h',
                         title=f"Top 15 Products by Trade Value ({latest_year})",
                         color='total_value_usd', color_continuous_scale='Greens',
                         labels={'total_value_usd': 'Trade Value (USD)', 'product_name': ''})
            fig.update_layout(height=480, showlegend=False)
            fig.update_xaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

    with c2:
        if not latest_products.empty:
            top_qty = latest_products.nlargest(15, 'total_quantity_mt').sort_values('total_quantity_mt')
            fig = px.bar(top_qty, x='total_quantity_mt', y='product_name', orientation='h',
                         title=f"Top 15 Products by Quantity ({latest_year})",
                         color='total_quantity_mt', color_continuous_scale='Blues',
                         labels={'total_quantity_mt': 'Quantity (MT)', 'product_name': ''})
            fig.update_layout(height=480, showlegend=False)
            st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # ── Global monthly trends: export vs import ──
    st.markdown('<div class="sec-hdr">📅 Monthly Global Trade Trend</div>', unsafe_allow_html=True)

    imp_m = tm['import_monthly']
    exp_m = tm['export_monthly']

    fig = go.Figure()
    if not exp_m.empty:
        ge = exp_m.groupby('date')['export_value_usd'].sum().reset_index().sort_values('date')
        fig.add_trace(go.Scatter(x=ge['date'], y=ge['export_value_usd'],
                                  name='Global Exports', fill='tozeroy',
                                  line=dict(color=EXP_COL, width=2), fillcolor='rgba(39,174,96,.15)'))
    if not imp_m.empty:
        gi = imp_m.groupby('date')['import_value_usd'].sum().reset_index().sort_values('date')
        fig.add_trace(go.Scatter(x=gi['date'], y=gi['import_value_usd'],
                                  name='Global Imports', fill='tozeroy',
                                  line=dict(color=IMP_COL, width=2), fillcolor='rgba(41,128,185,.15)'))
    fig.update_layout(title="All 40 Products — Monthly Export & Import Value",
                      height=380, xaxis_title='Month', yaxis_title='Value (USD)',
                      legend=dict(orientation='h', yanchor='bottom', y=1.02))
    fig.update_yaxes(tickformat='$,.0f')
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # ── Top countries — export & import shown side-by-side, each country counted once ──
    st.markdown('<div class="sec-hdr">🌍 Top Countries — All Products Combined</div>', unsafe_allow_html=True)

    exp_ct = tm['export_country_totals']
    imp_ct = tm['import_country_totals']

    # Aggregate across all HSN codes per country (one row per country)
    exp_by_country = (
        exp_ct.groupby('country')['total_export_value_usd'].sum()
        if not exp_ct.empty else pd.Series(dtype=float)
    )
    imp_by_country = (
        imp_ct.groupby('country')['total_import_value_usd'].sum()
        if not imp_ct.empty else pd.Series(dtype=float)
    )

    # Combined grouped bar chart (export + import per country)
    all_countries = sorted(set(exp_by_country.index) | set(imp_by_country.index))
    combined_df = pd.DataFrame({
        'country': all_countries,
        'Export Value (USD)': [exp_by_country.get(c, 0) for c in all_countries],
        'Import Value (USD)': [imp_by_country.get(c, 0) for c in all_countries],
    })
    combined_df['total'] = combined_df['Export Value (USD)'] + combined_df['Import Value (USD)']
    top15_combined = combined_df.nlargest(15, 'total').sort_values('total')

    melted = top15_combined.melt(
        id_vars='country', value_vars=['Export Value (USD)', 'Import Value (USD)'],
        var_name='Trade Type', value_name='Value (USD)'
    )
    fig = px.bar(
        melted, x='Value (USD)', y='country', color='Trade Type', orientation='h',
        title="Top 15 Countries — Export & Import (All Products)",
        color_discrete_map={'Export Value (USD)': EXP_COL, 'Import Value (USD)': IMP_COL},
        barmode='group',
        labels={'Value (USD)': 'Trade Value (USD)', 'country': ''}
    )
    fig.update_layout(height=480, legend=dict(orientation='h', yanchor='bottom', y=1.02))
    fig.update_xaxes(tickformat='$,.0f')
    st.plotly_chart(fig, use_container_width=True)

    # Individual top-15 for each direction (kept for detail, each country shown once)
    c1, c2 = st.columns(2)
    with c1:
        if not exp_by_country.empty:
            top_ec = exp_by_country.nlargest(15).reset_index().sort_values('total_export_value_usd')
            fig = px.bar(top_ec, x='total_export_value_usd', y='country', orientation='h',
                         title="Top 15 Exporting Countries",
                         color='total_export_value_usd', color_continuous_scale='Greens',
                         labels={'total_export_value_usd': 'Export Value (USD)', 'country': ''})
            fig.update_layout(height=420, showlegend=False)
            fig.update_xaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

    with c2:
        if not imp_by_country.empty:
            top_ic = imp_by_country.nlargest(15).reset_index().sort_values('total_import_value_usd')
            fig = px.bar(top_ic, x='total_import_value_usd', y='country', orientation='h',
                         title="Top 15 Importing Countries",
                         color='total_import_value_usd', color_continuous_scale='Blues',
                         labels={'total_import_value_usd': 'Import Value (USD)', 'country': ''})
            fig.update_layout(height=420, showlegend=False)
            fig.update_xaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

    st.markdown('<div class="sec-hdr">🧪 Paint & Chemicals Module Snapshot</div>', unsafe_allow_html=True)
    st.info(
        f"Your original TradeMap module is still available below in the detailed pages: "
        f"{stats['total_hsn_codes']} paint/chemical HSNs, {stats['export_countries']} export countries, "
        f"{stats['import_countries']} import countries."
    )


elif page == "🔎 Global Trade Search":
    st.markdown('<div class="main-title">🔎 Global Trade Search</div>', unsafe_allow_html=True)
    st.markdown("Search any HSN code or product from the 2017–2021 yearly CSV warehouse, with projections extended through 2025.")

    matches = proc.search_global_products(hsn_search_query, limit=200)
    if matches.empty:
        matches = proc.search_global_products(limit=200)
    if matches.empty:
        st.warning("Global trade warehouse data is not available.")
    else:
        selected_hsn = st.selectbox("Select HSN / Product", matches["hsn_code"].tolist(), format_func=GLOBAL_HSN_FMT)
        trend = proc.get_global_product_trend(selected_hsn)
        exporters = proc.get_global_exporters_by_hsn(selected_hsn, top_n=15)
        importers = proc.get_global_importers_by_hsn(selected_hsn, top_n=15)

        if not trend.empty:
            actual = trend[~trend["is_projection"]].sort_values("year")
            estimated = trend[trend["is_estimated"]].sort_values("year") if "is_estimated" in trend.columns else pd.DataFrame()
            projected = trend[trend["is_projection"]].sort_values("year")
            latest_actual = actual[actual["year"] <= 2021].iloc[-1] if not actual[actual["year"] <= 2021].empty else trend.iloc[0]
            latest_projected = projected.iloc[-1] if not projected.empty else trend.iloc[-1]
            latest_estimated = estimated.iloc[-1] if not estimated.empty else None
            base_actual = actual[actual["year"] <= 2021].iloc[0] if not actual[actual["year"] <= 2021].empty else latest_actual
            growth_pct = (
                ((latest_projected["total_value_usd"] - base_actual["total_value_usd"]) / base_actual["total_value_usd"]) * 100
                if base_actual["total_value_usd"] else 0
            )

            c1, c2, c3, c4 = st.columns(4)
            c1.metric("HSN", selected_hsn)
            c2.metric(f"Actual Value ({int(latest_actual['year'])})", f"${latest_actual['total_value_usd']/1e9:.2f}B")
            c3.metric(f"Estimated Value (2025)" if latest_estimated is not None else f"Projected Value ({int(latest_projected['year'])})", f"${(latest_estimated['total_value_usd'] if latest_estimated is not None else latest_projected['total_value_usd'])/1e9:.2f}B")
            c4.metric(f"Projected Value ({int(latest_projected['year'])})", f"${latest_projected['total_value_usd']/1e9:.2f}B")

            fig = go.Figure()
            actual_hist = trend[trend["year"] <= 2021].sort_values("year")
            if not actual_hist.empty:
                fig.add_trace(go.Bar(x=actual_hist["year"], y=actual_hist["total_value_usd"], name="Actual", marker_color="#1a5276"))
            if not estimated.empty:
                fig.add_trace(go.Bar(x=estimated["year"], y=estimated["total_value_usd"], name="Estimated", marker_color="#f39c12"))
            if not projected.empty:
                fig.add_trace(go.Bar(x=projected["year"], y=projected["total_value_usd"], name="Projected", marker_color="#48a868"))
            fig.update_layout(
                title=f"Annual Trade Value — {GLOBAL_HSN_FMT(selected_hsn)}",
                xaxis_title="Year",
                yaxis_title="Trade Value (USD)",
                height=420,
                barmode="group",
            )
            fig.update_yaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

            c1, c2 = st.columns(2)
            with c1:
                if not exporters.empty:
                    fig = px.bar(
                        exporters.sort_values("total_value_usd").tail(15),
                        x="total_value_usd", y="exporter_country", orientation="h",
                        title="Top Exporter Countries (2017–2021 actual)",
                        color="total_value_usd", color_continuous_scale="Greens",
                        labels={"total_value_usd": "Trade Value (USD)", "exporter_country": ""}
                    )
                    fig.update_layout(height=500, showlegend=False)
                    fig.update_xaxes(tickformat='$,.0f')
                    st.plotly_chart(fig, use_container_width=True)
            with c2:
                if not importers.empty:
                    fig = px.bar(
                        importers.sort_values("total_value_usd").tail(15),
                        x="total_value_usd", y="importer_country", orientation="h",
                        title="Top Importer Countries (2017–2021 actual)",
                        color="total_value_usd", color_continuous_scale="Blues",
                        labels={"total_value_usd": "Trade Value (USD)", "importer_country": ""}
                    )
                    fig.update_layout(height=500, showlegend=False)
                    fig.update_xaxes(tickformat='$,.0f')
                    st.plotly_chart(fig, use_container_width=True)

            with st.expander("📄 Product Year Table", expanded=False):
                cols = ["year", "total_value_usd", "total_quantity_mt", "exporter_countries", "importer_countries", "is_estimated", "is_projection"]
                disp = trend[[c for c in cols if c in trend.columns]].copy()
                disp.columns = ["Year", "Trade Value (USD)", "Quantity (MT)", "Exporter Countries", "Importer Countries", "Estimated", "Projected"][:len(disp.columns)]
                st.dataframe(disp, use_container_width=True)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 2 — EXPORT ANALYSIS
# ═══════════════════════════════════════════════════════════════════════
elif page == "📤 Export Analysis":
    st.markdown('<div class="main-title">📤 Export Analysis by Product</div>', unsafe_allow_html=True)
    st.markdown("Which countries export each product, and how much? Uses TradeMap when available and falls back to the CSV-based global trade warehouse.")

    selected_hsn  = st.selectbox("Select Product", sorted_hsn, format_func=HSN_FMT)
    product_name  = hsn_map.get(selected_hsn, selected_hsn)
    top_exp_df    = proc.get_top_exporting_countries(selected_hsn, top_n=20)

    if not top_exp_df.empty and 'total_export_value_usd' in top_exp_df.columns:
        c1, c2, c3 = st.columns(3)
        c1.metric("Top Exporter",     top_exp_df.iloc[0]['country'])
        c2.metric("Total Export Value", f"${top_exp_df['total_export_value_usd'].sum()/1e6:.1f}M USD")
        c3.metric("Countries Exporting", len(top_exp_df))

        st.markdown("---")
        c1, c2 = st.columns(2)

        with c1:
            st.markdown('<div class="sec-hdr">📤 Top Exporting Countries</div>', unsafe_allow_html=True)
            plot = top_exp_df.sort_values('total_export_value_usd').tail(15)
            fig  = px.bar(plot, x='total_export_value_usd', y='country', orientation='h',
                          title=f"Top 15 Exporters — {product_name}",
                          color='total_export_value_usd', color_continuous_scale='Greens',
                          labels={'total_export_value_usd': 'Export Value (USD)', 'country': ''})
            fig.update_layout(height=480, showlegend=False)
            fig.update_xaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

        with c2:
            st.markdown('<div class="sec-hdr">🌍 World Map</div>', unsafe_allow_html=True)
            all_exp = proc.get_export_countries_by_hsn(selected_hsn)
            if not all_exp.empty:
                fig = px.choropleth(all_exp, locations='country', locationmode='country names',
                                    color='total_export_value_usd', color_continuous_scale='Greens',
                                    title=f"Export Value by Country — {product_name}",
                                    labels={'total_export_value_usd': 'Export Value (USD)'})
                fig.update_layout(height=480)
                st.plotly_chart(fig, use_container_width=True)

        # Trend for top exporters
        top5 = top_exp_df.head(5)['country'].tolist()
        exp_m = proc.get_monthly_export_data(selected_hsn)
        exp_m5 = exp_m[exp_m['country'].isin(top5)] if not exp_m.empty else pd.DataFrame()
        if not exp_m5.empty:
            trend_title = "Annual Export Trend" if is_annual_series(exp_m5) else "Monthly Export Trend"
            st.markdown(f'<div class="sec-hdr">📈 {trend_title} — Top 5 Countries</div>', unsafe_allow_html=True)
            fig = px.line(exp_m5.sort_values('date'), x='date', y='export_value_usd',
                          color='country', markers=True,
                          title=f"{trend_title} — Top 5 Countries for {product_name}",
                          labels={'export_value_usd': 'Export Value (USD)', 'date': 'Period'})
            fig.update_layout(height=400)
            fig.update_yaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

        with st.expander("📄 Full Export Data Table"):
            disp = top_exp_df[['country','total_export_value_usd','avg_monthly_value','num_months']].copy()
            disp.columns = ['Country','Total Export Value (USD)','Avg Monthly (USD)','Months']
            disp['Total Export Value (USD)'] = disp['Total Export Value (USD)'].apply(lambda x: f"${x:,.0f}")
            disp['Avg Monthly (USD)']        = disp['Avg Monthly (USD)'].apply(lambda x: f"${x:,.0f}")
            st.dataframe(disp, use_container_width=True)
    else:
        st.info(f"No export data for {product_name}")


# ═══════════════════════════════════════════════════════════════════════
# PAGE 3 — IMPORT ANALYSIS
# ═══════════════════════════════════════════════════════════════════════
elif page == "📥 Import Analysis":
    st.markdown('<div class="main-title">📥 Import Analysis by Product</div>', unsafe_allow_html=True)
    st.markdown("Which countries import each product, and how much? Uses TradeMap first and falls back to importer data from the yearly CSV warehouse.")

    selected_hsn = st.selectbox("Select Product", sorted_hsn, format_func=HSN_FMT)
    product_name = hsn_map.get(selected_hsn, selected_hsn)
    top_imp_df   = proc.get_top_importing_countries(selected_hsn, top_n=20)

    if not top_imp_df.empty and 'total_import_value_usd' in top_imp_df.columns:
        c1, c2, c3 = st.columns(3)
        c1.metric("Top Importer",      top_imp_df.iloc[0]['country'])
        c2.metric("Total Import Value", f"${top_imp_df['total_import_value_usd'].sum()/1e6:.1f}M USD")
        c3.metric("Countries Importing", len(top_imp_df))

        st.markdown("---")
        c1, c2 = st.columns(2)

        with c1:
            st.markdown('<div class="sec-hdr">📥 Top Importing Countries</div>', unsafe_allow_html=True)
            plot = top_imp_df.sort_values('total_import_value_usd').tail(15)
            fig  = px.bar(plot, x='total_import_value_usd', y='country', orientation='h',
                          title=f"Top 15 Importers — {product_name}",
                          color='total_import_value_usd', color_continuous_scale='Blues',
                          labels={'total_import_value_usd': 'Import Value (USD)', 'country': ''})
            fig.update_layout(height=480, showlegend=False)
            fig.update_xaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

        with c2:
            st.markdown('<div class="sec-hdr">🌍 World Map</div>', unsafe_allow_html=True)
            all_imp = proc.get_import_countries_by_hsn(selected_hsn)
            if not all_imp.empty:
                fig = px.choropleth(all_imp, locations='country', locationmode='country names',
                                    color='total_import_value_usd', color_continuous_scale='Blues',
                                    title=f"Import Value by Country — {product_name}",
                                    labels={'total_import_value_usd': 'Import Value (USD)'})
                fig.update_layout(height=480)
                st.plotly_chart(fig, use_container_width=True)

        top5   = top_imp_df.head(5)['country'].tolist()
        imp_m  = proc.get_monthly_import_data(selected_hsn)
        imp_m5 = imp_m[imp_m['country'].isin(top5)] if not imp_m.empty else pd.DataFrame()
        if not imp_m5.empty:
            trend_title = "Annual Import Trend" if is_annual_series(imp_m5) else "Monthly Import Trend"
            st.markdown(f'<div class="sec-hdr">📈 {trend_title} — Top 5 Countries</div>', unsafe_allow_html=True)
            fig = px.line(imp_m5.sort_values('date'), x='date', y='import_value_usd',
                          color='country', markers=True,
                          title=f"{trend_title} — Top 5 Countries for {product_name}",
                          labels={'import_value_usd': 'Import Value (USD)', 'date': 'Period'})
            fig.update_layout(height=400)
            fig.update_yaxes(tickformat='$,.0f')
            st.plotly_chart(fig, use_container_width=True)

        with st.expander("📄 Full Import Data Table"):
            disp = top_imp_df[['country','total_import_value_usd','avg_monthly_value','num_months']].copy()
            disp.columns = ['Country','Total Import Value (USD)','Avg Monthly (USD)','Months']
            disp['Total Import Value (USD)'] = disp['Total Import Value (USD)'].apply(lambda x: f"${x:,.0f}")
            disp['Avg Monthly (USD)']        = disp['Avg Monthly (USD)'].apply(lambda x: f"${x:,.0f}")
            st.dataframe(disp, use_container_width=True)
    else:
        st.info(f"No import data for {product_name}")


# ═══════════════════════════════════════════════════════════════════════
# PAGE 4 — TRADE BALANCE
# ═══════════════════════════════════════════════════════════════════════
elif page == "🔄 Trade Balance":
    st.markdown('<div class="main-title">🔄 Export vs Import Trade Balance</div>', unsafe_allow_html=True)
    st.markdown("Compare export and import volumes per country for any product, and identify net exporters vs net importers.")

    selected_hsn = st.selectbox("Select Product", sorted_hsn, format_func=HSN_FMT)
    product_name = hsn_map.get(selected_hsn, selected_hsn)

    bal = proc.get_trade_balance_by_country(selected_hsn)

    if bal.empty:
        st.info("No trade balance data available.")
    else:
        # KPIs
        net_exp = bal[bal['trade_balance'] > 0]
        net_imp = bal[bal['trade_balance'] < 0]
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Net Exporters",  len(net_exp))
        c2.metric("Net Importers",  len(net_imp))
        c3.metric("Largest Exporter", net_exp.iloc[0]['country'] if not net_exp.empty else '—')
        c4.metric("Largest Importer", net_imp.iloc[-1]['country'] if not net_imp.empty else '—')

        st.markdown("---")

        # Top 20 by absolute balance
        top_bal = pd.concat([bal.nlargest(10, 'trade_balance'), bal.nsmallest(10, 'trade_balance')])
        top_bal = top_bal.drop_duplicates('country').sort_values('trade_balance')
        top_bal['color'] = top_bal['trade_balance'].apply(lambda x: BAL_POS if x > 0 else BAL_NEG)

        fig = go.Figure(go.Bar(
            x=top_bal['trade_balance'], y=top_bal['country'],
            orientation='h',
            marker_color=top_bal['color'],
            text=top_bal['trade_balance'].apply(lambda x: f"${x/1e6:+.0f}M"),
            textposition='outside'
        ))
        fig.update_layout(
            title=f"Trade Balance (Export − Import) — {product_name}",
            xaxis_title='Trade Balance (USD)  ← Net Importer | Net Exporter →',
            height=560, margin=dict(l=160)
        )
        fig.update_xaxes(tickformat='$,.0f')
        st.plotly_chart(fig, use_container_width=True)

        # Scatter: export vs import
        st.markdown('<div class="sec-hdr">🔵 Export vs Import Scatter</div>', unsafe_allow_html=True)
        scatter = bal[(bal['total_export_value_usd'] > 0) | (bal['total_import_value_usd'] > 0)].copy()
        scatter['abs_balance'] = scatter['trade_balance'].abs()
        fig2 = px.scatter(scatter, x='total_export_value_usd', y='total_import_value_usd',
                          color='net_status', hover_name='country',
                          size='abs_balance', size_max=45,
                          color_discrete_map={'Net Exporter': EXP_COL, 'Net Importer': IMP_COL},
                          title=f"Export vs Import by Country — {product_name}",
                          labels={'total_export_value_usd': 'Total Export Value (USD)',
                                  'total_import_value_usd': 'Total Import Value (USD)',
                                  'net_status': 'Status'})
        # Add 45° line
        maxv = max(scatter['total_export_value_usd'].max(), scatter['total_import_value_usd'].max())
        fig2.add_shape(type='line', x0=0, y0=0, x1=maxv, y1=maxv,
                       line=dict(color='gray', dash='dash', width=1))
        fig2.update_layout(height=480)
        fig2.update_xaxes(tickformat='$,.0f')
        fig2.update_yaxes(tickformat='$,.0f')
        st.plotly_chart(fig2, use_container_width=True)

        with st.expander("📄 Full Trade Balance Table"):
            disp = bal[['country','total_export_value_usd','total_import_value_usd','trade_balance','net_status']].copy()
            disp.columns = ['Country','Total Exports (USD)','Total Imports (USD)','Trade Balance (USD)','Status']
            for col in ['Total Exports (USD)','Total Imports (USD)','Trade Balance (USD)']:
                disp[col] = disp[col].apply(lambda x: f"${x:+,.0f}")
            st.dataframe(disp, use_container_width=True)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 5 — MONTHLY TRENDS
# ═══════════════════════════════════════════════════════════════════════
elif page == "📈 Monthly Trends":
    st.markdown('<div class="main-title">📈 Monthly Trade Trends</div>', unsafe_allow_html=True)
    st.markdown("Explore trade trends for any product and country. When monthly TradeMap data is unavailable, this page falls back to annual CSV-based trade series.")

    c1, c2, c3 = st.columns(3)
    with c1:
        selected_hsn = st.selectbox("Product", sorted_hsn, format_func=HSN_FMT)
    product_name = hsn_map.get(selected_hsn, selected_hsn)

    exp_m_all = proc.get_monthly_export_data(selected_hsn)
    imp_m_all = proc.get_monthly_import_data(selected_hsn)
    annual_mode = is_annual_series(exp_m_all) or is_annual_series(imp_m_all)
    countries  = sorted(set(
        list(exp_m_all['country'].unique() if not exp_m_all.empty else []) +
        list(imp_m_all['country'].unique() if not imp_m_all.empty else [])
    ))
    with c2:
        sel_country = st.selectbox("Country Filter", ['All Countries'] + countries)
    with c3:
        view = st.radio("View", ["Export & Import", "Export only", "Import only", "Stacked Countries"], horizontal=True)

    # Filter
    if sel_country != 'All Countries':
        exp_plot = exp_m_all[exp_m_all['country'] == sel_country] if not exp_m_all.empty else pd.DataFrame()
        imp_plot = imp_m_all[imp_m_all['country'] == sel_country] if not imp_m_all.empty else pd.DataFrame()
    else:
        exp_plot = exp_m_all
        imp_plot = imp_m_all

    # Aggregate
    def _agg(df, vcol):
        if df.empty: return pd.DataFrame()
        return df.groupby(['date','year_month'])[vcol].sum().reset_index().sort_values('date')

    ge = _agg(exp_plot, 'export_value_usd')
    gi = _agg(imp_plot, 'import_value_usd')

    if view == "Stacked Countries":
        top10_e = exp_m_all.groupby('country')['export_value_usd'].sum().nlargest(10).index.tolist() if not exp_m_all.empty else []
        top10_i = imp_m_all.groupby('country')['import_value_usd'].sum().nlargest(10).index.tolist() if not imp_m_all.empty else []

        c1, c2 = st.columns(2)
        with c1:
            if top10_e:
                ef = exp_m_all[exp_m_all['country'].isin(top10_e)]
                fig = px.bar(ef.sort_values('date'), x='date', y='export_value_usd', color='country',
                             barmode='stack', title=f"Monthly Export by Country (Top 10) — {product_name}",
                             labels={'export_value_usd': 'Export Value (USD)', 'date': 'Month'})
                fig.update_layout(height=430); fig.update_yaxes(tickformat='$,.0f')
                st.plotly_chart(fig, use_container_width=True)
        with c2:
            if top10_i:
                imf = imp_m_all[imp_m_all['country'].isin(top10_i)]
                fig = px.bar(imf.sort_values('date'), x='date', y='import_value_usd', color='country',
                             barmode='stack', title=f"Monthly Import by Country (Top 10) — {product_name}",
                             labels={'import_value_usd': 'Import Value (USD)', 'date': 'Month'})
                fig.update_layout(height=430); fig.update_yaxes(tickformat='$,.0f')
                st.plotly_chart(fig, use_container_width=True)
    else:
        fig = go.Figure()
        if view in ("Export & Import", "Export only") and not ge.empty:
            fig.add_trace(go.Bar(x=ge['date'], y=ge['export_value_usd'], name='Exports',
                                  marker_color=EXP_COL, opacity=0.8))
            ma = ge['export_value_usd'].rolling(3, min_periods=1).mean()
            fig.add_trace(go.Scatter(x=ge['date'], y=ma, name='Export 3M MA',
                                      line=dict(color='darkgreen', width=2, dash='dot')))
        if view in ("Export & Import", "Import only") and not gi.empty:
            fig.add_trace(go.Bar(x=gi['date'], y=gi['import_value_usd'], name='Imports',
                                  marker_color=IMP_COL, opacity=0.8))
            ma = gi['import_value_usd'].rolling(3, min_periods=1).mean()
            fig.add_trace(go.Scatter(x=gi['date'], y=ma, name='Import 3M MA',
                                      line=dict(color='darkblue', width=2, dash='dot')))
        lbl = sel_country if sel_country != 'All Countries' else 'All Countries'
        fig.update_layout(title=f"{product_name} — {lbl}", height=430,
                          xaxis_title='Year' if annual_mode else 'Month', yaxis_title='Value (USD)',
                          barmode='group',
                          legend=dict(orientation='h', yanchor='bottom', y=1.02))
        fig.update_yaxes(tickformat='$,.0f')
        st.plotly_chart(fig, use_container_width=True)

    # KPIs row
    st.markdown("---")
    kc = st.columns(4)
    if not ge.empty:
        kc[0].metric("Latest Export",  f"${ge['export_value_usd'].iloc[-1]/1e6:.2f}M")
        kc[1].metric("Peak Export",    f"${ge['export_value_usd'].max()/1e6:.2f}M")
    if not gi.empty:
        kc[2].metric("Latest Import",  f"${gi['import_value_usd'].iloc[-1]/1e6:.2f}M")
        kc[3].metric("Peak Import",    f"${gi['import_value_usd'].max()/1e6:.2f}M")

    # YoY table
    st.markdown('<div class="sec-hdr">📅 Period Comparison</div>', unsafe_allow_html=True)
    tab_e, tab_i = st.tabs(["📤 Export", "📥 Import"])
    month_names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

    with tab_e:
        if not exp_m_all.empty:
            if annual_mode:
                piv = exp_m_all.groupby('year')['export_value_usd'].sum().reset_index().set_index('year')
            else:
                yoy = exp_m_all.groupby(['year','month'])['export_value_usd'].sum().reset_index()
                piv = yoy.pivot(index='month', columns='year', values='export_value_usd').fillna(0)
                piv.index = [month_names[i-1] for i in piv.index]
            st.dataframe(piv.style.format({c: '${:,.0f}' for c in piv.columns}).background_gradient(cmap='Greens'), use_container_width=True)

    with tab_i:
        if not imp_m_all.empty:
            if annual_mode:
                piv = imp_m_all.groupby('year')['import_value_usd'].sum().reset_index().set_index('year')
            else:
                yoy = imp_m_all.groupby(['year','month'])['import_value_usd'].sum().reset_index()
                piv = yoy.pivot(index='month', columns='year', values='import_value_usd').fillna(0)
                piv.index = [month_names[i-1] for i in piv.index]
            st.dataframe(piv.style.format({c: '${:,.0f}' for c in piv.columns}).background_gradient(cmap='Blues'), use_container_width=True)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 6 — FORECAST
# ═══════════════════════════════════════════════════════════════════════
elif page == "🔮 Forecast":
    st.markdown('<div class="main-title">🔮 Trade Forecast & Projections</div>', unsafe_allow_html=True)
    st.markdown("Forecasts use TradeMap monthly data when available and annual CSV-based trade series otherwise.")

    c1, c2, c3, c4 = st.columns(4)
    with c1: selected_hsn = st.selectbox("Product", sorted_hsn, format_func=HSN_FMT)
    exp_probe = proc.get_monthly_export_totals(selected_hsn)
    imp_probe = proc.get_monthly_import_totals(selected_hsn)
    annual_forecast_mode = is_annual_series(exp_probe) or is_annual_series(imp_probe)
    with c2: fwd_months   = st.slider("Years to forecast" if annual_forecast_mode else "Months to forecast", 1, 3 if annual_forecast_mode else 12, 1 if annual_forecast_mode else 6)
    with c3: method_lbl   = st.radio("Method", ["Linear", "Exponential", "Rolling Avg"], horizontal=True)
    with c4: trade_dir    = st.radio("Direction", ["Export", "Import", "Both"], horizontal=True)

    product_name = hsn_map.get(selected_hsn, selected_hsn)
    method_map   = {"Linear": "linear", "Exponential": "exponential", "Rolling Avg": "average"}
    method       = method_map[method_lbl]
    analyzer     = TrendAnalyzer()

    def _build_forecast_trace(hist_df, vcol, label, color, dash_color):
        if hist_df.empty: return []
        hist_df = hist_df.sort_values('date')
        vals    = hist_df[vcol].values
        fvals   = analyzer.simple_forecast(vals, periods=fwd_months, method=method)
        last_d  = hist_df['date'].max()
        f_dates = pd.date_range(start=last_d + (pd.DateOffset(years=1) if annual_forecast_mode else pd.DateOffset(months=1)), periods=fwd_months, freq='YS' if annual_forecast_mode else 'MS')
        traces  = [
            go.Scatter(x=hist_df['date'], y=vals, mode='lines+markers', name=f'{label} (Historical)',
                       line=dict(color=color, width=2.5)),
            go.Scatter(x=f_dates, y=fvals, mode='lines+markers', name=f'{label} (Forecast)',
                       line=dict(color=dash_color, width=2.5, dash='dash'), marker=dict(symbol='diamond', size=7)),
        ]
        std = np.std(np.diff(vals)) if len(vals) > 1 else 0
        traces.append(go.Scatter(
            x=list(f_dates)+list(f_dates)[::-1],
            y=list(np.array(fvals)+std)+list(np.array(fvals)-std)[::-1],
            fill='toself', fillcolor=f'rgba({",".join(str(int(c*255)) for c in px.colors.hex_to_rgb(dash_color))},.10)',
            line=dict(color='rgba(0,0,0,0)'), showlegend=False, name=f'{label} CI'
        ))
        return traces, vals, fvals

    exp_tot_df = proc.get_monthly_export_totals(selected_hsn)
    imp_tot_df = proc.get_monthly_import_totals(selected_hsn)

    fig = go.Figure()
    kpis = {}

    if trade_dir in ("Export", "Both") and not exp_tot_df.empty:
        res = _build_forecast_trace(exp_tot_df, 'export_value_usd', 'Export', EXP_COL, '#1abc9c')
        if res:
            for t in res[0]: fig.add_trace(t)
            kpis['exp_last'] = res[1][-1]; kpis['exp_fcast'] = res[2]

    if trade_dir in ("Import", "Both") and not imp_tot_df.empty:
        res = _build_forecast_trace(imp_tot_df, 'import_value_usd', 'Import', IMP_COL, '#8e44ad')
        if res:
            for t in res[0]: fig.add_trace(t)
            kpis['imp_last'] = res[1][-1]; kpis['imp_fcast'] = res[2]

    fig.update_layout(title=f"Trade Forecast — {product_name} ({method_lbl})",
                      height=460, xaxis_title='Year' if annual_forecast_mode else 'Month', yaxis_title='Value (USD)',
                      legend=dict(orientation='h', yanchor='bottom', y=1.02))
    fig.update_yaxes(tickformat='$,.0f')
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")
    kc = st.columns(4)
    if 'exp_last' in kpis:
        kc[0].metric("Last Export",   f"${kpis['exp_last']/1e6:.2f}M")
        chg = (kpis['exp_fcast'][0]-kpis['exp_last'])/kpis['exp_last']*100 if kpis['exp_last'] else 0
        kc[1].metric("Export YoY Proj." if annual_forecast_mode else "Export MoM Proj.", f"{chg:+.1f}%")
    if 'imp_last' in kpis:
        kc[2].metric("Last Import",   f"${kpis['imp_last']/1e6:.2f}M")
        chg = (kpis['imp_fcast'][0]-kpis['imp_last'])/kpis['imp_last']*100 if kpis['imp_last'] else 0
        kc[3].metric("Import YoY Proj." if annual_forecast_mode else "Import MoM Proj.", f"{chg:+.1f}%")

    # Annual history
    st.markdown('<div class="sec-hdr">📊 Annual Trade History (all products)</div>', unsafe_allow_html=True)
    ann = proc.load_annual_trade_values()
    if not ann.empty and 'Year' in ann.columns:
        fig_a = px.bar(ann.sort_values('Year'), x='Year', y='Trade_Value',
                       title="Annual Import Value — All 40 Products",
                       color='Trade_Value', color_continuous_scale='Blues',
                       labels={'Trade_Value': 'Import Value (USD)'})
        fig_a.update_layout(height=360, showlegend=False)
        fig_a.update_yaxes(tickformat='$,.0f')
        st.plotly_chart(fig_a, use_container_width=True)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 7 — PRICING
# ═══════════════════════════════════════════════════════════════════════
elif page == "💰 Pricing":
    st.markdown('<div class="main-title">💰 Product Reference Pricing</div>', unsafe_allow_html=True)
    st.markdown("Market reference prices (USD/MT) cross-referenced with actual export and import volumes.")

    try:
        from trademap_data_loader import MARKET_PRICES
    except ImportError:
        pass

    col_e = 'total_export_value_usd'
    col_i = 'total_import_value_usd'

    # Aggregate by hsn_code to avoid double-counting from duplicate product_name rows
    _exp_raw = tm['export_hsn_totals']
    _imp_raw = tm['import_hsn_totals']
    exp_by_hsn = (
        _exp_raw.groupby('hsn_code').agg(**{col_e: (col_e, 'sum'), 'num_countries': ('num_countries', 'sum')})
        if not _exp_raw.empty and col_e in _exp_raw.columns else pd.DataFrame()
    )
    imp_by_hsn = (
        _imp_raw.groupby('hsn_code').agg(**{col_i: (col_i, 'sum'), 'num_countries': ('num_countries', 'sum')})
        if not _imp_raw.empty and col_i in _imp_raw.columns else pd.DataFrame()
    )

    rows = []
    for hsn, info in sorted(MARKET_PRICES.items()):
        ev, iv, ne, ni = 0, 0, 0, 0
        if not exp_by_hsn.empty and hsn in exp_by_hsn.index:
            ev = exp_by_hsn.loc[hsn, col_e]; ne = exp_by_hsn.loc[hsn, 'num_countries']
        if not imp_by_hsn.empty and hsn in imp_by_hsn.index:
            iv = imp_by_hsn.loc[hsn, col_i]; ni = imp_by_hsn.loc[hsn, 'num_countries']
        rows.append({'HSN': hsn, 'Product': info['name'],
                     'Price (USD/MT)': info['price'], 'Unit': info['unit'],
                     'Export Value (USD)': ev, 'Export Countries': int(ne),
                     'Import Value (USD)': iv, 'Import Countries': int(ni)})

    pdf = pd.DataFrame(rows).sort_values('Price (USD/MT)', ascending=False)

    c1, c2 = st.columns(2)
    with c1:
        fig = px.bar(pdf.sort_values('Price (USD/MT)'), x='Price (USD/MT)', y='Product',
                     orientation='h', title="Reference Price (USD/MT)",
                     color='Price (USD/MT)', color_continuous_scale='Oranges')
        fig.update_layout(height=680, showlegend=False)
        st.plotly_chart(fig, use_container_width=True)

    with c2:
        fig2 = px.scatter(pdf, x='Export Value (USD)', y='Import Value (USD)',
                          size='Price (USD/MT)', color='Price (USD/MT)',
                          hover_name='Product', color_continuous_scale='RdYlGn_r',
                          title="Export vs Import Volume (bubble = price)")
        fig2.update_layout(height=680, showlegend=False)
        fig2.update_xaxes(tickformat='$,.0f'); fig2.update_yaxes(tickformat='$,.0f')
        st.plotly_chart(fig2, use_container_width=True)

    st.markdown('<div class="sec-hdr">📋 Full Pricing Table</div>', unsafe_allow_html=True)
    disp = pdf.copy()
    disp['Price (USD/MT)']      = disp['Price (USD/MT)'].apply(lambda x: f"${x:,.0f}")
    disp['Export Value (USD)']  = disp['Export Value (USD)'].apply(lambda x: f"${x/1e6:.1f}M")
    disp['Import Value (USD)']  = disp['Import Value (USD)'].apply(lambda x: f"${x/1e6:.1f}M")
    st.dataframe(disp, use_container_width=True, height=580)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 8 — COMPANIES & TRADE COUNTRIES
# ═══════════════════════════════════════════════════════════════════════
elif page == "🏢 Companies":
    st.markdown('<div class="main-title">🏢 Companies Intelligence</div>', unsafe_allow_html=True)
    st.markdown("Browse **real exporting companies** (global, 74 products) and **Indian importing companies** (40 products) — sourced directly from ITC TradeMap.")

    # ── Load all three data sources ──
    @st.cache_data
    def _load_exp_co():
        try:
            from export_companies_loader import get_export_companies
            return get_export_companies()
        except Exception as e:
            st.error(f"Export companies error: {e}")
            return pd.DataFrame()

    @st.cache_data
    def _load_imp_co():
        try:
            from import_companies_loader import get_import_companies
            return get_import_companies()
        except Exception as e:
            st.error(f"Import companies error: {e}")
            return pd.DataFrame()

    exp_co  = _load_exp_co()    # global exporting companies
    imp_co  = _load_imp_co()    # India importing companies
    imp_ctry = proc.load_companies_unified()   # country-level trade values from XLS
    imp_ctry = imp_ctry[imp_ctry['trade_side'] == 'Importer'] if not imp_ctry.empty else pd.DataFrame()

    # ── Summary KPIs ──
    k1, k2, k3, k4 = st.columns(4)
    k1.metric("Exporting Companies",  f"{exp_co['company_name'].nunique():,}"  if not exp_co.empty else "—")
    k2.metric("Indian Importers",     f"{imp_co['company_name'].nunique():,}"  if not imp_co.empty else "—")
    k3.metric("Exporter Countries",   exp_co['country'].nunique()              if not exp_co.empty else 0)
    k4.metric("Products Covered",     max(exp_co['hsn_code'].nunique() if not exp_co.empty else 0,
                                         imp_co['hsn_code'].nunique() if not imp_co.empty else 0))

    st.markdown("---")

    # ── Filters ──
    c1, c2, c3 = st.columns([2, 2, 1])
    with c1:
        all_hsn = sorted(set(
            list(exp_co['hsn_code'].dropna().astype(str).unique() if not exp_co.empty else []) +
            list(imp_co['hsn_code'].dropna().astype(str).unique() if not imp_co.empty else [])
        ))
        sel_hsn = st.selectbox("Product (HSN)", ['All'] + all_hsn,
                               format_func=lambda x: 'All Products' if x == 'All' else HSN_FMT(x))
    with c2:
        if sel_hsn != 'All':
            exp_pool = exp_co[exp_co['hsn_code'] == sel_hsn]['country'].dropna().unique() if not exp_co.empty else []
            imp_pool = imp_co[imp_co['hsn_code'] == sel_hsn]['country'].dropna().unique() if not imp_co.empty else []
        else:
            exp_pool = exp_co['country'].dropna().unique() if not exp_co.empty else []
            imp_pool = imp_co['country'].dropna().unique() if not imp_co.empty else []
        all_countries = sorted(set(list(exp_pool) + list(imp_pool)))
        sel_country = st.selectbox("Country", ['All'] + all_countries)
    with c3:
        view_mode = st.radio("View", ["Both", "Exporters", "Importers"], horizontal=True)

    # ── Apply filters ──
    flt_exp = exp_co.copy() if not exp_co.empty else pd.DataFrame()
    flt_imp = imp_co.copy() if not imp_co.empty else pd.DataFrame()
    if sel_hsn != 'All':
        if not flt_exp.empty: flt_exp = flt_exp[flt_exp['hsn_code'] == sel_hsn]
        if not flt_imp.empty: flt_imp = flt_imp[flt_imp['hsn_code'] == sel_hsn]
    if sel_country != 'All':
        if not flt_exp.empty: flt_exp = flt_exp[flt_exp['country'] == sel_country]
        if not flt_imp.empty: flt_imp = flt_imp[flt_imp['country'] == sel_country]

    st.markdown("---")

    # ══════════════════════════════════════
    # SECTION A: EXPORTING COMPANIES
    # ══════════════════════════════════════
    if view_mode in ("Both", "Exporters"):
        st.markdown('<div class="sec-hdr">📤 Exporting Companies</div>', unsafe_allow_html=True)

        if flt_exp.empty:
            st.info("No exporting company data for the selected filters.")
        else:
            ea, eb, ec = st.columns(3)
            ea.metric("Companies Found", f"{flt_exp['company_name'].nunique():,}")
            eb.metric("Countries",       flt_exp['country'].nunique())
            ec.metric("HSN Products",    flt_exp['hsn_code'].nunique())

            c1, c2 = st.columns(2)
            with c1:
                top_co = (flt_exp.groupby('country')['company_name']
                          .nunique().nlargest(20).reset_index()
                          .sort_values('company_name')
                          .rename(columns={'company_name': 'Companies'}))
                fig = px.bar(top_co, x='Companies', y='country', orientation='h',
                             title="Top Countries by Exporting Companies",
                             color='Companies', color_continuous_scale='Greens',
                             labels={'country': ''})
                fig.update_layout(height=500, showlegend=False)
                st.plotly_chart(fig, use_container_width=True)

            with c2:
                if sel_hsn == 'All':
                    top_hsn = (flt_exp.groupby(['hsn_code','product_name'])['company_name']
                               .nunique().nlargest(15).reset_index()
                               .sort_values('company_name')
                               .rename(columns={'company_name': 'Companies'}))
                    fig = px.bar(top_hsn, x='Companies', y='product_name', orientation='h',
                                 title="Top Products by Exporting Companies",
                                 color='Companies', color_continuous_scale='Teal',
                                 labels={'product_name': ''})
                    fig.update_layout(height=500, showlegend=False)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    # Show country pie for selected product
                    top_pie = flt_exp.groupby('country')['company_name'].nunique().nlargest(15)
                    fig = px.pie(values=top_pie.values, names=top_pie.index,
                                 title=f"Company Distribution by Country — {HSN_FMT(sel_hsn)}",
                                 hole=0.4)
                    fig.update_layout(height=500)
                    st.plotly_chart(fig, use_container_width=True)

            # Company directory table
            st.markdown('<div class="sec-hdr">📋 Company Directory</div>', unsafe_allow_html=True)

            # Search box
            search = st.text_input("🔍 Search company name", placeholder="Type to filter…", key="co_search")
            disp = flt_exp.copy()
            if search:
                disp = disp[disp['company_name'].str.contains(search, case=False, na=False)]

            # Column selection
            show_cols = ['company_name','country','city','website','product_name','hsn_code','num_categories','num_employees']
            show_cols = [c for c in show_cols if c in disp.columns]
            disp_display = disp[show_cols].drop_duplicates(subset=['company_name','hsn_code']).reset_index(drop=True)
            disp_display.columns = [c.replace('_',' ').title() for c in disp_display.columns]

            st.caption(f"Showing {len(disp_display):,} records")
            st.dataframe(disp_display, use_container_width=True, height=450)

            # Download
            st.download_button(
                "⬇ Download Exporting Companies CSV",
                flt_exp.to_csv(index=False),
                f"export_companies{'_'+sel_hsn if sel_hsn!='All' else ''}.csv",
                "text/csv"
            )

        st.markdown("---")

    # ══════════════════════════════════════
    # SECTION B: IMPORTING COMPANIES (India)
    # ══════════════════════════════════════
    if view_mode in ("Both", "Importers"):
        st.markdown('<div class="sec-hdr">📥 Importing Companies (India)</div>', unsafe_allow_html=True)
        st.caption("Indian companies that import these products — sourced from ITC TradeMap India import data.")

        if flt_imp.empty:
            st.info("No importing company data for the selected filters." +
                    (" (This product may not have India import data available.)" if sel_hsn != 'All' else ""))
        else:
            ia, ib, ic_ = st.columns(3)
            ia.metric("Indian Importers Found", f"{flt_imp['company_name'].nunique():,}")
            ib.metric("HSN Products",           flt_imp['hsn_code'].nunique())
            ic_.metric("Cities Covered",        flt_imp['city'].nunique() if 'city' in flt_imp.columns else "—")

            c1, c2 = st.columns(2)
            with c1:
                if sel_hsn == 'All':
                    top_imp_hsn = (flt_imp.groupby(['hsn_code','product_name'])['company_name']
                                   .nunique().nlargest(15).reset_index()
                                   .sort_values('company_name')
                                   .rename(columns={'company_name': 'Importers'}))
                    fig = px.bar(top_imp_hsn, x='Importers', y='product_name', orientation='h',
                                 title="Products by Number of Indian Importers",
                                 color='Importers', color_continuous_scale='Blues',
                                 labels={'product_name': ''})
                    fig.update_layout(height=500, showlegend=False)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    city_counts = flt_imp['city'].value_counts().head(15)
                    fig = px.bar(x=city_counts.values, y=city_counts.index, orientation='h',
                                 title="Indian Importers by City",
                                 color=city_counts.values, color_continuous_scale='Blues',
                                 labels={'x': 'Number of Companies', 'y': ''})
                    fig.update_layout(height=450, showlegend=False)
                    st.plotly_chart(fig, use_container_width=True)

            with c2:
                top_co_products = (flt_imp.groupby('company_name')['hsn_code']
                                   .nunique().nlargest(15).reset_index()
                                   .sort_values('hsn_code')
                                   .rename(columns={'hsn_code': 'Products Imported', 'company_name': 'Company'}))
                fig = px.bar(top_co_products, x='Products Imported', y='Company', orientation='h',
                             title="Top Indian Importers by Products Range",
                             color='Products Imported', color_continuous_scale='Teal',
                             labels={'Company': ''})
                fig.update_layout(height=500, showlegend=False)
                st.plotly_chart(fig, use_container_width=True)

            # Import company directory
            st.markdown('<div class="sec-hdr">📋 Indian Importer Directory</div>', unsafe_allow_html=True)
            imp_search = st.text_input("🔍 Search importer name", placeholder="Type to filter…", key="imp_co_search")
            disp_i = flt_imp.copy()
            if imp_search:
                disp_i = disp_i[disp_i['company_name'].str.contains(imp_search, case=False, na=False)]

            show_i_cols = ['company_name','city','website','product_name','hsn_code','num_categories']
            show_i_cols = [c for c in show_i_cols if c in disp_i.columns]
            disp_i_display = disp_i[show_i_cols].drop_duplicates(subset=['company_name','hsn_code']).reset_index(drop=True)
            disp_i_display.columns = [c.replace('_',' ').title() for c in disp_i_display.columns]

            st.caption(f"Showing {len(disp_i_display):,} records | All companies based in 🇮🇳 India")
            st.dataframe(disp_i_display, use_container_width=True, height=420)

            st.download_button(
                "⬇ Download Indian Importers CSV",
                flt_imp.to_csv(index=False),
                f"import_companies_india{'_'+sel_hsn if sel_hsn!='All' else ''}.csv",
                "text/csv"
            )

        st.markdown("---")

    # ══════════════════════════════════════
    # SECTION C: SIDE-BY-SIDE (Both mode, product selected)
    # ══════════════════════════════════════
    if view_mode == "Both" and sel_hsn != 'All' and not flt_exp.empty and not flt_imp.empty:
        st.markdown('<div class="sec-hdr">🔄 Global Exporters vs Indian Importers — Head to Head</div>', unsafe_allow_html=True)

        c1, c2 = st.columns(2)
        with c1:
            top_exp_co = (flt_exp.groupby('country')['company_name'].nunique()
                          .nlargest(15).reset_index().sort_values('company_name')
                          .rename(columns={'company_name': 'Exporting Companies'}))
            fig = px.bar(top_exp_co, x='Exporting Companies', y='country', orientation='h',
                         title=f"Global Exporters by Country — {HSN_FMT(sel_hsn)}",
                         color='Exporting Companies', color_continuous_scale='Greens',
                         labels={'country': ''})
            fig.update_layout(height=450, showlegend=False)
            st.plotly_chart(fig, use_container_width=True)

        with c2:
            # India importer city distribution for this product
            city_imp = (flt_imp.groupby('city')['company_name'].nunique()
                        .nlargest(15).reset_index().sort_values('company_name')
                        .rename(columns={'company_name': 'Indian Importers', 'city': 'City'}))
            fig = px.bar(city_imp, x='Indian Importers', y='City', orientation='h',
                         title=f"Indian Importers by City — {HSN_FMT(sel_hsn)}",
                         color='Indian Importers', color_continuous_scale='Blues',
                         labels={'City': ''})
            fig.update_layout(height=450, showlegend=False)
            st.plotly_chart(fig, use_container_width=True)

        # Combined stats
        st.info(
            f"**{HSN_FMT(sel_hsn)}** — "
            f"**{flt_exp['company_name'].nunique():,}** global exporters across "
            f"**{flt_exp['country'].nunique()}** countries "
            f"vs **{flt_imp['company_name'].nunique():,}** Indian importers across "
            f"**{flt_imp['city'].nunique() if 'city' in flt_imp.columns else '?'}** cities."
        )

    # ══════════════════════════════════════
    # SECTION D: Country-level import values (supplementary)
    # ══════════════════════════════════════
    if view_mode in ("Both", "Importers") and not imp_ctry.empty:
        with st.expander("🌍 Global Import Country Values (from TradeMap XLS)"):
            flt_ctry = imp_ctry.copy()
            if sel_hsn != 'All':
                flt_ctry = flt_ctry[flt_ctry['hsn_code'].astype(str) == sel_hsn]
            if not flt_ctry.empty and 'total_value_usd' in flt_ctry.columns:
                top_c = (flt_ctry.groupby('country')['total_value_usd'].sum()
                         .nlargest(20).reset_index().sort_values('total_value_usd'))
                fig = px.bar(top_c, x='total_value_usd', y='country', orientation='h',
                             title="Top Importing Countries by Trade Value (USD)",
                             color='total_value_usd', color_continuous_scale='Blues',
                             labels={'total_value_usd': 'Import Value (USD)', 'country': ''})
                fig.update_layout(height=500, showlegend=False)
                fig.update_xaxes(tickformat='$,.0f')
                st.plotly_chart(fig, use_container_width=True)


# ═══════════════════════════════════════════════════════════════════════
# PAGE 9 — DATA EXPORT
# ═══════════════════════════════════════════════════════════════════════
elif page == "📋 Data Export":
    st.markdown('<div class="main-title">📋 Data Export</div>', unsafe_allow_html=True)
    st.markdown("Download any dataset as CSV for offline analysis.")

    c1, c2, c3 = st.columns(3)
    with c1:
        st.subheader("📤 Export Countries")
        df = proc.load_export_countries()
        if not df.empty:
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "export_countries.csv", "text/csv")
    with c2:
        st.subheader("📥 Import Countries")
        df = proc.load_import_countries()
        if not df.empty:
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "import_countries.csv", "text/csv")
    with c3:
        st.subheader("🌍 Trade Countries (Both Sides)")
        df = proc.load_companies_unified()
        if not df.empty:
            st.caption(f"{len(df):,} rows — exporters & importers per HSN")
            st.download_button("⬇ Download", df.to_csv(index=False), "trade_countries_both_sides.csv", "text/csv")

    c1, c2, c3 = st.columns(3)
    with c1:
        st.subheader("📤 Exporting Companies (Global)")
        try:
            from export_companies_loader import get_export_companies
            df = get_export_companies()
            if not df.empty:
                st.caption(f"{df['company_name'].nunique():,} companies | {df['hsn_code'].nunique()} HSNs | {df['country'].nunique()} countries")
                st.download_button("⬇ Download", df.to_csv(index=False), "exporting_companies_global.csv", "text/csv")
        except Exception as e:
            st.warning(f"Export companies not available: {e}")
    with c2:
        st.subheader("📥 Importing Companies (India)")
        try:
            from import_companies_loader import get_import_companies
            df = get_import_companies()
            if not df.empty:
                st.caption(f"{df['company_name'].nunique():,} companies | {df['hsn_code'].nunique()} HSNs | India only")
                st.download_button("⬇ Download", df.to_csv(index=False), "importing_companies_india.csv", "text/csv")
        except Exception as e:
            st.warning(f"Import companies not available: {e}")
    with c3:
        st.subheader("📅 Monthly Export Data")
        df = tm['export_monthly']
        if not df.empty:
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "monthly_exports.csv", "text/csv")
    with c2:
        st.subheader("📅 Monthly Import Data")
        df = tm['import_monthly']
        if not df.empty:
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "monthly_imports.csv", "text/csv")
    with c3:
        st.subheader("💰 Pricing")
        df = proc.load_price_per_unit()
        if not df.empty:
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "pricing.csv", "text/csv")

    st.markdown("---")
    st.markdown("### 🌍 Global Trade Warehouse Downloads")
    g1, g2, g3 = st.columns(3)
    with g1:
        df = proc.load_global_product_index()
        if not df.empty:
            st.subheader("HSN Index")
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "global_hsn_index.csv", "text/csv")
    with g2:
        df = proc.load_global_trade_product_year()
        if not df.empty:
            st.subheader("Product-Year Trade")
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "global_product_year_trade.csv", "text/csv")
    with g3:
        df = proc.load_global_trade_world_year()
        if not df.empty:
            st.subheader("World Year Summary")
            st.caption(f"{len(df):,} rows")
            st.download_button("⬇ Download", df.to_csv(index=False), "global_world_year_summary.csv", "text/csv")

    st.markdown("---")
    st.markdown("### 📦 Single-Product Download")
    c1, c2 = st.columns(2)
    with c1:
        sel = st.selectbox("Product", sorted_hsn, format_func=HSN_FMT)
        df_e = proc.get_monthly_export_data(sel)
        df_i = proc.get_monthly_import_data(sel)
        if not df_e.empty:
            st.download_button(f"⬇ Export data — {sel}", df_e.to_csv(index=False), f"export_{sel}.csv", "text/csv")
        if not df_i.empty:
            st.download_button(f"⬇ Import data — {sel}", df_i.to_csv(index=False), f"import_{sel}.csv", "text/csv")

# ── Footer ────────────────────────────────────────────────────────────
st.markdown("---")
st.markdown(f"""
<div style='text-align:center; color:#aaa; font-size:.82em;'>
  🌍 Global Trade Intelligence &nbsp;|&nbsp; Spark + Hadoop Warehouse &nbsp;|&nbsp;
  {global_stats['total_products']} Products · {max(global_stats['exporter_countries'], global_stats['importer_countries'])}+ Countries · 2017–2026
</div>""", unsafe_allow_html=True)
