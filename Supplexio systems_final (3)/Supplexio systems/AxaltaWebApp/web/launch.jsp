<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Autonomous Reverse Auction &amp; Global Trade Intelligence</title>

    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
                    },
                    colors: {
                        supple: {
                            navy: '#0B1E47',
                            deep: '#071533',
                            royal: '#163B7C',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            emerald: '#10B981',
                            rose: '#F43F5E',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(11, 30, 71, 0.04), 0 8px 24px -8px rgba(11, 30, 71, 0.08)',
                        'card-hover': '0 14px 32px -10px rgba(11, 30, 71, 0.14), 0 4px 12px -4px rgba(13, 148, 136, 0.10)',
                        'hero-glass': '0 25px 60px -15px rgba(4, 11, 28, 0.68), inset 0 1px 0 rgba(255, 255, 255, 0.12)'
                    }
                }
            }
        };
    </script>

    <style>
        .tabular-nums { font-variant-numeric: tabular-nums; }

        .bg-supplexio-hero {
            background: radial-gradient(ellipse 85% 65% at 50% 0%, #163B7C 0%, #0B1E47 52%, #071533 100%);
        }

        .bg-dot-grid {
            background-size: 28px 28px;
            background-image: radial-gradient(circle, rgba(255, 255, 255, 0.08) 1px, transparent 1px);
        }

        /* Explicit Supplexio Navy-Teal Top Navbar */
        .sp-launch-navbar {
            background: linear-gradient(90deg, rgba(11, 30, 71, 0.97) 0%, rgba(16, 45, 98, 0.97) 60%, rgba(13, 74, 92, 0.97) 100%);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }

        @keyframes marqueeScroll {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
        .marquee-track {
            display: flex;
            width: max-content;
            animation: marqueeScroll 40s linear infinite;
        }
        .marquee-wrapper:hover .marquee-track {
            animation-play-state: paused;
        }

        @keyframes toastSlideIn {
            from { transform: translateX(110%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .toast-enter { animation: toastSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards; }

        input[type="range"].roi-slider {
            -webkit-appearance: none;
            appearance: none;
            background: rgba(255, 255, 255, 0.16);
            height: 6px;
            border-radius: 9999px;
            outline: none;
        }
        input[type="range"].roi-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 20px;
            height: 20px;
            border-radius: 9999px;
            background: #F59E0B;
            border: 3px solid #0B1E47;
            box-shadow: 0 0 12px rgba(245, 158, 11, 0.55);
            cursor: pointer;
            transition: transform 0.15s ease;
        }
        input[type="range"].roi-slider::-webkit-slider-thumb:hover {
            transform: scale(1.12);
        }
        input[type="range"].roi-slider::-moz-range-thumb {
            width: 20px;
            height: 20px;
            border-radius: 9999px;
            background: #F59E0B;
            border: 3px solid #0B1E47;
            cursor: pointer;
        }

        ::-webkit-scrollbar { width: 7px; height: 7px; }
        ::-webkit-scrollbar-track { background: #F4F7FC; }
        ::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 9999px; }
    </style>
</head>

<body class="bg-[#F4F7FC] text-slate-800 font-sans antialiased overflow-x-hidden">

    <!-- Toast Notification Stack -->
    <div id="toastContainer" class="fixed top-5 right-5 z-[80] flex flex-col gap-2.5 max-w-sm w-full pointer-events-none"></div>

    <!-- =================================================================== -->
    <!-- 1. STICKY SUPPLEXIO NAVY-TEAL NAVBAR                                -->
    <!-- =================================================================== -->
    <header class="sticky top-0 z-50 sp-launch-navbar border-b border-white/15 shadow-lg">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-[72px] flex items-center justify-between gap-4">

            <!-- Exact Supplexio Logo Badge -->
            <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-3 group shrink-0">
                <div class="bg-gradient-to-br from-[#0B1E3D] to-[#0F3D4C] px-3.5 py-2 rounded-xl border border-cyan-400/25 shadow-md group-hover:border-cyan-400/45 transition-all">
                    <div class="flex items-center gap-1.5">
                        <svg class="w-4 h-4 text-[#2DD4BF]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                            <path d="M2 17l10 5 10-5"></path>
                            <path d="M2 12l10 5 10-5"></path>
                        </svg>
                        <span class="text-lg font-extrabold tracking-tight text-white leading-none">Supple<span class="text-[#2DD4BF]">xio</span></span>
                    </div>
                    <div class="text-[8px] font-bold tracking-[0.2em] text-slate-300 uppercase mt-1 flex items-center justify-center gap-1.5">
                        <span>BID BOLD</span>
                        <span class="w-1.5 h-1.5 rounded-full bg-[#F59E0B] shadow-[0_0_8px_#F59E0B]"></span>
                        <span>SOURCE SMART</span>
                    </div>
                </div>
            </a>

            <!-- Center Navigation Links (Desktop) -->
            <nav class="hidden lg:flex items-center gap-7 text-xs font-semibold text-slate-200/90">
                <a href="#capabilities" class="hover:text-[#2DD4BF] transition-colors">Capabilities</a>
                <a href="#marketplace" class="hover:text-[#2DD4BF] transition-colors inline-flex items-center gap-1.5">
                    <span>Live Floor</span>
                    <span class="w-1.5 h-1.5 rounded-full bg-[#10B981] animate-pulse"></span>
                </a>
                <a href="#how-it-works" class="hover:text-[#2DD4BF] transition-colors">How It Works</a>
                <a href="#trade-intel" onclick="event.preventDefault(); openTradeIntelModal();" class="hover:text-[#2DD4BF] transition-colors">Trade Intel</a>
                <a href="#faq" class="hover:text-[#2DD4BF] transition-colors">FAQ</a>
            </nav>

            <!-- Right CTAs (Real Application Links) -->
            <div class="hidden md:flex items-center gap-2.5">
                <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold text-cyan-200 hover:text-white bg-white/10 hover:bg-white/20 border border-white/15 transition-all">
                    <svg class="w-3.5 h-3.5 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <span>Global Trade Intel</span>
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="px-4 py-2 rounded-xl text-xs font-bold bg-[#F59E0B] hover:bg-amber-400 text-slate-950 shadow-sm transition-all">
                    Buyer Login
                </a>
                <a href="${pageContext.request.contextPath}/bidding?action=login" class="px-4 py-2 rounded-xl text-xs font-bold text-[#2DD4BF] hover:text-slate-950 bg-cyan-500/10 hover:bg-[#2DD4BF] border border-cyan-400/40 transition-all">
                    Supplier Portal
                </a>
            </div>

            <!-- Mobile Menu Button -->
            <button type="button" onclick="toggleMobileNav()" class="lg:hidden p-2 rounded-xl bg-white/10 hover:bg-white/15 text-white" aria-label="Toggle Menu">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
                </svg>
            </button>
        </div>

        <!-- Mobile Dropdown Nav -->
        <div id="mobileNavMenu" class="hidden lg:hidden bg-[#071533] border-t border-white/10 px-4 py-4 space-y-3">
            <div class="flex flex-col space-y-2 text-sm font-semibold text-slate-200">
                <a href="#capabilities" onclick="toggleMobileNav()" class="py-1.5 hover:text-[#2DD4BF]">Capabilities</a>
                <a href="#marketplace" onclick="toggleMobileNav()" class="py-1.5 hover:text-[#2DD4BF]">Live Floor</a>
                <a href="#how-it-works" onclick="toggleMobileNav()" class="py-1.5 hover:text-[#2DD4BF]">How It Works</a>
                <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="py-1.5 hover:text-[#2DD4BF]">Global Trade Intel</a>
                <a href="#faq" onclick="toggleMobileNav()" class="py-1.5 hover:text-[#2DD4BF]">FAQ</a>
            </div>
            <div class="pt-3 border-t border-white/10 grid grid-cols-2 gap-2">
                <a href="${pageContext.request.contextPath}/login.jsp" class="py-2.5 px-3 rounded-xl text-xs font-bold text-center bg-[#F59E0B] text-slate-950">Buyer Login</a>
                <a href="${pageContext.request.contextPath}/bidding?action=login" class="py-2.5 px-3 rounded-xl text-xs font-bold text-center bg-cyan-500/15 text-[#2DD4BF] border border-cyan-400/35">Supplier Portal</a>
            </div>
        </div>
    </header>

    <!-- =================================================================== -->
    <!-- 2. LIVE BACI COMMODITY SPOT MARQUEE                                 -->
    <!-- =================================================================== -->
    <div class="bg-[#071533] border-b border-white/10 py-2.5 overflow-hidden marquee-wrapper relative">
        <div class="max-w-full flex items-center">
            <div class="hidden sm:flex items-center gap-2 pl-5 pr-4 py-1 bg-[#071533] z-10 border-r border-white/10 shrink-0 shadow-[12px_0_20px_#071533]">
                <span class="w-2 h-2 rounded-full bg-[#2DD4BF] animate-pulse"></span>
                <span class="text-[10px] font-mono font-bold uppercase tracking-widest text-[#2DD4BF]">BACI SPOT INTEL</span>
            </div>
            <div class="overflow-hidden flex-1">
                <div class="marquee-track" id="commodityMarqueeTrack"></div>
            </div>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- 3. IMMERSIVE HERO SECTION (2-COLUMN SPLIT)                          -->
    <!-- =================================================================== -->
    <section class="relative bg-supplexio-hero text-white overflow-hidden pt-12 pb-16 lg:pt-16 lg:pb-24">
        <div class="absolute inset-0 bg-dot-grid opacity-70 pointer-events-none"></div>
        <div class="absolute -top-24 left-1/4 w-[520px] h-[520px] rounded-full bg-cyan-400/10 blur-3xl pointer-events-none"></div>
        <div class="absolute bottom-0 right-1/4 w-[480px] h-[480px] rounded-full bg-teal-500/10 blur-3xl pointer-events-none"></div>

        <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-8 items-center">

                <!-- LEFT COLUMN (6 cols) -->
                <div class="lg:col-span-6 space-y-6">
                    <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/15 border border-emerald-400/35 backdrop-blur-sm">
                        <span class="w-2 h-2 rounded-full bg-[#10B981] animate-ping"></span>
                        <span class="text-[10px] sm:text-[10.5px] font-mono font-bold uppercase tracking-widest text-emerald-300">AUTONOMOUS REVERSE AUCTION ENGINE • BACI 1D-RESNET V2</span>
                    </div>

                    <h1 class="text-3xl sm:text-5xl lg:text-[50px] font-black tracking-tight leading-[1.08] text-white">
                        Drive Raw Material Costs Down Through <span class="text-transparent bg-clip-text bg-gradient-to-r from-[#2DD4BF] to-emerald-300">Live Reverse Auctions.</span>
                    </h1>

                    <p class="text-sm sm:text-base text-slate-300 leading-relaxed max-w-xl">
                        Give procurement teams complete buyer control while putting verified suppliers into transparent real-time L1 bid compression — backed by automated GST Purchase Orders, digital GRN verification, and 1D-ResNet price surge alerts.
                    </p>

                    <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 pt-1">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="px-6 py-3.5 rounded-xl bg-[#F59E0B] hover:bg-amber-400 text-slate-950 font-extrabold text-sm shadow-xl shadow-amber-500/20 transition-all active:scale-[0.98] flex items-center justify-center gap-2">
                            <span>Enter Buyer Workspace</span>
                            <span aria-hidden="true">→</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/bidding?action=signup" class="px-6 py-3.5 rounded-xl bg-gradient-to-r from-[#0D9488] to-teal-600 hover:from-teal-500 hover:to-teal-600 text-white font-bold text-sm border border-cyan-300/30 shadow-lg shadow-teal-900/40 transition-all active:scale-[0.98] flex items-center justify-center gap-2">
                            <span>Join as Verified Supplier</span>
                        </a>
                    </div>

                    <!-- 4 Live Database-Synced KPI Stat Tiles -->
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-3">
                        <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-3.5">
                            <div id="statActiveAuctions" class="text-xl sm:text-2xl font-extrabold font-mono tabular-nums text-[#2DD4BF]">${publicStats.activeAuctions}</div>
                            <div class="text-[10.5px] font-medium text-slate-300 mt-0.5 leading-tight">Active Auctions</div>
                        </div>
                        <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-3.5">
                            <div id="statActiveSuppliers" class="text-xl sm:text-2xl font-extrabold font-mono tabular-nums text-white">${publicStats.activeSuppliers}</div>
                            <div class="text-[10.5px] font-medium text-slate-300 mt-0.5 leading-tight">Active Suppliers</div>
                        </div>
                        <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-3.5">
                            <div id="statLiveBids" class="text-xl sm:text-2xl font-extrabold font-mono tabular-nums text-white">${publicStats.liveBids}</div>
                            <div class="text-[10.5px] font-medium text-slate-300 mt-0.5 leading-tight">Live Bids</div>
                        </div>
                        <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-3.5">
                            <div id="statProducts" class="text-xl sm:text-2xl font-extrabold font-mono tabular-nums text-amber-300">${publicStats.products}</div>
                            <div class="text-[10.5px] font-medium text-slate-300 mt-0.5 leading-tight">Products Managed</div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT COLUMN (6 cols): EXISTING PLATFORM SNAPSHOT WITH YEAR-WISE AUCTION PULSE CHART -->
                <div class="lg:col-span-6">
                    <div class="bg-[#091838]/90 backdrop-blur-xl rounded-2xl border border-cyan-400/25 shadow-hero-glass overflow-hidden">
                        <div class="px-5 py-3.5 bg-white/5 border-b border-white/10 flex items-center justify-between gap-2">
                            <div class="flex items-center gap-2">
                                <span class="w-2 h-2 rounded-full bg-[#10B981] animate-ping shrink-0"></span>
                                <span class="text-[11px] font-mono font-bold tracking-wider uppercase text-cyan-200">
                                    PLATFORM SNAPSHOT • YEAR-WISE AUCTION PULSE
                                </span>
                            </div>
                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-400/35">
                                LIVE SYNC
                            </span>
                        </div>

                        <div class="p-5 space-y-4">
                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                                <div class="p-3.5 rounded-xl bg-white/5 border border-white/10">
                                    <span class="text-[10px] font-mono uppercase tracking-wider text-slate-400 block">BUYER CONTROL</span>
                                    <span class="text-base font-extrabold text-white mt-0.5 block">Secure</span>
                                </div>
                                <div class="p-3.5 rounded-xl bg-teal-500/10 border border-cyan-400/35">
                                    <span class="text-[10px] font-mono uppercase tracking-wider text-[#2DD4BF] block">SUPPLIER ACCESS</span>
                                    <span class="text-base font-extrabold text-white mt-0.5 block">Open</span>
                                </div>
                                <div class="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-400/35">
                                    <span class="text-[10px] font-mono uppercase tracking-wider text-emerald-300 block">BIDDING MODE</span>
                                    <span class="text-base font-extrabold text-emerald-300 mt-0.5 block">Live Reverse</span>
                                </div>
                            </div>

                            <!-- Year-wise / Time-Series Auction Pulse Chart -->
                            <div class="p-4 rounded-xl bg-[#06122B]/85 border border-white/10">
                                <div class="flex items-center justify-between gap-2 mb-2.5">
                                    <span class="text-[10px] font-mono font-bold uppercase tracking-wider text-slate-300">AUCTION ACTIVITY OVER TIME</span>
                                    <span class="text-[10px] font-mono font-semibold text-[#2DD4BF]">Live Database Feed</span>
                                </div>
                                <div class="relative h-[200px] w-full">
                                    <canvas id="auctionPulseChart"></canvas>
                                </div>
                            </div>

                            <!-- Platform Highlights -->
                            <ul class="space-y-2 text-xs text-slate-200 pt-1">
                                <li class="flex items-center gap-2.5">
                                    <span class="w-4 h-4 rounded-full bg-emerald-500/20 text-emerald-300 flex items-center justify-center text-[10px] font-bold shrink-0">✓</span>
                                    <span>Buyers keep the internal management workspace with full PO &amp; inventory governance.</span>
                                </li>
                                <li class="flex items-center gap-2.5">
                                    <span class="w-4 h-4 rounded-full bg-emerald-500/20 text-emerald-300 flex items-center justify-center text-[10px] font-bold shrink-0">✓</span>
                                    <span>Suppliers can self-register and enter the live reverse bidding marketplace.</span>
                                </li>
                                <li class="flex items-center gap-2.5">
                                    <span class="w-4 h-4 rounded-full bg-emerald-500/20 text-emerald-300 flex items-center justify-center text-[10px] font-bold shrink-0">✓</span>
                                    <span>Active auctions sync automatically from the first screen as events go live.</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 4. CAPABILITIES BENTO GRID (Balanced 2x2 Grid on #F4F7FC)           -->
    <!-- =================================================================== -->
    <section id="capabilities" class="py-16 lg:py-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="max-w-2xl mb-10">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-200/80 text-[10.5px] font-mono font-bold uppercase tracking-widest text-[#163B7C]">
                    UNIFIED PROCUREMENT ARCHITECTURE
                </div>
                <h2 class="mt-3 text-2xl sm:text-4xl font-extrabold text-[#0B1E47] tracking-tight leading-tight">
                    Built to compress raw material spend from trigger to payout.
                </h2>
                <p class="mt-2.5 text-sm sm:text-base text-slate-600 leading-relaxed">
                    Every workflow shares one real-time ledger — eliminating fragmented RFQ emails, manual vendor comparisons, and GST invoice mismatches.
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-white rounded-2xl border border-[#E2E8F0] p-6 sm:p-7 shadow-card hover:shadow-card-hover transition-all flex flex-col justify-between">
                    <div>
                        <div class="w-12 h-12 rounded-2xl bg-blue-50 border border-blue-100 text-[#163B7C] flex items-center justify-center mb-5">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-extrabold text-[#0B1E47] tracking-tight">Real-Time Reverse Bidding Engine</h3>
                        <p class="mt-2 text-sm text-slate-600 leading-relaxed">
                            Enforce strict ceiling prices, live L1 rank visibility, configurable anti-sniping auto-extensions, and immutable timestamped binding bid audit trails.
                        </p>
                    </div>
                    <div class="mt-6 pt-4 border-t border-slate-100 flex flex-wrap items-center gap-2 text-[11px] font-mono font-semibold text-slate-600">
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Anti-Sniping</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Live L1 Visibility</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Binding Audit Trail</span>
                    </div>
                </div>

                <div class="bg-white rounded-2xl border border-[#E2E8F0] p-6 sm:p-7 shadow-card hover:shadow-card-hover transition-all flex flex-col justify-between">
                    <div>
                        <div class="w-12 h-12 rounded-2xl bg-amber-50 border border-amber-200/70 text-[#F59E0B] flex items-center justify-center mb-5">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-extrabold text-[#0B1E47] tracking-tight">Kanban Inventory-to-Auction Triggers</h3>
                        <p class="mt-2 text-sm text-slate-600 leading-relaxed">
                            Monitor min/max raw material buffer levels across plants in real time. The instant a critical SKU drops into Low Kanban status, pre-draft a replenishment auction automatically.
                        </p>
                    </div>
                    <div class="mt-6 pt-4 border-t border-slate-100 flex flex-wrap items-center gap-2 text-[11px] font-mono font-semibold text-slate-600">
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Min/Max Buffers</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Auto-Replenishment</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Zero Stockouts</span>
                    </div>
                </div>

                <div class="bg-white rounded-2xl border border-[#E2E8F0] p-6 sm:p-7 shadow-card hover:shadow-card-hover transition-all flex flex-col justify-between">
                    <div>
                        <div class="w-12 h-12 rounded-2xl bg-emerald-50 border border-emerald-200/70 text-[#10B981] flex items-center justify-center mb-5">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-extrabold text-[#0B1E47] tracking-tight">End-to-End PO, GRN &amp; GST Settlement</h3>
                        <p class="mt-2 text-sm text-slate-600 leading-relaxed">
                            Generate official Purchase Orders in one click with automated 7.5% / 18% GST calculation, supplier dispatch confirmation, digital Goods Receipt Notes, and escrow payout tracking.
                        </p>
                    </div>
                    <div class="mt-6 pt-4 border-t border-slate-100 flex flex-wrap items-center gap-2 text-[11px] font-mono font-semibold text-slate-600">
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">One-Click PO</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">7.5% / 18% GST</span>
                        <span class="px-2.5 py-1 rounded-lg bg-[#F4F7FC] border border-slate-200">Escrow Tracking</span>
                    </div>
                </div>

                <div id="trade-intel" class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#0B1E47] via-[#102960] to-[#0E4A5C] text-white p-6 sm:p-7 shadow-xl border border-cyan-400/25 flex flex-col justify-between">
                    <div class="absolute inset-0 bg-dot-grid opacity-55 pointer-events-none"></div>
                    <div class="absolute -top-16 -right-16 w-52 h-52 rounded-full bg-[#2DD4BF]/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10">
                        <div class="flex flex-wrap items-center justify-between gap-2 mb-5">
                            <div class="w-12 h-12 rounded-2xl bg-cyan-400/15 border border-cyan-300/30 text-[#2DD4BF] flex items-center justify-center">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                            </div>
                            <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-rose-500/20 text-rose-200 border border-rose-400/35">
                                5,384 BACI COMMODITIES
                            </span>
                        </div>
                        <h3 class="text-lg font-extrabold text-white tracking-tight">1D-ResNet Global Trade Intelligence</h3>
                        <p class="mt-2 text-sm text-cyan-100/85 leading-relaxed">
                            Benchmark 5,384 BACI commodities with 30-day global price surge alerts and PCA-KMeans supplier clustering — locking in contracts before import inflation hits.
                        </p>
                    </div>

                    <div class="relative z-10 mt-6 pt-4 border-t border-white/10 flex flex-wrap items-center justify-between gap-3">
                        <span class="text-[11px] font-mono text-cyan-200">PCA-KMeans Clustering • Surge Radar</span>
                        <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="px-4 py-2 rounded-xl bg-[#2DD4BF] hover:bg-teal-300 text-slate-950 font-extrabold text-xs shadow-md transition-all">
                            Open Trade Intel →
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 5. PUBLIC ACTIVE REVERSE AUCTIONS FLOOR (#marketplace, LIVE DB SYNC)-->
    <!-- =================================================================== -->
    <section id="marketplace" class="py-16 lg:py-20 bg-white border-y border-[#E2E8F0] scroll-mt-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

            <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-5 mb-8">
                <div>
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-[10.5px] font-mono font-bold uppercase tracking-widest text-emerald-700">
                        <span class="w-2 h-2 rounded-full bg-[#10B981] animate-ping"></span>
                        PUBLIC ACTIVE REVERSE AUCTIONS • REAL-TIME SYNC
                    </div>
                    <h2 class="mt-3 text-2xl sm:text-4xl font-extrabold text-[#0B1E47] tracking-tight">
                        Live Sourcing Lots Open for Bidding
                    </h2>
                    <p class="mt-2 text-sm text-slate-600 max-w-2xl">
                        Inspect live L1 floor prices, ceiling benchmarks, and ticking countdowns synced directly from our procurement database. Approved suppliers can place binding reverse bids.
                    </p>
                </div>

                <a href="${pageContext.request.contextPath}/bidding?action=signup" class="self-start lg:self-auto px-5 py-2.5 rounded-xl bg-[#F59E0B] hover:bg-amber-400 text-slate-950 font-extrabold text-xs shadow-md transition-all whitespace-nowrap">
                    Join as Supplier →
                </a>
            </div>

            <!-- Dynamic Category Filter Pills -->
            <div class="flex flex-wrap items-center gap-2 mb-7" id="marketFilterPills"></div>

            <!-- Live Lot Cards Grid -->
            <div id="liveAuctionCardsGrid" class="grid grid-cols-1 md:grid-cols-2 gap-6"></div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 6. INTERACTIVE 5-STEP WORKFLOW & ROI SAVINGS ESTIMATOR              -->
    <!-- =================================================================== -->
    <section id="how-it-works" class="py-16 lg:py-20 scroll-mt-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

            <div class="max-w-2xl mb-10">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-teal-50 border border-teal-200 text-[10.5px] font-mono font-bold uppercase tracking-widest text-[#0D9488]">
                    END-TO-END WORKFLOW
                </div>
                <h2 class="mt-3 text-2xl sm:text-4xl font-extrabold text-[#0B1E47] tracking-tight">
                    From Demand Trigger to Escrow Payout in 5 Steps
                </h2>
                <p class="mt-2 text-sm sm:text-base text-slate-600">
                    Click any step below to explore how Supplexio automates sourcing, or model your annual procurement savings with our interactive estimator.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-7 items-stretch">

                <div class="lg:col-span-7 bg-white rounded-2xl border border-[#E2E8F0] p-6 shadow-card flex flex-col justify-between space-y-6">
                    <div>
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-xs font-bold text-[#0B1E47]">Interactive Auction Lifecycle</span>
                            <span class="text-[11px] font-mono text-slate-400">Select a stage to inspect</span>
                        </div>
                        <div id="workflowStepsGrid" class="grid grid-cols-1 sm:grid-cols-5 gap-2.5"></div>
                    </div>

                    <div id="workflowDetailStrip" class="p-5 rounded-2xl bg-gradient-to-br from-[#F4F7FC] to-teal-50/55 border border-teal-200/80 space-y-2.5"></div>

                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-1">
                        <div class="p-3 rounded-xl bg-[#F4F7FC] border border-slate-200/70">
                            <div class="text-[10px] font-mono font-bold uppercase text-[#163B7C]">Pre-Auction</div>
                            <p class="text-[11px] text-slate-600 mt-0.5">Verify HSN specs, ceiling budget &amp; Tier-1 invite list.</p>
                        </div>
                        <div class="p-3 rounded-xl bg-[#F4F7FC] border border-slate-200/70">
                            <div class="text-[10px] font-mono font-bold uppercase text-[#0D9488]">Live Floor</div>
                            <p class="text-[11px] text-slate-600 mt-0.5">Monitor L1 velocity &amp; answer buyer-desk queries.</p>
                        </div>
                        <div class="p-3 rounded-xl bg-[#F4F7FC] border border-slate-200/70">
                            <div class="text-[10px] font-mono font-bold uppercase text-emerald-700">Post-Award</div>
                            <p class="text-[11px] text-slate-600 mt-0.5">Auto-issue GST PO, confirm GRN &amp; release escrow.</p>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-5 relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#0B1E47] via-[#102960] to-[#071533] text-white p-6 sm:p-7 shadow-xl border border-cyan-400/20 flex flex-col justify-between">
                    <div class="absolute inset-0 bg-dot-grid opacity-55 pointer-events-none"></div>
                    <div class="absolute -bottom-20 -right-20 w-60 h-60 rounded-full bg-amber-400/10 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 space-y-6">
                        <div>
                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-amber-500/20 text-amber-300 border border-amber-400/35">
                                INTERACTIVE ROI CALCULATOR
                            </span>
                            <h3 class="mt-3 text-xl font-extrabold text-white tracking-tight">Procurement Savings Estimator</h3>
                            <p class="mt-1 text-xs text-slate-300">Calculate your projected annual savings at Supplexio's 14.8% average reverse-auction compression.</p>
                        </div>

                        <div class="space-y-2.5">
                            <div class="flex items-center justify-between">
                                <label for="roiSpendSlider" class="text-xs font-semibold text-slate-300">Monthly Procurement Spend</label>
                                <span id="roiSpendReadout" class="text-base font-extrabold font-mono tabular-nums text-[#2DD4BF]">₹50 Lakhs</span>
                            </div>
                            <input type="range" id="roiSpendSlider" min="5" max="200" step="5" value="50" oninput="updateRoiCalculator()" class="w-full roi-slider">
                            <div class="flex justify-between text-[10px] font-mono text-slate-400">
                                <span>₹5L / mo</span>
                                <span>₹100L / mo</span>
                                <span>₹200L / mo</span>
                            </div>
                        </div>

                        <div class="p-4 rounded-2xl bg-white/10 border border-white/15 space-y-3.5">
                            <div>
                                <span class="text-[10px] font-mono uppercase tracking-wider text-emerald-300 block">Annual Projected Savings (14.8% Avg)</span>
                                <div id="roiAnnualSavings" class="text-3xl sm:text-4xl font-black font-mono tabular-nums text-white mt-1">₹88,80,000</div>
                            </div>
                            <div class="grid grid-cols-2 gap-3 pt-3 border-t border-white/10">
                                <div>
                                    <span class="text-[10px] font-mono uppercase text-slate-400 block">Cycle Time Saved</span>
                                    <span class="text-sm font-extrabold font-mono tabular-nums text-[#2DD4BF]">68% Faster</span>
                                </div>
                                <div>
                                    <span class="text-[10px] font-mono uppercase text-slate-400 block">Monthly Margin Gain</span>
                                    <span id="roiMonthlyGain" class="text-sm font-extrabold font-mono tabular-nums text-amber-300">₹7,40,000</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <a href="${pageContext.request.contextPath}/login.jsp" class="relative z-10 mt-6 w-full py-3.5 px-4 rounded-xl bg-[#F59E0B] hover:bg-amber-400 text-slate-950 font-extrabold text-xs shadow-lg shadow-amber-500/20 transition-all text-center block">
                        Launch Buyer Workspace →
                    </a>
                </div>

            </div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 7. ROLE-SPECIFIC WORKSPACES (SIDE-BY-SIDE COMPARISON)               -->
    <!-- =================================================================== -->
    <section class="py-16 lg:py-20 bg-white border-y border-[#E2E8F0]">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-2xl mx-auto mb-11">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-200/80 text-[10.5px] font-mono font-bold uppercase tracking-widest text-[#163B7C]">
                    ROLE-SPECIFIC WORKSPACES
                </div>
                <h2 class="mt-3 text-2xl sm:text-4xl font-extrabold text-[#0B1E47] tracking-tight">
                    Two Tailored Portals, One Synchronized Engine
                </h2>
                <p class="mt-2 text-sm sm:text-base text-slate-600">
                    Purpose-built interfaces that maximize cost governance for enterprise buyers and bidding speed for verified suppliers.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-7">

                <div class="bg-[#F4F7FC] rounded-2xl border-2 border-[#0B1E47]/15 p-7 sm:p-8 flex flex-col justify-between shadow-card">
                    <div>
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#0B1E47] text-[#2DD4BF] text-[10px] font-mono font-bold uppercase tracking-wider">
                            BUYER ENTERPRISE WORKSPACE
                        </div>
                        <h3 class="mt-4 text-2xl font-extrabold text-[#0B1E47] tracking-tight">Command Control for Procurement Teams</h3>
                        <p class="mt-2 text-sm text-slate-600 leading-relaxed">
                            Manage product catalogs, Kanban inventory alerts, 1D-ResNet price surge triggers, live reverse auctions, and GST purchase orders from one secure console.
                        </p>

                        <ul class="mt-6 space-y-3 text-sm text-slate-700">
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0B1E47] text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Publish ceiling-enforced reverse auctions with anti-sniping rules</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0B1E47] text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Receive 1D-ResNet 30-day import surge alerts across 5,384 commodities</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0B1E47] text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Auto-trigger replenishment RFQs when Kanban stock hits Low buffer</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0B1E47] text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Convert L1 winners to GST-calculated POs with role-based approvals</span>
                            </li>
                        </ul>
                    </div>

                    <a href="${pageContext.request.contextPath}/login.jsp" class="mt-8 w-full py-3.5 px-5 rounded-xl bg-[#0B1E47] hover:bg-[#163B7C] text-white font-bold text-sm shadow-md transition-all flex items-center justify-center gap-2">
                        <span>Enter Buyer Workspace</span>
                        <span>→</span>
                    </a>
                </div>

                <div class="bg-[#F4F7FC] rounded-2xl border-2 border-[#0D9488]/25 p-7 sm:p-8 flex flex-col justify-between shadow-card">
                    <div>
                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#0D9488] text-white text-[10px] font-mono font-bold uppercase tracking-wider">
                            SUPPLIER OPEN MARKETPLACE
                        </div>
                        <h3 class="mt-4 text-2xl font-extrabold text-[#0B1E47] tracking-tight">Zero-Friction Access to Live Industrial Demand</h3>
                        <p class="mt-2 text-sm text-slate-600 leading-relaxed">
                            Self-onboard in minutes, discover open auctions matched to your HSN supply categories, compete transparently on L1 pricing, and track escrow payouts.
                        </p>

                        <ul class="mt-6 space-y-3 text-sm text-slate-700">
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0D9488] text-white flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Instant registration with GSTIN verification &amp; Tier-1 supplier badge</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0D9488] text-white flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Live Chart.js price trend rooms with one-click undercut presets</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0D9488] text-white flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>Direct in-lot messaging with buyer desks &amp; inspection photo uploads</span>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <span class="w-5 h-5 rounded-full bg-[#0D9488] text-white flex items-center justify-center shrink-0 mt-0.5 text-xs font-bold">✓</span>
                                <span>One-click PO acceptance, GST invoice upload &amp; UTR settlement tracking</span>
                            </li>
                        </ul>
                    </div>

                    <a href="${pageContext.request.contextPath}/bidding?action=signup" class="mt-8 w-full py-3.5 px-5 rounded-xl bg-gradient-to-r from-[#0D9488] to-[#10B981] hover:opacity-95 text-white font-bold text-sm shadow-md transition-all flex items-center justify-center gap-2">
                        <span>Join as Verified Supplier</span>
                        <span>→</span>
                    </a>
                </div>

            </div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 8. EXECUTIVE B2B FAQ ACCORDION (5 QUESTIONS)                        -->
    <!-- =================================================================== -->
    <section id="faq" class="py-16 lg:py-20 scroll-mt-20">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-10">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-200/75 text-[10.5px] font-mono font-bold uppercase tracking-widest text-slate-600">
                    EXECUTIVE FAQ
                </div>
                <h2 class="mt-3 text-2xl sm:text-4xl font-extrabold text-[#0B1E47] tracking-tight">
                    Frequently Asked Questions
                </h2>
                <p class="mt-2 text-sm text-slate-600">
                    Answers on reverse auction governance, 1D-ResNet trade intelligence, supplier vetting, and GST settlement.
                </p>
            </div>

            <div id="faqAccordion" class="space-y-3"></div>
        </div>
    </section>

    <!-- =================================================================== -->
    <!-- 9. CLEAN ENTERPRISE FOOTER                                          -->
    <!-- =================================================================== -->
    <footer class="bg-[#071533] text-slate-300 border-t border-white/10">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 pb-10 border-b border-white/10">

                <div class="space-y-4">
                    <div class="inline-block bg-gradient-to-br from-[#0B1E3D] to-[#0F3D4C] px-3.5 py-2 rounded-xl border border-cyan-400/25">
                        <div class="flex items-center gap-1.5">
                            <svg class="w-4 h-4 text-[#2DD4BF]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                                <path d="M2 17l10 5 10-5"></path>
                                <path d="M2 12l10 5 10-5"></path>
                            </svg>
                            <span class="text-lg font-extrabold tracking-tight text-white">Supple<span class="text-[#2DD4BF]">xio</span></span>
                        </div>
                        <div class="text-[8px] font-bold tracking-[0.2em] text-slate-300 uppercase mt-1 flex items-center justify-center gap-1.5">
                            <span>BID BOLD</span>
                            <span class="w-1.5 h-1.5 rounded-full bg-[#F59E0B]"></span>
                            <span>SOURCE SMART</span>
                        </div>
                    </div>
                    <p class="text-xs text-slate-400 leading-relaxed">
                        Autonomous reverse auction and 1D-ResNet global trade intelligence infrastructure for industrial buyers and verified Tier-1 suppliers.
                    </p>
                </div>

                <div>
                    <h4 class="text-xs font-bold uppercase tracking-wider text-white mb-3">Platform</h4>
                    <ul class="space-y-2 text-xs text-slate-400">
                        <li><a href="#capabilities" class="hover:text-[#2DD4BF] transition-colors">Reverse Bidding Engine</a></li>
                        <li><a href="#marketplace" class="hover:text-[#2DD4BF] transition-colors">Public Live Floor</a></li>
                        <li><a href="#how-it-works" class="hover:text-[#2DD4BF] transition-colors">Workflow &amp; ROI Estimator</a></li>
                        <li><a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="hover:text-[#2DD4BF] transition-colors">Global Trade Intel</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="text-xs font-bold uppercase tracking-wider text-white mb-3">Workspaces</h4>
                    <ul class="space-y-2 text-xs text-slate-400">
                        <li><a href="${pageContext.request.contextPath}/login.jsp" class="hover:text-[#2DD4BF] transition-colors">Buyer Login</a></li>
                        <li><a href="${pageContext.request.contextPath}/bidding?action=login" class="hover:text-[#2DD4BF] transition-colors">Supplier Portal</a></li>
                        <li><a href="${pageContext.request.contextPath}/bidding?action=signup" class="hover:text-[#2DD4BF] transition-colors">New Supplier Onboarding</a></li>
                        <li><a href="#faq" class="hover:text-[#2DD4BF] transition-colors">Procurement FAQ</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="text-xs font-bold uppercase tracking-wider text-white mb-3">Security &amp; Compliance</h4>
                    <div class="flex flex-wrap gap-2">
                        <span class="px-2.5 py-1 rounded-lg text-[10.5px] font-mono font-semibold bg-white/5 border border-white/10 text-emerald-300">256-Bit SSL</span>
                        <span class="px-2.5 py-1 rounded-lg text-[10.5px] font-mono font-semibold bg-white/5 border border-white/10 text-[#2DD4BF]">GST Compliant</span>
                        <span class="px-2.5 py-1 rounded-lg text-[10.5px] font-mono font-semibold bg-white/5 border border-white/10 text-amber-300">BACI Lakehouse</span>
                    </div>
                    <p class="mt-3 text-[11px] text-slate-400 font-mono">
                        Engine Status: <span class="text-emerald-400">99.99% Operational</span>
                    </p>
                </div>

            </div>

            <div class="pt-6 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-slate-400">
                <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                <p class="font-mono text-[11px] text-slate-500">Enterprise Reverse Auction &amp; Trade Intelligence Platform</p>
            </div>
        </div>
    </footer>

    <!-- =================================================================== -->
    <!-- MODAL: GLOBAL TRADE INTEL (1D-RESNET ALERTS)                        -->
    <!-- =================================================================== -->
    <div id="tradeIntelModal" class="fixed inset-0 z-50 bg-slate-950/75 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-[#0B1E47] text-white rounded-2xl max-w-2xl w-full shadow-2xl border border-cyan-400/30 overflow-hidden">
            <div class="px-6 py-4 bg-white/5 border-b border-white/10 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-widest text-[#2DD4BF]">1D-RESNET V2 NEURAL ENGINE • BACI LAKEHOUSE</span>
                    <h3 class="text-lg font-extrabold">Global Commodity Surge Alerts</h3>
                </div>
                <button type="button" onclick="closeModal('tradeIntelModal')" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">✕</button>
            </div>

            <div class="p-6 space-y-4">
                <p class="text-xs text-slate-300 leading-relaxed">
                    Real-time 30-day global import price forecasts across 5,384 HSN-indexed commodities with PCA-KMeans supplier cluster benchmarking.
                </p>

                <div class="overflow-x-auto rounded-xl border border-white/10">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="bg-white/5 text-[10px] font-mono uppercase tracking-wider text-slate-400 border-b border-white/10">
                                <th class="py-3 px-4">Commodity &amp; HSN</th>
                                <th class="py-3 px-4 text-right">Spot Rate (INR)</th>
                                <th class="py-3 px-4">30-Day Signal</th>
                                <th class="py-3 px-4 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/10">
                            <tr>
                                <td class="py-3 px-4 font-bold">Bitumen Primer <span class="block text-[10px] font-mono text-slate-400">HSN 271500</span></td>
                                <td class="py-3 px-4 text-right font-mono tabular-nums">₹2,625.00</td>
                                <td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-rose-500/20 text-rose-300 border border-rose-400/35">+7.4% SURGE</span></td>
                                <td class="py-3 px-4 text-right"><a href="${pageContext.request.contextPath}/login.jsp?redirect=%2Finventory" class="px-2.5 py-1 rounded-lg text-[10px] font-bold bg-[#F59E0B] text-slate-950 inline-block">Draft Hedge</a></td>
                            </tr>
                            <tr>
                                <td class="py-3 px-4 font-bold">Titanium Dioxide <span class="block text-[10px] font-mono text-slate-400">HSN 320611</span></td>
                                <td class="py-3 px-4 text-right font-mono tabular-nums">₹3,291.75</td>
                                <td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-rose-500/20 text-rose-300 border border-rose-400/35">+6.4% SURGE</span></td>
                                <td class="py-3 px-4 text-right"><a href="${pageContext.request.contextPath}/login.jsp?redirect=%2Finventory" class="px-2.5 py-1 rounded-lg text-[10px] font-bold bg-[#2DD4BF] text-slate-950 inline-block">Draft Hedge</a></td>
                            </tr>
                            <tr>
                                <td class="py-3 px-4 font-bold">Copper Cathodes <span class="block text-[10px] font-mono text-slate-400">HSN 740311</span></td>
                                <td class="py-3 px-4 text-right font-mono tabular-nums">₹7,82,400/MT</td>
                                <td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/20 text-amber-300 border border-amber-400/35">+3.2% SURGE</span></td>
                                <td class="py-3 px-4 text-right"><a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="text-[10px] font-mono text-cyan-200 hover:underline">Inspect →</a></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <a href="${pageContext.request.contextPath}/trade-intelligence.jsp" class="px-4 py-2 rounded-xl text-xs font-bold bg-[#2DD4BF] text-slate-950 hover:bg-teal-300 transition-all">Open Full Trade Intel Workspace →</a>
                </div>
            </div>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- CORE APPLICATION SCRIPT (LIVE DB SYNC + CHARTS + WORKFLOW)          -->
    <!-- =================================================================== -->
    <script>
        var ctxPath = '${pageContext.request.contextPath}';

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

        // 1. LIVE BACI COMMODITY SPOT MARQUEE
        const marqueeCommodities = [
            { name: 'Titanium Dioxide', hsn: 'HSN 320611', price: '₹3,291.75', change: '+6.4% SURGE', type: 'surge' },
            { name: 'Granite Slab', hsn: 'HSN 680223', price: '₹9,315.00', change: '-2.1% COOLING', type: 'cooling' },
            { name: 'Bitumen Primer', hsn: 'HSN 271500', price: '₹2,625.00', change: '+7.4% SURGE', type: 'surge' },
            { name: 'Electrical Wire 2.5mm', hsn: 'HSN 854449', price: '₹1,842.84', change: '-1.4% STABLE', type: 'stable' },
            { name: 'Copper Cathodes', hsn: 'HSN 740311', price: '₹7,82,400/MT', change: '+3.2% SURGE', type: 'surge' },
            { name: 'Aluminum Plates', hsn: 'HSN 760612', price: '₹2,08,700', change: '-4.8% COOLING', type: 'cooling' }
        ];

        function renderMarquee() {
            const track = document.getElementById('commodityMarqueeTrack');
            const buildItems = () => marqueeCommodities.map(c => {
                let pillClass = 'bg-emerald-500/20 text-emerald-300 border-emerald-400/30';
                if (c.type === 'surge') pillClass = 'bg-rose-500/20 text-rose-300 border-rose-400/35';
                else if (c.type === 'stable') pillClass = 'bg-cyan-500/15 text-[#2DD4BF] border-cyan-400/30';
                return '<div class="inline-flex items-center gap-2.5 px-5 border-r border-white/10 text-xs whitespace-nowrap">' +
                    '<span class="font-semibold text-white">' + c.name + '</span>' +
                    '<span class="font-mono text-[10px] text-slate-400">' + c.hsn + '</span>' +
                    '<span class="font-mono font-bold tabular-nums text-cyan-200">' + c.price + '</span>' +
                    '<span class="px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold border ' + pillClass + '">' + c.change + '</span>' +
                '</div>';
            }).join('');
            track.innerHTML = buildItems() + buildItems();
        }

        // 2. EXISTING YEAR-WISE / TIME-SERIES AUCTION PULSE CHART
        let auctionPulseChart = null;
        function loadAuctionPulseChart() {
            fetch(ctxPath + '/api/dashboard/auctions-over-time')
                .then(res => res.json())
                .then(data => {
                    const ctx = document.getElementById('auctionPulseChart');
                    if (!ctx) return;
                    if (auctionPulseChart) {
                        auctionPulseChart.data.labels = data.labels || [];
                        auctionPulseChart.data.datasets[0].data = data.values || [];
                        auctionPulseChart.update('none');
                        return;
                    }
                    const g = ctx.getContext('2d').createLinearGradient(0, 0, 0, 200);
                    g.addColorStop(0, 'rgba(45, 212, 191, 0.36)');
                    g.addColorStop(1, 'rgba(13, 148, 136, 0.00)');
                    auctionPulseChart = new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: data.labels || [],
                            datasets: [{
                                label: 'Auctions',
                                data: data.values || [],
                                borderColor: '#2DD4BF',
                                backgroundColor: g,
                                borderWidth: 2.5,
                                fill: true,
                                tension: 0.35,
                                pointRadius: 4,
                                pointHoverRadius: 6,
                                pointBackgroundColor: '#0B1E47',
                                pointBorderColor: '#2DD4BF',
                                pointBorderWidth: 2
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: {
                                x: {
                                    grid: { display: false },
                                    ticks: { color: '#94A3B8', font: { size: 11, family: 'JetBrains Mono' }, maxRotation: 0, autoSkip: true, maxTicksLimit: 6 }
                                },
                                y: {
                                    beginAtZero: true,
                                    ticks: { precision: 0, color: '#94A3B8', font: { size: 11, family: 'JetBrains Mono' } },
                                    grid: { color: 'rgba(148, 163, 184, 0.14)' }
                                }
                            }
                        }
                    });
                })
                .catch(function() {});
        }

        // 3. LIVE DATABASE-SYNCED ACTIVE AUCTIONS FLOOR
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

        let marketFilter = 'All';

        function setMarketFilter(cat) {
            marketFilter = cat;
            renderFilterPills();
            renderPublicMarketplace();
        }

        function renderFilterPills() {
            const container = document.getElementById('marketFilterPills');
            if (!container) return;
            const cats = ['All'];
            liveAuctions.forEach(a => {
                const c = a.category || 'Strategic Sourcing';
                if (!cats.includes(c)) cats.push(c);
            });
            if (!cats.includes(marketFilter)) marketFilter = 'All';

            container.innerHTML = cats.map(c => {
                const active = c === marketFilter;
                const label = c === 'All' ? ('All Lots (' + liveAuctions.length + ')') : escHtml(c);
                return '<button type="button" onclick="setMarketFilter(\'' + escHtml(c).replace(/'/g, "\\'") + '\')" ' +
                    'class="px-4 py-2 rounded-xl text-xs transition-all ' +
                    (active ? 'font-bold bg-[#0B1E47] text-white shadow-sm' : 'font-semibold bg-slate-100 text-slate-600 hover:bg-slate-200') + '">' +
                    label + '</button>';
            }).join('');
        }

        function renderPublicMarketplace() {
            const grid = document.getElementById('liveAuctionCardsGrid');
            if (!grid) return;
            const list = marketFilter === 'All'
                ? liveAuctions
                : liveAuctions.filter(a => (a.category || 'Strategic Sourcing') === marketFilter);

            if (list.length === 0) {
                grid.innerHTML = '<div class="md:col-span-2 bg-[#F4F7FC] rounded-2xl border border-slate-200 p-10 text-center space-y-3">' +
                    '<h3 class="text-lg font-extrabold text-[#0B1E47]">No active auctions right now</h3>' +
                    '<p class="text-sm text-slate-600 max-w-md mx-auto">Live reverse auctions appear here automatically as soon as buyers publish them.</p>' +
                    '<div class="flex justify-center gap-3 pt-2">' +
                        '<a href="' + ctxPath + '/login.jsp?redirect=%2Fauction%3Faction%3Dnew" class="px-5 py-2.5 rounded-xl bg-[#0B1E47] text-white text-xs font-bold">Launch Auction (Buyer)</a>' +
                        '<a href="' + ctxPath + '/bidding?action=signup" class="px-5 py-2.5 rounded-xl bg-[#0D9488] text-white text-xs font-bold">Create Supplier Account</a>' +
                    '</div></div>';
                return;
            }

            grid.innerHTML = list.map(lot => {
                const savedPct = Number(lot.savingsPct || 0).toFixed(1);
                return '<article class="bg-white rounded-2xl border border-[#E2E8F0] shadow-card hover:shadow-card-hover transition-all overflow-hidden flex flex-col justify-between">' +
                    '<div>' +
                        '<div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0E5A6D] px-5 py-4 text-white">' +
                            '<div class="flex items-center justify-between gap-2 mb-1.5">' +
                                '<div class="flex items-center gap-2">' +
                                    '<span class="px-2 py-0.5 rounded text-[10px] font-mono font-bold bg-white/15 text-cyan-200">LOT #' + lot.id + '</span>' +
                                    '<span class="text-[11px] font-medium text-cyan-100/85">' + escHtml(lot.category || 'Strategic Sourcing') + '</span>' +
                                '</div>' +
                                '<span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/25 text-emerald-200 border border-emerald-400/35">' +
                                    '<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>LIVE</span>' +
                            '</div>' +
                            '<div class="flex items-baseline justify-between gap-2">' +
                                '<h3 class="text-lg font-extrabold tracking-tight">' + escHtml(lot.productName) + '</h3>' +
                                '<span class="text-xs font-mono font-semibold text-cyan-200 shrink-0">' + lot.requiredQuantity + ' ' + escHtml(lot.unit) + '</span>' +
                            '</div>' +
                        '</div>' +
                        '<div class="p-5 space-y-4">' +
                            '<div class="grid grid-cols-2 gap-3">' +
                                '<div class="p-3 rounded-xl bg-[#F4F7FC] border border-slate-200/75">' +
                                    '<span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">Ceiling Price</span>' +
                                    '<span class="text-sm font-bold font-mono tabular-nums text-slate-700 mt-0.5 block">' + formatINR(lot.startPrice, 2) + '</span>' +
                                '</div>' +
                                '<div class="p-3 rounded-xl bg-teal-50/70 border border-teal-200/80">' +
                                    '<span class="text-[10px] font-mono font-bold uppercase tracking-wider text-[#0D9488] block">Current L1 Bid</span>' +
                                    '<span class="text-sm font-black font-mono tabular-nums text-[#0B1E47] mt-0.5 block">' + formatINR(lot.currentPrice, 2) + '</span>' +
                                '</div>' +
                            '</div>' +
                            '<div class="flex flex-wrap items-center justify-between gap-2 pt-2 border-t border-slate-100 text-xs">' +
                                '<div class="flex items-center gap-1.5 text-amber-700 font-mono font-bold tabular-nums">' +
                                    '<svg class="w-3.5 h-3.5 text-[#F59E0B]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>' +
                                    '<span class="lot-live-timer" data-endms="' + (lot.endTimeMs || 0) + '">' + formatCountdown(lot.endTimeMs) + '</span>' +
                                '</div>' +
                                '<div class="flex items-center gap-2">' +
                                    '<span class="px-2 py-0.5 rounded-md text-[10.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 border border-emerald-500/30 tabular-nums">-' + savedPct + '% Saved</span>' +
                                    '<span class="font-mono text-[11px] font-semibold text-slate-500">' + lot.bidCount + ' Bids</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="px-5 pb-5">' +
                        '<a href="' + ctxPath + '/bidding?action=login" class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#0B1E47] via-[#163B7C] to-[#0D9488] hover:opacity-95 text-white font-bold text-xs shadow-md transition-all flex items-center justify-center gap-2">' +
                            '<svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path></svg>' +
                            '<span>Bid Now in Supplier Portal →</span>' +
                        '</a>' +
                    '</div>' +
                '</article>';
            }).join('');
        }

        function tickMarketplaceTimers() {
            document.querySelectorAll('.lot-live-timer').forEach(el => {
                const endMs = Number(el.getAttribute('data-endms') || 0);
                el.textContent = formatCountdown(endMs);
            });
        }

        function syncLiveLaunchData() {
            fetch(ctxPath + '/home?action=liveJson', { cache: 'no-store' })
                .then(res => res.json())
                .then(data => {
                    if (data.stats) {
                        document.getElementById('statActiveAuctions').textContent = data.stats.activeAuctions;
                        document.getElementById('statActiveSuppliers').textContent = data.stats.activeSuppliers;
                        document.getElementById('statLiveBids').textContent = data.stats.liveBids;
                        document.getElementById('statProducts').textContent = data.stats.products;
                    }
                    if (Array.isArray(data.auctions)) {
                        liveAuctions = data.auctions;
                        renderFilterPills();
                        renderPublicMarketplace();
                    }
                })
                .catch(function() {});
        }

        // 4. INTERACTIVE 5-STEP WORKFLOW & ROI SAVINGS ESTIMATOR
        const workflowSteps = [
            { num: '01', title: 'Define Demand & Ceiling', detailTitle: 'Step 1: Define Demand, HSN Specs & AI Ceiling Price', detailBody: 'Import replenishment demand directly from Kanban low-stock alerts or 1D-ResNet price surge warnings. Set quantity, delivery window, GST rate, and a benchmarked ceiling price.', badge: '90-Sec Setup' },
            { num: '02', title: 'Invite & Publish Lot', detailTitle: 'Step 2: Invite Verified Suppliers & Publish to Live Floor', detailBody: 'Target Tier-1 KYC-verified suppliers matched to the HSN category or open the lot to the public marketplace. Configure minimum bid decrement steps and anti-sniping extensions.', badge: 'Verified Vendors' },
            { num: '03', title: 'Live Reverse Bidding', detailTitle: 'Step 3: Real-Time Downward L1 Bid Compression', detailBody: 'Approved suppliers compete transparently on live downward price curves with real-time L1 rank updates, buyer-desk clarification chat, and immutable timestamped bid logging.', badge: '14.8% Avg. Compression' },
            { num: '04', title: 'Award & Issue PO', detailTitle: 'Step 4: One-Click L1 Award & Automated GST Purchase Order', detailBody: 'Review the complete bid ledger, award the winning supplier, and instantly issue a numbered, GST-calculated Purchase Order routed through your team approval limits.', badge: '100% Audit-Ready' },
            { num: '05', title: 'GRN & Escrow Payout', detailTitle: 'Step 5: Digital GRN Verification & Escrow Settlement', detailBody: 'Log material receipt via digital GRN, verify the supplier’s uploaded GST tax invoice against delivered quantities, and release UTR-tracked RTGS/NEFT escrow payouts.', badge: 'Zero Discrepancy' }
        ];

        let activeStepIdx = 0;

        function renderWorkflow() {
            const grid = document.getElementById('workflowStepsGrid');
            grid.innerHTML = workflowSteps.map((st, idx) => {
                const isActive = idx === activeStepIdx;
                return '<button type="button" onclick="selectWorkflowStep(' + idx + ')" class="text-left p-3.5 rounded-xl border transition-all flex flex-col justify-between gap-2.5 ' +
                    (isActive ? 'bg-[#0B1E47] text-white border-[#0B1E47] shadow-md -translate-y-0.5' : 'bg-[#F4F7FC] hover:bg-slate-100 text-slate-800 border-slate-200/80') + '">' +
                    '<span class="w-7 h-7 rounded-lg font-mono text-xs font-extrabold flex items-center justify-center ' +
                    (isActive ? 'bg-[#2DD4BF] text-slate-950' : 'bg-white text-[#163B7C] border border-slate-200') + '">' + st.num + '</span>' +
                    '<span class="text-xs font-bold leading-snug ' + (isActive ? 'text-white' : 'text-[#0B1E47]') + '">' + st.title + '</span>' +
                '</button>';
            }).join('');

            const cur = workflowSteps[activeStepIdx];
            document.getElementById('workflowDetailStrip').innerHTML =
                '<div class="flex flex-wrap items-center justify-between gap-2">' +
                    '<span class="text-[10px] font-mono font-bold uppercase tracking-widest text-[#0D9488]">STAGE ' + cur.num + ' DETAILS</span>' +
                    '<span class="px-2.5 py-0.5 rounded-md text-[10px] font-mono font-bold bg-[#0D9488] text-white">' + cur.badge + '</span>' +
                '</div>' +
                '<h4 class="text-sm sm:text-base font-extrabold text-[#0B1E47]">' + cur.detailTitle + '</h4>' +
                '<p class="text-xs sm:text-sm text-slate-600 leading-relaxed">' + cur.detailBody + '</p>';
        }

        function selectWorkflowStep(idx) {
            activeStepIdx = idx;
            renderWorkflow();
        }

        function updateRoiCalculator() {
            const monthlyLakhs = Number(document.getElementById('roiSpendSlider').value);
            document.getElementById('roiSpendReadout').textContent = '₹' + monthlyLakhs + ' Lakhs';
            const monthlySpendINR = monthlyLakhs * 100000;
            const monthlyGain = Math.round(monthlySpendINR * 0.148);
            const annualSavings = monthlyGain * 12;
            document.getElementById('roiAnnualSavings').textContent = formatINR(annualSavings, 0);
            document.getElementById('roiMonthlyGain').textContent = formatINR(monthlyGain, 0);
        }

        // 5. FAQ ACCORDION
        const faqItems = [
            { q: 'How does Supplexio vet suppliers before they can bid on live reverse auctions?', a: 'Every supplier completes GSTIN, corporate PAN, and business document verification. Buyers can enforce Tier-1 Verified gating so only approved industrial suppliers participate in live bidding rooms.' },
            { q: 'How does the 1D-ResNet Global Trade Intelligence engine protect against raw material inflation?', a: 'Supplexio benchmarks 5,384 BACI commodities in real time. When our 1D-ResNet model detects an upcoming 30-day global price surge, it triggers proactive alerts and one-click hedging auction drafts.' },
            { q: 'How does Anti-Sniping prevent last-second bid manipulation?', a: 'If a supplier submits a lower L1 bid within the final minutes of an auction, Supplexio protects fair price discovery for all competing vendors.' },
            { q: 'Are winning bids automatically converted into GST-compliant Purchase Orders?', a: 'Yes. Awarding the L1 winner generates an official Purchase Order with automated GST calculation, followed by supplier acceptance, digital GRN verification, tax invoice matching, and UTR-tracked payouts.' },
            { q: 'How quickly can our procurement team and existing vendors go live?', a: 'Buyers can configure their workspace and launch their first reverse auction in minutes. Existing or new suppliers can self-register via the Supplier Portal without manual IT intervention.' }
        ];
        let openFaqIndex = 0;

        function renderFaq() {
            const container = document.getElementById('faqAccordion');
            container.innerHTML = faqItems.map((item, idx) => {
                const isOpen = idx === openFaqIndex;
                return '<div class="bg-white rounded-2xl border ' + (isOpen ? 'border-[#0D9488]/45 shadow-card' : 'border-[#E2E8F0]') + ' overflow-hidden transition-all">' +
                    '<button type="button" onclick="toggleFaq(' + idx + ')" class="w-full px-6 py-4 text-left flex items-center justify-between gap-4">' +
                        '<span class="text-sm font-bold text-[#0B1E47]">' + item.q + '</span>' +
                        '<span class="w-7 h-7 rounded-lg flex items-center justify-center shrink-0 transition-transform ' + (isOpen ? 'bg-[#0B1E47] text-[#2DD4BF] rotate-45' : 'bg-slate-100 text-slate-600') + ' font-bold text-base">+</span>' +
                    '</button>' +
                    '<div class="' + (isOpen ? 'block' : 'hidden') + ' px-6 pb-5 pt-0 text-xs sm:text-sm text-slate-600 leading-relaxed border-t border-slate-100">' +
                        '<div class="pt-3">' + item.a + '</div>' +
                    '</div></div>';
            }).join('');
        }

        function toggleFaq(idx) {
            openFaqIndex = openFaqIndex === idx ? -1 : idx;
            renderFaq();
        }

        // 6. MODALS & MOBILE NAV
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
        function openTradeIntelModal() { openModal('tradeIntelModal'); }
        function toggleMobileNav() {
            document.getElementById('mobileNavMenu').classList.toggle('hidden');
        }

        window.addEventListener('DOMContentLoaded', function () {
            renderMarquee();
            loadAuctionPulseChart();
            renderFilterPills();
            renderPublicMarketplace();
            renderWorkflow();
            updateRoiCalculator();
            renderFaq();
            setInterval(tickMarketplaceTimers, 1000);
            setInterval(function() {
                syncLiveLaunchData();
                loadAuctionPulseChart();
            }, 10000);
        });
    </script>

    <!-- Unified Supplexio AI Gemini Agent -->
    <jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />
</body>
</html>
