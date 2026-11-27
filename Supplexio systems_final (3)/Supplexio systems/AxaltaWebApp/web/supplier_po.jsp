<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%!
    private static String escJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", " ")
                .replace("<", "\\u003c")
                .replace(">", "\\u003e");
    }
%>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String errorMsg = (String) request.getSession().getAttribute("error");
    if (errorMsg != null) request.getSession().removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="en" class="h-full" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — My Purchase Orders</title>

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
                        'drawer': '-12px 0 40px -10px rgba(11, 30, 71, 0.28)'
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

        table.density-compact th,
        table.density-compact td {
            padding-top: 0.55rem !important;
            padding-bottom: 0.55rem !important;
        }

        .sp-sidebar.collapsed { width: 76px !important; }
        .sp-sidebar.collapsed .sp-hide-collapsed { display: none !important; }
        .sp-sidebar.collapsed ~ .sp-main-wrap { margin-left: 76px !important; }
        @media (max-width: 1023px) {
            .sp-sidebar.collapsed ~ .sp-main-wrap { margin-left: 0 !important; }
        }

        @media print {
            body * { visibility: hidden !important; }
            #printableDocumentArea, #printableDocumentArea * { visibility: visible !important; }
            #printableDocumentArea {
                position: fixed !important;
                inset: 0 !important;
                width: 100% !important;
                background: #FFFFFF !important;
                color: #0F172A !important;
                padding: 24px !important;
                border: none !important;
                box-shadow: none !important;
            }
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
    <!-- SETTINGS SLIDE-IN DRAWER (Identical to Supplier Main Page)      -->
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
        <!-- FIXED LEFT SIDEBAR (Exact Supplier Main Page Sidebar)           -->
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
                <!-- Live Auctions -->
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

                <!-- Active: My Purchase Orders -->
                <a href="${pageContext.request.contextPath}/supplier-po-view" class="flex items-center justify-between px-3.5 py-2.5 rounded-xl bg-white/12 border-l-4 border-[#2DD4BF] text-white font-semibold text-sm shadow-sm transition-all">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-[#2DD4BF] shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <span class="sp-hide-collapsed">My Purchase Orders</span>
                    </div>
                    <span id="sidebarPendingBadge" class="sp-hide-collapsed px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-amber-500/25 text-amber-300 border border-amber-400/35 tabular-nums">
                        <%= poList != null ? poList.size() : 0 %>
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

            <!-- Live Engine Status Mini-Widget -->
            <div class="sp-hide-collapsed mx-3 mb-3 p-3 rounded-xl bg-white/5 border border-white/10">
                <div class="flex items-center justify-between text-[11px] font-medium text-slate-300">
                    <span class="flex items-center gap-1.5">
                        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                        Bid Engine
                    </span>
                    <span class="font-mono text-emerald-300 text-[10px]">SYNCED</span>
                </div>
                <p class="text-[10px] text-slate-400 mt-1 leading-relaxed">Real-time L1 price feed active. Bids reflect immediately across buyers.</p>
            </div>

            <!-- Supplier Profile Card & Real Logout Link -->
            <div class="p-3 border-t border-white/10 bg-[#081534]/50">
                <div class="flex items-center gap-2.5 p-2 rounded-xl bg-white/5 border border-white/10 mb-2">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-br from-[#2DD4BF] to-[#0D9488] text-slate-950 font-extrabold text-xs flex items-center justify-center shrink-0 shadow uppercase">
                        <c:out value="${not empty supplier.name ? fn:substring(supplier.name, 0, 2) : 'SP'}"/>
                    </div>
                    <div class="sp-hide-collapsed min-w-0 flex-1">
                        <div class="text-xs font-bold text-white truncate"><c:out value="${not empty supplier.name ? supplier.name : 'Supplier'}"/></div>
                        <div class="text-[10px] text-slate-300 font-mono truncate"><c:out value="${not empty supplier.email ? supplier.email : ''}"/></div>
                    </div>
                </div>
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

            <!-- Mobile Top Bar -->
            <div class="lg:hidden sticky top-0 z-20 bg-[#0B1E47] text-white px-4 py-3 flex items-center justify-between border-b border-white/10 shadow">
                <div class="flex items-center gap-3">
                    <button type="button" onclick="toggleMobileSidebar()" class="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white" aria-label="Open Menu">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                    <span class="font-extrabold tracking-tight text-base">Supple<span class="text-[#2DD4BF]">xio</span></span>
                </div>
                <button type="button" onclick="toggleDarkMode()" class="p-2 rounded-lg bg-white/10 text-amber-300" aria-label="Toggle Dark Mode">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                    </svg>
                </button>
            </div>

            <div class="p-4 sm:p-6 lg:p-7 max-w-[1520px] w-full mx-auto space-y-6">

                <% if (errorMsg != null) { %>
                <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-rose-500/12 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold shadow-sm">
                    <div class="flex items-center gap-2.5">
                        <i class="fas fa-exclamation-circle text-rose-500 text-sm"></i>
                        <span><%= errorMsg %></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-rose-500/15">&times;</button>
                </div>
                <% } %>

                <!-- ======================================================= -->
                <!-- TOP DARK NAVY COMMAND BANNER                            -->
                <!-- ======================================================= -->
                <section class="relative overflow-hidden rounded-2xl text-white p-6 lg:p-7 shadow-lg border border-white/10" style="background: linear-gradient(110deg, #0B1E47 0%, #12336B 55%, #0E6B7E 100%);">
                    <div class="absolute inset-0 hero-dot-grid opacity-75 pointer-events-none"></div>
                    <div class="absolute -top-24 -right-16 w-72 h-72 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>

                    <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-5">
                        <div class="space-y-2 max-w-2xl">
                            <div class="inline-flex items-center gap-2 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold tracking-wider uppercase bg-white/10 text-cyan-200 border border-white/15 backdrop-blur-sm">
                                <span class="w-1.5 h-1.5 rounded-full bg-[#2DD4BF]"></span>
                                SUPPLIER PORTAL • FULFILLMENT &amp; BILLING
                            </div>
                            <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white">My Purchase Orders</h1>
                            <p class="text-sm text-slate-200/85 leading-relaxed">
                                Accept issued POs, submit ASN shipping details, upload commercial GST invoices, and download verified PO, GRN &amp; Invoice PDFs.
                            </p>
                        </div>

                        <div class="flex flex-wrap items-center gap-2.5">
                            <button type="button" id="bannerActionPill" onclick="setStatusFilter('ACTION_NEEDED')" class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-bold bg-amber-500/20 hover:bg-amber-500/30 text-amber-200 border border-amber-400/40 backdrop-blur-sm transition-all">
                                <span class="w-2 h-2 rounded-full bg-amber-400 animate-ping"></span>
                                <span id="bannerActionText">0 Actions Required</span>
                            </button>

                            <button type="button" onclick="exportFilteredCsv()" class="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-white/12 hover:bg-white/20 text-white border border-white/20 backdrop-blur-sm transition-all">
                                <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                                </svg>
                                <span>Export CSV</span>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- 4-CARD EXECUTIVE KPI STRIP                              -->
                <!-- ======================================================= -->
                <section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total PO Value</p>
                            <div id="kpiTotalValue" class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">₹0.00</div>
                            <p id="kpiTotalCount" class="text-[11px] text-slate-500 dark:text-slate-400 font-medium mt-1">0 Purchase Orders</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-blue-500/10 text-[#102A63] dark:text-[#2DD4BF] flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                        </div>
                    </div>

                    <button type="button" onclick="setStatusFilter('ACTION_NEEDED')" class="text-left bg-white dark:bg-[#111827] hover:border-amber-400 dark:hover:border-amber-500/60 rounded-2xl border border-amber-200 dark:border-amber-500/35 p-4 shadow-card transition-all flex items-start justify-between group">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-amber-600 dark:text-amber-400 flex items-center gap-1.5">
                                Action Required
                                <span class="text-[10px] font-normal opacity-75 group-hover:underline">Filter →</span>
                            </p>
                            <div id="kpiActionCount" class="mt-1.5 text-xl font-extrabold text-amber-600 dark:text-amber-400 font-mono tabular-nums">0 Orders</div>
                            <p id="kpiActionSub" class="text-[11px] text-slate-600 dark:text-slate-400 font-medium mt-1">0 to accept • 0 to ship • 0 invoices due</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-amber-500/15 text-amber-600 dark:text-amber-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                            </svg>
                        </div>
                    </button>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">Settled &amp; Closed</p>
                            <div id="kpiSettledValue" class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">₹0.00</div>
                            <p id="kpiSettledSub" class="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium mt-1">0 Completed Orders</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-emerald-500/12 text-emerald-600 dark:text-emerald-400 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] p-4 shadow-card flex items-start justify-between">
                        <div>
                            <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Total GST (7.5%)</p>
                            <div id="kpiTotalGst" class="mt-1.5 text-xl font-extrabold text-slate-900 dark:text-white font-mono tabular-nums">₹0.00</div>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400 font-medium mt-1">Tax reconciliation across POs</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-teal-500/12 text-[#0D9488] dark:text-[#2DD4BF] flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z"></path>
                            </svg>
                        </div>
                    </div>
                </section>

                <!-- ======================================================= -->
                <!-- HIGH-DENSITY PURCHASE ORDERS WORKSPACE CARD             -->
                <!-- ======================================================= -->
                <section class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">

                    <!-- Filter Toolbar -->
                    <div class="p-4 sm:p-5 border-b border-[#E2E8F0] dark:border-[#1E293B] space-y-4">
                        <div class="flex flex-wrap items-center gap-1.5" id="statusFilterTabs"></div>

                        <div class="flex flex-col md:flex-row md:items-center justify-between gap-3">
                            <div class="relative flex-1 max-w-md">
                                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                    </svg>
                                </span>
                                <input type="text" id="searchInput" oninput="renderTable()" placeholder="Search by PO ID, PO Number, or Material..." class="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100 placeholder-slate-400 transition-all">
                            </div>

                            <div class="flex flex-wrap items-center gap-2.5">
                                <select id="sortSelect" onchange="renderTable()" class="px-3 py-2 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl text-slate-700 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 cursor-pointer">
                                    <option value="dateDesc">Date: Newest</option>
                                    <option value="dateAsc">Date: Oldest</option>
                                    <option value="totalDesc">Total: High to Low</option>
                                    <option value="totalAsc">Total: Low to High</option>
                                </select>

                                <div class="inline-flex items-center bg-slate-100 dark:bg-slate-800 p-1 rounded-xl border border-slate-200/80 dark:border-slate-700 text-[11px] font-semibold">
                                    <button type="button" id="densityComfortableBtn" onclick="setTableDensity('comfortable')" class="px-2.5 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all">
                                        Comfortable
                                    </button>
                                    <button type="button" id="densityCompactBtn" onclick="setTableDensity('compact')" class="px-2.5 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all">
                                        Compact
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Responsive Data Table -->
                    <div class="overflow-x-auto">
                        <table id="poTable" class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50/90 dark:bg-slate-900/80 border-b border-[#E2E8F0] dark:border-[#1E293B] text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                    <th class="py-3 px-2.5 whitespace-nowrap">PO ID</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap">PO No.</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap">Material</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap text-right">Qty</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap text-right">Amount</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap text-right">GST (7.5%)</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap text-right">Total</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap">Status</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap">Date</th>
                                    <th class="py-3 px-2.5 whitespace-nowrap text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="poTableBody" class="divide-y divide-slate-100 dark:divide-slate-800/80 text-xs"></tbody>
                        </table>
                    </div>

                    <!-- Table Footer Summary -->
                    <div class="px-4 sm:px-5 py-3 bg-slate-50/70 dark:bg-slate-900/50 border-t border-[#E2E8F0] dark:border-[#1E293B] flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs text-slate-500 dark:text-slate-400">
                        <span id="tableShowingText" class="font-medium">Showing 0 of 0 Purchase Orders</span>
                        <span id="tableFilteredTotal" class="font-mono tabular-nums font-semibold text-slate-700 dark:text-slate-200">Filtered Total: ₹0.00</span>
                    </div>
                </section>

                <!-- Footer -->
                <footer class="pt-2 pb-6 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500">
                    <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                    <p class="font-mono text-[11px] mt-1 sm:mt-0">Verified Supplier Fulfillment &amp; Three-Way Match Ledger</p>
                </footer>
            </div>
        </main>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 1: ACCEPT PURCHASE ORDER (POST /pos/accept)                   -->
    <!-- =================================================================== -->
    <div id="acceptPoModal" class="fixed inset-0 z-50 bg-slate-950/60 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0E6B7E] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-cyan-200">Dispatch Confirmation</span>
                    <h3 class="text-base font-extrabold tracking-tight">Accept Purchase Order</h3>
                </div>
                <button type="button" onclick="closeAcceptModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <form id="acceptPoForm" method="post" action="<%= request.getContextPath() %>/pos/accept" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="acceptPoId" />

                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 grid grid-cols-2 gap-3 text-xs">
                    <div>
                        <span class="text-[10px] uppercase font-semibold text-slate-400 block">PO Number</span>
                        <span id="acceptModalPoNo" class="font-mono font-bold text-slate-900 dark:text-white break-all"></span>
                    </div>
                    <div>
                        <span class="text-[10px] uppercase font-semibold text-slate-400 block">Material &amp; Qty</span>
                        <span id="acceptModalMaterial" class="font-bold text-slate-900 dark:text-white"></span>
                    </div>
                    <div>
                        <span class="text-[10px] uppercase font-semibold text-slate-400 block">Base Amount + GST</span>
                        <span id="acceptModalBreakdown" class="font-mono tabular-nums text-slate-600 dark:text-slate-300"></span>
                    </div>
                    <div>
                        <span class="text-[10px] uppercase font-semibold text-slate-400 block">Grand Total</span>
                        <span id="acceptModalTotal" class="font-mono tabular-nums font-extrabold text-[#0D9488] dark:text-[#2DD4BF]"></span>
                    </div>
                </div>

                <label class="flex items-start gap-2.5 p-3 rounded-xl bg-blue-50/70 dark:bg-blue-950/30 border border-blue-200/70 dark:border-blue-800/50 cursor-pointer">
                    <input type="checkbox" id="acceptConfirmCheck" required checked class="mt-0.5 w-4 h-4 rounded text-[#0D9488] border-slate-300 focus:ring-[#0D9488]">
                    <span class="text-[11px] leading-relaxed text-slate-700 dark:text-slate-300">
                        I formally accept the pricing, 7.5% GST terms, and quantity specified in this Purchase Order and commit to providing shipping details next.
                    </span>
                </label>

                <div class="flex items-center justify-end gap-2.5 pt-2">
                    <button type="button" onclick="closeAcceptModal()" class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#102A63] via-[#16367D] to-[#0D9488] hover:opacity-95 text-white shadow-md transition-all">
                        ✓ Confirm &amp; Accept PO
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 2: FILL SHIPPING DETAILS (ASN) (POST /shipments/ship)         -->
    <!-- =================================================================== -->
    <div id="shipModal" class="fixed inset-0 z-50 bg-slate-950/60 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#D97706] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-amber-200">Advance Shipment Notice</span>
                    <h3 class="text-base font-extrabold tracking-tight flex items-center gap-2">
                        <i class="fas fa-truck"></i>
                        <span>Shipping Details (ASN)</span>
                    </h3>
                </div>
                <button type="button" onclick="closeShipModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/shipments/ship" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="shipPoId" />

                <div class="p-3.5 rounded-xl bg-amber-50/70 dark:bg-amber-950/25 border border-amber-200 dark:border-amber-800/50 flex items-center justify-between text-xs">
                    <div>
                        <span class="text-[10px] uppercase font-semibold text-amber-700 dark:text-amber-300 block">Dispatching PO</span>
                        <span id="shipModalPoNo" class="font-mono font-bold text-slate-900 dark:text-white"></span>
                    </div>
                    <div class="text-right">
                        <span class="text-[10px] uppercase font-semibold text-amber-700 dark:text-amber-300 block">Material &amp; Qty</span>
                        <span id="shipModalMaterial" class="font-bold text-slate-900 dark:text-white"></span>
                    </div>
                </div>

                <div>
                    <label for="shipAsn" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">ASN Number <span class="text-rose-500">*</span></label>
                    <input type="text" name="asnNumber" id="shipAsn" required placeholder="e.g. ASN-2026-001" class="w-full px-3 py-2 text-xs font-mono font-semibold bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 text-slate-900 dark:text-white">
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label for="shipCarrier" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Carrier <span class="text-rose-500">*</span></label>
                        <input type="text" name="carrier" id="shipCarrier" required placeholder="e.g. BlueDart / DHL" class="w-full px-3 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 text-slate-900 dark:text-white">
                    </div>
                    <div>
                        <label for="shipTracking" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Tracking Number <span class="text-rose-500">*</span></label>
                        <input type="text" name="trackingNumber" id="shipTracking" required placeholder="Tracking / AWB number" class="w-full px-3 py-2 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 text-slate-900 dark:text-white">
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2.5 pt-2">
                    <button type="button" onclick="closeShipModal()" class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-amber-500 to-orange-500 hover:opacity-95 text-slate-950 shadow-md transition-all inline-flex items-center gap-1.5">
                        <i class="fas fa-shipping-fast"></i>
                        <span>SHIP ORDER</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 3: UPLOAD COMMERCIAL INVOICE (POST /invoices/upload)          -->
    <!-- =================================================================== -->
    <div id="invoiceModal" class="fixed inset-0 z-50 bg-slate-950/60 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-slate-800 rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#BE123C] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-amber-300">Three-Way Match Billing</span>
                    <h3 class="text-base font-extrabold tracking-tight flex items-center gap-2">
                        <i class="fas fa-file-invoice"></i>
                        <span>Commercial / Tax Invoice</span>
                    </h3>
                </div>
                <button type="button" onclick="closeInvoiceModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/invoices/upload" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="invPoId" />

                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 space-y-2.5 text-xs">
                    <div class="flex items-center justify-between border-b border-slate-200/70 dark:border-slate-800 pb-2">
                        <span id="invModalPoNo" class="font-mono font-bold text-slate-900 dark:text-white"></span>
                        <span id="invModalMaterial" class="font-semibold text-slate-600 dark:text-slate-300"></span>
                    </div>
                    <div class="grid grid-cols-3 gap-2">
                        <div>
                            <span class="text-[10px] uppercase text-slate-400 font-semibold block">Base Amount</span>
                            <span id="invModalAmount" class="font-mono tabular-nums font-bold text-slate-800 dark:text-slate-100"></span>
                        </div>
                        <div>
                            <span class="text-[10px] uppercase text-slate-400 font-semibold block">GST (7.5%)</span>
                            <span id="invModalGst" class="font-mono tabular-nums font-bold text-slate-800 dark:text-slate-100"></span>
                        </div>
                        <div>
                            <span class="text-[10px] uppercase text-slate-400 font-semibold block">Grand Total</span>
                            <span id="invModalTotal" class="font-mono tabular-nums font-extrabold text-[#0D9488] dark:text-[#2DD4BF]"></span>
                        </div>
                    </div>
                </div>

                <p class="text-[11px] text-slate-500 dark:text-slate-400 leading-relaxed">
                    Invoice quantity must match the PO ordered quantity and warehouse received quantity for three-way match. Once submitted, status transitions to <strong>PAYMENT PENDING</strong>.
                </p>

                <div>
                    <label for="invNumber" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Invoice Number <span class="text-rose-500">*</span></label>
                    <input type="text" name="invoiceNumber" id="invNumber" required placeholder="e.g. INV-2026-089" class="w-full px-3 py-2 text-xs font-mono font-semibold uppercase bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label for="invPrice" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Invoice Price (excl. GST) <span class="text-rose-500">*</span></label>
                        <input type="number" name="invoicePrice" id="invPrice" step="0.01" required class="w-full px-3 py-2 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                    </div>
                    <div>
                        <label for="invQty" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Invoice Quantity <span class="text-rose-500">*</span></label>
                        <input type="number" name="invoiceQuantity" id="invQty" min="1" required class="w-full px-3 py-2 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                    </div>
                </div>

                <div class="flex items-center justify-end gap-2.5 pt-2">
                    <button type="button" onclick="closeInvoiceModal()" class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-rose-600 to-amber-500 hover:opacity-95 text-white shadow-md transition-all inline-flex items-center gap-1.5">
                        <i class="fas fa-upload"></i>
                        <span>Upload Invoice</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- SLIDE-OVER DOCUMENT & ORDER DETAIL DRAWER                           -->
    <!-- =================================================================== -->
    <div id="detailDrawerOverlay" onclick="closeDetailDrawer()" class="fixed inset-0 z-50 bg-slate-950/55 backdrop-blur-sm hidden"></div>
    <aside id="detailDrawer" class="drawer-panel fixed inset-y-0 right-0 z-50 w-full max-w-2xl bg-white dark:bg-[#0F172A] border-l border-slate-200 dark:border-slate-800 shadow-drawer transform translate-x-full flex flex-col">
        <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0E6B7E] text-white p-5 border-b border-white/10">
            <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                    <div class="flex flex-wrap items-center gap-2">
                        <span id="drawerPoNumber" class="px-2 py-0.5 rounded text-[11px] font-mono font-bold bg-white/15 text-cyan-200"></span>
                        <span id="drawerStatusPill"></span>
                    </div>
                    <h3 id="drawerMaterialTitle" class="text-xl font-extrabold tracking-tight mt-1.5 truncate"></h3>
                    <p id="drawerMetaSub" class="text-xs text-cyan-100/80 font-mono mt-0.5"></p>
                </div>
                <button type="button" onclick="closeDetailDrawer()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors" aria-label="Close Drawer">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
        </div>

        <div class="flex-1 overflow-y-auto p-5 space-y-5">
            <!-- 7-Stage Fulfillment Stepper -->
            <div class="p-4 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
                <div class="flex items-center justify-between mb-3 gap-2 flex-wrap">
                    <h4 class="text-[11px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Fulfillment &amp; Settlement Lifecycle</h4>
                    <div id="drawerQuickWorkflowAction"></div>
                </div>
                <div id="drawerStepper" class="grid grid-cols-4 sm:grid-cols-7 gap-1.5"></div>
            </div>

            <!-- Document Preview Tabs & Official PDF/Print Actions -->
            <div class="flex flex-wrap items-center justify-between gap-2">
                <div class="inline-flex items-center bg-slate-100 dark:bg-slate-800 p-1 rounded-xl border border-slate-200/80 dark:border-slate-700" id="drawerDocTabs"></div>
                <div class="flex items-center gap-2">
                    <a id="drawerPdfDownloadLink" href="#" target="_blank" class="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-800 dark:text-slate-100 border border-slate-200 dark:border-slate-700 transition-all">
                        <i class="fas fa-file-pdf text-rose-500"></i>
                        <span>Download PDF</span>
                    </a>
                    <button type="button" onclick="printCurrentDocument()" class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] hover:opacity-95 text-white shadow-sm transition-all">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
                        </svg>
                        <span>Print</span>
                    </button>
                </div>
            </div>

            <!-- Authentic B2B Supplexio Document Preview -->
            <div id="printableDocumentArea" class="bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-2xl p-6 shadow-sm text-slate-800 dark:text-slate-100"></div>
        </div>
    </aside>

    <!-- =================================================================== -->
    <!-- FLOATING WARM-AMBER AI SUPPLIER COPILOT                             -->
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
                    <h4 class="text-xs font-extrabold leading-tight">Supplexio AI PO Copilot</h4>
                    <p class="text-[10px] font-mono font-bold opacity-80">FULFILLMENT &amp; GST RECONCILIATION</p>
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
                Hello <strong><c:out value="${not empty supplier.name ? supplier.name : 'Supplier'}"/></strong>! I'm synced with your live Purchase Order ledger. Ask me about pending acceptances, shipments, due invoices, or GST totals.
            </div>
        </div>

        <div class="px-3 py-2 bg-white dark:bg-[#111827] border-t border-slate-100 dark:border-slate-800 flex flex-wrap gap-1.5">
            <button type="button" onclick="sendCopilotPrompt('Pending actions summary')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Pending actions summary
            </button>
            <button type="button" onclick="sendCopilotPrompt('Calculate total GST')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Calculate total GST
            </button>
            <button type="button" onclick="sendCopilotPrompt('Which invoices are due?')" class="text-[10px] font-semibold px-2.5 py-1 rounded-full bg-amber-500/15 hover:bg-amber-500/25 text-amber-800 dark:text-amber-300 border border-amber-500/30 transition-colors">
                Which invoices are due?
            </button>
        </div>

        <form onsubmit="handleCopilotSubmit(event)" class="p-2.5 bg-white dark:bg-[#111827] border-t border-slate-200 dark:border-slate-800 flex gap-2">
            <input type="text" id="copilotInput" placeholder="Ask about POs, shipping, GST, or invoices..." class="flex-1 px-3 py-1.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-amber-500 text-slate-800 dark:text-slate-100">
            <button type="submit" class="px-3 py-1.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-xs transition-colors">
                Ask
            </button>
        </form>
    </div>

    <button type="button" onclick="toggleAiCopilot()" title="Supplexio AI PO Copilot" class="fixed bottom-5 right-5 z-40 w-14 h-14 rounded-full bg-gradient-to-tr from-[#F59E0B] to-amber-300 text-slate-950 shadow-2xl hover:scale-105 active:scale-95 transition-transform flex items-center justify-center ring-4 ring-amber-500/25">
        <svg class="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2a2 2 0 012 2v1h3a3 3 0 013 3v8a3 3 0 01-3 3H7a3 3 0 01-3-3V8a3 3 0 013-3h3V4a2 2 0 012-2zm-3 9a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm6 0a1.5 1.5 0 100 3 1.5 1.5 0 000-3zm-5 5h4a1 1 0 110 2h-4a1 1 0 110-2z"/>
        </svg>
    </button>

    <!-- =================================================================== -->
    <!-- CORE APPLICATION SCRIPT (Wired to Real Backend Data & Endpoints)    -->
    <!-- =================================================================== -->
    <script>
        const contextPath = '<%= request.getContextPath() %>';
        const supplierDisplayName = '<%= escJs(request.getSession().getAttribute("supplier") != null ? ((com.axaltacoating.model.Supplier) request.getSession().getAttribute("supplier")).getName() : "Supplier") %>';
        const supplierDisplayEmail = '<%= escJs(request.getSession().getAttribute("supplier") != null ? ((com.axaltacoating.model.Supplier) request.getSession().getAttribute("supplier")).getEmail() : "") %>';

        const purchaseOrders = [
        <%
            if (poList != null && !poList.isEmpty()) {
                for (int idx = 0; idx < poList.size(); idx++) {
                    Object obj = poList.get(idx);
                    Class<?> bc = obj.getClass();
                    long   poId     = (Long)   bc.getMethod("getId").invoke(obj);
                    String material = (String) bc.getMethod("getMaterial").invoke(obj);
                    String poNumber = "";
                    try { poNumber = (String) bc.getMethod("getPoNumber").invoke(obj); } catch(Exception e) {}
                    if (poNumber == null || poNumber.isEmpty()) poNumber = "PO-" + poId;
                    double amount   = (Double) bc.getMethod("getAmount").invoke(obj);
                    int    qty      = (Integer)bc.getMethod("getQuantity").invoke(obj);
                    String company  = "";
                    try { company = (String) bc.getMethod("getCompanyName").invoke(obj); } catch(Exception e) {}
                    String status   = (String) bc.getMethod("getStatus").invoke(obj);
                    if ("COMPLETED".equalsIgnoreCase(status)) status = "PO_DRAFT";
                    if ("SENT".equalsIgnoreCase(status)) status = "PO_SENT";
                    if ("PAID".equalsIgnoreCase(status)) status = "PAYMENT_SUCCESSFUL";
                    if ("PENDING".equalsIgnoreCase(status)) status = "PO_DRAFT";
                    if (status == null) status = "PO_DRAFT";
                    status = status.toUpperCase();

                    java.util.Date createdAt = (java.util.Date) bc.getMethod("getCreatedAt").invoke(obj);
                    String dateStr = createdAt != null ? sdf.format(createdAt) : "-";
                    double gst   = amount * 0.075;
                    double total = amount + gst;

                    boolean hasPo  = !"PO_DRAFT".equalsIgnoreCase(status);
                    boolean hasGrn = "DELIVERED".equalsIgnoreCase(status) || "INVOICING_PENDING".equalsIgnoreCase(status) || "INVOICE_REQUESTED".equalsIgnoreCase(status) || "PAYMENT_PENDING".equalsIgnoreCase(status) || "PAYMENT_SUCCESSFUL".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status);
                    boolean hasInv = "PAYMENT_PENDING".equalsIgnoreCase(status) || "PAYMENT_SUCCESSFUL".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status);

                    StringBuilder docsJs = new StringBuilder("[");
                    boolean firstDoc = true;
                    if (hasPo)  { docsJs.append("'PO'"); firstDoc = false; }
                    if (hasGrn) { if (!firstDoc) docsJs.append(","); docsJs.append("'GRN'"); firstDoc = false; }
                    if (hasInv) { if (!firstDoc) docsJs.append(","); docsJs.append("'INV'"); }
                    docsJs.append("]");
        %>
            {
                poId: <%= poId %>,
                poNumber: "<%= escJs(poNumber) %>",
                material: "<%= escJs(material != null ? material : "N/A") %>",
                companyName: "<%= escJs(company != null ? company : "Supplexio Enterprise") %>",
                qty: <%= qty %>,
                amount: <%= String.format(java.util.Locale.US, "%.2f", amount) %>,
                gst: <%= String.format(java.util.Locale.US, "%.2f", gst) %>,
                total: <%= String.format(java.util.Locale.US, "%.2f", total) %>,
                status: "<%= escJs(status) %>",
                date: "<%= escJs(dateStr) %>",
                docs: <%= docsJs.toString() %>
            }<%= (idx < poList.size() - 1) ? "," : "" %>
        <%
                }
            }
        %>
        ];

        let activeStatusFilter = 'ALL';
        let activeDensity = 'comfortable';
        let drawerPoId = null;
        let drawerActiveDocTab = 'PO';

        function formatINR(value) {
            return '₹' + Number(value).toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        function escapeHtml(str) {
            return String(str || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function isActionNeededStatus(status) {
            return status === 'PO_SENT' || status === 'PO_ACCEPTED' || status === 'DELIVERED' || status === 'INVOICING_PENDING' || status === 'INVOICE_REQUESTED';
        }

        function getStatusBadgeHtml(status) {
            const map = {
                PO_SENT: {
                    label: 'PO SENT',
                    classes: 'bg-amber-500/15 text-amber-700 dark:text-amber-300 border-amber-500/35',
                    dot: 'bg-amber-500 animate-pulse'
                },
                PO_ACCEPTED: {
                    label: 'PO ACCEPTED',
                    classes: 'bg-blue-500/15 text-blue-700 dark:text-blue-300 border-blue-500/35',
                    dot: 'bg-blue-500 animate-pulse'
                },
                SHIPPED: {
                    label: 'SHIPPED',
                    classes: 'bg-sky-500/15 text-sky-700 dark:text-sky-300 border-sky-500/35',
                    dot: 'bg-sky-500'
                },
                DELIVERED: {
                    label: 'DELIVERED',
                    classes: 'bg-cyan-500/15 text-cyan-700 dark:text-cyan-300 border-cyan-500/35',
                    dot: 'bg-cyan-500'
                },
                INVOICING_PENDING: {
                    label: 'INVOICE REQUESTED',
                    classes: 'bg-rose-500/15 text-rose-700 dark:text-rose-300 border-rose-500/35',
                    dot: 'bg-rose-500 animate-pulse'
                },
                INVOICE_REQUESTED: {
                    label: 'INVOICE REQUESTED',
                    classes: 'bg-rose-500/15 text-rose-700 dark:text-rose-300 border-rose-500/35',
                    dot: 'bg-rose-500 animate-pulse'
                },
                PAYMENT_PENDING: {
                    label: 'PAYMENT PENDING',
                    classes: 'bg-indigo-500/15 text-indigo-700 dark:text-indigo-300 border-indigo-500/35',
                    dot: 'bg-indigo-500 animate-pulse'
                },
                PAYMENT_SUCCESSFUL: {
                    label: 'PAYMENT SUCCESSFUL',
                    classes: 'bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border-emerald-500/30',
                    dot: 'bg-emerald-500'
                },
                CLOSED: {
                    label: 'CLOSED',
                    classes: 'bg-slate-500/12 text-slate-600 dark:text-slate-300 border-slate-400/30',
                    dot: 'bg-slate-400'
                },
                PO_DRAFT: {
                    label: 'PO DRAFT',
                    classes: 'bg-slate-500/12 text-slate-600 dark:text-slate-300 border-slate-400/30',
                    dot: 'bg-slate-400'
                }
            };
            const cfg = map[status] || { label: status, classes: 'bg-slate-500/12 text-slate-600 dark:text-slate-300 border-slate-400/30', dot: 'bg-slate-400' };
            return `<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-mono font-bold border whitespace-nowrap \${cfg.classes}">
                <span class="w-1.5 h-1.5 rounded-full \${cfg.dot}"></span>
                \${cfg.label}
            </span>`;
        }

        function updateDashboardMetrics() {
            const totalValue = purchaseOrders.reduce((s, po) => s + po.total, 0);
            const totalGst = purchaseOrders.reduce((s, po) => s + po.gst, 0);

            const toAccept = purchaseOrders.filter(po => po.status === 'PO_SENT').length;
            const toShip = purchaseOrders.filter(po => po.status === 'PO_ACCEPTED').length;
            const invoicesDue = purchaseOrders.filter(po => po.status === 'DELIVERED' || po.status === 'INVOICING_PENDING' || po.status === 'INVOICE_REQUESTED').length;
            const totalActions = toAccept + toShip + invoicesDue;

            const settledOrders = purchaseOrders.filter(po => po.status === 'PAYMENT_SUCCESSFUL' || po.status === 'CLOSED');
            const settledValue = settledOrders.reduce((s, po) => s + po.total, 0);

            document.getElementById('kpiTotalValue').textContent = formatINR(totalValue);
            document.getElementById('kpiTotalCount').textContent = `\${purchaseOrders.length} Purchase Orders`;

            document.getElementById('kpiActionCount').textContent = `\${totalActions} \${totalActions === 1 ? 'Order' : 'Orders'}`;
            document.getElementById('kpiActionSub').textContent = `\${toAccept} to accept • \${toShip} to ship • \${invoicesDue} invoices due`;

            document.getElementById('kpiSettledValue').textContent = formatINR(settledValue);
            document.getElementById('kpiSettledSub').textContent = `\${settledOrders.length} Completed Orders`;

            document.getElementById('kpiTotalGst').textContent = formatINR(totalGst);

            const sidebarBadge = document.getElementById('sidebarPendingBadge');
            if (sidebarBadge) {
                sidebarBadge.textContent = totalActions > 0 ? totalActions : purchaseOrders.length;
                sidebarBadge.className = totalActions > 0
                    ? 'sp-hide-collapsed px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/25 text-amber-300 border border-amber-400/35 tabular-nums'
                    : 'sp-hide-collapsed px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-white/10 text-cyan-200 tabular-nums';
            }

            document.getElementById('bannerActionText').textContent = totalActions > 0
                ? `\${totalActions} \${totalActions === 1 ? 'Action' : 'Actions'} Required`
                : 'All Actions Cleared';

            renderFilterTabs();
        }

        function renderFilterTabs() {
            const counts = {
                ALL: purchaseOrders.length,
                ACTION_NEEDED: purchaseOrders.filter(p => isActionNeededStatus(p.status)).length,
                PO_SENT: purchaseOrders.filter(p => p.status === 'PO_SENT').length,
                PO_ACCEPTED: purchaseOrders.filter(p => p.status === 'PO_ACCEPTED').length,
                SHIPPED: purchaseOrders.filter(p => p.status === 'SHIPPED').length,
                DELIVERED_INV: purchaseOrders.filter(p => p.status === 'DELIVERED' || p.status === 'INVOICING_PENDING' || p.status === 'INVOICE_REQUESTED').length,
                PAYMENT_PENDING: purchaseOrders.filter(p => p.status === 'PAYMENT_PENDING').length,
                PAYMENT_SUCCESSFUL: purchaseOrders.filter(p => p.status === 'PAYMENT_SUCCESSFUL').length,
                CLOSED: purchaseOrders.filter(p => p.status === 'CLOSED').length
            };

            const tabs = [
                { key: 'ALL', label: 'All' },
                { key: 'ACTION_NEEDED', label: 'Action Needed' },
                { key: 'PO_SENT', label: 'PO Sent' },
                { key: 'PO_ACCEPTED', label: 'PO Accepted' },
                { key: 'SHIPPED', label: 'Shipped' },
                { key: 'DELIVERED_INV', label: 'Delivered / Invoice Due' },
                { key: 'PAYMENT_PENDING', label: 'Payment Pending' },
                { key: 'PAYMENT_SUCCESSFUL', label: 'Payment Successful' },
                { key: 'CLOSED', label: 'Closed' }
            ];

            const container = document.getElementById('statusFilterTabs');
            container.innerHTML = tabs.map(t => {
                const isActive = activeStatusFilter === t.key;
                const activeStyle = 'bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm border-transparent';
                const inactiveStyle = 'bg-slate-100/90 dark:bg-slate-800/80 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 border-slate-200/70 dark:border-slate-700';
                const badgeStyle = isActive
                    ? 'bg-white/20 text-white'
                    : (t.key === 'ACTION_NEEDED' && counts[t.key] > 0 ? 'bg-amber-500/20 text-amber-700 dark:text-amber-300' : 'bg-slate-200/80 dark:bg-slate-700 text-slate-600 dark:text-slate-300');

                return `
                    <button type="button" onclick="setStatusFilter('\${t.key}')" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all \${isActive ? activeStyle : inactiveStyle}">
                        <span>\${t.label}</span>
                        <span class="px-1.5 py-0.2 rounded-md text-[10px] font-mono tabular-nums \${badgeStyle}">\${counts[t.key]}</span>
                    </button>
                `;
            }).join('');
        }

        function setStatusFilter(key) {
            activeStatusFilter = key;
            renderFilterTabs();
            renderTable();
        }

        function getFilteredPOs() {
            const q = document.getElementById('searchInput').value.trim().toLowerCase();
            const sortBy = document.getElementById('sortSelect').value;

            let list = purchaseOrders.filter(po => {
                const matchesSearch = !q ||
                    String(po.poId).includes(q) ||
                    po.poNumber.toLowerCase().includes(q) ||
                    po.material.toLowerCase().includes(q);
                if (!matchesSearch) return false;

                if (activeStatusFilter === 'ACTION_NEEDED') return isActionNeededStatus(po.status);
                if (activeStatusFilter === 'DELIVERED_INV') return po.status === 'DELIVERED' || po.status === 'INVOICING_PENDING' || po.status === 'INVOICE_REQUESTED';
                if (activeStatusFilter !== 'ALL') return po.status === activeStatusFilter;
                return true;
            });

            if (sortBy === 'dateDesc') list.sort((a, b) => b.date.localeCompare(a.date));
            else if (sortBy === 'dateAsc') list.sort((a, b) => a.date.localeCompare(b.date));
            else if (sortBy === 'totalDesc') list.sort((a, b) => b.total - a.total);
            else if (sortBy === 'totalAsc') list.sort((a, b) => a.total - b.total);
            return list;
        }

        function buildDocLinkPill(poId, docType) {
            const styles = {
                PO: 'bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-blue-300 border-blue-200 dark:border-blue-800 hover:bg-blue-100 dark:hover:bg-blue-900/70',
                GRN: 'bg-emerald-50 dark:bg-emerald-950/50 text-emerald-700 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800 hover:bg-emerald-100 dark:hover:bg-emerald-900/70',
                INV: 'bg-rose-50 dark:bg-rose-950/50 text-rose-700 dark:text-rose-300 border-rose-200 dark:border-rose-800 hover:bg-rose-100 dark:hover:bg-rose-900/70'
            };
            const urlMap = {
                PO: contextPath + '/documents/po.pdf?poId=' + poId,
                GRN: contextPath + '/documents/grn.pdf?poId=' + poId,
                INV: contextPath + '/documents/invoice.pdf?poId=' + poId
            };
            return `<a href="\${urlMap[docType]}" target="_blank" onclick="event.stopPropagation();" title="Download \${docType} PDF" class="inline-flex items-center gap-1 px-2 py-1 rounded-lg text-[10px] font-mono font-bold border transition-colors \${styles[docType]}">
                <i class="fas fa-file-pdf text-[9px]"></i> \${docType}
            </a>`;
        }

        function renderTable() {
            const tbody = document.getElementById('poTableBody');
            const list = getFilteredPOs();

            const filteredSum = list.reduce((s, p) => s + p.total, 0);
            document.getElementById('tableShowingText').textContent = `Showing \${list.length} of \${purchaseOrders.length} Purchase Orders`;
            document.getElementById('tableFilteredTotal').textContent = `Filtered Total: \${formatINR(filteredSum)}`;

            if (list.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="10" class="py-12 px-4 text-center">
                            <div class="text-sm font-bold text-slate-700 dark:text-slate-200">No purchase orders found</div>
                            <p class="text-xs text-slate-400 mt-1">\${purchaseOrders.length === 0 ? 'You have not received any purchase orders yet.' : 'Try clearing your search or switching back to "All".'}</p>
                            \${purchaseOrders.length > 0 ? '<button type="button" onclick="resetFilters()" class="mt-3 px-4 py-1.5 rounded-xl bg-[#0B1E47] text-white text-xs font-semibold hover:opacity-90">Reset Filters</button>' : ''}
                        </td>
                    </tr>
                `;
                return;
            }

            tbody.innerHTML = list.map(po => {
                let primaryActionHtml = '';
                if (po.status === 'PO_SENT') {
                    primaryActionHtml = `<button type="button" onclick="event.stopPropagation(); openAcceptModal(\${po.poId})" class="px-3 py-1.5 rounded-lg text-[11px] font-bold bg-gradient-to-r from-[#102A63] to-[#0D9488] hover:opacity-95 text-white shadow-sm whitespace-nowrap transition-all">
                        <i class="fas fa-check mr-1"></i> Accept PO
                    </button>`;
                } else if (po.status === 'PO_ACCEPTED') {
                    primaryActionHtml = `<button type="button" onclick="event.stopPropagation(); openShipModal(\${po.poId})" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold border-2 border-dashed border-amber-500 bg-amber-500/10 hover:bg-amber-500 text-amber-700 dark:text-amber-300 hover:text-slate-950 whitespace-nowrap transition-all">
                        <i class="fas fa-truck"></i> FILL SHIPPING DETAILS
                    </button>`;
                } else if (po.status === 'DELIVERED' || po.status === 'INVOICING_PENDING' || po.status === 'INVOICE_REQUESTED') {
                    primaryActionHtml = `<button type="button" onclick="event.stopPropagation(); openInvoiceModal(\${po.poId})" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold border-2 border-dashed border-rose-500 bg-rose-500/10 hover:bg-rose-600 text-rose-600 dark:text-rose-300 hover:text-white whitespace-nowrap transition-all">
                        <i class="fas fa-file-invoice"></i> UPLOAD INVOICE
                    </button>`;
                }

                const docPillsHtml = po.docs.map(doc => buildDocLinkPill(po.poId, doc)).join('');

                return `
                    <tr onclick="openDetailDrawer(\${po.poId}, 'PO')" class="hover:bg-slate-50/90 dark:hover:bg-slate-800/45 transition-colors cursor-pointer group">
                        <td class="py-3 px-2.5 font-mono font-bold text-slate-700 dark:text-slate-300 whitespace-nowrap">#\${po.poId}</td>
                        <td class="py-3 px-2.5 whitespace-nowrap">
                            <div class="flex items-center gap-1">
                                <span class="font-mono font-bold text-[#0B1E47] dark:text-[#2DD4BF] text-xs">\${escapeHtml(po.poNumber)}</span>
                                <button type="button" onclick="event.stopPropagation(); copyPoNumber('\${escapeHtml(po.poNumber)}')" title="Copy PO Number" class="p-1 rounded-md text-slate-400 hover:text-slate-700 dark:hover:text-white hover:bg-slate-200/70 dark:hover:bg-slate-700 opacity-70 group-hover:opacity-100 transition-all">
                                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                                    </svg>
                                </button>
                            </div>
                        </td>
                        <td class="py-3 px-2.5 font-semibold text-slate-900 dark:text-white whitespace-nowrap">\${escapeHtml(po.material)}</td>
                        <td class="py-3 px-2.5 text-right font-mono tabular-nums font-semibold text-slate-700 dark:text-slate-200 whitespace-nowrap">\${po.qty.toLocaleString('en-IN')}</td>
                        <td class="py-3 px-2.5 text-right font-mono tabular-nums text-slate-700 dark:text-slate-300 whitespace-nowrap">\${formatINR(po.amount)}</td>
                        <td class="py-3 px-2.5 text-right font-mono tabular-nums text-slate-500 dark:text-slate-400 whitespace-nowrap">\${formatINR(po.gst)}</td>
                        <td class="py-3 px-2.5 text-right font-mono tabular-nums font-extrabold text-slate-900 dark:text-white whitespace-nowrap">\${formatINR(po.total)}</td>
                        <td class="py-3 px-2.5 whitespace-nowrap">\${getStatusBadgeHtml(po.status)}</td>
                        <td class="py-3 px-2.5 font-mono tabular-nums text-[11px] text-slate-500 dark:text-slate-400 whitespace-nowrap">\${escapeHtml(po.date)}</td>
                        <td class="py-3 px-2.5 whitespace-nowrap text-right">
                            <div class="inline-flex items-center justify-end gap-1.5">
                                \${primaryActionHtml}
                                \${docPillsHtml}
                                <button type="button" onclick="event.stopPropagation(); openDetailDrawer(\${po.poId}, 'PO')" title="View Order Lifecycle & Documents" class="p-1.5 rounded-lg text-slate-500 dark:text-slate-400 hover:text-[#0B1E47] dark:hover:text-[#2DD4BF] hover:bg-slate-100 dark:hover:bg-slate-800 border border-transparent hover:border-slate-200 dark:hover:border-slate-700 transition-all">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                </button>
                            </div>
                        </td>
                    </tr>
                `;
            }).join('');
        }

        function resetFilters() {
            document.getElementById('searchInput').value = '';
            document.getElementById('sortSelect').value = 'dateDesc';
            setStatusFilter('ALL');
        }

        function setTableDensity(mode) {
            activeDensity = mode;
            const table = document.getElementById('poTable');
            const comfBtn = document.getElementById('densityComfortableBtn');
            const compBtn = document.getElementById('densityCompactBtn');

            if (mode === 'compact') {
                table.classList.add('density-compact');
                compBtn.className = 'px-2.5 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                comfBtn.className = 'px-2.5 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            } else {
                table.classList.remove('density-compact');
                comfBtn.className = 'px-2.5 py-1 rounded-lg bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm transition-all';
                compBtn.className = 'px-2.5 py-1 rounded-lg text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-all';
            }
        }

        function copyPoNumber(poNumber) {
            try {
                const tempInput = document.createElement('textarea');
                tempInput.value = poNumber;
                tempInput.style.position = 'fixed';
                tempInput.style.opacity = '0';
                document.body.appendChild(tempInput);
                tempInput.select();
                document.execCommand('copy');
                document.body.removeChild(tempInput);
                showToast(`Copied \${poNumber} to clipboard`, 'info');
            } catch (err) {
                showToast(`PO Number: \${poNumber}`, 'info');
            }
        }

        // =================================================================
        // MODAL 1: ACCEPT PO (Real POST /pos/accept)
        // =================================================================
        function openAcceptModal(poId) {
            const po = purchaseOrders.find(p => p.poId === poId);
            if (!po) return;
            document.getElementById('acceptPoId').value = po.poId;
            document.getElementById('acceptModalPoNo').textContent = po.poNumber;
            document.getElementById('acceptModalMaterial').textContent = `\${po.material} (Qty: \${po.qty.toLocaleString('en-IN')})`;
            document.getElementById('acceptModalBreakdown').textContent = `\${formatINR(po.amount)} + \${formatINR(po.gst)} GST`;
            document.getElementById('acceptModalTotal').textContent = formatINR(po.total);
            document.getElementById('acceptConfirmCheck').checked = true;

            const modal = document.getElementById('acceptPoModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeAcceptModal() {
            const modal = document.getElementById('acceptPoModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        // =================================================================
        // MODAL 2: SHIPPING DETAILS (Real POST /shipments/ship)
        // =================================================================
        function openShipModal(poId) {
            const po = purchaseOrders.find(p => p.poId === poId);
            if (!po) return;
            document.getElementById('shipPoId').value = po.poId;
            document.getElementById('shipModalPoNo').textContent = po.poNumber;
            document.getElementById('shipModalMaterial').textContent = `\${po.material} × \${po.qty.toLocaleString('en-IN')}`;
            document.getElementById('shipAsn').value = '';
            document.getElementById('shipCarrier').value = '';
            document.getElementById('shipTracking').value = '';

            const modal = document.getElementById('shipModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeShipModal() {
            const modal = document.getElementById('shipModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        // =================================================================
        // MODAL 3: UPLOAD INVOICE (Real POST /invoices/upload)
        // =================================================================
        function openInvoiceModal(poId) {
            const po = purchaseOrders.find(p => p.poId === poId);
            if (!po) return;
            document.getElementById('invPoId').value = po.poId;
            document.getElementById('invModalPoNo').textContent = po.poNumber;
            document.getElementById('invModalMaterial').textContent = `\${po.material} × \${po.qty.toLocaleString('en-IN')}`;
            document.getElementById('invModalAmount').textContent = formatINR(po.amount);
            document.getElementById('invModalGst').textContent = formatINR(po.gst);
            document.getElementById('invModalTotal').textContent = formatINR(po.total);

            document.getElementById('invPrice').value = po.amount.toFixed(2);
            document.getElementById('invQty').value = po.qty;
            document.getElementById('invNumber').value = '';

            const modal = document.getElementById('invoiceModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeInvoiceModal() {
            const modal = document.getElementById('invoiceModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        // =================================================================
        // SLIDE-OVER DOCUMENT & LIFECYCLE DRAWER
        // =================================================================
        function openDetailDrawer(poId, initialDocTab = 'PO') {
            drawerPoId = poId;
            const po = purchaseOrders.find(p => p.poId === poId);
            if (!po) return;

            drawerActiveDocTab = po.docs.includes(initialDocTab) ? initialDocTab : (po.docs[0] || 'PO');
            renderDrawerContent();

            document.getElementById('detailDrawerOverlay').classList.remove('hidden');
            document.getElementById('detailDrawer').classList.remove('translate-x-full');
        }

        function closeDetailDrawer() {
            document.getElementById('detailDrawer').classList.add('translate-x-full');
            document.getElementById('detailDrawerOverlay').classList.add('hidden');
            drawerPoId = null;
        }

        function switchDrawerDocTab(docType) {
            drawerActiveDocTab = docType;
            renderDrawerContent();
        }

        function getLifecycleStageIndex(status) {
            const stages = {
                PO_DRAFT: 0,
                PO_SENT: 0,
                PO_ACCEPTED: 1,
                SHIPPED: 2,
                DELIVERED: 3,
                INVOICING_PENDING: 4,
                INVOICE_REQUESTED: 4,
                PAYMENT_PENDING: 5,
                PAYMENT_SUCCESSFUL: 6,
                CLOSED: 6
            };
            return stages[status] !== undefined ? stages[status] : 0;
        }

        function renderDrawerContent() {
            const po = purchaseOrders.find(p => p.poId === drawerPoId);
            if (!po) return;

            document.getElementById('drawerPoNumber').textContent = po.poNumber + ' (#' + po.poId + ')';
            document.getElementById('drawerStatusPill').innerHTML = getStatusBadgeHtml(po.status);
            document.getElementById('drawerMaterialTitle').textContent = po.material;
            document.getElementById('drawerMetaSub').textContent = `Issued \${po.date} • Qty: \${po.qty.toLocaleString('en-IN')} • Total: \${formatINR(po.total)}`;

            const quickActionEl = document.getElementById('drawerQuickWorkflowAction');
            if (po.status === 'PO_SENT') {
                quickActionEl.innerHTML = `<button type="button" onclick="openAcceptModal(\${po.poId})" class="px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0D9488] text-white hover:opacity-90">✓ Accept PO</button>`;
            } else if (po.status === 'PO_ACCEPTED') {
                quickActionEl.innerHTML = `<button type="button" onclick="openShipModal(\${po.poId})" class="px-3 py-1.5 rounded-lg text-[11px] font-bold bg-amber-500 text-slate-950 hover:opacity-90"><i class="fas fa-truck mr-1"></i> Fill Shipping Details</button>`;
            } else if (po.status === 'DELIVERED' || po.status === 'INVOICING_PENDING' || po.status === 'INVOICE_REQUESTED') {
                quickActionEl.innerHTML = `<button type="button" onclick="openInvoiceModal(\${po.poId})" class="px-3 py-1.5 rounded-lg text-[11px] font-bold bg-rose-600 text-white hover:opacity-90"><i class="fas fa-file-invoice mr-1"></i> Upload Invoice</button>`;
            } else {
                quickActionEl.innerHTML = '';
            }

            const steps = ['PO Sent', 'Accepted', 'Shipped', 'Delivered', 'Invoice Req', 'Pay Pending', 'Paid / Closed'];
            const currentIdx = getLifecycleStageIndex(po.status);
            document.getElementById('drawerStepper').innerHTML = steps.map((label, i) => {
                const done = i <= currentIdx;
                const active = i === currentIdx;
                return `
                    <div class="flex flex-col items-center text-center">
                        <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-mono font-bold mb-1.5 \${done ? 'bg-[#0D9488] text-white' : 'bg-slate-200 dark:bg-slate-800 text-slate-400'} \${active ? 'ring-4 ring-teal-500/25' : ''}">
                            \${done ? '✓' : i + 1}
                        </div>
                        <span class="text-[10px] leading-tight font-semibold \${done ? 'text-slate-800 dark:text-slate-100' : 'text-slate-400'}">\${label}</span>
                    </div>
                `;
            }).join('');

            const docDefs = [
                { key: 'PO', label: 'Purchase Order' },
                { key: 'GRN', label: 'GRN Receipt' },
                { key: 'INV', label: 'Tax Invoice' }
            ];
            document.getElementById('drawerDocTabs').innerHTML = docDefs.map(d => {
                const available = po.docs.includes(d.key);
                const isActive = drawerActiveDocTab === d.key;
                if (!available) {
                    return `<button type="button" disabled class="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-400 dark:text-slate-600 cursor-not-allowed">\${d.label} (Pending)</button>`;
                }
                return `<button type="button" onclick="switchDrawerDocTab('\${d.key}')" class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all \${isActive ? 'bg-white dark:bg-slate-700 text-[#0B1E47] dark:text-[#2DD4BF] shadow-sm' : 'text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white'}">
                    \${d.label}
                </button>`;
            }).join('');

            const pdfUrlMap = {
                PO: contextPath + '/documents/po.pdf?poId=' + po.poId,
                GRN: contextPath + '/documents/grn.pdf?poId=' + po.poId,
                INV: contextPath + '/documents/invoice.pdf?poId=' + po.poId
            };
            const pdfLink = document.getElementById('drawerPdfDownloadLink');
            if (po.docs.includes(drawerActiveDocTab)) {
                pdfLink.href = pdfUrlMap[drawerActiveDocTab];
                pdfLink.classList.remove('hidden');
            } else {
                pdfLink.classList.add('hidden');
            }

            const docTitleMap = {
                PO: 'OFFICIAL PURCHASE ORDER',
                GRN: 'GOODS RECEIPT NOTE (GRN)',
                INV: 'SUPPLIER TAX INVOICE (GST)'
            };
            const docRefMap = {
                PO: po.poNumber,
                GRN: `GRN-\${po.poId}`,
                INV: `INV-\${po.poId}`
            };
            const unitRate = po.qty > 0 ? (po.amount / po.qty) : po.amount;

            document.getElementById('printableDocumentArea').innerHTML = `
                <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4 pb-5 border-b border-slate-200 dark:border-slate-800">
                    <div>
                        <div class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#0B1E47] text-white text-xs font-extrabold tracking-tight">
                            <span>Supple<span class="text-[#2DD4BF]">xio</span></span>
                        </div>
                        <h4 class="text-base font-extrabold text-slate-900 dark:text-white mt-2">\${docTitleMap[drawerActiveDocTab] || 'PURCHASE ORDER'}</h4>
                        <p class="text-[11px] font-mono text-slate-500 dark:text-slate-400">Doc Ref: \${escapeHtml(docRefMap[drawerActiveDocTab] || po.poNumber)}</p>
                    </div>
                    <div class="sm:text-right text-xs space-y-0.5">
                        <div class="font-mono font-bold text-slate-800 dark:text-slate-100">Date: \${escapeHtml(po.date)}</div>
                        <div class="text-[11px] text-slate-500 dark:text-slate-400">Currency: INR (₹)</div>
                        <div class="pt-1">\${getStatusBadgeHtml(po.status)}</div>
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 py-4 border-b border-slate-200 dark:border-slate-800 text-xs">
                    <div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900/70 border border-slate-200/70 dark:border-slate-800">
                        <span class="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">Supplier (Vendor)</span>
                        <div class="font-bold text-slate-900 dark:text-white">\${escapeHtml(supplierDisplayName)}</div>
                        <div class="text-slate-500 dark:text-slate-400 mt-0.5">\${escapeHtml(supplierDisplayEmail)}</div>
                    </div>
                    <div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-900/70 border border-slate-200/70 dark:border-slate-800">
                        <span class="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">Buyer (Bill To / Ship To)</span>
                        <div class="font-bold text-slate-900 dark:text-white">\${escapeHtml(po.companyName)}</div>
                        <div class="text-slate-500 dark:text-slate-400 mt-0.5">Supplexio Enterprise Procurement</div>
                    </div>
                </div>

                <div class="py-4">
                    <table class="w-full text-xs border-collapse">
                        <thead>
                            <tr class="border-b border-slate-200 dark:border-slate-800 text-[10px] uppercase tracking-wider text-slate-400">
                                <th class="py-2 text-left">Material Description</th>
                                <th class="py-2 text-right">Qty</th>
                                <th class="py-2 text-right">Unit Rate</th>
                                <th class="py-2 text-right">Line Amount</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                            <tr>
                                <td class="py-3 font-bold text-slate-900 dark:text-white">
                                    \${escapeHtml(po.material)}
                                    <div class="text-[10px] font-normal text-slate-400">Awarded via Supplexio Reverse Auction Platform</div>
                                </td>
                                <td class="py-3 text-right font-mono tabular-nums">\${po.qty.toLocaleString('en-IN')}</td>
                                <td class="py-3 text-right font-mono tabular-nums">\${formatINR(unitRate)}</td>
                                <td class="py-3 text-right font-mono tabular-nums font-bold">\${formatINR(po.amount)}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="pt-4 border-t border-slate-200 dark:border-slate-800 flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                    <div class="text-[11px] text-slate-500 dark:text-slate-400 space-y-1">
                        \${drawerActiveDocTab === 'GRN' ? `<div class="text-emerald-600 dark:text-emerald-400 font-semibold">✓ Quantity Inspected &amp; Verified</div>` : ''}
                    </div>
                    <div class="w-full sm:w-64 space-y-1.5 text-xs">
                        <div class="flex justify-between text-slate-600 dark:text-slate-300">
                            <span>Taxable Amount</span>
                            <span class="font-mono tabular-nums">\${formatINR(po.amount)}</span>
                        </div>
                        <div class="flex justify-between text-slate-600 dark:text-slate-300">
                            <span>GST (7.5%)</span>
                            <span class="font-mono tabular-nums">\${formatINR(po.gst)}</span>
                        </div>
                        <div class="flex justify-between pt-2 border-t border-slate-200 dark:border-slate-800 text-sm font-extrabold text-slate-900 dark:text-white">
                            <span>Grand Total</span>
                            <span class="font-mono tabular-nums text-[#0D9488] dark:text-[#2DD4BF]">\${formatINR(po.total)}</span>
                        </div>
                    </div>
                </div>
            `;
        }

        function printCurrentDocument() {
            showToast('Opening print / Save PDF dialog...', 'info');
            window.print();
        }

        function exportFilteredCsv() {
            const list = getFilteredPOs();
            if (list.length === 0) {
                showToast('No Purchase Orders to export for current filter.', 'warning');
                return;
            }
            const headers = ['PO ID', 'PO Number', 'Material', 'Qty', 'Amount (INR)', 'GST 7.5% (INR)', 'Total (INR)', 'Status', 'Date', 'Documents'];
            const rows = list.map(p => [
                p.poId,
                p.poNumber,
                `"\${p.material.replace(/"/g, '""')}"`,
                p.qty,
                p.amount.toFixed(2),
                p.gst.toFixed(2),
                p.total.toFixed(2),
                p.status,
                p.date,
                `"\${p.docs.join(', ')}"`
            ]);

            const csvContent = [headers.join(','), ...rows.map(r => r.join(','))].join('\n');
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.setAttribute('href', url);
            link.setAttribute('download', `supplexio_supplier_pos_\${new Date().toISOString().slice(0, 10)}.csv`);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);

            showToast(`Exported \${list.length} Purchase Orders to CSV.`, 'success');
        }

        function toggleDarkMode() {
            const isDark = !document.documentElement.classList.contains('dark');
            document.documentElement.classList.toggle('dark', isDark);
            document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
            localStorage.setItem('sp-theme', isDark ? 'dark' : 'light');
            const darkTog = document.getElementById('spDarkToggle');
            if (darkTog) darkTog.checked = isDark;
        }

        function toggleMobileSidebar() {
            document.getElementById('sidebar').classList.toggle('-translate-x-full');
            document.getElementById('sidebarBackdrop').classList.toggle('hidden');
        }

        function showToast(message, type = 'info') {
            const container = document.getElementById('toastContainer');
            const palette = {
                success: 'bg-emerald-950/95 border-emerald-500/40 text-emerald-100',
                warning: 'bg-amber-950/95 border-amber-500/40 text-amber-100',
                info: 'bg-[#0B1E47]/95 border-cyan-400/35 text-white'
            };
            const toast = document.createElement('div');
            toast.className = `toast-enter pointer-events-auto px-4 py-3 rounded-xl border shadow-xl text-xs font-medium flex items-center justify-between gap-3 backdrop-blur-md \${palette[type] || palette.info}`;
            toast.innerHTML = `<span>\${escapeHtml(message)}</span>`;
            container.appendChild(toast);
            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(12px)';
                toast.style.transition = 'all 0.25s ease';
                setTimeout(() => toast.remove(), 260);
            }, 3400);
        }

        function toggleAiCopilot() {
            const pop = document.getElementById('aiCopilotPopover');
            pop.classList.toggle('hidden');
            pop.classList.toggle('flex');
        }

        function sendCopilotPrompt(promptText) {
            document.getElementById('copilotInput').value = promptText;
            handleCopilotSubmit(new Event('submit'));
        }

        function handleCopilotSubmit(e) {
            e.preventDefault();
            const input = document.getElementById('copilotInput');
            const text = input.value.trim();
            if (!text) return;

            const box = document.getElementById('copilotMessages');
            const userMsg = document.createElement('div');
            userMsg.className = 'p-2.5 rounded-xl bg-amber-500/15 border border-amber-500/30 text-slate-900 dark:text-slate-100 font-medium ml-6';
            userMsg.textContent = text;
            box.appendChild(userMsg);
            input.value = '';

            setTimeout(() => {
                const lower = text.toLowerCase();
                const toAccept = purchaseOrders.filter(p => p.status === 'PO_SENT');
                const toShip = purchaseOrders.filter(p => p.status === 'PO_ACCEPTED');
                const invDue = purchaseOrders.filter(p => p.status === 'DELIVERED' || p.status === 'INVOICING_PENDING' || p.status === 'INVOICE_REQUESTED');
                const totalGst = purchaseOrders.reduce((s, p) => s + p.gst, 0);
                const totalVal = purchaseOrders.reduce((s, p) => s + p.total, 0);

                let reply = `You currently have <strong>\${purchaseOrders.length} Purchase Orders</strong> totaling <strong>\${formatINR(totalVal)}</strong>.`;
                if (lower.includes('pending') || lower.includes('action')) {
                    reply = `<strong>Pending Actions (\${toAccept.length + toShip.length + invDue.length}):</strong><br>• <strong>\${toAccept.length} to Accept:</strong> \${toAccept.map(p => p.poNumber).join(', ') || 'None'}<br>• <strong>\${toShip.length} to Ship (ASN):</strong> \${toShip.map(p => p.poNumber).join(', ') || 'None'}<br>• <strong>\${invDue.length} Invoices Due:</strong> \${invDue.map(p => p.poNumber).join(', ') || 'None'}`;
                } else if (lower.includes('gst') || lower.includes('tax')) {
                    reply = `Total <strong>7.5% GST</strong> across all \${purchaseOrders.length} POs is <strong class="font-mono">\${formatINR(totalGst)}</strong> on a combined grand total of <strong class="font-mono">\${formatINR(totalVal)}</strong>.`;
                } else if (lower.includes('invoice') || lower.includes('due')) {
                    reply = invDue.length > 0
                        ? `<strong>\${invDue.length} POs</strong> require a Commercial Invoice: \${invDue.map(p => `<strong>\${p.poNumber}</strong> (\${p.material}, \${formatINR(p.total)})`).join(', ')}.`
                        : `All delivered POs have their invoices submitted!`;
                }

                const aiMsg = document.createElement('div');
                aiMsg.className = 'p-2.5 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 leading-relaxed mr-4';
                aiMsg.innerHTML = reply;
                box.appendChild(aiMsg);
                box.scrollTop = box.scrollHeight;
            }, 350);
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

            updateDashboardMetrics();
            renderTable();
        });
    </script>
</body>
</html>
