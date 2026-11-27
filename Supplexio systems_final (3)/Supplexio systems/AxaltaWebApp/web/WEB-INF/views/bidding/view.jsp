<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en" class="h-full" data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Reverse Auction Bidding Room | <c:out value="${auction.productName}"/></title>

    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

    <!-- Tailwind CSS CDN & Chart.js -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/chart.min.js"></script>
    <script>if (typeof Chart === 'undefined') { document.write('<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"><\/script>'); }</script>

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
                            navy: '#0B1E47',
                            midnavy: '#12336B',
                            royal: '#16367D',
                            deepblue: '#1E3A8A',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06)',
                        'card-hover': '0 10px 24px -8px rgba(11, 30, 71, 0.12)',
                        'drawer': '-12px 0 40px -10px rgba(11, 30, 71, 0.25)'
                    }
                }
            }
        };
    </script>

    <style>
        .tabular-nums { font-variant-numeric: tabular-nums; }
        .hero-dot-grid {
            background-size: 24px 24px;
            background-image: radial-gradient(circle, rgba(45, 212, 191, 0.16) 1px, transparent 1px);
        }
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 9999px; }
        .dark ::-webkit-scrollbar-thumb { background: #334155; }

        @keyframes toastSlideIn {
            from { transform: translateX(110%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .toast-enter { animation: toastSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
        .drawer-panel { transition: transform 0.32s cubic-bezier(0.16, 1, 0.3, 1); }

        /* Harmonize included auction-photos.jsp card with Tailwind theme */
        .auction-photo-card {
            border-radius: 1rem !important;
            border: 1px solid #E2E8F0 !important;
            background: #ffffff !important;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06) !important;
            overflow: hidden;
        }
        .dark .auction-photo-card {
            background: #111827 !important;
            border-color: #1e293b !important;
            color: #f1f5f9 !important;
        }
        .auction-photo-card .card-header {
            padding: 0.9rem 1.25rem !important;
            background: rgba(248, 250, 252, 0.8) !important;
            border-bottom: 1px solid #f1f5f9 !important;
            color: #0f172a !important;
        }
        .dark .auction-photo-card .card-header {
            background: rgba(15, 23, 42, 0.6) !important;
            border-bottom-color: #1e293b !important;
            color: #f8fafc !important;
        }
        .auction-photo-card .card-header h4 {
            font-size: 0.875rem !important;
            font-weight: 700 !important;
        }
        .auction-photo-card .card-body { padding: 1rem !important; }
    </style>

    <script>
        (function() {
            var saved = localStorage.getItem('sp-theme') || 'light';
            document.documentElement.setAttribute('data-theme', saved);
            if (saved === 'dark') {
                document.documentElement.classList.add('dark');
            }
        })();
    </script>
</head>

<body class="h-full bg-[#F4F7FC] dark:bg-[#0B1120] text-slate-800 dark:text-slate-100 font-sans antialiased transition-colors duration-200">

    <!-- Toast Notification Stack -->
    <div id="toastContainer" class="fixed top-5 right-5 z-[80] flex flex-col gap-2.5 max-w-sm w-full pointer-events-none"></div>

    <!-- =============================================================== -->
    <!-- SETTINGS SLIDE-IN DRAWER (Same as Supplier Main Page)           -->
    <!-- =============================================================== -->
    <div id="spSettingsOverlay" class="fixed inset-0 z-[60] bg-slate-950/60 backdrop-blur-sm hidden transition-opacity">
        <div id="spSettingsDrawer" class="drawer-panel fixed inset-y-0 right-0 z-[65] w-full max-w-md bg-white dark:bg-[#0F172A] border-l border-slate-200 dark:border-slate-800 shadow-drawer transform translate-x-full flex flex-col">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0F4C5C] text-white px-6 py-4 flex items-center justify-between border-b border-white/10">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-[#2DD4BF]">
                        <i class="fas fa-cog"></i>
                    </div>
                    <div>
                        <h5 class="text-sm font-bold text-white">Supplier Settings</h5>
                        <p class="text-[10px] font-mono text-cyan-200/80">THEME &amp; ACCOUNT SECURITY</p>
                    </div>
                </div>
                <button type="button" id="spSettingsClose" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors" aria-label="Close Settings">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-5 space-y-5">
                <div class="flex items-center justify-between p-4 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                    <div class="flex items-center gap-2.5">
                        <span class="w-8 h-8 rounded-xl bg-amber-500/15 text-amber-500 flex items-center justify-center">
                            <i class="fas fa-moon text-sm"></i>
                        </span>
                        <div>
                            <div class="text-xs font-bold text-slate-900 dark:text-white">Dark Mode</div>
                            <div class="text-[11px] text-slate-500 dark:text-slate-400">Switch marketplace contrast theme</div>
                        </div>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox" id="spDarkToggle" class="sr-only peer">
                        <div class="w-11 h-6 bg-slate-300 peer-focus:outline-none rounded-full peer dark:bg-slate-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0D9488]"></div>
                    </label>
                </div>

                <div class="p-4 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 space-y-3">
                    <div class="flex items-center gap-2 text-xs font-bold text-slate-900 dark:text-white">
                        <i class="fas fa-lock text-[#0D9488]"></i>
                        <span>Change Account Password</span>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-2.5">
                        <input type="hidden" name="action" value="changePassword">
                        <input type="password" name="oldPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Current Password" required>
                        <input type="password" name="newPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="New Password (min 6 chars)" required minlength="6">
                        <input type="password" name="confirmPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Confirm New Password" required minlength="6">
                        <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                            <i class="fas fa-save mr-1"></i> Update Password
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="min-h-screen flex">

        <!-- =============================================================== -->
        <!-- EXACT SAME LEFT SIDEBAR AS SUPPLIER MAIN PAGE (bidding/list.jsp)-->
        <!-- =============================================================== -->
        <aside id="sidebar" class="sp-sidebar fixed inset-y-0 left-0 z-40 w-[260px] bg-gradient-to-b from-[#0B1E47] via-[#102960] to-[#16367D] text-white flex flex-col border-r border-white/10 transform -translate-x-full lg:translate-x-0 transition-all duration-300 ease-in-out shadow-2xl lg:shadow-none">

            <!-- Supplexio Logo Badge -->
            <div class="p-4 border-b border-white/10">
                <a href="${pageContext.request.contextPath}/bidding" class="block bg-gradient-to-br from-[#0B1E3D] to-[#0F3D4C] px-4 py-3 rounded-2xl border border-cyan-500/25 shadow-lg hover:border-cyan-400/50 transition">
                    <div class="flex items-center justify-center gap-1.5">
                        <svg class="w-5 h-5 text-[#2DD4BF] shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z"></path>
                            <path d="M2 17l10 5 10-5"></path>
                            <path d="M2 12l10 5 10-5"></path>
                        </svg>
                        <span class="text-xl font-extrabold tracking-tight text-white">Supple<span class="text-[#2DD4BF]">xio</span></span>
                    </div>
                    <div class="text-[9px] font-bold tracking-[0.2em] text-slate-300 uppercase mt-1 flex items-center justify-center gap-1.5">
                        <span>BID BOLD</span>
                        <span class="w-1.5 h-1.5 rounded-full bg-[#F59E0B] shadow-[0_0_8px_#F59E0B]"></span>
                        <span>SOURCE SMART</span>
                    </div>
                </a>
            </div>

            <!-- Supplier Portal Tag -->
            <div class="px-4 pt-4 pb-2 flex items-center justify-between">
                <span class="text-[10px] font-mono font-semibold uppercase tracking-widest text-cyan-200/70">Supplier Portal</span>
                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-400/25">Approved</span>
            </div>

            <!-- Primary Navigation (Exact Main Page Links) -->
            <nav class="flex-1 px-3 py-1 space-y-1.5 overflow-y-auto">
                <a href="${pageContext.request.contextPath}/bidding" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl bg-white/12 border-l-4 border-[#2DD4BF] text-white font-semibold text-sm shadow-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-[#2DD4BF] shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                        <span>Live Auctions</span>
                    </div>
                    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-400/30">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                        LIVE
                    </span>
                </a>

                <a href="${pageContext.request.contextPath}/supplier-po-view" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <span>My Purchase Orders</span>
                    </div>
                </a>

                <button type="button" id="spOpenSettings" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all text-left">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        <span>Settings</span>
                    </div>
                </button>
            </nav>

            <!-- Supplier Profile Card & Logout -->
            <div class="p-3 border-t border-white/10 bg-[#081534]/50">
                <a href="${pageContext.request.contextPath}/bidding?action=profile" title="Edit Profile &amp; Account Settings" class="flex items-center gap-2.5 p-2 rounded-xl bg-white/5 hover:bg-white/12 border border-white/10 hover:border-[#2DD4BF]/50 mb-2 transition-all cursor-pointer group">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-br from-[#2DD4BF] to-[#0D9488] text-slate-950 font-extrabold text-xs flex items-center justify-center shrink-0 shadow uppercase">
                        <c:out value="${fn:substring(sessionScope.supplier.name, 0, 2)}"/>
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-xs font-bold text-white truncate group-hover:text-[#2DD4BF] transition-colors"><c:out value="${sessionScope.supplier.name}"/></div>
                        <div class="text-[10px] text-slate-300 font-mono truncate"><c:out value="${sessionScope.supplier.email}"/></div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/bidding?action=logout" class="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-slate-200 hover:text-white bg-white/5 hover:bg-rose-500/20 border border-white/10 hover:border-rose-400/30 transition-all">
                    <svg class="w-3.5 h-3.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <!-- Mobile Sidebar Backdrop -->
        <div id="sidebarBackdrop" onclick="toggleMobileSidebar()" class="fixed inset-0 z-30 bg-slate-950/60 backdrop-blur-sm hidden lg:hidden"></div>

        <!-- =============================================================== -->
        <!-- MAIN WORKSPACE AREA (Shifted Upwards, No Top Breadcrumb Bar)    -->
        <!-- =============================================================== -->
        <main class="flex-1 lg:ml-[260px] flex flex-col min-w-0">

            <!-- Mobile Header Bar -->
            <div class="lg:hidden sticky top-0 z-20 bg-[#0B1E47] text-white px-4 py-3 flex items-center justify-between border-b border-white/10 shadow">
                <div class="flex items-center gap-3">
                    <button type="button" onclick="toggleMobileSidebar()" class="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white" aria-label="Open Navigation">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                    <span class="font-extrabold tracking-tight text-base">Supple<span class="text-[#2DD4BF]">xio</span></span>
                </div>
            </div>

            <div class="px-4 sm:px-6 lg:px-7 pt-4 sm:pt-5 pb-6 max-w-[1520px] w-full mx-auto space-y-5">

                <!-- Servlet Success / Error Alerts -->
                <c:if test="${not empty success}">
                    <div class="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold flex items-center justify-between">
                        <span><i class="fas fa-check-circle mr-2"></i><c:out value="${success}"/></span>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700 font-bold text-sm">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold flex items-center justify-between">
                        <span><i class="fas fa-exclamation-triangle mr-2"></i><c:out value="${error}"/></span>
                        <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-700 font-bold text-sm">&times;</button>
                    </div>
                </c:if>

                <!-- Compute User's Rank & Bid Stats -->
                <c:set var="userIsLowest" value="${not empty allBids and allBids[0][0].supplierId == sessionScope.supplier.id}" />
                <c:set var="userHasBid" value="${not empty supplierBids}" />

                <!-- ======================================================= -->
                <!-- DARK NAVY AUCTION COMMAND HERO BANNER                   -->
                <!-- ======================================================= -->
                <section class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0F3D4C] text-white p-6 lg:p-7 shadow-lg border border-white/10">
                    <div class="absolute inset-0 hero-dot-grid opacity-75 pointer-events-none"></div>
                    <div class="absolute -top-24 -right-16 w-72 h-72 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-6">
                        <div class="space-y-2.5">
                            <div class="flex flex-wrap items-center gap-2">
                                <a href="${pageContext.request.contextPath}/bidding" class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-white/10 hover:bg-white/20 text-cyan-100 border border-white/15 transition">
                                    <i class="fas fa-arrow-left text-[9px]"></i>
                                    All Auctions
                                </a>
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-400/35">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                                    <c:choose>
                                        <c:when test="${isAuctionActive}">LIVE REVERSE AUCTION</c:when>
                                        <c:otherwise><c:out value="${auction.status}"/></c:otherwise>
                                    </c:choose>
                                </span>
                                <c:choose>
                                    <c:when test="${userIsLowest}">
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-emerald-500/25 text-emerald-200 border border-emerald-400/40">
                                            Your Status: L1 Lowest Bid
                                        </span>
                                    </c:when>
                                    <c:when test="${userHasBid}">
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-rose-500/25 text-rose-200 border border-rose-400/40">
                                            Your Status: Outbid — Counter Now
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-amber-500/20 text-amber-200 border border-amber-400/35">
                                            No Bids Placed Yet
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div>
                                <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white"><c:out value="${auction.productName}"/></h1>
                                <p class="text-xs sm:text-sm text-cyan-100/80 font-mono mt-1">
                                    Lot #<c:out value="${auction.id}"/> • Open Supplier Marketplace
                                </p>
                            </div>
                        </div>

                        <div class="flex flex-col sm:flex-row sm:items-center gap-4">
                            <!-- High-Contrast Live Countdown Module -->
                            <div class="bg-slate-950/35 backdrop-blur-md border border-white/15 rounded-2xl px-4 py-3">
                                <div class="text-[10px] font-mono uppercase tracking-widest text-rose-300 font-bold mb-1.5 flex items-center gap-1.5">
                                    <span class="w-1.5 h-1.5 rounded-full bg-rose-400 animate-pulse"></span>
                                    Time Remaining
                                </div>
                                <div class="flex items-center gap-2 font-mono tabular-nums" id="heroCountdownWrap" data-end="${auction.endTime.time}">
                                    <div class="bg-white/10 border border-white/10 rounded-xl px-2.5 py-1.5 text-center min-w-[50px]">
                                        <div id="cdDays" class="text-lg font-extrabold text-white leading-none">--</div>
                                        <div class="text-[9px] text-cyan-200/80 uppercase mt-0.5">Days</div>
                                    </div>
                                    <span class="text-white/50 font-bold">:</span>
                                    <div class="bg-white/10 border border-white/10 rounded-xl px-2.5 py-1.5 text-center min-w-[44px]">
                                        <div id="cdHours" class="text-lg font-extrabold text-white leading-none">--</div>
                                        <div class="text-[9px] text-cyan-200/80 uppercase mt-0.5">Hrs</div>
                                    </div>
                                    <span class="text-white/50 font-bold">:</span>
                                    <div class="bg-white/10 border border-white/10 rounded-xl px-2.5 py-1.5 text-center min-w-[44px]">
                                        <div id="cdMins" class="text-lg font-extrabold text-white leading-none">--</div>
                                        <div class="text-[9px] text-cyan-200/80 uppercase mt-0.5">Min</div>
                                    </div>
                                    <span class="text-white/50 font-bold">:</span>
                                    <div class="bg-rose-500/20 border border-rose-400/35 rounded-xl px-2.5 py-1.5 text-center min-w-[44px]">
                                        <div id="cdSecs" class="text-lg font-extrabold text-rose-300 leading-none">--</div>
                                        <div class="text-[9px] text-rose-200 uppercase mt-0.5">Sec</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Quick Message Buyer CTA -->
                            <button type="button" onclick="openAuctionChat()" class="inline-flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-white/12 hover:bg-white/20 text-white font-bold text-xs border border-white/20 backdrop-blur-sm transition-all self-start sm:self-center">
                                <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                </svg>
                                <span>Message Buyer</span>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- EXECUTIVE KPI SUMMARY STRIP (4 Compact Cards)           -->
                <!-- ======================================================= -->
                <section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-[#0D9488] dark:text-[#2DD4BF]">Current Lowest Price (L1)</p>
                            <div class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">
                                ₹<fmt:formatNumber value="${auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                            </div>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400 font-mono tabular-nums mt-1">
                                ₹<fmt:formatNumber value="${auction.currentPrice / (auction.requiredQuantity > 0 ? auction.requiredQuantity : 1)}" minFractionDigits="2" maxFractionDigits="2"/> / unit
                            </p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-teal-500/12 text-[#0D9488] dark:text-[#2DD4BF] flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Starting Ceiling Price</p>
                            <div class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">
                                ₹<fmt:formatNumber value="${auction.startingPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                            </div>
                            <div class="mt-1 flex items-center gap-1.5">
                                <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-mono font-bold bg-emerald-500/12 text-emerald-700 dark:text-emerald-300 tabular-nums">
                                    -₹<fmt:formatNumber value="${auction.startingPrice - auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                                </span>
                                <span class="text-[11px] text-slate-400">below ceiling</span>
                            </div>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-blue-500/10 text-[#1E3A8A] dark:text-blue-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div class="min-w-0">
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Quantity &amp; Schedule</p>
                            <div class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">
                                <c:out value="${auction.requiredQuantity}"/> Units
                            </div>
                            <p class="text-[10.5px] text-slate-500 dark:text-slate-400 font-mono tabular-nums mt-1 truncate">
                                <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm"/> → <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/>
                            </p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border ${userIsLowest ? 'border-emerald-200 dark:border-emerald-500/35' : 'border-[#E2E8F0] dark:border-slate-800'} p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Your Bid Position</p>
                            <div class="mt-1.5 text-xl font-extrabold ${userIsLowest ? 'text-emerald-600 dark:text-emerald-400' : (userHasBid ? 'text-rose-600 dark:text-rose-400' : 'text-slate-800 dark:text-white')} tracking-tight">
                                <c:choose>
                                    <c:when test="${userIsLowest}">#1 (Lowest Bid)</c:when>
                                    <c:when test="${userHasBid}">Outbid</c:when>
                                    <c:otherwise>Not Placed</c:otherwise>
                                </c:choose>
                            </div>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400 font-mono mt-1"><c:out value="${fn:length(allBids)}"/> Bids Recorded</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl ${userIsLowest ? 'bg-emerald-500/12 text-emerald-600 dark:text-emerald-400' : 'bg-slate-100 dark:bg-slate-800 text-slate-500'} flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- TWO-COLUMN MAIN WORKSPACE (67% Left / 33% Right)        -->
                <!-- ======================================================= -->
                <section class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <!-- LEFT COLUMN (lg:col-span-8) -->
                    <div class="lg:col-span-8 space-y-6">

                        <!-- 1. PLACE YOUR BID CARD (Real POST /bidding?action=bid) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap items-center justify-between gap-2 bg-slate-50/70 dark:bg-slate-900/50">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-[#1E3A8A] to-[#0D9488] text-white flex items-center justify-center shadow-sm">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Place Your Bid</h2>
                                        <p class="text-[11px] text-slate-500 dark:text-slate-400">Submit a binding lower price to secure or defend L1 position.</p>
                                    </div>
                                </div>
                                <span class="px-3 py-1 rounded-full text-xs font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-[#2DD4BF] border border-blue-200 dark:border-blue-800 tabular-nums">
                                    Must be &lt; ₹<fmt:formatNumber value="${auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                                </span>
                            </div>

                            <div class="p-5">
                                <c:choose>
                                    <c:when test="${isAuctionActive}">
                                        <form id="placeBidForm" method="post" action="${pageContext.request.contextPath}/bidding" onsubmit="return validateBidSubmit()" class="space-y-4">
                                            <input type="hidden" name="action" value="bid">
                                            <input type="hidden" name="auctionId" value="${auction.id}">

                                            <div>
                                                <label for="amount" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Your Bid Amount (₹)</label>
                                                <div class="flex flex-col sm:flex-row gap-3">
                                                    <div class="relative flex-1">
                                                        <span class="absolute inset-y-0 left-0 pl-4 flex items-center text-lg font-mono font-bold text-slate-400">₹</span>
                                                        <input type="number" step="0.01" min="0" max="${auction.currentPrice}" id="amount" name="amount" oninput="updateBidPreview()" required placeholder="Enter lower bid amount..." class="w-full pl-9 pr-4 py-3 text-lg font-mono font-extrabold tabular-nums bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all">
                                                    </div>
                                                    <button type="submit" id="placeBidBtn" class="px-6 py-3 rounded-xl bg-gradient-to-r from-[#1E3A8A] via-[#154B87] to-[#0D9488] hover:opacity-95 active:scale-[0.99] text-white font-bold text-sm shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2 whitespace-nowrap disabled:opacity-50">
                                                        <i class="fas fa-gavel"></i>
                                                        <span>Place Binding Bid</span>
                                                    </button>
                                                </div>
                                            </div>

                                            <!-- Quick Undercut Preset Chips -->
                                            <div class="flex flex-wrap items-center gap-2">
                                                <span class="text-[11px] font-semibold text-slate-500 dark:text-slate-400 mr-1">Quick Undercut:</span>
                                                <button type="button" onclick="applyQuickUndercut('fixed', 100)" class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-₹100</button>
                                                <button type="button" onclick="applyQuickUndercut('fixed', 500)" class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-₹500</button>
                                                <button type="button" onclick="applyQuickUndercut('fixed', 1000)" class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-₹1,000</button>
                                                <button type="button" onclick="applyQuickUndercut('percent', 0.5)" class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-0.5%</button>
                                                <button type="button" onclick="applyQuickUndercut('percent', 1.0)" class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-1.0%</button>
                                            </div>

                                            <!-- Validation Error Banner -->
                                            <div id="bidErrorBanner" class="hidden p-3 rounded-xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-800/60 text-xs font-semibold text-rose-600 dark:text-rose-300 flex items-center gap-2">
                                                <i class="fas fa-exclamation-circle"></i>
                                                <span id="bidErrorText">Your bid must be strictly lower than the current price.</span>
                                            </div>

                                            <!-- Live Dynamic Preview Strip -->
                                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900/80 border border-slate-200/80 dark:border-slate-800 text-xs">
                                                <div>
                                                    <span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">New Unit Rate</span>
                                                    <span id="previewUnitRate" class="font-mono tabular-nums font-bold text-slate-800 dark:text-slate-100 mt-0.5 block">—</span>
                                                </div>
                                                <div>
                                                    <span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">Reduction vs Current</span>
                                                    <span id="previewReduction" class="font-mono tabular-nums font-bold text-emerald-600 dark:text-emerald-400 mt-0.5 block">—</span>
                                                </div>
                                                <div>
                                                    <span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">Total Savings vs Ceiling</span>
                                                    <span id="previewCeilingSavings" class="font-mono tabular-nums font-bold text-[#0D9488] dark:text-[#2DD4BF] mt-0.5 block">—</span>
                                                </div>
                                            </div>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="p-4 rounded-xl bg-blue-50 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-800 text-xs font-semibold text-blue-800 dark:text-blue-200">
                                            <c:choose>
                                                <c:when test="${currentTimeMillis < auction.startTime.time}">
                                                    <i class="fas fa-clock mr-1.5"></i> This auction has not started yet. It will begin on <fmt:formatDate value="${auction.startTime}" pattern="MMM dd, yyyy HH:mm:ss"/>.
                                                </c:when>
                                                <c:when test="${currentTimeMillis > auction.endTime.time || auction.status == 'COMPLETED'}">
                                                    <i class="fas fa-flag-checkered mr-1.5"></i> This auction has ended on <fmt:formatDate value="${auction.endTime}" pattern="MMM dd, yyyy HH:mm:ss"/>.
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fas fa-exclamation-circle mr-1.5"></i> This auction is not active.
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- 2. BID PRICE TREND CARD (Chart.js from /api/bids/chart) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between bg-slate-50/70 dark:bg-slate-900/50">
                                <div>
                                    <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Bid Price Trend</h2>
                                    <p class="text-[11px] text-slate-500 dark:text-slate-400">Showing bid price trend over time</p>
                                </div>
                                <span class="px-2.5 py-1 rounded-lg text-[10px] font-mono font-bold bg-teal-50 dark:bg-teal-950/50 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200/80 dark:border-teal-800">
                                    LIVE TELEMETRY
                                </span>
                            </div>
                            <div class="p-5">
                                <div class="chart-container relative h-[280px] w-full">
                                    <canvas id="bidChart"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- 3. ALL BIDS LEDGER CARD (Real ${allBids}) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-wrap items-center justify-between gap-3 bg-slate-50/70 dark:bg-slate-900/50">
                                <div class="flex items-center gap-2.5">
                                    <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">All Bids</h2>
                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-cyan-300 border border-blue-200 dark:border-blue-800">
                                        <c:out value="${fn:length(allBids)}"/> Bids
                                    </span>
                                </div>

                                <div class="inline-flex items-center bg-slate-100 dark:bg-slate-800 p-1 rounded-xl border border-slate-200/80 dark:border-slate-700 text-xs font-semibold">
                                    <button type="button" id="filterAllBidsBtn" onclick="filterAllBids('all')" class="px-3 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all">
                                        All Bids
                                    </button>
                                    <button type="button" id="filterMyBidsBtn" onclick="filterAllBids('mine')" class="px-3 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all">
                                        My Bids
                                    </button>
                                </div>
                            </div>

                            <div class="overflow-x-auto">
                                <table class="w-full text-left border-collapse">
                                    <thead>
                                        <tr class="bg-slate-50/90 dark:bg-slate-900/70 border-b border-[#E2E8F0] dark:border-slate-800 text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                            <th class="py-3 px-5">Supplier</th>
                                            <th class="py-3 px-4 text-right">Bid Amount</th>
                                            <th class="py-3 px-4">Bid Time</th>
                                            <th class="py-3 px-5 text-right">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody id="allBidsTableBody" class="divide-y divide-slate-100 dark:divide-slate-800 text-xs">
                                        <c:forEach var="bidInfo" items="${allBids}" varStatus="status">
                                            <c:set var="bid" value="${bidInfo[0]}" />
                                            <c:set var="supplierName" value="${bidInfo[1]}" />
                                            <c:set var="isMine" value="${bid.supplierId == sessionScope.supplier.id}" />
                                            <tr class="bid-row ${status.index == 0 ? 'bg-emerald-50/50 dark:bg-emerald-950/20' : 'hover:bg-slate-50/80 dark:hover:bg-slate-800/40'} transition-colors" data-mine="${isMine}">
                                                <td class="py-3 px-5 font-semibold text-slate-800 dark:text-slate-100">
                                                    <c:out value="${supplierName}"/>
                                                    <c:if test="${isMine}"> <span class="text-[10px] font-mono text-[#0D9488] dark:text-[#2DD4BF]">(You)</span></c:if>
                                                </td>
                                                <td class="py-3 px-4 text-right font-mono tabular-nums font-bold text-slate-900 dark:text-white">
                                                    ₹<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2"/>
                                                </td>
                                                <td class="py-3 px-4 font-mono tabular-nums text-slate-500 dark:text-slate-400">
                                                    <fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                                </td>
                                                <td class="py-3 px-5 text-right">
                                                    <c:choose>
                                                        <c:when test="${status.index == 0}">
                                                            <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">Lowest Bid</span>
                                                        </c:when>
                                                        <c:when test="${isMine}">
                                                            <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-500/15 text-[#1E3A8A] dark:text-cyan-300 border border-blue-500/30">Your Bid</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Competing Bid</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty allBids}">
                                            <tr>
                                                <td colspan="4" class="py-8 text-center text-slate-400">No bids have been placed yet.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>

                    <!-- RIGHT COLUMN (lg:col-span-4) -->
                    <div class="lg:col-span-4 space-y-6">

                        <!-- 1. REAL PRODUCT PHOTOS WIDGET -->
                        <jsp:include page="/WEB-INF/views/common/auction-photos.jsp" />

                        <!-- 2. BUYER MESSAGES CARD -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between bg-slate-50/70 dark:bg-slate-900/50">
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Buyer Messages</h3>
                                <span id="unreadMsgPill" class="hidden inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/15 text-amber-700 dark:text-amber-300 border border-amber-500/30">
                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
                                    <span data-count-for="${auction.id}">0</span> New
                                </span>
                            </div>
                            <div class="p-4 space-y-3.5">
                                <p class="text-xs text-slate-600 dark:text-slate-400 leading-relaxed">
                                    Ask clarifications, confirm documents, or respond to buyer questions for this auction.
                                </p>
                                <button type="button" id="openAuctionChat" onclick="openAuctionChat()" class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0D9488] hover:opacity-95 text-white font-bold text-xs shadow-sm transition-all flex items-center justify-center gap-2">
                                    <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                    </svg>
                                    <span>Message Buyer</span>
                                </button>
                            </div>
                        </div>

                        <!-- 3. YOUR BIDS CARD (Real ${supplierBids}) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between bg-slate-50/70 dark:bg-slate-900/50">
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Your Bids</h3>
                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-teal-50 dark:bg-teal-950/50 text-[#0D9488] dark:text-[#2DD4BF] border border-teal-200 dark:border-teal-800">
                                    <c:out value="${fn:length(supplierBids)}"/> Placed
                                </span>
                            </div>
                            <div class="overflow-x-auto">
                                <table class="w-full text-left border-collapse">
                                    <thead>
                                        <tr class="bg-slate-50 dark:bg-slate-900/70 border-b border-slate-100 dark:border-slate-800 text-[10px] font-semibold uppercase tracking-wider text-slate-400">
                                            <th class="py-2.5 px-4">Amount</th>
                                            <th class="py-2.5 px-4 text-right">Time</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100 dark:divide-slate-800 text-xs">
                                        <c:forEach var="bid" items="${supplierBids}">
                                            <tr class="hover:bg-slate-50/60 dark:hover:bg-slate-800/30">
                                                <td class="py-2.5 px-4 font-mono tabular-nums font-bold text-slate-900 dark:text-white">
                                                    ₹<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2"/>
                                                </td>
                                                <td class="py-2.5 px-4 text-right font-mono tabular-nums text-slate-500 dark:text-slate-400">
                                                    <fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty supplierBids}">
                                            <tr>
                                                <td colspan="2" class="py-6 text-center text-slate-400">You haven't placed any bids yet.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- 4. BIDDING TIPS CARD -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center gap-2 bg-slate-50/70 dark:bg-slate-900/50">
                                <svg class="w-4 h-4 text-[#1E3A8A] dark:text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Bidding Tips</h3>
                            </div>
                            <ul class="divide-y divide-slate-100 dark:divide-slate-800 text-xs text-slate-600 dark:text-slate-300">
                                <li class="p-3.5 flex items-start gap-2.5">
                                    <span class="w-5 h-5 rounded-full bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 font-bold text-[10px]">i</span>
                                    <span>Your bid must be lower than the current price.</span>
                                </li>
                                <li class="p-3.5 flex items-start gap-2.5">
                                    <span class="w-5 h-5 rounded-full bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 font-bold text-[10px]">i</span>
                                    <span>Open supplier access means faster competition, so bid early and monitor the trend.</span>
                                </li>
                                <li class="p-3.5 flex items-start gap-2.5">
                                    <span class="w-5 h-5 rounded-full bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-[#2DD4BF] flex items-center justify-center shrink-0 mt-0.5 font-bold text-[10px]">i</span>
                                    <span>You can place multiple bids until the auction ends.</span>
                                </li>
                                <li class="p-3.5 flex items-start gap-2.5">
                                    <span class="w-5 h-5 rounded-full bg-amber-50 dark:bg-amber-950/50 text-amber-600 dark:text-amber-400 flex items-center justify-center shrink-0 mt-0.5 font-bold text-[10px]">!</span>
                                    <span class="font-medium text-slate-700 dark:text-slate-200">All bids are binding and cannot be withdrawn.</span>
                                </li>
                            </ul>
                        </div>

                    </div>
                </section>

                <!-- Footer -->
                <footer class="pt-3 pb-6 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500 border-t border-slate-200/70 dark:border-slate-800">
                    <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                    <p class="font-mono text-[11px] mt-1 sm:mt-0">Lot #<c:out value="${auction.id}"/> • Real-Time Binding Reverse Auction</p>
                </footer>
            </div>
        </main>
    </div>

    <!-- =================================================================== -->
    <!-- BUYER DESK MESSAGING MODAL (Real /auction-messages API)             -->
    <!-- =================================================================== -->
    <div id="auctionChatPanel" class="fixed inset-0 z-50 bg-slate-950/60 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden flex flex-col max-h-[85vh]">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0F3D4C] text-white p-4 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-cyan-500/20 border border-cyan-400/30 flex items-center justify-center text-[#2DD4BF]">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-white">Buyer Procurement Desk</h3>
                        <p class="text-[11px] font-mono text-cyan-200/90">Lot #<c:out value="${auction.id}"/> • <c:out value="${auction.productName}"/></p>
                    </div>
                </div>
                <button type="button" id="chatCloseBtn" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <div id="auctionChatThread" class="p-4 flex-1 overflow-y-auto space-y-3 bg-slate-50/70 dark:bg-slate-900/60 min-h-[250px]"></div>

            <form id="auctionChatForm" class="p-3.5 bg-white dark:bg-[#111827] border-t border-slate-200 dark:border-slate-800 flex items-center gap-2">
                <input type="text" id="auctionChatInput" required autocomplete="off" placeholder="Type your message to the buyer..." class="flex-1 px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100">
                <button type="submit" class="px-4 py-2 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] hover:opacity-95 text-white text-xs font-bold shadow transition-all">
                    Send
                </button>
            </form>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- FLOATING WARM-AMBER AI BIDDING COPILOT                              -->
    <!-- =================================================================== -->
    <div id="aiCopilotPopover" class="fixed bottom-24 right-5 z-50 w-80 sm:w-96 max-w-[calc(100vw-2.5rem)] bg-white dark:bg-[#111827] border border-amber-400/40 rounded-2xl shadow-2xl hidden flex-col overflow-hidden">
        <div class="bg-gradient-to-r from-[#F59E0B] to-amber-400 text-slate-950 px-4 py-3 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-8 h-8 rounded-full bg-slate-950 text-amber-400 flex items-center justify-center shadow">
                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2a2 2 0 012 2v1h3a3 3 0 013 3v8a3 3 0 01-3 3H7a3 3 0 01-3-3V8a3 3 0 013-3h3V4a2 2 0 012-2zm-3 9a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm6 0a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm-5 5h4a1 1 0 110 2h-4a1 1 0 110-2z"/>
                    </svg>
                </div>
                <div>
                    <h4 class="text-xs font-extrabold leading-tight">Supplexio AI Bidding Copilot</h4>
                    <p class="text-[10px] font-mono font-bold opacity-80">LIVE REVERSE AUCTION ADVISOR</p>
                </div>
            </div>
            <button type="button" onclick="toggleAiCopilot()" class="p-1 rounded-lg hover:bg-black/10 text-slate-950">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>

        <div id="copilotMessages" class="p-3.5 h-60 overflow-y-auto space-y-2.5 text-xs bg-slate-50/70 dark:bg-slate-900/50">
            <div class="p-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200/80 dark:border-slate-700 text-slate-700 dark:text-slate-200 leading-relaxed">
                Hi <strong><c:out value="${sessionScope.supplier.name}"/></strong>! Current L1 on <strong><c:out value="${auction.productName}"/></strong> is <strong>₹<fmt:formatNumber value="${auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>. Ask me for bid recommendations or trend insights.
            </div>
        </div>

        <div class="px-3 py-2 bg-white dark:bg-[#111827] border-t border-slate-100 dark:border-slate-800 flex flex-wrap gap-1.5">
            <button type="button" onclick="askCopilot('Suggest optimal undercut bid')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Suggest optimal undercut bid
            </button>
            <button type="button" onclick="askCopilot('Analyze price trend')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Analyze price trend
            </button>
        </div>

        <form onsubmit="handleCopilotSubmit(event)" class="p-2.5 bg-white dark:bg-[#111827] border-t border-slate-200 dark:border-slate-800 flex gap-2">
            <input type="text" id="copilotInput" placeholder="Ask AI bidding advisor..." class="flex-1 px-3 py-1.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-amber-500 text-slate-800 dark:text-slate-100">
            <button type="submit" class="px-3 py-1.5 rounded-xl bg-[#F59E0B] hover:bg-amber-400 text-slate-950 font-bold text-xs transition-colors">
                Ask
            </button>
        </form>
    </div>

    <button type="button" onclick="toggleAiCopilot()" title="Supplexio AI Bidding Copilot" class="fixed bottom-5 right-5 z-40 w-14 h-14 rounded-full bg-gradient-to-tr from-[#F59E0B] to-amber-300 text-slate-950 shadow-2xl hover:scale-105 active:scale-95 transition-transform flex items-center justify-center ring-4 ring-amber-500/25">
        <svg class="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2a2 2 0 012 2v1h3a3 3 0 013 3v8a3 3 0 01-3 3H7a3 3 0 01-3-3V8a3 3 0 013-3h3V4a2 2 0 012-2zm-3 9a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm6 0a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm-5 5h4a1 1 0 110 2h-4a1 1 0 110-2z"/>
        </svg>
    </button>

    <!-- =================================================================== -->
    <!-- CORE APPLICATION SCRIPT (Real Servlet Endpoints & Countdown)        -->
    <!-- =================================================================== -->
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        var auctionId = '${auction.id}';
        var currentPrice = ${auction.currentPrice};
        var startingPrice = ${auction.startingPrice};
        var requiredQty = ${auction.requiredQuantity > 0 ? auction.requiredQuantity : 1};
        var endTimeMs = ${auction.endTime.time};

        function formatINR(num) {
            return '₹' + Number(num || 0).toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        function escapeHtml(str) {
            if (!str) return '';
            return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        // Countdown Timer
        function updateCountdown() {
            var now = Date.now();
            var distance = endTimeMs - now;
            if (distance <= 0) {
                document.getElementById('cdDays').textContent = '00';
                document.getElementById('cdHours').textContent = '00';
                document.getElementById('cdMins').textContent = '00';
                document.getElementById('cdSecs').textContent = '00';
                var btn = document.getElementById('placeBidBtn');
                if (btn) {
                    btn.disabled = true;
                    btn.textContent = 'Auction Ended';
                }
                return;
            }
            var days = Math.floor(distance / (1000 * 60 * 60 * 24));
            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var mins = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var secs = Math.floor((distance % (1000 * 60)) / 1000);
            document.getElementById('cdDays').textContent = String(days);
            document.getElementById('cdHours').textContent = String(hours).padStart(2, '0');
            document.getElementById('cdMins').textContent = String(mins).padStart(2, '0');
            document.getElementById('cdSecs').textContent = String(secs).padStart(2, '0');
        }
        updateCountdown();
        setInterval(updateCountdown, 1000);

        // Quick Undercut Presets & Live Bid Preview
        function applyQuickUndercut(type, val) {
            var input = document.getElementById('amount');
            if (!input) return;
            var nextVal = (type === 'fixed') ? (currentPrice - val) : (currentPrice * (1 - val / 100));
            input.value = Math.max(0.01, nextVal).toFixed(2);
            updateBidPreview();
        }

        function updateBidPreview() {
            var input = document.getElementById('amount');
            var errBanner = document.getElementById('bidErrorBanner');
            var errText = document.getElementById('bidErrorText');
            var btn = document.getElementById('placeBidBtn');
            var unitEl = document.getElementById('previewUnitRate');
            var redEl = document.getElementById('previewReduction');
            var ceilEl = document.getElementById('previewCeilingSavings');
            if (!input) return false;

            var val = parseFloat(input.value);
            if (isNaN(val) || val <= 0) {
                errBanner.classList.add('hidden');
                unitEl.textContent = '—';
                redEl.textContent = '—';
                ceilEl.textContent = '—';
                if (btn) btn.disabled = false;
                return false;
            }
            if (val >= currentPrice) {
                errText.textContent = 'Bid must be strictly lower than current L1 (' + formatINR(currentPrice) + ').';
                errBanner.classList.remove('hidden');
                if (btn) btn.disabled = true;
                return false;
            }
            errBanner.classList.add('hidden');
            if (btn) btn.disabled = false;
            var diff = currentPrice - val;
            var pct = ((diff / currentPrice) * 100).toFixed(2);
            var ceilDiff = Math.max(0, startingPrice - val);
            unitEl.textContent = formatINR(val / requiredQty) + ' / unit';
            redEl.textContent = '-' + formatINR(diff) + ' (-' + pct + '%)';
            ceilEl.textContent = '-' + formatINR(ceilDiff);
            return true;
        }

        function validateBidSubmit() {
            var input = document.getElementById('amount');
            var val = parseFloat(input ? input.value : 0);
            if (isNaN(val) || val <= 0 || val >= currentPrice) {
                updateBidPreview();
                showToast('Bid must be strictly lower than ' + formatINR(currentPrice), 'error');
                return false;
            }
            return true;
        }

        // All Bids / My Bids Filter
        function filterAllBids(mode) {
            var allBtn = document.getElementById('filterAllBidsBtn');
            var mineBtn = document.getElementById('filterMyBidsBtn');
            if (mode === 'all') {
                allBtn.className = 'px-3 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                mineBtn.className = 'px-3 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            } else {
                mineBtn.className = 'px-3 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                allBtn.className = 'px-3 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            }
            document.querySelectorAll('#allBidsTableBody tr.bid-row').forEach(function(row) {
                var isMine = row.getAttribute('data-mine') === 'true';
                row.style.display = (mode === 'all' || isMine) ? '' : 'none';
            });
        }

        // Real Bid Price Trend Chart (/api/bids/chart)
        document.addEventListener('DOMContentLoaded', function() {
            var canvas = document.getElementById('bidChart');
            if (canvas && typeof Chart !== 'undefined') {
                fetch(contextPath + '/api/bids/chart?auctionId=' + encodeURIComponent(auctionId))
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (!data || !data.length) {
                            document.querySelector('.chart-container').innerHTML =
                                '<div class="h-full flex items-center justify-center text-xs text-slate-400">No bid history available yet to plot trend.</div>';
                            return;
                        }
                        var labels = data.map(function(item) { return new Date(item.bidTime).toLocaleString(); });
                        var amounts = data.map(function(item) { return item.bidAmount; });
                        var ctx = canvas.getContext('2d');
                        var grad = ctx.createLinearGradient(0, 0, 0, 260);
                        grad.addColorStop(0, 'rgba(13, 148, 136, 0.25)');
                        grad.addColorStop(1, 'rgba(13, 148, 136, 0.01)');

                        new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels: labels,
                                datasets: [{
                                    label: 'Bid Amount (₹)',
                                    data: amounts,
                                    borderColor: '#0D9488',
                                    backgroundColor: grad,
                                    fill: true,
                                    tension: 0.25,
                                    borderWidth: 2.5,
                                    pointRadius: 4,
                                    pointBackgroundColor: '#1E3A8A'
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { display: false },
                                    tooltip: {
                                        callbacks: {
                                            label: function(c) { return ' Bid: ' + formatINR(c.parsed.y); }
                                        }
                                    }
                                },
                                scales: {
                                    y: {
                                        grid: { color: 'rgba(148, 163, 184, 0.15)' },
                                        ticks: {
                                            font: { size: 10, family: 'JetBrains Mono' },
                                            callback: function(v) { return '₹' + Number(v).toLocaleString('en-IN'); }
                                        }
                                    },
                                    x: {
                                        grid: { display: false },
                                        ticks: { font: { size: 10, family: 'JetBrains Mono' } }
                                    }
                                }
                            }
                        });
                    })
                    .catch(function() {});
            }

            // Settings Drawer Controls
            var overlay = document.getElementById('spSettingsOverlay');
            var drawer = document.getElementById('spSettingsDrawer');
            var openBtn = document.getElementById('spOpenSettings');
            var closeBtn = document.getElementById('spSettingsClose');
            function openSettings() {
                overlay.classList.remove('hidden');
                setTimeout(function() { drawer.classList.remove('translate-x-full'); }, 10);
            }
            function closeSettings() {
                drawer.classList.add('translate-x-full');
                setTimeout(function() { overlay.classList.add('hidden'); }, 280);
            }
            if (openBtn) openBtn.addEventListener('click', openSettings);
            if (closeBtn) closeBtn.addEventListener('click', closeSettings);
            if (overlay) overlay.addEventListener('click', function(e) { if (e.target === overlay) closeSettings(); });

            var darkTog = document.getElementById('spDarkToggle');
            if (darkTog) {
                darkTog.checked = (localStorage.getItem('sp-theme') === 'dark');
                darkTog.addEventListener('change', function() {
                    var theme = this.checked ? 'dark' : 'light';
                    document.documentElement.setAttribute('data-theme', theme);
                    document.documentElement.classList.toggle('dark', this.checked);
                    localStorage.setItem('sp-theme', theme);
                });
            }
        });

        // Real Buyer Messaging (/auction-messages)
        function setMessageBadge(count) {
            var badge = document.querySelector('[data-count-for="' + auctionId + '"]');
            var pill = document.getElementById('unreadMsgPill');
            if (badge) badge.textContent = count;
            if (pill) {
                if (count > 0) pill.classList.remove('hidden');
                else pill.classList.add('hidden');
            }
        }

        function loadMessageCount() {
            fetch(contextPath + '/auction-messages?mode=counts&auctionId=' + encodeURIComponent(auctionId))
                .then(function(r) { return r.json(); })
                .then(function(counts) { setMessageBadge(counts[auctionId] || 0); })
                .catch(function() {});
        }

        function renderAuctionMessages(messages) {
            var thread = document.getElementById('auctionChatThread');
            thread.innerHTML = '';
            if (!messages || !messages.length) {
                thread.innerHTML = '<div class="text-xs text-slate-400 text-center py-10">No messages yet. Ask the buyer a clarification.</div>';
                return;
            }
            messages.forEach(function(item) {
                var isMine = item.senderType === 'SUPPLIER';
                var wrap = document.createElement('div');
                wrap.className = 'flex flex-col ' + (isMine ? 'items-end' : 'items-start');
                var bubble = document.createElement('div');
                bubble.className = isMine
                    ? 'max-w-[85%] rounded-2xl px-3.5 py-2.5 text-xs leading-relaxed bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white rounded-tr-sm shadow-sm'
                    : 'max-w-[85%] rounded-2xl px-3.5 py-2.5 text-xs leading-relaxed bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-800 dark:text-slate-100 rounded-tl-sm';
                var senderEl = document.createElement('div');
                senderEl.className = 'text-[10px] font-bold mb-0.5 ' + (isMine ? 'text-cyan-100' : 'text-[#0D9488] dark:text-[#2DD4BF]');
                senderEl.textContent = isMine ? 'You' : 'Buyer Procurement Desk';
                var bodyEl = document.createElement('p');
                bodyEl.textContent = item.message;
                bubble.appendChild(senderEl);
                bubble.appendChild(bodyEl);
                wrap.appendChild(bubble);
                thread.appendChild(wrap);
            });
            thread.scrollTop = thread.scrollHeight;
        }

        function openAuctionChat() {
            var modal = document.getElementById('auctionChatPanel');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            fetch(contextPath + '/auction-messages?auctionId=' + encodeURIComponent(auctionId))
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    renderAuctionMessages(data.messages || []);
                    setMessageBadge(0);
                })
                .catch(function() { renderAuctionMessages([]); });
        }

        document.getElementById('chatCloseBtn').addEventListener('click', function() {
            var modal = document.getElementById('auctionChatPanel');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        });

        document.getElementById('auctionChatForm').addEventListener('submit', function(event) {
            event.preventDefault();
            var input = document.getElementById('auctionChatInput');
            var message = input.value.trim();
            if (!message) return;

            var params = new URLSearchParams();
            params.append('action', 'send');
            params.append('auctionId', auctionId);
            params.append('message', message);

            fetch(contextPath + '/auction-messages', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(function() {
                input.value = '';
                return fetch(contextPath + '/auction-messages?auctionId=' + encodeURIComponent(auctionId));
            }).then(function(r) { return r.json(); })
              .then(function(data) {
                  renderAuctionMessages(data.messages || []);
                  showToast('Message sent to Buyer Desk', 'success');
              });
        });

        loadMessageCount();
        setInterval(loadMessageCount, 15000);

        // Mobile Sidebar & Toasts
        function toggleMobileSidebar() {
            document.getElementById('sidebar').classList.toggle('-translate-x-full');
            document.getElementById('sidebarBackdrop').classList.toggle('hidden');
        }

        function showToast(message, type) {
            var container = document.getElementById('toastContainer');
            var toast = document.createElement('div');
            var borderClass = 'border-cyan-500/40 text-cyan-200';
            var dotClass = 'bg-cyan-400';
            if (type === 'success') { borderClass = 'border-emerald-500/40 text-emerald-200'; dotClass = 'bg-emerald-400'; }
            else if (type === 'error') { borderClass = 'border-rose-500/40 text-rose-200'; dotClass = 'bg-rose-400'; }
            toast.className = 'toast-enter pointer-events-auto bg-[#0B1E47]/95 backdrop-blur-md border ' + borderClass + ' rounded-xl px-4 py-3 shadow-2xl flex items-center justify-between gap-3 text-xs font-semibold';
            toast.innerHTML = '<div class="flex items-center gap-2.5"><span class="w-2 h-2 rounded-full ' + dotClass + ' shrink-0 animate-pulse"></span><span class="text-white">' + escapeHtml(message) + '</span></div><button type="button" onclick="this.parentElement.remove()" class="text-slate-400 hover:text-white text-sm leading-none">&times;</button>';
            container.appendChild(toast);
            setTimeout(function() {
                toast.style.opacity = '0';
                toast.style.transition = 'opacity 0.25s ease';
                setTimeout(function() { toast.remove(); }, 250);
            }, 3500);
        }

        // AI Copilot
        function toggleAiCopilot() {
            var pop = document.getElementById('aiCopilotPopover');
            pop.classList.toggle('hidden');
            pop.classList.toggle('flex');
        }

        function askCopilot(text) {
            document.getElementById('copilotInput').value = text;
            handleCopilotSubmit(new Event('submit'));
        }

        function handleCopilotSubmit(e) {
            e.preventDefault();
            var input = document.getElementById('copilotInput');
            var text = input.value.trim();
            if (!text) return;
            var box = document.getElementById('copilotMessages');
            var userMsg = document.createElement('div');
            userMsg.className = 'p-2.5 rounded-xl bg-amber-500/15 border border-amber-500/30 text-slate-900 dark:text-slate-100 font-medium ml-6';
            userMsg.textContent = text;
            box.appendChild(userMsg);
            input.value = '';

            setTimeout(function() {
                var lower = text.toLowerCase();
                var reply = 'Current L1 is <strong>' + formatINR(currentPrice) + '</strong> (' + formatINR(currentPrice / requiredQty) + '/unit).';
                if (lower.indexOf('undercut') !== -1 || lower.indexOf('suggest') !== -1) {
                    reply = 'A <strong>-0.5%</strong> undercut is <strong>' + formatINR(currentPrice * 0.995) + '</strong> and a <strong>-1.0%</strong> undercut is <strong>' + formatINR(currentPrice * 0.99) + '</strong>.';
                } else if (lower.indexOf('trend') !== -1 || lower.indexOf('price') !== -1) {
                    var drop = Math.max(0, startingPrice - currentPrice);
                    reply = 'Bidding has compressed the lot by <strong>' + formatINR(drop) + '</strong> below the starting ceiling of <strong>' + formatINR(startingPrice) + '</strong>.';
                }
                var aiMsg = document.createElement('div');
                aiMsg.className = 'p-2.5 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 leading-relaxed mr-4';
                aiMsg.innerHTML = reply;
                box.appendChild(aiMsg);
                box.scrollTop = box.scrollHeight;
            }, 350);
        }
    </script>
<jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />
</body>
</html>
