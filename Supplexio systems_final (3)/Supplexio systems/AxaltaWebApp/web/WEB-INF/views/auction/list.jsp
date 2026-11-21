<%@page contentType="text/html" pageEncoding="UTF-8" %>
  <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
      <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <!DOCTYPE html>
        <html lang="en" class="h-full bg-slate-50">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Supplexio — Reverse Auction Management</title>
          <!-- Tailwind CSS -->
          <script src="https://cdn.tailwindcss.com"></script>
          <!-- Google Fonts: Inter & JetBrains Mono -->
          <link rel="preconnect" href="https://fonts.googleapis.com">
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
          <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap"
            rel="stylesheet">
          <!-- jQuery -->
          <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
          <!-- Chart.js for 1D-ResNet Timing Trajectory Sparklines -->
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
                    navy: {
                      800: '#1E293B',
                      900: '#0F172A',
                      950: '#080D1A',
                    },
                    amber: {
                      400: '#FBBF24',
                      500: '#F59E0B',
                      600: '#D97706',
                    },
                    emerald: {
                      500: '#10B981',
                      600: '#059669',
                    }
                  }
                }
              }
            }
          </script>
          <style>
            /* Custom scrollbars and tabular numbers */
            .font-mono-tabular {
              font-family: 'JetBrains Mono', monospace;
              font-variant-numeric: tabular-nums;
            }

            ::-webkit-scrollbar {
              width: 6px;
              height: 6px;
            }

            ::-webkit-scrollbar-track {
              background: rgba(0, 0, 0, 0.03);
            }

            ::-webkit-scrollbar-thumb {
              background: rgba(148, 163, 184, 0.4);
              border-radius: 9999px;
            }

            ::-webkit-scrollbar-thumb:hover {
              background: rgba(100, 116, 139, 0.6);
            }

            @keyframes pulse-emerald {

              0%,
              100% {
                opacity: 1;
                transform: scale(1);
              }

              50% {
                opacity: 0.4;
                transform: scale(1.2);
              }
            }

            .animate-pulse-emerald {
              animation: pulse-emerald 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
            }

            /* Modal Backdrop Blur */
            .glass-backdrop {
              background: rgba(15, 23, 42, 0.45);
              backdrop-filter: blur(4px);
            }
          </style>
          <!-- Lucide Icons -->
          <script src="https://unpkg.com/lucide@latest"></script>
        </head>

        <body
          class="h-full flex overflow-hidden font-sans text-slate-800 antialiased selection:bg-brand-cyan selection:text-brand-navy">

          <!-- WRAPPER: Full Height Desktop Canvas -->
          <div class="flex h-full w-full overflow-hidden">

            <!-- ASIDE: Left Modern Navigation Sidebar -->
            <aside
              class="w-64 bg-gradient-to-b from-[#172E6E] via-[#1E3E96] to-[#1B3680] text-white flex flex-col flex-shrink-0 shadow-xl border-r border-blue-900/40 relative z-20">
              <!-- Brand Badge Header -->
              <div class="p-4 border-b border-white/10">
                <a href="${pageContext.request.contextPath}/home?action=workspace"
                  class="bg-[#0B1E3D] rounded-xl p-3 border border-white/10 shadow-lg flex flex-col items-center text-center block no-underline">
                  <div class="flex items-center gap-1">
                    <span class="text-2xl font-black tracking-tight text-white">Supple</span>
                    <span class="text-2xl font-black tracking-tight text-[#2DD4BF]">xio</span>
                  </div>
                  <span class="text-[9px] font-bold tracking-widest text-slate-300 uppercase mt-0.5">BID BOLD • SOURCE
                    SMART</span>
                </a>
              </div>

              <!-- Top CTA Button: Launch Dashboard -->
              <div class="p-4 pb-2">
                <a href="${pageContext.request.contextPath}/home"
                  class="w-full bg-[#F59E0B] hover:bg-[#D97706] text-slate-950 font-bold py-2.5 px-4 rounded-lg shadow-md flex items-center justify-center gap-2 transition-all duration-150 transform active:scale-95 text-sm no-underline">
                  <i data-lucide="rocket" class="w-4 h-4 fill-slate-950 text-slate-950"></i>
                  <span>Launch Dashboard</span>
                </a>
              </div>

              <!-- Navigation Links -->
              <nav class="flex-1 px-3 py-2 space-y-1 overflow-y-auto text-sm font-medium">
                <a href="${pageContext.request.contextPath}/home?action=workspace"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="layout-dashboard" class="w-4 h-4 text-slate-300"></i>
                  <span>Dashboard</span>
                </a>
                <a href="${pageContext.request.contextPath}/product"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="package" class="w-4 h-4 text-slate-300"></i>
                  <span>Products</span>
                </a>
                <a href="${pageContext.request.contextPath}/auction"
                  class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline bg-white/15 text-white font-semibold shadow-inner border border-white/20 backdrop-blur-sm">
                  <div class="flex items-center gap-3">
                    <i data-lucide="gavel" class="w-4 h-4 text-[#2DD4BF]"></i>
                    <span>Reverse Auctions</span>
                  </div>
                  <span
                    class="bg-amber-500/30 text-amber-300 text-[10px] font-bold px-2 py-0.5 rounded-full border border-amber-400/40">LIVE</span>
                </a>
                <a href="${pageContext.request.contextPath}/supplier"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="users" class="w-4 h-4 text-slate-300"></i>
                  <span>Suppliers</span>
                </a>
                <a href="${pageContext.request.contextPath}/payment"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="credit-card" class="w-4 h-4 text-slate-300"></i>
                  <span>Payments</span>
                </a>
                <a href="${pageContext.request.contextPath}/todo"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="check-square" class="w-4 h-4 text-slate-300"></i>
                  <span>To-Do List</span>
                </a>
                <a href="${pageContext.request.contextPath}/inventory"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="boxes" class="w-4 h-4 text-slate-300"></i>
                  <span>Inventory Management</span>
                </a>
                <a href="http://localhost:8501" target="_blank"
                  class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <div class="flex items-center gap-3">
                    <i data-lucide="globe-2" class="w-4 h-4 text-[#2DD4BF]"></i>
                    <span>Global Trade Intel</span>
                  </div>
                  <span class="w-2 h-2 rounded-full bg-[#2DD4BF] animate-pulse"></span>
                </a>
                <a href="${pageContext.request.contextPath}/user-po-view"
                  class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <div class="flex items-center gap-3">
                    <i data-lucide="file-text" class="w-4 h-4 text-slate-300"></i>
                    <span>Purchase Orders</span>
                  </div>
                  <span class="bg-[#2DD4BF] text-slate-950 text-[10px] font-extrabold px-2 py-0.5 rounded-full"
                    id="po-total-badge">54</span>
                </a>
                <a href="${pageContext.request.contextPath}/settings"
                  class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                  <i data-lucide="settings" class="w-4 h-4 text-slate-300"></i>
                  <span>Settings</span>
                </a>
              </nav>

              <!-- Sidebar User Profile Footer (Clickable to Edit Profile & Password) -->
              <div class="p-3 border-t border-white/10 bg-black/20">
                <div onclick="openUserProfileModal()"
                  class="flex items-center gap-3 p-2.5 rounded-xl bg-white/5 hover:bg-white/15 border border-white/10 hover:border-white/20 transition-all duration-150 cursor-pointer group"
                  title="Click to update username or change password">
                  <div
                    class="w-9 h-9 rounded-full bg-[#2DD4BF] text-slate-950 font-black flex items-center justify-center text-xs shadow-md tracking-wider flex-shrink-0 group-hover:scale-105 transition-transform"
                    id="sidebar-user-avatar">
                    <%= (session.getAttribute("username") !=null && ((String)session.getAttribute("username")).length()>
                      0) ? ((String)session.getAttribute("username")).substring(0, Math.min(2,
                      ((String)session.getAttribute("username")).length())).toUpperCase() : "AD" %>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-bold text-white tracking-wide truncate group-hover:text-[#2DD4BF] transition-colors"
                      id="sidebar-username-display">
                      <%= session.getAttribute("username") !=null ? session.getAttribute("username") : "admin" %>
                    </p>
                  </div>
                  <div class="text-slate-400 group-hover:text-white transition-colors">
                    <i data-lucide="settings" class="w-4 h-4 text-[#2DD4BF]"></i>
                  </div>
                </div>
              </div>
            </aside>

            <!-- MAIN VIEWPORT CONTAINER -->
            <main class="flex-1 flex flex-col min-w-0 overflow-y-auto bg-slate-50 overflow-y-auto">

              <!-- TOP STICKY APPLICATION BAR -->
              <header
                class="bg-white border-b border-slate-200 px-6 py-4 flex flex-col md:flex-row md:items-center justify-between gap-4 sticky top-0 z-20 shadow-xs">
                <div>
                  <div class="flex items-center space-x-2.5">
                    <h2 class="text-xl font-extrabold text-slate-900 tracking-tight">Reverse Auction Management</h2>
                    <span
                      class="px-2 py-0.5 rounded-full text-[11px] font-bold bg-amber-100 text-amber-800 border border-amber-200">
                      Enterprise Live Floor
                    </span>
                  </div>
                  <p class="text-xs text-slate-500 mt-1">Live reverse bidding floor, supplier contract awards, and
                    autonomous savings analytics</p>
                </div>

                <div class="flex items-center space-x-3">
                  <!-- Export Button -->
                  <button onclick="exportCSV()"
                    class="px-3.5 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50 font-medium text-sm transition-colors flex items-center space-x-2 shadow-xs">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    <span>Export Data</span>
                  </button>

                  <!-- Create New Auction Button: Opens High-Tech Timing Oracle Modal -->
                  <button type="button" onclick="openCreateAuctionModal()"
                    class="px-4 py-2 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-navy-950 font-bold rounded-lg shadow-md hover:shadow-amber-500/20 text-sm transition-all duration-150 flex items-center space-x-2">
                    <svg class="w-4 h-4 text-navy-950" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4" />
                    </svg>
                    <span>+ Create New Auction</span>
                  </button>
                </div>
              </header>

              <!-- CONTENT BODY CONTAINER -->
              <div class="p-6 space-y-6 flex-1 max-w-7xl mx-auto w-full">

                <!-- EXECUTIVE KPI SUMMARY STRIP (4 Cards) -->
                <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4" id="kpiStrip">
                  <!-- Card 1: Total Auctions -->
                  <div
                    class="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div class="absolute top-0 left-0 right-0 h-1 bg-slate-400"></div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Auctions</span>
                      <div class="w-9 h-9 rounded-lg bg-slate-100 flex items-center justify-center text-slate-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                      </div>
                    </div>
                    <div class="mt-3 flex items-baseline space-x-2">
                      <span id="kpiTotalAuctions" class="text-3xl font-bold font-mono-tabular text-slate-900">0</span>
                      <span class="text-xs font-medium text-slate-500">Auctions</span>
                    </div>
                    <p class="text-xs text-slate-400 mt-2 flex items-center">
                      <span class="text-emerald-600 font-semibold mr-1">↑ 100%</span> logged on Supplexio
                    </p>
                  </div>

                  <!-- Card 2: Live Active Auctions -->
                  <div
                    class="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div class="absolute top-0 left-0 right-0 h-1 bg-emerald-500"></div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Live Active</span>
                      <div class="w-9 h-9 rounded-lg bg-emerald-50 flex items-center justify-center text-emerald-600">
                        <span class="w-3 h-3 rounded-full bg-emerald-500 animate-pulse-emerald"></span>
                      </div>
                    </div>
                    <div class="mt-3 flex items-baseline space-x-2">
                      <span id="kpiLiveAuctions" class="text-3xl font-bold font-mono-tabular text-emerald-600">0</span>
                      <span class="text-xs font-medium text-slate-500">Bidding Now</span>
                    </div>
                    <p class="text-xs text-slate-500 mt-2 flex items-center">
                      <span class="w-2 h-2 rounded-full bg-emerald-500 inline-block mr-1.5"></span> Real-time supplier
                      ticker
                    </p>
                  </div>

                  <!-- Card 3: Awaiting PO Award -->
                  <div
                    class="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div class="absolute top-0 left-0 right-0 h-1 bg-amber-500"></div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Awaiting PO
                        Award</span>
                      <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                      </div>
                    </div>
                    <div class="mt-3 flex items-baseline space-x-2">
                      <span id="kpiAwardPending" class="text-3xl font-bold font-mono-tabular text-amber-600">0</span>
                      <span class="text-xs font-medium text-slate-500">Actions Pending</span>
                    </div>
                    <p class="text-xs text-slate-400 mt-2">Requires buyer decision</p>
                  </div>

                  <!-- Card 4: Realized Cost Savings -->
                  <div
                    class="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-md transition-shadow relative overflow-hidden group">
                    <div class="absolute top-0 left-0 right-0 h-1 bg-indigo-600"></div>
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Realized
                        Savings</span>
                      <div class="w-9 h-9 rounded-lg bg-indigo-50 flex items-center justify-center text-indigo-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                      </div>
                    </div>
                    <div class="mt-3 flex items-baseline space-x-2">
                      <span id="kpiRealizedSavings"
                        class="text-2xl font-bold font-mono-tabular text-slate-900">₹0.00</span>
                    </div>
                    <p class="text-xs text-slate-500 mt-2 flex items-center justify-between">
                      <span>Avg reduction:</span>
                      <span id="kpiAvgSavingsPct"
                        class="px-1.5 py-0.5 bg-emerald-100 text-emerald-700 rounded font-mono-tabular font-bold text-[11px]">-0.0%</span>
                    </p>
                  </div>
                </section>

                <!-- FILTER & TOOLBAR CARD -->
                <section
                  class="bg-white rounded-xl border border-slate-200 p-4 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <!-- Search & Filter Controls -->
                  <div class="flex flex-wrap items-center gap-3 flex-1">
                    <!-- Search Input -->
                    <div class="relative min-w-[220px] flex-1 sm:flex-initial">
                      <svg class="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" fill="none"
                        stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                      </svg>
                      <input type="text" id="searchInput" oninput="handleSearch()"
                        placeholder="Search auctions by ID, product, winner..."
                        class="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-300 rounded-lg text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 transition-all placeholder:text-slate-400">
                    </div>

                    <!-- Status Dropdown Filter: Exactly matching existing status options -->
                    <select id="statusFilter" onchange="applyFilters()"
                      class="bg-slate-50 border border-slate-300 text-slate-700 text-sm rounded-lg focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 p-2 font-medium">
                      <option value="ALL">All Statuses</option>
                      <option value="ACTIVE">Active</option>
                      <option value="COMPLETED">Completed — award PO</option>
                      <option value="AWARDED">Awarded</option>
                      <option value="PO_DRAFT">PO Draft</option>
                      <option value="PO_SENT">PO Sent</option>
                      <option value="PO_ACCEPTED">PO Accepted</option>
                      <option value="SHIPPED">Shipped</option>
                      <option value="DELIVERED">Delivered</option>
                      <option value="INVOICING_PENDING">Invoicing</option>
                      <option value="PAYMENT_PENDING">Payment Pending</option>
                      <option value="PAYMENT_SUCCESSFUL">Payment Successful</option>
                      <option value="CLOSED">Closed</option>
                      <option value="CANCELLED">Cancelled</option>
                    </select>

                    <!-- Product Categories Dropdown Filter: Displaying all product categories -->
                    <select id="productFilter" onchange="applyFilters()"
                      class="bg-slate-50 border border-slate-300 text-slate-700 text-sm rounded-lg focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 p-2 font-medium max-w-xs truncate">
                      <option value="ALL">All Product Categories</option>
                      <c:forEach var="cat" items="${categories}">
                        <option value="${cat}">${cat}</option>
                      </c:forEach>
                    </select>

                    <!-- Clear Filters Button -->
                    <button onclick="resetFilters()"
                      class="px-3 py-2 text-xs font-semibold text-slate-500 hover:text-slate-800 border border-slate-200 rounded-lg hover:bg-slate-100 transition-colors">
                      Reset Filters
                    </button>
                  </div>

                  <!-- Filter Metrics Badge -->
                  <div class="text-xs text-slate-500 font-medium shrink-0 flex items-center space-x-2">
                    <span>Active View:</span>
                    <span id="filteredCountBadge"
                      class="bg-navy-900 text-amber-400 font-mono-tabular font-bold px-2.5 py-1 rounded-full text-xs">
                      0 Auctions
                    </span>
                  </div>
                </section>

                <!-- HIGH-DENSITY REVERSE AUCTIONS DATA TABLE -->
                <section class="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
                  <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-600">
                      <thead
                        class="bg-slate-50/80 text-xs text-slate-500 uppercase tracking-wider border-b border-slate-200 font-semibold select-none">
                        <tr>
                          <th scope="col" class="py-3.5 px-4 cursor-pointer hover:bg-slate-100 transition-colors"
                            onclick="sortTable('id')">
                            <div class="flex items-center space-x-1">
                              <span>ID</span>
                              <span id="sortIcon_id" class="text-slate-400">↕</span>
                            </div>
                          </th>
                          <th scope="col" class="py-3.5 px-4 cursor-pointer hover:bg-slate-100 transition-colors"
                            onclick="sortTable('product')">
                            <div class="flex items-center space-x-1">
                              <span>Product & Quantity</span>
                              <span id="sortIcon_product" class="text-slate-400">↕</span>
                            </div>
                          </th>
                          <th scope="col"
                            class="py-3.5 px-4 cursor-pointer hover:bg-slate-100 transition-colors text-right"
                            onclick="sortTable('startPrice')">
                            <div class="flex items-center justify-end space-x-1">
                              <span>Start Price (₹)</span>
                              <span id="sortIcon_startPrice" class="text-slate-400">↕</span>
                            </div>
                          </th>
                          <th scope="col"
                            class="py-3.5 px-4 cursor-pointer hover:bg-slate-100 transition-colors text-right"
                            onclick="sortTable('currentBid')">
                            <div class="flex items-center justify-end space-x-1">
                              <span>Current Best (₹)</span>
                              <span id="sortIcon_currentBid" class="text-slate-400">↕</span>
                            </div>
                          </th>
                          <th scope="col" class="py-3.5 px-4">
                            <span>Schedule / Live Countdown</span>
                          </th>
                          <th scope="col" class="py-3.5 px-4">
                            <span>Status & Winner</span>
                          </th>
                          <th scope="col" class="py-3.5 px-4 text-center">
                            <span>Actions</span>
                          </th>
                        </tr>
                      </thead>
                      <tbody id="auctionTableBody" class="divide-y divide-slate-100">
                        <!-- Rendered via JavaScript -->
                      </tbody>
                    </table>
                  </div>

                  <!-- TABLE FOOTER & PAGINATION -->
                  <div
                    class="px-6 py-4 border-t border-slate-200 bg-slate-50/50 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
                    <div class="flex items-center space-x-3">
                      <span>Rows per page:</span>
                      <select id="pageSizeSelect" onchange="changePageSize(this.value)"
                        class="bg-white border border-slate-300 rounded px-2 py-1 text-xs font-semibold focus:outline-none focus:ring-1 focus:ring-amber-500">
                        <option value="10">10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                      </select>
                      <span id="paginationInfo" class="font-mono-tabular">Showing 0 to 0 of 0 entries</span>
                    </div>

                    <div class="flex items-center space-x-1" id="paginationButtons">
                      <!-- Buttons rendered via JS -->
                    </div>
                  </div>
                </section>

              </div>
            </main>

            <!-- SLIDE-OVER BID ROOM DRAWER -->
            <div id="drawerBackdrop" onclick="closeDrawer()"
              class="fixed inset-0 glass-backdrop z-50 hidden opacity-0 transition-opacity duration-300"></div>
            <aside id="bidRoomDrawer"
              class="fixed inset-y-0 right-0 z-50 w-full max-w-xl bg-white shadow-2xl transform translate-x-full transition-transform duration-300 ease-in-out flex flex-col">
              <!-- Drawer Header -->
              <div class="p-6 bg-navy-900 text-white border-b border-slate-800 flex items-center justify-between">
                <div>
                  <div class="flex items-center space-x-2">
                    <span id="drawerAuctionId"
                      class="text-xs font-mono-tabular px-2 py-0.5 rounded bg-slate-800 text-amber-400 font-bold">#--</span>
                    <span id="drawerStatusBadge" class="px-2 py-0.5 rounded text-xs font-semibold">Status</span>
                  </div>
                  <h2 id="drawerProductName" class="text-xl font-bold mt-1 text-white">Product Name</h2>
                  <p id="drawerQuantity" class="text-xs text-slate-400 mt-0.5">Quantity Details</p>
                </div>
                <button onclick="closeDrawer()"
                  class="p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition-colors">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <!-- Drawer Body Content -->
              <div class="flex-1 overflow-y-auto p-6 space-y-6">

                <!-- Countdown Bar if Live -->
                <div id="drawerTimerBox"
                  class="hidden bg-emerald-50 border border-emerald-200 rounded-xl p-4 flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <span class="w-3 h-3 rounded-full bg-emerald-500 animate-pulse-emerald"></span>
                    <div>
                      <p class="text-xs font-bold text-emerald-800 uppercase tracking-wider">Live Reverse Bidding</p>
                      <p class="text-xs text-emerald-600">Suppliers competing in real-time</p>
                    </div>
                  </div>
                  <div id="drawerCountdown"
                    class="text-lg font-bold font-mono-tabular text-emerald-700 bg-white px-3 py-1 rounded border border-emerald-200 shadow-xs">
                    00:00:00
                  </div>
                </div>

                <!-- 3 Price Mini Cards -->
                <div class="grid grid-cols-3 gap-3">
                  <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center">
                    <span class="text-[10px] uppercase font-semibold text-slate-400 block">Ceiling / Start</span>
                    <span id="drawerStartPrice"
                      class="text-sm font-bold font-mono-tabular text-slate-700 mt-1 block">₹0.00</span>
                  </div>
                  <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center">
                    <span class="text-[10px] uppercase font-semibold text-slate-400 block">Current Best</span>
                    <span id="drawerCurrentBid"
                      class="text-sm font-bold font-mono-tabular text-emerald-600 mt-1 block">₹0.00</span>
                  </div>
                  <div class="bg-slate-50 p-3 rounded-xl border border-slate-200 text-center">
                    <span class="text-[10px] uppercase font-semibold text-slate-400 block">Total Savings</span>
                    <span id="drawerSavings"
                      class="text-sm font-bold font-mono-tabular text-indigo-600 mt-1 block">₹0.00</span>
                  </div>
                </div>

                <!-- Interactive Actions Bar -->
                <div class="bg-slate-50 border border-slate-200 rounded-xl p-4 space-y-3">
                  <h4 class="text-xs font-bold uppercase tracking-wider text-slate-500">Bid Room Operator Controls</h4>
                  <div class="flex flex-wrap gap-2" id="drawerActionButtons">
                    <!-- Rendered dynamically depending on auction status -->
                  </div>
                </div>

                <!-- Chronological Supplier Bid History -->
                <div>
                  <h3 class="text-sm font-bold text-slate-900 mb-3 flex items-center justify-between">
                    <span>Supplier Bid Audit History</span>
                    <span id="bidCountBadge" class="text-xs font-normal text-slate-500 font-mono-tabular">0 bids
                      logged</span>
                  </h3>

                  <div
                    class="border border-slate-200 rounded-xl divide-y divide-slate-100 bg-white overflow-hidden shadow-xs">
                    <div
                      class="bg-slate-50 px-4 py-2 text-[11px] font-semibold text-slate-400 uppercase flex justify-between">
                      <span>Supplier</span>
                      <span>Bid Amount & Delta</span>
                    </div>
                    <div id="drawerBidTimeline" class="max-h-64 overflow-y-auto divide-y divide-slate-100">
                      <!-- Timeline items rendered via JS -->
                    </div>
                  </div>
                </div>

              </div>
            </aside>

            <!-- FLOATING SUPPLEXIO AI ASSISTANT WIDGET -->
            <div class="fixed bottom-6 right-6 z-40">
              <div id="aiPopover"
                class="hidden mb-3 w-80 bg-navy-900 border border-slate-700 rounded-2xl shadow-2xl text-slate-200 p-4 transform transition-all">
                <div class="flex items-center justify-between border-b border-slate-800 pb-2 mb-3">
                  <div class="flex items-center space-x-2">
                    <span class="w-2 h-2 rounded-full bg-amber-400 animate-ping"></span>
                    <h4 class="text-xs font-bold uppercase tracking-wider text-amber-400">Supplexio Procurement AI</h4>
                  </div>
                  <button onclick="toggleAiWidget()" class="text-slate-400 hover:text-white text-xs">✕</button>
                </div>
                <div class="space-y-2.5 text-xs">
                  <div class="bg-slate-800/80 p-2.5 rounded-lg border border-slate-700">
                    <p class="font-semibold text-white">💡 Real-time Competitive Signals</p>
                    <p class="text-slate-400 mt-1">1D-ResNet neural forecasts monitor market clearance ceilings across
                      all trade commodity chapters.</p>
                  </div>
                  <div class="bg-slate-800/80 p-2.5 rounded-lg border border-slate-700">
                    <p class="font-semibold text-white">⚠️ Action Recommended</p>
                    <p class="text-slate-400 mt-1" id="aiPendingPrompt">Auctions awaiting PO award can be awarded
                      immediately to lock in supplier prices.</p>
                  </div>
                </div>
              </div>

              <button onclick="toggleAiWidget()"
                class="w-12 h-12 bg-gradient-to-tr from-navy-900 to-slate-800 hover:from-navy-800 hover:to-slate-700 text-amber-400 p-3 rounded-full shadow-2xl border-2 border-amber-500/40 flex items-center justify-center group transition-transform duration-200 hover:scale-105"
                title="Supplexio AI Assistant">
                <svg class="w-6 h-6 text-amber-400 group-hover:rotate-12 transition-transform" fill="none"
                  stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </button>
            </div>

            <!-- TOAST NOTIFICATION CONTAINER -->
            <div id="toastContainer" class="fixed top-5 right-5 z-50 space-y-2 pointer-events-none"></div>

            <!-- HIDDEN FORMS FOR POST ACTIONS -->

            <!-- IN-APP CONFIRMATION & AUDIT MODAL -->
            <!-- ========================================================================= -->
            <!-- 🌟 CREATE REVERSE AUCTION & 1D-RESNET TIMING ORACLE MODAL                   -->
            <!-- ========================================================================= -->
            <div id="createAuctionModal"
              class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md hidden flex items-center justify-center p-3 sm:p-5 overflow-y-auto">
              <div
                class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-3xl w-full max-h-[92vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200 my-auto">

                <!-- Modal Header -->
                <div
                  class="px-6 py-4 bg-gradient-to-r from-navy-950 via-slate-900 to-navy-900 text-white flex items-center justify-between border-b border-slate-800 flex-shrink-0">
                  <div class="flex items-center space-x-3">
                    <div
                      class="w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                      </svg>
                    </div>
                    <div>
                      <h3 class="text-base font-bold tracking-tight text-white flex items-center gap-2">
                        <span>Create New Reverse Auction</span>
                        <span
                          class="px-2 py-0.5 rounded-full text-[10px] bg-sky-500/20 text-sky-300 border border-sky-400/30 font-mono">Timing
                          Oracle</span>
                      </h3>
                      <p class="text-[11px] text-slate-400 font-sans">1D-ResNet &amp; Bi-LSTM market price forecasting
                        &amp; strategic procurement advisory</p>
                    </div>
                  </div>
                  <div class="flex items-center space-x-2">
                    <a href="${pageContext.request.contextPath}/auction?action=new"
                      class="text-xs text-slate-400 hover:text-amber-400 font-medium px-2 py-1 rounded transition hover:bg-slate-800"
                      title="Open Full Form">
                      Full Page &nearr;
                    </a>
                    <button type="button" onclick="closeCreateAuctionModal()"
                      class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 transition">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Modal Body (Scrollable) -->
                <form id="createAuctionForm" action="${pageContext.request.contextPath}/auction" method="POST"
                  onsubmit="return validateCreateModalForm()" class="p-6 space-y-5 overflow-y-auto flex-1 font-sans">
                  <input type="hidden" name="action" value="create">

        <!-- Product Selection Row -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label class="text-xs font-bold text-slate-800 uppercase tracking-wider flex items-center gap-1.5">
              <span>Select Commodity / Product</span>
              <span class="text-rose-500">*</span>
            </label>
            <span id="productCountBadge" class="text-[11px] font-semibold text-sky-700 bg-sky-50 border border-sky-200 px-2.5 py-0.5 rounded-full flex items-center gap-1 shadow-xs">
              <svg class="w-3 h-3 text-sky-600 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>
              5,492 Commodities Available (108 Enterprise + 5,384 Global BACI)
            </span>
          </div>

          <!-- Live Universal Search & Selection Combobox -->
          <div class="relative" id="productComboboxWrapper">
            <div class="relative flex items-center">
              <input type="text" id="modalBaciSearchInput" 
                     placeholder="Search or click to browse 5,492 commodities (e.g. 'Steel Rods', 'Titanium', 'Paint', '721420')..." 
                     class="w-full text-xs font-medium px-3.5 py-2.5 pl-9 pr-20 bg-white border border-slate-300 rounded-xl focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 text-slate-800 placeholder-slate-400 outline-none transition cursor-pointer shadow-xs" 
                     autocomplete="off"
                     onclick="openProductDropdown()"
                     onfocus="openProductDropdown()">
              <svg class="w-4 h-4 text-sky-500 absolute left-3 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
              
              <div class="absolute right-2.5 flex items-center space-x-1.5">
                <button type="button" id="clearProductBtn" onclick="clearSelectedProduct(event)" class="hidden text-slate-400 hover:text-rose-500 p-1 rounded-full transition" title="Clear selection">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                </button>
                <button type="button" onclick="toggleProductDropdown(event)" class="text-slate-400 hover:text-slate-600 p-1 rounded-md transition" title="Toggle catalog list">
                  <svg id="comboboxChevron" class="w-4 h-4 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                </button>
              </div>
            </div>

            <!-- Active Selected Product Banner (Shows when an item is chosen) -->
            <div id="selectedProductCard" class="hidden mt-2 p-2.5 bg-gradient-to-r from-sky-50 via-slate-50 to-amber-50 border border-sky-200 rounded-xl flex items-center justify-between shadow-xs">
              <div class="flex items-center space-x-2.5">
                <span id="selectedProductTypeBadge" class="px-2 py-0.5 text-[10px] font-bold rounded-md bg-sky-600 text-white uppercase tracking-wider">Enterprise</span>
                <div>
                  <div class="flex items-center space-x-2">
                    <span id="selectedProductName" class="text-xs font-bold text-slate-900">Steel Rods</span>
                    <span id="selectedProductHsn" class="text-[10px] font-mono px-1.5 py-0.2 bg-slate-200 text-slate-700 rounded font-semibold">HSN: 721420</span>
                  </div>
                  <div class="text-[11px] text-slate-500 font-medium flex items-center space-x-2 mt-0.5">
                    <span id="selectedProductCategory">Steel &amp; Metals</span>
                    <span>•</span>
                    <span class="text-emerald-700 font-bold font-mono" id="selectedProductPrice">₹58,000 / ton</span>
                  </div>
                </div>
              </div>
              <button type="button" onclick="openProductDropdown(true)" class="text-xs font-bold text-sky-600 hover:text-sky-800 bg-white border border-sky-200 hover:border-sky-300 px-2.5 py-1 rounded-lg transition shadow-xs flex items-center space-x-1">
                <span>Change</span>
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
              </button>
            </div>

            <!-- Rich Dropdown Menu -->
            <div id="modalBaciSearchResults" class="absolute left-0 right-0 top-full mt-1.5 bg-white border border-slate-200 rounded-2xl shadow-2xl z-40 max-h-80 flex flex-col hidden overflow-hidden">
              <!-- Category Filter Chips -->
              <div class="p-2.5 bg-slate-50 border-b border-slate-200 flex items-center gap-1.5 overflow-x-auto text-[11px] no-scrollbar">
                <button type="button" onclick="filterCatalogCategory('all')" id="catBtn_all" class="cat-pill active px-2.5 py-1 rounded-lg font-bold bg-slate-900 text-white whitespace-nowrap shadow-xs">✨ All (5,492)</button>
                <button type="button" onclick="filterCatalogCategory('Enterprise')" id="catBtn_Enterprise" class="cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap">🏭 Enterprise (108)</button>
                <button type="button" onclick="filterCatalogCategory('Global BACI')" id="catBtn_Global" class="cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap">🌐 Global BACI (5,384)</button>
                <button type="button" onclick="filterCatalogCategory('Steel')" id="catBtn_Steel" class="cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap">🏗️ Steel</button>
                <button type="button" onclick="filterCatalogCategory('Paint')" id="catBtn_Paint" class="cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap">🧪 Chemicals &amp; Paint</button>
                <button type="button" onclick="filterCatalogCategory('Electrical')" id="catBtn_Electrical" class="cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap">⚡ Electrical</button>
              </div>

              <!-- Product Results List -->
              <div id="catalogListContainer" class="flex-1 overflow-y-auto divide-y divide-slate-100 max-h-64 p-1">
                <!-- Dynamically populated -->
              </div>

              <!-- Footer with Search Count & Global BACI hint -->
              <div class="px-3.5 py-2 bg-slate-50 border-t border-slate-200 flex items-center justify-between text-[11px] text-slate-500">
                <span id="catalogStatusCount">Showing products</span>
                <span class="text-sky-600 font-semibold flex items-center gap-1">
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
                  Instant Bilateral BACI Lakehouse Search
                </span>
              </div>
            </div>
          </div>

          <!-- Hidden Synced Native Select (so standard form submit with productId works 100%) -->
          <select id="modalProductId" name="productId" required onchange="onModalProductChange()" class="hidden">
            <option value="">— Select Product —</option>
            <c:forEach var="p" items="${products}">
              <option value="${p.id}" data-name="${p.name}" data-price="${p.unitPrice}" data-unit="${p.unit != null ? p.unit : 'units'}" data-hsn="${p.hsnCode != null ? p.hsnCode : 'General'}" data-category="${p.category}">
                ${p.name} (HSN: ${p.hsnCode != null ? p.hsnCode : 'General'})
              </option>
            </c:forEach>
          </select>
        </div>

                    <!-- Body Content -->
                    <div class="p-4 bg-white space-y-3.5">
                      <!-- Strategic Headline & Recommendation -->
                      <div class="space-y-1">
                        <h4 id="modalOracleHeadline"
                          class="text-sm font-extrabold text-slate-900 flex items-center gap-1.5"></h4>
                        <p id="modalOracleAdvisory" class="text-xs text-slate-600 leading-relaxed font-sans"></p>
                      </div>

                      <!-- Key Metrics Grid -->
                      <div
                        class="grid grid-cols-2 sm:grid-cols-4 gap-2.5 p-3 rounded-xl bg-slate-50 border border-slate-200/80 font-sans">
                        <div>
                          <span class="text-[10px] text-slate-500 font-semibold uppercase block">Spot Benchmark</span>
                          <span id="modalOracleSpotPrice" class="text-xs font-mono font-bold text-slate-800">--</span>
                        </div>
                        <div>
                          <span class="text-[10px] text-slate-500 font-semibold uppercase block">30d Projection</span>
                          <span id="modalOraclePredPrice" class="text-xs font-mono font-bold">--</span>
                        </div>
                        <div>
                          <span id="modalOracleSavingsLabel"
                            class="text-[10px] text-slate-500 font-semibold uppercase block">Projected Delta</span>
                          <span id="modalOracleSavingsVal"
                            class="text-xs font-mono font-bold text-emerald-600">--</span>
                        </div>
                        <div>
                          <span class="text-[10px] text-slate-500 font-semibold uppercase block">Execution Window</span>
                          <span id="modalOracleWindow" class="text-[11px] font-semibold text-slate-800">--</span>
                        </div>
                      </div>

                      <!-- Trajectory Sparkline Chart -->
                      <div class="space-y-1">
                        <div class="flex items-center justify-between text-[11px]">
                          <span class="font-bold text-slate-700 flex items-center gap-1">
                            <svg class="w-3.5 h-3.5 text-sky-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                            </svg>
                            Multi-Horizon Price Trajectory (1D-ResNet Multi-Step)
                          </span>
                          <span id="modalOracleConfidence" class="text-[10px] font-mono text-slate-500">Confidence:
                            91.4%</span>
                        </div>
                        <div class="h-28 w-full bg-slate-50 rounded-xl p-2 border border-slate-200/60 relative">
                          <canvas id="modalTimingSparklineChart"></canvas>
                        </div>
                      </div>

                      <!-- Strategic Action Quick Buttons -->
                      <div id="modalOracleActionButtons" class="pt-1 flex flex-wrap items-center gap-2">
                        <!-- Dynamically populated buttons -->
                      </div>
                    </div>
                  </div>

                  <!-- Schedule Inputs (Dates & Times) -->
                  <div class="space-y-1.5 pt-1 border-t border-slate-200">
                    <label class="text-xs font-bold text-slate-800 uppercase tracking-wider block">Auction Schedule
                      (IST)</label>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div>
                        <span class="text-[11px] text-slate-500 font-medium block mb-1">Start Date &amp; Time</span>
                        <div class="grid grid-cols-2 gap-2">
                          <input type="date" id="modalStartDate" name="startDate" required
                            class="text-xs px-2.5 py-2 bg-slate-50 border border-slate-300 rounded-lg text-slate-800">
                          <input type="time" id="modalStartTime" name="startTime" required
                            class="text-xs px-2.5 py-2 bg-slate-50 border border-slate-300 rounded-lg text-slate-800">
                        </div>
                      </div>
                      <div>
                        <span class="text-[11px] text-slate-500 font-medium block mb-1">End Date &amp; Time</span>
                        <div class="grid grid-cols-2 gap-2">
                          <input type="date" id="modalEndDate" name="endDate" required
                            class="text-xs px-2.5 py-2 bg-slate-50 border border-slate-300 rounded-lg text-slate-800">
                          <input type="time" id="modalEndTime" name="endTime" required
                            class="text-xs px-2.5 py-2 bg-slate-50 border border-slate-300 rounded-lg text-slate-800">
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Modal Footer Actions -->
                  <div class="pt-3 border-t border-slate-200 flex items-center justify-between">
                    <button type="button" onclick="closeCreateAuctionModal()"
                      class="px-4 py-2 border border-slate-300 rounded-xl text-xs font-semibold text-slate-700 bg-white hover:bg-slate-50 transition shadow-xs">
                      Cancel
                    </button>
                    <button type="submit" id="modalSubmitAuctionBtn"
                      class="px-6 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-bold rounded-xl text-xs shadow-md hover:shadow-amber-500/20 transition flex items-center gap-1.5">
                      <svg class="w-4 h-4 text-slate-950" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                      <span>Launch Reverse Auction</span>
                    </button>
                  </div>
                </form>
              </div>
            </div>

            <!-- IN-APP CONFIRMATION & AUDIT MODAL -->
            <div id="appConfirmModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4">
              <!-- Backdrop -->
              <div class="fixed inset-0 bg-slate-950/70 backdrop-blur-sm transition-opacity"
                onclick="closeAppConfirmModal()"></div>

            <!-- Modal Card -->
            <div
              class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden transform transition-all z-10 animate-in fade-in zoom-in-95 duration-200">
              <!-- Modal Header -->
              <div id="confirmModalHeader"
                class="px-6 py-4.5 bg-gradient-to-r from-slate-950 via-navy-900 to-slate-900 text-white flex items-center justify-between border-b border-slate-800">
                <div class="flex items-center space-x-3">
                  <div id="confirmModalIconBox"
                    class="w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                  <div>
                    <h3 id="confirmModalTitle" class="text-sm font-bold tracking-tight text-white">Confirmation</h3>
                    <p id="confirmModalSubtitle"
                      class="text-[10px] text-amber-400 font-mono tracking-wider uppercase font-semibold">SUPPLEXIO
                      ACTION AUDIT</p>
                  </div>
                </div>
                <button type="button" onclick="closeAppConfirmModal()"
                  class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 transition">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <!-- Modal Body -->
              <div class="p-6 space-y-4">
                <div id="confirmModalMessage" class="text-sm text-slate-700 leading-relaxed font-sans">
                  <!-- Main message text -->
                </div>

                <!-- Rich Summary Details Box -->
                <div id="confirmModalDetails"
                  class="hidden bg-slate-50 border border-slate-200 rounded-xl p-4 text-xs text-slate-700 space-y-2 font-sans">
                  <!-- Details dynamic content -->
                </div>
              </div>

              <!-- Modal Footer -->
              <div class="px-6 py-4 bg-slate-50 border-t border-slate-200 flex items-center justify-end space-x-3">
                <button type="button" id="confirmModalCancelBtn" onclick="closeAppConfirmModal()"
                  class="px-4 py-2 border border-slate-300 rounded-xl text-xs font-semibold text-slate-700 bg-white hover:bg-slate-100 transition shadow-xs">
                  Cancel
                </button>
                <button type="button" id="confirmModalConfirmBtn"
                  class="px-5 py-2.5 rounded-xl text-xs font-semibold shadow-md transition flex items-center space-x-1.5">
                  <!-- Button label & icon -->
                </button>
              </div>
            </div>
          </div>

          <form id="actionDeleteForm" action="${pageContext.request.contextPath}/auction" method="post"
            style="display:none;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" id="postDeleteId">
          </form>

          <!-- APPLICATION LOGIC -->
          <script>
            // INJECT REAL LIVE AUCTIONS FROM BACKEND (or empty fallback)
            const rawAuctions = <%= request.getAttribute("auctionsJson") != null ? request.getAttribute("auctionsJson") : "[]" %>;

            let auctionsData = Array.isArray(rawAuctions) && rawAuctions.length > 0 ? rawAuctions : [];

            // STATE VARIABLES
            let filteredAuctions = [...auctionsData];
            let sortField = 'id';
            let sortAsc = false;
            let currentPage = 1;
            let pageSize = 10;
            let activeDrawerId = null;

            // CURRENCY FORMATTER
            const formatINR = (amount) => {
              if (isNaN(amount) || amount === null) amount = 0;
              return new Intl.NumberFormat('en-IN', {
                style: 'currency',
                currency: 'INR',
                maximumFractionDigits: 2
              }).format(amount);
            };

            // SECONDS TO HH:MM:SS FORMATTER
            const formatTime = (secs) => {
              if (secs <= 0) return "00:00:00";
              const h = Math.floor(secs / 3600).toString().padStart(2, '0');
              const m = Math.floor((secs % 3600) / 60).toString().padStart(2, '0');
              const s = (secs % 60).toString().padStart(2, '0');
              return `\${h}:\${m}:\${s}`;
            };

            // CANONICAL STATUS LABELS & STYLES
            function getStatusBadge(status) {
              const s = (status || '').toUpperCase().trim();
              let label = status;
              let badgeClass = 'bg-slate-100 text-slate-700 border-slate-200';
              let isLive = false;

              if (s === 'ACTIVE' || s === 'LIVE' || s === 'LIVE BIDDING') {
                label = 'Active';
                badgeClass = 'bg-emerald-50 text-emerald-700 border-emerald-200';
                isLive = true;
              } else if (s === 'COMPLETED') {
                label = 'Completed — award PO';
                badgeClass = 'bg-amber-50 text-amber-700 border-amber-200';
              } else if (s === 'AWARDED') {
                label = 'Awarded';
                badgeClass = 'bg-indigo-50 text-indigo-700 border-indigo-200';
              } else if (s === 'PO_DRAFT') {
                label = 'PO Draft';
                badgeClass = 'bg-slate-100 text-slate-700 border-slate-200';
              } else if (s === 'PO_SENT' || s === 'SENT') {
                label = 'PO Sent';
                badgeClass = 'bg-orange-50 text-orange-700 border-orange-200';
              } else if (s === 'PO_ACCEPTED') {
                label = 'PO Accepted';
                badgeClass = 'bg-blue-50 text-blue-700 border-blue-200';
              } else if (s === 'SHIPPED') {
                label = 'Shipped';
                badgeClass = 'bg-cyan-50 text-cyan-700 border-cyan-200';
              } else if (s === 'DELIVERED') {
                label = 'Delivered';
                badgeClass = 'bg-emerald-50 text-emerald-700 border-emerald-200';
              } else if (s === 'INVOICING_PENDING') {
                label = 'Invoicing';
                badgeClass = 'bg-purple-50 text-purple-700 border-purple-200';
              } else if (s === 'PAYMENT_PENDING') {
                label = 'Payment Pending';
                badgeClass = 'bg-amber-50 text-amber-700 border-amber-200';
              } else if (s === 'PAYMENT_SUCCESSFUL' || s === 'PAID') {
                label = 'Payment Successful';
                badgeClass = 'bg-teal-50 text-teal-700 border-teal-200';
              } else if (s === 'CLOSED') {
                label = 'Closed';
                badgeClass = 'bg-slate-200 text-slate-800 border-slate-300';
              } else if (s === 'CANCELLED') {
                label = 'Cancelled';
                badgeClass = 'bg-rose-50 text-rose-700 border-rose-200';
              }

              return { label, badgeClass, isLive };
            }

            // INIT FUNCTION ON LOAD
            window.onload = function () {
              updateDashboard();

              // Check URL parameters for direct drawer opening or modal
              const urlParams = new URLSearchParams(window.location.search);
              if (urlParams.has('drawer')) {
                const dId = parseInt(urlParams.get('drawer'));
                if (!isNaN(dId)) setTimeout(() => openDrawer(dId), 150);
              }


              // Live Ticking Interval (Updates live auction timers every second)
              setInterval(() => {
                let needsRender = false;
                auctionsData.forEach(item => {
                  const s = (item.status || '').toUpperCase();
                  if ((s === 'ACTIVE' || s === 'LIVE BIDDING') && item.remainingSeconds > 0) {
                    item.remainingSeconds--;
                    needsRender = true;
                  }
                });
                if (needsRender) {
                  renderTable();
                  if (activeDrawerId) renderDrawerContent();
                }
              }, 1000);

              // Mobile sidebar toggle setup
              const mobileBtn = document.getElementById('mobileMenuBtn');
              if (mobileBtn) {
                mobileBtn.addEventListener('click', () => {
                  const sidebar = document.getElementById('sidebar');
                  sidebar.classList.toggle('-translate-x-full');
                });
              }

              // Catalog change handler in create modal
              const newProdSelect = document.getElementById('newProductId');
              if (newProdSelect) {
                newProdSelect.addEventListener('change', function () {
                  const selected = this.options[this.selectedIndex];
                  const price = selected.getAttribute('data-price');
                  if (price && price > 0) {
                    const startPriceInput = document.getElementById('newStartPrice');
                    if (startPriceInput && !startPriceInput.value) {
                      startPriceInput.value = price;
                    }
                  }
                });
              }
            };

            // MAIN REFRESH LOGIC
            function updateDashboard() {
              applyFilters();
              updateKPIs();
            }

            // UPDATE EXECUTIVE SUMMARY KPIS
            function updateKPIs() {
              const totalAuctions = auctionsData.length;
              const liveAuctions = auctionsData.filter(a => (a.status || '').toUpperCase() === 'ACTIVE' || (a.status || '').toUpperCase() === 'LIVE BIDDING').length;
              const awardPending = auctionsData.filter(a => (a.status || '').toUpperCase() === 'COMPLETED').length;

              let totalSavingsSum = 0;
              let totalStartPriceSum = 0;

              auctionsData.forEach(a => {
                const start = parseFloat(a.startPrice) || 0;
                const bid = parseFloat(a.currentBid) || start;
                if (start > bid) {
                  totalSavingsSum += (start - bid);
                }
                totalStartPriceSum += start;
              });

              const avgSavingsPct = totalStartPriceSum > 0 ? (totalSavingsSum / totalStartPriceSum) * 100 : 0;

              document.getElementById('kpiTotalAuctions').textContent = totalAuctions;
              document.getElementById('kpiLiveAuctions').textContent = liveAuctions;
              document.getElementById('kpiAwardPending').textContent = awardPending;
              document.getElementById('kpiRealizedSavings').textContent = formatINR(totalSavingsSum);
              document.getElementById('kpiAvgSavingsPct').textContent = `-\${avgSavingsPct.toFixed(1)}%`;

              const aiPending = document.getElementById('aiPendingPrompt');
              if (aiPending) {
                aiPending.textContent = awardPending > 0
                  ? `\${awardPending} Completed auction(s) await PO award. Immediate award recommended to lock price.`
                  : 'All completed auctions have been processed or awarded.';
              }
            }

            // FILTER LOGIC
            function applyFilters() {
              const searchVal = document.getElementById('searchInput').value.toLowerCase().trim();
              const statusVal = document.getElementById('statusFilter').value;
              const catVal = document.getElementById('productFilter').value;

              filteredAuctions = auctionsData.filter(item => {
                const itemProd = (item.product || '').toLowerCase();
                const itemCat = (item.category || '').toLowerCase();
                const itemHsn = (item.hsnCode || '').toLowerCase();
                const itemWinner = (item.winner || '').toLowerCase();
                const itemId = item.id ? item.id.toString() : '';

                // Search text matching
                const matchesSearch = !searchVal ||
                  itemId.includes(searchVal) ||
                  itemProd.includes(searchVal) ||
                  itemCat.includes(searchVal) ||
                  itemHsn.includes(searchVal) ||
                  itemWinner.includes(searchVal);

                // Status matching
                let matchesStatus = true;
                if (statusVal && statusVal !== 'ALL') {
                  const itemStatus = (item.status || '').toUpperCase().trim();
                  const targetStatus = statusVal.toUpperCase().trim();

                  if (targetStatus === 'ACTIVE') {
                    matchesStatus = (itemStatus === 'ACTIVE' || itemStatus === 'LIVE' || itemStatus === 'LIVE BIDDING');
                  } else if (targetStatus === 'COMPLETED') {
                    matchesStatus = (itemStatus === 'COMPLETED');
                  } else if (targetStatus === 'PO_SENT') {
                    matchesStatus = (itemStatus === 'PO_SENT' || itemStatus === 'SENT');
                  } else if (targetStatus === 'PAYMENT_SUCCESSFUL') {
                    matchesStatus = (itemStatus === 'PAYMENT_SUCCESSFUL' || itemStatus === 'PAID');
                  } else {
                    matchesStatus = (itemStatus === targetStatus);
                  }
                }

                // Product category matching
                let matchesCategory = true;
                if (catVal && catVal !== 'ALL') {
                  const catLower = catVal.toLowerCase().trim();
                  matchesCategory = (itemCat === catLower || itemCat.includes(catLower) || itemProd.includes(catLower));
                }

                return matchesSearch && matchesStatus && matchesCategory;
              });

              // Sort data
              filteredAuctions.sort((a, b) => {
                let valA = a[sortField];
                let valB = b[sortField];

                if (typeof valA === 'string') valA = valA.toLowerCase();
                if (typeof valB === 'string') valB = valB.toLowerCase();

                if (valA < valB) return sortAsc ? -1 : 1;
                if (valA > valB) return sortAsc ? 1 : -1;
                return 0;
              });

              currentPage = 1; // Reset to page 1 on filter change
              document.getElementById('filteredCountBadge').textContent = `\${filteredAuctions.length} Auctions`;
              renderTable();
            }

            function handleSearch() {
              applyFilters();
            }

            function resetFilters() {
              document.getElementById('searchInput').value = '';
              document.getElementById('statusFilter').value = 'ALL';
              document.getElementById('productFilter').value = 'ALL';
              applyFilters();
              showToast('Filters reset to default view');
            }

            // SORTING LOGIC
            function sortTable(field) {
              if (sortField === field) {
                sortAsc = !sortAsc;
              } else {
                sortField = field;
                sortAsc = true;
              }

              // Update Header Icons
              ['id', 'product', 'startPrice', 'currentBid'].forEach(f => {
                const icon = document.getElementById(`sortIcon_\${f}`);
                if (icon) {
                  if (f === sortField) {
                    icon.textContent = sortAsc ? '↑' : '↓';
                    icon.classList.add('text-amber-500', 'font-bold');
                  } else {
                    icon.textContent = '↕';
                    icon.classList.remove('text-amber-500', 'font-bold');
                  }
                }
              });

              applyFilters();
            }

            // RENDER REVERSE AUCTION TABLE
            function renderTable() {
              const tbody = document.getElementById('auctionTableBody');
              tbody.innerHTML = '';

              if (filteredAuctions.length === 0) {
                tbody.innerHTML = `
          <tr>
            <td colspan="7" class="py-12 text-center text-slate-400 bg-white">
              <div class="max-w-sm mx-auto space-y-2">
                <svg class="w-10 h-10 mx-auto text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
                <p class="font-semibold text-slate-700">No matching reverse auctions found</p>
                <p class="text-xs text-slate-400">Try adjusting your filters or launch a new auction.</p>
              </div>
            </td>
          </tr>`;
                renderPagination(0);
                return;
              }

              const startIdx = (currentPage - 1) * pageSize;
              const endIdx = startIdx + parseInt(pageSize);
              const pageData = filteredAuctions.slice(startIdx, endIdx);

              pageData.forEach(item => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-slate-50/80 transition-colors group cursor-pointer";
                tr.onclick = (e) => {
                  // Prevent drawer opening if action buttons were clicked
                  if (!e.target.closest('button') && !e.target.closest('a')) {
                    openDrawer(item.id);
                  }
                };

                const startPrice = parseFloat(item.startPrice) || 0;
                const currentBid = parseFloat(item.currentBid) || startPrice;
                const hasSavings = startPrice > currentBid;
                const savingsPct = hasSavings && startPrice > 0 ? (((startPrice - currentBid) / startPrice) * 100).toFixed(1) : 0;

                const { label, badgeClass, isLive } = getStatusBadge(item.status);

                const catBadge = item.category ? '<span class="px-1.5 py-0.2 bg-slate-100 text-slate-600 rounded text-[10px] border border-slate-200 font-medium">' + escapeHtml(item.category) + '</span>' : '';
                const hsnBadge = item.hsnCode ? '<span class="px-1.5 py-0.2 bg-blue-50 text-blue-700 rounded text-[10px] border border-blue-200 font-mono font-bold tracking-tight">HSN: ' + escapeHtml(item.hsnCode) + '</span>' : '';
                const savingsBadge = hasSavings ? '<span class="inline-block mt-0.5 px-1.5 py-0.2 bg-emerald-100 text-emerald-700 text-[10px] font-mono-tabular font-bold rounded">-' + savingsPct + '%</span>' : '<span class="text-[10px] text-slate-400 font-mono-tabular">0% savings</span>';
                
                let scheduleHtml = '';
                if (isLive) {
                  scheduleHtml = '<div class="flex items-center space-x-2"><span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse-emerald"></span><span class="font-mono-tabular font-bold text-emerald-700 text-xs bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">' + formatTime(item.remainingSeconds) + '</span></div>';
                } else {
                  scheduleHtml = '<div class="text-xs text-slate-500 font-mono-tabular">' + (item.startTime ? 'Start: ' + item.startTime : 'Schedule logged') + '</div><div class="text-xs text-slate-400 font-mono-tabular">' + (item.endTime ? 'End: ' + item.endTime : '') + '</div>';
                }

                let winnerHtml = '';
                if (item.winner) {
                  winnerHtml = '<div class="text-xs font-semibold text-slate-700 mt-1 flex items-center"><svg class="w-3 h-3 text-amber-500 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" /></svg><span>' + escapeHtml(item.winner) + '</span></div>';
                }

                const ctxPath = '${pageContext.request.contextPath}';
                const statusUpper = (item.status || '').toUpperCase();
                let actionsHtml = '';
                actionsHtml += '<button onclick="openDrawer(' + item.id + ')" class="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition-colors" title="Open Bid Room Drawer"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg></button>';
                actionsHtml += '<a href="' + ctxPath + '/auction?action=view&id=' + item.id + '" class="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Enter Bidding Floor"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg></a>';

                if (statusUpper === 'COMPLETED') {
                  actionsHtml += '<button onclick="awardPOPrompt(' + item.id + ')" class="p-1.5 text-amber-600 hover:text-amber-800 hover:bg-amber-50 rounded-lg transition-colors" title="Award Purchase Order"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg></button>';
                }

                if (['AWARDED', 'PO_DRAFT', 'PO_SENT', 'PO_ACCEPTED', 'INVOICING_PENDING', 'PAYMENT_PENDING', 'PAYMENT_SUCCESSFUL'].includes(statusUpper)) {
                  actionsHtml += '<a href="' + ctxPath + '/user-po-view" class="p-1.5 text-blue-600 hover:text-blue-800 hover:bg-blue-50 rounded-lg transition-colors" title="View in Purchase Orders"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg></a>';
                }

                if (statusUpper === 'PAID' || statusUpper === 'SHIPPED') {
                  actionsHtml += '<button onclick="markDelivered(' + item.id + ', \'' + escapeHtml(item.product) + '\', ' + (item.requiredQuantity || 1) + ')" class="p-1.5 text-emerald-600 hover:text-emerald-800 hover:bg-emerald-50 rounded-lg transition-colors" title="Mark as Delivered"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></button>';
                }

                if (statusUpper !== 'DELIVERED' && statusUpper !== 'CLOSED') {
                  actionsHtml += '<button onclick="deleteAuction(' + item.id + ')" class="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Delete Auction"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>';
                }

                tr.innerHTML = '<td class="py-4 px-4 font-mono-tabular font-bold text-slate-900 text-xs">#' + item.id + '</td>' +
                  '<td class="py-4 px-4">' +
                    '<div class="font-bold text-slate-900">' + escapeHtml(item.product) + '</div>' +
                    '<div class="flex flex-wrap items-center gap-1.5 mt-1">' +
                      '<span class="text-xs text-slate-500 font-medium">' + escapeHtml(item.quantity || '') + '</span>' +
                      catBadge + hsnBadge +
                    '</div>' +
                  '</td>' +
                  '<td class="py-4 px-4 text-right font-mono-tabular text-slate-600">' + formatINR(startPrice) + '</td>' +
                  '<td class="py-4 px-4 text-right">' +
                    '<div class="font-mono-tabular font-bold text-slate-900">' + formatINR(currentBid) + '</div>' +
                    savingsBadge +
                  '</td>' +
                  '<td class="py-4 px-4">' + scheduleHtml + '</td>' +
                  '<td class="py-4 px-4">' +
                    '<span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold border ' + badgeClass + '">' +
                      (isLive ? '<span class="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5 animate-pulse"></span>' : '') +
                      label +
                    '</span>' +
                    winnerHtml +
                  '</td>' +
                  '<td class="py-4 px-4 text-center">' +
                    '<div class="flex items-center justify-center space-x-1">' + actionsHtml + '</div>' +
                  '</td>';

                tbody.appendChild(tr);
              });

              renderPagination(filteredAuctions.length);
            }

            // PAGINATION LOGIC
            function renderPagination(totalItems) {
              const totalPages = Math.ceil(totalItems / pageSize) || 1;
              const startEntry = totalItems === 0 ? 0 : (currentPage - 1) * pageSize + 1;
              const endEntry = Math.min(currentPage * pageSize, totalItems);

              document.getElementById('paginationInfo').textContent = `Showing \${startEntry} to \${endEntry} of \${totalItems} entries`;

              const btnContainer = document.getElementById('paginationButtons');
              btnContainer.innerHTML = '';

              // Prev Button
              const prevBtn = document.createElement('button');
              prevBtn.className = `px-2.5 py-1 rounded border text-xs font-semibold \${currentPage === 1 ? 'border-slate-200 text-slate-300 cursor-not-allowed' : 'border-slate-300 text-slate-600 hover:bg-slate-100'}`;
              prevBtn.textContent = 'Prev';
              prevBtn.disabled = currentPage === 1;
              prevBtn.onclick = () => { if (currentPage > 1) { currentPage--; renderTable(); } };
              btnContainer.appendChild(prevBtn);

              // Page Numbers (sliding window)
              const maxPagesToShow = 5;
              let startP = Math.max(1, currentPage - 2);
              let endP = Math.min(totalPages, startP + maxPagesToShow - 1);
              if (endP - startP < maxPagesToShow - 1) {
                startP = Math.max(1, endP - maxPagesToShow + 1);
              }

              for (let i = startP; i <= endP; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.className = `px-2.5 py-1 rounded text-xs font-mono-tabular font-bold \${i === currentPage ? 'bg-navy-900 text-amber-400' : 'text-slate-600 hover:bg-slate-100'}`;
                pageBtn.textContent = i;
                pageBtn.onclick = () => { currentPage = i; renderTable(); };
                btnContainer.appendChild(pageBtn);
              }

              // Next Button
              const nextBtn = document.createElement('button');
              nextBtn.className = `px-2.5 py-1 rounded border text-xs font-semibold \${currentPage === totalPages || totalPages === 0 ? 'border-slate-200 text-slate-300 cursor-not-allowed' : 'border-slate-300 text-slate-600 hover:bg-slate-100'}`;
              nextBtn.textContent = 'Next';
              nextBtn.disabled = currentPage === totalPages || totalPages === 0;
              nextBtn.onclick = () => { if (currentPage < totalPages) { currentPage++; renderTable(); } };
              btnContainer.appendChild(nextBtn);
            }

            function changePageSize(size) {
              pageSize = parseInt(size);
              currentPage = 1;
              renderTable();
            }

            // SLIDE-OVER DRAWER CONTROL
            function openDrawer(id) {
              activeDrawerId = id;
              renderDrawerContent();

              const drawer = document.getElementById('bidRoomDrawer');
              const backdrop = document.getElementById('drawerBackdrop');

              backdrop.classList.remove('hidden');
              setTimeout(() => backdrop.classList.remove('opacity-0'), 10);

              drawer.classList.remove('translate-x-full');
            }

            function closeDrawer() {
              const drawer = document.getElementById('bidRoomDrawer');
              const backdrop = document.getElementById('drawerBackdrop');

              drawer.classList.add('translate-x-full');
              backdrop.classList.add('opacity-0');
              setTimeout(() => {
                backdrop.classList.add('hidden');
                activeDrawerId = null;
              }, 300);
            }

            function renderDrawerContent() {
              const item = auctionsData.find(a => a.id === activeDrawerId);
              if (!item) return;

              document.getElementById('drawerAuctionId').textContent = `#\${item.id}`;
              document.getElementById('drawerProductName').textContent = item.product;
              document.getElementById('drawerQuantity').textContent = `Quantity: \${item.quantity || ''} \${item.hsnCode ? '• HSN: ' + item.hsnCode : ''} \${item.category ? '• ' + item.category : ''}`;

              const { label, isLive } = getStatusBadge(item.status);
              const badge = document.getElementById('drawerStatusBadge');
              badge.textContent = label;
              if (isLive) {
                badge.className = 'px-2 py-0.5 rounded text-xs font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30';
              } else if ((item.status || '').toUpperCase() === 'COMPLETED') {
                badge.className = 'px-2 py-0.5 rounded text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30';
              } else {
                badge.className = 'px-2 py-0.5 rounded text-xs font-semibold bg-slate-700 text-slate-300';
              }

              // Live Timer box
              const timerBox = document.getElementById('drawerTimerBox');
              if (isLive) {
                timerBox.classList.remove('hidden');
                document.getElementById('drawerCountdown').textContent = formatTime(item.remainingSeconds);
              } else {
                timerBox.classList.add('hidden');
              }

              // Mini cards
              const startPrice = parseFloat(item.startPrice) || 0;
              const currentBid = parseFloat(item.currentBid) || startPrice;
              document.getElementById('drawerStartPrice').textContent = formatINR(startPrice);
              document.getElementById('drawerCurrentBid').textContent = formatINR(currentBid);
              const savings = Math.max(0, startPrice - currentBid);
              const savingsPct = startPrice > 0 ? ((savings / startPrice) * 100).toFixed(1) : 0;
              document.getElementById('drawerSavings').textContent = `\${formatINR(savings)} (\${savingsPct}%)`;

              // Drawer Action Buttons
              const actionsContainer = document.getElementById('drawerActionButtons');
              actionsContainer.innerHTML = '';

              if (isLive) {
                // Simulate lower bid button
                const simBtn = document.createElement('button');
                simBtn.className = 'w-full sm:w-auto px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-lg shadow transition-colors flex items-center justify-center space-x-1.5';
                simBtn.innerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"/></svg>
          <span>Simulate Lower Bid (-2.5%)</span>
        `;
                simBtn.onclick = () => simulateLowerBid(item.id);
                actionsContainer.appendChild(simBtn);

                // Complete auction button
                const compBtn = document.createElement('button');
                compBtn.className = 'w-full sm:w-auto px-4 py-2 bg-amber-500 hover:bg-amber-600 text-navy-950 font-bold text-xs rounded-lg shadow transition-colors flex items-center justify-center space-x-1.5';
                compBtn.innerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          <span>Complete Auction Floor</span>
        `;
                compBtn.onclick = () => completeAuction(item.id);
                actionsContainer.appendChild(compBtn);
              } else if ((item.status || '').toUpperCase() === 'COMPLETED') {
                const awardBtn = document.createElement('button');
                awardBtn.className = 'w-full sm:w-auto px-4 py-2 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-navy-950 font-bold text-xs rounded-lg shadow transition-colors flex items-center justify-center space-x-1.5';
                awardBtn.innerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          <span>Award Purchase Order</span>
        `;
                awardBtn.onclick = () => awardPOPrompt(item.id);
                actionsContainer.appendChild(awardBtn);
              }

              if (['AWARDED', 'PO_DRAFT', 'PO_SENT', 'PO_ACCEPTED', 'INVOICING_PENDING', 'PAYMENT_PENDING', 'PAYMENT_SUCCESSFUL'].includes((item.status || '').toUpperCase())) {
                const viewPoBtn = document.createElement('a');
                viewPoBtn.href = '${pageContext.request.contextPath}/user-po-view';
                viewPoBtn.className = 'w-full sm:w-auto px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-lg shadow transition-colors flex items-center justify-center space-x-1.5 no-underline';
                viewPoBtn.innerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
          <span>View Purchase Orders</span>
        `;
                actionsContainer.appendChild(viewPoBtn);
              }

              if ((item.status || '').toUpperCase() === 'PAID' || (item.status || '').toUpperCase() === 'SHIPPED') {
                const delivBtn = document.createElement('button');
                delivBtn.className = 'w-full sm:w-auto px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-lg shadow transition-colors flex items-center justify-center space-x-1.5';
                delivBtn.innerHTML = `
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          <span>Mark as Delivered</span>
        `;
                delivBtn.onclick = () => markDelivered(item.id, item.product, item.requiredQuantity || 1);
                actionsContainer.appendChild(delivBtn);
              }

              // Enter full bidding floor link
              const floorLink = document.createElement('a');
              floorLink.href = `${pageContext.request.contextPath}/auction?action=view&id=\${item.id}`;
              floorLink.className = 'w-full sm:w-auto px-4 py-2 bg-slate-200 hover:bg-slate-300 text-slate-800 font-bold text-xs rounded-lg transition-colors flex items-center justify-center space-x-1.5 no-underline';
              floorLink.innerHTML = `
        <svg class="w-4 h-4 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
        <span>Open Dedicated Bidding Room</span>
      `;
              actionsContainer.appendChild(floorLink);

              // Render Bid Audit Timeline
              const timeline = document.getElementById('drawerBidTimeline');
              timeline.innerHTML = '';
              const bids = Array.isArray(item.bids) ? item.bids : [];
              document.getElementById('bidCountBadge').textContent = `\${bids.length} bids logged`;

              if (bids.length === 0) {
                timeline.innerHTML = `<div class="p-6 text-xs text-center text-slate-400">No supplier bids recorded yet.</div>`;
              } else {
                bids.forEach((bid, idx) => {
                  const div = document.createElement('div');
                  div.className = "px-4 py-3 flex items-center justify-between text-xs hover:bg-slate-50 transition-colors";
                  div.innerHTML = `
            <div>
              <p class="font-bold text-slate-800">\${escapeHtml(bid.supplier || 'Verified Supplier')}</p>
              <p class="text-[10px] text-slate-400 font-mono-tabular mt-0.5">\${bid.time || 'Logged'}</p>
            </div>
            <div class="text-right">
              <p class="font-mono-tabular font-bold text-slate-900">\${formatINR(bid.amount)}</p>
              \${idx === 0 ? `< span class="text-[9px] font-bold text-emerald-600 uppercase bg-emerald-50 px-1 rounded" > Current Lowest</span > ` : ''}
            </div>
          `;
                  timeline.appendChild(div);
                });
              }
            }

            // SIMULATE LOWER BID FUNCTION (INTERACTIVE ACTION)
            function simulateLowerBid(id) {
              const item = auctionsData.find(a => a.id === id);
              if (!item) return;

              const randomSuppliers = ['Rajesh Metals', 'National Logistics Ltd', 'Shree Tech Materials', 'Apex Industrial Solutions', 'Suthar Global Trading'];
              const supplierName = randomSuppliers[Math.floor(Math.random() * randomSuppliers.length)];

              const current = parseFloat(item.currentBid) || parseFloat(item.startPrice) || 1000;
              const newBid = Math.round((current * 0.975) * 100) / 100;
              const timeNow = 'Just Now';

              item.currentBid = newBid;
              if (!Array.isArray(item.bids)) item.bids = [];
              item.bids.unshift({
                supplier: supplierName,
                amount: newBid,
                time: timeNow
              });

              updateDashboard();
              if (activeDrawerId === id) renderDrawerContent();
              showToast(`New competitive bid ₹\${newBid.toLocaleString('en-IN')} placed by \${supplierName}!`);
            }


            // -------------------------------------------------------------------
            // IN-APP CONFIRMATION MODAL ENGINE (REPLACES SYSTEM POPUPS)
            // -------------------------------------------------------------------
            let appConfirmCallback = null;

            function showAppConfirm(config) {
              const modal = document.getElementById('appConfirmModal');
              const titleEl = document.getElementById('confirmModalTitle');
              const subtitleEl = document.getElementById('confirmModalSubtitle');
              const messageEl = document.getElementById('confirmModalMessage');
              const detailsEl = document.getElementById('confirmModalDetails');
              const confirmBtn = document.getElementById('confirmModalConfirmBtn');
              const cancelBtn = document.getElementById('confirmModalCancelBtn');
              const iconBox = document.getElementById('confirmModalIconBox');

              if (!modal) return;

              titleEl.textContent = config.title || 'Confirmation Required';
              subtitleEl.textContent = config.subtitle || 'SUPPLEXIO ACTION AUDIT';
              messageEl.innerHTML = config.message || 'Are you sure you want to proceed?';

              if (config.detailsHtml) {
                detailsEl.innerHTML = config.detailsHtml;
                detailsEl.classList.remove('hidden');
              } else {
                detailsEl.innerHTML = '';
                detailsEl.classList.add('hidden');
              }

              confirmBtn.className = 'px-5 py-2.5 rounded-xl text-xs font-semibold shadow-md transition flex items-center space-x-1.5 ' + (config.confirmClass || 'bg-navy-900 hover:bg-slate-800 text-white');
              confirmBtn.innerHTML = '<span>' + (config.confirmText || 'Confirm') + '</span>';

              if (cancelBtn) {
                cancelBtn.textContent = config.cancelText || 'Cancel';
                cancelBtn.style.display = config.hideCancel ? 'none' : '';
              }

              // Configure icon box based on iconType
              if (config.iconType === 'award') {
                iconBox.className = 'w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400';
                iconBox.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>';
              } else if (config.iconType === 'trash') {
                iconBox.className = 'w-10 h-10 rounded-xl bg-rose-500/20 border border-rose-500/40 flex items-center justify-center text-rose-400';
                iconBox.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>';
              } else if (config.iconType === 'complete') {
                iconBox.className = 'w-10 h-10 rounded-xl bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400';
                iconBox.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>';
              } else {
                iconBox.className = 'w-10 h-10 rounded-xl bg-blue-500/20 border border-blue-500/40 flex items-center justify-center text-blue-400';
                iconBox.innerHTML = '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>';
              }

              appConfirmCallback = config.onConfirm || null;
              confirmBtn.onclick = function () {
                const cb = appConfirmCallback;
                closeAppConfirmModal();
                if (typeof cb === 'function') {
                  cb();
                }
              };

              modal.classList.remove('hidden');
              modal.classList.add('flex'); modal.style.display = 'flex';
            }

            function closeAppConfirmModal() {
              const modal = document.getElementById('appConfirmModal');
              if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex'); modal.style.display = 'none';
              }
              appConfirmCallback = null;
            }


            // COMPLETE AUCTION FUNCTION (WITH IN-APP CONFIRMATION MODAL)
            function completeAuction(id) {
              const item = auctionsData.find(a => a.id === id);
              const prodName = item ? item.product : ('Auction #' + id);
              const bestBid = item && item.currentBid ? '₹' + item.currentBid.toLocaleString('en-IN') : 'N/A';

              showAppConfirm({
                title: 'Complete Auction #' + id,
                subtitle: 'SUPPLEXIO REVERSE AUCTION FINALIZATION',
                iconType: 'complete',
                message: 'Complete <strong>Auction #' + id + '</strong>? This will determine the winning supplier and finalize the reverse auction.<br><br><span class="text-xs text-slate-500">All real-time bidding for this lot will be frozen and savings metrics calculated.</span>',
                detailsHtml:
                  '<div class="flex justify-between items-center pb-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Commodity:</span>' +
                  '<span class="font-bold text-slate-900">' + escapeHtml(prodName) + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center pt-1">' +
                  '<span class="font-semibold text-slate-500">Current Best Bid:</span>' +
                  '<span class="font-mono font-bold text-emerald-600">' + bestBid + '</span>' +
                  '</div>',
                confirmText: 'Complete Auction Floor',
                confirmClass: 'bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold',
                onConfirm: function () {
                  $.ajax({
                    url: '${pageContext.request.contextPath}/auction-completion',
                    method: 'POST',
                    data: {
                      action: 'completeAuction',
                      auctionId: id
                    },
                    dataType: 'json',
                    success: function (response) {
                      if (response.success) {
                        if (item) {
                          item.status = 'COMPLETED';
                        }
                        updateDashboard();
                        if (activeDrawerId === id) renderDrawerContent();
                        showToast(response.message || `Auction #${id} successfully completed!`);
                      } else {
                        showToast(response.message || 'Unable to complete auction');
                      }
                    },
                    error: function (xhr, status, error) {
                      // Local fallback simulation
                      if (item) {
                        item.status = 'COMPLETED';
                        updateDashboard();
                        if (activeDrawerId === id) renderDrawerContent();
                      }
                      showToast(`Auction #${id} completed`);
                    }
                  });
                }
              });
            }

            // AWARD PURCHASE ORDER AND CREATE OFFICIAL PO IN DATABASE (WITH IN-APP MODAL)
            function awardPOPrompt(id) {
              const item = auctionsData.find(a => a.id === id);
              if (!item) return;

              const defaultWinner = item.winner || (item.bids && item.bids.length > 0 ? item.bids[0].supplier : 'Heet Patel');
              const supplierId = item.winningSupplierId || (item.bids && item.bids.length > 0 && item.bids[0].supplierId ? item.bids[0].supplierId : 103);
              const finalPrice = item.currentBid ? '₹' + item.currentBid.toLocaleString('en-IN') : 'N/A';

              showAppConfirm({
                title: 'Award Purchase Order',
                subtitle: 'SUPPLEXIO B2B CONTRACT AWARD · #AUC-' + id,
                iconType: 'award',
                message: 'Award Purchase Order for <strong>Auction #' + id + ' (' + escapeHtml(item.product) + ')</strong> to <strong>' + escapeHtml(defaultWinner) + '</strong>?<br><br><span class="text-xs text-slate-500">This will generate the official Purchase Order draft and record it in the database.</span>',
                detailsHtml:
                  '<div class="flex justify-between items-center pb-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Originating Auction:</span>' +
                  '<span class="font-mono font-bold text-slate-900">#AUC-' + id + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center py-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Awarded Supplier:</span>' +
                  '<span class="font-bold text-slate-900">' + escapeHtml(defaultWinner) + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center py-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Commodity:</span>' +
                  '<span class="font-bold text-slate-900">' + escapeHtml(item.product) + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center pt-1">' +
                  '<span class="font-semibold text-slate-500">Contract Final Price:</span>' +
                  '<span class="font-mono font-bold text-emerald-600">' + finalPrice + '</span>' +
                  '</div>',
                confirmText: 'Award Purchase Order',
                confirmClass: 'bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-navy-950 font-bold',
                onConfirm: function () {
                  showToast('Generating official Purchase Order for Auction #' + id + '...');

                  $.ajax({
                    url: '${pageContext.request.contextPath}/auctions/award',
                    method: 'POST',
                    data: {
                      auctionId: id,
                      winningSupplierId: supplierId,
                      format: 'json'
                    },
                    dataType: 'json',
                    success: function (response) {
                      if (response && response.success) {
                        item.status = 'AWARDED';
                        item.winner = defaultWinner;
                        updateDashboard();
                        if (activeDrawerId === id) renderDrawerContent();

                        // Display rich notification toast with direct link to Purchase Orders page
                        const container = document.getElementById('toastContainer');
                        if (container) {
                          const div = document.createElement('div');
                          div.className = 'p-3 bg-emerald-950 border border-emerald-500/60 rounded-xl shadow-2xl text-white text-xs flex flex-col space-y-2 pointer-events-auto transform transition-all duration-300';
                          div.innerHTML = `
                    <div class="flex items-center space-x-2">
                      <span class="text-base">🎉</span>
                      <span class="font-bold">Purchase Order Created!</span>
                    </div>
                    <p class="text-slate-300">\${response.message || 'PO generated successfully.'}</p>
                    <div class="flex items-center space-x-2 pt-1">
                      <a href="\${response.poUrl || '${pageContext.request.contextPath}/user-po-view'}" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold rounded text-xs transition flex items-center space-x-1 no-underline">
                        <span>View in Purchase Orders</span>
                        <span>&rarr;</span>
                      </a>
                      <button onclick="this.closest('.pointer-events-auto').remove()" class="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded text-xs">
                        Dismiss
                      </button>
                    </div>
                  `;
                          container.appendChild(div);
                          setTimeout(() => { div.remove(); }, 12000);
                        }
                      } else {
                        showToast(response.error || 'Failed to award auction');
                      }
                    },
                    error: function (xhr) {
                      let err = 'Error awarding auction';
                      try {
                        const res = JSON.parse(xhr.responseText);
                        if (res.error) err = res.error;
                      } catch (e) { }
                      showToast(err);
                    }
                  });
                }
              });
            }

            // MARK DELIVERED FUNCTION (WITH IN-APP MODAL)
            function markDelivered(id, prod, qty) {
              showAppConfirm({
                title: 'Confirm Delivery Received',
                subtitle: 'SUPPLEXIO GOODS RECEIPT AUDIT · #AUC-' + id,
                iconType: 'complete',
                message: 'Confirm delivery has been received at the warehouse for <strong>' + escapeHtml(prod) + '</strong> (Auction #' + id + ')?',
                detailsHtml:
                  '<div class="flex justify-between items-center pb-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Auction Reference:</span>' +
                  '<span class="font-mono font-bold text-slate-900">#AUC-' + id + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center py-1 border-b border-slate-200">' +
                  '<span class="font-semibold text-slate-500">Commodity:</span>' +
                  '<span class="font-bold text-slate-900">' + escapeHtml(prod) + '</span>' +
                  '</div>' +
                  '<div class="flex justify-between items-center pt-1">' +
                  '<span class="font-semibold text-slate-500">Quantity:</span>' +
                  '<span class="font-mono font-bold text-slate-900">' + (qty || 1) + ' units</span>' +
                  '</div>',
                confirmText: 'Confirm Delivery',
                confirmClass: 'bg-emerald-600 hover:bg-emerald-700 text-white font-bold',
                onConfirm: function () {
                  $.ajax({
                    url: '${pageContext.request.contextPath}/auction-completion',
                    method: 'POST',
                    data: {
                      action: 'markDelivered',
                      auctionId: id,
                      quantity: qty || 1
                    },
                    dataType: 'json',
                    success: function (response) {
                      const item = auctionsData.find(a => a.id === id);
                      if (item) {
                        item.status = 'DELIVERED';
                      }
                      updateDashboard();
                      if (activeDrawerId === id) renderDrawerContent();
                      showToast(response.message || `Delivery recorded for Auction #${id}`);
                    },
                    error: function () {
                      const item = auctionsData.find(a => a.id === id);
                      if (item) {
                        item.status = 'DELIVERED';
                        updateDashboard();
                        if (activeDrawerId === id) renderDrawerContent();
                      }
                      showToast(`Delivery recorded for Auction #${id}`);
                    }
                  });
                }
              });
            }

            // DELETE AUCTION (WITH IN-APP MODAL)
            function deleteAuction(id) {
              const item = auctionsData.find(a => a.id === id);
              const prodName = item ? item.product : ('Auction #' + id);

              showAppConfirm({
                title: 'Delete Auction Lot',
                subtitle: 'SUPPLEXIO PERMANENT ACTION · #AUC-' + id,
                iconType: 'trash',
                message: 'Are you sure you want to delete Auction #' + id + ' (<strong>' + escapeHtml(prodName) + '</strong>)?<br><br><span class="text-xs text-rose-600 font-semibold">⚠️ This action cannot be undone. All bids and history will be permanently deleted.</span>',
                confirmText: 'Delete Auction',
                confirmClass: 'bg-rose-600 hover:bg-rose-700 text-white font-bold',
                onConfirm: function () {
                  document.getElementById('postDeleteId').value = id;
                  document.getElementById('actionDeleteForm').submit();
                }
              });
            }

            // EXPORT TO CSV
            function exportCSV() {
              let csv = 'Auction ID,Product,Category,Quantity,Start Price (INR),Current Best Bid (INR),Status,Winner,Start Time,End Time\n';
              filteredAuctions.forEach(a => {
                csv += `"\${a.id}","\${a.product}","\${a.category || ''}","\${a.quantity || ''}",\${a.startPrice},\${a.currentBid},"\${a.status}","\${a.winner || ''}","\${a.startTime || ''}","\${a.endTime || ''}"\n`;
              });

              const blob = new Blob([csv], { type: 'text/csv' });
              const url = window.URL.createObjectURL(blob);
              const a = document.createElement('a');
              a.setAttribute('hidden', '');
              a.setAttribute('href', url);
              a.setAttribute('download', `Supplexio_Reverse_Auctions_\${new Date().toISOString().slice(0,10)}.csv`);
              document.body.appendChild(a);
              a.click();
              document.body.removeChild(a);
              showToast('Exported Reverse Auctions report to CSV');
            }

            // TOGGLE AI ASSISTANT POPOVER
            function toggleAiWidget() {
              const popover = document.getElementById('aiPopover');
              popover.classList.toggle('hidden');
            }

            // TOAST NOTIFICATION SYSTEM
            function showToast(message) {
              const container = document.getElementById('toastContainer');
              const toast = document.createElement('div');
              toast.className = 'bg-navy-900 text-white px-4 py-3 rounded-xl shadow-2xl border border-amber-500/50 text-xs font-semibold flex items-center space-x-2 pointer-events-auto transform translate-y-2 opacity-0 transition-all duration-300';
              toast.innerHTML = `
        <span class="w-2 h-2 rounded-full bg-amber-400"></span>
        <span>\${escapeHtml(message)}</span>
      `;

              container.appendChild(toast);
              setTimeout(() => {
                toast.classList.remove('translate-y-2', 'opacity-0');
              }, 10);

              setTimeout(() => {
                toast.classList.add('opacity-0', 'translate-y-2');
                setTimeout(() => toast.remove(), 300);
              }, 3500);
            }

            // HELPER UTILITY FOR HTML ESCAPING
            function escapeHtml(str) {
              if (!str) return '';
              return String(str).replace(/[&<>"']/g, function (m) {
                return {
                  '&': '&amp;',
                  '<': '&lt;',
                  '>': '&gt;',
                  '"': '&quot;',
                  "'": '&#039;'
                }[m];
              });
            }

            // Deep-linking URL triggers for testing in-app modals
            (function checkUrlParams() {
              try {
                const p = new URLSearchParams(window.location.search);
                if (p.has('showCompleteModal')) {
                  const id = parseInt(p.get('showCompleteModal')) || 57;
                  setTimeout(() => completeAuction(id), 300);
                }
                if (p.has('showAwardModal')) {
                  const id = parseInt(p.get('showAwardModal')) || 57;
                  setTimeout(() => awardPOPrompt(id), 300);
                }
              } catch (e) {
                console.error('Error handling URL params', e);
              }
            })();


            // USER PROFILE & PASSWORD MODAL LOGIC
            function openUserProfileModal() {
              const modal = document.getElementById('userProfileModal');
              if (!modal) return;
              const alertBox = document.getElementById('profileModalAlert');
              if (alertBox) alertBox.classList.add('hidden');

              const oldP = document.getElementById('profileModalOldPassword');
              const newP = document.getElementById('profileModalNewPassword');
              const confP = document.getElementById('profileModalConfirmPassword');
              if (oldP) oldP.value = '';
              if (newP) newP.value = '';
              if (confP) confP.value = '';

              modal.classList.remove('hidden');
              modal.classList.add('flex'); modal.style.display = 'flex';
            }

            function closeUserProfileModal() {
              const modal = document.getElementById('userProfileModal');
              if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex'); modal.style.display = 'none';
              }
            }

            function submitUserProfileUpdate() {
              const usernameInput = document.getElementById('profileModalUsername');
              const emailInput = document.getElementById('profileModalEmail');
              const oldP = document.getElementById('profileModalOldPassword');
              const newP = document.getElementById('profileModalNewPassword');
              const confP = document.getElementById('profileModalConfirmPassword');
              const btn = document.getElementById('btnSaveProfile');

              const username = usernameInput ? usernameInput.value.trim() : '';
              const email = emailInput ? emailInput.value.trim() : '';
              const oldPassword = oldP ? oldP.value : '';
              const newPassword = newP ? newP.value : '';
              const confirmPassword = confP ? confP.value : '';

              if (!username) {
                showProfileModalError('Username cannot be empty.');
                return;
              }

              if (newPassword) {
                if (!oldPassword) {
                  showProfileModalError('Please enter current password to verify identity.');
                  return;
                }
                if (newPassword.length < 6) {
                  showProfileModalError('New password must be at least 6 characters.');
                  return;
                }
                if (newPassword !== confirmPassword) {
                  showProfileModalError('New password and confirmation do not match.');
                  return;
                }
              }

              btn.disabled = true;
              btn.innerHTML = '<span>Saving...</span>';

              const ctx = '${pageContext.request.contextPath}';

              $.ajax({
                url: ctx + '/update_profile.jsp',
                type: 'POST',
                dataType: 'json',
                data: {
                  username: username,
                  email: email,
                  oldPassword: oldPassword,
                  newPassword: newPassword,
                  confirmPassword: confirmPassword
                },
                success: function (res) {
                  btn.disabled = false;
                  btn.innerHTML = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg><span>Save Account Changes</span>';

                  if (res && res.success) {
                    const disp = document.getElementById('sidebar-username-display');
                    if (disp) disp.textContent = res.username;
                    const avatar = document.getElementById('sidebar-user-avatar');
                    if (avatar) avatar.textContent = res.username.substring(0, 2).toUpperCase();

                    closeUserProfileModal();

                    if (typeof showToast === 'function') {
                      showToast(res.message || 'Profile updated successfully!', 'success');
                    } else {
                      alert(res.message || 'Profile updated successfully!');
                    }
                  } else {
                    showProfileModalError(res.error || 'Failed to update profile.');
                  }
                },
                error: function (xhr) {
                  btn.disabled = false;
                  btn.innerHTML = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg><span>Save Account Changes</span>';
                  let err = 'Server communication error';
                  try {
                    const r = JSON.parse(xhr.responseText);
                    if (r.error) err = r.error;
                  } catch (e) { }
                  showProfileModalError(err);
                }
              });
            }

            function showProfileModalError(msg) {
              const alertBox = document.getElementById('profileModalAlert');
              if (alertBox) {
                alertBox.className = 'p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold flex items-center gap-2';
                alertBox.innerHTML = '<svg class="w-4 h-4 flex-shrink-0 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg><span>' + msg + '</span>';
                alertBox.classList.remove('hidden');
              }
            }

            // =========================================================================
            // 🌟 1D-RESNET TIMING ORACLE & CREATE AUCTION MODAL ENGINE
            // =========================================================================
            let modalTimingChart = null;
            let modalOracleData = null;
            let modalPricingMode = 'TOTAL'; // 'TOTAL' or 'UNIT'
            let modalCustomHsn = '';
            let modalCustomName = '';
            let modalCustomPrice = 0;
            let modalCustomUnit = 'units';

            function openCreateAuctionModal() {
              const modal = document.getElementById('createAuctionModal');
              if (!modal) return;

              // Pre-fill dates (start = now, end = +7 days)
              const now = new Date();
              const pad = n => n < 10 ? '0' + n : '' + n;
              const toDateStr = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
              const toTimeStr = d => pad(d.getHours()) + ':' + pad(d.getMinutes());

              const sDate = document.getElementById('modalStartDate');
              const sTime = document.getElementById('modalStartTime');
              const eDate = document.getElementById('modalEndDate');
              const eTime = document.getElementById('modalEndTime');

              if (sDate && !sDate.value) sDate.value = toDateStr(now);
              if (sTime && !sTime.value) sTime.value = toTimeStr(now);
              if (eDate && !eDate.value) {
                const later = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
                eDate.value = toDateStr(later);
              }
              if (eTime && !eTime.value) eTime.value = toTimeStr(now);

              if (sDate) sDate.min = toDateStr(now);
              if (eDate) eDate.min = toDateStr(now);

              modal.classList.remove('hidden');
              modal.classList.add('flex');
              modal.style.display = 'flex';
              document.body.classList.add('overflow-hidden');

      if (typeof initCatalogData === 'function') {
        initCatalogData();
      }
              onModalProductChange();
            }

            function closeCreateAuctionModal() {
              const modal = document.getElementById('createAuctionModal');
              if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                modal.style.display = 'none';
                document.body.classList.remove('overflow-hidden');
              }
            }

            function setModalPriceMode(mode) {
              modalPricingMode = mode;
              const totalBtn = document.getElementById('modalModeTotalBtn');
              const unitBtn = document.getElementById('modalModeUnitBtn');
              const priceInput = document.getElementById('modalStartingPrice');
              const hint = document.getElementById('modalCeilingHint');
              const breakdown = document.getElementById('modalCeilingBreakdown');

              if (!priceInput) return;

              const qty = parseFloat(document.getElementById('modalQuantity').value) || 1;
              const unit = modalOracleData ? (modalOracleData.unit || 'units') : modalCustomUnit;

              if (mode === 'TOTAL') {
                if (totalBtn) { totalBtn.className = 'px-2 py-0.5 rounded-md font-bold bg-white text-slate-800 shadow-xs'; }
                if (unitBtn) { unitBtn.className = 'px-2 py-0.5 rounded-md font-medium text-slate-600 hover:text-slate-900'; }
                if (modalOracleData && modalOracleData.total_ceiling_inr) {
                  priceInput.value = modalOracleData.total_ceiling_inr;
                }
                if (hint) hint.textContent = 'Total procurement lot ceiling (' + qty + ' ' + unit + ')';
                if (breakdown && modalOracleData) {
                  breakdown.textContent = '(₹' + Number(modalOracleData.suggested_ceiling_inr).toLocaleString() + ' / ' + unit + ')';
                }
              } else {
                if (unitBtn) { unitBtn.className = 'px-2 py-0.5 rounded-md font-bold bg-white text-slate-800 shadow-xs'; }
                if (totalBtn) { totalBtn.className = 'px-2 py-0.5 rounded-md font-medium text-slate-600 hover:text-slate-900'; }
                if (modalOracleData && modalOracleData.suggested_ceiling_inr) {
                  priceInput.value = modalOracleData.suggested_ceiling_inr;
                }
                if (hint) hint.textContent = `Per-unit reverse auction ceiling`;
                if (breakdown && modalOracleData) {
                  breakdown.textContent = '(Lot: ₹' + Number(modalOracleData.total_ceiling_inr).toLocaleString() + ')';
                }
              }

              priceInput.classList.add('ring-2', 'ring-emerald-500', 'bg-emerald-50');
              setTimeout(() => priceInput.classList.remove('ring-2', 'ring-emerald-500', 'bg-emerald-50'), 800);
            }

            function onModalProductChange() {
              const select = document.getElementById('modalProductId');
              if (!select) return;
              const opt = select.options[select.selectedIndex];
              if (!opt || !opt.value) {
                const card = document.getElementById('modalTimingOracleCard');
                if (card) card.classList.add('hidden');
                return;
              }

      const pName = modalCustomName || opt.getAttribute('data-name') || '';
      const pPrice = modalCustomPrice || parseFloat(opt.getAttribute('data-price')) || 0;
      const pUnit = modalCustomUnit || opt.getAttribute('data-unit') || 'units';
      const pHsn = (modalCustomHsn && modalCustomHsn !== 'General') ? modalCustomHsn : (opt.getAttribute('data-hsn') || '721420');

              modalCustomName = pName;
              modalCustomPrice = pPrice;
              modalCustomUnit = pUnit;
              modalCustomHsn = pHsn;

      // Update selected product card banner
      const scard = document.getElementById('selectedProductCard');
      const stype = document.getElementById('selectedProductTypeBadge');
      const sname = document.getElementById('selectedProductName');
      const shsn = document.getElementById('selectedProductHsn');
      const scat = document.getElementById('selectedProductCategory');
      const sprice = document.getElementById('selectedProductPrice');
      const searchInp = document.getElementById('modalBaciSearchInput');
      const clearBtn = document.getElementById('clearProductBtn');

      if (scard) scard.classList.remove('hidden');
      if (stype) {
        stype.textContent = (selectedCommodityObj && selectedCommodityObj.catalog_type === 'Global BACI') ? 'Global BACI' : 'Enterprise';
        stype.className = stype.textContent === 'Enterprise' ? 'px-2 py-0.5 text-[10px] font-bold rounded-md bg-sky-600 text-white uppercase tracking-wider' : 'px-2 py-0.5 text-[10px] font-bold rounded-md bg-amber-600 text-white uppercase tracking-wider';
      }
      if (sname) sname.textContent = pName;
      if (shsn) shsn.textContent = 'HSN: ' + (pHsn || 'General');
      if (scat) scat.textContent = opt.getAttribute('data-category') || 'Enterprise';
      if (sprice) sprice.textContent = '₹' + Number(pPrice).toLocaleString() + ' / ' + pUnit;
      if (searchInp && !searchInp.value) searchInp.value = pName + ' (HSN: ' + (pHsn || 'General') + ')';
      if (clearBtn) clearBtn.classList.remove('hidden');

              const unitBadge = document.getElementById('modalQuantityUnitBadge');
              if (unitBadge) unitBadge.textContent = pUnit;

              const qtyInput = document.getElementById('modalQuantity');
              const qty = parseFloat(qtyInput ? qtyInput.value : 0) || 0;

              if (qty > 0) {
                fetchModalTimingOracle(opt.value, pName, pHsn, qty);
              } else {
                const priceInput = document.getElementById('modalStartingPrice');
                if (priceInput && pPrice > 0 && !priceInput.value) {
                  priceInput.value = pPrice;
                }
                const card = document.getElementById('modalTimingOracleCard');
                if (card) card.classList.add('hidden');
              }
            }

            function onModalQuantityInput() {
              const select = document.getElementById('modalProductId');
              const pId = select ? select.value : '';
              const qty = parseFloat(document.getElementById('modalQuantity').value) || 0;

              if ((pId || modalCustomHsn) && qty > 0) {
                fetchModalTimingOracle(pId, modalCustomName, modalCustomHsn, qty);
              } else {
                const card = document.getElementById('modalTimingOracleCard');
                if (card) card.classList.add('hidden');
              }
            }

            function fetchModalTimingOracle(productId, productName, hsnCode, quantity) {
              const card = document.getElementById('modalTimingOracleCard');
              const headline = document.getElementById('modalOracleHeadline');
              const advisory = document.getElementById('modalOracleAdvisory');

              if (card) card.classList.remove('hidden');
              if (headline) headline.textContent = "Consulting 1D-ResNet neural inference & BACI trade lakehouse...";
              if (advisory) advisory.textContent = 'Analyzing multi-step bilateral trade momentum for ' + (productName || 'selected commodity') + ' (' + quantity + ' units)...';

              let url = 'http://localhost:5000/api/timing-oracle?';
              if (productId) url += 'product_id=' + encodeURIComponent(productId) + '&';
              if (productName) url += 'product_name=' + encodeURIComponent(productName) + '&';
              if (hsnCode) url += 'hsn=' + encodeURIComponent(hsnCode) + '&';
              url += 'quantity=' + encodeURIComponent(quantity);

              fetch(url)
                .then(r => r.json())
                .then(data => {
                  if (data.status === 'success') {
                    modalOracleData = data;
                    renderTimingOracleUI(data);
                  }
                })
                .catch(err => {
                  console.error("Timing Oracle error:", err);
                  if (headline) headline.textContent = "1D-ResNet Trade Benchmark Available";
                  if (advisory) advisory.textContent = 'Real-time commodity baseline: ₹' + Number(modalCustomPrice).toLocaleString() + ' / ' + modalCustomUnit + '. Competitive bidding ceiling active.';
                });
            }

            function renderTimingOracleUI(data) {
              const timing = data.timing_oracle || {};
              const unit = data.unit || 'units';
              const qty = data.quantity || 1;

              const header = document.getElementById('modalOracleHeader');
              const badge = document.getElementById('modalOracleBadge');
              const headline = document.getElementById('modalOracleHeadline');
              const advisory = document.getElementById('modalOracleAdvisory');

              const spotPrice = document.getElementById('modalOracleSpotPrice');
              const predPrice = document.getElementById('modalOraclePredPrice');
              const savingsLabel = document.getElementById('modalOracleSavingsLabel');
              const savingsVal = document.getElementById('modalOracleSavingsVal');
              const winEl = document.getElementById('modalOracleWindow');
              const confEl = document.getElementById('modalOracleConfidence');
              const actionBtns = document.getElementById('modalOracleActionButtons');

              if (spotPrice) spotPrice.textContent = '₹' + Number(data.benchmark_price_inr).toLocaleString() + '/' + unit;
              if (predPrice) {
                const pred30 = timing.price_horizons ? timing.price_horizons.pred_30d_inr : data.suggested_ceiling_inr;
                predPrice.textContent = '₹' + Number(pred30).toLocaleString() + '/' + unit + ' (' + (timing.predicted_price_change_pct || data.trend_pct) + ')';
                predPrice.className = 'text-xs font-mono font-bold ' + (timing.badge_color === 'rose' ? 'text-rose-600' : (timing.badge_color === 'emerald' ? 'text-emerald-600' : 'text-sky-600'));
              }
              if (savingsLabel && timing.savings_label) savingsLabel.textContent = timing.savings_label;
              if (savingsVal && timing.savings_amount !== undefined) {
                savingsVal.textContent = '~₹' + Number(timing.savings_amount).toLocaleString();
                savingsVal.className = 'text-xs font-mono font-bold ' + (timing.badge_color === 'rose' ? 'text-amber-600' : 'text-emerald-600');
              }
              if (winEl && timing.optimal_window) winEl.textContent = timing.optimal_window;
              if (confEl && timing.confidence_score) confEl.textContent = 'Confidence: ' + timing.confidence_score + '% (1D-ResNet)';

              if (headline) headline.textContent = timing.headline || "1D-ResNet Market Advisory";
              if (advisory) advisory.textContent = timing.strategic_advisory || data.ai_recommendation;

              if (timing.verdict === 'DELAY_AND_SPOT') {
                if (header) header.className = "px-4 py-3 flex items-center justify-between text-xs font-bold text-white bg-gradient-to-r from-emerald-600 to-teal-700 transition-colors";
                if (badge) {
                  badge.className = "px-2.5 py-0.5 rounded-full text-[10px] font-mono tracking-wider uppercase font-bold bg-white/20 text-emerald-100 border border-emerald-300/40";
                  badge.textContent = timing.badge_text || "DELAY ADVISORY: SPOT BUFFER RECOMMENDED";
                }
              } else if (timing.verdict === 'BUY_NOW_LOCK_CONTRACT') {
                if (header) header.className = "px-4 py-3 flex items-center justify-between text-xs font-bold text-white bg-gradient-to-r from-rose-600 to-amber-700 transition-colors";
                if (badge) {
                  badge.className = "px-2.5 py-0.5 rounded-full text-[10px] font-mono tracking-wider uppercase font-bold bg-white/20 text-rose-100 border border-rose-300/40";
                  badge.textContent = timing.badge_text || "SURGE HEDGE ADVISORY: BUY NOW";
                }
              } else {
                if (header) header.className = "px-4 py-3 flex items-center justify-between text-xs font-bold text-white bg-gradient-to-r from-sky-600 to-indigo-700 transition-colors";
                if (badge) {
                  badge.className = "px-2.5 py-0.5 rounded-full text-[10px] font-mono tracking-wider uppercase font-bold bg-white/20 text-sky-100 border border-sky-300/40";
                  badge.textContent = timing.badge_text || "OPTIMAL TIMING: STABLE CORRIDOR";
                }
              }

              if (actionBtns) {
                let btnHtml = '';
                if (timing.verdict === 'DELAY_AND_SPOT') {
                  btnHtml += '<button type="button" onclick="applySpotBufferAuction(' + (timing.spot_quantity || 10) + ', ' + (timing.suggested_buffer_days || 15) + ')" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg text-xs font-bold shadow-xs transition flex items-center gap-1.5"><svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg><span>Run ' + (timing.suggested_buffer_days || 15) + '-Day Buffer Spot Auction (' + (timing.spot_quantity || 10) + ' ' + unit + ')</span></button><button type="button" onclick="setModalPriceMode(\'' + modalPricingMode + '\')" class="px-3 py-1.5 border border-slate-300 hover:bg-slate-100 text-slate-700 rounded-lg text-xs font-semibold transition">Keep Full Volume (' + qty + ' ' + unit + ')</button>';
                } else if (timing.verdict === 'BUY_NOW_LOCK_CONTRACT') {
                  btnHtml += '<button type="button" onclick="applySurgeHedgeAuction(' + (timing.suggested_buffer_days || 180) + ')" class="px-3 py-1.5 bg-rose-600 hover:bg-rose-500 text-white rounded-lg text-xs font-bold shadow-xs transition flex items-center gap-1.5"><svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg><span>Lock Long-Term Contract Volume Immediately</span></button>';
                } else {
                  btnHtml += '<button type="button" onclick="setModalPriceMode(\'' + modalPricingMode + '\')" class="px-3 py-1.5 bg-sky-600 hover:bg-sky-500 text-white rounded-lg text-xs font-bold shadow-xs transition flex items-center gap-1.5"><svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg><span>Apply AI Recommended Ceiling (₹' + Number(data.total_ceiling_inr).toLocaleString() + ')</span></button>';
                }
                actionBtns.innerHTML = btnHtml;
              }

              setModalPriceMode(modalPricingMode);

              renderTimingSparkline(
                timing.sparkline_unit_prices || data.sparkline_data,
                timing.sparkline_labels || data.sparkline_months,
                data.trend
              );
            }

            function renderTimingSparkline(dataPoints, labels, trend) {
              const canvas = document.getElementById('modalTimingSparklineChart');
              if (!canvas) return;
              const ctx = canvas.getContext('2d');
              if (modalTimingChart) modalTimingChart.destroy();

              const isSurge = trend === 'SURGE';
              const isDecline = trend === 'DECLINE';
              const strokeColor = isSurge ? '#e11d48' : (isDecline ? '#059669' : '#0284c7');
              const fillColor = isSurge ? 'rgba(225, 29, 72, 0.12)' : (isDecline ? 'rgba(5, 150, 105, 0.12)' : 'rgba(2, 132, 199, 0.12)');

              modalTimingChart = new Chart(ctx, {
                type: 'line',
                data: {
                  labels: labels,
                  datasets: [{
                    data: dataPoints,
                    borderColor: strokeColor,
                    backgroundColor: fillColor,
                    fill: true,
                    tension: 0.35,
                    borderWidth: 2,
                    pointRadius: 3,
                    pointBackgroundColor: strokeColor,
                  }]
                },
                options: {
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { display: false },
                    tooltip: {
                      callbacks: {
                        label: function(ctx) { return ' Price: ₹' + Number(ctx.raw).toLocaleString(); }
                      }
                    }
                  },
                  scales: {
                    x: {
                      grid: { display: false },
                      ticks: { font: { size: 9, family: 'JetBrains Mono' }, color: '#64748b' }
                    },
                    y: {
                      grid: { color: 'rgba(226, 232, 240, 0.6)' },
                      ticks: {
                        font: { size: 9, family: 'JetBrains Mono' },
                        color: '#64748b',
                        callback: function(v) { return '₹' + (v >= 1000 ? Math.round(v/1000) + 'k' : v); }
                      }
                    }
                  }
                }
              });
            }

            function applySpotBufferAuction(spotQty, bufferDays) {
              const qtyInput = document.getElementById('modalQuantity');
              if (qtyInput) {
                qtyInput.value = spotQty;
                qtyInput.classList.add('ring-2', 'ring-emerald-500', 'bg-emerald-50');
                setTimeout(() => qtyInput.classList.remove('ring-2', 'ring-emerald-500', 'bg-emerald-50'), 1200);
              }

              const sDateInput = document.getElementById('modalStartDate');
              const eDateInput = document.getElementById('modalEndDate');
              if (sDateInput && eDateInput && sDateInput.value) {
                const start = new Date(sDateInput.value);
                const end = new Date(start.getTime() + (bufferDays || 15) * 24 * 60 * 60 * 1000);
                const pad = n => n < 10 ? '0' + n : '' + n;
                eDateInput.value = end.getFullYear() + '-' + pad(end.getMonth() + 1) + '-' + pad(end.getDate());
              }

              onModalQuantityInput();
              showToast('⚡ Adjusted to ' + spotQty + ' buffer units over ' + bufferDays + ' days as advised by 1D-ResNet.');
            }

            function applySurgeHedgeAuction(days) {
              const sDateInput = document.getElementById('modalStartDate');
              const eDateInput = document.getElementById('modalEndDate');
              if (sDateInput && eDateInput && sDateInput.value) {
                const start = new Date(sDateInput.value);
                const end = new Date(start.getTime() + (days || 180) * 24 * 60 * 60 * 1000);
                const pad = n => n < 10 ? '0' + n : '' + n;
                eDateInput.value = end.getFullYear() + '-' + pad(end.getMonth() + 1) + '-' + pad(end.getDate());
              }
              showToast('🛡 Extended contract horizon to ' + days + ' days to lock in price hedge.');
            }

            function validateCreateModalForm() {
              const pId = document.getElementById('modalProductId').value;
              const qty = parseFloat(document.getElementById('modalQuantity').value) || 0;
              const price = parseFloat(document.getElementById('modalStartingPrice').value) || 0;
              const sDate = document.getElementById('modalStartDate').value;
              const sTime = document.getElementById('modalStartTime').value;
              const eDate = document.getElementById('modalEndDate').value;
              const eTime = document.getElementById('modalEndTime').value;

              if (!pId) { alert('Please select a product or commodity.'); return false; }
              if (qty <= 0) { alert('Please enter a valid required quantity.'); return false; }
              if (price <= 0) { alert('Please enter a valid starting ceiling price.'); return false; }
              if (!sDate || !sTime || !eDate || !eTime) { alert('Please fill in complete schedule dates and times.'); return false; }

              const startDT = new Date(sDate + 'T' + sTime);
              const endDT = new Date(eDate + 'T' + eTime);
              if (endDT <= startDT) {
                alert('End date/time must be strictly after start date/time.');
                return false;
              }
              return true;
            }

            // =========================================================================
            // 🌐 COMPREHENSIVE PRODUCT & BACI COMMODITY COMBOSPEC (5,492 PRODUCTS)
            // =========================================================================
            let catalogCache = [];
            let enterpriseCache = [];
            let globalCache = [];
            let activeCategoryFilter = 'all';
            let baciDebounceTimer = null;
            let selectedCommodityObj = null;

            function initCatalogData() {
              const select = document.getElementById('modalProductId');
              enterpriseCache = [];
              if (select) {
                for (let i = 0; i < select.options.length; i++) {
                  const opt = select.options[i];
                  if (!opt.value) continue;
                  const name = opt.getAttribute('data-name') || opt.textContent.split('(HSN:')[0].trim();
                  const hsn = opt.getAttribute('data-hsn') || 'General';
                  const price = parseFloat(opt.getAttribute('data-price')) || 0;
                  const unit = opt.getAttribute('data-unit') || 'units';
                  const cat = opt.getAttribute('data-category') || 'Enterprise';
                  const isLow = opt.textContent.includes('Low Stock');
                  enterpriseCache.push({
                    id: opt.value,
                    name: name,
                    hsn_code: hsn,
                    base_price: price,
                    unit: unit,
                    category: cat,
                    catalog_type: 'Enterprise',
                    is_low_stock: isLow
                  });
                }
              }

              fetch('http://localhost:5000/api/all-catalog-products')
                .then(r => r.json())
                .then(data => {
                  if (data && data.global_trade_products) {
                    globalCache = data.global_trade_products;
                    if (data.enterprise_products && data.enterprise_products.length > 0) {
                      enterpriseCache = data.enterprise_products;
                    }
                  }
                  catalogCache = [...enterpriseCache, ...globalCache];
                  const badge = document.getElementById('productCountBadge');
                  if (badge) {
                    badge.innerHTML = '<svg class="w-3 h-3 text-sky-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg> 5,492 Commodities Available (' + enterpriseCache.length + ' Enterprise + 5,384 BACI)';
                  }
                })
                .catch(() => {
                  catalogCache = [...enterpriseCache];
                });
            }

            function toggleProductDropdown(e) {
              if (e) e.stopPropagation();
              const resultsBox = document.getElementById('modalBaciSearchResults');
              if (resultsBox && !resultsBox.classList.contains('hidden')) {
                closeProductDropdown();
              } else {
                openProductDropdown(true);
              }
            }

            function openProductDropdown(forceResetSearch) {
              const resultsBox = document.getElementById('modalBaciSearchResults');
              const searchInput = document.getElementById('modalBaciSearchInput');
              const chevron = document.getElementById('comboboxChevron');
              if (!resultsBox) return;

              if (forceResetSearch && searchInput) {
                searchInput.value = '';
                const clearBtn = document.getElementById('clearProductBtn');
                if (clearBtn) clearBtn.classList.add('hidden');
              }

              resultsBox.classList.remove('hidden');
              if (chevron) chevron.classList.add('rotate-180');
              
              const query = searchInput ? searchInput.value.trim() : '';
              renderCatalogDropdown(query, activeCategoryFilter);
              if (searchInput) searchInput.focus();
            }

            function closeProductDropdown() {
              const resultsBox = document.getElementById('modalBaciSearchResults');
              const chevron = document.getElementById('comboboxChevron');
              if (resultsBox) resultsBox.classList.add('hidden');
              if (chevron) chevron.classList.remove('rotate-180');
            }

            function filterCatalogCategory(cat) {
              activeCategoryFilter = cat;
              const pills = document.querySelectorAll('.cat-pill');
              pills.forEach(p => {
                p.className = 'cat-pill px-2.5 py-1 rounded-lg font-semibold bg-white text-slate-700 hover:bg-slate-100 border border-slate-200 whitespace-nowrap transition';
              });
              const activeBtn = document.getElementById('catBtn_' + (cat === 'all' ? 'all' : cat === 'Global BACI' ? 'Global' : cat));
              if (activeBtn) {
                activeBtn.className = 'cat-pill active px-2.5 py-1 rounded-lg font-bold bg-slate-900 text-white whitespace-nowrap shadow-xs';
              }
              const searchInput = document.getElementById('modalBaciSearchInput');
              const query = searchInput ? searchInput.value.trim() : '';
              renderCatalogDropdown(query, activeCategoryFilter);
            }

            function renderCatalogDropdown(query, catFilter) {
              const listContainer = document.getElementById('catalogListContainer');
              const statusCount = document.getElementById('catalogStatusCount');
              if (!listContainer) return;

              let items = [];
              const qLower = (query || '').toLowerCase();

              const pool = (catalogCache && catalogCache.length > 0) ? catalogCache : enterpriseCache;

              if (qLower) {
                items = pool.filter(it => 
                  (it.name && it.name.toLowerCase().includes(qLower)) ||
                  (it.hsn_code && String(it.hsn_code).toLowerCase().includes(qLower)) ||
                  (it.category && it.category.toLowerCase().includes(qLower))
                );
              } else {
                items = pool;
              }

              if (catFilter && catFilter !== 'all') {
                if (catFilter === 'Enterprise') {
                  items = items.filter(it => it.catalog_type === 'Enterprise');
                } else if (catFilter === 'Global BACI') {
                  items = items.filter(it => it.catalog_type !== 'Enterprise');
                } else {
                  items = items.filter(it => (it.category || '').toLowerCase().includes(catFilter.toLowerCase()));
                }
              }

              if (statusCount) {
                statusCount.textContent = items.length + ' matches';
              }

              if (items.length === 0) {
                listContainer.innerHTML = '<div class="p-8 text-center text-slate-400 text-xs font-mono"><p class="text-base mb-1">🔍 No commodities found</p><p class="text-[11px] text-slate-500">Try searching another HSN code or commodity title.</p></div>';
                return;
              }

              const entItems = items.filter(it => it.catalog_type === 'Enterprise').slice(0, 50);
              const baciItems = items.filter(it => it.catalog_type !== 'Enterprise').slice(0, 75);

              let html = '';

              if (entItems.length > 0) {
                html += '<div class="px-3 py-1.5 bg-slate-100 text-[10px] font-bold text-slate-600 uppercase tracking-wider flex items-center justify-between sticky top-0 z-10"><span>🏭 Enterprise Catalog (' + entItems.length + ' listed)</span><span class="text-sky-700 font-semibold font-mono">Immediate Stock Available</span></div>';
                entItems.forEach(item => {
                  const safeName = (item.name || '').replace(/'/g, "\\'").replace(/"/g, '&quot;');
                  const safeCat = (item.category || '').replace(/'/g, "\\'");
                  const isSelected = selectedCommodityObj && (selectedCommodityObj.id === item.id || selectedCommodityObj.hsn_code === item.hsn_code);
                  html += '<div onclick="selectCommodity(' + item.id + ', \'' + item.hsn_code + '\', \'' + safeName + '\', ' + (item.base_price || 0) + ', \'' + (item.unit || 'units') + '\', \'' + safeCat + '\', \'Enterprise\')" class="p-2.5 hover:bg-sky-50 cursor-pointer transition flex items-center justify-between text-xs group ' + (isSelected ? 'bg-sky-50/80 font-bold border-l-4 border-sky-600' : '') + '"><div><div class="font-bold text-slate-900 group-hover:text-sky-700 flex items-center gap-1.5"><span>' + item.name + '</span>' + (item.is_low_stock ? '<span class="text-[9px] font-bold px-1.5 py-0.2 bg-rose-100 text-rose-700 rounded-full">⚠ Low Stock</span>' : '') + '</div><div class="text-[10px] text-slate-500 font-mono mt-0.5"><span class="bg-slate-100 px-1 py-0.2 rounded font-semibold text-slate-700">HSN: ' + item.hsn_code + '</span> • ' + (item.category || 'Enterprise') + '</div></div><div class="text-right font-mono"><div class="font-bold text-slate-900 group-hover:text-sky-700">₹' + Number(item.base_price || 0).toLocaleString() + '</div><div class="text-[10px] text-slate-400">/' + (item.unit || 'unit') + '</div></div></div>';
                });
              }

              if (baciItems.length > 0) {
                html += '<div class="px-3 py-1.5 bg-sky-50 text-[10px] font-bold text-sky-800 uppercase tracking-wider flex items-center justify-between sticky top-0 z-10 border-t border-sky-100"><span>🌐 Global BACI Trade Lakehouse (' + baciItems.length + ' listed)</span><span class="text-sky-600 font-mono">5,384 Sourcing Items</span></div>';
                baciItems.forEach(item => {
                  const safeName = (item.name || '').replace(/'/g, "\\'").replace(/"/g, '&quot;');
                  const safeCat = (item.category || '').replace(/'/g, "\\'");
                  const isSelected = selectedCommodityObj && selectedCommodityObj.hsn_code === item.hsn_code;
                  html += '<div onclick="selectCommodity(' + (item.id || 0) + ', \'' + item.hsn_code + '\', \'' + safeName + '\', ' + (item.base_price || 2500) + ', \'' + (item.unit || 'units') + '\', \'' + safeCat + '\', \'Global BACI\')" class="p-2.5 hover:bg-amber-50/70 cursor-pointer transition flex items-center justify-between text-xs group ' + (isSelected ? 'bg-amber-50 font-bold border-l-4 border-amber-500' : '') + '"><div><div class="font-bold text-slate-900 group-hover:text-amber-800 flex items-center gap-1.5"><span>' + item.name + '</span><span class="text-[9px] font-bold px-1.5 py-0.2 bg-sky-100 text-sky-700 rounded-full font-mono">BACI</span></div><div class="text-[10px] text-slate-500 font-mono mt-0.5"><span class="bg-amber-100 text-amber-900 px-1 py-0.2 rounded font-semibold">HSN: ' + item.hsn_code + '</span> • ' + (item.category || 'Commodity') + '</div></div><div class="text-right font-mono"><div class="font-bold text-amber-700 group-hover:text-amber-900">₹' + Number(item.base_price || 0).toLocaleString() + '</div><div class="text-[10px] text-slate-400">/' + (item.unit || 'units') + '</div></div></div>';
                });
              }

              listContainer.innerHTML = html;
            }

            function selectCommodity(id, hsn, name, price, unit, category, catalogType) {
              selectedCommodityObj = { id: id, hsn_code: hsn, name: name, base_price: price, unit: unit, category: category, catalog_type: catalogType };
              
              closeProductDropdown();

              const searchInput = document.getElementById('modalBaciSearchInput');
              const clearBtn = document.getElementById('clearProductBtn');
              if (searchInput) searchInput.value = name + ' (HSN: ' + hsn + ')';
              if (clearBtn) clearBtn.classList.remove('hidden');

              const card = document.getElementById('selectedProductCard');
              const typeBadge = document.getElementById('selectedProductTypeBadge');
              const nameEl = document.getElementById('selectedProductName');
              const hsnEl = document.getElementById('selectedProductHsn');
              const catEl = document.getElementById('selectedProductCategory');
              const priceEl = document.getElementById('selectedProductPrice');

              if (card) card.classList.remove('hidden');
              if (typeBadge) {
                typeBadge.textContent = catalogType;
                typeBadge.className = catalogType === 'Enterprise' ? 'px-2 py-0.5 text-[10px] font-bold rounded-md bg-sky-600 text-white uppercase tracking-wider' : 'px-2 py-0.5 text-[10px] font-bold rounded-md bg-amber-600 text-white uppercase tracking-wider';
              }
              if (nameEl) nameEl.textContent = name;
              if (hsnEl) hsnEl.textContent = 'HSN: ' + hsn;
              if (catEl) catEl.textContent = category || 'Commodity';
              if (priceEl) priceEl.textContent = '₹' + Number(price).toLocaleString() + ' / ' + unit;

              const unitBadge = document.getElementById('modalQuantityUnitBadge');
              if (unitBadge) unitBadge.textContent = unit;

              const select = document.getElementById('modalProductId');
              if (catalogType === 'Enterprise' && id > 0) {
                if (select) select.value = id;
                onModalProductChange();
              } else {
                fetch('http://localhost:5000/api/ensure-product', {
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  body: JSON.stringify({
                    name: name,
                    hsn_code: hsn,
                    category: category,
                    base_price: price,
                    unit: unit
                  })
                })
                .then(r => r.json())
                .then(res => {
                  if (res.status === 'success' && res.product_id) {
                    const actualId = res.product_id;
                    selectedCommodityObj.id = actualId;
                    if (select) {
                      let opt = select.querySelector('option[value="' + actualId + '"]');
                      if (!opt) {
                        opt = new Option(name + ' (HSN: ' + hsn + ')', actualId, true, true);
                        opt.setAttribute('data-name', name);
                        opt.setAttribute('data-price', price);
                        opt.setAttribute('data-unit', unit);
                        opt.setAttribute('data-hsn', hsn);
                        opt.setAttribute('data-category', category);
                        select.add(opt);
                      }
                      select.value = actualId;
                    }
                    onModalProductChange();
                  }
                })
                .catch(err => {
                  console.warn('Ensure product warning:', err);
                  onModalProductChange();
                });
              }

              const qtyInput = document.getElementById('modalQuantity');
              const qty = parseFloat(qtyInput ? qtyInput.value : 0) || 0;
              if (qty > 0) {
                const ceilingInput = document.getElementById('modalStartingPrice');
                if (ceilingInput && price > 0) {
                  ceilingInput.value = Math.round(qty * price);
                }
                fetchModalTimingOracle(select ? select.value : '', name, hsn, qty);
                fetchSmartBasketRecommendations(select ? select.value : '', hsn, qty);
              } else if (qtyInput) {
                qtyInput.focus();
                qtyInput.classList.add('ring-2', 'ring-sky-500');
                setTimeout(() => qtyInput.classList.remove('ring-2', 'ring-sky-500'), 1000);
              }
            }

            function clearSelectedProduct(e) {
              if (e) e.stopPropagation();
              selectedCommodityObj = null;
              modalCustomHsn = '';
              modalCustomName = '';
              modalCustomPrice = 0;
              modalCustomUnit = 'units';

              const searchInput = document.getElementById('modalBaciSearchInput');
              const clearBtn = document.getElementById('clearProductBtn');
              const card = document.getElementById('selectedProductCard');
              const select = document.getElementById('modalProductId');

              if (searchInput) searchInput.value = '';
              if (clearBtn) clearBtn.classList.add('hidden');
              if (card) card.classList.add('hidden');
              if (select) select.value = '';

              const oracleCard = document.getElementById('modalTimingOracleCard');
              if (oracleCard) oracleCard.classList.add('hidden');
              const basketCard = document.getElementById('modalSmartBasketCard');
              if (basketCard) basketCard.classList.add('hidden');

              openProductDropdown(true);
            }

            // =========================================================================
            // 🌐 PHASE 2: TRUE LANDED COST (LDP) NORMALIZER & RE-RANKING JAVASCRIPT
            // =========================================================================
            let isLdpActive = false;
            let currentDrawerAuction = null;
            let normalizedLdpData = null;

            function toggleLdpNormalizer(active) {
              isLdpActive = active;
              if (!currentDrawerAuction) {
                if (auctionsData.length > 0) {
                  currentDrawerAuction = auctionsData[0];
                  activeDrawerId = currentDrawerAuction.id;
                } else {
                  return;
                }
              }

              const header = document.getElementById('drawerBidAmountHeader');
              if (header) {
                header.textContent = active ? 'True Landed Cost (LDP)' : 'Bid Amount & Overhead';
              }

              if (active) {
                fetchAndRenderLdpTimeline(currentDrawerAuction);
              } else {
                const alert = document.getElementById('drawerLdpNarrativeAlert');
                if (alert) alert.classList.add('hidden');
                renderRawBidTimeline(currentDrawerAuction);
              }
            }

            function fetchAndRenderLdpTimeline(auctionItem) {
              if (!auctionItem) return;
              const timeline = document.getElementById('drawerBidTimeline');
              const alert = document.getElementById('drawerLdpNarrativeAlert');
              if (!timeline) return;

              const bids = Array.isArray(auctionItem.bids) ? auctionItem.bids : [];
              if (bids.length === 0) {
                timeline.innerHTML = '<div class="p-6 text-xs text-center text-slate-400">No supplier bids recorded yet.</div>';
                return;
              }

              const payloadBids = bids.map((b, idx) => ({
                id: b.id || idx,
                supplier_id: b.supplierId || idx,
                supplier_name: b.supplier || b.supplierName || 'Supplier',
                country_code: b.countryCode || b.country || (idx === 0 && bids.length > 1 ? 'CHN' : 'IND'),
                amount: b.amount || 0,
                time: b.time || 'Logged'
              }));

              fetch('http://localhost:5000/api/normalize-bids-ldp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                  hsn_code: auctionItem.hsnCode || '721420',
                  bids: payloadBids
                })
              })
              .then(r => r.json())
              .then(res => {
                if (res.status === 'success') {
                  normalizedLdpData = res;
                  if (alert && res.re_ranked) {
                    alert.innerHTML = '<div class="font-bold flex items-center gap-1.5 mb-1"><span class="text-amber-400">🏆 LDP Re-Ranking Triggered:</span> Domestic Supplier Takes #1!</div>' + res.comparison_narrative;
                    alert.classList.remove('hidden');
                  } else if (alert) {
                    alert.innerHTML = '<div class="font-bold flex items-center gap-1.5 mb-1"><span class="text-emerald-400">✓ Cost Parity Verified:</span> ' + res.winner_ldp.supplier_name + ' maintains lowest landed cost.</div>' + res.comparison_narrative;
                    alert.classList.remove('hidden');
                  }

                  timeline.innerHTML = '';
                  res.bids_by_ldp.forEach((bid, idx) => {
                    const div = document.createElement('div');
                    div.className = 'px-4 py-3 flex items-center justify-between text-xs hover:bg-slate-50 transition-colors ' + (idx === 0 ? 'bg-emerald-50/50 border-l-4 border-emerald-500' : '');
                    
                    const flag = bid.supplier_country === 'IND' ? '🇮🇳' : (bid.supplier_country === 'CHN' ? '🇨🇳' : (bid.supplier_country === 'DEU' ? '🇩🇪' : (bid.supplier_country === 'ARE' ? '🇦🇪' : '🌐')));
                    const countryBadge = bid.is_domestic 
                      ? '<span class="text-[9px] font-bold text-emerald-700 bg-emerald-100 px-1.5 py-0.5 rounded border border-emerald-200">' + flag + ' Domestic</span>'
                      : '<span class="text-[9px] font-bold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded border border-amber-200">' + flag + ' ' + bid.supplier_country + '</span>';

                    const rankBadge = idx === 0
                      ? '<span class="text-[9px] font-extrabold text-emerald-700 uppercase bg-emerald-100 px-1.5 py-0.5 rounded shadow-xs">🏆 1st (LDP Winner)</span>'
                      : (bid.rank_worsened ? '<span class="text-[9px] font-semibold text-rose-600 bg-rose-50 px-1.5 py-0.5 rounded">Rank ' + bid.ldp_rank + ' (Raw was #' + bid.raw_rank + ')</span>' : '<span class="text-[9px] text-slate-500 font-mono">#' + bid.ldp_rank + '</span>');

                    div.innerHTML = 
                      '<div>' +
                        '<div class="flex items-center space-x-1.5">' +
                          '<p class="font-bold text-slate-800">' + escapeHtml(bid.supplier_name) + '</p>' +
                          countryBadge +
                        '</div>' +
                        '<div class="flex items-center space-x-2 text-[10px] text-slate-400 font-mono-tabular mt-0.5">' +
                          '<span>' + bid.time + '</span>' +
                          '<span>•</span>' +
                          '<span>Raw: ' + formatINR(bid.raw_bid_amount) + '</span>' +
                        '</div>' +
                        (bid.is_domestic 
                          ? '<p class="text-[10px] text-emerald-600 font-medium mt-0.5">✓ 0% Customs Duty • Local Logistics (3.5%)</p>'
                          : '<p class="text-[10px] text-rose-600 font-medium mt-0.5">⚠️ +' + formatINR(bid.total_hidden_overhead) + ' Overhead (Tariff ' + bid.customs_tariff_pct + '%, Freight ' + bid.freight_pct + '%, Carbon ' + bid.risk_buffer_pct + '%)</p>'
                        ) +
                      '</div>' +
                      '<div class="text-right">' +
                        '<p class="font-mono-tabular font-extrabold text-sm ' + (idx === 0 ? 'text-emerald-700' : 'text-slate-900') + '">' + formatINR(bid.true_landed_cost) + '</p>' +
                        '<div class="mt-0.5">' + rankBadge + '</div>' +
                      '</div>';
                    timeline.appendChild(div);
                  });
                }
              })
              .catch(err => {
                console.error('LDP normalization error:', err);
                renderRawBidTimeline(auctionItem);
              });
            }

            function renderRawBidTimeline(auctionItem) {
              const timeline = document.getElementById('drawerBidTimeline');
              if (!timeline) return;
              timeline.innerHTML = '';
              const bids = Array.isArray(auctionItem.bids) ? auctionItem.bids : [];
              const countEl = document.getElementById('bidCountBadge');
              if (countEl) countEl.textContent = bids.length + ' bids logged';

              if (bids.length === 0) {
                timeline.innerHTML = '<div class="p-6 text-xs text-center text-slate-400">No supplier bids recorded yet.</div>';
              } else {
                bids.forEach((bid, idx) => {
                  const div = document.createElement('div');
                  div.className = 'px-4 py-3 flex items-center justify-between text-xs hover:bg-slate-50 transition-colors';
                  const flag = bid.countryCode === 'CHN' ? '🇨🇳' : (bid.countryCode === 'DEU' ? '🇩🇪' : '🇮🇳');
                  div.innerHTML = 
                    '<div>' +
                      '<p class="font-bold text-slate-800">' + escapeHtml(bid.supplier || bid.supplierName || 'Verified Supplier') + ' <span class="text-[10px] text-slate-400">' + flag + '</span></p>' +
                      '<p class="text-[10px] text-slate-400 font-mono-tabular mt-0.5">' + (bid.time || 'Logged') + '</p>' +
                    '</div>' +
                    '<div class="text-right">' +
                      '<p class="font-mono-tabular font-bold text-slate-900">' + formatINR(bid.amount) + '</p>' +
                      (idx === 0 ? '<span class="text-[9px] font-bold text-emerald-600 uppercase bg-emerald-50 px-1 rounded">Current Lowest</span>' : '') +
                    '</div>';
                  timeline.appendChild(div);
                });
              }
            }

            function simulateOverseasVsDomesticBids() {
              if (!currentDrawerAuction) {
                if (auctionsData.length > 0) {
                  currentDrawerAuction = auctionsData[0];
                  openDrawer(currentDrawerAuction.id);
                } else {
                  return;
                }
              }
              openDrawer(currentDrawerAuction.id);

              const base = currentDrawerAuction.currentBid || 1000;
              const overseasBid = Math.round(base * 0.90);
              const domesticBid = Math.round(base * 0.98);

              currentDrawerAuction.bids = [
                { supplier: 'Shaoxing Heavy Industries', countryCode: 'CHN', amount: overseasBid, time: 'Just Now (Overseas)' },
                { supplier: 'Tata Bharat Steels Ltd', countryCode: 'IND', amount: domesticBid, time: '1 min ago (Domestic)' }
              ];

              const toggle = document.getElementById('drawerLdpToggle');
              if (toggle) toggle.checked = true;
              toggleLdpNormalizer(true);
              showToast('⚡ Injected Global Overseas Bid vs Domestic Bid. Watch LDP Normalizer re-rank #1!');
            }

            // =========================================================================
            // 🔗 PHASE 3: VAE COMBINATORIAL SMART BASKET JAVASCRIPT
            // =========================================================================
            let smartBasketData = null;

            function fetchSmartBasketRecommendations(productId, hsnCode, quantity) {
              const card = document.getElementById('modalSmartBasketCard');
              const headline = document.getElementById('modalSmartBasketHeadline');
              const prompt = document.getElementById('modalSmartBasketPrompt');
              const itemsContainer = document.getElementById('modalSmartBasketItems');
              const discountBadge = document.getElementById('modalSmartBasketDiscountBadge');
              const savingsNotice = document.getElementById('modalSmartBasketSavingsNotice');

              let url = 'http://localhost:5000/api/smart-basket-recommendations?hsn=' + encodeURIComponent(hsnCode || '721420') + '&quantity=' + encodeURIComponent(quantity || 100);
              if (productId) url += '&product_id=' + encodeURIComponent(productId);

              fetch(url)
                .then(r => r.json())
                .then(data => {
                  if (data.status === 'success' && data.bundle_candidates && data.bundle_candidates.length > 0) {
                    smartBasketData = data;
                    if (card) card.classList.remove('hidden');
                    if (headline) headline.textContent = data.headline;
                    if (prompt) prompt.textContent = data.strategic_prompt;
                    if (discountBadge) discountBadge.textContent = 'Save +' + data.synergy_discount_pct + '%';
                    if (savingsNotice) savingsNotice.innerHTML = 'Est. Synergy Discount: <strong class="text-emerald-700 font-bold">' + formatINR(data.estimated_savings_inr) + '</strong>';

                    if (itemsContainer) {
                      itemsContainer.innerHTML = '';
                      data.bundle_candidates.forEach((c, idx) => {
                        const label = document.createElement('label');
                        label.className = 'flex items-center justify-between p-2.5 bg-white border border-indigo-100 rounded-xl hover:border-indigo-300 transition cursor-pointer text-xs';
                        label.innerHTML = 
                          '<div class="flex items-center space-x-2.5">' +
                            '<input type="checkbox" checked data-idx="' + idx + '" class="w-4 h-4 text-indigo-600 rounded focus:ring-indigo-500 border-slate-300">' +
                            '<div>' +
                              '<p class="font-bold text-slate-800">' + escapeHtml(c.product_name) + ' <span class="text-[10px] font-mono text-indigo-600">(HSN ' + c.hsn_code + ')</span></p>' +
                              '<p class="text-[10px] text-slate-500">Recommended Bundle: ' + c.recommended_quantity + ' ' + (c.unit || 'units') + ' • ' + formatINR(c.base_price) + ' / ' + (c.unit || 'unit') + '</p>' +
                            '</div>' +
                          '</div>' +
                          '<div class="text-right">' +
                            '<span class="text-[10px] font-bold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded-full border border-indigo-200">' + Math.round(c.affinity_score * 100) + '% Affinity</span>' +
                          '</div>';
                        itemsContainer.appendChild(label);
                      });
                    }
                  } else {
                    if (card) card.classList.add('hidden');
                  }
                })
                .catch(err => {
                  console.error('Smart Basket error:', err);
                  if (card) card.classList.add('hidden');
                });
            }

            function applySmartBasketBundle() {
              if (!smartBasketData || !smartBasketData.bundle_candidates) return;
              const input = document.getElementById('modalStartingPrice');
              const discount = smartBasketData.synergy_discount_pct || 7.4;
              const savings = smartBasketData.estimated_savings_inr || 380000;

              if (input && input.value) {
                const curVal = parseFloat(input.value) || 0;
                const discounted = Math.round(curVal * (1 - (discount / 100.0)));
                input.value = discounted;
              }

              showToast('📦 Bundled ' + smartBasketData.bundle_candidates.length + ' affinity items into Smart Basket Auction! Applied -' + discount + '% synergy discount (Saves ' + formatINR(savings) + ').');
              const btn = document.getElementById('modalApplySmartBasketBtn');
              if (btn) {
                btn.innerHTML = '<span>✓ Smart Basket Bundled (-' + discount + '%)</span>';
                btn.className = 'px-3.5 py-1.5 bg-emerald-600 text-white rounded-xl text-xs font-bold shadow-sm flex items-center gap-1.5 cursor-default';
              }
            }

            document.addEventListener('DOMContentLoaded', function() {
              initCatalogData();

              const baciSearchInput = document.getElementById('modalBaciSearchInput');
              if (baciSearchInput) {
                baciSearchInput.addEventListener('input', function() {
                  const query = this.value.trim();
                  const clearBtn = document.getElementById('clearProductBtn');
                  if (clearBtn) {
                    if (query.length > 0) clearBtn.classList.remove('hidden');
                    else clearBtn.classList.add('hidden');
                  }

                  renderCatalogDropdown(query, activeCategoryFilter);

                  clearTimeout(baciDebounceTimer);
                  if (query.length >= 1) {
                    baciDebounceTimer = setTimeout(() => {
                      fetch('http://localhost:5000/api/search-products?q=' + encodeURIComponent(query))
                        .then(r => r.json())
                        .then(data => {
                          const items = data.products || data.results || [];
                          if (items && items.length > 0) {
                            const existingHsns = new Set(catalogCache.map(c => c.hsn_code));
                            items.forEach(it => {
                              if (!existingHsns.has(it.hsn_code)) {
                                catalogCache.push(it);
                                existingHsns.add(it.hsn_code);
                              }
                            });
                            renderCatalogDropdown(query, activeCategoryFilter);
                          }
                        })
                        .catch(() => {});
                    }, 200);
                  }
                });
              }

              document.addEventListener('click', function(e) {
                const wrapper = document.getElementById('productComboboxWrapper');
                if (wrapper && !wrapper.contains(e.target)) {
                  closeProductDropdown();
                }
              });
            });

    </script>

          <!-- USER PROFILE & SECURITY SETTINGS MODAL -->
          <div id="userProfileModal" class="fixed inset-0 z-[120] hidden items-center justify-center p-4">
            <div class="fixed inset-0 bg-slate-950/70 backdrop-blur-sm transition-opacity"
              onclick="closeUserProfileModal()"></div>
            <div
              class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden transform transition-all z-10 animate-in fade-in zoom-in-95 duration-150">
              <div
                class="px-6 py-4.5 bg-gradient-to-r from-[#0B1E3D] via-[#172E6E] to-[#0B1E3D] text-white flex items-center justify-between border-b border-blue-900/40">
                <div class="flex items-center space-x-3">
                  <div
                    class="w-10 h-10 rounded-xl bg-teal-500/20 border border-teal-500/40 flex items-center justify-center text-[#2DD4BF]">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                  </div>
                  <div>
                    <h3 class="text-sm font-bold tracking-tight text-white">Account Settings & Security</h3>
                    <p class="text-[10px] text-teal-400 font-mono tracking-wider uppercase font-semibold">SUPPLEXIO
                      PROFILE MANAGEMENT</p>
                  </div>
                </div>
                <button type="button" onclick="closeUserProfileModal()"
                  class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-white/10 transition">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <div class="p-6 space-y-4 text-slate-800">
                <div id="profileModalAlert" class="hidden p-3 rounded-xl text-xs font-semibold"></div>
                <div>
                  <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                    Username <span class="text-rose-500">*</span>
                  </label>
                  <input type="text" id="profileModalUsername" value="<%= session.getAttribute(" username") !=null ?
                    session.getAttribute("username") : "admin" %>"
                  class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2
                  focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition"
                  placeholder="Enter username" />
                  <p class="text-[11px] text-slate-400 mt-1">Primary sign-in and account identifier across Supplexio.
                  </p>
                </div>
                <div>
                  <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Email
                    Address</label>
                  <input type="email" id="profileModalEmail" value="<%= session.getAttribute(" userEmail") !=null ?
                    session.getAttribute("userEmail") : "admin@example.com" %>"
                  class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2
                  focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition"
                  placeholder="admin@example.com" />
                </div>
                <div class="pt-2 border-t border-slate-200">
                  <span class="text-xs font-bold text-slate-900 flex items-center gap-1.5">
                    <svg class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                    Change Password (Optional)
                  </span>
                  <p class="text-[11px] text-slate-400 mt-0.5">Leave blank if only updating your username or email.</p>
                </div>
                <div>
                  <label class="block text-[11px] font-semibold text-slate-600 mb-1">Current Password</label>
                  <input type="password" id="profileModalOldPassword"
                    class="w-full px-3.5 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition"
                    placeholder="Enter current password to verify" autocomplete="current-password" />
                </div>
                <div class="grid grid-cols-2 gap-3">
                  <div>
                    <label class="block text-[11px] font-semibold text-slate-600 mb-1">New Password</label>
                    <input type="password" id="profileModalNewPassword"
                      class="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition"
                      placeholder="Min 6 characters" autocomplete="new-password" />
                  </div>
                  <div>
                    <label class="block text-[11px] font-semibold text-slate-600 mb-1">Confirm Password</label>
                    <input type="password" id="profileModalConfirmPassword"
                      class="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition"
                      placeholder="Re-enter password" autocomplete="new-password" />
                  </div>
                </div>
              </div>
              <div class="px-6 py-4 bg-slate-50 border-t border-slate-200 flex items-center justify-end space-x-3">
                <button type="button" onclick="closeUserProfileModal()"
                  class="px-4 py-2 border border-slate-300 rounded-xl text-xs font-semibold text-slate-700 bg-white hover:bg-slate-100 transition shadow-xs">
                  Cancel
                </button>
                <button type="button" id="btnSaveProfile" onclick="submitUserProfileUpdate()"
                  class="px-5 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-bold rounded-xl text-xs shadow-md transition flex items-center space-x-1.5">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span>Save Account Changes</span>
                </button>
              </div>
            </div>
          </div>

          <script>
            if (window.lucide) { lucide.createIcons(); }
            document.addEventListener("DOMContentLoaded", function () { if (window.lucide) lucide.createIcons(); });
          </script>
        </body>

        </html>