<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat displayFmt = new SimpleDateFormat("dd MMM yyyy, HH:mm");

    JSONArray poJsonArray = new JSONArray();
    if (poList != null) {
        for (Object obj : poList) {
            Class<?> beanClass = obj.getClass();
            long id = ((Number) beanClass.getMethod("getId").invoke(obj)).longValue();
            long auctionId = 0;
            try { auctionId = ((Number) beanClass.getMethod("getAuctionId").invoke(obj)).longValue(); } catch (Exception ignored) {}
            long supplierId = 0;
            try { supplierId = ((Number) beanClass.getMethod("getSupplierId").invoke(obj)).longValue(); } catch (Exception ignored) {}
            String supplier = (String) beanClass.getMethod("getCompanyName").invoke(obj);
            if (supplier == null || supplier.trim().isEmpty()) {
                supplier = (String) beanClass.getMethod("getSupplierName").invoke(obj);
            }
            String material = (String) beanClass.getMethod("getMaterial").invoke(obj);
            double amount = ((Number) beanClass.getMethod("getAmount").invoke(obj)).doubleValue();
            int qty = 1;
            try { qty = ((Number) beanClass.getMethod("getQuantity").invoke(obj)).intValue(); } catch (Exception ignored) {}
            int receivedQty = 0;
            try { receivedQty = ((Number) beanClass.getMethod("getReceivedQuantity").invoke(obj)).intValue(); } catch (Exception ignored) {}
            String status = (String) beanClass.getMethod("getStatus").invoke(obj);
            if (status == null || status.trim().isEmpty()) status = "PO_DRAFT";
            if ("COMPLETED".equalsIgnoreCase(status) || "PENDING".equalsIgnoreCase(status)) status = "PO_DRAFT";
            if ("SENT".equalsIgnoreCase(status)) status = "PO_SENT";
            if ("PAID".equalsIgnoreCase(status)) status = "PAYMENT_SUCCESSFUL";
            java.util.Date createdAt = (java.util.Date) beanClass.getMethod("getCreatedAt").invoke(obj);

            double gst = amount * 0.075;
            double total = amount + gst;

            JSONObject item = new JSONObject();
            item.put("id", id);
            item.put("auctionId", auctionId);
            item.put("supplierId", supplierId);
            item.put("supplier", supplier != null ? supplier : "Unknown Supplier");
            item.put("material", material != null ? material : "Material");
            item.put("amount", amount);
            item.put("quantity", qty);
            item.put("receivedQuantity", receivedQty);
            item.put("gst", gst);
            item.put("total", total);
            item.put("status", status);
            item.put("created_at", createdAt != null ? displayFmt.format(createdAt) : "Recent");
            item.put("raw_date", createdAt != null ? createdAt.getTime() : 0);
            poJsonArray.add(item);
        }
    }
    String errorMsg = (String) session.getAttribute("error");
    if (errorMsg != null) session.removeAttribute("error");
    String successMsg = (String) session.getAttribute("success");
    if (successMsg != null) session.removeAttribute("success");
%>
<!DOCTYPE html>
<html lang="en" class="h-full bg-[#F4F7FC]">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio - Enterprise Purchase Orders</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Lucide Icons CDN -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
                    },
                    colors: {
                        brand: {
                            navy: '#0B1E3D',
                            royalDark: '#172E6E',
                            royalMid: '#1E3E96',
                            royalBase: '#1B3680',
                            royalAccent: '#2563EB',
                            cyan: '#2DD4BF',
                            amber: '#F59E0B',
                            amberHover: '#D97706',
                            iceBg: '#F4F7FC',
                        }
                    }
                }
            }
        }
    </script>

    <style>
        ::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        ::-webkit-scrollbar-track {
            background: #F1F5F9;
        }
        ::-webkit-scrollbar-thumb {
            background: #CBD5E1;
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #94A3B8;
        }
        .tabular-nums {
            font-variant-numeric: tabular-nums;
        }
        @media print {
            body * {
                visibility: hidden;
            }
            #printable-document, #printable-document * {
                visibility: visible;
            }
            #printable-document {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
            }
        }
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
                <a href="${pageContext.request.contextPath}/inventory" class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <i data-lucide="boxes" class="w-4 h-4 text-slate-300"></i>
                    <span>Inventory Management</span>
                </a>
                <a href="http://localhost:8501" target="_blank" class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline text-slate-200 hover:bg-white/10 hover:text-white">
                    <div class="flex items-center gap-3">
                        <i data-lucide="globe-2" class="w-4 h-4 text-[#2DD4BF]"></i>
                        <span>Global Trade Intel</span>
                    </div>
                    <span class="w-2 h-2 rounded-full bg-[#2DD4BF] animate-pulse"></span>
                </a>
                <a href="${pageContext.request.contextPath}/user-po-view" class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors no-underline bg-white/15 text-white font-semibold shadow-inner border border-white/20 backdrop-blur-sm">
                    <div class="flex items-center gap-3">
                        <i data-lucide="file-text" class="w-4 h-4 text-[#2DD4BF]"></i>
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

            <!-- GLOBAL BAR -->
            <header class="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between sticky top-0 z-10 shadow-sm">
                <div class="flex items-center gap-3">
                    <div class="bg-blue-50 text-brand-royalMid p-2 rounded-lg border border-blue-100">
                        <i data-lucide="file-check-2" class="w-5 h-5"></i>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-slate-900 tracking-tight flex items-center gap-2">
                            Purchase Orders
                            <span class="text-xs font-medium bg-emerald-100 text-emerald-800 px-2 py-0.5 rounded-full border border-emerald-200">GST Compliance 7.5% Active</span>
                        </h1>
                        <p class="text-xs text-slate-500">Track purchase orders, audit supplier transmissions, verify GST compliance, and manage billing documents.</p>
                    </div>
                </div>

                <div class="flex items-center gap-3">
                    <button onclick="exportToCSV()" class="bg-white hover:bg-slate-50 text-slate-700 border border-slate-300 text-xs font-semibold px-3.5 py-2 rounded-lg flex items-center gap-2 shadow-sm transition-all">
                        <i data-lucide="download" class="w-3.5 h-3.5 text-slate-500"></i>
                        <span>Export CSV</span>
                    </button>
                    <a href="${pageContext.request.contextPath}/auction" class="bg-brand-royalMid hover:bg-brand-royalDark text-white text-xs font-bold px-4 py-2 rounded-lg flex items-center gap-2 shadow-md transition-all active:scale-95 no-underline">
                        <i data-lucide="gavel" class="w-4 h-4"></i>
                        <span>Reverse Auctions</span>
                    </a>
                </div>
            </header>

            <!-- SESSION ALERTS -->
            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="mx-6 mt-4 p-3 bg-red-50 border border-red-200 rounded-xl text-red-800 text-xs flex items-center justify-between shadow-sm">
                    <div class="flex items-center gap-2">
                        <i data-lucide="alert-circle" class="w-4 h-4 text-red-600"></i>
                        <span><%= errorMsg %></span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700">&times;</button>
                </div>
            <% } %>
            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="mx-6 mt-4 p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-emerald-800 text-xs flex items-center justify-between shadow-sm">
                    <div class="flex items-center gap-2">
                        <i data-lucide="check-circle-2" class="w-4 h-4 text-emerald-600"></i>
                        <span><%= successMsg %></span>
                    </div>
                    <button onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700">&times;</button>
                </div>
            <% } %>

            <div class="p-6 space-y-6 flex-1">

                <!-- KPI Metrics Grid -->
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                    
                    <!-- KPI 1: Total Committed Volume -->
                    <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow relative overflow-hidden group">
                        <div class="flex items-center justify-between text-slate-500 mb-1">
                            <span class="text-xs font-semibold uppercase tracking-wider">Total Value</span>
                            <i data-lucide="banknote" class="w-4 h-4 text-brand-royalMid"></i>
                        </div>
                        <div class="flex items-baseline gap-2">
                            <span id="kpi-total-val" class="text-2xl font-extrabold text-slate-900 font-mono tabular-nums">₹ 0.00</span>
                        </div>
                        <div class="mt-2 text-[11px] text-slate-500 flex items-center justify-between">
                            <span>Total System POs</span>
                            <span id="kpi-total-count" class="font-mono font-bold text-slate-700">0 orders</span>
                        </div>
                    </div>

                    <!-- KPI 2: Action Required (Audit / Pending) -->
                    <div onclick="filterByStatusQuick('ACTION_REQ')" class="bg-white p-4 rounded-xl border border-amber-200 bg-amber-50/20 shadow-sm hover:shadow-md transition-shadow cursor-pointer relative overflow-hidden group">
                        <div class="absolute top-0 right-0 w-2 h-full bg-amber-500"></div>
                        <div class="flex items-center justify-between text-amber-700 mb-1">
                            <span class="text-xs font-semibold uppercase tracking-wider">Action Required</span>
                            <i data-lucide="alert-triangle" class="w-4 h-4 text-amber-500"></i>
                        </div>
                        <div class="flex items-baseline gap-2">
                            <span id="kpi-pending-count" class="text-2xl font-extrabold text-amber-900 font-mono tabular-nums">0</span>
                            <span class="text-xs text-amber-700 font-semibold">orders</span>
                        </div>
                        <p class="mt-2 text-[11px] text-amber-800">Pending Executive Audit</p>
                    </div>

                    <!-- KPI 3: In Transit / Shipped -->
                    <div onclick="filterByStatusQuick('SENT')" class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow cursor-pointer relative overflow-hidden group">
                        <div class="flex items-center justify-between text-slate-500 mb-1">
                            <span class="text-xs font-semibold uppercase tracking-wider">In-Transit / Shipped</span>
                            <i data-lucide="truck" class="w-4 h-4 text-indigo-600"></i>
                        </div>
                        <div class="flex items-baseline gap-2">
                            <span id="kpi-sent-val" class="text-2xl font-extrabold text-slate-900 font-mono tabular-nums">₹ 0.00</span>
                        </div>
                        <div class="mt-2 text-[11px] text-slate-500 flex items-center justify-between">
                            <span>Active Inbound</span>
                            <span id="kpi-sent-count" class="font-mono font-bold text-slate-700">0 orders</span>
                        </div>
                    </div>

                    <!-- KPI 4: Settled / Delivered -->
                    <div onclick="filterByStatusQuick('SETTLED')" class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow cursor-pointer relative overflow-hidden group">
                        <div class="flex items-center justify-between text-slate-500 mb-1">
                            <span class="text-xs font-semibold uppercase tracking-wider">Settled & Closed</span>
                            <i data-lucide="check-check" class="w-4 h-4 text-emerald-600"></i>
                        </div>
                        <div class="flex items-baseline gap-2">
                            <span id="kpi-settled-count" class="text-2xl font-extrabold text-emerald-800 font-mono tabular-nums">0</span>
                            <span class="text-xs text-emerald-700 font-semibold">cleared</span>
                        </div>
                        <p class="mt-2 text-[11px] text-slate-500">Delivered & Paid Orders</p>
                    </div>

                    <!-- KPI 5: GST Input Tax Credit -->
                    <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow relative overflow-hidden group">
                        <div class="flex items-center justify-between text-slate-500 mb-1">
                            <span class="text-xs font-semibold uppercase tracking-wider">GST ITC Pool</span>
                            <i data-lucide="percent" class="w-4 h-4 text-emerald-600"></i>
                        </div>
                        <div class="flex items-baseline gap-2">
                            <span id="kpi-gst-val" class="text-2xl font-extrabold text-emerald-700 font-mono tabular-nums">₹ 0.00</span>
                        </div>
                        <p class="mt-2 text-[11px] text-slate-500">Input Tax Credit (7.5%)</p>
                    </div>

                </div>

                <!-- FILTER & CONTROLS TOOLBAR -->
                <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-3">
                    
                    <!-- Top Filter Row: Search & Dynamic Dropdowns -->
                    <div class="flex flex-col md:flex-row gap-3 items-center justify-between">
                        
                        <!-- Search Box -->
                        <div class="relative w-full md:w-80">
                            <i data-lucide="search" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"></i>
                            <input type="text" id="search-input" oninput="handleFilterChange()" placeholder="Search by PO ID, Supplier, Material, Auction #..." 
                                   class="w-full text-xs bg-slate-50 border border-slate-300 rounded-lg pl-9 pr-3 py-2 font-medium text-slate-800 placeholder-slate-400 focus:bg-white focus:outline-none focus:ring-2 focus:ring-brand-royalMid focus:border-brand-royalMid transition-all">
                        </div>

                        <!-- Secondary Filters -->
                        <div class="flex items-center gap-3 w-full md:w-auto justify-end">
                            <!-- Supplier Filter Dropdown -->
                            <div class="flex items-center gap-2">
                                <span class="text-xs font-semibold text-slate-500 whitespace-nowrap">Supplier:</span>
                                <select id="supplier-select" onchange="handleFilterChange()" 
                                        class="text-xs bg-slate-50 border border-slate-300 rounded-lg px-2.5 py-1.5 font-medium text-slate-700 focus:bg-white focus:outline-none focus:ring-2 focus:ring-brand-royalMid">
                                    <option value="ALL">All Suppliers</option>
                                </select>
                            </div>

                            <!-- Clear Filter Button -->
                            <button onclick="clearAllFilters()" class="text-xs text-slate-500 hover:text-slate-800 font-semibold px-2.5 py-1.5 border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors flex items-center gap-1">
                                <i data-lucide="rotate-ccw" class="w-3 h-3"></i> Reset
                            </button>
                        </div>
                    </div>

                    <!-- Bottom Filter Row: Dynamic Status Filter Pills -->
                    <div class="flex items-center gap-2 pt-2 border-t border-slate-100 overflow-x-auto pb-1 text-xs">
                        <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider shrink-0 mr-1">Status:</span>
                        <div class="flex items-center gap-1.5 shrink-0" id="status-pill-container">
                            <!-- Populated via JS -->
                        </div>
                    </div>
                </div>

                <!-- ENTERPRISE DATA TABLE CONTAINER -->
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col">
                    <div class="overflow-x-auto flex-1">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50/80 border-b border-slate-200 text-[11px] font-bold text-slate-600 uppercase tracking-wider select-none">
                                    <th class="py-3 px-4 cursor-pointer hover:bg-slate-100/70" onclick="sortTable('id')">
                                        <div class="flex items-center gap-1">
                                            <span>PO ID</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-3">
                                        <span>Auction Ref</span>
                                    </th>
                                    <th class="py-3 px-4 cursor-pointer hover:bg-slate-100/70" onclick="sortTable('supplier')">
                                        <div class="flex items-center gap-1">
                                            <span>Supplier Name</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 cursor-pointer hover:bg-slate-100/70" onclick="sortTable('material')">
                                        <div class="flex items-center gap-1">
                                            <span>Material / Description</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 text-right cursor-pointer hover:bg-slate-100/70" onclick="sortTable('amount')">
                                        <div class="flex items-center justify-end gap-1">
                                            <span>Base Amount</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 text-right cursor-pointer hover:bg-slate-100/70" onclick="sortTable('total')">
                                        <div class="flex items-center justify-end gap-1">
                                            <span>Total (incl. GST)</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 text-center cursor-pointer hover:bg-slate-100/70" onclick="sortTable('status')">
                                        <div class="flex items-center justify-center gap-1">
                                            <span>Lifecycle Status</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 text-right cursor-pointer hover:bg-slate-100/70" onclick="sortTable('raw_date')">
                                        <div class="flex items-center justify-end gap-1">
                                            <span>Created Date</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="py-3 px-4 text-center">
                                        <span>Workflow Actions</span>
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 text-xs" id="po-table-body">
                                <!-- Populated dynamically by JS -->
                            </tbody>
                        </table>
                    </div>

                    <!-- TABLE FOOTER & PAGINATION -->
                    <div class="bg-slate-50 px-6 py-3 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
                        <div class="flex items-center gap-4">
                            <div class="flex items-center gap-2">
                                <span>Rows per page:</span>
                                <select id="rows-per-page" onchange="handleRowsPerPageChange(this.value)" class="bg-white border border-slate-300 rounded px-2 py-1 text-slate-700 font-semibold focus:outline-none">
                                    <option value="10">10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                </select>
                            </div>
                            <span id="pagination-summary">Showing 0 of 0 records</span>
                        </div>

                        <div class="flex items-center gap-1">
                            <button id="btn-prev-page" onclick="changePage(-1)" class="p-1 rounded border border-slate-300 bg-white hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed">
                                <i data-lucide="chevron-left" class="w-4 h-4"></i>
                            </button>
                            <span id="page-indicator" class="px-3 font-semibold text-slate-700 font-mono">Page 1 of 1</span>
                            <button id="btn-next-page" onclick="changePage(1)" class="p-1 rounded border border-slate-300 bg-white hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed">
                                <i data-lucide="chevron-right" class="w-4 h-4"></i>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

            <!-- FOOTER -->
            <footer class="bg-brand-navy text-white text-xs py-6 px-6 border-t border-slate-800 mt-auto">
                <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-6 pb-6">
                    <div>
                        <div class="flex items-center gap-1 mb-2">
                            <span class="text-lg font-black tracking-tight text-white">Supple</span>
                            <span class="text-lg font-black tracking-tight text-[#2DD4BF]">xio</span>
                        </div>
                        <p class="text-slate-400 text-[11px] leading-relaxed">Enterprise Trade Intelligence, Autonomous Dynamic B2B Reverse Auctions, & Inbound Logistics Platform.</p>
                    </div>
                    <div>
                        <h4 class="font-bold text-white mb-2 uppercase tracking-wider text-[11px]">Core Essentials</h4>
                        <ul class="space-y-1 text-slate-300 text-[11px]">
                            <li><a href="${pageContext.request.contextPath}/auction" class="hover:text-white hover:underline flex items-center gap-1"><i data-lucide="chevron-right" class="w-3 h-3 text-[#2DD4BF]"></i> Reverse Auctions Floor</a></li>
                            <li><a href="${pageContext.request.contextPath}/user-po-view" class="hover:text-white hover:underline flex items-center gap-1"><i data-lucide="chevron-right" class="w-3 h-3 text-[#2DD4BF]"></i> Purchase Orders Hub</a></li>
                            <li><a href="${pageContext.request.contextPath}/inventory" class="hover:text-white hover:underline flex items-center gap-1"><i data-lucide="chevron-right" class="w-3 h-3 text-[#2DD4BF]"></i> Inventory Management</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="font-bold text-white mb-2 uppercase tracking-wider text-[11px]">Analytics & Intel</h4>
                        <ul class="space-y-1 text-slate-300 text-[11px]">
                            <li><a href="http://localhost:8501" target="_blank" class="hover:text-white hover:underline flex items-center gap-1"><i data-lucide="chevron-right" class="w-3 h-3 text-[#2DD4BF]"></i> Global Trade Intelligence</a></li>
                            <li><a href="${pageContext.request.contextPath}/payments" class="hover:text-white hover:underline flex items-center gap-1"><i data-lucide="chevron-right" class="w-3 h-3 text-[#2DD4BF]"></i> Payment Settlements</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="font-bold text-white mb-2 uppercase tracking-wider text-[11px]">Support & Governance</h4>
                        <p class="text-slate-300 leading-relaxed space-y-1 text-[11px]">
                            <span class="flex items-center gap-2"><i data-lucide="phone" class="w-3.5 h-3.5 text-[#2DD4BF]"></i> +91 98765 43210</span>
                            <span class="flex items-center gap-2"><i data-lucide="mail" class="w-3.5 h-3.5 text-[#2DD4BF]"></i> procurement@supplexio.com</span>
                        </p>
                    </div>
                </div>
                <div class="border-t border-white/10 pt-3 text-center text-[11px] text-slate-400">
                    © 2026 Supplexio. All Rights Reserved. Enterprise Procurement Portal v4.2
                </div>
            </footer>

        </main>
    </div>

    <!-- TOAST NOTIFICATION CONTAINER -->
    <div id="toast-container" class="fixed top-5 right-5 z-50 flex flex-col gap-2 pointer-events-none"></div>

    <!-- MODAL 1: AI ASSISTANT -->
    <div id="ai-modal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 hidden flex items-end sm:items-center justify-center p-4">
        <div class="bg-white w-full max-w-lg rounded-2xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col h-[520px]">
            <div class="bg-[#0B1E3D] text-white p-4 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <div class="w-7 h-7 rounded-lg bg-[#2DD4BF] text-slate-950 flex items-center justify-center font-black text-xs">AI</div>
                    <div>
                        <h3 class="text-sm font-bold">Supplexio Procurement Intelligence</h3>
                        <p class="text-[10px] text-slate-300">Live Trade Copilot & PO Analysis</p>
                    </div>
                </div>
                <button onclick="toggleAiDrawer()" class="text-slate-400 hover:text-white"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <div class="flex-1 p-4 overflow-y-auto space-y-3 bg-slate-50" id="ai-chat-body">
                <div class="bg-white border border-slate-200 text-slate-800 p-3 rounded-xl max-w-[85%] shadow-sm text-xs leading-relaxed">
                    Hello! I am your <strong>Supplexio AI Procurement Copilot</strong>. I monitor purchase orders, verify 3-way matching with reverse auctions, and forecast delivery timelines. How can I assist you today?
                </div>
            </div>
            <div class="p-3 border-t border-slate-200 bg-white flex items-center gap-2">
                <input type="text" id="ai-input" placeholder="Ask about PO status, vendor ratings, or delivery..." onkeydown="if(event.key==='Enter') sendAiMessage()"
                       class="flex-1 text-xs border border-slate-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-brand-royalMid">
                <button onclick="sendAiMessage()" class="bg-brand-royalMid hover:bg-brand-royalDark text-white p-2 rounded-lg">
                    <i data-lucide="send" class="w-4 h-4"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- MODAL 2: AUDIT VERIFICATION & PO DISPATCH MODAL -->
    <div id="audit-modal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white w-full max-w-lg rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
            <div class="bg-amber-500 text-slate-950 p-4 flex items-center justify-between font-bold">
                <div class="flex items-center gap-2">
                    <i data-lucide="shield-alert" class="w-5 h-5"></i>
                    <h3 class="text-sm">Audit Verification & Supplier Transmission</h3>
                </div>
                <button onclick="closeModal('audit-modal')" class="text-slate-950 hover:text-black"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <form id="auditSendForm" method="post" action="${pageContext.request.contextPath}/pos/send" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="audit-po-id-input">
                
                <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 text-xs text-amber-900 space-y-2">
                    <div class="flex justify-between font-bold border-b border-amber-200 pb-2">
                        <span id="audit-po-id" class="font-mono text-sm">PO #0</span>
                        <span id="audit-status" class="bg-amber-200 text-amber-900 px-2 py-0.5 rounded font-mono">PO_DRAFT</span>
                    </div>
                    <div class="grid grid-cols-2 gap-2 pt-1 font-sans">
                        <div>
                            <span class="text-amber-700 block">Supplier:</span>
                            <span id="audit-supplier" class="font-semibold text-slate-900">-</span>
                        </div>
                        <div>
                            <span class="text-amber-700 block">Material:</span>
                            <span id="audit-material" class="font-semibold text-slate-900">-</span>
                        </div>
                        <div>
                            <span class="text-amber-700 block">Base Amount:</span>
                            <span id="audit-base" class="font-mono text-slate-900">₹ 0.00</span>
                        </div>
                        <div>
                            <span class="text-amber-700 block">Total incl. GST (7.5%):</span>
                            <span id="audit-total" class="font-mono font-bold text-slate-900">₹ 0.00</span>
                        </div>
                    </div>
                </div>

                <!-- Mandatory Checkbox Verification -->
                <div class="bg-slate-50 border border-slate-200 rounded-xl p-3 flex items-start gap-3">
                    <input type="checkbox" id="audit-check" name="executiveApproved" value="true" onchange="toggleAuditSubmitButton()" class="mt-0.5 w-4 h-4 text-brand-royalMid rounded border-slate-300 focus:ring-brand-royalMid cursor-pointer" required>
                    <label for="audit-check" class="text-xs font-semibold text-slate-800 leading-snug cursor-pointer">
                        AUDIT VERIFICATION REQUIRED: <span class="font-normal text-slate-600">I confirm that quantity, unit pricing, GST tax computation (7.5%), and delivery terms have been verified and approved for transmission.</span>
                    </label>
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" onclick="closeModal('audit-modal')" class="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50">Cancel</button>
                    <button type="submit" id="btn-dispatch-po" disabled class="px-5 py-2 bg-brand-royalMid disabled:bg-slate-300 disabled:cursor-not-allowed text-white rounded-lg text-xs font-bold shadow-md flex items-center gap-1.5 transition-all">
                        <i data-lucide="send" class="w-3.5 h-3.5"></i>
                        <span>Send PO to Supplier</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 3: RECORD GOODS RECEIPT (GRN) MODAL -->
    <div id="grn-receive-modal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
            <div class="bg-emerald-600 text-white p-4 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <i data-lucide="warehouse" class="w-5 h-5 text-emerald-200"></i>
                    <h3 class="text-sm font-bold">Record Inbound Goods Receipt (GRN)</h3>
                </div>
                <button onclick="closeModal('grn-receive-modal')" class="text-white hover:text-emerald-200"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/goods-receipts/receive" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="grnReceivePoId">
                <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-3 text-xs text-emerald-950 flex justify-between items-center">
                    <div>
                        <p class="font-bold text-slate-800" id="grnReceivePoLabel">PO #0</p>
                        <p class="text-[11px] text-emerald-700">Ordered Quantity: <strong id="grnOrderedQtyLabel">-</strong> units</p>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-700 mb-1">Received Quantity *</label>
                    <input type="number" name="receivedQuantity" id="grnReceiveQty" min="1" required class="w-full text-xs font-mono border border-slate-300 rounded-lg p-2.5 bg-slate-50 focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-700 mb-1">Warehouse Inbound Location *</label>
                    <input type="text" name="warehouseLocation" placeholder="e.g. WH-A / Bay 3" required value="WH-A / Bay 1" class="w-full text-xs border border-slate-300 rounded-lg p-2.5 bg-slate-50 focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" onclick="closeModal('grn-receive-modal')" class="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold shadow-md flex items-center gap-1.5">
                        <i data-lucide="check-circle" class="w-4 h-4"></i>
                        <span>Confirm Receipt</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 4: ADJUST GOODS RECEIPT (GRN) MODAL -->
    <div id="grn-adjust-modal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
            <div class="bg-amber-500 text-slate-950 p-4 flex items-center justify-between font-bold">
                <div class="flex items-center gap-2">
                    <i data-lucide="edit-3" class="w-5 h-5"></i>
                    <h3 class="text-sm">Adjust Received Quantity</h3>
                </div>
                <button onclick="closeModal('grn-adjust-modal')" class="text-slate-950 hover:text-black"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/goods-receipts/adjust" class="p-5 space-y-4">
                <input type="hidden" name="poId" id="grnAdjustPoId">
                <div class="bg-amber-50 border border-amber-200 rounded-xl p-3 text-xs text-amber-900">
                    <p class="font-bold mb-1">Discrepancy Resolution</p>
                    <p class="text-[11px] text-amber-800 leading-relaxed">Ordered: <strong id="grnAdjustOrderedLabel">-</strong> · Current Received: <strong id="grnAdjustReceivedLabel">-</strong></p>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-700 mb-1">Updated Received Quantity *</label>
                    <input type="number" name="receivedQuantity" id="grnAdjustQty" min="1" required class="w-full text-xs font-mono border border-slate-300 rounded-lg p-2.5 bg-slate-50 focus:ring-2 focus:ring-amber-500 outline-none">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-700 mb-1">Warehouse Inbound Location *</label>
                    <input type="text" name="warehouseLocation" placeholder="Inbound location" required value="WH-A / Bay 1" class="w-full text-xs border border-slate-300 rounded-lg p-2.5 bg-slate-50 focus:ring-2 focus:ring-amber-500 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" onclick="closeModal('grn-adjust-modal')" class="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-amber-500 hover:bg-amber-600 text-slate-950 rounded-lg text-xs font-bold shadow-md flex items-center gap-1.5">
                        <i data-lucide="save" class="w-4 h-4"></i>
                        <span>Save Adjustment</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- DOCUMENT PREVIEW SLIDE-OVER DRAWER (KEPT EXACT SAME AS IN supplexio_purchase_orders.html) -->
    <div id="document-drawer" class="fixed inset-0 z-50 hidden overflow-hidden">
        <div class="absolute inset-0 bg-slate-900/50 backdrop-blur-sm transition-opacity" onclick="closeDrawer()"></div>
        <div class="fixed inset-y-0 right-0 max-w-full flex pl-10">
            <div class="w-screen max-w-2xl bg-white shadow-2xl flex flex-col">
                
                <!-- Drawer Header -->
                <div class="bg-brand-navy p-4 text-white flex items-center justify-between border-b border-slate-800">
                    <div class="flex items-center gap-3">
                        <div class="p-2 bg-white/10 rounded-lg">
                            <i data-lucide="file-text" class="w-5 h-5 text-[#2DD4BF]"></i>
                        </div>
                        <div>
                            <h2 class="text-sm font-bold flex items-center gap-2" id="doc-title-header">
                                Document Viewer
                            </h2>
                            <p class="text-[11px] text-slate-300">Official Supplexio Systems B2B Audit Record</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <button onclick="window.print()" class="bg-white/10 hover:bg-white/20 text-white text-xs font-semibold px-3 py-1.5 rounded-lg flex items-center gap-1.5 transition-colors">
                            <i data-lucide="printer" class="w-3.5 h-3.5"></i> Print
                        </button>
                        <button onclick="closeDrawer()" class="text-slate-400 hover:text-white p-1">
                            <i data-lucide="x" class="w-6 h-6"></i>
                        </button>
                    </div>
                </div>

                <!-- Printable Document Canvas -->
                <div class="flex-1 overflow-y-auto p-8 bg-slate-50" id="printable-document">
                    <!-- Dynamic Document Layout Populated by JS -->
                </div>

            </div>
        </div>
    </div>

    <!-- JAVASCRIPT LOGIC & STATE MANAGEMENT -->
    <script>
        // Store context path cleanly for JS concatenation without JSP EL interference
        const contextPath = '<%= request.getContextPath() %>';

        // INJECT REAL LIVE PURCHASE ORDERS DATASET FROM DATABASE
        const initialPOData = <%= poJsonArray.toJSONString() %>;

        // State Store
        let state = {
            pos: Array.isArray(initialPOData) ? [...initialPOData] : [],
            activeStatusFilter: 'ALL',
            activeSupplierFilter: 'ALL',
            searchQuery: '',
            sortField: 'id',
            sortAsc: false,
            currentPage: 1,
            pageSize: 10,
            selectedAuditPOId: null,
        };

        // -------------------------------------------------------------------
        // INITIALIZATION
        // -------------------------------------------------------------------
        window.onload = function() {
            populateSupplierDropdown();
            renderDashboard();
            lucide.createIcons();
        };

        function populateSupplierDropdown() {
            const select = document.getElementById('supplier-select');
            if (!select) return;
            const suppliers = Array.from(new Set(state.pos.map(p => p.supplier).filter(Boolean))).sort();
            suppliers.forEach(s => {
                const opt = document.createElement('option');
                opt.value = s;
                opt.textContent = s;
                select.appendChild(opt);
            });
        }

        function renderDashboard() {
            updateKPIs();
            renderStatusPills();
            renderTable();
            const badge = document.getElementById('po-total-badge');
            if (badge) badge.textContent = state.pos.length;
            lucide.createIcons();
        }

        // -------------------------------------------------------------------
        // FORMATTERS
        // -------------------------------------------------------------------
        function formatINR(val) {
            return new Intl.NumberFormat('en-IN', {
                style: 'currency',
                currency: 'INR',
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }).format(val || 0);
        }

        function getSupplierInitials(name) {
            if (!name) return 'PO';
            const parts = name.split(' ');
            if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
            return name.substring(0, 2).toUpperCase();
        }

        // -------------------------------------------------------------------
        // KPI ENGINE
        // -------------------------------------------------------------------
        function updateKPIs() {
            const totalVal = state.pos.reduce((acc, p) => acc + (p.total || 0), 0);
            const totalGst = state.pos.reduce((acc, p) => acc + (p.gst || 0), 0);
            
            // Action Required: PO_DRAFT
            const pendingOrders = state.pos.filter(p => ['PO_DRAFT', 'CREATED', 'PENDING'].includes((p.status || '').toUpperCase()));
            
            // In Transit: SHIPPED, PO_SENT, PO_ACCEPTED
            const inTransitOrders = state.pos.filter(p => ['PO_SENT', 'SENT', 'PO_ACCEPTED', 'SHIPPED'].includes((p.status || '').toUpperCase()));
            const inTransitVal = inTransitOrders.reduce((acc, p) => acc + (p.total || 0), 0);

            // Settled: DELIVERED, PAYMENT_SUCCESSFUL, PAID, CLOSED
            const settledOrders = state.pos.filter(p => ['DELIVERED', 'PAYMENT_SUCCESSFUL', 'PAID', 'CLOSED'].includes((p.status || '').toUpperCase()));

            document.getElementById('kpi-total-val').textContent = formatINR(totalVal);
            document.getElementById('kpi-total-count').textContent = state.pos.length + ' orders';
            document.getElementById('kpi-pending-count').textContent = pendingOrders.length;
            document.getElementById('kpi-sent-val').textContent = formatINR(inTransitVal);
            document.getElementById('kpi-sent-count').textContent = inTransitOrders.length + ' orders';
            document.getElementById('kpi-settled-count').textContent = settledOrders.length;
            document.getElementById('kpi-gst-val').textContent = formatINR(totalGst);
        }

        // -------------------------------------------------------------------
        // STATUS PILL FILTER BAR
        // -------------------------------------------------------------------
        const STATUS_DEFINITIONS = [
            { key: 'ALL', label: 'All Orders' },
            { key: 'PO_DRAFT', label: 'Draft PO' },
            { key: 'PO_SENT', label: 'Sent to Supplier' },
            { key: 'PO_ACCEPTED', label: 'PO Accepted' },
            { key: 'SHIPPED', label: 'Shipped (Inbound)' },
            { key: 'DELIVERED', label: 'Delivered' },
            { key: 'INVOICING_PENDING', label: 'Awaiting Invoice' },
            { key: 'PAYMENT_PENDING', label: 'Payment Pending' },
            { key: 'PAYMENT_SUCCESSFUL', label: 'Paid & Settled' },
            { key: 'CLOSED', label: 'Closed' }
        ];

        function renderStatusPills() {
            const container = document.getElementById('status-pill-container');
            if (!container) return;
            container.innerHTML = '';

            STATUS_DEFINITIONS.forEach(def => {
                let count = 0;
                if (def.key === 'ALL') {
                    count = state.pos.length;
                } else {
                    count = state.pos.filter(p => (p.status || '').toUpperCase() === def.key).length;
                }

                const isActive = state.activeStatusFilter === def.key;
                const btn = document.createElement('button');
                btn.onclick = () => setStatusFilter(def.key);

                if (isActive) {
                    btn.className = "bg-brand-royalMid text-white font-bold px-3 py-1 rounded-full shadow-sm flex items-center gap-1.5 transition-all";
                } else {
                    btn.className = "bg-slate-100 hover:bg-slate-200 text-slate-600 font-medium px-3 py-1 rounded-full border border-slate-200 transition-colors flex items-center gap-1.5";
                }

                btn.innerHTML = '<span>' + def.label + '</span>' +
                    '<span class="' + (isActive ? 'bg-white text-brand-royalMid' : 'bg-slate-200 text-slate-700') + ' text-[10px] font-mono font-bold px-1.5 py-0.2 rounded-full">' + count + '</span>';
                container.appendChild(btn);
            });
        }

        function setStatusFilter(statusKey) {
            state.activeStatusFilter = statusKey;
            state.currentPage = 1;
            renderDashboard();
        }

        function filterByStatusQuick(type) {
            if (type === 'ACTION_REQ') state.activeStatusFilter = 'PO_DRAFT';
            else if (type === 'SENT') state.activeStatusFilter = 'SHIPPED';
            else if (type === 'SETTLED') state.activeStatusFilter = 'DELIVERED';
            state.currentPage = 1;
            renderDashboard();
        }

        // -------------------------------------------------------------------
        // FILTERING & SORTING PIPELINE
        // -------------------------------------------------------------------
        function handleFilterChange() {
            state.searchQuery = document.getElementById('search-input').value.trim().toLowerCase();
            state.activeSupplierFilter = document.getElementById('supplier-select').value;
            state.currentPage = 1;
            renderDashboard();
        }

        function clearAllFilters() {
            document.getElementById('search-input').value = '';
            document.getElementById('supplier-select').value = 'ALL';
            state.searchQuery = '';
            state.activeSupplierFilter = 'ALL';
            state.activeStatusFilter = 'ALL';
            state.currentPage = 1;
            renderDashboard();
        }

        function sortTable(field) {
            if (state.sortField === field) {
                state.sortAsc = !state.sortAsc;
            } else {
                state.sortField = field;
                state.sortAsc = true;
            }
            renderTable();
        }

        function getFilteredData() {
            return state.pos.filter(po => {
                const s = (po.status || '').toUpperCase();
                // Status Filter
                if (state.activeStatusFilter !== 'ALL') {
                    if (state.activeStatusFilter === 'PO_DRAFT') {
                        if (!['PO_DRAFT', 'CREATED', 'PENDING'].includes(s)) return false;
                    } else if (state.activeStatusFilter === 'PO_SENT') {
                        if (!['PO_SENT', 'SENT'].includes(s)) return false;
                    } else if (state.activeStatusFilter === 'PAYMENT_SUCCESSFUL') {
                        if (!['PAYMENT_SUCCESSFUL', 'PAID'].includes(s)) return false;
                    } else {
                        if (s !== state.activeStatusFilter) return false;
                    }
                }

                // Supplier Filter
                if (state.activeSupplierFilter !== 'ALL' && po.supplier !== state.activeSupplierFilter) {
                    return false;
                }

                // Search Query Filter
                if (state.searchQuery) {
                    const q = state.searchQuery;
                    const matchId = String(po.id).toLowerCase().includes(q);
                    const matchAuction = String(po.auctionId || '').toLowerCase().includes(q);
                    const matchSup = String(po.supplier || '').toLowerCase().includes(q);
                    const matchMat = String(po.material || '').toLowerCase().includes(q);
                    if (!matchId && !matchAuction && !matchSup && !matchMat) return false;
                }

                return true;
            }).sort((a, b) => {
                let vA = a[state.sortField];
                let vB = b[state.sortField];

                if (typeof vA === 'string') vA = vA.toLowerCase();
                if (typeof vB === 'string') vB = vB.toLowerCase();

                if (vA < vB) return state.sortAsc ? -1 : 1;
                if (vA > vB) return state.sortAsc ? 1 : -1;
                return 0;
            });
        }

        // -------------------------------------------------------------------
        // HELPER FUNCTIONS FOR CLEAN DOM GENERATION
        // -------------------------------------------------------------------
        function getAuctionRefBadge(auctionId) {
            if (auctionId && auctionId > 0) {
                return '<a href="' + contextPath + '/auction?action=view&id=' + auctionId + '" class="inline-flex items-center gap-1 text-[11px] font-mono font-semibold text-amber-700 bg-amber-50 hover:bg-amber-100 px-2 py-0.5 rounded border border-amber-200 transition-colors no-underline" title="View Originating Reverse Auction #' + auctionId + '">' +
                       '<i data-lucide="gavel" class="w-3 h-3 text-amber-600"></i>' +
                       '<span>#AUC-' + auctionId + '</span>' +
                       '</a>';
            }
            return '<span class="text-slate-400 text-[11px] font-mono">Direct PO</span>';
        }

        // -------------------------------------------------------------------
        // TABLE RENDERER
        // -------------------------------------------------------------------
        function renderTable() {
            const tbody = document.getElementById('po-table-body');
            if (!tbody) return;
            tbody.innerHTML = '';

            const filtered = getFilteredData();
            const totalRows = filtered.length;
            const totalPages = Math.ceil(totalRows / state.pageSize) || 1;

            if (state.currentPage > totalPages) state.currentPage = totalPages;
            if (state.currentPage < 1) state.currentPage = 1;

            const startIdx = (state.currentPage - 1) * state.pageSize;
            const endIdx = Math.min(startIdx + state.pageSize, totalRows);
            const pageData = filtered.slice(startIdx, endIdx);

            const startNum = totalRows === 0 ? 0 : startIdx + 1;
            document.getElementById('pagination-summary').textContent = 'Showing ' + startNum + ' to ' + endIdx + ' of ' + totalRows + ' purchase orders';
            document.getElementById('page-indicator').textContent = 'Page ' + state.currentPage + ' of ' + totalPages;
            document.getElementById('btn-prev-page').disabled = state.currentPage === 1;
            document.getElementById('btn-next-page').disabled = state.currentPage === totalPages || totalRows === 0;

            if (pageData.length === 0) {
                tbody.innerHTML = '<tr><td colspan="9" class="py-12 text-center text-slate-400">' +
                    '<i data-lucide="inbox" class="w-8 h-8 mx-auto mb-2 text-slate-300"></i>' +
                    '<p class="font-semibold text-sm text-slate-600">No purchase orders found</p>' +
                    '<p class="text-xs text-slate-400 mt-1">Try resetting filters or search query.</p>' +
                    '</td></tr>';
                lucide.createIcons();
                return;
            }

            pageData.forEach(po => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-blue-50/40 transition-colors group";

                tr.innerHTML = 
                    '<td class="py-3 px-4 font-mono font-bold text-brand-royalMid">#PO-' + po.id + '</td>' +
                    '<td class="py-3 px-3">' + getAuctionRefBadge(po.auctionId) + '</td>' +
                    '<td class="py-3 px-4">' +
                        '<div class="flex items-center gap-2">' +
                            '<div class="w-7 h-7 rounded-full bg-slate-200 text-slate-700 font-bold flex items-center justify-center text-[10px] shrink-0 font-mono">' +
                                getSupplierInitials(po.supplier) +
                            '</div>' +
                            '<span class="font-semibold text-slate-900 truncate max-w-[150px]">' + po.supplier + '</span>' +
                        '</div>' +
                    '</td>' +
                    '<td class="py-3 px-4">' +
                        '<span class="font-semibold text-slate-900">' + po.material + '</span>' +
                        '<span class="text-[11px] text-slate-500 block">Ordered: ' + (po.quantity || 1) + ' units</span>' +
                    '</td>' +
                    '<td class="py-3 px-4 text-right font-mono font-semibold text-slate-700">' +
                        formatINR(po.amount) +
                        '<span class="text-[10px] text-slate-400 block">+ GST ' + formatINR(po.gst) + '</span>' +
                    '</td>' +
                    '<td class="py-3 px-4 text-right font-mono font-bold text-slate-900">' +
                        formatINR(po.total) +
                    '</td>' +
                    '<td class="py-3 px-4 text-center">' +
                        getStatusBadge(po.status) +
                    '</td>' +
                    '<td class="py-3 px-4 text-right text-slate-500 font-mono text-[11px]">' +
                        po.created_at +
                    '</td>' +
                    '<td class="py-3 px-4 text-center">' +
                        renderActionsColumn(po) +
                    '</td>';
                tbody.appendChild(tr);
            });

            lucide.createIcons();
        }

        // -------------------------------------------------------------------
        // LIFECYCLE BADGES
        // -------------------------------------------------------------------
        function getStatusBadge(status) {
            const s = (status || '').toUpperCase();
            switch(s) {
                case 'PO_DRAFT':
                case 'CREATED':
                case 'PENDING':
                    return '<span class="inline-flex items-center gap-1 bg-amber-100 text-amber-900 font-bold px-2.5 py-1 rounded-full text-[10px] border border-amber-300 shadow-sm">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>DRAFT PO</span>';
                case 'PO_SENT':
                case 'SENT':
                    return '<span class="inline-flex items-center gap-1 bg-sky-100 text-sky-900 font-bold px-2.5 py-1 rounded-full text-[10px] border border-sky-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-sky-500"></span>PO SENT</span>';
                case 'PO_ACCEPTED':
                    return '<span class="inline-flex items-center gap-1 bg-blue-100 text-blue-900 font-bold px-2.5 py-1 rounded-full text-[10px] border border-blue-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-blue-600"></span>PO ACCEPTED</span>';
                case 'SHIPPED':
                    return '<span class="inline-flex items-center gap-1 bg-indigo-100 text-indigo-900 font-bold px-2.5 py-1 rounded-full text-[10px] border border-indigo-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-indigo-600"></span>SHIPPED</span>';
                case 'DELIVERED':
                    return '<span class="inline-flex items-center gap-1 bg-emerald-100 text-emerald-900 font-bold px-2.5 py-1 rounded-full text-[10px] border border-emerald-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>DELIVERED</span>';
                case 'INVOICING_PENDING':
                    return '<span class="inline-flex items-center gap-1 bg-amber-100 text-amber-800 font-bold px-2.5 py-1 rounded-full text-[10px] border border-amber-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>AWAITING INVOICE</span>';
                case 'PAYMENT_PENDING':
                    return '<span class="inline-flex items-center gap-1 bg-rose-100 text-rose-800 font-bold px-2.5 py-1 rounded-full text-[10px] border border-rose-300">' +
                           '<span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>PAYMENT PENDING</span>';
                case 'PAYMENT_SUCCESSFUL':
                case 'PAID':
                    return '<span class="inline-flex items-center gap-1 bg-slate-900 text-emerald-400 font-bold px-2.5 py-1 rounded-full text-[10px] border border-slate-700">' +
                           '<i data-lucide="check-circle-2" class="w-3 h-3 text-emerald-400"></i>PAID & SETTLED</span>';
                case 'CLOSED':
                    return '<span class="inline-flex items-center gap-1 bg-slate-800 text-slate-300 font-bold px-2.5 py-1 rounded-full text-[10px] border border-slate-700">' +
                           'CLOSED</span>';
                default:
                    return '<span class="bg-slate-100 text-slate-700 px-2 py-1 rounded text-[10px] font-semibold">' + status + '</span>';
            }
        }

        // -------------------------------------------------------------------
        // HIGH DENSITY WORKFLOW ACTIONS COLUMN
        // -------------------------------------------------------------------
        function renderActionsColumn(po) {
            const s = (po.status || '').toUpperCase();
            let primaryBtn = '';

            if (['PO_DRAFT', 'CREATED', 'PENDING'].includes(s)) {
                primaryBtn = '<button onclick="openAuditModal(' + po.id + ')" class="bg-amber-500 hover:bg-amber-600 text-slate-950 font-extrabold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95">' +
                    '<i data-lucide="shield-check" class="w-3 h-3"></i> Verify & Send</button>';
            } else if (['PO_SENT', 'SENT'].includes(s)) {
                primaryBtn = '<span class="bg-slate-100 text-slate-500 text-[10px] font-semibold px-2 py-1 rounded border border-slate-200 flex items-center gap-1">' +
                    '<i data-lucide="clock" class="w-3 h-3 text-sky-600"></i> Pending Supplier</span>';
            } else if (s === 'PO_ACCEPTED') {
                primaryBtn = '<span class="bg-blue-50 text-blue-700 text-[10px] font-semibold px-2 py-1 rounded border border-blue-200 flex items-center gap-1">' +
                    '<i data-lucide="truck" class="w-3 h-3 text-blue-600"></i> Awaiting Dispatch</span>';
            } else if (s === 'SHIPPED') {
                primaryBtn = '<button onclick="openGrnReceiveModal(' + po.id + ', ' + (po.quantity || 1) + ')" class="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95">' +
                    '<i data-lucide="warehouse" class="w-3 h-3"></i> Record GRN</button>';
            } else if (s === 'DELIVERED') {
                const orderedQty = po.quantity || 1;
                const receivedQty = po.receivedQuantity || 0;
                if (receivedQty > 0 && receivedQty !== orderedQty) {
                    primaryBtn = '<button onclick="openGrnAdjustModal(' + po.id + ', ' + orderedQty + ', ' + receivedQty + ')" class="bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95">' +
                        '<i data-lucide="alert-triangle" class="w-3 h-3"></i> Adjust GRN (' + receivedQty + '/' + orderedQty + ')</button>';
                } else {
                    primaryBtn = '<form method="post" action="' + contextPath + '/invoices/request" class="inline">' +
                        '<input type="hidden" name="poId" value="' + po.id + '">' +
                        '<button type="submit" class="bg-brand-royalMid hover:bg-brand-royalDark text-white font-semibold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95">' +
                        '<i data-lucide="send" class="w-3 h-3"></i> Send Invoice</button></form>';
                }
            } else if (s === 'INVOICING_PENDING') {
                primaryBtn = '<span class="bg-slate-100 text-slate-500 text-[10px] font-semibold px-2 py-1 rounded border border-slate-200 flex items-center gap-1" title="Supplier notified to upload invoice">' +
                    '<i data-lucide="check" class="w-3 h-3 text-emerald-600"></i> Invoice Requested</span>';
            } else if (s === 'PAYMENT_PENDING') {
                primaryBtn = '<a href="' + contextPath + '/payment?action=new&poId=' + po.id + '" class="bg-rose-600 hover:bg-rose-700 text-white font-bold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95 no-underline">' +
                    '<i data-lucide="credit-card" class="w-3 h-3"></i> Pay Invoice</a>';
            } else if (['PAYMENT_SUCCESSFUL', 'PAID'].includes(s)) {
                primaryBtn = '<form method="post" action="' + contextPath + '/transactions/close" class="inline">' +
                    '<input type="hidden" name="poId" value="' + po.id + '">' +
                    '<button type="submit" class="bg-slate-900 hover:bg-black text-white font-bold text-[11px] px-2.5 py-1 rounded shadow-sm flex items-center gap-1 transition-transform active:scale-95">' +
                    '<i data-lucide="check-square" class="w-3 h-3"></i> Close</button></form>';
            } else if (s === 'CLOSED') {
                primaryBtn = '<span class="text-emerald-700 font-bold text-[10px] flex items-center gap-1 px-1.5 py-0.5 bg-emerald-50 rounded border border-emerald-200">' +
                    '<i data-lucide="check-circle-2" class="w-3 h-3"></i> Settled</span>';
            }

            // Compact Document Buttons (PO, GRN/CH, INV)
            let docButtons = '<div class="flex items-center gap-1">' +
                '<button onclick="openDocumentDrawer(' + po.id + ', \'PO\')" title="View PO Document" class="px-1.5 py-0.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded text-[10px] font-mono font-bold border border-slate-300 transition-colors">PO</button>';
            
            if (!['PO_DRAFT', 'CREATED', 'PENDING'].includes(s)) {
                docButtons += '<button onclick="openDocumentDrawer(' + po.id + ', \'CHALLAN\')" title="View Delivery Challan / GRN" class="px-1.5 py-0.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded text-[10px] font-mono font-bold border border-slate-300 transition-colors">GRN</button>';
            }
            if (['DELIVERED', 'INVOICING_PENDING', 'PAYMENT_PENDING', 'PAYMENT_SUCCESSFUL', 'PAID', 'CLOSED'].includes(s)) {
                docButtons += '<button onclick="openDocumentDrawer(' + po.id + ', \'INVOICE\')" title="View Tax Invoice" class="px-1.5 py-0.5 bg-blue-50 hover:bg-blue-100 text-brand-royalMid rounded text-[10px] font-mono font-bold border border-blue-200 transition-colors">INV</button>';
            }
            docButtons += '</div>';

            return '<div class="flex items-center justify-center gap-2">' + primaryBtn + docButtons + '</div>';
        }

        // -------------------------------------------------------------------
        // PAGINATION HANDLERS
        // -------------------------------------------------------------------
        function handleRowsPerPageChange(val) {
            state.pageSize = parseInt(val);
            state.currentPage = 1;
            renderTable();
        }

        function changePage(delta) {
            state.currentPage += delta;
            renderTable();
        }

        // -------------------------------------------------------------------
        // MODALS & DRAWER INTERACTIONS
        // -------------------------------------------------------------------
        function openAuditModal(poId) {
            const po = state.pos.find(p => p.id === poId);
            if (!po) return;

            state.selectedAuditPOId = poId;
            document.getElementById('audit-po-id-input').value = poId;
            document.getElementById('audit-po-id').textContent = 'PO #' + po.id;
            document.getElementById('audit-supplier').textContent = po.supplier;
            document.getElementById('audit-material').textContent = po.material;
            document.getElementById('audit-base').textContent = formatINR(po.amount);
            document.getElementById('audit-total').textContent = formatINR(po.total);
            document.getElementById('audit-check').checked = false;
            document.getElementById('btn-dispatch-po').disabled = true;

            document.getElementById('audit-modal').classList.remove('hidden');
            lucide.createIcons();
        }

        function toggleAuditSubmitButton() {
            const checked = document.getElementById('audit-check').checked;
            document.getElementById('btn-dispatch-po').disabled = !checked;
        }

        function openGrnReceiveModal(poId, orderedQty) {
            document.getElementById('grnReceivePoId').value = poId;
            document.getElementById('grnReceivePoLabel').textContent = 'PO #' + poId;
            document.getElementById('grnOrderedQtyLabel').textContent = orderedQty;
            document.getElementById('grnReceiveQty').value = orderedQty;
            document.getElementById('grn-receive-modal').classList.remove('hidden');
            lucide.createIcons();
        }

        function openGrnAdjustModal(poId, orderedQty, receivedQty) {
            document.getElementById('grnAdjustPoId').value = poId;
            document.getElementById('grnAdjustOrderedLabel').textContent = orderedQty;
            document.getElementById('grnAdjustReceivedLabel').textContent = receivedQty;
            document.getElementById('grnAdjustQty').value = orderedQty;
            document.getElementById('grn-adjust-modal').classList.remove('hidden');
            lucide.createIcons();
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            if (modal) modal.classList.add('hidden');
        }

        // -------------------------------------------------------------------
        // DOCUMENT PREVIEW DRAWER (SLIDE-OVER SIDE PANEL)
        // -------------------------------------------------------------------
        function openDocumentDrawer(poId, docType) {
            const po = state.pos.find(p => p.id === poId);
            if (!po) return;

            const docCanvas = document.getElementById('printable-document');
            const docTitle = docType === 'PO' ? 'Purchase Order' : docType === 'CHALLAN' ? 'Delivery Challan / GRN' : 'Tax Invoice';
            document.getElementById('doc-title-header').textContent = docTitle + ' — #PO-' + po.id;

            const s = (po.status || '').toUpperCase();
            let docDownloadButtons = '<a href="' + contextPath + '/documents/po.pdf?poId=' + po.id + '" target="_blank" class="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-brand-royalMid border border-blue-200 rounded font-semibold flex items-center gap-1 no-underline"><i data-lucide="file-down" class="w-3.5 h-3.5"></i><span>Download PO PDF</span></a>';
            if (!['PO_DRAFT', 'CREATED', 'PENDING'].includes(s)) {
                docDownloadButtons += '<a href="' + contextPath + '/documents/grn.pdf?poId=' + po.id + '" target="_blank" class="px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200 rounded font-semibold flex items-center gap-1 no-underline"><i data-lucide="file-down" class="w-3.5 h-3.5"></i><span>GRN PDF</span></a>';
            }
            if (['DELIVERED', 'INVOICING_PENDING', 'PAYMENT_PENDING', 'PAYMENT_SUCCESSFUL', 'PAID', 'CLOSED'].includes(s)) {
                docDownloadButtons += '<a href="' + contextPath + '/documents/invoice.pdf?poId=' + po.id + '" target="_blank" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-800 border border-rose-200 rounded font-semibold flex items-center gap-1 no-underline"><i data-lucide="file-down" class="w-3.5 h-3.5"></i><span>Invoice PDF</span></a>';
            }

            let auctionBox = '';
            if (po.auctionId && po.auctionId > 0) {
                auctionBox = '<div class="p-3 bg-blue-50 border border-blue-200 rounded-lg flex items-center justify-between text-xs">' +
                    '<div class="flex items-center gap-2"><i data-lucide="gavel" class="w-4 h-4 text-brand-royalMid"></i><span class="text-slate-700">Originating Reverse Auction: <strong>#AUC-' + po.auctionId + '</strong></span></div>' +
                    '<a href="' + contextPath + '/auction?action=view&id=' + po.auctionId + '" target="_blank" class="px-2.5 py-1 bg-brand-royalMid hover:bg-brand-royalDark text-white font-semibold rounded text-[11px] transition no-underline">View Bidding Floor &rarr;</a>' +
                    '</div>';
            }

            docCanvas.innerHTML = 
                '<div class="bg-white border border-slate-300 p-8 rounded-xl shadow-lg max-w-xl mx-auto space-y-6 font-sans text-slate-800">' +
                    '<!-- Letterhead -->' +
                    '<div class="flex justify-between items-start border-b border-slate-200 pb-6">' +
                        '<div>' +
                            '<div class="bg-[#0B1E3D] text-white px-3 py-1.5 rounded-lg inline-flex items-center gap-1 font-bold text-lg mb-2">' +
                                'Supple<span class="text-[#2DD4BF]">xio</span>' +
                            '</div>' +
                            '<p class="text-xs text-slate-500 leading-tight">' +
                                'Supplexio Systems India Private Limited<br>' +
                                'HITEC City, Madhapur, Hyderabad, Telangana 500081<br>' +
                                'GSTIN: 36AAACS9981F1Z8 | CIN: U72900TG2024PTC18234' +
                            '</p>' +
                        '</div>' +
                        '<div class="text-right font-mono">' +
                            '<span class="text-xs font-bold text-slate-400 uppercase tracking-widest block mb-1">' + (docType === 'PO' ? 'PURCHASE ORDER' : docType === 'CHALLAN' ? 'GOODS RECEIPT / CHALLAN' : 'TAX INVOICE') + '</span>' +
                            '<span class="text-lg font-bold text-brand-royalMid block">#PO-' + po.id + '</span>' +
                            '<span class="text-xs text-slate-500 block">' + po.created_at + '</span>' +
                        '</div>' +
                    '</div>' +

                    '<!-- Vendor & Ship To Grid -->' +
                    '<div class="grid grid-cols-2 gap-6 text-xs bg-slate-50 p-4 rounded-lg border border-slate-200">' +
                        '<div>' +
                            '<p class="font-bold text-slate-400 uppercase tracking-wider text-[10px] mb-1">VENDOR / SUPPLIER</p>' +
                            '<p class="font-bold text-slate-900 text-sm">' + po.supplier + '</p>' +
                            '<p class="text-slate-600 mt-0.5">Verified B2B Tier-1 Partner</p>' +
                            '<p class="text-slate-500">GST Compliance Verified (7.5%)</p>' +
                        '</div>' +
                        '<div>' +
                            '<p class="font-bold text-slate-400 uppercase tracking-wider text-[10px] mb-1">DELIVER TO</p>' +
                            '<p class="font-bold text-slate-900 text-sm">Supplexio Warehouse Hub #4</p>' +
                            '<p class="text-slate-600 mt-0.5">Plot 88, Logistics Corridor</p>' +
                            '<p class="text-slate-500">Hyderabad, TS 500081</p>' +
                        '</div>' +
                    '</div>' +

                    auctionBox +

                    '<!-- Line Item Breakdown -->' +
                    '<div>' +
                        '<table class="w-full text-left text-xs border-collapse">' +
                            '<thead>' +
                                '<tr class="bg-slate-100 border-b border-slate-300 font-bold text-slate-700">' +
                                    '<th class="py-2.5 px-3">Item / Description</th>' +
                                    '<th class="py-2.5 px-3 text-right">Qty</th>' +
                                    '<th class="py-2.5 px-3 text-right">Base Price</th>' +
                                    '<th class="py-2.5 px-3 text-right">GST (7.5%)</th>' +
                                    '<th class="py-2.5 px-3 text-right">Total</th>' +
                                '</tr>' +
                            '</thead>' +
                            '<tbody class="divide-y divide-slate-200 font-mono">' +
                                '<tr>' +
                                    '<td class="py-3 px-3 font-sans font-semibold text-slate-900">' + po.material + '</td>' +
                                    '<td class="py-3 px-3 text-right text-slate-600">' + (po.quantity || 1) + ' units</td>' +
                                    '<td class="py-3 px-3 text-right text-slate-700">' + formatINR(po.amount) + '</td>' +
                                    '<td class="py-3 px-3 text-right text-amber-700">' + formatINR(po.gst) + '</td>' +
                                    '<td class="py-3 px-3 text-right font-bold text-slate-900">' + formatINR(po.total) + '</td>' +
                                '</tr>' +
                            '</tbody>' +
                        '</table>' +
                    '</div>' +

                    '<!-- Totals Box -->' +
                    '<div class="flex justify-end pt-2">' +
                        '<div class="w-64 bg-slate-50 p-4 rounded-xl border border-slate-200 text-xs space-y-2 font-mono">' +
                            '<div class="flex justify-between text-slate-600">' +
                                '<span>Subtotal:</span>' +
                                '<span>' + formatINR(po.amount) + '</span>' +
                            '</div>' +
                            '<div class="flex justify-between text-slate-600">' +
                                '<span>GST (7.5% Rate):</span>' +
                                '<span class="text-amber-700">' + formatINR(po.gst) + '</span>' +
                            '</div>' +
                            '<div class="border-t border-slate-300 pt-2 flex justify-between font-bold text-slate-900 text-sm">' +
                                '<span>Grand Total:</span>' +
                                '<span class="text-brand-royalMid">' + formatINR(po.total) + '</span>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +

                    '<!-- Official Document Downloads -->' +
                    '<div class="border-t border-slate-200 pt-4 flex flex-wrap gap-2 justify-between items-center text-xs">' +
                        '<div class="flex items-center gap-1.5">' + docDownloadButtons + '</div>' +
                    '</div>' +

                    '<!-- Authorization & Status Stamp -->' +
                    '<div class="border-t border-slate-200 pt-6 flex items-center justify-between text-xs">' +
                        '<div>' +
                            '<span class="text-slate-400 block text-[10px] uppercase font-bold">Document Status</span>' +
                            '<span class="font-bold text-slate-900">' + po.status + '</span>' +
                        '</div>' +
                        '<div class="text-center">' +
                            '<div class="w-32 border-b border-slate-400 mb-1"></div>' +
                            '<span class="text-[10px] text-slate-500 font-medium">Authorized Signatory</span>' +
                        '</div>' +
                    '</div>' +
                '</div>';

            document.getElementById('document-drawer').classList.remove('hidden');
            lucide.createIcons();
        }

        function closeDrawer() {
            document.getElementById('document-drawer').classList.add('hidden');
        }

        // -------------------------------------------------------------------
        // EXPORT TO CSV
        // -------------------------------------------------------------------
        function exportToCSV() {
            const data = getFilteredData();
            if (data.length === 0) {
                showToast("No purchase orders to export.", "error");
                return;
            }

            let csv = "PO ID,Auction ID,Supplier,Material,Ordered Qty,Base Amount,GST (7.5%),Total Amount,Status,Created Date\n";
            data.forEach(d => {
                csv += '"' + d.id + '","' + (d.auctionId || '') + '","' + (d.supplier || '').replace(/"/g, '""') + '","' + (d.material || '').replace(/"/g, '""') + '","' + (d.quantity || 1) + '","' + d.amount + '","' + d.gst + '","' + d.total + '","' + d.status + '","' + d.created_at + '"\n';
            });

            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement("a");
            const url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "Supplexio_Purchase_Orders_" + new Date().toISOString().slice(0, 10) + ".csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            showToast("Exported " + data.length + " PO records to CSV successfully!", "success");
        }

        // -------------------------------------------------------------------
        // TOAST NOTIFICATIONS
        // -------------------------------------------------------------------
        function showToast(message, type) {
            type = type || 'info';
            const container = document.getElementById('toast-container');
            if (!container) return;
            const toast = document.createElement('div');
            
            let bgClass = 'bg-slate-900 text-white';
            let icon = 'info';

            if (type === 'success') {
                bgClass = 'bg-emerald-700 text-white shadow-lg';
                icon = 'check-circle';
            } else if (type === 'error') {
                bgClass = 'bg-rose-700 text-white shadow-lg';
                icon = 'alert-octagon';
            } else if (type === 'info') {
                bgClass = 'bg-brand-royalMid text-white shadow-lg';
                icon = 'bell';
            }

            toast.className = bgClass + " text-xs font-semibold px-4 py-3 rounded-xl shadow-xl flex items-center gap-2.5 transition-all duration-300 transform translate-y-2 opacity-0 pointer-events-auto border border-white/20";
            toast.innerHTML = '<i data-lucide="' + icon + '" class="w-4 h-4 text-[#2DD4BF]"></i>' +
                '<span>' + message + '</span>';

            container.appendChild(toast);
            lucide.createIcons();

            setTimeout(() => {
                toast.classList.remove('translate-y-2', 'opacity-0');
            }, 10);

            setTimeout(() => {
                toast.classList.add('opacity-0', 'translate-y-2');
                setTimeout(() => toast.remove(), 300);
            }, 3500);
        }

        // -------------------------------------------------------------------
        // AI ASSISTANT POPUP LOGIC
        // -------------------------------------------------------------------
        function toggleAiDrawer() {
            const modal = document.getElementById('ai-modal');
            if (modal) modal.classList.toggle('hidden');
        }

        function sendAiMessage() {
            const input = document.getElementById('ai-input');
            const txt = input.value.trim();
            if (!txt) return;

            const chatBody = document.getElementById('ai-chat-body');

            const userMsg = document.createElement('div');
            userMsg.className = 'bg-brand-royalMid text-white p-3 rounded-xl max-w-[85%] ml-auto text-xs';
            userMsg.textContent = txt;
            chatBody.appendChild(userMsg);

            input.value = '';
            chatBody.scrollTop = chatBody.scrollHeight;

            setTimeout(() => {
                const aiMsg = document.createElement('div');
                aiMsg.className = 'bg-white border border-slate-200 text-slate-800 p-3 rounded-xl max-w-[85%] shadow-sm text-xs';
                aiMsg.innerHTML = '<strong>Supplexio AI Copilot:</strong> Real-time scan of ' + state.pos.length + ' purchase orders completed. All tax calculations comply with 7.5% GST requirements. Originating reverse auctions are synced.';
                chatBody.appendChild(aiMsg);
                chatBody.scrollTop = chatBody.scrollHeight;
            }, 600);
        }

        // Deep-linking URL parameter handlers for Drawer and Modals
        (function checkUrlParams() {
            try {
                const p = new URLSearchParams(window.location.search);
                if (p.has('openDrawer')) {
                    const id = parseInt(p.get('openDrawer')) || (state.pos[0] ? state.pos[0].id : 44);
                    const docType = p.get('docType') || 'PO';
                    setTimeout(() => openDocumentDrawer(id, docType), 150);
                }
                if (p.has('openAudit')) {
                    const id = parseInt(p.get('openAudit')) || (state.pos[0] ? state.pos[0].id : 44);
                    setTimeout(() => openAuditModal(id), 150);
                }
                if (p.has('profile')) {
                    setTimeout(() => openUserProfileModal(), 200);
                }
            } catch(e) {
                console.error('Error handling URL params', e);
            }
        })();
    
        // -------------------------------------------------------------------
        // USER PROFILE & PASSWORD MODAL LOGIC
        // -------------------------------------------------------------------
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
            modal.classList.add('flex');
            if (typeof lucide !== 'undefined') lucide.createIcons();
        }

        function closeUserProfileModal() {
            const modal = document.getElementById('userProfileModal');
            if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
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

            const ctx = (typeof contextPath !== 'undefined') ? contextPath : '<%= request.getContextPath() %>';

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
        <!-- Backdrop -->
        <div class="fixed inset-0 bg-slate-950/70 backdrop-blur-sm transition-opacity" onclick="closeUserProfileModal()"></div>

        <!-- Modal Content -->
        <div class="relative bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden transform transition-all z-10 animate-in fade-in zoom-in-95 duration-150">
            <!-- Header Banner -->
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

            <!-- Form Body -->
            <div class="p-6 space-y-4">
                <div id="profileModalAlert" class="hidden p-3 rounded-xl text-xs font-semibold"></div>

                <!-- Username Section -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                        Username <span class="text-rose-500">*</span>
                    </label>
                    <input type="text" id="profileModalUsername" value="<%= session.getAttribute("username") != null ? session.getAttribute("username") : "admin" %>" 
                           class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition" 
                           placeholder="Enter username" />
                    <p class="text-[11px] text-slate-400 mt-1">This is your primary login name and account identifier across Supplexio.</p>
                </div>

                <!-- Email Address -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                        Email Address
                    </label>
                    <input type="email" id="profileModalEmail" value="<%= session.getAttribute("userEmail") != null ? session.getAttribute("userEmail") : "admin@example.com" %>" 
                           class="w-full px-3.5 py-2.5 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 font-medium transition" 
                           placeholder="admin@example.com" />
                </div>

                <!-- Password Divider -->
                <div class="pt-2 border-t border-slate-200">
                    <span class="text-xs font-bold text-slate-900 flex items-center gap-1.5">
                        <svg class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                        Change Password (Optional)
                    </span>
                    <p class="text-[11px] text-slate-400 mt-0.5">Leave blank if you only want to update your username or email.</p>
                </div>

                <!-- Current Password -->
                <div>
                    <label class="block text-[11px] font-semibold text-slate-600 mb-1">
                        Current Password
                    </label>
                    <input type="password" id="profileModalOldPassword" 
                           class="w-full px-3.5 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition" 
                           placeholder="Enter current password to verify" autocomplete="current-password" />
                </div>

                <!-- New & Confirm Password -->
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-[11px] font-semibold text-slate-600 mb-1">
                            New Password
                        </label>
                        <input type="password" id="profileModalNewPassword" 
                               class="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition" 
                               placeholder="Min 6 characters" autocomplete="new-password" />
                    </div>
                    <div>
                        <label class="block text-[11px] font-semibold text-slate-600 mb-1">
                            Confirm Password
                        </label>
                        <input type="password" id="profileModalConfirmPassword" 
                               class="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-blue-600 focus:bg-white text-slate-900 transition" 
                               placeholder="Re-enter password" autocomplete="new-password" />
                    </div>
                </div>
            </div>

            <!-- Footer Action Buttons -->
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
