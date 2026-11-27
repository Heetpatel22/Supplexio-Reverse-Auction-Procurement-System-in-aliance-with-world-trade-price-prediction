<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en" class="h-full" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Buyer Settings &amp; Workspace Configuration</title>

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
                            midnavy: '#12336B',
                            royal: '#16367D',
                            deepblue: '#1E3A8A',
                            teal: '#0D9488',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            emerald: '#10B981',
                            canvas: '#F4F7FC'
                        }
                    },
                    boxShadow: {
                        'card': '0 1px 3px rgba(15, 23, 42, 0.04), 0 6px 18px -6px rgba(15, 23, 42, 0.06)',
                        'card-hover': '0 10px 24px -8px rgba(11, 30, 71, 0.12)'
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
        .ring-progress {
            transition: stroke-dashoffset 0.65s cubic-bezier(0.16, 1, 0.3, 1), stroke 0.3s ease;
        }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }
        input[type="range"].supple-slider { accent-color: #0D9488; }
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

    <!-- Buyer Unified Left Sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <!-- Toast Notification Stack -->
    <div id="toastContainer" class="fixed top-5 right-5 z-[80] flex flex-col gap-2.5 max-w-sm w-full pointer-events-none"></div>

    <div class="main-content min-h-screen">
        <div class="p-4 sm:p-6 lg:p-7 max-w-[1520px] w-full mx-auto space-y-6">

            <!-- Session Feedback Alerts -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-emerald-500/12 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold shadow-sm">
                    <div class="flex items-center gap-2.5">
                        <i class="fas fa-check-circle text-emerald-500 text-sm"></i>
                        <span><c:out value="${sessionScope.successMessage}"/></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-emerald-500/15">&times;</button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-rose-500/12 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold shadow-sm">
                    <div class="flex items-center gap-2.5">
                        <i class="fas fa-exclamation-circle text-rose-500 text-sm"></i>
                        <span><c:out value="${sessionScope.errorMessage}"/></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-rose-500/15">&times;</button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.pwdSuccess}">
                <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-emerald-500/12 border border-emerald-500/30 text-emerald-700 dark:text-emerald-300 text-xs font-semibold shadow-sm">
                    <div class="flex items-center gap-2.5">
                        <i class="fas fa-check-circle text-emerald-500 text-sm"></i>
                        <span><c:out value="${sessionScope.pwdSuccess}"/></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-emerald-500/15">&times;</button>
                </div>
                <c:remove var="pwdSuccess" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.pwdError}">
                <div class="flex items-center justify-between gap-3 px-4 py-3 rounded-2xl bg-rose-500/12 border border-rose-500/30 text-rose-700 dark:text-rose-300 text-xs font-semibold shadow-sm">
                    <div class="flex items-center gap-2.5">
                        <i class="fas fa-exclamation-circle text-rose-500 text-sm"></i>
                        <span><c:out value="${sessionScope.pwdError}"/></span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="p-1 rounded-lg hover:bg-rose-500/15">&times;</button>
                </div>
                <c:remove var="pwdError" scope="session" />
            </c:if>

            <!-- ======================================================= -->
            <!-- TOP UTILITY BAR                                         -->
            <!-- ======================================================= -->
            <header class="bg-white dark:bg-[#111827] border border-[#E2E8F0] dark:border-[#1E293B] rounded-2xl px-4 sm:px-5 py-3.5 shadow-card flex flex-col xl:flex-row xl:items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-2 text-xs font-medium">
                    <a href="${pageContext.request.contextPath}/" class="text-slate-400 dark:text-slate-500 hover:text-[#0B1E47] dark:hover:text-[#2DD4BF] font-semibold transition-colors">Buyer Workspace</a>
                    <span class="text-slate-300 dark:text-slate-600">/</span>
                    <span class="text-[#0B1E47] dark:text-[#2DD4BF] font-bold">Settings &amp; Profile</span>
                    <span id="unsavedIndicator" class="hidden ml-1 inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/15 text-amber-700 dark:text-amber-300 border border-amber-500/35">
                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
                        Unsaved Changes
                    </span>
                </div>

                <div class="flex flex-wrap items-center gap-2">
                    <button type="button" onclick="toggleDarkMode()" class="inline-flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 border border-slate-200 dark:border-slate-700 transition-all">
                        <svg class="w-3.5 h-3.5 text-amber-500 dark:text-amber-300" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                        </svg>
                        <span id="topDarkModeLabel">Dark Mode</span>
                    </button>

                    <button type="button" onclick="openBuyerPreviewModal()" class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-slate-900 hover:bg-slate-50 dark:hover:bg-slate-800 text-[#0B1E47] dark:text-[#2DD4BF] border border-slate-300 dark:border-slate-700 shadow-sm transition-all">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                        </svg>
                        <span>Preview Buyer Card</span>
                    </button>

                    <button type="button" onclick="exportConfigJson()" class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-slate-900 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-200 border border-slate-300 dark:border-slate-700 shadow-sm transition-all">
                        <svg class="w-4 h-4 text-[#0D9488] dark:text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                        </svg>
                        <span>Export Config</span>
                    </button>

                    <button type="submit" form="buyerProfileForm" class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#1E3A8A] via-[#154B87] to-[#0D9488] hover:opacity-95 active:scale-[0.99] text-white shadow-md transition-all">
                        <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
                        </svg>
                        <span>Save Changes</span>
                    </button>
                </div>
            </header>

            <!-- ======================================================= -->
            <!-- EXECUTIVE COMMAND HERO                                  -->
            <!-- ======================================================= -->
            <c:set var="displayCompany" value="${not empty buyerProfile['companyName'] ? buyerProfile['companyName'] : (not empty currentUser.username ? currentUser.username : 'Supplexio Buyer Workspace')}" />
            <c:set var="displayRole" value="${not empty buyerProfile['designation'] ? buyerProfile['designation'] : currentUser.role}" />
            <c:set var="displayAddress" value="${not empty buyerProfile['address'] ? buyerProfile['address'] : 'India'}" />
            <section class="relative overflow-hidden rounded-2xl text-white p-6 lg:p-7 shadow-lg border border-white/10" style="background: linear-gradient(115deg, #0B1E47 0%, #12336B 52%, #0F3D4C 100%);">
                <div class="absolute inset-0 hero-dot-grid opacity-75 pointer-events-none"></div>
                <div class="absolute -top-24 -right-20 w-80 h-80 rounded-full bg-cyan-400/15 blur-3xl pointer-events-none"></div>

                <div class="relative z-10 flex flex-col xl:flex-row xl:items-center justify-between gap-6">
                    <div class="flex flex-col sm:flex-row sm:items-center gap-5">
                        <div id="heroLogoContainer" class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl bg-gradient-to-br from-[#2DD4BF] via-[#0D9488] to-[#0B1E47] border-2 border-cyan-300/40 shadow-xl flex items-center justify-center text-2xl sm:text-3xl font-extrabold text-white uppercase shrink-0">
                            <c:out value="${fn:substring(displayCompany, 0, 2)}"/>
                        </div>

                        <div class="space-y-2">
                            <div class="flex flex-wrap items-center gap-2">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider bg-cyan-400/15 text-[#2DD4BF] border border-cyan-400/35">
                                    ENTERPRISE BUYER
                                </span>
                                <span id="heroGstinPill" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 border border-emerald-400/35">
                                    ✓ <c:out value="${currentUser.role}"/>
                                </span>
                            </div>

                            <h1 id="heroCompanyTitle" class="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                                <c:out value="${displayCompany}"/>
                            </h1>

                            <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-slate-200/90">
                                <span class="inline-flex items-center gap-1.5 font-medium">
                                    <i class="fas fa-map-marker-alt text-[#2DD4BF]"></i>
                                    <span id="heroLocationText"><c:out value="${displayAddress}"/></span>
                                </span>
                                <span class="inline-flex items-center gap-1.5 font-medium">
                                    <i class="fas fa-briefcase text-[#2DD4BF]"></i>
                                    <span id="heroRoleText"><c:out value="${displayRole}"/></span>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Workspace Readiness Ring -->
                    <div class="bg-white/10 backdrop-blur-md border border-white/15 rounded-2xl p-4 flex items-center gap-4 shadow-xl min-w-[260px]">
                        <div class="relative w-16 h-16 shrink-0">
                            <svg class="w-16 h-16 -rotate-90" viewBox="0 0 64 64">
                                <circle cx="32" cy="32" r="26" fill="none" stroke="rgba(255,255,255,0.16)" stroke-width="6"></circle>
                                <circle id="readinessRingCircle" class="ring-progress" cx="32" cy="32" r="26" fill="none" stroke="#2DD4BF" stroke-width="6" stroke-linecap="round" stroke-dasharray="163.36" stroke-dashoffset="13.07"></circle>
                            </svg>
                            <div class="absolute inset-0 flex items-center justify-center">
                                <span id="readinessPercentText" class="text-sm font-extrabold font-mono tabular-nums text-white">80%</span>
                            </div>
                        </div>
                        <div class="min-w-0">
                            <div class="text-[10px] font-mono uppercase tracking-wider text-cyan-200/85 font-bold">Workspace Readiness</div>
                            <div id="readinessStatusLabel" class="text-xs font-bold text-white mt-0.5">Profile Active</div>
                            <div id="readinessDocsSummary" class="text-[10px] font-mono text-cyan-200 mt-1">0 / 3 Documents Uploaded</div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- 3-TAB WORKSPACE SWITCHER (Evenly Spaced 3 Tabs)         -->
            <!-- ======================================================= -->
            <div class="bg-white dark:bg-[#111827] border border-[#E2E8F0] dark:border-[#1E293B] rounded-2xl p-1.5 shadow-card">
                <nav class="grid grid-cols-1 sm:grid-cols-3 gap-1.5" role="tablist">
                    <button type="button" id="tabBtn-org" onclick="switchWorkspaceTab('org')" class="workspace-tab-btn w-full justify-center px-4 py-2.5 rounded-xl text-xs font-bold transition-all flex items-center gap-2 bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm">
                        <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                        <span>Organization &amp; Buyer Profile</span>
                    </button>

                    <button type="button" id="tabBtn-auction" onclick="switchWorkspaceTab('auction')" class="workspace-tab-btn w-full justify-center px-4 py-2.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800">
                        <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                        <span>Auction &amp; AI Rules</span>
                    </button>

                    <button type="button" id="tabBtn-security" onclick="switchWorkspaceTab('security')" class="workspace-tab-btn w-full justify-center px-4 py-2.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800">
                        <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                        <span>Security &amp; Preferences</span>
                    </button>
                </nav>
            </div>

            <!-- ======================================================= -->
            <!-- TAB 1: ORGANIZATION & BUYER PROFILE                     -->
            <!-- ======================================================= -->
            <section id="tabPanel-org" class="tab-panel active">
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <!-- Main 8-Column Form Area -->
                    <form id="buyerProfileForm" method="post" action="${pageContext.request.contextPath}/settings" class="lg:col-span-8 space-y-6">
                        <input type="hidden" name="action" value="updateBuyerProfile">

                        <!-- Card A: Core Buyer Account & Registration Details -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex flex-wrap items-center justify-between gap-2">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-[#0B1E47] to-[#0D9488] text-white flex items-center justify-center shadow-sm">
                                        <svg class="w-4 h-4 text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Core Buyer Account &amp; Registration Details</h2>
                                        <p class="text-[11px] text-slate-500 dark:text-slate-400">Legal entity information embedded into Reverse Auctions, Purchase Orders, and GST invoices.</p>
                                    </div>
                                </div>
                                <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-blue-50 dark:bg-blue-950/60 text-[#1E3A8A] dark:text-[#2DD4BF] border border-blue-200 dark:border-blue-800">
                                    BUYER IDENTITY
                                </span>
                            </div>

                            <div class="p-5 grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="md:col-span-2">
                                    <label for="companyNameInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Company / Legal Entity Name <span class="text-rose-500">*</span></label>
                                    <input type="text" id="companyNameInput" name="companyName" required value="<c:out value='${displayCompany}'/>" oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-sm font-semibold bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white transition-all">
                                </div>

                                <div>
                                    <label for="businessTypeSelect" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Business Type</label>
                                    <select id="businessTypeSelect" name="businessType" onchange="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white cursor-pointer">
                                        <option value="Manufacturing & OEM" ${buyerProfile['businessType'] == 'Manufacturing & OEM' ? 'selected' : ''}>Manufacturing &amp; OEM</option>
                                        <option value="Construction & Infrastructure" ${buyerProfile['businessType'] == 'Construction & Infrastructure' ? 'selected' : ''}>Construction &amp; Infrastructure</option>
                                        <option value="EPC & Heavy Contracting" ${buyerProfile['businessType'] == 'EPC & Heavy Contracting' ? 'selected' : ''}>EPC &amp; Heavy Contracting</option>
                                        <option value="Wholesale & Distribution" ${buyerProfile['businessType'] == 'Wholesale & Distribution' ? 'selected' : ''}>Wholesale &amp; Distribution</option>
                                        <option value="Industrial Services" ${buyerProfile['businessType'] == 'Industrial Services' ? 'selected' : ''}>Industrial Services</option>
                                        <option value="Retail & E-Commerce" ${buyerProfile['businessType'] == 'Retail & E-Commerce' ? 'selected' : ''}>Retail &amp; E-Commerce</option>
                                    </select>
                                </div>

                                <div>
                                    <div class="flex items-center justify-between mb-1.5">
                                        <label for="workEmailInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300">Work Email <span class="text-rose-500">*</span></label>
                                        <span class="px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Verified</span>
                                    </div>
                                    <input type="email" id="workEmailInput" name="email" required value="<c:out value='${currentUser.email}'/>" oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                                </div>

                                <div>
                                    <label for="usernameInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Username</label>
                                    <input type="text" id="usernameInput" readonly value="<c:out value='${currentUser.username}'/>" class="w-full px-3.5 py-2.5 text-xs font-mono bg-slate-100 dark:bg-slate-800/70 border border-slate-200 dark:border-slate-700 rounded-xl text-slate-500 dark:text-slate-400 cursor-not-allowed">
                                </div>

                                <div>
                                    <label for="designationInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Your Role / Designation</label>
                                    <input type="text" id="designationInput" name="designation" value="<c:out value='${displayRole}'/>" oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                                </div>

                                <div>
                                    <label for="workPhoneInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Work Phone</label>
                                    <input type="tel" id="workPhoneInput" name="phone" value="<c:out value='${buyerProfile["phone"]}'/>" placeholder="+91 9876543210" oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs font-mono tabular-nums bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                                </div>

                                <div>
                                    <div class="flex items-center justify-between mb-1.5">
                                        <label for="gstinInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300">GSTIN / Tax ID</label>
                                        <span id="gstinStatusBadge" class="px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-slate-100 dark:bg-slate-800 text-slate-500">Optional</span>
                                    </div>
                                    <input type="text" id="gstinInput" name="gstin" value="<c:out value='${buyerProfile["gstin"]}'/>" maxlength="15" placeholder="24AABCA9603R1ZM" oninput="validateGstinLive(); onFieldModified();" class="w-full px-3.5 py-2.5 text-xs font-mono uppercase tabular-nums font-semibold bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white">
                                </div>

                                <div class="md:col-span-2">
                                    <label for="primarySourcingSelect" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Primary Sourcing Category</label>
                                    <select id="primarySourcingSelect" name="sourcingCategory" onchange="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white cursor-pointer">
                                        <option value="Chemicals, Resins & Polymers" ${buyerProfile['sourcingCategory'] == 'Chemicals, Resins & Polymers' ? 'selected' : ''}>Chemicals, Resins &amp; Polymers</option>
                                        <option value="Raw Materials, Steel & Metals" ${buyerProfile['sourcingCategory'] == 'Raw Materials, Steel & Metals' ? 'selected' : ''}>Raw Materials, Steel &amp; Metals</option>
                                        <option value="Electrical, Cables & Hardware" ${buyerProfile['sourcingCategory'] == 'Electrical, Cables & Hardware' ? 'selected' : ''}>Electrical, Cables &amp; Hardware</option>
                                        <option value="Packaging & Logistics" ${buyerProfile['sourcingCategory'] == 'Packaging & Logistics' ? 'selected' : ''}>Packaging &amp; Logistics</option>
                                        <option value="Machinery & Equipment" ${buyerProfile['sourcingCategory'] == 'Machinery & Equipment' ? 'selected' : ''}>Machinery &amp; Equipment</option>
                                        <option value="Multi-Category Procurement" ${buyerProfile['sourcingCategory'] == 'Multi-Category Procurement' ? 'selected' : ''}>Multi-Category Procurement</option>
                                    </select>
                                </div>

                                <div class="md:col-span-2">
                                    <label for="plantAddressInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Registered Plant / Delivery Address</label>
                                    <textarea id="plantAddressInput" name="address" rows="2" placeholder="Plot 18, GIDC Industrial Estate, Vadodara, Gujarat 390010" oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-900 dark:text-white resize-none"><c:out value="${buyerProfile['address']}"/></textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Card B: Sourcing Scope & Procurement Limits -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex flex-wrap items-center justify-between gap-2">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-8 h-8 rounded-xl bg-teal-500/12 text-[#0D9488] dark:text-[#2DD4BF] flex items-center justify-center">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path></svg>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-bold text-slate-900 dark:text-white tracking-tight">Sourcing Scope &amp; Procurement Limits</h2>
                                        <p class="text-[11px] text-slate-500 dark:text-slate-400">Visible to verified suppliers when evaluating your reverse auction RFQs.</p>
                                    </div>
                                </div>
                            </div>

                            <div class="p-5 space-y-5">
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <label for="monthlySpendSelect" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Est. Monthly Procurement Spend</label>
                                        <select id="monthlySpendSelect" name="monthlySpend" onchange="onFieldModified()" class="w-full px-3 py-2 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white cursor-pointer">
                                            <option value="₹10L – ₹50L" ${buyerProfile['monthlySpend'] == '₹10L – ₹50L' ? 'selected' : ''}>₹10L – ₹50L</option>
                                            <option value="₹50L – ₹2Cr" ${buyerProfile['monthlySpend'] == '₹50L – ₹2Cr' or empty buyerProfile['monthlySpend'] ? 'selected' : ''}>₹50L – ₹2Cr</option>
                                            <option value="₹2Cr – ₹10Cr" ${buyerProfile['monthlySpend'] == '₹2Cr – ₹10Cr' ? 'selected' : ''}>₹2Cr – ₹10Cr</option>
                                            <option value="₹10Cr+" ${buyerProfile['monthlySpend'] == '₹10Cr+' ? 'selected' : ''}>₹10Cr+</option>
                                        </select>
                                    </div>

                                    <div>
                                        <label for="paymentTermsSelect" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Default Payment Terms</label>
                                        <select id="paymentTermsSelect" name="paymentTerms" onchange="onFieldModified()" class="w-full px-3 py-2 text-xs font-medium bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white cursor-pointer">
                                            <option value="Net 30 Days" ${buyerProfile['paymentTerms'] == 'Net 30 Days' or empty buyerProfile['paymentTerms'] ? 'selected' : ''}>Net 30 Days</option>
                                            <option value="Net 15 Days" ${buyerProfile['paymentTerms'] == 'Net 15 Days' ? 'selected' : ''}>Net 15 Days</option>
                                            <option value="Escrow on GRN" ${buyerProfile['paymentTerms'] == 'Escrow on GRN' ? 'selected' : ''}>Escrow on GRN</option>
                                            <option value="Advance + Balance" ${buyerProfile['paymentTerms'] == 'Advance + Balance' ? 'selected' : ''}>Advance + Balance</option>
                                        </select>
                                    </div>

                                    <div>
                                        <label for="corporateWebsiteInput" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Corporate Website</label>
                                        <input type="url" id="corporateWebsiteInput" name="website" value="<c:out value='${buyerProfile["website"]}'/>" placeholder="https://company.in" oninput="onFieldModified()" class="w-full px-3 py-2 text-xs font-mono bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white">
                                    </div>
                                </div>

                                <div class="pt-2 border-t border-slate-100 dark:border-[#1E293B]">
                                    <label for="buyerBriefTextarea" class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Buyer Brief for Suppliers</label>
                                    <textarea id="buyerBriefTextarea" name="buyerBrief" rows="3" placeholder="Describe your company's recurring sourcing requirements and payment reliability..." oninput="onFieldModified()" class="w-full px-3.5 py-2.5 text-xs leading-relaxed bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:bg-white dark:focus:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 focus:border-[#0D9488] text-slate-800 dark:text-slate-100"><c:out value="${buyerProfile['buyerBrief']}"/></textarea>
                                </div>
                            </div>

                            <div class="px-5 py-3.5 bg-slate-50/70 dark:bg-slate-900/40 border-t border-slate-100 dark:border-[#1E293B] flex items-center justify-between gap-3">
                                <span class="text-[11px] text-slate-500 dark:text-slate-400">Changes persist directly to your buyer workspace profile.</span>
                                <button type="submit" class="inline-flex items-center gap-2 px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] hover:opacity-95 text-white shadow-md transition-all">
                                    <i class="fas fa-save"></i>
                                    <span>Save Buyer Profile</span>
                                </button>
                            </div>
                        </div>
                    </form>

                    <!-- Right 4-Column Area: 3 Business Documents + Quick Security Summary -->
                    <div class="lg:col-span-4 space-y-6">

                        <!-- Business Documents (3 Optional Upload Cards: PAN, Aadhar, Registration Certificate) -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center justify-between gap-2">
                                <div class="flex items-center gap-2">
                                    <i class="fas fa-folder-open text-[#0D9488] dark:text-[#2DD4BF] text-sm"></i>
                                    <h3 class="text-sm font-bold text-slate-900 dark:text-white">Business Documents</h3>
                                </div>
                                <span class="text-[10px] font-mono font-semibold text-slate-500 dark:text-slate-400">Optional</span>
                            </div>

                            <div class="p-4 space-y-3">
                                <!-- 1. Company PAN Card -->
                                <form method="post" action="${pageContext.request.contextPath}/settings" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadBuyerDocument">
                                    <input type="hidden" name="docType" value="PAN">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Company PAN Card</div>
                                        <c:choose>
                                            <c:when test="${not empty buyerDocs['PAN']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty buyerDocs['PAN']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${buyerDocs['PAN']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty buyerDocs['PAN'] ? 'Replace' : 'Upload PAN'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty buyerDocs['PAN']}">
                                            <a href="${pageContext.request.contextPath}/settings?action=viewBuyerDocument&docType=PAN" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteBuyerDoc('PAN')" title="Delete uploaded PAN document" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>

                                <!-- 2. Aadhar Card of the Owner -->
                                <form method="post" action="${pageContext.request.contextPath}/settings" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadBuyerDocument">
                                    <input type="hidden" name="docType" value="AADHAR">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Aadhar Card of the Owner</div>
                                        <c:choose>
                                            <c:when test="${not empty buyerDocs['AADHAR']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty buyerDocs['AADHAR']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${buyerDocs['AADHAR']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty buyerDocs['AADHAR'] ? 'Replace' : 'Upload Aadhar'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty buyerDocs['AADHAR']}">
                                            <a href="${pageContext.request.contextPath}/settings?action=viewBuyerDocument&docType=AADHAR" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteBuyerDoc('AADHAR')" title="Delete uploaded Aadhar document" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>

                                <!-- 3. Business Registration Certificate -->
                                <form method="post" action="${pageContext.request.contextPath}/settings" enctype="multipart/form-data" class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] space-y-2">
                                    <input type="hidden" name="action" value="uploadBuyerDocument">
                                    <input type="hidden" name="docType" value="REG_CERT">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Business Registration Certificate</div>
                                        <c:choose>
                                            <c:when test="${not empty buyerDocs['REG_CERT']}">
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">✓ Provided</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-slate-200/70 dark:bg-slate-800 text-slate-500 dark:text-slate-400">Optional</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty buyerDocs['REG_CERT']}">
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 truncate"><c:out value="${buyerDocs['REG_CERT']}"/></div>
                                    </c:if>
                                    <div class="flex items-center gap-2 pt-1">
                                        <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[11px] font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white cursor-pointer transition-all">
                                            <i class="fas fa-upload text-[10px]"></i>
                                            <span>${not empty buyerDocs['REG_CERT'] ? 'Replace' : 'Upload Certificate'}</span>
                                            <input type="file" name="docFile" accept=".pdf,.png,.jpg,.jpeg" class="hidden" onchange="this.form.submit()">
                                        </label>
                                        <c:if test="${not empty buyerDocs['REG_CERT']}">
                                            <a href="${pageContext.request.contextPath}/settings?action=viewBuyerDocument&docType=REG_CERT" target="_blank" class="px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-700 text-[#0D9488] dark:text-[#2DD4BF] hover:underline">View</a>
                                            <button type="button" onclick="deleteBuyerDoc('REG_CERT')" title="Delete uploaded Registration Certificate" class="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 border border-rose-500/25 transition-all">
                                                <i class="fas fa-trash-alt text-[11px]"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <form id="deleteBuyerDocForm" method="post" action="${pageContext.request.contextPath}/settings" class="hidden">
                            <input type="hidden" name="action" value="deleteBuyerDocument">
                            <input type="hidden" name="docType" id="deleteBuyerDocType">
                        </form>

                        <!-- Quick Security Summary Card -->
                        <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                            <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center gap-2">
                                <svg class="w-4 h-4 text-[#0D9488] dark:text-[#2DD4BF]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                                <h3 class="text-sm font-bold text-slate-900 dark:text-white">Quick Security Summary</h3>
                            </div>

                            <div class="p-4 space-y-3.5">
                                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] flex items-center justify-between gap-2">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Account Password</div>
                                        <div class="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">Update signed-in credentials</div>
                                    </div>
                                    <button type="button" onclick="openPasswordModal()" class="px-3 py-1.5 rounded-lg text-xs font-bold bg-[#0B1E47] dark:bg-slate-800 hover:opacity-90 text-white border border-slate-700 transition-all whitespace-nowrap">
                                        Change Password
                                    </button>
                                </div>

                                <div class="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] flex items-center justify-between gap-2">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Account Role</div>
                                        <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400 mt-0.5"><c:out value="${currentUser.username}"/></div>
                                    </div>
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">
                                        <c:out value="${currentUser.role}"/>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- TAB 2: AUCTION & AI RULES                               -->
            <!-- ======================================================= -->
            <section id="tabPanel-auction" class="tab-panel">
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-xl bg-amber-500/15 text-amber-600 dark:text-amber-400 flex items-center justify-center">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                            </div>
                            <div>
                                <h2 class="text-base font-bold text-slate-900 dark:text-white">Reverse Auction Engine Defaults</h2>
                                <p class="text-[11px] text-slate-500 dark:text-slate-400">Default rules applied automatically to newly launched auctions.</p>
                            </div>
                        </div>
                        <div class="p-5 space-y-5">
                            <div class="p-4 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] space-y-3">
                                <div class="flex items-start justify-between gap-3">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Anti-Sniping Auto-Extension</div>
                                        <p class="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">Automatically extends auction end time on last-minute L1 bids.</p>
                                    </div>
                                    <input type="checkbox" id="antiSnipingToggle" checked onchange="saveLocalPref('antiSniping', this.checked)" class="w-4 h-4 mt-0.5 rounded text-[#0D9488] focus:ring-[#0D9488] cursor-pointer">
                                </div>
                            </div>

                            <label class="flex items-center justify-between p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B] cursor-pointer">
                                <div>
                                    <div class="text-xs font-bold text-slate-900 dark:text-white">Auto-Draft Purchase Order on Award</div>
                                    <div class="text-[11px] text-slate-500 dark:text-slate-400">Automatically generates GST-calculated PO draft once L1 winner is confirmed.</div>
                                </div>
                                <input type="checkbox" id="autoDraftPoToggle" checked onchange="saveLocalPref('autoDraftPo', this.checked)" class="w-4 h-4 rounded text-[#0D9488] focus:ring-[#0D9488]">
                            </label>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center justify-between gap-2">
                            <div class="flex items-center gap-2.5">
                                <div class="w-8 h-8 rounded-xl bg-cyan-500/15 text-[#0D9488] dark:text-[#2DD4BF] flex items-center justify-center">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                </div>
                                <div>
                                    <h2 class="text-base font-bold text-slate-900 dark:text-white">1D-ResNet Trade Intel &amp; Kanban Automation</h2>
                                    <p class="text-[11px] text-slate-500 dark:text-slate-400">Predictive price hedging and autonomous inventory replenishment rules.</p>
                                </div>
                            </div>
                            <span class="px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-cyan-500/15 text-[#0D9488] dark:text-[#2DD4BF] border border-cyan-500/30">NEURAL V2</span>
                        </div>
                        <div class="p-5 space-y-5">
                            <div class="p-4 rounded-xl bg-gradient-to-br from-slate-50 to-teal-50/40 dark:from-slate-900 dark:to-teal-950/20 border border-slate-200 dark:border-slate-800 space-y-3">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <div class="text-xs font-bold text-slate-900 dark:text-white">Global Price Surge Alert Threshold</div>
                                        <div class="text-[11px] text-slate-500 dark:text-slate-400">Triggers hedging alert when 1D-ResNet forecasts 30-day spike.</div>
                                    </div>
                                    <span id="surgeThresholdReadout" class="px-3 py-1 rounded-xl text-sm font-mono font-extrabold tabular-nums bg-[#0B1E47] text-[#2DD4BF] shadow-sm">+5.0%</span>
                                </div>
                                <input type="range" id="surgeThresholdSlider" min="2.0" max="15.0" step="0.5" value="5.0" oninput="updateSurgeReadout(this.value)" class="w-full supple-slider cursor-pointer">
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ======================================================= -->
            <!-- TAB 3: SECURITY & PREFERENCES (No Notification Routing) -->
            <!-- ======================================================= -->
            <section id="tabPanel-security" class="tab-panel space-y-6">
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <!-- Appearance & Workspace -->
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40">
                            <h2 class="text-base font-bold text-slate-900 dark:text-white">Appearance &amp; Workspace Preferences</h2>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Customize theme and regional formatting.</p>
                        </div>
                        <div class="p-5 space-y-4">
                            <div class="flex items-center justify-between p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B]">
                                <div>
                                    <div class="text-xs font-bold text-slate-900 dark:text-white">Theme Mode</div>
                                    <div class="text-[11px] text-slate-500 dark:text-slate-400">Switch between Light Ice-Slate and Dark Enterprise Slate.</div>
                                </div>
                                <button type="button" onclick="toggleDarkMode()" class="px-3.5 py-1.5 rounded-lg text-xs font-bold bg-[#0B1E47] dark:bg-amber-400 text-white dark:text-slate-950 transition-all">
                                    Toggle Dark Mode
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Change Password Card (Real POST /settings action=changePassword) -->
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40">
                            <h2 class="text-base font-bold text-slate-900 dark:text-white">Account Security &amp; Password</h2>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Update the password for your signed-in account.</p>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/settings" class="p-5 space-y-3">
                            <input type="hidden" name="action" value="changePassword">
                            <input type="password" name="oldPassword" placeholder="Current Password" required class="w-full px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488] text-slate-900 dark:text-white">
                            <input type="password" name="newPassword" placeholder="New Password (min 6 chars)" required minlength="6" class="w-full px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488] text-slate-900 dark:text-white">
                            <input type="password" name="confirmPassword" placeholder="Confirm New Password" required minlength="6" class="w-full px-3.5 py-2 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:border-[#0D9488] text-slate-900 dark:text-white">
                            <button type="submit" class="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white text-xs font-bold shadow hover:opacity-95 transition">
                                <i class="fas fa-save mr-1"></i> Update Password
                            </button>
                        </form>
                    </div>
                </div>

                <%
                    String ua = request.getHeader("User-Agent");
                    if (ua == null) ua = "Unknown Browser";
                    String browserLabel = ua.contains("Edg") ? "Microsoft Edge" : (ua.contains("Chrome") ? "Google Chrome" : (ua.contains("Firefox") ? "Mozilla Firefox" : (ua.contains("Safari") ? "Safari" : "Web Browser")));
                    String osLabel = ua.contains("Windows") ? "Windows" : (ua.contains("Mac") ? "macOS" : (ua.contains("Linux") ? "Linux" : "Desktop / Mobile"));
                    String clientIp = request.getRemoteAddr();
                    String sessIdShort = session.getId() != null && session.getId().length() >= 8 ? session.getId().substring(0, 8) : session.getId();
                    String lastAccessedStr = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(session.getLastAccessedTime()));
                %>
                <!-- Active Login Sessions (Where Account Is Logged In) -->
                <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                    <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex items-center justify-between">
                        <div>
                            <h2 class="text-base font-bold text-slate-900 dark:text-white">Active Login Sessions</h2>
                            <p class="text-[11px] text-slate-500 dark:text-slate-400">Devices and locations currently authenticated to this buyer account.</p>
                        </div>
                        <span class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">1 Active Session</span>
                    </div>
                    <div class="p-4 space-y-2.5">
                        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-[#1E293B]">
                            <div class="flex items-center gap-3">
                                <div class="w-9 h-9 rounded-xl bg-emerald-500/12 text-emerald-600 dark:text-emerald-400 flex items-center justify-center shrink-0">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <div class="text-xs font-bold text-slate-900 dark:text-white"><%= browserLabel %> on <%= osLabel %> — Current Session</div>
                                    <div class="text-[11px] font-mono text-slate-500 dark:text-slate-400">IP: <%= clientIp %> • Session: <%= sessIdShort %>... • Last Active: <%= lastAccessedStr %></div>
                                </div>
                            </div>
                            <span class="self-start sm:self-center px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">THIS DEVICE</span>
                        </div>
                    </div>
                </div>

                <c:if test="${isAdmin}">
                    <div class="bg-white dark:bg-[#111827] rounded-2xl border border-[#E2E8F0] dark:border-[#1E293B] shadow-card overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 dark:border-[#1E293B] bg-slate-50/70 dark:bg-slate-900/40 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                            <div>
                                <h2 class="text-base font-bold text-slate-900 dark:text-white">Workspace User Directory (Admin)</h2>
                                <p class="text-[11px] text-slate-500 dark:text-slate-400">Manage system user accounts and roles.</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/settings?action=newUser" class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white shadow-sm hover:opacity-95">
                                <i class="fas fa-plus-circle"></i> Add New User
                            </a>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left border-collapse text-xs">
                                <thead>
                                    <tr class="bg-slate-50/90 dark:bg-slate-900/80 border-b border-[#E2E8F0] dark:border-[#1E293B] text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                                        <th class="py-3 px-4">ID</th>
                                        <th class="py-3 px-4">Username</th>
                                        <th class="py-3 px-4">Email</th>
                                        <th class="py-3 px-4">Role</th>
                                        <th class="py-3 px-4">Status</th>
                                        <th class="py-3 px-4 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 dark:divide-[#1E293B]">
                                    <c:forEach items="${users}" var="u">
                                        <tr class="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                                            <td class="py-3 px-4 font-mono">#<c:out value="${u.id}"/></td>
                                            <td class="py-3 px-4 font-bold text-slate-900 dark:text-white"><c:out value="${u.username}"/></td>
                                            <td class="py-3 px-4 font-mono text-slate-600 dark:text-slate-300"><c:out value="${u.email}"/></td>
                                            <td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-blue-500/10 text-blue-700 dark:text-blue-300"><c:out value="${u.role}"/></span></td>
                                            <td class="py-3 px-4"><span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300"><c:out value="${u.status}"/></span></td>
                                            <td class="py-3 px-4 text-right whitespace-nowrap">
                                                <a href="${pageContext.request.contextPath}/settings?action=editUser&id=${u.id}" class="px-2.5 py-1 rounded-lg text-[11px] font-semibold bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-700 dark:text-slate-200 mr-1">Edit</a>
                                                <c:if test="${u.id != currentUser.id}">
                                                    <form method="post" action="${pageContext.request.contextPath}/settings" class="inline" onsubmit="return confirm('Delete user ${u.username}?');">
                                                        <input type="hidden" name="action" value="deleteUser">
                                                        <input type="hidden" name="id" value="${u.id}">
                                                        <button type="submit" class="px-2.5 py-1 rounded-lg text-[11px] font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40">Delete</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:if>
            </section>

            <!-- Footer -->
            <footer class="pt-3 pb-6 text-center sm:flex sm:items-center sm:justify-between text-xs text-slate-400 dark:text-slate-500 border-t border-slate-200/70 dark:border-[#1E293B]">
                <p>© 2026 Supplexio Procurement Systems Inc. All rights reserved.</p>
                <p class="font-mono text-[11px] mt-1 sm:mt-0">Buyer Enterprise Settings • Workspace Configuration</p>
            </footer>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 1: PREVIEW BUYER CARD MODAL                                   -->
    <!-- =================================================================== -->
    <div id="buyerPreviewModal" class="fixed inset-0 z-50 bg-slate-950/65 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-[#1E293B] rounded-2xl max-w-2xl w-full shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
            <div class="bg-gradient-to-r from-[#0B1E47] via-[#12336B] to-[#0F3D4C] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-cyan-200">Public Supplier View</span>
                    <h3 class="text-base font-extrabold tracking-tight">How Suppliers See Your Buyer Profile</h3>
                </div>
                <button type="button" onclick="closeBuyerPreviewModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">✕</button>
            </div>
            <div id="buyerPreviewBody" class="p-6 overflow-y-auto space-y-5"></div>
            <div class="px-5 py-3.5 bg-slate-50 dark:bg-slate-900 border-t border-slate-200 dark:border-[#1E293B] flex items-center justify-between">
                <span class="text-[11px] text-slate-500 dark:text-slate-400">Displayed to verified suppliers on all live reverse auctions.</span>
                <button type="button" onclick="closeBuyerPreviewModal()" class="px-4 py-2 rounded-xl text-xs font-bold bg-[#0B1E47] dark:bg-[#0D9488] text-white">Close Preview</button>
            </div>
        </div>
    </div>

    <!-- =================================================================== -->
    <!-- MODAL 2: CHANGE PASSWORD MODAL                                      -->
    <!-- =================================================================== -->
    <div id="passwordModal" class="fixed inset-0 z-50 bg-slate-950/65 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-[#111827] border border-slate-200 dark:border-[#1E293B] rounded-2xl max-w-md w-full shadow-2xl overflow-hidden">
            <div class="bg-gradient-to-r from-[#0B1E47] to-[#12336B] text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <span class="text-[10px] font-mono uppercase tracking-wider text-cyan-200">Security Credentials</span>
                    <h3 class="text-base font-extrabold">Change Account Password</h3>
                </div>
                <button type="button" onclick="closePasswordModal()" class="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white">✕</button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/settings" class="p-5 space-y-4">
                <input type="hidden" name="action" value="changePassword">
                <div>
                    <label class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Current Password <span class="text-rose-500">*</span></label>
                    <input type="password" name="oldPassword" required placeholder="Enter current password" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">New Password <span class="text-rose-500">*</span></label>
                    <input type="password" name="newPassword" required minlength="6" placeholder="At least 6 characters" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">Confirm Password <span class="text-rose-500">*</span></label>
                    <input type="password" name="confirmPassword" required minlength="6" placeholder="Re-enter new password" class="w-full px-3.5 py-2.5 text-xs bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0D9488]/30 text-slate-900 dark:text-white">
                </div>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" onclick="closePasswordModal()" class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">Cancel</button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-gradient-to-r from-[#1E3A8A] to-[#0D9488] text-white shadow">Update Password</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        var GSTIN_REGEX = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
        var uploadedBuyerDocs = {
            PAN: '<c:out value="${buyerDocs[\'PAN\']}"/>',
            AADHAR: '<c:out value="${buyerDocs[\'AADHAR\']}"/>',
            REG_CERT: '<c:out value="${buyerDocs[\'REG_CERT\']}"/>'
        };

        function escapeHtml(str) {
            return String(str || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function deleteBuyerDoc(docType) {
            document.getElementById('deleteBuyerDocType').value = docType;
            document.getElementById('deleteBuyerDocForm').submit();
        }

        function switchWorkspaceTab(tabKey) {
            ['org', 'auction', 'security'].forEach(function(k) {
                var panel = document.getElementById('tabPanel-' + k);
                var btn = document.getElementById('tabBtn-' + k);
                if (!panel || !btn) return;
                if (k === tabKey) {
                    panel.classList.add('active');
                    btn.className = 'workspace-tab-btn w-full justify-center px-4 py-2.5 rounded-xl text-xs font-bold transition-all flex items-center gap-2 bg-[#0B1E47] dark:bg-[#0D9488] text-white shadow-sm';
                } else {
                    panel.classList.remove('active');
                    btn.className = 'workspace-tab-btn w-full justify-center px-4 py-2.5 rounded-xl text-xs font-semibold transition-all flex items-center gap-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800';
                }
            });
        }

        function validateGstinLive() {
            var input = document.getElementById('gstinInput');
            var badge = document.getElementById('gstinStatusBadge');
            var val = input.value.trim().toUpperCase();
            if (!val) {
                badge.textContent = 'Optional';
                badge.className = 'px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-slate-100 dark:bg-slate-800 text-slate-500';
                return false;
            }
            if (GSTIN_REGEX.test(val)) {
                badge.textContent = 'Valid GSTIN';
                badge.className = 'px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30';
                return true;
            }
            badge.textContent = 'Check Format';
            badge.className = 'px-2 py-0.5 rounded-full text-[9.5px] font-mono font-bold bg-amber-500/15 text-amber-700 dark:text-amber-300 border border-amber-500/30';
            return false;
        }

        function onFieldModified() {
            document.getElementById('unsavedIndicator').classList.remove('hidden');
            var company = document.getElementById('companyNameInput').value.trim();
            var role = document.getElementById('designationInput').value.trim();
            var addr = document.getElementById('plantAddressInput').value.trim();
            if (company) document.getElementById('heroCompanyTitle').textContent = company;
            if (role) document.getElementById('heroRoleText').textContent = role;
            if (addr) document.getElementById('heroLocationText').textContent = addr;
            updateReadinessRing();
        }

        function updateReadinessRing() {
            var docsCount = [uploadedBuyerDocs.PAN, uploadedBuyerDocs.AADHAR, uploadedBuyerDocs.REG_CERT].filter(function(v) { return v && v.length > 0; }).length;
            var score = 70 + (docsCount * 10);
            if (score > 100) score = 100;
            var circumference = 163.36;
            var offset = circumference - (score / 100) * circumference;
            var ring = document.getElementById('readinessRingCircle');
            if (ring) {
                ring.style.strokeDashoffset = offset.toFixed(2);
                ring.style.stroke = score === 100 ? '#10B981' : '#2DD4BF';
            }
            document.getElementById('readinessPercentText').textContent = score + '%';
            document.getElementById('readinessDocsSummary').textContent = docsCount + ' / 3 Documents Uploaded';
            document.getElementById('readinessStatusLabel').textContent = score === 100 ? '100% Enterprise Ready' : 'Profile Active';
        }

        function openBuyerPreviewModal() {
            var company = document.getElementById('companyNameInput').value.trim();
            var email = document.getElementById('workEmailInput').value.trim();
            var phone = document.getElementById('workPhoneInput').value.trim();
            var address = document.getElementById('plantAddressInput').value.trim();
            var brief = document.getElementById('buyerBriefTextarea').value.trim();
            var initials = company.split(' ').map(function(w) { return w[0]; }).filter(Boolean).slice(0, 2).join('').toUpperCase() || 'BY';

            var docItems = [
                { label: 'Company PAN Card', file: uploadedBuyerDocs.PAN },
                { label: 'Aadhar Card of the Owner', file: uploadedBuyerDocs.AADHAR },
                { label: 'Business Registration Certificate', file: uploadedBuyerDocs.REG_CERT }
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
                        '<span class="inline-block mt-1 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/15 text-emerald-700 dark:text-emerald-300 border border-emerald-500/30">Enterprise Buyer</span>' +
                    '</div>' +
                '</div>' +
                '<div class="p-4 rounded-xl bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-[#1E293B] space-y-2 text-xs">' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Work Email</span><span class="font-mono text-slate-800 dark:text-slate-100">' + escapeHtml(email) + '</span></div>' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Phone</span><span class="font-mono text-slate-800 dark:text-slate-100">' + escapeHtml(phone || 'Not provided') + '</span></div>' +
                    '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Address</span><span class="text-slate-700 dark:text-slate-200">' + escapeHtml(address || 'Not provided') + '</span></div>' +
                    (brief ? '<div><span class="font-semibold text-slate-400 uppercase text-[10px] block">Buyer Brief</span><span class="text-slate-700 dark:text-slate-200">' + escapeHtml(brief) + '</span></div>' : '') +
                '</div>' +
                '<div class="p-4 rounded-xl ' + (allProvided ? 'bg-emerald-50/70 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-800/50' : 'bg-slate-50 dark:bg-slate-900 border-slate-200 dark:border-[#1E293B]') + ' border space-y-2 text-xs">' +
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

        function toggleDarkMode() {
            var isDark = !document.documentElement.classList.contains('dark');
            document.documentElement.classList.toggle('dark', isDark);
            document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
            localStorage.setItem('sp-theme', isDark ? 'dark' : 'light');
            var lbl = document.getElementById('topDarkModeLabel');
            if (lbl) lbl.textContent = isDark ? 'Light Mode' : 'Dark Mode';
        }

        function updateSurgeReadout(val) {
            document.getElementById('surgeThresholdReadout').textContent = '+' + Number(val).toFixed(1) + '%';
            localStorage.setItem('sp-buyer-surge-threshold', val);
        }

        function saveLocalPref(key, val) {
            localStorage.setItem('sp-buyer-pref-' + key, String(val));
        }

        function exportConfigJson() {
            var cfg = {
                companyName: document.getElementById('companyNameInput').value.trim(),
                email: document.getElementById('workEmailInput').value.trim(),
                designation: document.getElementById('designationInput').value.trim(),
                gstin: document.getElementById('gstinInput').value.trim(),
                documents: uploadedBuyerDocs
            };
            var blob = new Blob([JSON.stringify(cfg, null, 2)], { type: 'application/json' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'supplexio_buyer_workspace_config.json';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        document.addEventListener('DOMContentLoaded', function() {
            validateGstinLive();
            updateReadinessRing();
            var isDark = document.documentElement.classList.contains('dark');
            var lbl = document.getElementById('topDarkModeLabel');
            if (lbl) lbl.textContent = isDark ? 'Light Mode' : 'Dark Mode';
        });
    </script>
</body>
</html>
