<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en" class="h-full" data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Supplier Live Auction Marketplace</title>

    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
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
                            midnavy: '#16367D',
                            royal: '#1E3A8A',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06)',
                        'card-hover': '0 12px 28px -8px rgba(11, 30, 71, 0.14), 0 4px 10px -4px rgba(13, 148, 136, 0.08)',
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

        @keyframes priceFlash {
            0% { background-color: rgba(16, 185, 129, 0.25); }
            100% { background-color: transparent; }
        }
        .price-flash { animation: priceFlash 1.1s ease-out; }
        .drawer-panel { transition: transform 0.32s cubic-bezier(0.16, 1, 0.3, 1); }

        .sp-sidebar.collapsed { width: 76px !important; }
        .sp-sidebar.collapsed .sp-hide-collapsed { display: none !important; }
        .sp-sidebar.collapsed ~ .sp-main-wrap { margin-left: 76px !important; }
        @media (max-width: 1023px) {
            .sp-sidebar.collapsed ~ .sp-main-wrap { margin-left: 0 !important; }
        }
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
    <div id="toastContainer" class="fixed top-5 right-5 z-[70] flex flex-col gap-2.5 max-w-sm w-full pointer-events-none"></div>

    <!-- =============================================================== -->
    <!-- SETTINGS SLIDE-IN DRAWER (Dark Mode + Change Password)          -->
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
                        <p class="text-[10px] font-mono text-cyan-200/80">THEME & ACCOUNT SECURITY</p>
                    </div>
                </div>
                <button type="button" id="spSettingsClose" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors" aria-label="Close Settings">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-5 space-y-5">
                <!-- Dark Mode Toggle -->
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

                <!-- Change Password Form (Connected to BiddingServlet) -->
                <div class="p-4 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 space-y-3">
                    <div class="flex items-center gap-2 text-xs font-bold text-slate-900 dark:text-white">
                        <i class="fas fa-lock text-[#0D9488]"></i>
                        <span>Change Account Password</span>
                    </div>

                    <c:choose>
                        <c:when test="${fn:startsWith(supplierPassword, 'GOOGLE_') or supplierIsGoogle}">
                            <p class="text-xs text-slate-500 dark:text-slate-400">Your account uses Google Sign-In. Set a local backup password below.</p>
                            <form id="spPwdForm" method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-2.5">
                                <input type="hidden" name="action" value="changePassword">
                                <input type="password" name="newPassword" id="spNewPwdG" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="New Password (min 6 chars)" required minlength="6">
                                <input type="password" name="confirmPassword" id="spConfPwdG" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Confirm New Password" required minlength="6">
                                <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                                    <i class="fas fa-save mr-1"></i> Set Password
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form id="spPwdForm" method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-2.5">
                                <input type="hidden" name="action" value="changePassword">
                                <input type="password" name="oldPassword" id="spOldPwd" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Current Password" required>
                                <input type="password" name="newPassword" id="spNewPwd" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="New Password (min 6 chars)" required minlength="6">
                                <input type="password" name="confirmPassword" id="spConfPwd" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Confirm New Password" required minlength="6">
                                <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                                    <i class="fas fa-save mr-1"></i> Update Password
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${not empty pwdSuccess}">
                        <div class="sp-feedback p-2.5 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold">
                            <i class="fas fa-check-circle mr-1"></i> ${pwdSuccess}
                        </div>
                    </c:if>
                    <c:if test="${not empty pwdError}">
                        <div class="sp-feedback p-2.5 rounded-xl bg-rose-500/15 border border-rose-500/30 text-rose-600 dark:text-rose-300 text-xs font-semibold">
                            <i class="fas fa-exclamation-circle mr-1"></i> ${pwdError}
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <div class="min-h-screen flex">

        <!-- =============================================================== -->
        <!-- FIXED LEFT SIDEBAR (260px Desktop / Collapsible Mobile Drawer)  -->
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
                        <span class="sp-hide-collapsed text-xl font-extrabold tracking-tight text-white">Supple<span class="text-[#2DD4BF]">xio</span></span>
                    </div>
                    <div class="sp-hide-collapsed text-[9px] font-bold tracking-[0.2em] text-slate-300 uppercase mt-1 flex items-center justify-center gap-1.5">
                        <span>BID BOLD</span>
                        <span class="w-1.5 h-1.5 rounded-full bg-[#F59E0B] shadow-[0_0_8px_#F59E0B]"></span>
                        <span>SOURCE SMART</span>
                    </div>
                </a>
            </div>

            <!-- Supplier Portal Tag -->
            <div class="sp-hide-collapsed px-4 pt-4 pb-2 flex items-center justify-between">
                <span class="text-[10px] font-mono font-semibold uppercase tracking-widest text-cyan-200/70">Supplier Portal</span>
                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-400/25">Approved</span>
            </div>

            <!-- Primary Navigation (All Real Servlet Links Preserved) -->
            <nav class="flex-1 px-3 py-1 space-y-1.5 overflow-y-auto">
                <!-- Active: Live Auctions -->
                <a href="${pageContext.request.contextPath}/bidding" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl bg-white/12 border-l-4 border-[#2DD4BF] text-white font-semibold text-sm shadow-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-[#2DD4BF] shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">Live Auctions</span>
                    </div>
                    <span id="sidebarLiveBadge" class="sp-hide-collapsed inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-400/30">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                        <c:out value="${fn:length(auctions)}"/> LIVE
                    </span>
                </a>

                <!-- My Purchase Orders (Real Servlet Link) -->
                <a href="${pageContext.request.contextPath}/supplier-po-view" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">My Purchase Orders</span>
                    </div>
                    <span class="sp-hide-collapsed px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-white/10 text-cyan-200">
                        <c:out value="${purchaseOrders != null ? fn:length(purchaseOrders) : 0}"/>
                    </span>
                </a>

                <!-- Settings Drawer Trigger -->
                <button type="button" id="spOpenSettings" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all text-left">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">Settings</span>
                    </div>
                </button>
            </nav>

            <!-- Supplier Profile Card & Real Logout Link -->
            <div class="p-3 border-t border-white/10 bg-[#081534]/50">
                <a href="${pageContext.request.contextPath}/bidding?action=profile" title="Edit Profile &amp; Account Settings" class="flex items-center gap-2.5 p-2 rounded-xl bg-white/5 hover:bg-white/12 border border-white/10 hover:border-[#2DD4BF]/50 mb-2 transition-all cursor-pointer group">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-br from-[#2DD4BF] to-[#0D9488] text-slate-950 font-extrabold text-xs flex items-center justify-center shrink-0 shadow uppercase">
                        <c:out value="${fn:substring(supplier.name, 0, 2)}"/>
                    </div>
                    <div class="sp-hide-collapsed min-w-0 flex-1">
                        <div class="text-xs font-bold text-white truncate group-hover:text-[#2DD4BF] transition-colors"><c:out value="${supplier.name}"/></div>
                        <div class="text-[10px] text-slate-300 font-mono truncate"><c:out value="${supplier.email}"/></div>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/bidding?action=logout" class="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-slate-200 hover:text-white bg-white/5 hover:bg-rose-500/20 border border-white/10 hover:border-rose-400/30 transition-all">
                    <svg class="w-3.5 h-3.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                    <span class="sp-hide-collapsed">Logout</span>
                </a>
            </div>
        </aside>

        <!-- Mobile Sidebar Backdrop -->
        <div id="sidebarBackdrop" onclick="toggleMobileSidebar()" class="fixed inset-0 z-30 bg-slate-950/60 backdrop-blur-sm hidden lg:hidden"></div>

        <!-- =============================================================== -->
        <!-- MAIN WORKSPACE CONTENT                                          -->
        <!-- =============================================================== -->
        <main class="sp-main-wrap flex-1 lg:ml-[260px] flex flex-col min-w-0 transition-all duration-300">

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
                <div class="flex items-center gap-2">
                    <button type="button" onclick="toggleDarkMode()" class="p-2 rounded-lg bg-white/10 text-amber-300" aria-label="Toggle Dark Mode">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                        </svg>
                    </button>
                </div>
            </div>

            <div class="p-4 sm:p-6 lg:p-7 max-w-[1440px] w-full mx-auto space-y-6">

                <!-- Alerts from BiddingServlet -->
                <c:if test="${not empty error}">
                    <div class="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold flex items-center justify-between">
                        <span><i class="fas fa-exclamation-triangle mr-2"></i><c:out value="${error}"/></span>
                        <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-700 font-bold text-sm">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold flex items-center justify-between">
                        <span><i class="fas fa-check-circle mr-2"></i><c:out value="${success}"/></span>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700 font-bold text-sm">&times;</button>
                    </div>
                </c:if>

                <!-- ======================================================= -->
                <!-- TOP COMMAND HERO BANNER                                 -->
                <!-- ======================================================= -->
                <section class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#0B1E47] via-[#112C66] to-[#163B7C] text-white p-6 lg:p-7 shadow-lg border border-[#1E3A8A]/50">
                    <div class="absolute inset-0 hero-dot-grid opacity-70 pointer-events-none"></div>
                    <div class="absolute -top-24 -right-24 w-72 h-72 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>
                    <div class="absolute -bottom-24 left-1/3 w-64 h-64 rounded-full bg-blue-500/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-6">
                        <div class="space-y-3 max-w-2xl">
                            <div class="flex flex-wrap items-center gap-2">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-white/10 text-cyan-100 border border-white/15 backdrop-blur-sm">
                                    <svg class="w-3 h-3 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
                                    </svg>
                                    SUPPLIER PORTAL
                                </span>
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-400/30">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                                    MARKETPLACE ACCESS: OPEN TO ALL ACTIVE AUCTIONS
                                </span>
                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-amber-500/15 text-amber-300 border border-amber-400/30">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
                                    </svg>
                                    VERIFIED SUPPLIER
                                </span>
                            </div>

                            <div>
                                <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white">Live Auction Marketplace</h1>
                                <p class="text-sm text-slate-200/85 mt-1.5 leading-relaxed">
                                    Track active sourcing events, message buyers, review POs, and place competitive reverse bids.
                                </p>
                            </div>
                        </div>

                        <!-- Frosted-Glass Supplier Identity Card (Live from ${supplier}) -->
                        <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-4 sm:min-w-[330px] shadow-xl">
                            <div class="flex items-start justify-between gap-3">
                                <div>
                                    <div class="text-[10px] font-mono uppercase tracking-wider text-cyan-200/80">Approved Account</div>
                                    <div class="text-base font-bold text-white mt-0.5">Welcome, <c:out value="${supplier.name}"/></div>
                                </div>
                                <div class="flex items-center gap-1.5">
                                    <button type="button" id="refreshFloorBtn" onclick="refreshFloor()" title="Refresh Floor" class="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-xs font-semibold text-white border border-white/15 transition-all">
                                        <svg id="refreshFloorIcon" class="w-3.5 h-3.5 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                        </svg>
                                        <span class="hidden sm:inline">Refresh Floor</span>
                                    </button>
                                    <button type="button" onclick="toggleDarkMode()" title="Toggle Dark Mode" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-amber-300 border border-white/15 transition-all">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                            <div class="mt-3 pt-3 border-t border-white/10 grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                                <div class="flex items-center gap-1.5 text-slate-200 min-w-0">
                                    <svg class="w-3.5 h-3.5 text-[#2DD4BF] shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                    </svg>
                                    <span class="font-mono text-[11px] truncate"><c:out value="${supplier.email}"/></span>
                                </div>
                                <div class="flex items-center gap-1.5 text-slate-200">
                                    <svg class="w-3.5 h-3.5 text-[#2DD4BF] shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                                    </svg>
                                    <span class="font-mono text-[11px] tabular-nums"><c:out value="${supplier.phone}"/></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- EXECUTIVE KPI STRIP (4 Compact Hairline Cards)          -->
                <!-- ======================================================= -->
                <section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Active Opportunities</p>
                            <div class="mt-1.5 flex items-center gap-2">
                                <span id="kpiActiveLots" class="text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums"><c:out value="${fn:length(auctions)}"/> Live Lots</span>
                                <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                            </div>
                            <p class="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium mt-1">Approved marketplace access</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total Marketplace Value</p>
                            <div id="kpiTotalValue" class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums rounded px-0.5 transition-colors">
                                ₹0.00
                            </div>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400 font-medium mt-1">Aggregate current L1 floor</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-blue-500/10 text-[#1E3A8A] dark:text-cyan-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Purchase Orders</p>
                            <div class="mt-1.5 flex items-center gap-2">
                                <span class="text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums"><c:out value="${purchaseOrders != null ? fn:length(purchaseOrders) : 0}"/> Orders</span>
                                <a href="${pageContext.request.contextPath}/supplier-po-view" class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-teal-500/15 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View POs</a>
                            </div>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400 font-medium mt-1">Awarded supplier contracts</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-teal-500/10 text-[#0D9488] dark:text-[#2DD4BF] flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-amber-200/80 dark:border-amber-500/30 p-4 shadow-card flex items-start justify-between">
                        <div class="min-w-0">
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-amber-600 dark:text-amber-400">Next Lot Closing</p>
                            <div id="kpiNextClosingTimer" class="mt-1.5 text-xl font-extrabold text-amber-600 dark:text-amber-400 font-mono tabular-nums">
                                --
                            </div>
                            <p id="kpiNextClosingName" class="text-[11px] text-slate-600 dark:text-slate-400 font-medium mt-1 truncate">Monitoring live lots</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-amber-500/15 text-amber-600 dark:text-amber-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- SECTION HEADER + SEARCH, FILTER & VIEW TOOLBAR          -->
                <!-- ======================================================= -->
                <section class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-4 sm:p-5 shadow-card space-y-4">
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                        <div>
                            <div class="inline-flex items-center gap-1.5 text-[10px] font-mono font-bold uppercase tracking-wider text-[#0D9488] dark:text-[#2DD4BF]">
                                <span class="w-1.5 h-1.5 rounded-full bg-[#0D9488] dark:bg-[#2DD4BF]"></span>
                                ACTIVE AUCTIONS
                            </div>
                            <h2 class="text-lg font-bold text-slate-900 dark:text-white tracking-tight">Bid Opportunities Open Now</h2>
                            <p class="text-xs text-slate-500 dark:text-slate-400">Every active reverse auction visible here is open for immediate bidding by approved supplier accounts.</p>
                        </div>
                        <span id="visibleCountPill" class="self-start sm:self-center inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-cyan-300 border border-blue-200 dark:border-blue-800">
                            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                            <c:out value="${fn:length(auctions)}"/> Live
                        </span>
                    </div>

                    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3 pt-2 border-t border-slate-100 dark:border-slate-800">
                        <div class="flex flex-col sm:flex-row sm:items-center gap-3 flex-1">
                            <div class="relative flex-1 max-w-md">
                                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                    </svg>
                                </span>
                                <input type="text" id="searchInput" oninput="renderMarketplace()" placeholder="Search live auctions by product, category, or ID..." class="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100 placeholder-slate-400 transition-all">
                            </div>

                            <div class="flex flex-wrap items-center gap-1.5" id="filterPills">
                                <button type="button" onclick="setFilter('all')" data-filter="all" class="filter-pill px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-[#0B1E47] text-white shadow-sm">
                                    All Live (<c:out value="${fn:length(auctions)}"/>)
                                </button>
                                <button type="button" onclick="setFilter('closing')" data-filter="closing" class="filter-pill px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700">
                                    Closing &lt; 24h
                                </button>
                                <button type="button" onclick="setFilter('highvalue')" data-filter="highvalue" class="filter-pill px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700">
                                    High Value
                                </button>
                            </div>
                        </div>

                        <div class="flex items-center gap-2.5 self-end lg:self-auto">
                            <select id="sortSelect" onchange="renderMarketplace()" class="px-3 py-2 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-slate-700 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 cursor-pointer">
                                <option value="endingSoon">Sort: Ending Soonest</option>
                                <option value="highestPrice">Sort: Highest Price</option>
                                <option value="lowestPrice">Sort: Lowest Price</option>
                            </select>

                            <div class="inline-flex items-center bg-slate-100 dark:bg-slate-800 p-1 rounded-xl border border-slate-200/70 dark:border-slate-700">
                                <button type="button" id="viewGridBtn" onclick="setViewMode('grid')" title="Card Grid View" class="p-1.5 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
                                    </svg>
                                </button>
                                <button type="button" id="viewTableBtn" onclick="setViewMode('table')" title="Compact Table View" class="p-1.5 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- MARKETPLACE LOTS CONTAINER (Grid / Table View)          -->
                <!-- ======================================================= -->
                <section id="marketplaceContainer"></section>

                <!-- Footer -->
                <footer class="pt-4 pb-8 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500 border-t border-slate-200/70 dark:border-slate-800">
                    <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                    <p class="font-mono text-[11px] mt-1 sm:mt-0">Reverse Auction Engine v2.4 • 256-Bit Encrypted Bidding Floor</p>
                </footer>
            </div>
        </main>
    </div>

    <!-- =================================================================== -->
    <!-- INTERACTIVE SLIDE-OVER BIDDING ROOM DRAWER (Real POST /bidding)     -->
    <!-- =================================================================== -->
    <div id="bidDrawerOverlay" onclick="closeBidDrawer()" class="fixed inset-0 z-50 bg-slate-950/55 backdrop-blur-sm hidden transition-opacity"></div>
    <aside id="bidDrawer" class="drawer-panel fixed inset-y-0 right-0 z-50 w-full max-w-lg bg-white dark:bg-[#0F172A] border-l border-slate-200 dark:border-slate-800 shadow-drawer transform translate-x-full flex flex-col">
        <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0F4C5C] text-white p-5 border-b border-white/10">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <div class="flex items-center gap-2">
                        <span id="drawerLotId" class="px-2 py-0.5 rounded text-[10px] font-mono font-bold bg-white/15 text-cyan-200">#0</span>
                        <span id="drawerCategory" class="text-[11px] font-medium text-cyan-200/90">Lot</span>
                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/25 text-emerald-300 border border-emerald-400/30">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                            LIVE
                        </span>
                    </div>
                    <h3 id="drawerTitle" class="text-xl font-extrabold tracking-tight mt-1.5">--</h3>
                </div>
                <button type="button" onclick="closeBidDrawer()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors" aria-label="Close Bid Room">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <div class="mt-4 grid grid-cols-3 gap-2.5">
                <div class="bg-white/10 rounded-xl p-2.5 border border-white/10">
                    <div class="text-[10px] uppercase tracking-wider text-slate-300">Current L1</div>
                    <div id="drawerCurrentL1" class="text-sm font-extrabold font-mono tabular-nums text-[#2DD4BF] mt-0.5">₹0.00</div>
                </div>
                <div class="bg-white/10 rounded-xl p-2.5 border border-white/10">
                    <div class="text-[10px] uppercase tracking-wider text-slate-300">Time Left</div>
                    <div id="drawerTimeLeft" class="text-sm font-extrabold font-mono tabular-nums text-amber-300 mt-0.5">--</div>
                </div>
                <div class="bg-white/10 rounded-xl p-2.5 border border-white/10">
                    <div class="text-[10px] uppercase tracking-wider text-slate-300">Full Room</div>
                    <a id="drawerFullRoomLink" href="#" class="inline-flex items-center gap-1 text-xs font-bold mt-1 text-cyan-200 hover:text-white underline">
                        Open View →
                    </a>
                </div>
            </div>
        </div>

        <div class="flex-1 overflow-y-auto p-5 space-y-5">
            <div class="grid grid-cols-3 gap-2.5 p-3 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 text-xs">
                <div>
                    <span class="text-[10px] text-slate-400 uppercase font-semibold block">Quantity</span>
                    <span id="drawerQty" class="font-bold font-mono text-slate-800 dark:text-slate-100">--</span>
                </div>
                <div>
                    <span class="text-[10px] text-slate-400 uppercase font-semibold block">End Time</span>
                    <span id="drawerEndTime" class="font-bold font-mono text-slate-800 dark:text-slate-100">--</span>
                </div>
                <div>
                    <span class="text-[10px] text-slate-400 uppercase font-semibold block">Current Unit Rate</span>
                    <span id="drawerUnitRate" class="font-bold font-mono text-slate-800 dark:text-slate-100">--</span>
                </div>
            </div>

            <!-- Real Servlet Reverse Bid Form -->
            <form id="reverseBidForm" method="post" action="${pageContext.request.contextPath}/bidding" onsubmit="return validateBidSubmit()" class="p-4 rounded-2xl bg-slate-50/80 dark:bg-slate-900/90 border border-slate-200 dark:border-slate-800 space-y-4">
                <input type="hidden" name="action" value="bid">
                <input type="hidden" name="auctionId" id="drawerAuctionIdInput" value="">

                <div class="flex items-center justify-between">
                    <h4 class="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-1.5">
                        <svg class="w-4 h-4 text-[#0D9488]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path>
                        </svg>
                        Place Competitive Reverse Bid
                    </h4>
                    <span class="text-[10px] font-mono text-slate-500 dark:text-slate-400">Must be &lt; Current L1</span>
                </div>

                <div>
                    <span class="text-[11px] font-semibold text-slate-600 dark:text-slate-400 block mb-1.5">Quick Undercut Presets</span>
                    <div class="grid grid-cols-4 gap-2">
                        <button type="button" onclick="applyDecrementPreset(0.5)" class="py-1.5 px-2 rounded-lg text-xs font-mono font-bold bg-white dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-0.5%</button>
                        <button type="button" onclick="applyDecrementPreset(1)" class="py-1.5 px-2 rounded-lg text-xs font-mono font-bold bg-white dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-1.0%</button>
                        <button type="button" onclick="applyDecrementPreset(2.5)" class="py-1.5 px-2 rounded-lg text-xs font-mono font-bold bg-white dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-2.5%</button>
                        <button type="button" onclick="applyDecrementPreset(5)" class="py-1.5 px-2 rounded-lg text-xs font-mono font-bold bg-white dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-700 dark:text-slate-200 hover:text-[#0D9488] dark:hover:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">-5.0%</button>
                    </div>
                </div>

                <div>
                    <label for="bidAmountInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Your Bid Amount (Total ₹)</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-sm font-mono font-bold text-slate-400">₹</span>
                        <input type="number" step="0.01" name="amount" id="bidAmountInput" oninput="validateBidInput()" required placeholder="Enter lower bid amount..." class="w-full pl-8 pr-4 py-2.5 text-sm font-mono font-bold tabular-nums bg-white dark:bg-slate-950 border border-slate-300 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                    </div>

                    <div id="bidCalculationBox" class="mt-2 p-2.5 rounded-xl bg-white dark:bg-slate-950/70 border border-slate-200/80 dark:border-slate-800 text-xs flex items-center justify-between">
                        <span id="bidValidationMsg" class="text-slate-500 dark:text-slate-400">Select a preset or type a lower bid</span>
                        <span id="bidPerUnitPreview" class="font-mono font-semibold text-slate-700 dark:text-slate-300"></span>
                    </div>
                </div>

                <div>
                    <label for="bidRemarksInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">Delivery Lead Time / Notes <span class="font-normal text-slate-400">(Optional)</span></label>
                    <input type="text" name="notes" id="bidRemarksInput" placeholder="e.g., Ex-stock dispatch within 48 hrs, ISI certified" class="w-full px-3 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100 placeholder-slate-400">
                </div>

                <button type="submit" id="submitBidBtn" class="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-[#1E3A8A] via-[#174F8B] to-[#0D9488] hover:opacity-95 text-white font-bold text-sm shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"></path>
                    </svg>
                    <span>Submit Reverse Bid</span>
                </button>
            </form>
        </div>
    </aside>

    <!-- =================================================================== -->
    <!-- INTERACTIVE MESSAGE BUYER MODAL (Real /auction-messages API)       -->
    <!-- =================================================================== -->
    <div id="messageModal" class="fixed inset-0 z-50 bg-slate-950/60 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden flex flex-col max-h-[85vh]">
            <div class="bg-gradient-to-r from-[#0B1E47] to-[#12336B] text-white p-4 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-cyan-500/20 border border-cyan-400/30 flex items-center justify-center text-[#2DD4BF]">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-white" id="chatAuctionName">Buyer Procurement Desk</h3>
                        <p id="msgModalLotContext" class="text-[11px] font-mono text-cyan-200/90">Talk to buyer for this auction</p>
                    </div>
                </div>
                <button type="button" onclick="closeMessageModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <div id="auctionChatThread" class="p-4 flex-1 overflow-y-auto space-y-3 bg-slate-50/70 dark:bg-slate-900/60 min-h-[240px]"></div>

            <form id="auctionChatForm" class="p-3.5 bg-white dark:bg-[#111827] border-t border-slate-200 dark:border-slate-800 flex items-center gap-2">
                <input type="text" id="auctionChatInput" required autocomplete="off" placeholder="Type message to buyer..." class="flex-1 px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100">
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
        <div class="bg-gradient-to-r from-amber-500 to-amber-400 text-slate-950 px-4 py-3 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-8 h-8 rounded-full bg-slate-950 text-amber-400 flex items-center justify-center shadow">
                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2a2 2 0 012 2v1h3a3 3 0 013 3v8a3 3 0 01-3 3H7a3 3 0 01-3-3V8a3 3 0 013-3h3V4a2 2 0 012-2zm-3 9a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm6 0a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm-5 5h4a1 1 0 110 2h-4a1 1 0 110-2z"/>
                    </svg>
                </div>
                <div>
                    <h4 class="text-xs font-extrabold leading-tight">Supplexio AI Bidding Copilot</h4>
                    <p class="text-[10px] font-mono font-bold opacity-80">REAL-TIME MARGIN & LOT INTEL</p>
                </div>
            </div>
            <button type="button" onclick="toggleAiCopilot()" class="p-1 rounded-lg hover:bg-black/10 text-slate-950">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>

        <div id="copilotMessages" class="p-3.5 h-60 overflow-y-auto space-y-2.5 text-xs bg-slate-50/60 dark:bg-slate-900/50">
            <div class="p-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200/80 dark:border-slate-700 text-slate-700 dark:text-slate-200 leading-relaxed">
                Hi <strong><c:out value="${supplier.name}"/></strong>! I'm monitoring all <strong><c:out value="${fn:length(auctions)}"/> live lots</strong> on the Supplexio floor. Ask me about margin targets, closing timers, or reverse bidding strategy.
            </div>
        </div>

        <div class="px-3 py-2 bg-white dark:bg-[#111827] border-t border-slate-100 dark:border-slate-800 flex flex-wrap gap-1.5">
            <button type="button" onclick="sendCopilotPrompt('Which lot closes soonest?')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Which lot closes soonest?
            </button>
            <button type="button" onclick="sendCopilotPrompt('Analyze highest value lot')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Analyze highest value lot
            </button>
            <button type="button" onclick="sendCopilotPrompt('Reverse bidding tips')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Reverse bidding tips
            </button>
        </div>

        <form onsubmit="handleCopilotSubmit(event)" class="p-2.5 bg-white dark:bg-[#111827] border-t border-slate-200 dark:border-slate-800 flex gap-2">
            <input type="text" id="copilotInput" placeholder="Ask bidding copilot..." class="flex-1 px-3 py-1.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-amber-500 text-slate-800 dark:text-slate-100">
            <button type="submit" class="px-3 py-1.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-xs transition-colors">
                Ask
            </button>
        </form>
    </div>

    <!-- Floating Amber Robot Trigger Button -->
    <button type="button" onclick="toggleAiCopilot()" title="Supplexio AI Bidding Copilot" class="fixed bottom-5 right-5 z-40 w-14 h-14 rounded-full bg-gradient-to-tr from-[#F59E0B] to-amber-300 text-slate-950 shadow-2xl hover:scale-105 active:scale-95 transition-transform flex items-center justify-center ring-4 ring-amber-500/25">
        <svg class="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2a2 2 0 012 2v1h3a3 3 0 013 3v8a3 3 0 01-3 3H7a3 3 0 01-3-3V8a3 3 0 013-3h3V4a2 2 0 012-2zm-3 9a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm6 0a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm-5 5h4a1 1 0 110 2h-4a1 1 0 110-2z"/>
        </svg>
    </button>

    <!-- =================================================================== -->
    <!-- APPLICATION LOGIC (Live JSTL Auctions + Real Servlet Integration)    -->
    <!-- =================================================================== -->
    <script>
        var contextPath = '${pageContext.request.contextPath}';
        var SUPPLIER_NAME = '<c:out value="${supplier.name}"/>';

        // Build live auctions array directly from BiddingServlet ${auctions}
        var auctions = [
            <c:forEach var="auction" items="${auctions}" varStatus="loop">
            {
                id: '${auction.id}',
                title: '<c:out value="${auction.productName}"/>',
                category: '<c:out value="${auction.category != null ? auction.category : \'Procurement Lot\'}"/>',
                quantityDisplay: '${auction.requiredQuantity} <c:out value="${auction.unit != null ? auction.unit : \'units\'}"/>',
                unitCount: ${auction.requiredQuantity > 0 ? auction.requiredQuantity : 1},
                unitLabel: '<c:out value="${auction.unit != null ? auction.unit : \'unit\'}"/>',
                currentPrice: ${auction.currentPrice},
                startingCeiling: ${auction.startingPrice},
                endTime: '<fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/>',
                endTimeMillis: ${auction.endTime.time},
                viewUrl: contextPath + '/bidding?action=view&id=${auction.id}',
                status: 'Live'
            }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        var activeFilter = 'all';
        var viewMode = 'grid';
        var activeDrawerLotId = null;
        var activeAuctionId = null;
        var unreadCounts = {};

        function escapeHtml(str) {
            if (!str) return '';
            return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function formatINR(num) {
            return '₹' + Number(num || 0).toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        function getTimeLeftSec(lot) {
            return Math.max(0, Math.floor((lot.endTimeMillis - Date.now()) / 1000));
        }

        function formatTimeLeft(totalSeconds) {
            if (totalSeconds <= 0) return 'Auction ended';
            var d = Math.floor(totalSeconds / 86400);
            var h = Math.floor((totalSeconds % 86400) / 3600);
            var m = Math.floor((totalSeconds % 3600) / 60);
            var s = totalSeconds % 60;
            if (d > 0) return d + 'd ' + h + 'h ' + m + 'm ' + s + 's';
            return h + 'h ' + m + 'm ' + s + 's';
        }

        function getFilteredAuctions() {
            var query = (document.getElementById('searchInput').value || '').trim().toLowerCase();
            var sortBy = document.getElementById('sortSelect').value;

            var list = auctions.filter(function(lot) {
                var matchesSearch = !query ||
                    lot.title.toLowerCase().indexOf(query) !== -1 ||
                    lot.category.toLowerCase().indexOf(query) !== -1 ||
                    String(lot.id).toLowerCase().indexOf(query) !== -1;
                if (!matchesSearch) return false;

                var left = getTimeLeftSec(lot);
                if (activeFilter === 'closing') return left > 0 && left < 86400;
                if (activeFilter === 'highvalue') return lot.currentPrice >= 100000;
                return true;
            });

            if (sortBy === 'endingSoon') {
                list.sort(function(a, b) { return a.endTimeMillis - b.endTimeMillis; });
            } else if (sortBy === 'highestPrice') {
                list.sort(function(a, b) { return b.currentPrice - a.currentPrice; });
            } else if (sortBy === 'lowestPrice') {
                list.sort(function(a, b) { return a.currentPrice - b.currentPrice; });
            }
            return list;
        }

        function updateKpiStrip() {
            var totalValue = auctions.reduce(function(sum, lot) { return sum + lot.currentPrice; }, 0);
            var soonestLot = auctions.slice().sort(function(a, b) { return a.endTimeMillis - b.endTimeMillis; })[0];

            var totalEl = document.getElementById('kpiTotalValue');
            if (totalEl) totalEl.textContent = formatINR(totalValue);

            var activeEl = document.getElementById('kpiActiveLots');
            if (activeEl) activeEl.textContent = auctions.length + ' Live Lots';

            if (soonestLot) {
                document.getElementById('kpiNextClosingTimer').textContent = formatTimeLeft(getTimeLeftSec(soonestLot));
                document.getElementById('kpiNextClosingName').textContent = soonestLot.title;
            } else {
                document.getElementById('kpiNextClosingTimer').textContent = '--';
                document.getElementById('kpiNextClosingName').textContent = 'No open lots';
            }
        }

        function renderMarketplace() {
            var container = document.getElementById('marketplaceContainer');
            var list = getFilteredAuctions();

            document.getElementById('visibleCountPill').innerHTML =
                '<span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> ' + list.length + ' Live';

            if (list.length === 0) {
                container.innerHTML =
                    '<div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 p-12 text-center shadow-card">' +
                        '<div class="w-12 h-12 rounded-2xl bg-slate-100 dark:bg-slate-800 text-slate-400 mx-auto flex items-center justify-center mb-3">' +
                            '<i class="fas fa-search text-lg"></i>' +
                        '</div>' +
                        '<h3 class="text-sm font-bold text-slate-800 dark:text-white">No matching live auctions found</h3>' +
                        '<p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Try adjusting your search query or switching back to "All Live".</p>' +
                        '<button type="button" onclick="resetFilters()" class="mt-4 px-4 py-2 rounded-xl text-xs font-semibold bg-[#0B1E47] text-white hover:opacity-90 transition-opacity">Reset Filters</button>' +
                    '</div>';
                return;
            }

            if (viewMode === 'grid') {
                var cardsHtml = list.map(function(lot) {
                    var leftSec = getTimeLeftSec(lot);
                    var unitPrice = lot.currentPrice / (lot.unitCount || 1);
                    var isUrgent = leftSec > 0 && leftSec < 86400;
                    var uCount = unreadCounts[lot.id] || 0;
                    var msgBadgeHtml = '<span class="message-count absolute -top-1.5 -right-1.5 min-w-[18px] h-[18px] px-1 rounded-full bg-rose-600 text-white text-[10px] font-bold flex items-center justify-center ' + (uCount > 0 ? '' : 'hidden') + '" data-count-for="' + lot.id + '">' + uCount + '</span>';

                    var ribbonHtml = isUrgent
                        ? '<div class="px-4 py-1.5 bg-amber-50 dark:bg-amber-950/40 border-b border-amber-200/70 dark:border-amber-800/50 flex items-center justify-between text-[11px] font-bold text-amber-700 dark:text-amber-300">' +
                            '<span>⏱ Closing Soon (&lt; 24h)</span><span class="font-mono text-[10px]">Priority Sourcing</span></div>'
                        : '';

                    return '<article class="group bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card hover:shadow-card-hover transition-all duration-200 overflow-hidden flex flex-col">' +
                        '<div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0E6B7E] px-5 py-4 text-white">' +
                            '<div class="flex items-center justify-between gap-2 mb-1.5">' +
                                '<div class="flex items-center gap-2 min-w-0">' +
                                    '<span class="px-2 py-0.5 rounded text-[10px] font-mono font-bold bg-white/15 text-cyan-200 border border-white/10">#' + escapeHtml(lot.id) + '</span>' +
                                    '<span class="text-[11px] font-medium text-cyan-100/85 truncate">' + escapeHtml(lot.category) + '</span>' +
                                '</div>' +
                                '<span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-400/20 text-emerald-200 border border-emerald-400/35 shrink-0">' +
                                    '<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>Live</span>' +
                            '</div>' +
                            '<h3 class="text-base font-extrabold tracking-tight text-white truncate">' + escapeHtml(lot.title) + '</h3>' +
                        '</div>' +
                        ribbonHtml +
                        '<div class="p-5 flex-1 flex flex-col justify-between space-y-4">' +
                            '<div class="grid grid-cols-2 gap-3">' +
                                '<div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900/80 border border-slate-200/70 dark:border-slate-800">' +
                                    '<span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">Quantity</span>' +
                                    '<span class="text-sm font-bold font-mono tabular-nums text-slate-900 dark:text-white mt-0.5 block">' + escapeHtml(lot.quantityDisplay) + '</span>' +
                                '</div>' +
                                '<div class="p-3 rounded-xl bg-teal-50/60 dark:bg-teal-950/30 border border-teal-200/70 dark:border-teal-800/50">' +
                                    '<span class="text-[10px] font-semibold uppercase tracking-wider text-[#0D9488] dark:text-[#2DD4BF] block">Current Price</span>' +
                                    '<span class="text-sm font-extrabold font-mono tabular-nums text-slate-900 dark:text-white mt-0.5 block">' + formatINR(lot.currentPrice) + '</span>' +
                                '</div>' +
                                '<div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900/80 border border-slate-200/70 dark:border-slate-800">' +
                                    '<span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400 block">End Time</span>' +
                                    '<span class="text-xs font-bold font-mono tabular-nums text-slate-700 dark:text-slate-200 mt-1 block">' + escapeHtml(lot.endTime) + '</span>' +
                                '</div>' +
                                '<div class="p-3 rounded-xl ' + (isUrgent ? 'bg-amber-50/80 dark:bg-amber-950/30 border-amber-200/80 dark:border-amber-800/50' : 'bg-slate-50 dark:bg-slate-900/80 border-slate-200/70 dark:border-slate-800') + ' border">' +
                                    '<span class="text-[10px] font-semibold uppercase tracking-wider ' + (isUrgent ? 'text-amber-600 dark:text-amber-400' : 'text-slate-400') + ' block">Time Left</span>' +
                                    '<span id="card-timer-' + lot.id + '" class="text-xs font-extrabold font-mono tabular-nums ' + (isUrgent ? 'text-amber-700 dark:text-amber-300' : 'text-slate-800 dark:text-slate-100') + ' mt-1 block">' + formatTimeLeft(leftSec) + '</span>' +
                                '</div>' +
                            '</div>' +
                            '<div class="flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400 pt-1 border-t border-slate-100 dark:border-slate-800">' +
                                '<a href="' + lot.viewUrl + '" class="font-semibold text-[#1E3A8A] dark:text-[#2DD4BF] hover:underline">View Bid Chart & History →</a>' +
                                '<span class="font-mono tabular-nums text-slate-600 dark:text-slate-300">' + formatINR(unitPrice) + ' / ' + escapeHtml(lot.unitLabel) + '</span>' +
                            '</div>' +
                            '<div class="flex items-center gap-2.5 pt-1">' +
                                '<button type="button" onclick="openBidDrawer(\'' + lot.id + '\')" class="flex-1 py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#1E3A8A] via-[#174F8B] to-[#0D9488] hover:opacity-95 active:scale-[0.99] text-white font-bold text-xs shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2">' +
                                    '<i class="fas fa-gavel"></i><span>Place Bid</span>' +
                                '</button>' +
                                '<button type="button" onclick="openChatModal(\'' + lot.id + '\', \'' + escapeHtml(lot.title).replace(/'/g, "\\'") + '\')" title="Message Buyer" class="relative p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-[#0B1E47] dark:text-[#2DD4BF] border border-slate-200 dark:border-slate-700 transition-all">' +
                                    '<i class="fas fa-envelope"></i>' + msgBadgeHtml +
                                '</button>' +
                            '</div>' +
                        '</div>' +
                    '</article>';
                }).join('');

                container.innerHTML = '<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">' + cardsHtml + '</div>';
            } else {
                var rowsHtml = list.map(function(lot) {
                    var leftSec = getTimeLeftSec(lot);
                    var isUrgent = leftSec > 0 && leftSec < 86400;
                    var uCount = unreadCounts[lot.id] || 0;
                    var msgBadgeHtml = '<span class="message-count absolute -top-1.5 -right-1.5 min-w-[16px] h-[16px] px-1 rounded-full bg-rose-600 text-white text-[9px] font-bold flex items-center justify-center ' + (uCount > 0 ? '' : 'hidden') + '" data-count-for="' + lot.id + '">' + uCount + '</span>';

                    return '<tr class="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors">' +
                        '<td class="py-3.5 px-4"><div class="flex items-center gap-2"><span class="px-1.5 py-0.5 rounded text-[10px] font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-cyan-300">#' + escapeHtml(lot.id) + '</span><div><a href="' + lot.viewUrl + '" class="font-bold text-slate-900 dark:text-white hover:underline">' + escapeHtml(lot.title) + '</a><div class="text-[11px] text-slate-400">' + escapeHtml(lot.category) + '</div></div></div></td>' +
                        '<td class="py-3.5 px-4 font-mono tabular-nums font-semibold text-slate-700 dark:text-slate-200">' + escapeHtml(lot.quantityDisplay) + '</td>' +
                        '<td class="py-3.5 px-4"><div class="font-mono tabular-nums font-extrabold text-slate-900 dark:text-white">' + formatINR(lot.currentPrice) + '</div><div class="text-[10px] font-mono text-slate-400">' + formatINR(lot.currentPrice / (lot.unitCount || 1)) + '/' + escapeHtml(lot.unitLabel) + '</div></td>' +
                        '<td class="py-3.5 px-4 font-mono tabular-nums text-slate-600 dark:text-slate-300">' + escapeHtml(lot.endTime) + '</td>' +
                        '<td class="py-3.5 px-4 font-mono tabular-nums font-bold ' + (isUrgent ? 'text-amber-600 dark:text-amber-400' : 'text-slate-800 dark:text-slate-200') + '" id="table-timer-' + lot.id + '">' + formatTimeLeft(leftSec) + '</td>' +
                        '<td class="py-3.5 px-4 text-right"><div class="inline-flex items-center gap-2">' +
                            '<button type="button" onclick="openBidDrawer(\'' + lot.id + '\')" class="px-3 py-1.5 rounded-lg bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white font-bold text-[11px] shadow-sm hover:opacity-95 transition-all">Place Bid</button>' +
                            '<button type="button" onclick="openChatModal(\'' + lot.id + '\', \'' + escapeHtml(lot.title).replace(/'/g, "\\'") + '\')" title="Message Buyer" class="relative p-1.5 rounded-lg bg-slate-100 dark:bg-slate-800 hover:bg-teal-50 dark:hover:bg-teal-900/40 text-slate-600 dark:text-cyan-300 border border-slate-200 dark:border-slate-700"><i class="fas fa-envelope text-xs"></i>' + msgBadgeHtml + '</button>' +
                        '</div></td>' +
                    '</tr>';
                }).join('');

                container.innerHTML =
                    '<div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-slate-800 shadow-card overflow-hidden">' +
                        '<div class="overflow-x-auto"><table class="w-full text-left border-collapse">' +
                            '<thead><tr class="bg-slate-50 dark:bg-slate-900/80 border-b border-slate-200 dark:border-slate-800 text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">' +
                                '<th class="py-3.5 px-4">Lot ID & Product</th><th class="py-3.5 px-4">Quantity</th><th class="py-3.5 px-4">Current Price</th><th class="py-3.5 px-4">End Time</th><th class="py-3.5 px-4">Time Left</th><th class="py-3.5 px-4 text-right">Actions</th>' +
                            '</tr></thead>' +
                            '<tbody class="divide-y divide-slate-100 dark:divide-slate-800 text-xs">' + rowsHtml + '</tbody>' +
                        '</table></div>' +
                    '</div>';
            }
        }

        function setFilter(filterKey) {
            activeFilter = filterKey;
            document.querySelectorAll('.filter-pill').forEach(function(btn) {
                if (btn.getAttribute('data-filter') === filterKey) {
                    btn.className = 'filter-pill px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm';
                } else {
                    btn.className = 'filter-pill px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700';
                }
            });
            renderMarketplace();
        }

        function resetFilters() {
            document.getElementById('searchInput').value = '';
            document.getElementById('sortSelect').value = 'endingSoon';
            setFilter('all');
        }

        function setViewMode(mode) {
            viewMode = mode;
            var gridBtn = document.getElementById('viewGridBtn');
            var tableBtn = document.getElementById('viewTableBtn');
            if (mode === 'grid') {
                gridBtn.className = 'p-1.5 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                tableBtn.className = 'p-1.5 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            } else {
                tableBtn.className = 'p-1.5 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                gridBtn.className = 'p-1.5 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            }
            renderMarketplace();
        }

        // Slide-over Bid Drawer
        function openBidDrawer(lotId) {
            activeDrawerLotId = String(lotId);
            var lot = auctions.find(function(a) { return String(a.id) === activeDrawerLotId; });
            if (!lot) return;

            document.getElementById('drawerLotId').textContent = '#' + lot.id;
            document.getElementById('drawerCategory').textContent = lot.category;
            document.getElementById('drawerTitle').textContent = lot.title;
            document.getElementById('drawerCurrentL1').textContent = formatINR(lot.currentPrice);
            document.getElementById('drawerTimeLeft').textContent = formatTimeLeft(getTimeLeftSec(lot));
            document.getElementById('drawerQty').textContent = lot.quantityDisplay;
            document.getElementById('drawerEndTime').textContent = lot.endTime;
            document.getElementById('drawerUnitRate').textContent = formatINR(lot.currentPrice / (lot.unitCount || 1)) + ' / ' + lot.unitLabel;
            document.getElementById('drawerFullRoomLink').href = lot.viewUrl;
            document.getElementById('drawerAuctionIdInput').value = lot.id;

            var suggested = Number((lot.currentPrice * 0.99).toFixed(2));
            document.getElementById('bidAmountInput').value = suggested;
            document.getElementById('bidAmountInput').max = lot.currentPrice;
            document.getElementById('bidRemarksInput').value = '';
            validateBidInput();

            document.getElementById('bidDrawerOverlay').classList.remove('hidden');
            document.getElementById('bidDrawer').classList.remove('translate-x-full');
        }

        function closeBidDrawer() {
            document.getElementById('bidDrawer').classList.add('translate-x-full');
            document.getElementById('bidDrawerOverlay').classList.add('hidden');
            activeDrawerLotId = null;
        }

        function applyDecrementPreset(percent) {
            var lot = auctions.find(function(a) { return String(a.id) === activeDrawerLotId; });
            if (!lot) return;
            var newPrice = Number((lot.currentPrice * (1 - percent / 100)).toFixed(2));
            document.getElementById('bidAmountInput').value = newPrice;
            validateBidInput();
        }

        function validateBidInput() {
            var lot = auctions.find(function(a) { return String(a.id) === activeDrawerLotId; });
            if (!lot) return false;
            var inputVal = parseFloat(document.getElementById('bidAmountInput').value);
            var msgEl = document.getElementById('bidValidationMsg');
            var unitEl = document.getElementById('bidPerUnitPreview');
            var submitBtn = document.getElementById('submitBidBtn');

            if (isNaN(inputVal) || inputVal <= 0) {
                msgEl.textContent = 'Enter a valid bid amount';
                msgEl.className = 'text-slate-500 dark:text-slate-400';
                unitEl.textContent = '';
                submitBtn.disabled = true;
                return false;
            }
            if (inputVal >= lot.currentPrice) {
                msgEl.textContent = 'Must be strictly lower than ' + formatINR(lot.currentPrice);
                msgEl.className = 'text-rose-600 dark:text-rose-400 font-semibold';
                unitEl.textContent = '';
                submitBtn.disabled = true;
                return false;
            }
            var savings = lot.currentPrice - inputVal;
            var savingsPct = ((savings / lot.currentPrice) * 100).toFixed(2);
            var perUnit = inputVal / (lot.unitCount || 1);
            msgEl.textContent = 'Undercut: -' + formatINR(savings) + ' (-' + savingsPct + '%)';
            msgEl.className = 'text-emerald-600 dark:text-emerald-400 font-semibold';
            unitEl.textContent = formatINR(perUnit) + '/' + lot.unitLabel;
            submitBtn.disabled = false;
            return true;
        }

        function validateBidSubmit() {
            if (!validateBidInput()) {
                showToast('Bid must be strictly lower than the current L1 price.', 'error');
                return false;
            }
            return true;
        }

        // Real Buyer Chat Modal (/auction-messages)
        function openChatModal(auctionId, auctionName) {
            activeAuctionId = auctionId;
            document.getElementById('chatAuctionName').textContent = auctionName || 'Buyer Procurement Desk';
            document.getElementById('msgModalLotContext').textContent = '#' + auctionId + ' • Talk to buyer for this auction';
            var modal = document.getElementById('messageModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');

            fetch(contextPath + '/auction-messages?auctionId=' + encodeURIComponent(activeAuctionId))
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    renderMessages(data.messages || []);
                    setBadge(activeAuctionId, 0);
                })
                .catch(function() {
                    renderMessages([]);
                });
        }

        function closeMessageModal() {
            var modal = document.getElementById('messageModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
            activeAuctionId = null;
        }

        function setBadge(auctionId, count) {
            unreadCounts[auctionId] = count || 0;
            var badge = document.querySelector('[data-count-for="' + auctionId + '"]');
            if (!badge) return;
            badge.textContent = count;
            if (count > 0) badge.classList.remove('hidden');
            else badge.classList.add('hidden');
        }

        function loadUnreadCounts() {
            fetch(contextPath + '/auction-messages?mode=counts')
                .then(function(r) { return r.json(); })
                .then(function(counts) {
                    document.querySelectorAll('[data-count-for]').forEach(function(badge) {
                        var aid = badge.getAttribute('data-count-for');
                        setBadge(aid, counts[aid] || 0);
                    });
                })
                .catch(function() {});
        }

        function renderMessages(messages) {
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

        // Countdown Engine
        function tickAllTimers() {
            auctions.forEach(function(lot) {
                var formatted = formatTimeLeft(getTimeLeftSec(lot));
                var cardTimer = document.getElementById('card-timer-' + lot.id);
                if (cardTimer) cardTimer.textContent = formatted;
                var tableTimer = document.getElementById('table-timer-' + lot.id);
                if (tableTimer) tableTimer.textContent = formatted;
            });

            var soonest = auctions.slice().sort(function(a, b) { return a.endTimeMillis - b.endTimeMillis; })[0];
            if (soonest) {
                var kpiTimer = document.getElementById('kpiNextClosingTimer');
                if (kpiTimer) kpiTimer.textContent = formatTimeLeft(getTimeLeftSec(soonest));
            }
            if (activeDrawerLotId) {
                var openLot = auctions.find(function(a) { return String(a.id) === activeDrawerLotId; });
                if (openLot) {
                    document.getElementById('drawerTimeLeft').textContent = formatTimeLeft(getTimeLeftSec(openLot));
                }
            }
        }

        function refreshFloor() {
            var icon = document.getElementById('refreshFloorIcon');
            if (icon) icon.classList.add('animate-spin');
            window.location.href = contextPath + '/bidding';
        }

        function toggleDarkMode() {
            document.documentElement.classList.toggle('dark');
            var isDark = document.documentElement.classList.contains('dark');
            var theme = isDark ? 'dark' : 'light';
            document.documentElement.setAttribute('data-theme', theme);
            localStorage.setItem('sp-theme', theme);
            var darkTog = document.getElementById('spDarkToggle');
            if (darkTog) darkTog.checked = isDark;
            showToast(isDark ? 'Dark Mode enabled' : 'Light Mode enabled', 'info');
        }

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
            else if (type === 'warning') { borderClass = 'border-amber-500/40 text-amber-200'; dotClass = 'bg-amber-400'; }
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

        // AI Bidding Copilot
        function toggleAiCopilot() {
            var pop = document.getElementById('aiCopilotPopover');
            pop.classList.toggle('hidden');
            pop.classList.toggle('flex');
        }

        function sendCopilotPrompt(promptText) {
            document.getElementById('copilotInput').value = promptText;
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
                var soonest = auctions.slice().sort(function(a, b) { return a.endTimeMillis - b.endTimeMillis; })[0];
                var highest = auctions.slice().sort(function(a, b) { return b.currentPrice - a.currentPrice; })[0];
                var total = auctions.reduce(function(s, l) { return s + l.currentPrice; }, 0);
                var lower = text.toLowerCase();

                var reply = 'All <strong>' + auctions.length + ' live lots</strong> total <strong>' + formatINR(total) + '</strong>. Click <strong>Place Bid</strong> on any lot to open the quick undercut drawer.';
                if (lower.indexOf('soon') !== -1 || lower.indexOf('close') !== -1 || lower.indexOf('time') !== -1) {
                    reply = soonest
                        ? '<strong>' + escapeHtml(soonest.title) + ' (#' + soonest.id + ')</strong> closes soonest in <strong class="font-mono">' + formatTimeLeft(getTimeLeftSec(soonest)) + '</strong> (End: ' + soonest.endTime + ').'
                        : 'No active lots right now.';
                } else if (lower.indexOf('high') !== -1 || lower.indexOf('value') !== -1 || lower.indexOf('margin') !== -1) {
                    reply = highest
                        ? '<strong>' + escapeHtml(highest.title) + ' (#' + highest.id + ')</strong> is the largest lot at <strong>' + formatINR(highest.currentPrice) + '</strong>. A -1% undercut is <strong>' + formatINR(highest.currentPrice * 0.99) + '</strong>.'
                        : 'No active lots right now.';
                } else if (lower.indexOf('tip') !== -1 || lower.indexOf('strategy') !== -1) {
                    reply = 'Reverse bidding tips: <strong>1)</strong> Use -0.5% or -1% steps early to preserve margin. <strong>2)</strong> Watch the final 15 minutes for competitor undercuts. <strong>3)</strong> Message the buyer desk to confirm dispatch terms.';
                }

                var aiMsg = document.createElement('div');
                aiMsg.className = 'p-2.5 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 leading-relaxed mr-4';
                aiMsg.innerHTML = reply;
                box.appendChild(aiMsg);
                box.scrollTop = box.scrollHeight;
            }, 350);
        }

        document.addEventListener('DOMContentLoaded', function() {
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
            if (overlay) overlay.addEventListener('click', function(e) {
                if (e.target === overlay) closeSettings();
            });

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

            <c:if test="${not empty pwdSuccess or not empty pwdError}">
            openSettings();
            </c:if>

            // Chat Form Submission (/auction-messages)
            var chatForm = document.getElementById('auctionChatForm');
            if (chatForm) {
                chatForm.addEventListener('submit', function(event) {
                    event.preventDefault();
                    var input = document.getElementById('auctionChatInput');
                    var message = input.value.trim();
                    if (!message || !activeAuctionId) return;

                    var params = new URLSearchParams();
                    params.append('action', 'send');
                    params.append('auctionId', activeAuctionId);
                    params.append('message', message);

                    fetch(contextPath + '/auction-messages', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    })
                    .then(function() {
                        input.value = '';
                        return fetch(contextPath + '/auction-messages?auctionId=' + encodeURIComponent(activeAuctionId));
                    })
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        renderMessages(data.messages || []);
                        showToast('Message sent to Buyer Desk', 'success');
                    });
                });
            }

            renderMarketplace();
            updateKpiStrip();
            setInterval(tickAllTimers, 1000);
            loadUnreadCounts();
            setInterval(loadUnreadCounts, 15000);
        });
    </script>
<jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />
</body>
</html>
