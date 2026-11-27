<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Buyer Command Cockpit</title>

    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Chart.js 4 CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
                    },
                    colors: {
                        supple: {
                            deep: '#071533',
                            navy: '#0B1E47',
                            midnavy: '#122B63',
                            royal: '#16367D',
                            brightnavy: '#163B7C',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            amberdark: '#D97706',
                            emerald: '#10B981',
                            rose: '#F43F5E',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06)',
                        'card-hover': '0 10px 26px -8px rgba(11, 30, 71, 0.12)',
                        'drawer': '-12px 0 40px -10px rgba(7, 21, 51, 0.35)'
                    }
                }
            }
        };
    </script>

    <style>
        .tabular-nums { font-variant-numeric: tabular-nums; }
        .hero-dot-grid {
            background-size: 22px 22px;
            background-image: radial-gradient(circle, rgba(45, 212, 191, 0.16) 1px, transparent 1px);
        }
        @keyframes marqueeScroll {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
        .marquee-track {
            display: flex;
            width: max-content;
            animation: marqueeScroll 42s linear infinite;
        }
        .marquee-wrapper:hover .marquee-track {
            animation-play-state: paused;
        }
        .drawer-panel { transition: transform 0.32s cubic-bezier(0.16, 1, 0.3, 1); }
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 9999px; }
        html.dark ::-webkit-scrollbar-thumb { background: #334155; }
    </style>
</head>

<body class="min-h-screen bg-[#F4F7FC] dark:bg-[#0B1120] text-slate-800 dark:text-slate-100 font-sans antialiased transition-colors duration-200 overflow-x-hidden">

    <!-- Existing Unified Sidebar (Untouched, includes dark-mode.jsp & ai-chatbot.jsp) -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <!-- =============================================================== -->
    <!-- MAIN WORKSPACE AREA                                             -->
    <!-- =============================================================== -->
    <main class="w-full min-h-screen flex flex-col">
        <div class="p-4 sm:p-6 lg:p-7 max-w-[1560px] w-full mx-auto space-y-5">

            <!-- ======================================================= -->
            <!-- 1. COMMAND HERO BANNER + LIVE BACI SPOT TICKER          -->
            <!-- ======================================================= -->
            <div class="space-y-3">
                <section class="relative overflow-hidden rounded-2xl text-white p-6 lg:p-7 shadow-lg border border-white/10" style="background: linear-gradient(115deg, #071533 0%, #0B1E47 52%, #163B7C 100%);">
                    <div class="absolute inset-0 hero-dot-grid opacity-70 pointer-events-none"></div>
                    <div class="absolute -top-24 -right-20 w-80 h-80 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-5">
                        <div class="space-y-2.5 max-w-2xl">
                            <div class="flex flex-wrap items-center gap-2">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 border border-emerald-400/35">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                                    REAL-TIME ENGINE ACTIVE
                                </span>
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider bg-amber-500/20 text-amber-300 border border-amber-400/35">
                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
                                    1D-ResNet V2 Neural Online
                                </span>
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-semibold bg-white/10 text-cyan-100 border border-white/15 backdrop-blur-sm">
                                    BACI Lakehouse: 5,384 Commodities
                                </span>
                            </div>

                            <div>
                                <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white">Supplexio Buyer Command Cockpit</h1>
                                <p class="text-xs sm:text-sm text-slate-300 mt-1 leading-relaxed">
                                    Pre-auction readiness, live bid compression, and neural commodity intelligence.
                                </p>
                            </div>
                        </div>

                        <!-- Right Action Cluster -->
                        <div class="flex flex-wrap items-center gap-2.5">
                            <a href="${pageContext.request.contextPath}/auction" class="px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#F59E0B] to-amber-400 hover:from-amber-400 hover:to-amber-300 text-slate-950 font-extrabold text-xs shadow-lg shadow-amber-500/20 transition-all active:scale-[0.98] flex items-center gap-1.5 no-underline">
                                <span>+ New Reverse Auction</span>
                            </a>
                            <button type="button" onclick="openAiCockpitDrawer()" class="px-4 py-2.5 rounded-xl bg-cyan-500/15 hover:bg-cyan-500/25 text-[#2DD4BF] font-bold text-xs border border-cyan-400/35 backdrop-blur-sm transition-all flex items-center gap-1.5">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                                <span>AI Procurement Cockpit</span>
                            </button>
                            <button type="button" onclick="openTradeMatrixModal()" class="px-4 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-semibold text-xs border border-white/20 transition-all flex items-center gap-1.5">
                                <svg class="w-4 h-4 text-cyan-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                <span>Global Trade Matrix</span>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- Live BACI Spot Ticker Bar -->
                <div class="bg-white dark:bg-[#111827] border border-[#E2E8F0] dark:border-slate-800 rounded-xl py-2 px-3 shadow-card overflow-hidden marquee-wrapper flex items-center">
                    <div class="hidden sm:flex items-center gap-1.5 pr-3 mr-3 border-r border-slate-200 dark:border-slate-700 shrink-0">
                        <span class="w-2 h-2 rounded-full bg-[#0D9488] dark:bg-[#2DD4BF] animate-pulse"></span>
                        <span class="text-[10px] font-mono font-bold uppercase tracking-wider text-[#0B1E47] dark:text-[#2DD4BF]">LIVE BACI TICKER</span>
                    </div>
                    <div class="overflow-hidden flex-1">
                        <div class="marquee-track" id="baciTickerTrack">
                            <span class="text-xs text-slate-400 px-4 font-mono">Loading live commodity feed...</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ======================================================= -->
            <!-- 2. EXECUTIVE AUCTION-READINESS KPI STRIP (5 CARDS)      -->
            <!-- ======================================================= -->
            <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
                <!-- KPI 1: Realized Cost Savings -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex flex-col justify-between">
                    <div class="flex items-center justify-between gap-2">
                        <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Realized Cost Savings</span>
                        <span class="text-[10px] font-mono font-bold text-emerald-600 dark:text-emerald-400">LIVE</span>
                    </div>
                    <div class="mt-2 text-2xl font-extrabold font-mono tabular-nums text-slate-900 dark:text-white">
                        ₹<fmt:formatNumber value="${not empty totalSavings ? totalSavings : 0}" maxFractionDigits="0" />
                    </div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-1.5">
                        <span class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/25">Reverse Auction Margin</span>
                        <span class="text-[10.5px] font-mono text-slate-400">All-time</span>
                    </div>
                </div>

                <!-- KPI 2: Active Reverse Auctions -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex flex-col justify-between">
                    <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Active Auctions</span>
                    <div id="kpiLotsCount" class="mt-2 text-2xl font-extrabold font-mono tabular-nums text-slate-900 dark:text-white">
                        ${not empty activeAuctions ? activeAuctions : 0} <span class="text-xs font-sans font-semibold text-slate-400">Live Lots</span>
                    </div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-1.5">
                        <a href="${pageContext.request.contextPath}/auction" class="text-[10.5px] font-mono font-bold text-[#0D9488] dark:text-[#2DD4BF] hover:underline">Manage Floor →</a>
                        <span id="kpiZeroBidChip" class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-amber-500/15 text-amber-700 dark:text-amber-300 border border-amber-500/30">Live Monitor</span>
                    </div>
                </div>

                <!-- KPI 3: Active Suppliers -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex flex-col justify-between">
                    <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Verified Suppliers</span>
                    <div class="mt-2 text-2xl font-extrabold font-mono tabular-nums text-slate-900 dark:text-white">
                        ${not empty activeSuppliers ? activeSuppliers : 0} <span class="text-xs font-sans font-semibold text-slate-400">Vendors</span>
                    </div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-1.5">
                        <span class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/25">Active Pool</span>
                        <a href="${pageContext.request.contextPath}/supplier" class="text-[10.5px] text-[#0D9488] dark:text-[#2DD4BF] hover:underline font-semibold">Directory →</a>
                    </div>
                </div>

                <!-- KPI 4: Auction-Triggered Restocks -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-rose-200/80 dark:border-rose-500/30 p-4 shadow-card flex flex-col justify-between">
                    <span class="text-[11px] font-semibold uppercase tracking-wider text-rose-600 dark:text-rose-400">Low-Stock Alerts</span>
                    <div class="mt-2 text-2xl font-extrabold font-mono tabular-nums text-slate-900 dark:text-white">
                        ${not empty lowStockCount ? lowStockCount : 0} <span class="text-xs font-sans font-semibold text-slate-400">SKUs</span>
                    </div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-1.5">
                        <span id="kpiUrgentSurgeBadge" class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-rose-500/15 text-rose-600 dark:text-rose-300 border border-rose-500/30">Kanban Trigger</span>
                        <a href="${pageContext.request.contextPath}/inventory" class="text-[10.5px] font-semibold text-rose-600 dark:text-rose-400 hover:underline">Restock →</a>
                    </div>
                </div>

                <!-- KPI 5: Transactions & Settlement Rate -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex flex-col justify-between sm:col-span-2 lg:col-span-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Payments &amp; Settlement</span>
                    <div class="mt-2 text-2xl font-extrabold font-mono tabular-nums text-slate-900 dark:text-white">
                        ${not empty totalTransactions ? totalTransactions : 0} <span class="text-xs font-sans font-semibold text-slate-400">Settled</span>
                    </div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-1.5">
                        <span class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-cyan-500/15 text-[#0D9488] dark:text-[#2DD4BF] border border-cyan-500/30">${not empty successRate ? successRate : 0}% Success</span>
                        <a href="${pageContext.request.contextPath}/user-po-view" class="text-[10.5px] text-[#0D9488] dark:text-[#2DD4BF] hover:underline font-semibold">PO Ledger →</a>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- 3. ACTIONABLE PRIORITY QUEUE: LIVE SOURCING TRIGGERS    -->
            <!-- ======================================================= -->
            <section id="triggersSection" class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 bg-slate-50/75 dark:bg-slate-900/50 flex flex-col md:flex-row md:items-center justify-between gap-3">
                    <div>
                        <div class="inline-flex items-center gap-1.5 text-[10px] font-mono font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400">
                            <span class="w-1.5 h-1.5 rounded-full bg-rose-500 animate-ping"></span>
                            LIVE SOURCING TRIGGERS — KANBAN × 1D-RESNET
                        </div>
                        <h2 class="text-base font-extrabold text-slate-900 dark:text-white tracking-tight mt-0.5">
                            Immediate Auction Triggers (Live Price Forecast &amp; Stock Alerts)
                        </h2>
                    </div>

                    <div class="flex flex-wrap items-center gap-1.5" id="triggerFilterPills">
                        <button type="button" onclick="setTriggerFilter('all')" data-tr="all" class="tr-pill px-3 py-1.5 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm transition-all">
                            All Triggers
                        </button>
                        <button type="button" onclick="setTriggerFilter('surge')" data-tr="surge" class="tr-pill px-3 py-1.5 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all">
                            Price Surge Risk
                        </button>
                        <button type="button" onclick="setTriggerFilter('critical')" data-tr="critical" class="tr-pill px-3 py-1.5 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all">
                            Low Stock
                        </button>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50/90 dark:bg-slate-900/80 border-b border-[#E2E8F0] dark:border-slate-800 text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                <th class="py-3 px-5">Material &amp; HSN</th>
                                <th class="py-3 px-4">Kanban Stock Level</th>
                                <th class="py-3 px-4">30d Neural Forecast</th>
                                <th class="py-3 px-4 text-right">AI Rec. Ceiling</th>
                                <th class="py-3 px-4">Trade Corridor</th>
                                <th class="py-3 px-5 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="sourcingTriggersBody" class="divide-y divide-slate-100 dark:divide-slate-800 text-xs">
                            <tr><td colspan="6" class="py-8 text-center text-slate-400 font-mono">Fetching live 1D-ResNet triggers from Trade Engine...</td></tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- 4. PRIMARY ANALYTICS ROW (7/5 SPLIT WITH CHART.JS)      -->
            <!-- ======================================================= -->
            <section class="grid grid-cols-1 lg:grid-cols-12 gap-5">
                <div class="lg:col-span-7 bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden flex flex-col">
                    <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap items-center justify-between gap-3">
                        <div>
                            <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Auction Activity &amp; Realized Savings</h2>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Live monthly auction volume vs. realized INR savings</p>
                        </div>
                        <span class="px-2.5 py-1 rounded-lg text-[10px] font-mono font-bold bg-teal-50 dark:bg-teal-950/50 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200 dark:border-teal-800">DATABASE SYNC</span>
                    </div>
                    <div class="p-5 flex-1">
                        <div class="relative h-[265px] w-full">
                            <canvas id="primaryCalibrationChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-5 bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden flex flex-col">
                    <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between gap-2">
                        <div>
                            <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Inventory Kanban Distribution</h2>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Live stock health breakdown across tracked SKUs</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/inventory" class="px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-teal-50 dark:bg-teal-950/50 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200 dark:border-teal-800 hover:underline">VIEW ALL</a>
                    </div>
                    <div class="p-5 flex-1 flex flex-col justify-between space-y-4">
                        <div class="relative h-[205px] w-full">
                            <canvas id="inventoryHealthChart"></canvas>
                        </div>
                        <div class="p-3 rounded-xl bg-teal-50/80 dark:bg-teal-950/35 border border-teal-200/80 dark:border-teal-800/60 flex items-center gap-2.5 text-xs">
                            <div class="w-7 h-7 rounded-lg bg-[#0D9488] text-white flex items-center justify-center shrink-0 font-bold text-xs">✓</div>
                            <span class="font-semibold text-[#0B1E47] dark:text-cyan-100 leading-snug">
                                Low-stock SKUs automatically surface in <a href="${pageContext.request.contextPath}/inventory" class="underline text-[#0D9488] dark:text-[#2DD4BF]">Inventory Management</a> for one-click reverse auctions.
                            </span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- 5. SECONDARY ANALYTICS ROW (3-COLUMN 4/4/4 GRID)        -->
            <!-- ======================================================= -->
            <section class="grid grid-cols-1 lg:grid-cols-12 gap-5">

                <!-- Col 1: Category Liquidity & Spend -->
                <div class="lg:col-span-4 bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden flex flex-col">
                    <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                        <div>
                            <h3 class="text-sm font-bold text-slate-900 dark:text-white">Category Spend Allocation</h3>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Live procurement spend by material category</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/product" class="text-[10px] font-mono font-bold text-[#0D9488] dark:text-[#2DD4BF] uppercase hover:underline">Catalog →</a>
                    </div>
                    <div id="categoryLiquidityList" class="p-4 space-y-3.5 flex-1">
                        <div class="text-xs text-slate-400 text-center py-6 font-mono">Loading spend breakdown...</div>
                    </div>
                </div>

                <!-- Col 2: Top Supplier Competitiveness -->
                <div id="supplierMatrixCard" class="lg:col-span-4 bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden flex flex-col">
                    <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                        <div>
                            <h3 class="text-sm font-bold text-slate-900 dark:text-white">Top Supplier Performance</h3>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Ranked by awards &amp; total bid volume</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/supplier" class="px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30 hover:underline">All Vendors</a>
                    </div>
                    <div id="supplierMatrixList" class="divide-y divide-slate-100 dark:divide-slate-800 flex-1">
                        <div class="text-xs text-slate-400 text-center py-6 font-mono">Loading top suppliers...</div>
                    </div>
                </div>

                <!-- Col 3: Quick Workspace Actions & Procurement Summary -->
                <div class="lg:col-span-4 bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden flex flex-col justify-between">
                    <div class="p-5 border-b border-slate-100 dark:border-slate-800 space-y-3.5">
                        <div class="flex items-center justify-between gap-2">
                            <div>
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Procurement Operations</h3>
                                <p class="text-[11px] text-slate-500 dark:text-slate-400">Direct workspace shortcuts</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/user-po-view" class="px-2.5 py-1 rounded-lg text-[10px] font-mono font-bold bg-amber-500/15 hover:bg-amber-500/25 text-amber-700 dark:text-amber-300 border border-amber-500/35 transition-colors">
                                Open POs →
                            </a>
                        </div>

                        <div class="grid grid-cols-2 gap-2.5 text-xs">
                            <a href="${pageContext.request.contextPath}/auction" class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-[#0D9488] transition-colors">
                                <div class="font-bold text-slate-900 dark:text-white">Reverse Auctions</div>
                                <div class="text-[10.5px] text-slate-500 dark:text-slate-400 mt-0.5">Create &amp; manage lots</div>
                            </a>
                            <a href="${pageContext.request.contextPath}/inventory" class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-[#0D9488] transition-colors">
                                <div class="font-bold text-slate-900 dark:text-white">Kanban Inventory</div>
                                <div class="text-[10.5px] text-slate-500 dark:text-slate-400 mt-0.5">${not empty lowStockCount ? lowStockCount : 0} low-stock alerts</div>
                            </a>
                            <a href="${pageContext.request.contextPath}/payment" class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-[#0D9488] transition-colors">
                                <div class="font-bold text-slate-900 dark:text-white">Payment Ledger</div>
                                <div class="text-[10.5px] text-slate-500 dark:text-slate-400 mt-0.5">₹<fmt:formatNumber value="${not empty totalSpend ? totalSpend : 0}" maxFractionDigits="0" /> settled</div>
                            </a>
                            <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-[#0D9488] transition-colors">
                                <div class="font-bold text-slate-900 dark:text-white">World Trade Intel</div>
                                <div class="text-[10.5px] text-slate-500 dark:text-slate-400 mt-0.5">BACI &amp; 1D-ResNet</div>
                            </a>
                        </div>
                    </div>

                    <div class="p-5 space-y-2.5 bg-slate-50/60 dark:bg-slate-900/40">
                        <div class="flex items-center justify-between">
                            <h4 class="text-xs font-bold text-slate-900 dark:text-white">Kanban Health Summary</h4>
                            <span id="invTotalLabel" class="text-[11px] font-mono font-bold text-slate-500 dark:text-slate-400">Syncing...</span>
                        </div>
                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="p-2 rounded-xl bg-white dark:bg-[#111827] border border-rose-200/70 dark:border-rose-500/30">
                                <div id="invLowCount" class="text-sm font-extrabold font-mono text-rose-600 dark:text-rose-400 tabular-nums">${not empty lowStockCount ? lowStockCount : 0}</div>
                                <div class="text-[10px] font-medium text-slate-500 dark:text-slate-400">Low Stock</div>
                            </div>
                            <div class="p-2 rounded-xl bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800">
                                <div id="invMedCount" class="text-sm font-extrabold font-mono text-amber-600 dark:text-amber-400 tabular-nums">-</div>
                                <div class="text-[10px] font-medium text-slate-500 dark:text-slate-400">Medium</div>
                            </div>
                            <div class="p-2 rounded-xl bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800">
                                <div id="invHighCount" class="text-sm font-extrabold font-mono text-emerald-600 dark:text-emerald-400 tabular-nums">-</div>
                                <div class="text-[10px] font-medium text-slate-500 dark:text-slate-400">Healthy</div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- 6. LIVE REVERSE AUCTION PULSE & BIDDING FLOOR           -->
            <!-- ======================================================= -->
            <section id="liveFloorSection" class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 bg-slate-50/75 dark:bg-slate-900/50 flex flex-col lg:flex-row lg:items-center justify-between gap-3">
                    <div>
                        <div class="inline-flex items-center gap-1.5 text-[10px] font-mono font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping"></span>
                            LIVE BIDDING OPERATIONS
                        </div>
                        <h2 class="text-base font-extrabold text-slate-900 dark:text-white tracking-tight mt-0.5">
                            Live Reverse Auction Pulse &amp; Competition Monitor
                        </h2>
                    </div>

                    <div class="flex flex-wrap items-center gap-2.5">
                        <div class="inline-flex items-center bg-slate-100 dark:bg-slate-800 p-1 rounded-xl border border-slate-200/80 dark:border-slate-700 text-xs font-semibold" id="floorFilterTabs"></div>
                        <a href="${pageContext.request.contextPath}/auction" class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold bg-teal-50 dark:bg-teal-950/50 hover:bg-teal-100 dark:hover:bg-teal-900/60 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200 dark:border-teal-800 transition-all no-underline">
                            <span>Open Auction Floor →</span>
                        </a>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50/90 dark:bg-slate-900/80 border-b border-[#E2E8F0] dark:border-slate-800 text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                <th class="py-3 px-5">Auction Lot</th>
                                <th class="py-3 px-4">Volume</th>
                                <th class="py-3 px-4 text-right">Ceiling Price</th>
                                <th class="py-3 px-4 text-right">Current Best L1</th>
                                <th class="py-3 px-4 text-right">Realized Savings</th>
                                <th class="py-3 px-4 text-center">Bids</th>
                                <th class="py-3 px-4">Competition Status</th>
                                <th class="py-3 px-4">Time Left</th>
                                <th class="py-3 px-5 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="liveFloorTableBody" class="divide-y divide-slate-100 dark:divide-slate-800 text-xs"></tbody>
                    </table>
                </div>
            </section>

            <!-- Footer -->
            <footer class="pt-2 pb-6 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500">
                <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                <p class="font-mono text-[11px] mt-1 sm:mt-0">Buyer Command Cockpit • 1D-ResNet V2 + BACI Lakehouse</p>
            </footer>
        </div>
    </main>

    <!-- =================================================================== -->
    <!-- DRAWER: AI PROCUREMENT COCKPIT (REAL SUGGESTIONS FROM APP)          -->
    <!-- =================================================================== -->
    <div id="aiCockpitOverlay" onclick="closeAiCockpitDrawer()" class="fixed inset-0 z-[10000] bg-slate-950/60 backdrop-blur-sm hidden"></div>
    <aside id="aiCockpitDrawer" class="drawer-panel fixed inset-y-0 right-0 z-[10001] w-full max-w-md bg-white dark:bg-[#0F172A] border-l border-slate-200 dark:border-slate-800 shadow-drawer transform translate-x-full flex flex-col">
        <div class="bg-gradient-to-r from-[#071533] via-[#0B1E47] to-[#0E5A6D] text-white p-5 border-b border-white/10 flex items-start justify-between gap-3">
            <div>
                <span class="text-[10px] font-mono uppercase tracking-widest text-[#2DD4BF]">1D-RESNET V2 LIVE ADVISORY</span>
                <h3 class="text-lg font-extrabold tracking-tight mt-0.5">AI Procurement Cockpit</h3>
                <p class="text-xs text-slate-300 mt-0.5">Real-time hedging &amp; restock suggestions from your live inventory and auctions.</p>
            </div>
            <button type="button" onclick="closeAiCockpitDrawer()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">✕</button>
        </div>

        <div id="aiCockpitSuggestionsList" class="flex-1 overflow-y-auto p-5 space-y-4">
            <div class="text-xs text-slate-400 text-center py-8 font-mono">Loading live AI procurement suggestions...</div>
        </div>
    </aside>

    <!-- =================================================================== -->
    <!-- MODAL: GLOBAL TRADE MATRIX (LIVE COMMODITIES + IMPORT/EXPORT COUNTRY)-->
    <!-- =================================================================== -->
    <div id="tradeMatrixModal" class="fixed inset-0 z-[10000] bg-slate-950/70 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-5xl w-full shadow-2xl overflow-hidden max-h-[88vh] flex flex-col">
            <div class="bg-gradient-to-r from-[#071533] via-[#0B1E47] to-[#0E5A6D] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-widest text-[#2DD4BF]">WORLD TRADE LIVE FEED • BACI LAKEHOUSE</span>
                    <h3 class="text-base font-extrabold">Global Trade Matrix &amp; Country Corridors</h3>
                </div>
                <div class="flex items-center gap-2">
                    <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="px-3 py-1.5 rounded-lg bg-[#2DD4BF] text-slate-950 text-xs font-bold hover:bg-teal-300 transition-colors no-underline">Full Trade Intel →</a>
                    <button type="button" onclick="closeModal('tradeMatrixModal')" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">✕</button>
                </div>
            </div>

            <div class="p-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap items-center justify-between gap-3">
                <input type="text" id="tradeMatrixSearch" oninput="renderTradeMatrixTable()" placeholder="Search live-feed commodity, HSN code, exporting or importing country..." class="flex-1 min-w-[240px] px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white">
                <span id="tradeMatrixUpdated" class="text-[11px] font-mono text-slate-500 dark:text-slate-400">Live feed syncing...</span>
            </div>

            <div class="overflow-auto flex-1">
                <table class="w-full text-left border-collapse text-xs">
                    <thead>
                        <tr class="bg-slate-50 dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 text-[10.5px] font-mono uppercase text-slate-500 dark:text-slate-400">
                            <th class="py-3 px-4">Commodity</th>
                            <th class="py-3 px-4">HSN</th>
                            <th class="py-3 px-4 text-right">Spot Rate (₹)</th>
                            <th class="py-3 px-4">30d Forecast</th>
                            <th class="py-3 px-4">Exporting Countries</th>
                            <th class="py-3 px-4">Importing Country</th>
                            <th class="py-3 px-4 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tradeMatrixBody" class="divide-y divide-slate-100 dark:divide-slate-800">
                        <tr><td colspan="7" class="py-8 text-center text-slate-400 font-mono">Loading live global trade feed...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- CORE APPLICATION SCRIPT (REAL MYSQL + FLASK LIVE SYNC)              -->
    <!-- =================================================================== -->
    <script>
        var ctxPath = '${pageContext.request.contextPath}';
        var flaskApiBase = 'http://127.0.0.1:5000';

        function formatINR(num, decimals) {
            var d = (typeof decimals === 'number') ? decimals : 2;
            return '₹' + Number(num || 0).toLocaleString('en-IN', {
                minimumFractionDigits: d,
                maximumFractionDigits: d
            });
        }

        function formatCountdown(endMs) {
            if (!endMs || endMs <= 0) return 'Live Event';
            var diffSec = Math.max(0, Math.floor((endMs - Date.now()) / 1000));
            if (diffSec <= 0) return 'Closing Soon';
            var d = Math.floor(diffSec / 86400);
            var h = Math.floor((diffSec % 86400) / 3600);
            var m = Math.floor((diffSec % 3600) / 60);
            var s = diffSec % 60;
            var pad = function(n) { return String(n).padStart(2, '0'); };
            return d > 0 ? (d + 'd ' + pad(h) + 'h ' + pad(m) + 'm ' + pad(s) + 's') : (pad(h) + 'h ' + pad(m) + 'm ' + pad(s) + 's');
        }

        function escHtml(str) {
            return String(str || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        // State populated from live backend & Flask
        let liveForecasts = [];
        let liveProposals = [];
        let liveUpdatedAt = '';
        let triggerFilter = 'all';
        let floorFilter = 'all';
        let primaryChart = null;
        let invChart = null;

        let liveAuctions = [
            <c:forEach var="auction" items="${featuredAuctions}" varStatus="st">
            {
                id: ${auction.id},
                productName: '<c:out value="${auction.productName}" />',
                category: '<c:out value="${empty auction.category ? \'Strategic Sourcing\' : auction.category}" />',
                unit: '<c:out value="${empty auction.unit ? \'units\' : auction.unit}" />',
                requiredQuantity: ${auction.requiredQuantity},
                startPrice: ${auction.startPrice},
                currentPrice: ${auction.currentPrice},
                savingsPct: ${auction.savingsPct},
                bidCount: ${auction.bidCount},
                endTimeMs: ${not empty auction.endTime ? auction.endTime.time : 0}
            }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
        ];

        // 1. FETCH LIVE TRADE FEED FROM FLASK (1D-ResNet + BACI Countries)
        function loadLiveTradeFeed() {
            fetch(flaskApiBase + '/api/inventory-surge-check')
                .then(res => res.json())
                .then(data => {
                    liveForecasts = Array.isArray(data.all_forecasts) ? data.all_forecasts : [];
                    liveProposals = Array.isArray(data.proposals) ? data.proposals : [];
                    liveUpdatedAt = data.live_updated_at || 'Live';

                    const urgBadge = document.getElementById('kpiUrgentSurgeBadge');
                    if (urgBadge) {
                        const surgeCnt = liveProposals.filter(p => (p.pct_num || 0) > 0).length;
                        urgBadge.textContent = surgeCnt + ' Live Surges';
                    }
                    const updEl = document.getElementById('tradeMatrixUpdated');
                    if (updEl) updEl.textContent = 'Updated: ' + liveUpdatedAt + ' (' + liveForecasts.length + ' SKUs)';

                    renderSpotTicker();
                    renderSourcingTriggers();
                    renderAiCockpitSuggestions();
                    renderTradeMatrixTable();
                })
                .catch(function() {
                    const tbody = document.getElementById('sourcingTriggersBody');
                    if (tbody && liveForecasts.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="6" class="py-8 text-center text-slate-400">Trade Engine warming up — <a href="' + ctxPath + '/inventory" class="text-[#0D9488] underline font-semibold">View Inventory Alerts</a></td></tr>';
                    }
                });
        }

        function renderSpotTicker() {
            const track = document.getElementById('baciTickerTrack');
            if (!track || liveForecasts.length === 0) return;
            const items = liveForecasts.slice(0, 12);
            const build = () => items.map(item => {
                const pct = Number(item.pct_num || 0);
                let badge = 'bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border-emerald-500/25';
                if (pct > 0) badge = 'bg-rose-500/15 text-rose-600 dark:text-rose-300 border-rose-500/30';
                else if (pct === 0) badge = 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 border-slate-200 dark:border-slate-700';

                return '<div class="inline-flex items-center gap-2 px-4 border-r border-slate-200 dark:border-slate-800 text-xs whitespace-nowrap">' +
                    '<span class="font-bold text-slate-800 dark:text-white">' + escHtml(item.item_name) + '</span>' +
                    '<span class="font-mono text-[10px] text-slate-400">HSN ' + escHtml(item.hsn_code) + '</span>' +
                    '<span class="font-mono font-bold tabular-nums text-[#0B1E47] dark:text-[#2DD4BF]">' + formatINR(item.spot_price_inr || item.ai_suggested_ceiling, 2) + '</span>' +
                    '<span class="px-1.5 py-0.5 rounded text-[9.5px] font-mono font-bold border ' + badge + '">' + escHtml(item.predicted_price_surge) + '</span>' +
                '</div>';
            }).join('');
            track.innerHTML = build() + build();
        }

        // 2. SOURCING TRIGGERS TABLE
        function setTriggerFilter(f) {
            triggerFilter = f;
            document.querySelectorAll('.tr-pill').forEach(btn => {
                const active = btn.getAttribute('data-tr') === f;
                btn.className = active
                    ? 'tr-pill px-3 py-1.5 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm transition-all'
                    : 'tr-pill px-3 py-1.5 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all';
            });
            renderSourcingTriggers();
        }

        function renderSourcingTriggers() {
            const tbody = document.getElementById('sourcingTriggersBody');
            if (!tbody) return;
            const list = liveProposals.filter(t => {
                if (triggerFilter === 'surge') return Number(t.pct_num || 0) > 0;
                if (triggerFilter === 'critical') return !!t.is_low;
                return true;
            }).slice(0, 6);

            if (list.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="py-8 text-center text-slate-400 font-mono">No triggers match this filter.</td></tr>';
                return;
            }

            tbody.innerHTML = list.map(t => {
                const stock = Number(t.current_stock || 0);
                const minStock = Math.max(1, Number(t.min_threshold || 50));
                const pctBar = Math.min(100, Math.round((stock / minStock) * 100));
                const pctNum = Number(t.pct_num || 0);
                const fcBadge = pctNum > 0
                    ? 'bg-rose-500/15 text-rose-600 dark:text-rose-300 border-rose-500/30'
                    : 'bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border-emerald-500/30';

                return '<tr class="hover:bg-slate-50/90 dark:hover:bg-slate-800/40 transition-colors">' +
                    '<td class="py-3.5 px-5 whitespace-nowrap">' +
                        '<div class="font-bold text-slate-900 dark:text-white">' + escHtml(t.item_name) + '</div>' +
                        '<div class="text-[10.5px] font-mono text-slate-400">HSN ' + escHtml(t.hsn_code) + ' • ' + escHtml(t.category || 'Industrial') + '</div>' +
                    '</td>' +
                    '<td class="py-3.5 px-4 whitespace-nowrap">' +
                        '<div class="flex items-center gap-2">' +
                            '<span class="font-mono font-bold tabular-nums ' + (t.is_low ? 'text-rose-600 dark:text-rose-400' : 'text-slate-700 dark:text-slate-200') + '">' + stock + ' / ' + minStock + ' min</span>' +
                            (t.is_low ? '<span class="px-1.5 py-0.5 rounded text-[9.5px] font-bold bg-rose-500/15 text-rose-600 dark:text-rose-300">Low Stock</span>' : '') +
                        '</div>' +
                        '<div class="w-28 h-1.5 rounded-full bg-slate-200 dark:bg-slate-700 mt-1 overflow-hidden">' +
                            '<div class="h-full rounded-full ' + (t.is_low ? 'bg-rose-500' : 'bg-emerald-500') + '" style="width:' + pctBar + '%"></div>' +
                        '</div>' +
                    '</td>' +
                    '<td class="py-3.5 px-4 whitespace-nowrap">' +
                        '<span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold border ' + fcBadge + '">' + escHtml(t.predicted_price_surge) + ' ' + escHtml(t.trend) + '</span>' +
                    '</td>' +
                    '<td class="py-3.5 px-4 text-right font-mono tabular-nums font-bold text-slate-900 dark:text-white whitespace-nowrap">' +
                        formatINR(t.ai_suggested_ceiling, 2) +
                    '</td>' +
                    '<td class="py-3.5 px-4 whitespace-nowrap text-[11px] text-slate-600 dark:text-slate-300">' +
                        '<span class="font-semibold">' + escHtml(t.exporting_countries || 'Global') + '</span> → <span class="text-[#0D9488] dark:text-[#2DD4BF] font-bold">' + escHtml(t.importing_country || 'India') + '</span>' +
                    '</td>' +
                    '<td class="py-3.5 px-5 text-right whitespace-nowrap">' +
                        '<a href="' + ctxPath + '/inventory" class="px-3.5 py-1.5 rounded-xl text-xs font-extrabold bg-gradient-to-r from-[#F59E0B] to-amber-400 hover:opacity-95 text-slate-950 shadow-sm transition-all inline-block no-underline">Launch Auction →</a>' +
                    '</td>' +
                '</tr>';
            }).join('');
        }

        // 3. REAL CHARTS FROM /api/dashboard/*
        function loadDashboardCharts() {
            const isDark = document.documentElement.classList.contains('dark');
            const gridColor = isDark ? 'rgba(148, 163, 184, 0.12)' : 'rgba(148, 163, 184, 0.20)';
            const tickColor = isDark ? '#94A3B8' : '#64748B';

            // Primary Chart: Auctions Over Time
            fetch(ctxPath + '/api/dashboard/auctions-over-time')
                .then(res => res.json())
                .then(data => {
                    const canvas = document.getElementById('primaryCalibrationChart');
                    if (!canvas) return;
                    const ctx = canvas.getContext('2d');
                    if (primaryChart) primaryChart.destroy();
                    const grad = ctx.createLinearGradient(0, 0, 0, 260);
                    grad.addColorStop(0, 'rgba(13, 148, 136, 0.28)');
                    grad.addColorStop(1, 'rgba(13, 148, 136, 0.00)');

                    primaryChart = new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: data.labels || [],
                            datasets: [
                                {
                                    label: 'Realized Savings (₹)',
                                    data: data.savings || [],
                                    yAxisID: 'ySavings',
                                    borderColor: '#0D9488',
                                    backgroundColor: grad,
                                    borderWidth: 2.5,
                                    fill: true,
                                    tension: 0.35,
                                    pointRadius: 4,
                                    pointBackgroundColor: isDark ? '#0B1120' : '#FFFFFF',
                                    pointBorderColor: '#0D9488'
                                },
                                {
                                    label: 'Auction Lots',
                                    data: data.values || [],
                                    yAxisID: 'yLots',
                                    type: 'bar',
                                    backgroundColor: isDark ? 'rgba(45, 212, 191, 0.28)' : 'rgba(11, 30, 71, 0.16)',
                                    borderColor: isDark ? '#2DD4BF' : '#0B1E47',
                                    borderWidth: 1.5,
                                    borderRadius: 6,
                                    barPercentage: 0.45
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            interaction: { mode: 'index', intersect: false },
                            plugins: {
                                legend: { position: 'top', align: 'end', labels: { color: tickColor, boxWidth: 10, font: { family: 'Inter', size: 11, weight: '600' } } }
                            },
                            scales: {
                                x: { grid: { display: false }, ticks: { color: tickColor, font: { family: 'JetBrains Mono', size: 10 } } },
                                ySavings: { position: 'left', grid: { color: gridColor, drawBorder: false }, ticks: { color: tickColor, font: { family: 'JetBrains Mono', size: 10 }, callback: v => '₹' + Math.round(v / 1000) + 'k' } },
                                yLots: { position: 'right', grid: { display: false }, ticks: { color: tickColor, font: { family: 'JetBrains Mono', size: 10 }, precision: 0 } }
                            }
                        }
                    });
                })
                .catch(function() {});

            // Inventory Kanban Status Doughnut
            fetch(ctxPath + '/api/dashboard/inventory-status')
                .then(res => res.json())
                .then(data => {
                    const labels = data.labels || ['Low', 'Medium', 'High'];
                    const values = data.values || [0, 0, 0];
                    const total = values.reduce((a, b) => a + Number(b || 0), 0);
                    document.getElementById('invTotalLabel').textContent = total + ' Total SKUs';
                    labels.forEach((lbl, idx) => {
                        const l = String(lbl).toLowerCase();
                        if (l.includes('low')) document.getElementById('invLowCount').textContent = values[idx];
                        else if (l.includes('med')) document.getElementById('invMedCount').textContent = values[idx];
                        else if (l.includes('high') || l.includes('opt')) document.getElementById('invHighCount').textContent = values[idx];
                    });

                    const canvas = document.getElementById('inventoryHealthChart');
                    if (!canvas) return;
                    if (invChart) invChart.destroy();
                    invChart = new Chart(canvas.getContext('2d'), {
                        type: 'doughnut',
                        data: {
                            labels: labels,
                            datasets: [{
                                data: values,
                                backgroundColor: ['#F43F5E', '#F59E0B', '#10B981'],
                                borderWidth: 0
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '66%',
                            plugins: {
                                legend: { position: 'bottom', labels: { color: tickColor, usePointStyle: true, padding: 14, font: { family: 'Inter', size: 11 } } }
                            }
                        }
                    });
                })
                .catch(function() {});

            // Category Spend Allocation
            fetch(ctxPath + '/api/dashboard/spend-by-category')
                .then(res => res.json())
                .then(data => {
                    const container = document.getElementById('categoryLiquidityList');
                    if (!container) return;
                    const labels = data.labels || [];
                    const values = data.values || [];
                    if (labels.length === 0) {
                        container.innerHTML = '<div class="text-xs text-slate-400 text-center py-6">No spend records yet.</div>';
                        return;
                    }
                    const total = Math.max(1, values.reduce((a, b) => a + Number(b || 0), 0));
                    const colors = ['bg-[#0B1E47] dark:bg-cyan-400', 'bg-[#0D9488]', 'bg-blue-600', 'bg-amber-500', 'bg-rose-500'];
                    container.innerHTML = labels.slice(0, 5).map((name, idx) => {
                        const val = Number(values[idx] || 0);
                        const share = Math.max(4, Math.round((val / total) * 100));
                        return '<div class="space-y-1.5">' +
                            '<div class="flex items-center justify-between text-xs">' +
                                '<span class="font-bold text-slate-800 dark:text-slate-100 truncate">' + escHtml(name) + '</span>' +
                                '<span class="font-mono font-bold tabular-nums text-slate-900 dark:text-white">' + formatINR(val, 0) + '</span>' +
                            '</div>' +
                            '<div class="w-full h-2 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">' +
                                '<div class="h-full rounded-full ' + colors[idx % colors.length] + '" style="width:' + share + '%"></div>' +
                            '</div>' +
                        '</div>';
                    }).join('');
                })
                .catch(function() {});

            // Top Supplier Performance
            fetch(ctxPath + '/api/dashboard/supplier-performance')
                .then(res => res.json())
                .then(data => {
                    const container = document.getElementById('supplierMatrixList');
                    if (!container) return;
                    const labels = data.labels || [];
                    const values = data.values || [];
                    if (labels.length === 0) {
                        container.innerHTML = '<div class="text-xs text-slate-400 text-center py-6">No supplier awards recorded yet.</div>';
                        return;
                    }
                    container.innerHTML = labels.slice(0, 5).map((name, idx) => {
                        return '<div class="px-5 py-3 flex items-center justify-between gap-3 hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">' +
                            '<div class="flex items-center gap-3 min-w-0">' +
                                '<span class="w-6 h-6 rounded-lg font-mono text-[11px] font-extrabold flex items-center justify-center shrink-0 ' + (idx === 0 ? 'bg-amber-400 text-slate-950' : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300') + '">#' + (idx + 1) + '</span>' +
                                '<div class="min-w-0">' +
                                    '<div class="text-xs font-bold text-slate-900 dark:text-white truncate">' + escHtml(name) + '</div>' +
                                    '<div class="text-[10.5px] font-mono text-slate-500 dark:text-slate-400">Verified Tier-1 Vendor</div>' +
                                '</div>' +
                            '</div>' +
                            '<span class="px-2 py-0.5 rounded-md text-[10.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/25 shrink-0 tabular-nums">' + values[idx] + ' Awards</span>' +
                        '</div>';
                    }).join('');
                })
                .catch(function() {});
        }

        // 4. LIVE REVERSE AUCTION FLOOR TABLE
        function renderFloorFilterTabs() {
            const total = liveAuctions.length;
            const needs = liveAuctions.filter(l => Number(l.bidCount || 0) === 0).length;
            const active = total - needs;
            const defs = [
                { key: 'all', label: 'All Live (' + total + ')' },
                { key: 'needs', label: 'Needs Bidders (' + needs + ')' },
                { key: 'active', label: 'Active Bidding (' + active + ')' }
            ];
            document.getElementById('floorFilterTabs').innerHTML = defs.map(d => {
                const isAct = floorFilter === d.key;
                return '<button type="button" onclick="setFloorFilter(\'' + d.key + '\')" class="px-3 py-1 rounded-lg transition-all ' + (isAct ? 'bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm font-bold' : 'text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white') + '">' + d.label + '</button>';
            }).join('');
        }

        function setFloorFilter(key) {
            floorFilter = key;
            renderFloorFilterTabs();
            renderLiveFloorTable();
        }

        function renderLiveFloorTable() {
            renderFloorFilterTabs();
            const tbody = document.getElementById('liveFloorTableBody');
            if (!tbody) return;
            const list = liveAuctions.filter(l => {
                const bc = Number(l.bidCount || 0);
                if (floorFilter === 'needs') return bc === 0;
                if (floorFilter === 'active') return bc > 0;
                return true;
            });

            if (list.length === 0) {
                tbody.innerHTML = '<tr><td colspan="9" class="py-10 text-center text-xs text-slate-400">No active reverse auctions right now. <a href="' + ctxPath + '/auction" class="text-[#0D9488] underline font-semibold">Create a new auction →</a></td></tr>';
                return;
            }

            tbody.innerHTML = list.map(lot => {
                const bc = Number(lot.bidCount || 0);
                const savingsAmt = Number(lot.startPrice || 0) - Number(lot.currentPrice || 0);
                const savingsPct = Number(lot.savingsPct || 0);
                const savingsDisplay = savingsAmt <= 0
                    ? '<span class="px-2 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-slate-500 font-mono text-[10.5px]">Baseline (0%)</span>'
                    : '<span class="font-mono font-bold text-emerald-600 dark:text-emerald-400">-' + savingsPct.toFixed(1) + '%</span>';

                let compBadge = '<span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-teal-500/15 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-500/30">Healthy Competition</span>';
                if (bc === 0) compBadge = '<span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-rose-500/15 text-rose-600 dark:text-rose-300 border border-rose-500/30">0 Bids — Invite Vendors</span>';
                else if (bc >= 5) compBadge = '<span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">High Velocity</span>';

                return '<tr class="hover:bg-slate-50/90 dark:hover:bg-slate-800/40 transition-colors">' +
                    '<td class="py-3.5 px-5 whitespace-nowrap"><div class="font-bold text-slate-900 dark:text-white">' + escHtml(lot.productName) + '</div><div class="text-[10.5px] font-mono text-slate-400">#' + lot.id + ' — ' + escHtml(lot.category) + '</div></td>' +
                    '<td class="py-3.5 px-4 font-mono tabular-nums font-semibold text-slate-700 dark:text-slate-200 whitespace-nowrap">' + lot.requiredQuantity + ' ' + escHtml(lot.unit) + '</td>' +
                    '<td class="py-3.5 px-4 text-right font-mono tabular-nums text-slate-500 dark:text-slate-400 whitespace-nowrap">' + formatINR(lot.startPrice, 2) + '</td>' +
                    '<td class="py-3.5 px-4 text-right font-mono tabular-nums font-extrabold text-slate-900 dark:text-white whitespace-nowrap">' + formatINR(lot.currentPrice, 2) + '</td>' +
                    '<td class="py-3.5 px-4 text-right whitespace-nowrap">' + savingsDisplay + '</td>' +
                    '<td class="py-3.5 px-4 text-center font-mono font-bold text-slate-700 dark:text-slate-200 whitespace-nowrap">' + bc + ' Bids</td>' +
                    '<td class="py-3.5 px-4 whitespace-nowrap">' + compBadge + '</td>' +
                    '<td class="py-3.5 px-4 font-mono tabular-nums font-bold text-amber-600 dark:text-amber-400 whitespace-nowrap floor-live-timer" data-endms="' + (lot.endTimeMs || 0) + '">' + formatCountdown(lot.endTimeMs) + '</td>' +
                    '<td class="py-3.5 px-5 text-right whitespace-nowrap"><a href="' + ctxPath + '/auction" class="px-3 py-1.5 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] hover:opacity-90 text-white shadow-sm transition-all inline-block no-underline">Enter Floor →</a></td>' +
                '</tr>';
            }).join('');
        }

        function tickAllCountdowns() {
            document.querySelectorAll('.floor-live-timer').forEach(el => {
                el.textContent = formatCountdown(Number(el.getAttribute('data-endms') || 0));
            });
        }

        function syncLiveAuctions() {
            fetch(ctxPath + '/home?action=liveJson', { cache: 'no-store' })
                .then(res => res.json())
                .then(data => {
                    if (Array.isArray(data.auctions)) {
                        liveAuctions = data.auctions;
                        renderLiveFloorTable();
                        const zeroCnt = liveAuctions.filter(l => Number(l.bidCount || 0) === 0).length;
                        const chip = document.getElementById('kpiZeroBidChip');
                        if (chip) {
                            chip.textContent = zeroCnt > 0 ? (zeroCnt + ' lot needs bidders') : 'All lots active ✓';
                        }
                    }
                })
                .catch(function() {});
        }

        // 5. AI PROCUREMENT COCKPIT (REAL SUGGESTIONS FROM APP)
        function openAiCockpitDrawer() {
            renderAiCockpitSuggestions();
            document.getElementById('aiCockpitOverlay').classList.remove('hidden');
            document.getElementById('aiCockpitDrawer').classList.remove('translate-x-full');
        }
        function closeAiCockpitDrawer() {
            document.getElementById('aiCockpitDrawer').classList.add('translate-x-full');
            document.getElementById('aiCockpitOverlay').classList.add('hidden');
        }

        function renderAiCockpitSuggestions() {
            const box = document.getElementById('aiCockpitSuggestionsList');
            if (!box) return;
            const cards = [];

            liveAuctions.filter(l => Number(l.bidCount || 0) === 0).forEach(lot => {
                cards.push(
                    '<div class="p-4 rounded-2xl bg-teal-50/70 dark:bg-teal-950/30 border border-teal-200 dark:border-teal-800/60 space-y-2">' +
                        '<div class="flex items-center justify-between">' +
                            '<span class="font-bold text-sm text-slate-900 dark:text-white">Lot #' + lot.id + ' • ' + escHtml(lot.productName) + '</span>' +
                            '<span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/20 text-amber-700 dark:text-amber-300">0 BIDS</span>' +
                        '</div>' +
                        '<p class="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">Active reverse auction (' + lot.requiredQuantity + ' ' + escHtml(lot.unit) + ') currently has 0 supplier bids. Invite Tier-1 vendors to drive L1 compression below ' + formatINR(lot.startPrice, 2) + '.</p>' +
                        '<a href="' + ctxPath + '/auction" class="inline-block text-xs font-bold text-[#0D9488] dark:text-[#2DD4BF] hover:underline">Manage Lot #' + lot.id + ' on Auction Floor →</a>' +
                    '</div>'
                );
            });

            liveProposals.slice(0, 5).forEach(p => {
                const isSurge = Number(p.pct_num || 0) > 0;
                const cardCls = isSurge ? 'bg-rose-50/70 dark:bg-rose-950/30 border-rose-200 dark:border-rose-800/60' : 'bg-amber-50/70 dark:bg-amber-950/30 border-amber-200 dark:border-amber-800/60';
                const badgeCls = isSurge ? 'bg-rose-500/20 text-rose-700 dark:text-rose-300' : 'bg-emerald-500/20 text-emerald-700 dark:text-emerald-300';
                cards.push(
                    '<div class="p-4 rounded-2xl border ' + cardCls + ' space-y-2.5">' +
                        '<div class="flex items-center justify-between">' +
                            '<span class="font-bold text-sm text-slate-900 dark:text-white">' + escHtml(p.item_name) + '</span>' +
                            '<span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold ' + badgeCls + '">' + escHtml(p.predicted_price_surge) + ' ' + escHtml(p.trend) + '</span>' +
                        '</div>' +
                        '<p class="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">' + escHtml(p.action_reason || ('HSN ' + p.hsn_code + ' • Stock ' + p.current_stock + '/' + p.min_threshold)) + '</p>' +
                        '<div class="flex items-center justify-between text-[11px] font-mono text-slate-500 dark:text-slate-400">' +
                            '<span>AI Ceiling: <strong class="text-slate-900 dark:text-white">' + formatINR(p.ai_suggested_ceiling, 2) + '</strong></span>' +
                            '<span>' + escHtml(p.exporting_countries || '') + ' → ' + escHtml(p.importing_country || 'India') + '</span>' +
                        '</div>' +
                        '<a href="' + ctxPath + '/inventory" class="block w-full text-center py-2 rounded-xl bg-[#F59E0B] hover:bg-amber-400 text-slate-950 font-extrabold text-xs shadow-sm transition-all no-underline">Launch Reverse Auction in Inventory →</a>' +
                    '</div>'
                );
            });

            if (cards.length === 0) {
                box.innerHTML = '<div class="text-xs text-slate-400 text-center py-8">All inventory levels and auctions are healthy.</div>';
            } else {
                box.innerHTML = cards.join('');
            }
        }

        // 6. GLOBAL TRADE MATRIX MODAL (LIVE FEED + EXPORTING/IMPORTING COUNTRIES)
        function openModal(id) {
            const el = document.getElementById(id);
            if (!el) return;
            el.classList.remove('hidden');
            el.classList.add('flex');
        }
        function closeModal(id) {
            const el = document.getElementById(id);
            if (!el) return;
            el.classList.add('hidden');
            el.classList.remove('flex');
        }
        function openTradeMatrixModal() {
            renderTradeMatrixTable();
            openModal('tradeMatrixModal');
        }

        function renderTradeMatrixTable() {
            const tbody = document.getElementById('tradeMatrixBody');
            if (!tbody) return;
            if (liveForecasts.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" class="py-8 text-center text-slate-400 font-mono">Loading live global trade feed...</td></tr>';
                return;
            }
            const q = (document.getElementById('tradeMatrixSearch').value || '').trim().toLowerCase();
            const list = liveForecasts.filter(c =>
                !q ||
                String(c.item_name || '').toLowerCase().includes(q) ||
                String(c.hsn_code || '').toLowerCase().includes(q) ||
                String(c.exporting_countries || '').toLowerCase().includes(q) ||
                String(c.importing_country || '').toLowerCase().includes(q)
            );
            tbody.innerHTML = list.map(c => {
                const pct = Number(c.pct_num || 0);
                const badge = pct > 0
                    ? 'bg-rose-500/15 text-rose-600 dark:text-rose-300'
                    : (pct < 0 ? 'bg-emerald-500/15 text-emerald-700 dark:text-emerald-300' : 'bg-amber-500/15 text-amber-700 dark:text-amber-300');
                return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">' +
                    '<td class="py-3 px-4 font-bold text-slate-900 dark:text-white">' + escHtml(c.item_name) + '<span class="block text-[10px] font-normal text-slate-400">' + escHtml(c.category || '') + '</span></td>' +
                    '<td class="py-3 px-4 font-mono text-slate-500 dark:text-slate-400">' + escHtml(c.hsn_code) + '</td>' +
                    '<td class="py-3 px-4 text-right font-mono font-bold text-slate-900 dark:text-white tabular-nums">' + formatINR(c.spot_price_inr || c.ai_suggested_ceiling, 2) + '</td>' +
                    '<td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold ' + badge + '">' + escHtml(c.predicted_price_surge) + ' ' + escHtml(c.trend) + '</span></td>' +
                    '<td class="py-3 px-4 text-slate-700 dark:text-slate-200 font-medium">' + escHtml(c.exporting_countries || 'Germany, USA, China') + '</td>' +
                    '<td class="py-3 px-4"><span class="px-2 py-0.5 rounded-md text-[10.5px] font-bold bg-teal-50 dark:bg-teal-950/50 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200 dark:border-teal-800">' + escHtml(c.importing_country || 'India') + '</span></td>' +
                    '<td class="py-3 px-4 text-right"><a href="' + ctxPath + '/inventory" class="text-[11px] font-bold text-[#0D9488] dark:text-[#2DD4BF] hover:underline">Auction →</a></td>' +
                '</tr>';
            }).join('');
        }

        // Re-render charts when Dark Mode toggles from Settings or elsewhere
        window.addEventListener('storage', function(e) {
            if (e.key === 'sp-theme') loadDashboardCharts();
        });

        window.addEventListener('DOMContentLoaded', function () {
            renderLiveFloorTable();
            loadDashboardCharts();
            loadLiveTradeFeed();
            setInterval(tickAllCountdowns, 1000);
            setInterval(syncLiveAuctions, 12000);
        });
    </script>
</body>
</html>
