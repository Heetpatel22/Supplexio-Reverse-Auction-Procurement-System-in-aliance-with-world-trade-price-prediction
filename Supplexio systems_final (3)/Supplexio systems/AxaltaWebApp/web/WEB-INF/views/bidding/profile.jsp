<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en" class="h-full" data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Supplier Profile &amp; Account Settings</title>

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
                            midnavy: '#102A63',
                            royal: '#16367D',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06)',
                        'drawer': '-12px 0 40px -10px rgba(11, 30, 71, 0.28)'
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
    <div id="toastContainer" class="fixed top-5 right-5 z-[80] flex flex-col gap-2.5 max-w-sm w-full pointer-events-none"></div>

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

                    <c:choose>
                        <c:when test="${fn:startsWith(supplierPassword, 'GOOGLE_') or supplierIsGoogle}">
                            <p class="text-xs text-slate-500 dark:text-slate-400">Your account uses Google Sign-In. Set a local backup password below.</p>
                            <form method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-2.5">
                                <input type="hidden" name="action" value="changePassword">
                                <input type="hidden" name="source" value="profile">
                                <input type="password" name="newPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="New Password (min 6 chars)" required minlength="6">
                                <input type="password" name="confirmPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Confirm New Password" required minlength="6">
                                <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                                    <i class="fas fa-save mr-1"></i> Set Password
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="${pageContext.request.contextPath}/bidding" class="space-y-2.5">
                                <input type="hidden" name="action" value="changePassword">
                                <input type="hidden" name="source" value="profile">
                                <input type="password" name="oldPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Current Password" required>
                                <input type="password" name="newPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="New Password (min 6 chars)" required minlength="6">
                                <input type="password" name="confirmPassword" class="w-full px-3.5 py-2 text-xs bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488]" placeholder="Confirm New Password" required minlength="6">
                                <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                                    <i class="fas fa-save mr-1"></i> Update Password
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${not empty pwdSuccess}">
                        <div class="p-2.5 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold">
                            <i class="fas fa-check-circle mr-1"></i> ${pwdSuccess}
                        </div>
                    </c:if>
                    <c:if test="${not empty pwdError}">
                        <div class="p-2.5 rounded-xl bg-rose-500/15 border border-rose-500/30 text-rose-600 dark:text-rose-300 text-xs font-semibold">
                            <i class="fas fa-exclamation-circle mr-1"></i> ${pwdError}
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <div class="min-h-screen flex">

        <!-- =============================================================== -->
        <!-- FIXED LEFT SIDEBAR (Exact Supplier Main Page Sidebar)           -->
        <!-- =============================================================== -->
        <aside id="sidebar" class="sp-sidebar fixed inset-y-0 left-0 z-40 w-[260px] bg-gradient-to-b from-[#0B1E47] via-[#102960] to-[#16367D] text-white flex flex-col border-r border-white/10 transform -translate-x-full lg:translate-x-0 transition-all duration-300 ease-in-out shadow-2xl lg:shadow-none">

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

            <div class="sp-hide-collapsed px-4 pt-4 pb-2 flex items-center justify-between">
                <span class="text-[10px] font-mono font-semibold uppercase tracking-widest text-cyan-200/70">Supplier Portal</span>
                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-400/25">Approved</span>
            </div>

            <nav class="flex-1 px-3 py-1 space-y-1.5 overflow-y-auto">
                <a href="${pageContext.request.contextPath}/bidding" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">Live Auctions</span>
                    </div>
                    <span class="sp-hide-collapsed inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-400/30">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                        LIVE
                    </span>
                </a>

                <a href="${pageContext.request.contextPath}/supplier-po-view" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-slate-200/90 hover:text-white hover:bg-white/10 font-medium text-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">My Purchase Orders</span>
                    </div>
                </a>

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

            <!-- Supplier Profile Card (Active) & Real Logout Link -->
            <div class="p-3 border-t border-white/10 bg-[#081534]/50">
                <a href="${pageContext.request.contextPath}/bidding?action=profile" title="Edit Profile &amp; Account Settings" class="flex items-center gap-2.5 p-2 rounded-xl bg-white/15 border border-[#2DD4BF]/60 mb-2 transition-all cursor-pointer">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-br from-[#2DD4BF] to-[#0D9488] text-slate-950 font-extrabold text-xs flex items-center justify-center shrink-0 shadow uppercase">
                        <c:out value="${fn:substring(supplier.name, 0, 2)}"/>
                    </div>
                    <div class="sp-hide-collapsed min-w-0 flex-1">
                        <div class="text-xs font-bold text-[#2DD4BF] truncate"><c:out value="${supplier.name}"/></div>
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
        <!-- MAIN WORKSPACE AREA                                             -->
        <!-- =============================================================== -->
        <main class="sp-main-wrap flex-1 lg:ml-[260px] flex flex-col min-w-0 transition-all duration-300">

            <!-- Mobile Top Header -->
            <div class="lg:hidden sticky top-0 z-20 bg-[#0B1E47] text-white px-4 py-3 flex items-center justify-between border-b border-white/10 shadow">
                <div class="flex items-center gap-3">
                    <button type="button" onclick="toggleMobileSidebar()" class="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white" aria-label="Open Sidebar">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                    <span class="font-extrabold tracking-tight text-base">Supple<span class="text-[#2DD4BF]">xio</span></span>
                </div>
            </div>

            <div class="p-4 sm:p-6 lg:p-7 max-w-[1520px] w-full mx-auto space-y-6">

                <c:if test="${not empty profileSuccess}">
                    <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-emerald-500/12 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i class="fas fa-check-circle text-emerald-500 text-sm"></i>
                            <span><c:out value="${profileSuccess}"/></span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-emerald-500/15">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty profileError}">
                    <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-rose-500/12 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i class="fas fa-exclamation-circle text-rose-500 text-sm"></i>
                            <span><c:out value="${profileError}"/></span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-rose-500/15">&times;</button>
                    </div>
                </c:if>

                <!-- ======================================================= -->
                <!-- EXECUTIVE PROFILE HERO BANNER                           -->
                <!-- ======================================================= -->
                <section class="relative overflow-hidden rounded-2xl text-white p-6 lg:p-7 shadow-lg border border-white/10" style="background: linear-gradient(115deg, #0B1E47 0%, #12336B 52%, #0E5A6D 100%);">
                    <div class="absolute inset-0 hero-dot-grid opacity-75 pointer-events-none"></div>
                    <div class="absolute -top-24 -right-20 w-80 h-80 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-6">
                        <div class="flex flex-col sm:flex-row sm:items-center gap-5">
                            <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl bg-gradient-to-br from-[#2DD4BF] via-[#0D9488] to-[#0B1E47] border-2 border-cyan-300/40 shadow-xl flex items-center justify-center text-2xl sm:text-3xl font-extrabold text-white uppercase shrink-0">
                                <c:out value="${fn:substring(supplier.name, 0, 2)}"/>
                            </div>

                            <div class="space-y-2">
                                <div class="flex flex-wrap items-center gap-2">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 border border-emerald-400/35">
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
                                        </svg>
                                        <c:out value="${not empty supplier.status ? supplier.status : 'ACTIVE'}"/> Supplier
                                    </span>
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-cyan-400/15 text-[#2DD4BF] border border-cyan-400/30">
                                        Supplier ID #<c:out value="${supplier.id}"/>
                                    </span>
                                </div>

                                <h1 id="heroCompanyName" class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                                    <c:out value="${supplier.name}"/>
                                </h1>

                                <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-slate-200/90">
                                    <span class="inline-flex items-center gap-1.5 font-mono">
                                        <i class="fas fa-envelope text-[#2DD4BF]"></i>
                                        <span id="heroEmail"><c:out value="${supplier.email}"/></span>
                                    </span>
                                    <span class="inline-flex items-center gap-1.5 font-mono">
                                        <i class="fas fa-phone text-[#2DD4BF]"></i>
                                        <span id="heroPhone"><c:out value="${supplier.phone}"/></span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="flex flex-wrap items-center gap-2.5">
                            <button type="button" onclick="openBuyerPreviewModal()" class="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl text-xs font-semibold bg-white/12 hover:bg-white/20 text-white border border-white/20 backdrop-blur-sm transition-all">
                                <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                                <span>Preview Buyer View</span>
                            </button>
                            <button type="submit" form="profileUpdateForm" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold bg-[#2DD4BF] hover:bg-teal-300 text-slate-950 shadow-md transition-all">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.4">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
                                </svg>
                                <span>Save Profile Changes</span>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- MAIN 2-COLUMN WORKSPACE (8 Cols Left + 4 Cols Right)    -->
                <!-- ======================================================= -->
                <section class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <!-- LEFT COLUMN (lg:col-span-8): EDITABLE SIGNUP & BUSINESS PROFILE -->
                    <div class="lg:col-span-8 space-y-6">
                        <form id="profileUpdateForm" method="post" action="${pageContext.request.contextPath}/bidding" class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <input type="hidden" name="action" value="updateProfile">

                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex flex-wrap items-center justify-between gap-2">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-[#0B1E47] to-[#0D9488] text-white flex items-center justify-center shadow-sm">
                                        <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Core Registration &amp; Business Identity</h2>
                                        <p class="text-[11px] text-slate-500 dark:text-slate-400">Edit the account details provided during supplier registration. Changes sync immediately to Purchase Orders &amp; Auctions.</p>
                                    </div>
                                </div>
                                <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#102A63] dark:text-[#2DD4BF] border border-blue-200 dark:border-blue-800">
                                    SIGNUP PROFILE
                                </span>
                            </div>

                            <div class="p-5 grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Supplier / Company Name * -->
                                <div class="md:col-span-2">
                                    <label for="companyNameInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                                        Supplier / Company Name <span class="text-rose-500">*</span>
                                    </label>
                                    <input type="text" id="companyNameInput" name="name" required value="<c:out value='${supplier.name}'/>"
                                        oninput="syncLivePreview()"
                                        class="w-full px-3.5 py-2.5 text-sm font-semibold bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-[#0B1120] focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all">
                                </div>

                                <!-- Business Email * -->
                                <div>
                                    <div class="flex items-center justify-between mb-1.5">
                                        <label for="businessEmailInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300">
                                            Business Email <span class="text-rose-500">*</span>
                                        </label>
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">
                                            ✓ Verified
                                        </span>
                                    </div>
                                    <input type="email" id="businessEmailInput" name="email" required value="<c:out value='${supplier.email}'/>"
                                        oninput="syncLivePreview()"
                                        class="w-full px-3.5 py-2.5 text-xs font-mono bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-[#0B1120] focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all">
                                </div>

                                <!-- Phone Number * -->
                                <div>
                                    <label for="contactPhoneInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                                        Phone Number <span class="text-rose-500">*</span>
                                    </label>
                                    <input type="tel" id="contactPhoneInput" name="phone" required value="<c:out value='${supplier.phone}'/>"
                                        oninput="syncLivePreview()"
                                        class="w-full px-3.5 py-2.5 text-xs font-mono tabular-nums bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-[#0B1120] focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all">
                                </div>

                                <!-- Business Address -->
                                <div class="md:col-span-2">
                                    <label for="businessAddressInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                                        Registered Business &amp; Dispatch Address
                                    </label>
                                    <textarea id="businessAddressInput" name="address" rows="3"
                                        placeholder="Plot 42, GIDC Industrial Estate, Vadodara, Gujarat 390010"
                                        class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-[#0B1120] focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all resize-none"><c:out value="${supplier.address}"/></textarea>
                                </div>
                            </div>

                            <div class="px-5 py-3.5 bg-slate-50/70 dark:bg-slate-900/40 border-t border-slate-100 dark:border-[#1E293B] flex items-center justify-between gap-3">
                                <span class="text-[11px] text-slate-500 dark:text-slate-400">All fields above are synced directly with your supplier database record.</span>
                                <button type="submit" class="inline-flex items-center gap-2 px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#102A63] via-[#16367D] to-[#0D9488] hover:opacity-95 text-white shadow-md transition-all">
                                    <i class="fas fa-save"></i>
                                    <span>Save Profile Changes</span>
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- RIGHT COLUMN (lg:col-span-4): ACCOUNT ACCESS & LINKED SIGN-IN -->
                    <div class="lg:col-span-4 space-y-6">
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center gap-2">
                                <svg class="w-4 h-4 text-[#0D9488] dark:text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                                </svg>
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Account Access &amp; Security</h3>
                            </div>

                            <div class="p-4 space-y-4">
                                <!-- Password Row -->
                                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200/80 dark:border-[#1E293B] flex items-center justify-between gap-3">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Account Password</div>
                                        <div class="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">Update your login credentials</div>
                                    </div>
                                    <button type="button" onclick="openPasswordModal()" class="px-3 py-1.5 rounded-lg text-xs font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white border border-slate-700 transition-all whitespace-nowrap">
                                        Change Password
                                    </button>
                                </div>

                                <!-- Account Status -->
                                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200/80 dark:border-[#1E293B] flex items-center justify-between gap-3">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Account Status</div>
                                        <div class="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">Marketplace bidding eligibility</div>
                                    </div>
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">
                                        <c:out value="${not empty supplier.status ? supplier.status : 'ACTIVE'}"/>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- OPTIONAL BUSINESS DOCUMENTS (Below Account Access & Security) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center justify-between gap-2">
                                <div class="flex items-center gap-2">
                                    <i class="fas fa-folder-open text-[#0D9488] dark:text-[#2DD4BF] text-sm"></i>
                                    <h3 class="text-sm font-bold text-slate-900 dark:text-white">Business Documents</h3>
                                </div>
                                <span class="text-[10px] font-mono font-semibold text-slate-500 dark:text-slate-400">Optional</span>
                            </div>

                            <div class="p-4 space-y-3">
                                <!-- Card 1: Company PAN Card -->
                                <form method="post" action="${pageContext.request.contextPath}/bidding" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadDocument">
                                    <input type="hidden" name="docType" value="PAN">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Company PAN Card</div>
                                        <c:choose>
                                            <c:when test="${not empty supplierDocs['PAN']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty supplierDocs['PAN']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${supplierDocs['PAN']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty supplierDocs['PAN'] ? 'Replace' : 'Upload PAN'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty supplierDocs['PAN']}">
                                            <a href="${pageContext.request.contextPath}/bidding?action=viewDocument&docType=PAN" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteSupplierDoc('PAN')" title="Delete uploaded PAN document" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>

                                <!-- Card 2: Aadhar Card of the Owner -->
                                <form method="post" action="${pageContext.request.contextPath}/bidding" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadDocument">
                                    <input type="hidden" name="docType" value="AADHAR">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Aadhar Card of the Owner</div>
                                        <c:choose>
                                            <c:when test="${not empty supplierDocs['AADHAR']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty supplierDocs['AADHAR']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${supplierDocs['AADHAR']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty supplierDocs['AADHAR'] ? 'Replace' : 'Upload Aadhar'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty supplierDocs['AADHAR']}">
                                            <a href="${pageContext.request.contextPath}/bidding?action=viewDocument&docType=AADHAR" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteSupplierDoc('AADHAR')" title="Delete uploaded Aadhar document" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>

                                <!-- Card 3: Business Registration Certificate -->
                                <form method="post" action="${pageContext.request.contextPath}/bidding" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadDocument">
                                    <input type="hidden" name="docType" value="REG_CERT">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Business Registration Certificate</div>
                                        <c:choose>
                                            <c:when test="${not empty supplierDocs['REG_CERT']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty supplierDocs['REG_CERT']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${supplierDocs['REG_CERT']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty supplierDocs['REG_CERT'] ? 'Replace' : 'Upload Certificate'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty supplierDocs['REG_CERT']}">
                                            <a href="${pageContext.request.contextPath}/bidding?action=viewDocument&docType=REG_CERT" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteSupplierDoc('REG_CERT')" title="Delete uploaded Registration Certificate" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <form id="deleteDocForm" method="post" action="${pageContext.request.contextPath}/bidding" class="hidden">
                            <input type="hidden" name="action" value="deleteDocument">
                            <input type="hidden" name="docType" id="deleteDocType">
                        </form>
                    </div>
                </section>

                <!-- Footer -->
                <footer class="pt-3 pb-6 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500 border-t border-slate-200/70 dark:border-[#1E293B]">
                    <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                    <p class="font-mono text-[11px] mt-1 sm:mt-0">Supplier Profile &amp; Account Settings</p>
                </footer>
            </div>
        </main>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 1: PREVIEW PUBLIC BUYER CARD MODAL                            -->
    <!-- =================================================================== -->
    <div id="buyerPreviewModal" class="fixed inset-0 z-50 bg-slate-950/65 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-[#1E293B] rounded-2xl max-w-xl w-full shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0E5A6D] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-cyan-200">Public Marketplace Card</span>
                    <h3 class="text-base font-extrabold tracking-tight">How Procurement Buyers See Your Profile</h3>
                </div>
                <button type="button" onclick="closeBuyerPreviewModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div id="buyerPreviewBody" class="p-6 overflow-y-auto space-y-4"></div>
            <div class="px-5 py-3.5 bg-slate-50 dark:bg-[#0B1120] border-t border-slate-200 dark:border-[#1E293B] flex items-center justify-between">
                <span class="text-[11px] text-slate-500 dark:text-slate-400">Live preview reflects your current form values.</span>
                <button type="button" onclick="closeBuyerPreviewModal()" class="px-4 py-2 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] text-white hover:opacity-90">
                    Close Preview
                </button>
            </div>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 2: CHANGE PASSWORD MODAL (Real POST /bidding)                 -->
    <!-- =================================================================== -->
    <div id="passwordModal" class="fixed inset-0 z-50 bg-slate-950/65 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-[#1E293B] rounded-2xl max-w-md w-full shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-[#0B1E47] to-[#12336B] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-cyan-200">Account Security</span>
                    <h3 class="text-base font-extrabold">Change Account Password</h3>
                </div>
                <button type="button" onclick="closePasswordModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/bidding" class="p-5 space-y-4">
                <input type="hidden" name="action" value="changePassword">
                <input type="hidden" name="source" value="profile">

                <c:if test="${not (fn:startsWith(supplierPassword, 'GOOGLE_') or supplierIsGoogle)}">
                    <div>
                        <label for="currentPwdInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Current Password <span class="text-rose-500">*</span></label>
                        <input type="password" id="currentPwdInput" name="oldPassword" required placeholder="Enter current password" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                    </div>
                </c:if>

                <div>
                    <label for="newPwdInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">New Password <span class="text-rose-500">*</span></label>
                    <input type="password" id="newPwdInput" name="newPassword" required minlength="6" placeholder="At least 6 characters" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                </div>

                <div>
                    <label for="confirmPwdInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Confirm New Password <span class="text-rose-500">*</span></label>
                    <input type="password" id="confirmPwdInput" name="confirmPassword" required minlength="6" placeholder="Re-enter new password" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                </div>

                <div class="flex items-center justify-end gap-2 pt-2">
                    <button type="button" onclick="closePasswordModal()" class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#102A63] to-[#0D9488] hover:opacity-95 text-white shadow">
                        Update Password
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function escapeHtml(str) {
            return String(str || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function deleteSupplierDoc(docType) {
            document.getElementById('deleteDocType').value = docType;
            document.getElementById('deleteDocForm').submit();
        }

        function syncLivePreview() {
            var name = document.getElementById('companyNameInput').value.trim();
            var email = document.getElementById('businessEmailInput').value.trim();
            var phone = document.getElementById('contactPhoneInput').value.trim();
            if (name) document.getElementById('heroCompanyName').textContent = name;
            if (email) document.getElementById('heroEmail').textContent = email;
            if (phone) document.getElementById('heroPhone').textContent = phone;
        }

        var uploadedDocs = {
            PAN: '<c:out value="${supplierDocs[\'PAN\']}"/>',
            AADHAR: '<c:out value="${supplierDocs[\'AADHAR\']}"/>',
            REG_CERT: '<c:out value="${supplierDocs[\'REG_CERT\']}"/>'
        };

        function openBuyerPreviewModal() {
            var company = document.getElementById('companyNameInput').value.trim();
            var email = document.getElementById('businessEmailInput').value.trim();
            var phone = document.getElementById('contactPhoneInput').value.trim();
            var address = document.getElementById('businessAddressInput').value.trim();
            var initials = company.split(' ').map(function(w) { return w[0]; }).filter(Boolean).slice(0, 2).join('').toUpperCase() || 'SP';

            var docItems = [
                { key: 'PAN', label: 'Company PAN Card', file: uploadedDocs.PAN },
                { key: 'AADHAR', label: 'Aadhar Card of the Owner', file: uploadedDocs.AADHAR },
                { key: 'REG_CERT', label: 'Business Registration Certificate', file: uploadedDocs.REG_CERT }
            ];
            var providedCount = docItems.filter(function(d) { return d.file && d.file.length > 0; }).length;
            var allProvided = providedCount === 3;

            var docsHtml = docItems.map(function(d) {
                var ok = d.file && d.file.length > 0;
                return '<div class="flex items-center justify-between gap-2 py-1">' +
                    '<span class="text-slate-700 dark:text-slate-200">' + (ok ? '<span class="text-emerald-500 font-bold mr-1">✓</span>' : '<span class="text-slate-400 mr-1">•</span>') + d.label + '</span>' +
                    (ok
                        ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">Provided</span>'
                        : '<span class="px-2 py-0.5 rounded-full text-[10px] font-mono text-slate-400 bg-slate-200/60 dark:bg-slate-800">Not Provided</span>') +
                    '</div>';
            }).join('');

            var docsHeaderBadge = allProvided
                ? '<span class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/20 text-emerald-700 dark:text-emerald-300 border border-emerald-500/40">✓ All Verification Documents Provided (3/3)</span>'
                : '<span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-600 dark:text-slate-300">' + providedCount + ' / 3 Provided</span>';

            document.getElementById('buyerPreviewBody').innerHTML =
                '<div class="flex items-center gap-4 pb-4 border-b border-slate-200 dark:border-[#1E293B]">' +
                    '<div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#0B1E47] to-[#0D9488] text-white font-extrabold text-xl flex items-center justify-center shrink-0 shadow">' + escapeHtml(initials) + '</div>' +
                    '<div>' +
                        '<h4 class="text-lg font-extrabold text-slate-900 dark:text-white">' + escapeHtml(company) + '</h4>' +
                        '<span class="inline-block mt-1 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">Verified Supplier</span>' +
                    '</div>' +
                '</div>' +
                '<div class="p-4 rounded-xl bg-slate-50 dark:bg-[#0B1120] border border-slate-200 dark:border-[#1E293B] space-y-2 text-xs">' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Business Email</span><span class="font-mono text-slate-800 dark:text-slate-100">' + escapeHtml(email) + '</span></div>' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Phone</span><span class="font-mono text-slate-800 dark:text-slate-100">' + escapeHtml(phone) + '</span></div>' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Address</span><span class="text-slate-700 dark:text-slate-200">' + escapeHtml(address || 'Not provided') + '</span></div>' +
                '</div>' +
                '<div class="p-4 rounded-xl ' + (allProvided ? 'bg-emerald-50/70 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-800/50' : 'bg-slate-50 dark:bg-[#0B1120] border-slate-200 dark:border-[#1E293B]') + ' border space-y-2 text-xs">' +
                    '<div class="flex items-center justify-between gap-2 pb-1.5 border-b border-slate-200/70 dark:border-slate-800">' +
                        '<span class="font-bold text-slate-800 dark:text-white uppercase text-[10px] tracking-wider">Submitted Business Documents</span>' +
                        docsHeaderBadge +
                    '</div>' +
                    docsHtml +
                '</div>';

            var modal = document.getElementById('buyerPreviewModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeBuyerPreviewModal() {
            var modal = document.getElementById('buyerPreviewModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        function openPasswordModal() {
            var m = document.getElementById('passwordModal');
            m.classList.remove('hidden');
            m.classList.add('flex');
        }

        function closePasswordModal() {
            var m = document.getElementById('passwordModal');
            m.classList.add('hidden');
            m.classList.remove('flex');
        }

        function toggleMobileSidebar() {
            document.getElementById('sidebar').classList.toggle('-translate-x-full');
            document.getElementById('sidebarBackdrop').classList.toggle('hidden');
        }

        document.addEventListener('DOMContentLoaded', function() {
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
        });
    </script>
<jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />
</body>
</html>

