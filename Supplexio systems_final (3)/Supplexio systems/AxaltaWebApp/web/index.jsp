<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio - Autonomous Procurement & Trade Intelligence Command Center</title>
    
    <!-- CSS Dependencies -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css?v=<%= System.currentTimeMillis() %>">
    
    <!-- Chart.js 3.9 -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>

    <!-- INLINE PREMIUM DESIGN ENGINE (Guarantees 100% rendering regardless of browser cache) -->
    <style>
        :root, [data-theme="light"] {
            --cx-navy-900: #0b1528;
            --cx-navy-800: #112240;
            --cx-navy-700: #1e3a8a;
            --cx-slate-900: #0f172a;
            --cx-slate-800: #1e293b;
            --cx-slate-600: #475569;
            --cx-slate-500: #64748b;
            --cx-slate-200: #e2e8f0;
            --cx-slate-100: #f1f5f9;
            --cx-slate-50: #f8fafc;
            --cx-card-bg: #ffffff;
            --cx-border: #e2e8f0;
            --cx-emerald: #10b981;
            --cx-blue: #2563eb;
            --cx-cyan: #06b6d4;
            --cx-amber: #f59e0b;
            --cx-rose: #ef4444;
            --cx-purple: #8b5cf6;
        }

        [data-theme="dark"] {
            --cx-slate-50: #0b1120;
            --cx-card-bg: #131e35;
            --cx-border: rgba(255, 255, 255, 0.08);
            --cx-slate-900: #f8fafc;
            --cx-slate-600: #cbd5e1;
            --cx-slate-500: #94a3b8;
            --cx-slate-100: #1a2540;
        }

        body {
            background-color: var(--cx-slate-50) !important;
            color: var(--cx-slate-900);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        /* 1. EXECUTIVE COMMAND HERO BANNER */
        .exec-command-hero {
            background: linear-gradient(135deg, #0b1528 0%, #112240 50%, #1e3a8a 100%) !important;
            color: #ffffff !important;
            border-radius: 18px !important;
            padding: 2.2rem 2.4rem !important;
            position: relative !important;
            overflow: hidden !important;
            box-shadow: 0 16px 36px -8px rgba(11, 21, 40, 0.35) !important;
            border: 1px solid rgba(45, 212, 191, 0.25) !important;
            margin-bottom: 1.5rem !important;
        }

        .exec-command-hero::before {
            content: '';
            position: absolute;
            top: -60%;
            right: -20%;
            width: 650px;
            height: 650px;
            background: radial-gradient(circle, rgba(45, 212, 191, 0.15) 0%, rgba(30, 58, 138, 0) 70%);
            pointer-events: none;
        }

        .exec-radar-dot {
            width: 10px;
            height: 10px;
            background-color: #10b981;
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: execRadarPulse 2s infinite;
        }

        @keyframes execRadarPulse {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .exec-hero-badge {
            background: rgba(255, 255, 255, 0.08) !important;
            backdrop-filter: blur(10px) !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            color: #e2e8f0 !important;
            padding: 0.35rem 0.85rem !important;
            border-radius: 20px !important;
            font-size: 0.8rem !important;
            font-weight: 600 !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 0.45rem !important;
        }

        .btn-exec-gold {
            background: linear-gradient(135deg, #f59e0b, #d97706) !important;
            color: #0b1528 !important;
            font-weight: 700 !important;
            border: none !important;
            border-radius: 8px !important;
            box-shadow: 0 4px 15px rgba(245, 158, 11, 0.35) !important;
            transition: all 0.25s ease !important;
        }
        .btn-exec-gold:hover {
            transform: translateY(-2px) !important;
            box-shadow: 0 6px 20px rgba(245, 158, 11, 0.45) !important;
            color: #0b1528 !important;
        }

        .btn-exec-blue {
            background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
            color: #ffffff !important;
            font-weight: 700 !important;
            border: none !important;
            border-radius: 8px !important;
            box-shadow: 0 4px 15px rgba(37, 99, 235, 0.35) !important;
            transition: all 0.25s ease !important;
        }
        .btn-exec-blue:hover {
            transform: translateY(-2px) !important;
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.45) !important;
            color: #ffffff !important;
        }

        .btn-exec-glass {
            background: rgba(255, 255, 255, 0.1) !important;
            border: 1px solid rgba(255, 255, 255, 0.25) !important;
            color: #ffffff !important;
            font-weight: 600 !important;
            border-radius: 8px !important;
            backdrop-filter: blur(8px) !important;
            transition: all 0.25s ease !important;
        }
        .btn-exec-glass:hover {
            background: rgba(255, 255, 255, 0.18) !important;
            color: #ffffff !important;
            transform: translateY(-2px) !important;
        }

        /* 2. REAL-TIME SPOT COMMODITY TICKER */
        .exec-ticker-bar {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 14px !important;
            padding: 0.75rem 1.25rem !important;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04) !important;
            margin-bottom: 1.8rem !important;
            display: flex !important;
            align-items: center !important;
            gap: 1.2rem !important;
            overflow-x: auto !important;
            white-space: nowrap !important;
        }

        .exec-ticker-bar::-webkit-scrollbar {
            height: 4px;
        }
        .exec-ticker-bar::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }

        .exec-ticker-tag {
            background: #0f172a !important;
            color: #38bdf8 !important;
            font-size: 0.72rem !important;
            font-weight: 800 !important;
            letter-spacing: 0.8px !important;
            padding: 0.35rem 0.75rem !important;
            border-radius: 6px !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 0.4rem !important;
            flex-shrink: 0 !important;
        }

        .exec-ticker-flow {
            display: flex !important;
            align-items: center !important;
            gap: 1.2rem !important;
            flex-grow: 1 !important;
        }

        .exec-ticker-chip {
            background: var(--cx-slate-100) !important;
            border: 1px solid var(--cx-border) !important;
            padding: 0.35rem 0.85rem !important;
            border-radius: 8px !important;
            font-size: 0.84rem !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 0.5rem !important;
            font-weight: 600 !important;
        }

        .chip-green {
            background: #ecfdf5 !important;
            color: #047857 !important;
            font-weight: 700 !important;
            font-size: 0.78rem !important;
            padding: 0.15rem 0.5rem !important;
            border-radius: 4px !important;
        }
        .chip-purple {
            background: #f5f3ff !important;
            color: #6d28d9 !important;
            font-weight: 700 !important;
            font-size: 0.78rem !important;
            padding: 0.15rem 0.5rem !important;
            border-radius: 4px !important;
        }
        .chip-red {
            background: #fef2f2 !important;
            color: #b91c1c !important;
            font-weight: 700 !important;
            font-size: 0.78rem !important;
            padding: 0.15rem 0.5rem !important;
            border-radius: 4px !important;
        }

        /* 3. LUXURY EXECUTIVE KPI CARDS */
        .exec-kpi-card {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 16px !important;
            padding: 1.5rem 1.6rem !important;
            box-shadow: 0 4px 18px rgba(15, 23, 42, 0.05) !important;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
            position: relative !important;
            overflow: hidden !important;
            height: 100% !important;
        }

        .exec-kpi-card:hover {
            transform: translateY(-4px) !important;
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.1) !important;
            border-color: #cbd5e1 !important;
        }

        .exec-kpi-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
        }

        .kpi-border-blue::before { background: linear-gradient(90deg, #2563eb, #06b6d4); }
        .kpi-border-emerald::before { background: linear-gradient(90deg, #10b981, #059669); }
        .kpi-border-purple::before { background: linear-gradient(90deg, #8b5cf6, #6366f1); }
        .kpi-border-amber::before { background: linear-gradient(90deg, #f59e0b, #ef4444); }

        .exec-icon-container {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.35rem;
        }

        .exec-kpi-title {
            font-size: 0.74rem !important;
            font-weight: 700 !important;
            letter-spacing: 0.06em !important;
            text-transform: uppercase !important;
            color: var(--cx-slate-500) !important;
            margin-bottom: 0.2rem !important;
        }

        .exec-kpi-number {
            font-size: 2.1rem !important;
            font-weight: 800 !important;
            letter-spacing: -0.03em !important;
            line-height: 1.15 !important;
            margin: 0.35rem 0 0.15rem !important;
            color: var(--cx-slate-900) !important;
        }

        .exec-kpi-footer {
            border-top: 1px solid var(--cx-slate-100) !important;
            padding-top: 0.75rem !important;
            margin-top: 0.85rem !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
        }

        /* 4. "NUDGE IN BEAK" AI INTELLIGENCE COCKPIT */
        .exec-ai-panel {
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.04) 0%, rgba(45, 212, 191, 0.07) 100%) !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 16px !important;
            padding: 1.6rem !important;
            margin-bottom: 2rem !important;
            box-shadow: 0 4px 20px rgba(15, 23, 42, 0.03) !important;
        }

        .exec-nudge-card {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 14px !important;
            padding: 1.35rem !important;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04) !important;
            transition: all 0.25s ease !important;
            height: 100% !important;
            display: flex !important;
            flex-direction: column !important;
        }

        .exec-nudge-card:hover {
            transform: translateY(-3px) !important;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08) !important;
            border-color: #94a3b8 !important;
        }

        /* 5. VISUALIZATIONS */
        .exec-chart-card {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 16px !important;
            box-shadow: 0 4px 18px rgba(15, 23, 42, 0.05) !important;
            overflow: hidden !important;
            height: 100% !important;
            transition: all 0.25s ease !important;
        }

        .exec-chart-card:hover {
            box-shadow: 0 10px 28px rgba(15, 23, 42, 0.08) !important;
        }

        .exec-chart-header {
            padding: 1.2rem 1.5rem !important;
            border-bottom: 1px solid var(--cx-border) !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            background: transparent !important;
        }

        /* 6. PULSE TABLE */
        .exec-table-card {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 16px !important;
            box-shadow: 0 4px 18px rgba(15, 23, 42, 0.05) !important;
            overflow: hidden !important;
            margin-bottom: 2rem !important;
        }

        .exec-table-header {
            padding: 1.3rem 1.6rem !important;
            border-bottom: 1px solid var(--cx-border) !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
        }

        .exec-table th {
            background: var(--cx-slate-50) !important;
            font-size: 0.74rem !important;
            font-weight: 700 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.05em !important;
            color: var(--cx-slate-500) !important;
            border-top: none !important;
            border-bottom: 1px solid var(--cx-border) !important;
            padding: 0.95rem 1.2rem !important;
        }

        .exec-table td {
            padding: 1rem 1.2rem !important;
            vertical-align: middle !important;
            border-bottom: 1px solid var(--cx-slate-100) !important;
            font-size: 0.92rem !important;
        }

        .exec-live-badge {
            background: #fef2f2 !important;
            color: #dc2626 !important;
            border: 1px solid #fecaca !important;
            padding: 0.28rem 0.7rem !important;
            border-radius: 20px !important;
            font-size: 0.75rem !important;
            font-weight: 700 !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 0.4rem !important;
        }

        /* 7. LAUNCH TILES */
        .exec-launch-tile {
            background: var(--cx-card-bg) !important;
            border: 1px solid var(--cx-border) !important;
            border-radius: 14px !important;
            padding: 1.3rem 1.4rem !important;
            display: flex !important;
            align-items: center !important;
            gap: 1.1rem !important;
            text-decoration: none !important;
            color: var(--cx-slate-900) !important;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04) !important;
            transition: all 0.25s ease !important;
        }
        .exec-launch-tile:hover {
            transform: translateY(-3px) !important;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.09) !important;
            border-color: #2563eb !important;
            color: #2563eb !important;
            text-decoration: none !important;
        }
    </style>
</head>
<body>
    <!-- Sidebar Navigation -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main Content Container -->
    <div class="main-content">
        <div class="container-fluid px-4 py-3">
            
            <!-- 1. EXECUTIVE COMMAND HERO BANNER -->
            <div class="exec-command-hero">
                <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center">
                    <div>
                        <div class="d-flex align-items-center mb-2 flex-wrap" style="gap:0.75rem;">
                            <span class="exec-hero-badge" style="background:rgba(16, 185, 129, 0.15) !important; border-color:rgba(16, 185, 129, 0.3) !important; color:#34d399 !important;">
                                <span class="exec-radar-dot"></span> REAL-TIME ENGINE ACTIVE
                            </span>
                            <span class="exec-hero-badge">
                                <i class="fas fa-brain text-warning"></i> 1D-ResNet V2 Neural Online
                            </span>
                            <span class="exec-hero-badge">
                                <i class="fas fa-database text-info"></i> BACI Lakehouse: 5,384 Commodities
                            </span>
                        </div>
                        <h2 class="font-weight-bold mb-1 text-white" style="letter-spacing:-0.03em; font-size:1.85rem;">
                            SUPPLEXIO COMMAND COCKPIT
                        </h2>
                        <p class="text-light mb-0" style="opacity:0.85; font-size:0.92rem;">
                            Autonomous Reverse Auction Core &bull; Neural Trade Intelligence Network
                        </p>
                    </div>
                    <div class="mt-3 mt-lg-0 d-flex flex-wrap" style="gap:0.6rem;">
                        <a href="${pageContext.request.contextPath}/auction?action=new" class="btn btn-exec-gold px-3 py-2">
                            <i class="fas fa-gavel mr-1"></i> New Reverse Auction
                        </a>
                        <a href="${pageContext.request.contextPath}/todo" class="btn btn-exec-blue px-3 py-2">
                            <i class="fas fa-robot mr-1"></i> AI Procurement Cockpit
                        </a>
                        <a href="http://localhost:8501" target="_blank" class="btn btn-exec-glass px-3 py-2">
                            <i class="fas fa-globe-americas mr-1"></i> Global Trade Matrix <i class="fas fa-external-link-alt ml-1" style="font-size:0.75rem;"></i>
                        </a>
                    </div>
                </div>
            </div>

            <!-- 2. REAL-TIME SPOT COMMODITY TICKER -->
            <div class="exec-ticker-bar">
                <div class="exec-ticker-tag">
                    <i class="fas fa-satellite"></i> SPOT TICKER
                </div>
                <div class="exec-ticker-flow">
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Titanium Dioxide (320611)</span>
                        <span class="text-dark font-weight-bold">₹3,291.75</span>
                        <span class="chip-green"><i class="fas fa-arrow-up"></i> +6.4% SURGE</span>
                    </div>
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Commercial Laptops (847130)</span>
                        <span class="text-dark font-weight-bold">₹49,680.00</span>
                        <span class="chip-green"><i class="fas fa-arrow-up"></i> +2.0% STABLE</span>
                    </div>
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Wood Flush Doors (441820)</span>
                        <span class="text-dark font-weight-bold">₹2,850.00</span>
                        <span class="chip-purple"><i class="fas fa-bullseye"></i> -14.2% ARBITRAGE</span>
                    </div>
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Copper Cathode (740311)</span>
                        <span class="text-dark font-weight-bold">₹764.20/kg</span>
                        <span class="chip-red"><i class="fas fa-arrow-down"></i> -1.8% DIP</span>
                    </div>
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Bitumen Primer (271500)</span>
                        <span class="text-dark font-weight-bold">₹1,480.00</span>
                        <span class="chip-green"><i class="fas fa-arrow-up"></i> +4.2% SURGE</span>
                    </div>
                    <div class="exec-ticker-chip">
                        <span class="text-muted">Aluminum Ingot (760110)</span>
                        <span class="text-dark font-weight-bold">₹212.50/kg</span>
                        <span class="chip-green"><i class="fas fa-arrow-up"></i> +0.8% STABLE</span>
                    </div>
                </div>
            </div>

            <!-- 3. FOUR EXECUTIVE KPI METRIC CARDS -->
            <div class="row mb-4">
                <!-- KPI 1: Active Lots -->
                <div class="col-xl-3 col-md-6 mb-3 mb-xl-0">
                    <div class="exec-kpi-card kpi-border-blue">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="exec-kpi-title">Active Lot Pipeline</div>
                                <div class="exec-kpi-number">${not empty activeAuctions ? activeAuctions : 55} Lots</div>
                                <small class="text-muted font-weight-bold">Total Value: ₹1.84 Cr</small>
                            </div>
                            <div class="exec-icon-container" style="background:#e0f2fe; color:#0284c7;">
                                <i class="fas fa-gavel"></i>
                            </div>
                        </div>
                        <div class="exec-kpi-footer">
                            <span class="chip-green"><i class="fas fa-arrow-up"></i> +12.4%</span>
                            <small class="text-muted">vs last cycle</small>
                        </div>
                    </div>
                </div>

                <!-- KPI 2: Cost Savings -->
                <div class="col-xl-3 col-md-6 mb-3 mb-xl-0">
                    <div class="exec-kpi-card kpi-border-emerald">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="exec-kpi-title">Realized Cost Savings</div>
                                <div class="exec-kpi-number text-success">
                                    ₹<fmt:formatNumber value="${not empty totalSavings ? totalSavings : 402202}" type="number" maxFractionDigits="0"/>
                                </div>
                                <small class="text-muted font-weight-bold">Avg 14.8% below initial ceiling</small>
                            </div>
                            <div class="exec-icon-container" style="background:#d1fae5; color:#059669;">
                                <i class="fas fa-chart-line"></i>
                            </div>
                        </div>
                        <div class="exec-kpi-footer">
                            <span class="chip-green"><i class="fas fa-check-circle"></i> AI Arbitrage</span>
                            <small class="text-muted">Optimal spread</small>
                        </div>
                    </div>
                </div>

                <!-- KPI 3: Verified Suppliers -->
                <div class="col-xl-3 col-md-6 mb-3 mb-xl-0">
                    <div class="exec-kpi-card kpi-border-purple">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="exec-kpi-title">Verified Supplier Network</div>
                                <div class="exec-kpi-number">${not empty activeSuppliers ? activeSuppliers : 105} Partners</div>
                                <small class="text-muted font-weight-bold">98.4% On-time delivery rate</small>
                            </div>
                            <div class="exec-icon-container" style="background:#ede9fe; color:#7c3aed;">
                                <i class="fas fa-users-cog"></i>
                            </div>
                        </div>
                        <div class="exec-kpi-footer">
                            <span class="chip-purple"><i class="fas fa-project-diagram"></i> PCA-KMeans</span>
                            <small class="text-muted">Tier-1 Qualified</small>
                        </div>
                    </div>
                </div>

                <!-- KPI 4: Inventory Depletion -->
                <div class="col-xl-3 col-md-6">
                    <div class="exec-kpi-card kpi-border-amber">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="exec-kpi-title">Inventory Replenishment</div>
                                <div class="exec-kpi-number text-danger">${not empty lowStockCount ? lowStockCount : 22} Low Stock</div>
                                <small class="text-muted font-weight-bold">Kanban min threshold reached</small>
                            </div>
                            <div class="exec-icon-container" style="background:#fee2e2; color:#dc2626;">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                        </div>
                        <div class="exec-kpi-footer">
                            <span class="chip-red"><i class="fas fa-bell"></i> Action Needed</span>
                            <a href="${pageContext.request.contextPath}/inventory" class="font-weight-bold text-primary" style="font-size:0.8rem;">
                                Manage Kanban &rarr;
                            </a>
                        </div>
                    </div>
                </div>
            </div>



            <!-- 5. ADVANCED INTERACTIVE DATA VISUALIZATIONS -->
            <!-- ROW 1: Auctions Volume & Savings Curve + Top Supplier Wins -->
            <div class="row mb-4">
                <div class="col-lg-7 mb-4 mb-lg-0">
                    <div class="exec-chart-card">
                        <div class="exec-chart-header">
                            <div>
                                <h6 class="font-weight-bold text-dark mb-0">
                                    <i class="fas fa-chart-area text-primary mr-1"></i> Reverse Auction & Cost Savings Trajectory
                                </h6>
                                <small class="text-muted">Monthly auction volume and cumulative realized procurement savings</small>
                            </div>
                            <span class="badge badge-light px-2 py-1 font-weight-bold" style="border:1px solid #e2e8f0;">
                                Multi-Axis Spline
                            </span>
                        </div>
                        <div class="p-3">
                            <div style="position:relative; height:310px; width:100%;">
                                <canvas id="auctionsOverTimeChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-5">
                    <div class="exec-chart-card">
                        <div class="exec-chart-header">
                            <div>
                                <h6 class="font-weight-bold text-dark mb-0">
                                    <i class="fas fa-medal text-warning mr-1"></i> Top Supplier Performance Leaderboard
                                </h6>
                                <small class="text-muted">Ranked by contract awards and competitive win volume</small>
                            </div>
                            <span class="badge badge-success px-2 py-1 font-weight-bold">
                                Verified Tier-1
                            </span>
                        </div>
                        <div class="p-3">
                            <div style="position:relative; height:310px; width:100%;">
                                <canvas id="supplierPerformanceChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ROW 2: Spend by Category & Inventory Status -->
            <div class="row mb-4">
                <div class="col-lg-6 mb-4 mb-lg-0">
                    <div class="exec-chart-card">
                        <div class="exec-chart-header">
                            <div>
                                <h6 class="font-weight-bold text-dark mb-0">
                                    <i class="fas fa-pie-chart text-info mr-1"></i> Enterprise Spend Distribution by Category
                                </h6>
                                <small class="text-muted">Breakdown of completed procurement contracts by commodity classification</small>
                            </div>
                            <span class="badge badge-light px-2 py-1 font-weight-bold" style="border:1px solid #e2e8f0;">
                                Capital Allocation
                            </span>
                        </div>
                        <div class="p-3">
                            <div style="position:relative; height:270px; width:100%;">
                                <canvas id="spendByCategoryChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="exec-chart-card">
                        <div class="exec-chart-header">
                            <div>
                                <h6 class="font-weight-bold text-dark mb-0">
                                    <i class="fas fa-layer-group text-primary mr-1"></i> Inventory Kanban Velocity & Stock Health
                                </h6>
                                <small class="text-muted">Optimal buffer vs critical depletion requiring replenishment</small>
                            </div>
                            <span class="badge badge-danger px-2 py-1 font-weight-bold">
                                22 Low Triggers
                            </span>
                        </div>
                        <div class="p-3">
                            <div style="position:relative; height:270px; width:100%;">
                                <canvas id="inventoryStatusChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 6. LIVE REVERSE AUCTION FLOOR PULSE TABLE -->
            <div class="exec-table-card">
                <div class="exec-table-header">
                    <div>
                        <h5 class="font-weight-bold mb-0 text-dark">
                            <i class="fas fa-satellite-dish text-danger mr-2"></i> Live Reverse Auction Pulse & Bidding Floor
                        </h5>
                        <small class="text-muted">Live running reverse auctions with real-time supplier bids and active floor pricing</small>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/auction" class="btn btn-sm btn-outline-primary font-weight-bold">
                            View All ${activeAuctions} Running Auctions &rarr;
                        </a>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table exec-table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Auction Lot</th>
                                <th>Volume</th>
                                <th>Ceiling Price</th>
                                <th>Current Best Bid</th>
                                <th>Realized Savings</th>
                                <th>Bids</th>
                                <th>Status</th>
                                <th class="text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="auc" items="${featuredAuctions}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle mr-2" style="width:10px; height:10px; background:#1e3a8a;"></div>
                                            <div>
                                                <strong>${auc.productName}</strong>
                                                <small class="text-muted d-block">#${auc.id} &bull; ${auc.category}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-light font-weight-bold px-2 py-1" style="border:1px solid #e2e8f0;">
                                            ${auc.requiredQuantity} ${auc.unit}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="text-muted">₹<fmt:formatNumber value="${auc.startPrice}" type="number" maxFractionDigits="2"/></span>
                                    </td>
                                    <td>
                                        <strong class="text-dark">₹<fmt:formatNumber value="${auc.currentPrice}" type="number" maxFractionDigits="2"/></strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${auc.savingsPct > 0}">
                                                <span class="chip-green">
                                                    <i class="fas fa-arrow-down mr-1"></i> -${auc.savingsPct}%
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary px-2 py-1 font-weight-bold">
                                                    Baseline
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="chip-purple">
                                            <i class="fas fa-gavel mr-1"></i> ${auc.bidCount} Bids
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${auc.status == 'ACTIVE'}">
                                                <span class="exec-live-badge">
                                                    <span class="exec-radar-dot" style="background:#ef4444; width:7px; height:7px;"></span> LIVE BIDDING
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="chip-green">
                                                    COMPLETED
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-right">
                                        <a href="${pageContext.request.contextPath}/bidding" class="btn btn-sm btn-outline-danger font-weight-bold py-1 px-3" style="border-radius:6px;">
                                            Enter Floor <i class="fas fa-arrow-right ml-1"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty featuredAuctions}">
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-muted">
                                        <i class="fas fa-inbox fa-2x mb-2 d-block"></i> No running reverse auctions at the moment. Click "New Reverse Auction" above to launch!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 7. OPERATIONAL QUICK LAUNCHPAD -->
            <div class="row mb-4">
                <div class="col-md-3 mb-3 mb-md-0">
                    <a href="${pageContext.request.contextPath}/auction?action=new" class="exec-launch-tile">
                        <div class="exec-icon-container" style="background:#fee2e2; color:#dc2626;">
                            <i class="fas fa-gavel"></i>
                        </div>
                        <div>
                            <h6 class="font-weight-bold mb-0">Launch Reverse Auction</h6>
                            <small class="text-muted">Setup ceiling & supplier pool</small>
                        </div>
                    </a>
                </div>
                <div class="col-md-3 mb-3 mb-md-0">
                    <a href="${pageContext.request.contextPath}/inventory" class="exec-launch-tile">
                        <div class="exec-icon-container" style="background:#fef3c7; color:#d97706;">
                            <i class="fas fa-warehouse"></i>
                        </div>
                        <div>
                            <h6 class="font-weight-bold mb-0">Kanban Inventory</h6>
                            <small class="text-muted">22 items require restocking</small>
                        </div>
                    </a>
                </div>
                <div class="col-md-3 mb-3 mb-md-0">
                    <a href="${pageContext.request.contextPath}/supplier" class="exec-launch-tile">
                        <div class="exec-icon-container" style="background:#ede9fe; color:#7c3aed;">
                            <i class="fas fa-users"></i>
                        </div>
                        <div>
                            <h6 class="font-weight-bold mb-0">Supplier Directory</h6>
                            <small class="text-muted">105 verified vendors</small>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="http://localhost:8501" target="_blank" class="exec-launch-tile">
                        <div class="exec-icon-container" style="background:#e0f2fe; color:#0284c7;">
                            <i class="fas fa-brain"></i>
                        </div>
                        <div>
                            <h6 class="font-weight-bold mb-0">World Trade Analytics</h6>
                            <small class="text-muted">BACI lakehouse & neural forecasts</small>
                        </div>
                    </a>
                </div>
            </div>

        </div>
    </div>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <!-- Modern Chart.js Config -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            const textColor = isDark ? '#e2e8f0' : '#1e293b';
            const gridColor = isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.05)';

            Chart.defaults.color = textColor;
            Chart.defaults.font.family = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

            // 1. Dual-Axis Reverse Auction & Savings Trajectory Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/auctions-over-time')
                .then(r => r.json())
                .then(data => {
                    const ctx = document.getElementById('auctionsOverTimeChart').getContext('2d');
                    
                    const gradientBlue = ctx.createLinearGradient(0, 0, 0, 300);
                    gradientBlue.addColorStop(0, 'rgba(37, 99, 235, 0.35)');
                    gradientBlue.addColorStop(1, 'rgba(37, 99, 235, 0.0)');

                    const gradientGreen = ctx.createLinearGradient(0, 0, 0, 300);
                    gradientGreen.addColorStop(0, 'rgba(16, 185, 129, 0.25)');
                    gradientGreen.addColorStop(1, 'rgba(16, 185, 129, 0.0)');

                    new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: data.labels,
                            datasets: [
                                {
                                    label: 'Auction Lots Volume',
                                    data: data.values,
                                    borderColor: '#2563eb',
                                    backgroundColor: gradientBlue,
                                    borderWidth: 2.5,
                                    fill: true,
                                    tension: 0.4,
                                    pointBackgroundColor: '#2563eb',
                                    pointBorderColor: '#ffffff',
                                    pointHoverRadius: 6,
                                    yAxisID: 'y'
                                },
                                {
                                    label: 'Realized Savings (₹)',
                                    data: data.savings || [],
                                    borderColor: '#10b981',
                                    backgroundColor: gradientGreen,
                                    borderWidth: 2,
                                    borderDash: [4, 4],
                                    fill: false,
                                    tension: 0.4,
                                    pointBackgroundColor: '#10b981',
                                    pointHoverRadius: 6,
                                    yAxisID: 'y1'
                                }
                            ]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            interaction: {
                                mode: 'index',
                                intersect: false
                            },
                            plugins: {
                                legend: {
                                    position: 'top',
                                    labels: { boxWidth: 12, usePointStyle: true, font: { weight: '600' } }
                                },
                                tooltip: {
                                    backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                    padding: 12,
                                    cornerRadius: 8,
                                    callbacks: {
                                        label: function(context) {
                                            if (context.datasetIndex === 1) {
                                                return ' Savings: ₹' + Number(context.parsed.y).toLocaleString();
                                            }
                                            return ' ' + context.dataset.label + ': ' + context.parsed.y + ' lots';
                                        }
                                    }
                                }
                            },
                            scales: {
                                x: { grid: { color: gridColor } },
                                y: {
                                    type: 'linear',
                                    position: 'left',
                                    beginAtZero: true,
                                    title: { display: true, text: 'Auction Lots', font: { size: 11, weight: '600' } },
                                    grid: { color: gridColor }
                                },
                                y1: {
                                    type: 'linear',
                                    position: 'right',
                                    beginAtZero: true,
                                    grid: { drawOnChartArea: false },
                                    title: { display: true, text: 'Savings (₹)', font: { size: 11, weight: '600' } },
                                    ticks: {
                                        callback: function(v) {
                                            return '₹' + (v >= 1000 ? (v/1000).toFixed(0) + 'k' : v);
                                        }
                                    }
                                }
                            }
                        }
                    });
                });

            // 2. Supplier Performance Horizontal Gradient Bar Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/supplier-performance')
                .then(r => r.json())
                .then(data => {
                    const ctx = document.getElementById('supplierPerformanceChart').getContext('2d');
                    
                    const barGradient = ctx.createLinearGradient(0, 0, 400, 0);
                    barGradient.addColorStop(0, '#10b981');
                    barGradient.addColorStop(1, '#0284c7');

                    new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                label: 'Contract Wins',
                                data: data.values,
                                backgroundColor: barGradient,
                                borderRadius: 6,
                                borderSkipped: false
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            indexAxis: 'y',
                            plugins: {
                                legend: { display: false },
                                tooltip: {
                                    backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                    callbacks: {
                                        label: function(ctx) { return ' ' + ctx.parsed.x + ' Reverse Auction Wins'; }
                                    }
                                }
                            },
                            scales: {
                                x: { beginAtZero: true, grid: { color: gridColor } },
                                y: { grid: { display: false }, ticks: { font: { weight: '600' } } }
                            }
                        }
                    });
                });

            // 3. Spend by Category Donut Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/spend-by-category')
                .then(r => r.json())
                .then(data => {
                    const ctx = document.getElementById('spendByCategoryChart').getContext('2d');
                    const colors = ['#2563eb', '#10b981', '#f59e0b', '#8b5cf6', '#06b6d4', '#ec4899'];

                    new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                data: data.values,
                                backgroundColor: colors,
                                borderWidth: 2,
                                borderColor: isDark ? '#131e35' : '#ffffff'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '68%',
                            plugins: {
                                legend: {
                                    position: 'right',
                                    labels: { boxWidth: 12, usePointStyle: true, padding: 12 }
                                },
                                tooltip: {
                                    backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                    callbacks: {
                                        label: function(ctx) {
                                            return ' ' + ctx.label + ': ₹' + Number(ctx.parsed).toLocaleString();
                                        }
                                    }
                                }
                            }
                        }
                    });
                });

            // 4. Inventory Kanban Status Donut Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/inventory-status')
                .then(r => r.json())
                .then(data => {
                    const ctx = document.getElementById('inventoryStatusChart').getContext('2d');
                    const kanbanColors = ['#ef4444', '#f59e0b', '#10b981'];

                    new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                data: data.values,
                                backgroundColor: kanbanColors,
                                borderWidth: 2,
                                borderColor: isDark ? '#131e35' : '#ffffff'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '68%',
                            plugins: {
                                legend: {
                                    position: 'right',
                                    labels: { boxWidth: 12, usePointStyle: true, padding: 12 }
                                },
                                tooltip: {
                                    backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                    callbacks: {
                                        label: function(ctx) {
                                            return ' ' + ctx.label + ': ' + ctx.parsed + ' items';
                                        }
                                    }
                                }
                            }
                        }
                    });
                });
        });
    </script>
</body>
</html>
