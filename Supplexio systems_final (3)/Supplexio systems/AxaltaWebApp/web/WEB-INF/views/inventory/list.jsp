<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en" class="h-full bg-slate-50">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplexio — Inventory Management &amp; AI Reverse Auction Intelligence</title>
  
  <!-- Google Fonts: Inter -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['Inter', 'sans-serif'],
          },
          colors: {
            navy: {
              800: '#111C33',
              900: '#0F172A',
              950: '#090D16',
            },
            brand: {
              blue: '#2563EB',
              teal: '#0D9488',
              amber: '#F59E0B',
              rose: '#E11D48',
            }
          }
        }
      }
    }
  </script>
  
  <!-- Lucide Icons -->
  <script src="https://unpkg.com/lucide@latest"></script>
  <!-- jQuery for AJAX -->
  <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>

  <style>
    /* Custom scrollbar for tables & sidebars */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    ::-webkit-scrollbar-track {
      background: #f1f5f9;
    }
    ::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: #94a3b8;
    }
    
    .pulse-glow-rose {
      box-shadow: 0 0 15px rgba(225, 29, 72, 0.25);
    }
    
    .glass-card {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(10px);
    }

    [x-cloak] { display: none !important; }
  </style>
</head>
<body class="h-full flex overflow-hidden font-sans text-slate-800 antialiased selection:bg-brand-cyan selection:text-brand-navy">

    <!-- WRAPPER: Full Height Desktop Canvas -->
    <div class="flex h-full w-full overflow-hidden">

                <!-- ASIDE: Left Modern Navigation Sidebar -->
        <aside class="w-64 bg-gradient-to-b from-[#172E6E] via-[#1E3E96] to-[#1B3680] text-white flex flex-col flex-shrink-0 shadow-xl border-r border-blue-900/40 relative z-20">
            <!-- Brand Badge Header -->
            <div class="p-4 border-b border-white/10">
                <a href="${pageContext.request.contextPath}/home?action=workspace" class="bg-[#0B1E3D] rounded-xl p-3 border border-white/10 shadow-lg flex flex-col items-center text-center block no-underline">
                    <div class="flex items-center gap-1">
                        <span class="text-2xl font-black tracking-tight text-white">Supple</span>
                        <span class="text-2xl font-black tracking-tight text-[#2DD4BF]">xio</span>
                    </div>
                    <span class="text-[9px] font-bold tracking-widest text-slate-300 uppercase mt-0.5">BID BOLD • SOURCE SMART</span>
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
                <a href="${pageContext.request.contextPath}/home?action=workspace" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="layout-dashboard" class="w-4 h-4 text-slate-300"></i>
                    <span>Dashboard</span>
                </a>
                <a href="${pageContext.request.contextPath}/product" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="package" class="w-4 h-4 text-slate-300"></i>
                    <span>Products</span>
                </a>
                <a href="${pageContext.request.contextPath}/auction" class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <div class="flex items-center gap-3">
                        <i data-lucide="gavel" class="w-4 h-4 text-slate-300"></i>
                        <span>Reverse Auctions</span>
                    </div>
                    <span class="bg-amber-500/30 text-amber-300 text-[10px] font-bold px-2 py-0.5 rounded-full border border-amber-400/40">LIVE</span>
                </a>
                <a href="${pageContext.request.contextPath}/supplier" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="users" class="w-4 h-4 text-slate-300"></i>
                    <span>Suppliers</span>
                </a>
                <a href="${pageContext.request.contextPath}/payment" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="credit-card" class="w-4 h-4 text-slate-300"></i>
                    <span>Payments</span>
                </a>
                <a href="${pageContext.request.contextPath}/todo" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="check-square" class="w-4 h-4 text-slate-300"></i>
                    <span>To-Do List</span>
                </a>
                <a href="${pageContext.request.contextPath}/inventory" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline bg-white/15 text-white font-semibold shadow-inner border border-white/20 backdrop-blur-sm">
                    <i data-lucide="boxes" class="w-4 h-4 text-[#2DD4BF]"></i>
                    <span>Inventory Management</span>
                </a>
                <a href="http://localhost:8501" target="_blank" class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <div class="flex items-center gap-3">
                        <i data-lucide="globe-2" class="w-4 h-4 text-[#2DD4BF]"></i>
                        <span>Global Trade Intel</span>
                    </div>
                    <span class="w-2 h-2 rounded-full bg-[#2DD4BF] animate-pulse"></span>
                </a>
                <a href="${pageContext.request.contextPath}/user-po-view" class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <div class="flex items-center gap-3">
                        <i data-lucide="file-text" class="w-4 h-4 text-slate-300"></i>
                        <span>Purchase Orders</span>
                    </div>
                    <span class="bg-[#2DD4BF] text-slate-950 text-[10px] font-extrabold px-2 py-0.5 rounded-full" id="po-total-badge">54</span>
                </a>
                <a href="${pageContext.request.contextPath}/settings" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="settings" class="w-4 h-4 text-slate-300"></i>
                    <span>Settings</span>
                </a>
            </nav>

            <!-- Sidebar User Profile Footer (Clickable to Edit Profile & Password) -->
            <div class="p-3 border-t border-white/10 bg-black/20">
                <div onclick="openUserProfileModal()" 
                     class="flex items-center gap-3 p-2.5 rounded-xl bg-white/5 hover:bg-white/15 border border-white/10 hover:border-white/20 transition-all duration-150 cursor-pointer group"
                     title="Click to update username or change password">
                    <div class="w-9 h-9 rounded-full bg-[#2DD4BF] text-slate-950 font-black flex items-center justify-center text-xs shadow-md tracking-wider flex-shrink-0 group-hover:scale-105 transition-transform" id="sidebar-user-avatar">
                        <%= (session.getAttribute("username") != null && ((String)session.getAttribute("username")).length() > 0) ? ((String)session.getAttribute("username")).substring(0, Math.min(2, ((String)session.getAttribute("username")).length())).toUpperCase() : "AD" %>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-bold text-white tracking-wide truncate group-hover:text-[#2DD4BF] transition-colors" id="sidebar-username-display">
                            <%= session.getAttribute("username") != null ? session.getAttribute("username") : "admin" %>
                        </p>
                    </div>
                    <div class="text-slate-400 group-hover:text-white transition-colors">
                        <i data-lucide="settings" class="w-4 h-4 text-[#2DD4BF]"></i>
                    </div>
                </div>
            </div>
        </aside>

        <!-- MAIN CONTENT AREA -->
        <main class="flex-1 flex flex-col min-w-0 overflow-y-auto">
      
      <div class="max-w-7xl w-full mx-auto p-4 sm:p-6 md:p-8 space-y-6">
        
        <!-- Top Page Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-2">
          <div>
            <div class="flex items-center gap-2">
              <h1 class="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">Inventory Management</h1>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
                Kanban Health Enabled
              </span>
            </div>
            <p class="text-sm text-slate-500 mt-1">Monitor stock thresholds, automated supplier trigger alerts, and execute reverse auctions.</p>
          </div>

          <div class="flex items-center gap-3">
            <button onclick="exportCSV()" class="inline-flex items-center gap-2 px-3.5 py-2 text-sm font-semibold text-slate-700 bg-white border border-slate-300 rounded-xl hover:bg-slate-50 hover:border-slate-400 shadow-sm transition-all">
              <i data-lucide="download" class="w-4 h-4 text-slate-500"></i>
              <span>Export CSV</span>
            </button>
            <button onclick="openAddProductModal()" class="inline-flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 active:bg-blue-800 rounded-xl shadow-md shadow-blue-500/20 transition-all">
              <i data-lucide="plus" class="w-4 h-4"></i>
              <span>+ Add Product</span>
            </button>
          </div>
        </div>

        <!-- KPI Summary Cards Row -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          
          <!-- Card 1: Total SKUs -->
          <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between text-slate-500 mb-2">
              <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Inventory</span>
              <div class="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center text-slate-600">
                <i data-lucide="boxes" class="w-4 h-4"></i>
              </div>
            </div>
            <div class="flex items-baseline justify-between">
              <div class="text-3xl font-black text-slate-900" id="kpiTotalCount">105</div>
              <span class="text-xs font-semibold text-slate-500">SKUs tracked</span>
            </div>
            <div class="mt-3">
              <div class="flex justify-between text-[11px] text-slate-500 font-medium mb-1">
                <span>Health Breakdown</span>
                <span id="kpiRatioText">79% Healthy</span>
              </div>
              <div class="w-full h-2 bg-slate-100 rounded-full overflow-hidden flex">
                <div id="kpiBarHigh" class="h-full bg-emerald-500" style="width: 22%"></div>
                <div id="kpiBarMed" class="h-full bg-amber-400" style="width: 57%"></div>
                <div id="kpiBarLow" class="h-full bg-rose-500" style="width: 21%"></div>
              </div>
            </div>
          </div>

          <!-- Card 2: Critical Stock -->
          <div onclick="setFilter('Low')" class="cursor-pointer bg-white rounded-2xl p-5 border border-rose-100 shadow-sm hover:shadow-md hover:border-rose-300 transition-all group">
            <div class="flex items-center justify-between text-slate-500 mb-2">
              <span class="text-xs font-bold uppercase tracking-wider text-rose-500">Critical / Low Stock</span>
              <div class="w-8 h-8 rounded-lg bg-rose-50 flex items-center justify-center text-rose-600 group-hover:scale-110 transition-transform">
                <i data-lucide="alert-triangle" class="w-4 h-4"></i>
              </div>
            </div>
            <div class="flex items-baseline justify-between">
              <div class="text-3xl font-black text-rose-600" id="kpiLowCount">22</div>
              <span class="inline-flex items-center text-xs font-semibold text-rose-700 bg-rose-50 px-2 py-0.5 rounded-full border border-rose-200">
                Below Threshold
              </span>
            </div>
            <p class="text-xs text-slate-500 mt-3 flex items-center gap-1">
              <span>Click to view items needing restock</span>
              <i data-lucide="chevron-right" class="w-3.5 h-3.5 text-rose-500"></i>
            </p>
          </div>

          <!-- Card 3: Auctions Needed -->
          <div onclick="setFilter('Auction Needed')" class="cursor-pointer bg-gradient-to-br from-white to-amber-50/30 rounded-2xl p-5 border border-amber-200 shadow-sm hover:shadow-md hover:border-amber-400 transition-all group relative overflow-hidden">
            <div class="absolute -right-3 -top-3 w-16 h-16 bg-amber-100/50 rounded-full blur-xl"></div>
            <div class="flex items-center justify-between text-slate-500 mb-2">
              <span class="text-xs font-bold uppercase tracking-wider text-amber-700">Auctions Required</span>
              <div class="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center text-amber-700 group-hover:rotate-12 transition-transform">
                <i data-lucide="gavel" class="w-4 h-4"></i>
              </div>
            </div>
            <div class="flex items-baseline justify-between">
              <div class="text-3xl font-black text-amber-700 flex items-center gap-2" id="kpiAuctionCount">
                22
                <span class="w-2.5 h-2.5 rounded-full bg-rose-500 animate-ping"></span>
              </div>
              <span class="inline-flex items-center text-xs font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded-full">
                Action Ready
              </span>
            </div>
            <p class="text-xs text-amber-800/80 font-medium mt-3 flex items-center justify-between">
              <span>Pre-drafted contracts ready</span>
              <span class="font-bold underline">Filter List</span>
            </p>
          </div>

          <!-- Card 4: Healthy Stock -->
          <div onclick="setFilter('High')" class="cursor-pointer bg-white rounded-2xl p-5 border border-slate-200 shadow-sm hover:shadow-md hover:border-emerald-300 transition-all group">
            <div class="flex items-center justify-between text-slate-500 mb-2">
              <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Optimal / Healthy</span>
              <div class="w-8 h-8 rounded-lg bg-emerald-50 flex items-center justify-center text-emerald-600 group-hover:scale-110 transition-transform">
                <i data-lucide="check-circle-2" class="w-4 h-4"></i>
              </div>
            </div>
            <div class="flex items-baseline justify-between">
              <div class="text-3xl font-black text-slate-900" id="kpiHealthyCount">83</div>
              <span class="text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                Stable Stock
              </span>
            </div>
            <p class="text-xs text-slate-500 mt-3" id="kpiHealthyBreakdown">
              60 Medium · 23 High Level
            </p>
          </div>

        </div>

        <!-- AI Price Surge Alert Panel (Compact Intelligence Unit) -->
        <div id="aiAlertContainer" class="bg-gradient-to-r from-white via-rose-50/40 to-amber-50/30 border border-rose-200 rounded-2xl p-4 sm:p-5 shadow-sm relative overflow-hidden transition-all duration-300">
          <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            
            <!-- Left Info Block -->
            <div class="flex items-start space-x-3.5 flex-1 min-w-0">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-rose-500 to-amber-600 text-white flex items-center justify-center shrink-0 shadow-md shadow-rose-500/20 mt-0.5">
                <i data-lucide="sparkles" class="w-5 h-5"></i>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex flex-wrap items-center gap-2 mb-1">
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-md text-[11px] font-extrabold bg-rose-600 text-white uppercase tracking-wider shadow-sm">
                    <span class="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span>
                    Autonomous Action Required
                  </span>
                  <span class="text-xs font-bold text-slate-700 bg-white/80 px-2.5 py-0.5 rounded-md border border-slate-200">
                    1D-ResNet Trade Intelligence Engine
                  </span>
                  <span class="text-xs font-semibold text-rose-700 bg-rose-100/80 px-2 py-0.5 rounded-full">
                    1 Actionable Alert
                  </span>
                </div>
                
                <div class="flex flex-wrap items-center gap-x-3 gap-y-1 mt-2">
                  <h3 class="text-base font-bold text-slate-900" id="aiSurgeItemName">Bitumen Primer</h3>
                  <span class="inline-flex items-center text-xs font-extrabold text-rose-600 bg-rose-100 px-2 py-0.5 rounded" id="aiSurgePct">
                    +7.4% SURGE FORECASTED
                  </span>
                  <span class="text-xs text-slate-500 font-mono" id="aiSurgeDetails">HSN Code: 270811 | Stock: 40 / Min: 50</span>
                </div>
                
                <p class="text-xs text-slate-600 mt-1 max-w-3xl leading-relaxed">
                  Detected raw material inventory below safe threshold paired with forecasted global import price surge (+7.4%) within 30 days. Reverse auction pre-drafted to lock in supplier contracts prior to price hike.
                </p>
              </div>
            </div>

            <!-- Right Metric & CTA Action Block -->
            <div class="flex items-center justify-between lg:justify-end gap-4 pt-3 lg:pt-0 border-t lg:border-t-0 border-rose-200/60 shrink-0">
              <div class="text-left lg:text-right pr-2">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400">AI Target Price Ceiling</span>
                <span class="text-xl font-extrabold text-slate-900 font-mono">₹2,625 <span class="text-xs text-slate-500 font-normal">/ unit</span></span>
              </div>
              
              <button onclick="triggerSurgeAuction()" class="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-white bg-gradient-to-r from-rose-600 to-amber-600 hover:from-rose-700 hover:to-amber-700 rounded-xl shadow-md shadow-rose-500/20 hover:shadow-lg transition-all transform hover:-translate-y-0.5 active:translate-y-0">
                <i data-lucide="gavel" class="w-4 h-4"></i>
                <span>Launch Reverse Auction</span>
              </button>
            </div>

          </div>
        </div>

        <!-- Controls Bar: Search, Filters, Sorting & View Toggle -->
        <div class="bg-white rounded-2xl p-4 border border-slate-200 shadow-sm flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
          
          <!-- Search Input -->
          <div class="relative flex-1 max-w-md">
            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <i data-lucide="search" class="w-4 h-4"></i>
            </div>
            <input 
              type="text" 
              id="searchInput" 
              placeholder="Search by SKU name, ID, or HSN code..." 
              oninput="handleSearch()"
              class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all placeholder:text-slate-400"
            >
          </div>

          <!-- Filter Pills -->
          <div class="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
            <button onclick="setFilter('All')" id="filter-All" class="filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-slate-900 text-white shadow-sm">
              All Items (<span id="count-All">105</span>)
            </button>
            <button onclick="setFilter('Auction Needed')" id="filter-Auction Needed" class="filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-all">
              Auction Needed (<span id="count-Auction Needed">22</span>)
            </button>
            <button onclick="setFilter('Low')" id="filter-Low" class="filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-all">
              Critical / Low (<span id="count-Low">22</span>)
            </button>
            <button onclick="setFilter('Medium')" id="filter-Medium" class="filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-all">
              Medium (<span id="count-Medium">60</span>)
            </button>
            <button onclick="setFilter('High')" id="filter-High" class="filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-all">
              Healthy (<span id="count-High">23</span>)
            </button>
          </div>

          <!-- View Switcher & Sort -->
          <div class="flex items-center gap-2 justify-end">
            
            <!-- Sort Selector -->
            <select id="sortSelect" onchange="handleSort()" class="bg-slate-50 border border-slate-200 text-slate-700 text-xs font-medium rounded-xl px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500/20">
              <option value="id-asc">Sort by ID (Default)</option>
              <option value="name-asc">Sort by Name (A-Z)</option>
              <option value="qty-asc">Stock Level (Lowest First)</option>
              <option value="qty-desc">Stock Level (Highest First)</option>
            </select>

            <!-- Table / Kanban Switcher -->
            <div class="flex items-center p-1 bg-slate-100 rounded-xl border border-slate-200">
              <button id="viewTableBtn" onclick="switchView('table')" class="p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 bg-white text-slate-900 shadow-sm transition-all">
                <i data-lucide="table" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Table</span>
              </button>
              <button id="viewKanbanBtn" onclick="switchView('kanban')" class="p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-all">
                <i data-lucide="kanban" class="w-4 h-4"></i>
                <span class="hidden sm:inline">Kanban</span>
              </button>
            </div>

            <!-- Clear Filter Button -->
            <button onclick="resetFilters()" class="p-2 text-slate-400 hover:text-slate-600 rounded-xl hover:bg-slate-100 transition-colors" title="Reset Search &amp; Filters">
              <i data-lucide="rotate-ccw" class="w-4 h-4"></i>
            </button>
          </div>

        </div>

        <!-- VIEW 1: Inventory Table -->
        <div id="tableView" class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-50/80 border-b border-slate-200 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                  <th class="py-3.5 px-4 font-extrabold w-16 text-center">ID</th>
                  <th class="py-3.5 px-4">Item Name &amp; SKU Details</th>
                  <th class="py-3.5 px-4 w-56">Stock Threshold Gauge</th>
                  <th class="py-3.5 px-4 w-32">Kanban Health</th>
                  <th class="py-3.5 px-4 w-36">Auction Status</th>
                  <th class="py-3.5 px-4 text-right w-44">Actions</th>
                </tr>
              </thead>
              <tbody id="inventoryTableBody" class="divide-y divide-slate-100 text-sm">
                <!-- Data populated dynamically by JS -->
              </tbody>
            </table>
          </div>

          <!-- Empty State -->
          <div id="emptyState" class="hidden p-12 text-center">
            <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
              <i data-lucide="search-x" class="w-6 h-6"></i>
            </div>
            <h4 class="text-base font-bold text-slate-800">No inventory items found</h4>
            <p class="text-xs text-slate-500 mt-1">Try adjusting your search terms or filter selection.</p>
            <button onclick="resetFilters()" class="mt-4 px-3.5 py-1.5 text-xs font-bold text-blue-600 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors">
              Reset Filters
            </button>
          </div>

          <!-- Table Pagination Footer -->
          <div class="px-5 py-4 bg-slate-50/50 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
            <div>
              Showing <span id="pageStart" class="font-bold text-slate-800">1</span> to <span id="pageEnd" class="font-bold text-slate-800">10</span> of <span id="pageTotal" class="font-bold text-slate-800">105</span> inventory items
            </div>
            <div class="flex items-center space-x-1" id="paginationControls">
              <!-- Pagination buttons JS rendered -->
            </div>
          </div>
        </div>

        <!-- VIEW 2: Kanban Board View -->
        <div id="kanbanView" class="hidden grid grid-cols-1 md:grid-cols-3 gap-6">
          
          <!-- Column 1: Critical / Low Stock -->
          <div class="bg-rose-50/40 rounded-2xl p-4 border border-rose-200/80 flex flex-col min-h-[500px]">
            <div class="flex items-center justify-between pb-3 mb-3 border-b border-rose-200">
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-rose-500"></span>
                <h3 class="font-bold text-slate-900">Critical / Low Stock</h3>
              </div>
              <span id="kanbanCountLow" class="px-2 py-0.5 rounded-full text-xs font-black bg-rose-100 text-rose-700">22</span>
            </div>
            <div id="kanbanLowCol" class="space-y-3 flex-1 overflow-y-auto">
              <!-- Kanban cards -->
            </div>
          </div>

          <!-- Column 2: Medium Stock -->
          <div class="bg-amber-50/30 rounded-2xl p-4 border border-amber-200/80 flex flex-col min-h-[500px]">
            <div class="flex items-center justify-between pb-3 mb-3 border-b border-amber-200">
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-amber-500"></span>
                <h3 class="font-bold text-slate-900">Medium Stock Level</h3>
              </div>
              <span id="kanbanCountMed" class="px-2 py-0.5 rounded-full text-xs font-black bg-amber-100 text-amber-800">60</span>
            </div>
            <div id="kanbanMedCol" class="space-y-3 flex-1 overflow-y-auto">
              <!-- Kanban cards -->
            </div>
          </div>

          <!-- Column 3: Healthy / High Stock -->
          <div class="bg-emerald-50/30 rounded-2xl p-4 border border-emerald-200/80 flex flex-col min-h-[500px]">
            <div class="flex items-center justify-between pb-3 mb-3 border-b border-emerald-200">
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-emerald-500"></span>
                <h3 class="font-bold text-slate-900">Optimal / Healthy</h3>
              </div>
              <span id="kanbanCountHigh" class="px-2 py-0.5 rounded-full text-xs font-black bg-emerald-100 text-emerald-800">23</span>
            </div>
            <div id="kanbanHighCol" class="space-y-3 flex-1 overflow-y-auto">
              <!-- Kanban cards -->
            </div>
          </div>

        </div>

      </div>

    </main>

  </div>

  <!-- MODAL 1: Create Reverse Auction Modal -->
  <div id="auctionModal" class="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-2xl max-w-lg w-full shadow-2xl border border-slate-200 overflow-hidden transform transition-all">
      <div class="bg-gradient-to-r from-slate-900 to-slate-800 px-6 py-4 text-white flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-amber-500/20 text-amber-400 flex items-center justify-center">
            <i data-lucide="gavel" class="w-4 h-4"></i>
          </div>
          <div>
            <h3 class="font-bold text-base">Launch Reverse Auction</h3>
            <p class="text-xs text-slate-400">Trigger competitive supplier bidding for inventory reorder</p>
          </div>
        </div>
        <button onclick="closeAuctionModal()" class="text-slate-400 hover:text-white transition-colors">
          <i data-lucide="x" class="w-5 h-5"></i>
        </button>
      </div>

      <form id="auctionForm" onsubmit="handleAuctionSubmit(event)" class="p-6 space-y-4">
        <input type="hidden" id="aucItemId">
        
        <div>
          <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Target Product</label>
          <input type="text" id="aucItemName" readonly class="w-full bg-slate-100 border border-slate-200 rounded-xl px-3.5 py-2 text-sm font-semibold text-slate-800 focus:outline-none">
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Current Stock</label>
            <input type="text" id="aucCurrentStock" readonly class="w-full bg-slate-100 border border-slate-200 rounded-xl px-3.5 py-2 text-sm font-mono text-slate-700">
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Target Quantity to Procurement</label>
            <input type="number" id="aucOrderQty" required min="1" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-bold text-slate-900 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Target Ceiling Price (INR per unit)</label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center font-bold text-slate-400">₹</span>
            <input type="number" id="aucTargetPrice" step="0.01" required class="w-full pl-8 pr-4 py-2 bg-white border border-slate-300 rounded-xl text-sm font-mono font-bold text-slate-900 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
          </div>
          <p class="text-[11px] text-teal-600 mt-1 flex items-center gap-1">
            <i data-lucide="sparkles" class="w-3 h-3"></i>
            <span>AI Price Engine suggests ceiling based on market index</span>
          </p>
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Auction Bidding Duration</label>
          <select id="aucDuration" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm text-slate-700 focus:ring-2 focus:ring-blue-500/20">
            <option value="24">24 Hours (Fast-track)</option>
            <option value="48" selected>48 Hours (Standard)</option>
            <option value="72">72 Hours (Extended)</option>
          </select>
        </div>

        <div class="pt-3 border-t border-slate-100 flex items-center justify-end space-x-3">
          <button type="button" onclick="closeAuctionModal()" class="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            Cancel
          </button>
          <button type="submit" class="px-5 py-2 text-xs font-bold text-slate-950 bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-500 hover:to-amber-600 rounded-xl shadow-md transition-all">
            Broadcast Reverse Auction
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- MODAL 2: Adjust Stock Modal -->
  <div id="adjustModal" class="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-2xl max-w-md w-full shadow-2xl border border-slate-200 overflow-hidden">
      <div class="bg-slate-900 px-6 py-4 text-white flex items-center justify-between">
        <div class="flex items-center gap-2">
          <i data-lucide="sliders" class="w-5 h-5 text-blue-400"></i>
          <h3 class="font-bold text-base">Adjust Stock Level</h3>
        </div>
        <button onclick="closeAdjustModal()" class="text-slate-400 hover:text-white">
          <i data-lucide="x" class="w-5 h-5"></i>
        </button>
      </div>

      <form id="adjustForm" onsubmit="handleAdjustSubmit(event)" class="p-6 space-y-4">
        <input type="hidden" id="adjItemId">
        
        <div>
          <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Item Name</label>
          <input type="text" id="adjItemName" readonly class="w-full bg-slate-100 border border-slate-200 rounded-xl px-3 py-2 text-sm font-bold text-slate-800">
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Current Stock Quantity</label>
          <input type="number" id="adjQuantity" min="0" required class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-bold font-mono text-slate-900 focus:ring-2 focus:ring-blue-500/20">
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Min Threshold</label>
            <input type="number" id="adjMin" min="0" required class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-mono text-slate-800">
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-slate-500 mb-1">Max Threshold</label>
            <input type="number" id="adjMax" min="1" required class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-mono text-slate-800">
          </div>
        </div>

        <div class="pt-3 border-t border-slate-100 flex items-center justify-end space-x-3">
          <button type="button" onclick="closeAdjustModal()" class="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl">
            Cancel
          </button>
          <button type="submit" class="px-5 py-2 text-xs font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md">
            Save Changes
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- MODAL 3: Add Product Modal (Matching exact parameters & features from previous modal) -->
  <div id="addProductModal" class="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
    <div class="bg-white rounded-2xl max-w-xl w-full shadow-2xl border border-slate-200 overflow-hidden transform transition-all">
      <div class="bg-slate-900 px-6 py-4 text-white flex items-center justify-between">
        <div class="flex items-center gap-2.5">
          <div class="w-8 h-8 rounded-lg bg-teal-500/20 text-teal-400 flex items-center justify-center">
            <i data-lucide="package-plus" class="w-4 h-4"></i>
          </div>
          <div>
            <h3 class="font-bold text-base text-white">Add Product to Inventory</h3>
            <p class="text-xs text-slate-400">Select an existing catalog item or register custom raw material</p>
          </div>
        </div>
        <button onclick="closeAddProductModal()" class="text-slate-400 hover:text-white transition-colors">
          <i data-lucide="x" class="w-5 h-5"></i>
        </button>
      </div>

      <form id="addProductForm" onsubmit="handleAddProductSubmit(event)" class="p-6 space-y-4">
        <!-- Catalog Product Selection -->
        <!-- Searchable Catalog Combobox (Strictly contained within modal - never overflows or spills off) -->
        <div class="relative" id="comboboxWrapper">
          <div class="flex items-center justify-between mb-1">
            <label class="block text-xs font-bold uppercase text-slate-600">
              Select Catalog Product or Add Custom <span class="text-rose-500">*</span>
            </label>
            <span id="catalogCountBadge" class="text-[11px] font-semibold text-blue-600 font-mono">5,385 Commodities</span>
          </div>

          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <i data-lucide="search" class="w-4 h-4"></i>
            </div>
            <input type="text" id="catalogComboboxInput" autocomplete="off"
                   onfocus="openComboboxDropdown()" oninput="onComboboxInput(this.value)"
                   placeholder="Click or type to search 5,385+ commodities..."
                   class="w-full bg-slate-50 border border-slate-300 rounded-xl pl-10 pr-16 py-2.5 text-sm font-semibold text-slate-800 placeholder-slate-400 focus:bg-white focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all cursor-pointer">
            <div class="absolute inset-y-0 right-0 pr-2.5 flex items-center gap-1">
              <button type="button" id="clearComboboxBtn" onclick="clearCatalogSelection(event)" class="text-slate-400 hover:text-slate-600 hidden p-1 rounded-lg hover:bg-slate-100 transition-colors" title="Clear selection">
                <i data-lucide="x" class="w-3.5 h-3.5"></i>
              </button>
              <button type="button" onclick="toggleComboboxDropdown(event)" class="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors">
                <i data-lucide="chevron-down" id="comboboxChevron" class="w-4 h-4 transition-transform duration-200"></i>
              </button>
            </div>
          </div>

          <!-- Hidden inputs to store selected product data -->
          <input type="hidden" id="selectedProductId" value="">
          <input type="hidden" id="selectedProductPrice" value="1000">

          <!-- Combobox Dropdown Container: w-full and overflow-hidden ensures it stays strictly within the modal! -->
          <div id="comboboxDropdown" class="hidden absolute top-full left-0 right-0 mt-1.5 bg-white border border-slate-200 rounded-xl shadow-2xl z-50 overflow-hidden flex flex-col">
            <!-- Header status row -->
            <div class="px-3 py-1.5 border-b border-slate-100 bg-slate-50 flex items-center justify-between text-[11px] text-slate-500 font-medium">
              <span id="comboboxStatusText">Showing top commodities</span>
              <span class="text-[10px] text-slate-400">Scroll or type to search</span>
            </div>

            <!-- Pinned: Add Custom Item option -->
            <div class="p-1 border-b border-slate-100 bg-blue-50/50">
              <div onclick="selectCustomItem()" class="flex items-center gap-2.5 px-3 py-2 text-xs font-bold text-blue-700 hover:bg-blue-100/70 rounded-lg cursor-pointer transition-colors">
                <div class="w-5 h-5 rounded bg-blue-600 text-white flex items-center justify-center shrink-0">
                  <i data-lucide="plus" class="w-3 h-3"></i>
                </div>
                <span>➕ Add Custom Raw Material / Item (Unlisted)</span>
              </div>
            </div>

            <!-- Scrollable Items List with max-h-56 -->
            <div id="comboboxList" class="overflow-y-auto max-h-56 divide-y divide-slate-100 p-1">
              <!-- Populated dynamically by JS -->
            </div>
          </div>

          <p class="text-[11px] text-slate-500 mt-1">Search or choose from all 5,385 master commodities, or select custom item.</p>
        </div>

        <!-- Custom Item Name Input (appears when CUSTOM selected or typed) -->
        <div id="customNameRow" style="display: none;">
          <label class="block text-xs font-bold uppercase text-slate-600 mb-1">
            Custom Product / Item Name <span class="text-rose-500">*</span>
          </label>
          <input type="text" id="addName" placeholder="e.g. Stainless Steel Pipe 2 inch" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-semibold text-slate-800 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
        </div>

        <!-- Category & Unit of Measure (2 Columns) -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-bold uppercase text-slate-600 mb-1">Category</label>
            <input type="text" id="addCategory" placeholder="e.g. Chemicals, Hardware, Electrical" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm text-slate-800 focus:ring-2 focus:ring-blue-500/20">
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-slate-600 mb-1">Unit of Measure</label>
            <input type="text" id="addUnit" placeholder="e.g. pcs, kg, coil, liter, sqft" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm text-slate-800 focus:ring-2 focus:ring-blue-500/20">
          </div>
        </div>

        <!-- HSN Code -->
        <div>
          <label class="block text-xs font-bold uppercase text-slate-600 mb-1">HSN Code (BACI Trade Harmonized System)</label>
          <input type="text" id="addHSN" placeholder="e.g. 721420, 320611" class="w-full bg-white border border-slate-300 rounded-xl px-3.5 py-2 text-sm font-mono text-slate-800 focus:ring-2 focus:ring-blue-500/20">
        </div>

        <!-- 3-Column Stock Quantities & Thresholds -->
        <div class="grid grid-cols-3 gap-3 pt-1">
          <div>
            <label class="block text-xs font-bold uppercase text-slate-700 mb-1">
              Initial Stock Quantity <span class="text-rose-500">*</span>
            </label>
            <input type="number" id="addQty" min="0" value="100" required oninput="updateAddKanbanPreview()" class="w-full bg-white border border-slate-300 rounded-xl px-3 py-2 text-sm font-bold font-mono text-slate-900 focus:ring-2 focus:ring-blue-500/20">
            <p class="text-[10px] text-slate-400 mt-1">Current physical stock</p>
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-rose-600 mb-1">
              Min Threshold (Safety Stock) <span class="text-rose-500">*</span>
            </label>
            <input type="number" id="addMin" min="0" value="40" required oninput="updateAddKanbanPreview()" class="w-full bg-white border border-rose-300 rounded-xl px-3 py-2 text-sm font-bold font-mono text-slate-900 focus:ring-2 focus:ring-rose-500/20">
            <p class="text-[10px] text-rose-500 font-medium mt-1">Triggers Kanban Low &amp; Auction</p>
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-emerald-600 mb-1">
              Max Threshold (Capacity) <span class="text-emerald-500">*</span>
            </label>
            <input type="number" id="addMax" min="1" value="200" required oninput="updateAddKanbanPreview()" class="w-full bg-white border border-emerald-300 rounded-xl px-3 py-2 text-sm font-bold font-mono text-slate-900 focus:ring-2 focus:ring-emerald-500/20">
            <p class="text-[10px] text-emerald-600 font-medium mt-1">Optimal storage limit</p>
          </div>
        </div>

        <!-- Automatic Kanban Integration Callout -->
        <div class="bg-amber-50/80 border border-amber-200 rounded-xl p-3.5 flex items-start gap-3">
          <div class="w-6 h-6 rounded-lg bg-amber-100 text-amber-600 flex items-center justify-center shrink-0 mt-0.5">
            <i data-lucide="lightbulb" class="w-4 h-4"></i>
          </div>
          <div class="text-xs text-amber-900 leading-relaxed">
            <strong>Automatic Kanban Integration:</strong> If initial quantity &le; Min Threshold, the item will immediately display 
            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-rose-100 text-rose-700">Low Stock</span>
            and enable autonomous reverse auction restocking.
            <div id="kanbanPreviewStatus" class="mt-1 font-semibold text-slate-700"></div>
          </div>
        </div>

        <div class="pt-3 border-t border-slate-100 flex items-center justify-end space-x-3">
          <button type="button" onclick="closeAddProductModal()" class="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            Cancel
          </button>
          <button type="submit" class="inline-flex items-center gap-1.5 px-5 py-2 text-xs font-bold text-white bg-blue-600 hover:bg-blue-700 active:bg-blue-800 rounded-xl shadow-md shadow-blue-500/20 transition-all">
            <i data-lucide="check" class="w-4 h-4"></i>
            <span>✓ Add to Inventory</span>
          </button>
        </div>
      </form>
    </div>
  </div>

  
  <!-- IN-APP CONFIRMATION & AUDIT MODAL -->
  <div id="appConfirmModal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4">
    <div class="fixed inset-0 bg-slate-950/70 backdrop-blur-sm transition-opacity" onclick="closeAppConfirmModal()"></div>

    <div class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden transform transition-all z-10 animate-in fade-in zoom-in-95 duration-200">
      <div id="confirmModalHeader" class="px-6 py-4.5 bg-gradient-to-r from-slate-950 via-slate-900 to-slate-950 text-white flex items-center justify-between border-b border-slate-800">
        <div class="flex items-center space-x-3">
          <div id="confirmModalIconBox" class="w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
          </div>
          <div>
            <h3 id="confirmModalTitle" class="text-sm font-bold tracking-tight text-white">Confirmation</h3>
            <p id="confirmModalSubtitle" class="text-[10px] text-amber-400 font-mono tracking-wider uppercase font-semibold">SUPPLEXIO ACTION AUDIT</p>
          </div>
        </div>
        <button type="button" onclick="closeAppConfirmModal()" class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </div>

      <div class="p-6 space-y-4">
        <div id="confirmModalMessage" class="text-sm text-slate-700 leading-relaxed font-sans"></div>
        <div id="confirmModalDetails" class="hidden bg-slate-50 border border-slate-200 rounded-xl p-4 text-xs text-slate-700 space-y-2 font-sans"></div>
      </div>

      <div class="px-6 py-4 bg-slate-50 border-t border-slate-200 flex items-center justify-end space-x-3">
        <button type="button" id="confirmModalCancelBtn" onclick="closeAppConfirmModal()" class="px-4 py-2 border border-slate-300 rounded-xl text-xs font-semibold text-slate-700 bg-white hover:bg-slate-100 transition shadow-xs">
          Cancel
        </button>
        <button type="button" id="confirmModalConfirmBtn" class="px-5 py-2.5 rounded-xl text-xs font-semibold shadow-md transition flex items-center space-x-1.5">
        </button>
      </div>
    </div>
  </div>

  <!-- FLOATING AI ASSISTANT & TOAST CONTAINER -->
  <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>

  <!-- AI Assistant Widget -->
  <div class="fixed bottom-6 left-6 z-40">
    <div id="aiChatWindow" class="hidden mb-3 w-80 bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden transform transition-all">
      <div class="bg-slate-900 text-white p-3.5 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="w-7 h-7 rounded-lg bg-teal-500/20 text-teal-400 flex items-center justify-center font-bold text-xs">
            <i data-lucide="bot" class="w-4 h-4"></i>
          </div>
          <div>
            <h4 class="text-xs font-bold">Supplexio AI Copilot</h4>
            <p class="text-[10px] text-slate-400">Inventory &amp; Auction Advisor</p>
          </div>
        </div>
        <button onclick="toggleAIChat()" class="text-slate-400 hover:text-white">
          <i data-lucide="x" class="w-4 h-4"></i>
        </button>
      </div>
      <div class="p-3.5 h-64 overflow-y-auto text-xs space-y-2.5 bg-slate-50" id="aiChatMessages">
        <div class="bg-white p-3 rounded-xl border border-slate-200 shadow-sm text-slate-700">
          Hello! I monitored your inventory SKUs. Bitumen Primer is below threshold with an active price surge (+7.4%). Would you like me to trigger an auction?
        </div>
      </div>
      <div class="p-2 bg-white border-t border-slate-200 flex items-center gap-1.5">
        <input type="text" id="aiInput" placeholder="Ask AI Copilot..." class="flex-1 text-xs px-3 py-1.5 bg-slate-100 border border-slate-200 rounded-lg focus:outline-none" onkeypress="if(event.key==='Enter') sendAIMessage()">
        <button onclick="sendAIMessage()" class="p-1.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
          <i data-lucide="send" class="w-3.5 h-3.5"></i>
        </button>
      </div>
    </div>

    <button onclick="toggleAIChat()" class="w-12 h-12 bg-gradient-to-tr from-blue-600 to-teal-500 hover:scale-105 active:scale-95 text-white rounded-full shadow-xl flex items-center justify-center transition-all group relative">
      <i data-lucide="bot" class="w-6 h-6"></i>
      <span class="absolute -top-1 -right-1 w-3.5 h-3.5 bg-rose-500 rounded-full border-2 border-white"></span>
    </button>
  </div>

  <!-- APPLICATION LOGIC JS -->
  <script>
    var contextPath = '${pageContext.request.contextPath}';
    
    // Live inventory data from backend MySQL database
    let inventoryData = ${not empty inventoryJson ? inventoryJson : '[]'};
    // Master catalog commodities (5,385 products)
    let allCatalogProducts = ${not empty catalogProductsJson ? catalogProductsJson : '[]'};

    // Fallback if data array is empty
    if (!inventoryData || inventoryData.length === 0) {
      inventoryData = [
        { id: 93, name: "Acrylic Sheet", qty: 35, min: 50, max: 200, hsn: "392051", status: "Low", auction: "Auction Needed" },
        { id: 3, name: "Aluminum Plates", qty: 82, min: 40, max: 120, hsn: "760611", status: "Medium", auction: "Not Needed" },
        { id: 8, name: "Aluminum Plates", qty: 158, min: 50, max: 200, hsn: "760612", status: "Medium", auction: "Not Needed" },
        { id: 91, name: "Aluminum Section", qty: 80, min: 50, max: 200, hsn: "760429", status: "Medium", auction: "Not Needed" },
        { id: 61, name: "Angle Valve", qty: 100, min: 50, max: 200, hsn: "848180", status: "Medium", auction: "Not Needed" },
        { id: 86, name: "Barbed Wire", qty: 200, min: 50, max: 200, hsn: "731300", status: "High", auction: "Not Needed" },
        { id: 43, name: "Bitumen Primer", qty: 40, min: 50, max: 200, hsn: "270811", status: "Low", auction: "Auction Needed", surge: 7.4, priceCeiling: 2625 },
        { id: 52, name: "Brass Door Handle", qty: 80, min: 50, max: 200, hsn: "830241", status: "Medium", auction: "Not Needed" },
        { id: 100, name: "Bubble Wrap", qty: 60, min: 50, max: 200, hsn: "392310", status: "Medium", auction: "Not Needed" },
        { id: 68, name: "Cable Tie", qty: 150, min: 50, max: 200, hsn: "392690", status: "Medium", auction: "Not Needed" },
        { id: 64, name: "Ceiling Fan", qty: 80, min: 50, max: 200, hsn: "841451", status: "Medium", auction: "Not Needed" },
        { id: 17, name: "Ceramic Floor Tiles", qty: 200, min: 50, max: 200, hsn: "690721", status: "High", auction: "Not Needed" },
        { id: 75, name: "Chain Block 1 Ton", qty: 100, min: 50, max: 200, hsn: "842511", status: "Medium", auction: "Not Needed" },
        { id: 87, name: "Chain Link Mesh", qty: 25, min: 50, max: 200, hsn: "731414", status: "Low", auction: "Auction Needed" },
        { id: 23, name: "Circuit Breaker 32A", qty: 200, min: 50, max: 200, hsn: "853620", status: "High", auction: "Not Needed" },
        { id: 29, name: "Claw Hammer", qty: 101, min: 50, max: 200, hsn: "820520", status: "Medium", auction: "Not Needed" },
        { id: 73, name: "Concrete Mixer", qty: 8, min: 50, max: 200, hsn: "847431", status: "Low", auction: "Auction Needed" },
        { id: 46, name: "Concrete Nail 2 inch", qty: 150, min: 50, max: 200, hsn: "731700", status: "Medium", auction: "Not Needed" },
        { id: 2, name: "Copper Sheets", qty: 71, min: 10, max: 80, hsn: "740911", status: "Medium", auction: "Not Needed" },
        { id: 7, name: "Copper Sheets", qty: 71, min: 50, max: 200, hsn: "740919", status: "Medium", auction: "Not Needed" }
      ];
    }

    // State Variables
    let currentFilter = 'All';
    let currentSearch = '';
    let currentSort = 'id-asc';
    let currentView = 'table';
    let currentPage = 1;
    const pageSize = 10;

    // Initialization
    window.onload = function() {
      lucide.createIcons();
      setupMobileMenu();
      renderApp();
      if (window.location.search.includes('openAdd=true') || window.location.hash === '#addProduct') {
        openAddProductModal();
        const urlParams = new URLSearchParams(window.location.search);
        const searchVal = urlParams.get('q');
        if (searchVal) {
          const inp = document.getElementById('catalogComboboxInput');
          if (inp) {
            inp.value = searchVal;
            openComboboxDropdown();
          }
        }
      }
    };

    function setupMobileMenu() {
      const btn = document.getElementById('mobileMenuBtn');
      const closeBtn = document.getElementById('closeMobileMenu');
      const sidebar = document.getElementById('sidebar');
      const overlay = document.getElementById('mobileOverlay');

      function openMenu() {
        sidebar.classList.remove('-translate-x-full');
        overlay.classList.remove('hidden');
      }
      function closeMenu() {
        sidebar.classList.add('-translate-x-full');
        overlay.classList.add('hidden');
      }

      if(btn) btn.addEventListener('click', openMenu);
      if(closeBtn) closeBtn.addEventListener('click', closeMenu);
      if(overlay) overlay.addEventListener('click', closeMenu);
    }

    // Helper: Recalculate item status
    function recalculateStatus(item) {
      if (item.qty <= item.min) {
        item.status = 'Low';
        item.auction = 'Auction Needed';
      } else if (item.qty >= Math.floor(item.max * 0.85)) {
        item.status = 'High';
        item.auction = 'Not Needed';
      } else {
        item.status = 'Medium';
        item.auction = 'Not Needed';
      }
    }

    // Filter, Search & Sort Logic
    function getFilteredData() {
      return inventoryData.filter(item => {
        // Filter match
        let matchesFilter = true;
        if (currentFilter === 'Auction Needed') matchesFilter = (item.auction === 'Auction Needed' || item.status === 'Low');
        else if (currentFilter === 'Low') matchesFilter = (item.status === 'Low');
        else if (currentFilter === 'Medium') matchesFilter = (item.status === 'Medium');
        else if (currentFilter === 'High') matchesFilter = (item.status === 'High');

        // Search match
        let matchesSearch = true;
        if (currentSearch) {
          const q = currentSearch.toLowerCase();
          matchesSearch = (item.name && item.name.toLowerCase().includes(q)) || 
                          String(item.id).includes(q) || 
                          (item.hsn && item.hsn.toLowerCase().includes(q));
        }

        return matchesFilter && matchesSearch;
      }).sort((a, b) => {
        if (currentSort === 'id-asc') return a.id - b.id;
        if (currentSort === 'name-asc') return (a.name || '').localeCompare(b.name || '');
        if (currentSort === 'qty-asc') return a.qty - b.qty;
        if (currentSort === 'qty-desc') return b.qty - a.qty;
        return 0;
      });
    }

    function renderApp() {
      updateKPIs();
      updateFilterCounts();

      const filtered = getFilteredData();

      if (currentView === 'table') {
        renderTable(filtered);
      } else {
        renderKanban(filtered);
      }

      lucide.createIcons();
    }

    // Update Top KPIs
    function updateKPIs() {
      const total = inventoryData.length || 1;
      const lowCount = inventoryData.filter(i => i.status === 'Low').length;
      const medCount = inventoryData.filter(i => i.status === 'Medium').length;
      const highCount = inventoryData.filter(i => i.status === 'High').length;
      const auctionCount = inventoryData.filter(i => i.auction === 'Auction Needed' || i.status === 'Low').length;
      const healthyTotal = medCount + highCount;

      document.getElementById('kpiTotalCount').innerText = total;
      document.getElementById('kpiLowCount').innerText = lowCount;
      document.getElementById('kpiAuctionCount').innerText = auctionCount;
      document.getElementById('kpiHealthyCount').innerText = healthyTotal;

      document.getElementById('kpiHealthyBreakdown').innerText = medCount + ' Medium · ' + highCount + ' High Level';
      document.getElementById('kpiRatioText').innerText = Math.round((healthyTotal / total) * 100) + '% Healthy';

      document.getElementById('kpiBarHigh').style.width = ((highCount / total) * 100) + '%';
      document.getElementById('kpiBarMed').style.width = ((medCount / total) * 100) + '%';
      document.getElementById('kpiBarLow').style.width = ((lowCount / total) * 100) + '%';
    }

    function updateFilterCounts() {
      document.getElementById('count-All').innerText = inventoryData.length;
      document.getElementById('count-Auction Needed').innerText = inventoryData.filter(i => i.auction === 'Auction Needed' || i.status === 'Low').length;
      document.getElementById('count-Low').innerText = inventoryData.filter(i => i.status === 'Low').length;
      document.getElementById('count-Medium').innerText = inventoryData.filter(i => i.status === 'Medium').length;
      document.getElementById('count-High').innerText = inventoryData.filter(i => i.status === 'High').length;
    }

    // Render Table View
    function renderTable(data) {
      const tbody = document.getElementById('inventoryTableBody');
      const emptyState = document.getElementById('emptyState');
      tbody.innerHTML = '';

      if (data.length === 0) {
        emptyState.classList.remove('hidden');
        document.getElementById('pageStart').innerText = 0;
        document.getElementById('pageEnd').innerText = 0;
        document.getElementById('pageTotal').innerText = 0;
        document.getElementById('paginationControls').innerHTML = '';
        return;
      }

      emptyState.classList.add('hidden');

      // Pagination bounds
      const totalPages = Math.ceil(data.length / pageSize);
      if (currentPage > totalPages) currentPage = 1;
      
      const startIdx = (currentPage - 1) * pageSize;
      const endIdx = Math.min(startIdx + pageSize, data.length);
      const pageData = data.slice(startIdx, endIdx);

      document.getElementById('pageStart').innerText = startIdx + 1;
      document.getElementById('pageEnd').innerText = endIdx;
      document.getElementById('pageTotal').innerText = data.length;

      renderPaginationControls(totalPages);

      pageData.forEach(item => {
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-slate-50/80 transition-colors group';

        const pct = Math.min(100, Math.round((item.qty / (item.max || 1)) * 100));
        
        let statusBadge = '';
        let fillBarColor = 'bg-slate-400';
        if (item.status === 'Low') {
          statusBadge = '<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-rose-100 text-rose-700"><span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>Low</span>';
          fillBarColor = 'bg-rose-500';
        } else if (item.status === 'Medium') {
          statusBadge = '<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800"><span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>Medium</span>';
          fillBarColor = 'bg-amber-400';
        } else {
          statusBadge = '<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800"><span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>High</span>';
          fillBarColor = 'bg-emerald-500';
        }

        let auctionBadge = '';
        if (item.auction === 'Auction Needed' || item.status === 'Low') {
          auctionBadge = '<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-bold bg-rose-50 text-rose-600 border border-rose-200">Auction Needed</span>';
        } else {
          auctionBadge = '<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-semibold bg-slate-100 text-slate-600">Not Needed</span>';
        }

        const isAuctionNeeded = (item.auction === 'Auction Needed' || item.status === 'Low');
        const actionButtons = isAuctionNeeded ? 
          '<div class="flex items-center justify-end space-x-1.5">' +
            '<button onclick="openCreateAuctionModal(' + item.id + ')" class="px-2.5 py-1 text-xs font-bold text-white bg-rose-600 hover:bg-rose-700 rounded-lg shadow-sm transition-all flex items-center gap-1">' +
              '<i data-lucide="gavel" class="w-3.5 h-3.5"></i>' +
              '<span>Create Auction</span>' +
            '</button>' +
            '<button onclick="openAdjustModal(' + item.id + ')" class="p-1.5 text-slate-500 hover:text-blue-600 hover:bg-slate-100 rounded-lg transition-colors" title="Adjust Stock">' +
              '<i data-lucide="sliders" class="w-4 h-4"></i>' +
            '</button>' +
            '<button onclick="deleteItem(' + item.id + ')" class="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors" title="Delete SKU">' +
              '<i data-lucide="trash-2" class="w-4 h-4"></i>' +
            '</button>' +
          '</div>' : 
          '<div class="flex items-center justify-end space-x-1.5">' +
            '<button onclick="openAdjustModal(' + item.id + ')" class="px-2.5 py-1 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-lg transition-colors flex items-center gap-1">' +
              '<i data-lucide="sliders" class="w-3.5 h-3.5"></i>' +
              '<span>Adjust</span>' +
            '</button>' +
            '<button onclick="deleteItem(' + item.id + ')" class="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors" title="Delete SKU">' +
              '<i data-lucide="trash-2" class="w-4 h-4"></i>' +
            '</button>' +
          '</div>';

        tr.innerHTML = 
          '<td class="py-3.5 px-4 font-mono text-slate-500 font-semibold text-center">' + item.id + '</td>' +
          '<td class="py-3.5 px-4">' +
            '<div class="font-bold text-slate-900 group-hover:text-blue-600 transition-colors flex items-center gap-2">' +
              '<span>' + item.name + '</span>' +
              (item.surge ? '<span class="px-1.5 py-0.5 text-[10px] font-black bg-rose-100 text-rose-700 rounded uppercase">AI Alert</span>' : '') +
            '</div>' +
            '<div class="text-xs text-slate-400 font-mono">HSN Code: ' + (item.hsn || 'N/A') + '</div>' +
          '</td>' +
          '<td class="py-3.5 px-4">' +
            '<div class="flex items-center justify-between text-xs mb-1">' +
              '<span class="font-mono font-bold text-slate-800">' + item.qty + ' ' + (item.unit || 'units') + '</span>' +
              '<span class="text-slate-400 font-mono text-[11px]">' + item.min + ' min / ' + item.max + ' max</span>' +
            '</div>' +
            '<div class="w-full h-2 bg-slate-100 rounded-full overflow-hidden relative">' +
              '<div class="h-full ' + fillBarColor + ' transition-all duration-300" style="width: ' + pct + '%"></div>' +
            '</div>' +
          '</td>' +
          '<td class="py-3.5 px-4">' + statusBadge + '</td>' +
          '<td class="py-3.5 px-4">' + auctionBadge + '</td>' +
          '<td class="py-3.5 px-4 text-right">' + actionButtons + '</td>';

        tbody.appendChild(tr);
      });
    }

    // Render Pagination Controls
    function renderPaginationControls(totalPages) {
      const container = document.getElementById('paginationControls');
      container.innerHTML = '';

      if (totalPages <= 1) return;

      const prevBtn = document.createElement('button');
      prevBtn.className = 'p-1 rounded-lg border text-xs font-semibold ' + (currentPage === 1 ? 'text-slate-300 border-slate-200 cursor-not-allowed' : 'text-slate-600 border-slate-300 hover:bg-slate-100');
      prevBtn.innerHTML = '<i data-lucide="chevron-left" class="w-4 h-4"></i>';
      prevBtn.onclick = function() { if(currentPage > 1) { currentPage--; renderApp(); } };
      container.appendChild(prevBtn);

      for (let i = 1; i <= totalPages; i++) {
        const btn = document.createElement('button');
        btn.className = 'px-2.5 py-1 rounded-lg text-xs font-bold ' + (currentPage === i ? 'bg-blue-600 text-white' : 'text-slate-600 hover:bg-slate-100');
        btn.innerText = i;
        btn.onclick = (function(page) { return function() { currentPage = page; renderApp(); }; })(i);
        container.appendChild(btn);
      }

      const nextBtn = document.createElement('button');
      nextBtn.className = 'p-1 rounded-lg border text-xs font-semibold ' + (currentPage === totalPages ? 'text-slate-300 border-slate-200 cursor-not-allowed' : 'text-slate-600 border-slate-300 hover:bg-slate-100');
      nextBtn.innerHTML = '<i data-lucide="chevron-right" class="w-4 h-4"></i>';
      nextBtn.onclick = function() { if(currentPage < totalPages) { currentPage++; renderApp(); } };
      container.appendChild(nextBtn);
    }

    // Render Kanban View
    function renderKanban(data) {
      const lowCol = document.getElementById('kanbanLowCol');
      const medCol = document.getElementById('kanbanMedCol');
      const highCol = document.getElementById('kanbanHighCol');

      lowCol.innerHTML = '';
      medCol.innerHTML = '';
      highCol.innerHTML = '';

      const lowItems = data.filter(i => i.status === 'Low');
      const medItems = data.filter(i => i.status === 'Medium');
      const highItems = data.filter(i => i.status === 'High');

      document.getElementById('kanbanCountLow').innerText = lowItems.length;
      document.getElementById('kanbanCountMed').innerText = medItems.length;
      document.getElementById('kanbanCountHigh').innerText = highItems.length;

      function createKanbanCard(item) {
        const card = document.createElement('div');
        card.className = 'bg-white rounded-xl p-3.5 border border-slate-200 shadow-sm hover:shadow-md transition-all space-y-2';
        
        const pct = Math.min(100, Math.round((item.qty / (item.max || 1)) * 100));
        const isAuction = (item.auction === 'Auction Needed' || item.status === 'Low');

        card.innerHTML = 
          '<div class="flex items-start justify-between">' +
            '<span class="font-mono text-xs text-slate-400 font-semibold">ID: #' + item.id + '</span>' +
            (isAuction ? '<span class="px-2 py-0.5 text-[10px] font-black bg-rose-100 text-rose-700 rounded">Auction Trigger</span>' : '') +
          '</div>' +
          '<h4 class="font-bold text-slate-900 text-sm">' + item.name + '</h4>' +
          '<div class="text-xs text-slate-500 flex justify-between">' +
            '<span>Stock: <strong class="text-slate-800">' + item.qty + '</strong> ' + (item.unit || 'units') + '</span>' +
            '<span>Min: ' + item.min + '</span>' +
          '</div>' +
          '<div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">' +
            '<div class="h-full ' + (item.status === 'Low' ? 'bg-rose-500' : item.status === 'Medium' ? 'bg-amber-400' : 'bg-emerald-500') + '" style="width: ' + pct + '%"></div>' +
          '</div>' +
          '<div class="pt-2 border-t border-slate-100 flex items-center justify-between text-xs">' +
            '<button onclick="openAdjustModal(' + item.id + ')" class="text-slate-600 font-semibold hover:text-blue-600">' +
              'Adjust Stock' +
            '</button>' +
            (isAuction ? 
              '<button onclick="openCreateAuctionModal(' + item.id + ')" class="px-2.5 py-1 text-[11px] font-bold text-white bg-rose-600 rounded-lg hover:bg-rose-700">' +
                'Launch Auction' +
              '</button>' : '') +
          '</div>';
        return card;
      }

      lowItems.forEach(item => lowCol.appendChild(createKanbanCard(item)));
      medItems.forEach(item => medCol.appendChild(createKanbanCard(item)));
      highItems.forEach(item => highCol.appendChild(createKanbanCard(item)));
    }

    // Handlers & View Toggles
    function switchView(view) {
      currentView = view;
      const tableBtn = document.getElementById('viewTableBtn');
      const kanbanBtn = document.getElementById('viewKanbanBtn');
      const tableView = document.getElementById('tableView');
      const kanbanView = document.getElementById('kanbanView');

      if (view === 'table') {
        tableView.classList.remove('hidden');
        kanbanView.classList.add('hidden');
        tableBtn.className = 'p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 bg-white text-slate-900 shadow-sm transition-all';
        kanbanBtn.className = 'p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-all';
      } else {
        tableView.classList.add('hidden');
        kanbanView.classList.remove('hidden');
        kanbanBtn.className = 'p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 bg-white text-slate-900 shadow-sm transition-all';
        tableBtn.className = 'p-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-all';
      }
      renderApp();
    }

    function setFilter(filter) {
      currentFilter = filter;
      document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.className = 'filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-all';
      });
      const activeBtn = document.getElementById('filter-' + filter);
      if(activeBtn) {
        activeBtn.className = 'filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold transition-all bg-slate-900 text-white shadow-sm';
      }
      currentPage = 1;
      renderApp();
    }

    function handleSearch() {
      currentSearch = document.getElementById('searchInput').value.trim();
      currentPage = 1;
      renderApp();
    }

    function handleSort() {
      currentSort = document.getElementById('sortSelect').value;
      renderApp();
    }

    function resetFilters() {
      document.getElementById('searchInput').value = '';
      document.getElementById('sortSelect').value = 'id-asc';
      currentSearch = '';
      currentSort = 'id-asc';
      setFilter('All');
    }

    // Modal Actions
    function openCreateAuctionModal(itemId) {
      const item = inventoryData.find(i => i.id === itemId);
      if(!item) return;

      document.getElementById('aucItemId').value = item.id;
      document.getElementById('aucItemName').value = item.name + ' (ID: #' + item.id + ')';
      document.getElementById('aucCurrentStock').value = item.qty + ' ' + (item.unit || 'units') + ' (Min: ' + item.min + ')';
      document.getElementById('aucOrderQty').value = Math.max(1, (item.max || 100) - item.qty);
      document.getElementById('aucTargetPrice').value = item.priceCeiling || (item.price || 2625);

      document.getElementById('auctionModal').classList.remove('hidden');
    }

    function triggerSurgeAuction() {
      const surgeItem = inventoryData.find(i => (i.surge || (i.name && i.name.toLowerCase().includes('bitumen'))));
      if (surgeItem) {
        openCreateAuctionModal(surgeItem.id);
      } else {
        openCreateAuctionModal(inventoryData[0].id);
      }
    }

    function closeAuctionModal() {
      document.getElementById('auctionModal').classList.add('hidden');
    }

    function handleAuctionSubmit(e) {
      e.preventDefault();
      const itemId = parseInt(document.getElementById('aucItemId').value);
      const item = inventoryData.find(i => i.id === itemId);
      const orderQty = document.getElementById('aucOrderQty').value;
      const targetPrice = document.getElementById('aucTargetPrice').value;
      const duration = document.getElementById('aucDuration').value;

      showToast('Broadcasting reverse auction for <strong>' + (item ? item.name : 'SKU #' + itemId) + '</strong>...', 'success');
      
      // Submit to backend
      $.ajax({
        url: contextPath + '/inventory',
        type: 'POST',
        data: {
          action: 'startAuction',
          itemId: itemId
        },
        complete: function() {
          if (item) {
            item.auctionStarted = true;
            item.auction = 'In Auction';
          }
          closeAuctionModal();
          renderApp();
          setTimeout(function() {
            window.location.href = contextPath + '/auction?action=new&inventoryId=' + itemId +
              '&commodity=' + encodeURIComponent(item ? item.name : '') +
              '&hsn=' + encodeURIComponent(item && item.hsn ? item.hsn : '') +
              '&qty=' + orderQty + '&ceiling=' + targetPrice + '&duration=' + duration;
          }, 800);
        }
      });
    }

    function openAdjustModal(itemId) {
      const item = inventoryData.find(i => i.id === itemId);
      if(!item) return;

      document.getElementById('adjItemId').value = item.id;
      document.getElementById('adjItemName').value = item.name;
      document.getElementById('adjQuantity').value = item.qty;
      document.getElementById('adjMin').value = item.min;
      document.getElementById('adjMax').value = item.max;

      document.getElementById('adjustModal').classList.remove('hidden');
    }

    function closeAdjustModal() {
      document.getElementById('adjustModal').classList.add('hidden');
    }

    function handleAdjustSubmit(e) {
      e.preventDefault();
      const itemId = parseInt(document.getElementById('adjItemId').value);
      const newQty = parseInt(document.getElementById('adjQuantity').value);
      const newMin = parseInt(document.getElementById('adjMin').value);
      const newMax = parseInt(document.getElementById('adjMax').value);
      const item = inventoryData.find(i => i.id === itemId);

      $.ajax({
        url: contextPath + '/inventory',
        type: 'POST',
        data: {
          action: 'update',
          id: itemId,
          quantity: newQty,
          minThreshold: newMin,
          maxThreshold: newMax
        },
        complete: function() {
          if (item) {
            item.qty = newQty;
            item.min = newMin;
            item.max = newMax;
            recalculateStatus(item);
          }
          closeAdjustModal();
          renderApp();
          showToast('Updated stock levels for <strong>' + (item ? item.name : 'SKU #' + itemId) + '</strong>.', 'success');
        }
      });
    }

    function escapeHtml(str) {
      if (!str) return '';
      return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function openComboboxDropdown() {
      const dd = document.getElementById('comboboxDropdown');
      const ch = document.getElementById('comboboxChevron');
      if (!dd) return;
      dd.classList.remove('hidden');
      if (ch) ch.classList.add('rotate-180');

      const q = document.getElementById('catalogComboboxInput').value.trim();
      filterAndRenderCombobox(q);
      lucide.createIcons();
    }

    function closeComboboxDropdown() {
      const dd = document.getElementById('comboboxDropdown');
      const ch = document.getElementById('comboboxChevron');
      if (!dd) return;
      dd.classList.add('hidden');
      if (ch) ch.classList.remove('rotate-180');
    }

    function toggleComboboxDropdown(e) {
      if (e) e.stopPropagation();
      const dd = document.getElementById('comboboxDropdown');
      if (dd && !dd.classList.contains('hidden')) {
        closeComboboxDropdown();
      } else {
        openComboboxDropdown();
      }
    }

    function onComboboxInput(val) {
      openComboboxDropdown();
      filterAndRenderCombobox(val);
    }

    function filterAndRenderCombobox(q) {
      const container = document.getElementById('comboboxList');
      const statusText = document.getElementById('comboboxStatusText');
      if (!container) return;

      const term = (q || '').trim().toLowerCase();
      let matches = [];

      if (!term || term.includes('[hsn:')) {
        matches = allCatalogProducts.slice(0, 50);
        if (statusText) statusText.innerText = 'Showing top commodities (' + allCatalogProducts.length + ' total)';
      } else {
        for (let i = 0; i < allCatalogProducts.length; i++) {
          const item = allCatalogProducts[i];
          const text = ((item.name || '') + ' ' + (item.hsnCode || '') + ' ' + (item.category || '')).toLowerCase();
          if (text.includes(term)) {
            matches.push(item);
            if (matches.length >= 60) break;
          }
        }
        if (statusText) statusText.innerText = matches.length + (matches.length === 60 ? '+ matching commodities' : ' matching commodities');
      }

      container.innerHTML = '';
      if (matches.length === 0) {
        container.innerHTML = '<div class="px-3 py-4 text-center text-xs text-slate-400">No commodities found matching "' + escapeHtml(term) + '".<br><span class="text-blue-600 font-semibold cursor-pointer" onclick="selectCustomItem()">Click here to add as custom item</span></div>';
        return;
      }

      matches.forEach(item => {
        const row = document.createElement('div');
        row.className = 'px-3 py-2 hover:bg-slate-100 rounded-lg cursor-pointer transition-colors group';
        row.innerHTML = 
          '<div class="flex items-center justify-between gap-2">' +
            '<div class="font-bold text-xs text-slate-800 group-hover:text-blue-600 truncate max-w-[340px]" title="' + escapeHtml(item.name) + '">' +
              escapeHtml(item.name) +
            '</div>' +
            '<span class="px-1.5 py-0.5 rounded text-[10px] font-mono font-bold bg-slate-100 text-slate-600 group-hover:bg-blue-100 group-hover:text-blue-700 shrink-0">' +
              'HSN ' + (item.hsnCode || 'N/A') +
            '</span>' +
          '</div>' +
          '<div class="text-[11px] text-slate-400 truncate mt-0.5">' +
            escapeHtml(item.category || 'General') + ' · Unit: ' + (item.unit || 'pcs') +
          '</div>';

        row.onclick = function(e) {
          e.stopPropagation();
          selectCatalogItem(item);
        };
        container.appendChild(row);
      });
    }

    function selectCatalogItem(item) {
      document.getElementById('catalogComboboxInput').value = item.name + ' [HSN: ' + (item.hsnCode || 'N/A') + ']';
      document.getElementById('selectedProductId').value = item.id;
      document.getElementById('selectedProductPrice').value = item.basePrice || 1000;
      document.getElementById('addCategory').value = item.category || 'General';
      document.getElementById('addUnit').value = item.unit || 'pcs';
      document.getElementById('addHSN').value = item.hsnCode || '';
      
      document.getElementById('customNameRow').style.display = 'none';
      document.getElementById('clearComboboxBtn').classList.remove('hidden');
      closeComboboxDropdown();
      updateAddKanbanPreview();
    }

    function selectCustomItem() {
      document.getElementById('catalogComboboxInput').value = '➕ Custom Raw Material / Item';
      document.getElementById('selectedProductId').value = 'CUSTOM';
      document.getElementById('selectedProductPrice').value = 1000;
      
      document.getElementById('customNameRow').style.display = 'block';
      const nameInput = document.getElementById('addName');
      nameInput.value = '';
      nameInput.focus();
      document.getElementById('addCategory').value = '';
      document.getElementById('addUnit').value = 'pcs';
      document.getElementById('addHSN').value = '';
      
      document.getElementById('clearComboboxBtn').classList.remove('hidden');
      closeComboboxDropdown();
      updateAddKanbanPreview();
    }

    function clearCatalogSelection(e) {
      if (e) e.stopPropagation();
      document.getElementById('catalogComboboxInput').value = '';
      document.getElementById('selectedProductId').value = '';
      document.getElementById('selectedProductPrice').value = 1000;
      document.getElementById('addCategory').value = '';
      document.getElementById('addUnit').value = '';
      document.getElementById('addHSN').value = '';
      document.getElementById('customNameRow').style.display = 'none';
      document.getElementById('clearComboboxBtn').classList.add('hidden');
      updateAddKanbanPreview();
      openComboboxDropdown();
    }

    document.addEventListener('click', function(e) {
      const wrapper = document.getElementById('comboboxWrapper');
      if (wrapper && !wrapper.contains(e.target)) {
        closeComboboxDropdown();
      }
    });

    function updateAddKanbanPreview() {
      const qty = parseInt(document.getElementById('addQty').value) || 0;
      const min = parseInt(document.getElementById('addMin').value) || 0;
      const max = parseInt(document.getElementById('addMax').value) || 0;
      const preview = document.getElementById('kanbanPreviewStatus');
      if (!preview) return;

      if (qty <= min) {
        preview.innerHTML = '<span class="text-rose-600 font-bold">⚠️ Warning: Initial stock (' + qty + ') &le; Min Threshold (' + min + '). Will be flagged as Low Stock with Auction Needed!</span>';
      } else if (qty >= Math.floor(max * 0.85)) {
        preview.innerHTML = '<span class="text-emerald-600 font-bold">✓ High Stock: Initial stock (' + qty + ') is healthy and near capacity (' + max + ').</span>';
      } else {
        preview.innerHTML = '<span class="text-amber-700 font-bold">✓ Normal Stock: Initial stock (' + qty + ') is balanced between min (' + min + ') and max (' + max + ').</span>';
      }
    }

    function openAddProductModal() {
      document.getElementById('addProductForm').reset();
      clearCatalogSelection();
      closeComboboxDropdown();
      document.getElementById('addQty').value = 100;
      document.getElementById('addMin').value = 40;
      document.getElementById('addMax').value = 200;
      updateAddKanbanPreview();
      document.getElementById('addProductModal').classList.remove('hidden');
      lucide.createIcons();
    }

    function closeAddProductModal() {
      closeComboboxDropdown();
      document.getElementById('addProductModal').classList.add('hidden');
    }

    function handleAddProductSubmit(e) {
      e.preventDefault();
      const selVal = document.getElementById('selectedProductId').value;
      let productId = '';
      let itemName = '';
      let priceVal = parseFloat(document.getElementById('selectedProductPrice').value) || 1000;

      if (selVal === 'CUSTOM' || (!selVal && document.getElementById('addName').value.trim())) {
        itemName = document.getElementById('addName').value.trim();
        if (!itemName) {
          showToast('Please enter a custom product / item name', 'error');
          return;
        }
      } else if (selVal) {
        productId = selVal;
        const comboInput = document.getElementById('catalogComboboxInput').value;
        itemName = comboInput.split(' [HSN:')[0].trim();
      } else {
        showToast('Please choose a catalog commodity or enter a custom item', 'error');
        return;
      }

      const category = document.getElementById('addCategory').value.trim();
      const unit = document.getElementById('addUnit').value.trim() || 'pcs';
      const hsn = document.getElementById('addHSN').value.trim();
      const qty = parseInt(document.getElementById('addQty').value) || 0;
      const min = parseInt(document.getElementById('addMin').value) || 0;
      const max = parseInt(document.getElementById('addMax').value) || 0;

      if (min >= max) {
        showToast('Min Threshold must be less than Max Threshold (Capacity)', 'error');
        return;
      }

      $.ajax({
        url: contextPath + '/inventory',
        type: 'POST',
        data: {
          action: 'add',
          productId: productId,
          itemName: itemName,
          category: category,
          unit: unit,
          hsn: hsn,
          price: priceVal,
          quantity: qty,
          minThreshold: min,
          maxThreshold: max,
          ajax: 'true'
        },
        dataType: 'json',
        success: function(resp) {
          const newId = (resp && resp.itemId) ? resp.itemId : (Math.max(...inventoryData.map(i => i.id), 0) + 1);
          const newItem = {
            id: newId,
            name: itemName,
            category: category,
            unit: unit,
            qty: qty,
            min: min,
            max: max,
            hsn: hsn || (resp && resp.hsnCode ? resp.hsnCode : 'N/A'),
            status: 'Medium',
            auction: 'Not Needed',
            price: priceVal
          };
          recalculateStatus(newItem);
          inventoryData.unshift(newItem);
          closeAddProductModal();
          renderApp();
          showToast('Successfully added <strong>' + itemName + '</strong> to inventory!', 'success');
        },
        error: function() {
          showToast('Added <strong>' + itemName + '</strong> to inventory.', 'success');
          setTimeout(function() { window.location.reload(); }, 600);
        }
      });
    }

    function deleteItem(itemId) {
      const item = inventoryData.find(i => i.id === itemId);
      if(!item) return;

      if(confirm('Are you sure you want to remove ' + item.name + ' from inventory?')) {
        $.ajax({
          url: contextPath + '/inventory',
          type: 'POST',
          data: {
            action: 'delete',
            id: itemId
          },
          complete: function() {
            inventoryData = inventoryData.filter(i => i.id !== itemId);
            renderApp();
            showToast('Item #' + itemId + ' (' + item.name + ') removed from inventory.', 'warning');
          }
        });
      }
    }

    // CSV Export
    function exportCSV() {
      let csvContent = "data:text/csv;charset=utf-8,ID,Item Name,HSN Code,Quantity,Min Threshold,Max Threshold,Kanban Status,Auction Status\n";
      inventoryData.forEach(i => {
        csvContent += i.id + ',"' + (i.name || '').replace(/"/g, '""') + '",' + (i.hsn || '') + ',' + i.qty + ',' + i.min + ',' + i.max + ',' + i.status + ',' + i.auction + "\n";
      });
      const encodedUri = encodeURI(csvContent);
      const link = document.createElement("a");
      link.setAttribute("href", encodedUri);
      link.setAttribute("download", "Supplexio_Inventory_Export_" + new Date().toISOString().slice(0,10) + ".csv");
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      showToast('Inventory report downloaded as CSV.', 'info');
    }

    // AI Assistant Chat Widget
    function toggleAIChat() {
      const win = document.getElementById('aiChatWindow');
      win.classList.toggle('hidden');
    }

    function sendAIMessage() {
      const input = document.getElementById('aiInput');
      const text = input.value.trim();
      if(!text) return;

      const container = document.getElementById('aiChatMessages');
      
      // User bubble
      const userMsg = document.createElement('div');
      userMsg.className = 'bg-blue-600 text-white p-2.5 rounded-xl ml-6 text-xs shadow-sm';
      userMsg.innerText = text;
      container.appendChild(userMsg);

      input.value = '';
      container.scrollTop = container.scrollHeight;

      // Simulated AI response
      setTimeout(() => {
        const aiMsg = document.createElement('div');
        aiMsg.className = 'bg-white p-3 rounded-xl border border-slate-200 shadow-sm text-slate-700 text-xs';
        aiMsg.innerText = 'Analyzing your request: "' + text + '". Supplexio 1D-ResNet Trade Engine recommends locking in reverse auction ceilings for low-buffer raw materials to avoid 30-day projected commodity surges.';
        container.appendChild(aiMsg);
        container.scrollTop = container.scrollHeight;
      }, 600);
    }

    // Toast Notification System
    function showToast(message, type = 'info') {
      const container = document.getElementById('toastContainer');
      const toast = document.createElement('div');

      let borderClass = 'border-blue-500 bg-slate-900 text-white';
      if (type === 'success') borderClass = 'border-emerald-500 bg-slate-900 text-white';
      if (type === 'warning') borderClass = 'border-amber-500 bg-slate-900 text-white';

      toast.className = 'pointer-events-auto flex items-center justify-between p-3.5 rounded-xl border-l-4 shadow-xl ' + borderClass + ' text-xs min-w-[280px] max-w-sm transition-all transform translate-y-2 opacity-0 duration-200';
      toast.innerHTML = 
        '<div class="flex items-center space-x-2">' +
          '<i data-lucide="' + (type === 'success' ? 'check-circle-2' : type === 'warning' ? 'alert-triangle' : 'info') + '" class="w-4 h-4 text-teal-400"></i>' +
          '<div>' + message + '</div>' +
        '</div>' +
        '<button onclick="this.parentElement.remove()" class="text-slate-400 hover:text-white ml-2">' +
          '<i data-lucide="x" class="w-3.5 h-3.5"></i>' +
        '</button>';

      container.appendChild(toast);
      lucide.createIcons();

      setTimeout(() => {
        toast.classList.remove('translate-y-2', 'opacity-0');
      }, 10);

      setTimeout(() => {
        toast.classList.add('opacity-0', 'translate-y-2');
        setTimeout(() => toast.remove(), 200);
      }, 4000);
    }
  
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
            success: function(res) {
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
            error: function(xhr) {
                btn.disabled = false;
                btn.innerHTML = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg><span>Save Account Changes</span>';
                let err = 'Server communication error';
                try {
                    const r = JSON.parse(xhr.responseText);
                    if (r.error) err = r.error;
                } catch(e) {}
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

  </script>

  <!-- USER PROFILE & SECURITY SETTINGS MODAL -->
  <div id="userProfileModal" class="fixed inset-0 z-[120] hidden items-center justify-center p-4">
      <div class="fixed inset-0 bg-slate-950/70 backdrop-blur-sm transition-opacity" onclick="closeUserProfileModal()"></div>
      <div class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden transform transition-all z-10 animate-in fade-in zoom-in-95 duration-150">
          <div class="px-6 py-4.5 bg-gradient-to-r from-[#0B1E3D] via-[#172E6E] to-[#0B1E3D] text-white flex items-center justify-between border-b border-blue-900/40">
              <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 rounded-xl bg-teal-500/20 border border-teal-500/40 flex items-center justify-center text-[#2DD4BF]">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                  </div>
                  <div>
                      <h3 class="text-sm font-bold tracking-tight text-white">Account Settings & Security</h3>
                      <p class="text-[10px] text-teal-400 font-mono tracking-wider uppercase font-semibold">SUPPLEXIO PROFILE MANAGEMENT</p>
                  </div>
              </div>
              <button type="button" onclick="closeUserProfileModal()" class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-white/10 transition">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
          </div>
          <div class="p-6 space-y-4 text-slate-800">
              <div id="profileModalAlert" class="hidden p-3 rounded-xl text-xs font-semibold"></div>
              <div>
                  <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                      Username <span class="text-rose-500">*</span>
                  </label>
                  <input type="text" id="profileModalUsername" value="<%= session.getAttribute("username") != null ? session.getAttribute("username") : "admin" %>" 
                         class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition" 
                         placeholder="Enter username" />
                  <p class="text-[11px] text-slate-400 mt-1">Primary sign-in and account identifier across Supplexio.</p>
              </div>
              <div>
                  <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Email Address</label>
                  <input type="email" id="profileModalEmail" value="<%= session.getAttribute("userEmail") != null ? session.getAttribute("userEmail") : "admin@example.com" %>" 
                         class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition" 
                         placeholder="admin@example.com" />
              </div>
              <div class="pt-2 border-t border-slate-200">
                  <span class="text-xs font-bold text-slate-900 flex items-center gap-1.5">
                      <svg class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
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
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                  <span>Save Account Changes</span>
              </button>
          </div>
      </div>
  </div>

</body>
</html>
