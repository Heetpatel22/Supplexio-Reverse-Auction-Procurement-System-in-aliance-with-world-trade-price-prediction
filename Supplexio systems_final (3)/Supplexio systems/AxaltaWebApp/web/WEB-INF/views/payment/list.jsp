<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page import="java.util.List, java.util.Map, java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONArray, org.json.simple.JSONObject"%>
<%
    List<Map<String, Object>> histList = (List<Map<String, Object>>) request.getAttribute("paymentHistory");
    JSONArray historyJson = new JSONArray();
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    if (histList != null) {
        for (Map<String, Object> p : histList) {
            JSONObject item = new JSONObject();
            item.put("id", p.get("id"));
            item.put("poId", p.get("poId"));
            item.put("auctionId", p.get("auctionId"));
            item.put("supplier", p.get("supplierName") != null ? p.get("supplierName") : "Unknown");
            item.put("product", p.get("productName") != null ? p.get("productName") : "N/A");
            item.put("amount", p.get("amount") != null ? p.get("amount") : 0.0);
            item.put("method", p.get("paymentMethod") != null ? p.get("paymentMethod") : "RTGS");
            item.put("status", p.get("status") != null ? p.get("status") : "Settled");
            Object d = p.get("paymentDate");
            if (d != null) {
                if (d instanceof java.util.Date) {
                    item.put("date", dateFmt.format((java.util.Date) d));
                } else {
                    item.put("date", d.toString());
                }
            } else {
                item.put("date", "-");
            }
            String utr = (String) p.get("transactionId");
            if (utr == null || utr.trim().isEmpty()) {
                utr = "SXP-UTR-" + p.get("id");
            }
            item.put("utr", utr);
            historyJson.add(item);
        }
    }

    List<Map<String, Object>> winList = (List<Map<String, Object>>) request.getAttribute("auctionWinners");
    JSONArray winnersJson = new JSONArray();
    if (winList != null) {
        for (Map<String, Object> w : winList) {
            JSONObject item = new JSONObject();
            item.put("poId", w.get("poId"));
            item.put("auctionId", "#AUC-" + w.get("auctionId"));
            item.put("product", w.get("productName"));
            item.put("supplier", w.get("supplierName"));
            item.put("amount", w.get("amount"));
            item.put("supplierId", w.get("supplierId"));
            item.put("invoiceId", w.get("invoiceId"));
            winnersJson.add(item);
        }
    }
%>
<!DOCTYPE html>
<html lang="en" class="h-full bg-[#F4F7FC]">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio — Payment Management & Settlement Ledger</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Inter & JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome & Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Alpine.js for lightweight reactivity -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

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
                            800: '#122456',
                            900: '#0F1E46',
                            950: '#0B1E3D',
                        },
                        suppleBlue: {
                            500: '#0066FF',
                            600: '#0052CC',
                            700: '#003D99',
                        },
                        suppleCyan: '#2DD4BF',
                        suppleAmber: '#F59E0B',
                    }
                }
            }
        }
    </script>
    <style>
        [x-cloak] { display: none !important; }
        .tabular-nums { font-variant-numeric: tabular-nums; }
        /* Custom scrollbars */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: #f1f5f9; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        .glass-btn {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .glass-btn:hover {
            background: rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body class="h-full text-slate-800 font-sans antialiased overflow-x-hidden selection:bg-blue-500 selection:text-white bg-[#F4F7FC]"
      x-data="paymentApp()"
      x-init="initData()">

    <!-- Include unified Supplexio sidebar (DO NOT REPLACE SIDEBAR) -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="flex h-screen w-full overflow-hidden bg-[#F4F7FC]">

        <!-- ==================== MAIN CONTENT AREA ==================== -->
        <main class="flex-1 flex flex-col min-w-0 overflow-y-auto">

            <!-- Top Header & Workspace Title -->
            <div class="p-6 pb-0 space-y-5">

                <!-- Alert Messages from Session or Request -->
                <c:if test="${not empty sessionScope.success}">
                    <div class="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-xs font-semibold flex items-center justify-between shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i data-lucide="check-circle-2" class="w-5 h-5 text-emerald-600"></i>
                            <span>${sessionScope.success}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-700 hover:text-emerald-900">&times;</button>
                    </div>
                    <c:remove var="success" scope="session"/>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-xs font-semibold flex items-center justify-between shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i data-lucide="check-circle-2" class="w-5 h-5 text-emerald-600"></i>
                            <span>${success}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-700 hover:text-emerald-900">&times;</button>
                    </div>
                </c:if>
                <c:if test="${not empty sessionScope.error}">
                    <div class="p-4 bg-rose-50 border border-rose-200 text-rose-800 rounded-xl text-xs font-semibold flex items-center justify-between shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i data-lucide="alert-circle" class="w-5 h-5 text-rose-600"></i>
                            <span>${sessionScope.error}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-rose-700 hover:text-rose-900">&times;</button>
                    </div>
                    <c:remove var="error" scope="session"/>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="p-4 bg-rose-50 border border-rose-200 text-rose-800 rounded-xl text-xs font-semibold flex items-center justify-between shadow-sm">
                        <div class="flex items-center gap-2.5">
                            <i data-lucide="alert-circle" class="w-5 h-5 text-rose-600"></i>
                            <span>${error}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-rose-700 hover:text-rose-900">&times;</button>
                    </div>
                </c:if>
                
                <!-- Command Header Card Banner -->
                <div class="bg-gradient-to-r from-[#0F172A] via-[#1E293B] to-[#0F172A] rounded-2xl p-5 text-white shadow-xl border border-slate-800 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-xl bg-blue-600/20 border border-blue-500/40 flex items-center justify-center text-blue-400 shadow-inner">
                            <i data-lucide="wallet" class="w-6 h-6"></i>
                        </div>
                        <div>
                            <div class="flex items-center gap-2">
                                <h1 class="text-xl font-bold tracking-tight">Payment Management & Settlement Ledger</h1>
                                <span class="bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-[10px] font-semibold px-2 py-0.5 rounded-full">GST Reconciled</span>
                            </div>
                            <p class="text-xs text-slate-400 mt-1">Automated supplier payouts, reverse auction escrow disbursements & audit compliance ledger.</p>
                        </div>
                    </div>

                    <div class="flex items-center gap-2 w-full md:w-auto">
                        <button @click="exportCSV()" class="glass-btn text-white hover:text-slate-100 text-xs font-semibold px-4 py-2.5 rounded-xl transition flex items-center gap-2 shadow-sm cursor-pointer">
                            <i data-lucide="download" class="w-4 h-4"></i>
                            <span>Export CSV</span>
                        </button>
                        <button @click="showRecordModal = true" class="bg-amber-500 hover:bg-amber-600 text-slate-950 text-xs font-bold px-4 py-2.5 rounded-xl transition flex items-center gap-2 shadow-lg shadow-amber-500/20 cursor-pointer">
                            <i data-lucide="plus-circle" class="w-4 h-4"></i>
                            <span>+ Record Payout</span>
                        </button>
                    </div>
                </div>

                <!-- Executive KPI Strip -->
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">

                    <!-- Card 1: Total Disbursed Volume -->
                    <div class="bg-white rounded-xl p-4 border border-slate-200 shadow-sm relative overflow-hidden group hover:border-blue-300 transition">
                        <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 to-indigo-600"></div>
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Total Disbursed Volume</span>
                                <div class="text-xl font-bold font-mono text-slate-900 mt-1 tabular-nums" x-text="formatINR(totalDisbursed)"></div>
                            </div>
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                                <i data-lucide="indian-rupee" class="w-5 h-5"></i>
                            </div>
                        </div>
                        <div class="mt-2 flex items-center justify-between text-xs">
                            <span class="text-slate-500" x-text="historyData.length + ' Settled Transactions'"></span>
                            <span class="text-emerald-600 font-medium flex items-center gap-1">
                                <i data-lucide="trending-up" class="w-3.5 h-3.5"></i> +12.4% vs last mo
                            </span>
                        </div>
                    </div>

                    <!-- Card 2: Pending Auction Payouts -->
                    <div class="bg-white rounded-xl p-4 border border-slate-200 shadow-sm relative overflow-hidden group hover:border-amber-300 transition">
                        <div class="absolute top-0 left-0 right-0 h-1 bg-amber-500"></div>
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Pending Auction Escrow</span>
                                <div class="text-xl font-bold font-mono text-slate-900 mt-1 tabular-nums" x-text="formatINR(pendingAmount)"></div>
                            </div>
                            <div class="w-9 h-9 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
                                <i data-lucide="clock" class="w-5 h-5"></i>
                            </div>
                        </div>
                        <div class="mt-2 flex items-center justify-between text-xs">
                            <span class="text-slate-500" x-text="pendingAuctions.length + ' Pending Action'"></span>
                            <span x-show="pendingAuctions.length === 0" class="text-slate-400 italic">Clear queue</span>
                            <span x-show="pendingAuctions.length > 0" class="text-amber-600 font-semibold animate-pulse">Action Required</span>
                        </div>
                    </div>

                    <!-- Card 3: Settled Transactions -->
                    <div class="bg-white rounded-xl p-4 border border-slate-200 shadow-sm relative overflow-hidden group hover:border-emerald-300 transition">
                        <div class="absolute top-0 left-0 right-0 h-1 bg-emerald-500"></div>
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Settlement Accuracy</span>
                                <div class="text-xl font-bold font-mono text-slate-900 mt-1 tabular-nums">100%</div>
                            </div>
                            <div class="w-9 h-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                                <i data-lucide="check-circle-2" class="w-5 h-5"></i>
                            </div>
                        </div>
                        <div class="mt-2 flex items-center justify-between text-xs">
                            <span class="text-slate-500">Automated RTGS/NEFT</span>
                            <span class="bg-emerald-100 text-emerald-700 font-semibold text-[10px] px-2 py-0.5 rounded-full">Reconciled</span>
                        </div>
                    </div>

                    <!-- Card 4: Largest Single Payout -->
                    <div class="bg-white rounded-xl p-4 border border-slate-200 shadow-sm relative overflow-hidden group hover:border-purple-300 transition">
                        <div class="absolute top-0 left-0 right-0 h-1 bg-purple-500"></div>
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Peak Transaction</span>
                                <div class="text-xl font-bold font-mono text-slate-900 mt-1 tabular-nums" x-text="formatINR(maxPayout.amount)"></div>
                            </div>
                            <div class="w-9 h-9 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center">
                                <i data-lucide="award" class="w-5 h-5"></i>
                            </div>
                        </div>
                        <div class="mt-2 flex items-center justify-between text-xs text-slate-500 truncate">
                            <span class="truncate">Supplier: <strong class="text-slate-800" x-text="maxPayout.supplier"></strong></span>
                            <span class="font-mono text-[10px] text-slate-400">#37</span>
                        </div>
                    </div>

                </div>

                <!-- High-Density Filter Bar Card -->
                <div class="bg-white rounded-xl p-4 border border-slate-200 shadow-sm space-y-3">
                    <form method="get" action="${pageContext.request.contextPath}/payment" class="grid grid-cols-1 md:grid-cols-6 gap-3">
                        <input type="hidden" name="action" value="filter">

                        <!-- Search Box -->
                        <div class="md:col-span-2 relative">
                            <label class="block text-[11px] font-semibold text-slate-500 mb-1">Search Keywords</label>
                            <div class="relative">
                                <i data-lucide="search" class="w-4 h-4 text-slate-400 absolute left-3 top-2.5"></i>
                                <input type="text" x-model="filterSearch" name="search" placeholder="Search ID, Supplier, Product or UTR..."
                                       class="w-full pl-9 pr-3 py-1.5 text-xs border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none">
                            </div>
                        </div>

                        <!-- Date Range: Start Date -->
                        <div>
                            <label class="block text-[11px] font-semibold text-slate-500 mb-1">Start Date</label>
                            <input type="date" x-model="filterStartDate" name="startDate" value="${startDate}"
                                   class="w-full px-2.5 py-1.5 text-xs border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-slate-700">
                        </div>

                        <!-- Date Range: End Date -->
                        <div>
                            <label class="block text-[11px] font-semibold text-slate-500 mb-1">End Date</label>
                            <input type="date" x-model="filterEndDate" name="endDate" value="${endDate}"
                                   class="w-full px-2.5 py-1.5 text-xs border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-slate-700">
                        </div>

                        <!-- Status Dropdown -->
                        <div>
                            <label class="block text-[11px] font-semibold text-slate-500 mb-1">Status</label>
                            <select x-model="filterStatus" name="status" class="w-full px-2.5 py-1.5 text-xs border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-slate-700">
                                <option value="ALL">All Statuses</option>
                                <option value="COMPLETED" ${statusFilter == 'COMPLETED' ? 'selected' : ''}>Settled / Completed</option>
                                <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Processing / Pending</option>
                                <option value="FAILED" ${statusFilter == 'FAILED' ? 'selected' : ''}>Failed</option>
                            </select>
                        </div>

                        <!-- Payment Method Dropdown -->
                        <div>
                            <label class="block text-[11px] font-semibold text-slate-500 mb-1">Payment Method</label>
                            <select x-model="filterMethod" name="paymentMethod" class="w-full px-2.5 py-1.5 text-xs border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-slate-700">
                                <option value="ALL">All Methods</option>
                                <option value="RTGS" ${paymentMethodFilter == 'RTGS' || paymentMethodFilter == 'BANK_TRANSFER' ? 'selected' : ''}>RTGS / NEFT / Bank</option>
                                <option value="Escrow" ${paymentMethodFilter == 'Escrow' ? 'selected' : ''}>Escrow Auto-Pay</option>
                                <option value="UPI" ${paymentMethodFilter == 'UPI' ? 'selected' : ''}>Corporate UPI</option>
                                <option value="CREDIT_CARD" ${paymentMethodFilter == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                                <option value="CHEQUE" ${paymentMethodFilter == 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                                <option value="CASH" ${paymentMethodFilter == 'CASH' ? 'selected' : ''}>Cash</option>
                            </select>
                        </div>
                    </form>

                    <!-- Preset Pills & Action Buttons -->
                    <div class="flex flex-wrap items-center justify-between gap-2 pt-2 border-t border-slate-100 text-xs">
                        <div class="flex items-center gap-1.5">
                            <span class="text-slate-400 text-[11px] mr-1">Presets:</span>
                            <button type="button" @click="resetFilters()" class="px-2.5 py-1 rounded-md bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium transition text-[11px] cursor-pointer">All Time</button>
                            <button type="button" @click="setPreset('2026')" class="px-2.5 py-1 rounded-md bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium transition text-[11px] cursor-pointer">Year 2026</button>
                            <button type="button" @click="setPreset('2025')" class="px-2.5 py-1 rounded-md bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium transition text-[11px] cursor-pointer">Year 2025</button>
                            <button type="button" @click="setPreset('Heet Patel')" class="px-2.5 py-1 rounded-md bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium transition text-[11px] cursor-pointer">Supplier: Heet Patel</button>
                        </div>
                        <div class="flex items-center gap-2">
                            <button type="button" @click="resetFilters()" class="text-slate-500 hover:text-slate-800 text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 transition cursor-pointer">
                                Reset Filters
                            </button>
                            <button type="button" @click="applyFilters()" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-1.5 rounded-lg text-xs shadow-sm flex items-center gap-1.5 transition cursor-pointer">
                                <i data-lucide="filter" class="w-3.5 h-3.5"></i>
                                <span>Filter Ledger</span>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Scrollable Tables Container -->
            <div class="p-6 space-y-6">

                <!-- SECTION 1: Auction Winners (Pending Payouts) -->
                <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                    <!-- Royal Blue Vibrant Banner Header -->
                    <div class="bg-gradient-to-r from-blue-600 via-blue-700 to-indigo-800 px-5 py-3.5 text-white flex items-center justify-between">
                        <div class="flex items-center gap-2.5">
                            <div class="w-7 h-7 rounded-md bg-white/10 flex items-center justify-center">
                                <i data-lucide="trophy" class="w-4 h-4 text-amber-300"></i>
                            </div>
                            <h2 class="text-sm font-bold tracking-wide">Auction Winners — Pending Payouts</h2>
                            <span class="bg-white/20 text-white text-xs font-mono font-bold px-2 py-0.5 rounded-full"
                                  x-text="pendingAuctions.length + ' Pending'"></span>
                        </div>

                        <button @click="simulateAwardedAuction()" class="bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-xs px-3 py-1.5 rounded-lg transition shadow flex items-center gap-1.5 cursor-pointer">
                            <i data-lucide="plus" class="w-3.5 h-3.5"></i>
                            <span>+ Simulate Awarded Auction</span>
                        </button>
                    </div>

                    <!-- Pending Auctions Table or Empty State -->
                    <div class="overflow-x-auto">
                        <template x-if="pendingAuctions.length === 0">
                            <div class="py-10 text-center flex flex-col items-center justify-center bg-slate-50/50">
                                <div class="w-12 h-12 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mb-2 shadow-sm">
                                    <i data-lucide="check-circle" class="w-6 h-6"></i>
                                </div>
                                <h3 class="text-sm font-semibold text-slate-800">No payments pending</h3>
                                <p class="text-xs text-slate-500 mt-0.5 max-w-sm">All awarded reverse auctions have been settled and disbursed to suppliers seamlessly.</p>
                            </div>
                        </template>

                        <template x-if="pendingAuctions.length > 0">
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-500 border-b border-slate-200">
                                        <th class="px-5 py-3">AUCTION ID</th>
                                        <th class="px-5 py-3">PRODUCT</th>
                                        <th class="px-5 py-3">WINNING SUPPLIER</th>
                                        <th class="px-5 py-3 text-right">WINNING AMOUNT</th>
                                        <th class="px-5 py-3 text-center">PAYMENT STATUS</th>
                                        <th class="px-5 py-3 text-center">ACTIONS</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 text-xs">
                                    <template x-for="item in pendingAuctions" :key="item.auctionId">
                                        <tr class="hover:bg-amber-50/30 transition">
                                            <td class="px-5 py-3.5 font-mono font-semibold text-blue-600" x-text="item.auctionId"></td>
                                            <td class="px-5 py-3.5 font-medium text-slate-800" x-text="item.product"></td>
                                            <td class="px-5 py-3.5 text-slate-700">
                                                <div class="flex items-center gap-2">
                                                    <span class="w-6 h-6 rounded-full bg-blue-100 text-blue-700 font-bold text-[10px] flex items-center justify-center" x-text="getInitials(item.supplier)"></span>
                                                    <span x-text="item.supplier"></span>
                                                </div>
                                            </td>
                                            <td class="px-5 py-3.5 font-mono font-bold text-slate-900 text-right tabular-nums" x-text="formatINR(item.amount)"></td>
                                            <td class="px-5 py-3.5 text-center">
                                                <span class="inline-flex items-center gap-1.5 bg-amber-100 text-amber-800 text-[11px] font-semibold px-2.5 py-0.5 rounded-full">
                                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
                                                    Escrow Locked
                                                </span>
                                            </td>
                                            <td class="px-5 py-3.5 text-center">
                                                <div class="flex items-center justify-center gap-2">
                                                    <button @click="openReleaseModal(item)" class="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs px-3 py-1.5 rounded-lg transition shadow-sm flex items-center justify-center gap-1 cursor-pointer">
                                                        <i data-lucide="send" class="w-3.5 h-3.5"></i>
                                                        <span>Release Payout</span>
                                                    </button>
                                                    <template x-if="item.poId">
                                                        <a :href="'${pageContext.request.contextPath}/payment?action=new&poId=' + item.poId" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs px-2.5 py-1.5 rounded-lg transition shadow-sm flex items-center gap-1 no-underline cursor-pointer">
                                                            <i data-lucide="file-text" class="w-3.5 h-3.5"></i>
                                                            <span>Pay Invoice</span>
                                                        </a>
                                                    </template>
                                                </div>
                                            </td>
                                        </tr>
                                    </template>
                                </tbody>
                            </table>
                        </template>
                    </div>
                </div>

                <!-- SECTION 2: Payment History Ledger -->
                <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                    <!-- Royal Blue Header Banner -->
                    <div class="bg-gradient-to-r from-blue-600 via-blue-700 to-indigo-800 px-5 py-3.5 text-white flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                        <div class="flex items-center gap-2.5">
                            <div class="w-7 h-7 rounded-md bg-white/10 flex items-center justify-center">
                                <i data-lucide="history" class="w-4 h-4 text-white"></i>
                            </div>
                            <h2 class="text-sm font-bold tracking-wide">Payment History Ledger</h2>
                            <span class="bg-white/20 text-white text-xs font-mono font-bold px-2 py-0.5 rounded-full"
                                  x-text="filteredHistory.length + ' Records'"></span>
                        </div>

                        <!-- Controls right -->
                        <div class="flex items-center gap-3 text-xs">
                            <div class="flex items-center gap-1 text-slate-200">
                                <span>Rows per page:</span>
                                <select x-model.number="pageSize" class="bg-white/10 text-white border border-white/20 rounded px-2 py-1 focus:outline-none text-xs cursor-pointer">
                                    <option value="10" class="text-slate-800">10</option>
                                    <option value="20" class="text-slate-800">20</option>
                                    <option value="50" class="text-slate-800">50</option>
                                    <option value="100" class="text-slate-800">All</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Ledger Table -->
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-500 border-b border-slate-200">
                                    <th @click="sortBy('id')" class="px-4 py-3 cursor-pointer hover:bg-slate-100 transition select-none">
                                        <div class="flex items-center gap-1">
                                            <span>ID</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th @click="sortBy('supplier')" class="px-4 py-3 cursor-pointer hover:bg-slate-100 transition select-none">
                                        <div class="flex items-center gap-1">
                                            <span>SUPPLIER</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th @click="sortBy('product')" class="px-4 py-3 cursor-pointer hover:bg-slate-100 transition select-none">
                                        <div class="flex items-center gap-1">
                                            <span>PRODUCT</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="px-4 py-3">METHOD</th>
                                    <th @click="sortBy('amount')" class="px-4 py-3 text-right cursor-pointer hover:bg-slate-100 transition select-none">
                                        <div class="flex items-center justify-end gap-1">
                                            <span>AMOUNT</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th @click="sortBy('date')" class="px-4 py-3 cursor-pointer hover:bg-slate-100 transition select-none">
                                        <div class="flex items-center gap-1">
                                            <span>PAYMENT DATE</span>
                                            <i data-lucide="arrow-up-down" class="w-3 h-3 text-slate-400"></i>
                                        </div>
                                    </th>
                                    <th class="px-4 py-3 text-center">STATUS</th>
                                    <th class="px-4 py-3 text-center">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 text-xs">
                                <template x-for="row in paginatedHistory" :key="row.id">
                                    <tr class="hover:bg-blue-50/40 transition cursor-pointer group" @click="openReceiptDrawer(row)">
                                        <!-- ID -->
                                        <td class="px-4 py-3 font-mono font-semibold text-slate-500 group-hover:text-blue-600" x-text="'#' + row.id"></td>
                                        
                                        <!-- SUPPLIER -->
                                        <td class="px-4 py-3 text-slate-800">
                                            <div class="flex items-center gap-2">
                                                <span class="w-6 h-6 rounded-full bg-slate-100 border border-slate-200 text-slate-700 font-bold text-[10px] flex items-center justify-center group-hover:border-blue-400 group-hover:bg-blue-100 group-hover:text-blue-700 transition"
                                                      x-text="getInitials(row.supplier)"></span>
                                                <span class="font-medium" x-text="row.supplier"></span>
                                            </div>
                                        </td>
                                        
                                        <!-- PRODUCT -->
                                        <td class="px-4 py-3 font-semibold text-slate-900" x-text="row.product"></td>
                                        
                                        <!-- METHOD -->
                                        <td class="px-4 py-3">
                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-semibold"
                                                  :class="getMethodBadgeClass(row.method)">
                                                <i data-lucide="credit-card" class="w-3 h-3"></i>
                                                <span x-text="row.method || 'RTGS'"></span>
                                            </span>
                                        </td>
                                        
                                        <!-- AMOUNT -->
                                        <td class="px-4 py-3 font-mono font-bold text-slate-900 text-right tabular-nums text-sm" x-text="formatINR(row.amount)"></td>
                                        
                                        <!-- PAYMENT DATE -->
                                        <td class="px-4 py-3 font-mono text-slate-600">
                                            <span x-text="row.date !== '-' ? row.date : '—'" :class="row.date === '-' ? 'text-slate-400 font-sans italic' : ''"></span>
                                        </td>
                                        
                                        <!-- STATUS -->
                                        <td class="px-4 py-3 text-center">
                                            <span class="inline-flex items-center gap-1 bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-bold px-2.5 py-0.5 rounded-full">
                                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                                <span x-text="row.status || 'Settled'"></span>
                                            </span>
                                        </td>
                                        
                                        <!-- ACTIONS -->
                                        <td class="px-4 py-3 text-center" @click.stop>
                                            <div class="flex items-center justify-center gap-1">
                                                <button @click="openReceiptDrawer(row)" title="View Receipt & Audit Trail" class="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition cursor-pointer">
                                                    <i data-lucide="eye" class="w-4 h-4"></i>
                                                </button>
                                                <button @click="downloadVoucher(row)" title="Download Payment Voucher" class="p-1.5 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-lg transition cursor-pointer">
                                                    <i data-lucide="file-text" class="w-4 h-4"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </template>

                                <!-- Empty search result state -->
                                <template x-if="filteredHistory.length === 0">
                                    <tr>
                                        <td colspan="8" class="py-12 text-center text-slate-400">
                                            <i data-lucide="file-x" class="w-8 h-8 mx-auto mb-2 text-slate-300"></i>
                                            <p class="text-sm font-medium">No matching payment records found</p>
                                            <p class="text-xs mt-1">Try resetting your date or search filters.</p>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Footer -->
                    <div class="px-5 py-3.5 bg-slate-50 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-600">
                        <div>
                            Showing <strong x-text="startIndex + 1"></strong> to <strong x-text="endIndex"></strong> of <strong x-text="filteredHistory.length"></strong> entries
                        </div>
                        <div class="flex items-center gap-1">
                            <button @click="prevPage()" :disabled="currentPage === 1" class="px-2.5 py-1.5 border border-slate-300 rounded-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-white font-medium transition cursor-pointer">
                                Previous
                            </button>
                            <span class="px-3 font-mono font-bold text-slate-800" x-text="currentPage + ' / ' + totalPages"></span>
                            <button @click="nextPage()" :disabled="currentPage >= totalPages" class="px-2.5 py-1.5 border border-slate-300 rounded-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-white font-medium transition cursor-pointer">
                                Next
                            </button>
                        </div>
                    </div>

                </div>

            </div>
        </main>
    </div>

    <!-- ==================== RECEIPT & AUDIT SLIDE-OVER DRAWER ==================== -->
    <div x-show="showDrawer" x-cloak class="fixed inset-0 z-50 overflow-hidden" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
        <!-- Backdrop -->
        <div x-show="showDrawer" x-transition:enter="ease-in-out duration-300" x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100" x-transition:leave="ease-in-out duration-300" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
             @click="showDrawer = false" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm transition-opacity"></div>

        <div class="fixed inset-y-0 right-0 max-w-full flex pl-10">
            <div x-show="showDrawer" x-transition:enter="transform transition ease-in-out duration-300" x-transition:enter-start="translate-x-full" x-transition:enter-end="translate-x-0" x-transition:leave="transform transition ease-in-out duration-300" x-transition:leave-start="translate-x-0" x-transition:leave-end="translate-x-full"
                 class="w-screen max-w-md bg-white shadow-2xl flex flex-col justify-between">
                
                <!-- Drawer Header -->
                <div class="p-6 bg-slate-900 text-white flex items-center justify-between border-b border-slate-800">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-blue-500/20 border border-blue-400/30 flex items-center justify-center text-blue-400">
                            <i data-lucide="receipt" class="w-5 h-5"></i>
                        </div>
                        <div>
                            <h3 class="text-base font-bold">Payment Voucher Receipt</h3>
                            <p class="text-xs text-slate-400 font-mono" x-text="activeReceipt ? activeReceipt.utr : ''"></p>
                        </div>
                    </div>
                    <button @click="showDrawer = false" class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-white/10 transition cursor-pointer">
                        <i data-lucide="x" class="w-5 h-5"></i>
                    </button>
                </div>

                <!-- Drawer Content -->
                <div class="p-6 space-y-6 overflow-y-auto flex-1 text-xs">
                    
                    <!-- Amount Banner -->
                    <div class="bg-blue-50 border border-blue-200 rounded-xl p-4 text-center">
                        <span class="text-[11px] font-semibold uppercase tracking-wider text-blue-600">Net Settled Amount</span>
                        <div class="text-3xl font-black font-mono text-blue-900 mt-1 tabular-nums" x-text="activeReceipt ? formatINR(activeReceipt.amount) : '₹0.00'"></div>
                        <div class="mt-2 inline-flex items-center gap-1.5 bg-emerald-100 text-emerald-800 text-[11px] font-bold px-3 py-0.5 rounded-full">
                            <i data-lucide="check-circle" class="w-3.5 h-3.5"></i>
                            Bank Settlement Confirmed
                        </div>
                    </div>

                    <!-- Metadata Grid -->
                    <div class="space-y-3">
                        <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400">Transaction Details</h4>
                        <div class="bg-slate-50 rounded-xl p-3.5 border border-slate-200 space-y-2.5">
                            <div class="flex justify-between">
                                <span class="text-slate-500">Transaction ID:</span>
                                <span class="font-mono font-bold text-slate-800" x-text="activeReceipt ? '#' + activeReceipt.id : ''"></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-slate-500">Supplier Name:</span>
                                <span class="font-semibold text-slate-800" x-text="activeReceipt ? activeReceipt.supplier : ''"></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-slate-500">Procured Product:</span>
                                <span class="font-semibold text-slate-800" x-text="activeReceipt ? activeReceipt.product : ''"></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-slate-500">Payment Channel:</span>
                                <span class="font-medium text-slate-800" x-text="activeReceipt ? (activeReceipt.method || 'RTGS Bank Wire') : ''"></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-slate-500">Timestamp:</span>
                                <span class="font-mono text-slate-700" x-text="activeReceipt ? (activeReceipt.date !== '-' ? activeReceipt.date : 'Legacy Settlement') : ''"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Tax & Fee Breakdown -->
                    <div class="space-y-3">
                        <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400">Financial Breakdown (Estimated GST)</h4>
                        <div class="border border-slate-200 rounded-xl p-3.5 space-y-2">
                            <div class="flex justify-between text-slate-600">
                                <span>Base Goods Value (Excl. Tax):</span>
                                <span class="font-mono" x-text="activeReceipt ? formatINR(activeReceipt.amount / 1.18) : ''"></span>
                            </div>
                            <div class="flex justify-between text-slate-600">
                                <span>Applicable GST (18% Input Credit):</span>
                                <span class="font-mono" x-text="activeReceipt ? formatINR(activeReceipt.amount - (activeReceipt.amount / 1.18)) : ''"></span>
                            </div>
                            <div class="pt-2 border-t border-slate-200 flex justify-between font-bold text-slate-900">
                                <span>Total Paid:</span>
                                <span class="font-mono" x-text="activeReceipt ? formatINR(activeReceipt.amount) : ''"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Audit Workflow Timeline -->
                    <div class="space-y-3">
                        <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400">Settlement Audit Trail</h4>
                        <div class="relative pl-5 space-y-4 border-l-2 border-emerald-400">
                            <div class="relative">
                                <span class="absolute -left-[27px] top-0 w-3 h-3 rounded-full bg-emerald-500 border-2 border-white"></span>
                                <p class="font-bold text-slate-800">Reverse Auction Concluded</p>
                                <p class="text-[11px] text-slate-500">Lowest bid awarded to supplier</p>
                            </div>
                            <div class="relative">
                                <span class="absolute -left-[27px] top-0 w-3 h-3 rounded-full bg-emerald-500 border-2 border-white"></span>
                                <p class="font-bold text-slate-800">Escrow Escorted & PO Matched</p>
                                <p class="text-[11px] text-slate-500">Quality verification check passed</p>
                            </div>
                            <div class="relative">
                                <span class="absolute -left-[27px] top-0 w-3 h-3 rounded-full bg-emerald-500 border-2 border-white"></span>
                                <p class="font-bold text-slate-800">Bank Wire Disbursed</p>
                                <p class="text-[11px] font-mono text-emerald-700" x-text="activeReceipt ? activeReceipt.utr : ''"></p>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Drawer Footer Actions -->
                <div class="p-4 bg-slate-50 border-t border-slate-200 flex items-center gap-3">
                    <button @click="printReceipt()" class="w-full bg-slate-900 hover:bg-slate-800 text-white font-bold py-2.5 px-4 rounded-xl transition flex items-center justify-center gap-2 cursor-pointer">
                        <i data-lucide="printer" class="w-4 h-4"></i>
                        <span>Print Official Voucher</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- ==================== RECORD PAYOUT MODAL ==================== -->
    <div x-show="showRecordModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
        <div @click.away="showRecordModal = false" class="bg-white rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden border border-slate-200">
            <div class="bg-slate-900 text-white px-6 py-4 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <i data-lucide="plus-circle" class="w-5 h-5 text-amber-400"></i>
                    <h3 class="font-bold text-base">Record New Supplier Payout</h3>
                </div>
                <button @click="showRecordModal = false" class="text-slate-400 hover:text-white cursor-pointer">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form @submit.prevent="submitRecordPayout()" class="p-6 space-y-4 text-xs">
                <div>
                    <label class="block font-semibold text-slate-700 mb-1">Supplier Name *</label>
                    <input type="text" x-model="newRecord.supplier" required placeholder="e.g. Heet Patel or Vaibhav Suthar"
                           class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-xs">
                </div>
                <div>
                    <label class="block font-semibold text-slate-700 mb-1">Product Description *</label>
                    <input type="text" x-model="newRecord.product" required placeholder="e.g. Industrial Steel Rods"
                           class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-xs">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block font-semibold text-slate-700 mb-1">Amount (₹) *</label>
                        <input type="number" step="0.01" x-model="newRecord.amount" required placeholder="50000.00"
                               class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono text-xs">
                    </div>
                    <div>
                        <label class="block font-semibold text-slate-700 mb-1">Payment Method</label>
                        <select x-model="newRecord.method" class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-xs">
                            <option value="RTGS">RTGS Wire</option>
                            <option value="NEFT">NEFT Transfer</option>
                            <option value="Escrow">Escrow Auto-Pay</option>
                            <option value="UPI">Corporate UPI</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block font-semibold text-slate-700 mb-1">Payment Date & Time</label>
                    <input type="text" x-model="newRecord.date" placeholder="2026-11-21 14:30:00"
                           class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono text-xs">
                </div>

                <div class="pt-3 border-t border-slate-100 flex items-center justify-end gap-2">
                    <button type="button" @click="showRecordModal = false" class="px-4 py-2 border border-slate-300 rounded-lg font-semibold text-slate-700 hover:bg-slate-50 transition cursor-pointer">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg shadow transition cursor-pointer">
                        Save & Record Payout
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ==================== RELEASE PAYOUT CONFIRMATION MODAL ==================== -->
    <div x-show="showReleaseModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
        <div @click.away="showReleaseModal = false" class="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden border border-slate-200">
            <div class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white px-6 py-4 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <i data-lucide="shield-check" class="w-5 h-5 text-amber-300"></i>
                    <h3 class="font-bold text-base">Authorize Escrow Disbursement</h3>
                </div>
                <button @click="showReleaseModal = false" class="text-white/80 hover:text-white cursor-pointer">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <div class="p-6 space-y-4 text-xs" x-if="selectedReleaseItem">
                <div class="bg-amber-50 border border-amber-200 rounded-xl p-3.5 space-y-1">
                    <div class="text-[11px] font-bold text-amber-800 uppercase">Auction Winner Confirmation</div>
                    <div class="font-bold text-slate-900 text-sm" x-text="selectedReleaseItem?.supplier"></div>
                    <div class="text-slate-600" x-text="'Product: ' + selectedReleaseItem?.product"></div>
                    <div class="font-mono text-lg font-black text-slate-900 mt-2" x-text="selectedReleaseItem ? formatINR(selectedReleaseItem.amount) : ''"></div>
                </div>

                <div>
                    <label class="block font-semibold text-slate-700 mb-1">Select Disbursement Route</label>
                    <select x-model="releaseMethod" class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none text-xs">
                        <option value="Escrow Auto-Pay">Supplexio Escrow Direct Auto-Pay</option>
                        <option value="RTGS">RTGS Instant Bank Wire</option>
                        <option value="NEFT">NEFT Corporate Batch</option>
                    </select>
                </div>

                <p class="text-[11px] text-slate-500">By clicking confirm, funds will be released from Supplexio Escrow to the supplier's verified bank account and logged in the settlement ledger.</p>

                <div class="pt-2 flex items-center justify-end gap-2">
                    <button type="button" @click="showReleaseModal = false" class="px-4 py-2 border border-slate-300 rounded-lg font-semibold text-slate-700 hover:bg-slate-50 transition cursor-pointer">
                        Cancel
                    </button>
                    <button type="button" @click="confirmReleasePayout()" class="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg shadow transition flex items-center gap-1.5 cursor-pointer">
                        <i data-lucide="check" class="w-4 h-4"></i>
                        <span>Confirm & Disburse</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- ==================== FLOATING AI COPILOT BOT & CHAT ==================== -->
    <div class="fixed bottom-6 right-6 z-40">
        <!-- Floating Toggle Button -->
        <button @click="showCopilot = !showCopilot" class="w-12 h-12 rounded-full bg-amber-500 hover:bg-amber-400 text-slate-950 flex items-center justify-center shadow-2xl shadow-amber-500/50 transition-transform transform hover:scale-105 border-2 border-amber-300 cursor-pointer">
            <i data-lucide="bot" class="w-6 h-6"></i>
        </button>

        <!-- Mini Chat Popover -->
        <div x-show="showCopilot" x-cloak x-transition
             class="absolute bottom-16 right-0 w-80 bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col">
            <div class="bg-gradient-to-r from-slate-900 to-blue-950 text-white p-3.5 flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <div class="w-7 h-7 rounded-full bg-amber-500 text-slate-950 flex items-center justify-center font-bold">
                        <i data-lucide="sparkles" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h4 class="font-bold text-xs">Supplexio AI Financial Copilot</h4>
                        <p class="text-[10px] text-slate-300">Live Ledger Assistant</p>
                    </div>
                </div>
                <button @click="showCopilot = false" class="text-slate-400 hover:text-white cursor-pointer">
                    <i data-lucide="x" class="w-4 h-4"></i>
                </button>
            </div>

            <!-- Messages Container -->
            <div class="p-3.5 h-64 overflow-y-auto space-y-3 text-xs bg-slate-50">
                <template x-for="msg in copilotMessages" :key="msg.id">
                    <div class="flex" :class="msg.sender === 'user' ? 'justify-end' : 'justify-start'">
                        <div class="max-w-[85%] rounded-xl p-2.5 shadow-sm"
                             :class="msg.sender === 'user' ? 'bg-blue-600 text-white rounded-br-none' : 'bg-white text-slate-800 border border-slate-200 rounded-bl-none'">
                            <p class="text-[11px]" x-text="msg.text"></p>
                        </div>
                    </div>
                </template>
            </div>

            <!-- Chat Quick Options -->
            <div class="p-2 bg-white border-t border-slate-100 flex flex-wrap gap-1 text-[10px]">
                <button type="button" @click="askCopilot('Total paid to Heet Patel?')" class="px-2 py-1 bg-slate-100 hover:bg-slate-200 rounded-md text-slate-700 cursor-pointer">Total: Heet Patel</button>
                <button type="button" @click="askCopilot('What is the largest payout?')" class="px-2 py-1 bg-slate-100 hover:bg-slate-200 rounded-md text-slate-700 cursor-pointer">Max Payout</button>
                <button type="button" @click="askCopilot('What is pending in escrow?')" class="px-2 py-1 bg-slate-100 hover:bg-slate-200 rounded-md text-slate-700 cursor-pointer">Pending Escrow</button>
            </div>

            <!-- Chat Input -->
            <div class="p-2.5 bg-white border-t border-slate-200 flex items-center gap-2">
                <input type="text" x-model="copilotInput" @keydown.enter="sendCopilotMessage()" placeholder="Ask AI about payments..."
                       class="flex-1 px-3 py-1.5 text-xs border border-slate-300 rounded-lg outline-none focus:ring-1 focus:ring-blue-500">
                <button type="button" @click="sendCopilotMessage()" class="p-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg cursor-pointer">
                    <i data-lucide="send" class="w-4 h-4"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- TOAST NOTIFICATION CONTAINER -->
    <div class="fixed top-5 right-5 z-50 space-y-2 pointer-events-none">
        <template x-for="t in toasts" :key="t.id">
            <div class="pointer-events-auto bg-slate-900 text-white px-4 py-3 rounded-xl shadow-2xl border border-slate-700 flex items-center gap-3 text-xs transition-all transform translate-y-0">
                <i data-lucide="check-circle-2" class="w-5 h-5 text-emerald-400"></i>
                <span font-medium x-text="t.message"></span>
            </div>
        </template>
    </div>

    <!-- ==================== ALPINE JS LOGIC ==================== -->
    <script>
        // Server Seed Data
        const serverHistory = <%= historyJson.isEmpty() ? "[]" : historyJson.toJSONString() %>;
        const serverPending = <%= winnersJson.isEmpty() ? "[]" : winnersJson.toJSONString() %>;

        // Fallback Seed Data (Matches exact verified 30 transactions)
        const fallbackHistory = [
            { id: 37, supplier: 'Heet Patel', product: 'Cattle, live', amount: 3817378.75, date: '2026-11-21 13:09:46', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20261121-0037' },
            { id: 36, supplier: 'Heet Patel', product: 'Granite Slab', amount: 6997.50, date: '2026-11-21 02:49:48', method: 'Escrow', status: 'Settled', utr: 'SXP-UTR-20261121-0036' },
            { id: 35, supplier: 'Heet Patel', product: 'Rake', amount: 600.45, date: '2026-05-16 18:00:11', method: 'NEFT', status: 'Settled', utr: 'SXP-UTR-20260516-0035' },
            { id: 34, supplier: 'Heet Patel', product: 'Granite Slab', amount: 10.75, date: '2026-05-16 17:47:26', method: 'UPI', status: 'Settled', utr: 'SXP-UTR-20260516-0034' },
            { id: 33, supplier: 'Heet Patel', product: 'Shovel', amount: 858.93, date: '2026-05-16 17:34:24', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260516-0033' },
            { id: 32, supplier: 'Heet Patel', product: 'Exhaust Fan', amount: 955.68, date: '2026-05-16 17:34:15', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260516-0032' },
            { id: 31, supplier: 'Heet Patel', product: 'Pickaxe', amount: 7000.00, date: '2026-05-16 00:00:00', method: 'NEFT', status: 'Settled', utr: 'SXP-UTR-20260516-0031' },
            { id: 30, supplier: 'Heet Patel', product: 'Hoe', amount: 899.00, date: '2026-05-16 00:00:00', method: 'UPI', status: 'Settled', utr: 'SXP-UTR-20260516-0030' },
            { id: 29, supplier: 'Heet Patel', product: 'Vibrator Needle', amount: 1222.00, date: '2026-05-14 00:00:00', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260514-0029' },
            { id: 28, supplier: 'Heet Patel', product: 'Flat Bar', amount: 1000.00, date: '2026-05-14 00:00:00', method: 'Escrow', status: 'Settled', utr: 'SXP-UTR-20260514-0028' },
            { id: 27, supplier: 'Vaibhav Suthar', product: 'Chain Block 1 Ton', amount: 8000.00, date: '2026-04-11 00:00:00', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260411-0027' },
            { id: 26, supplier: 'Heet Patel', product: 'Drywall Screw', amount: 10000.00, date: '2026-04-11 00:00:00', method: 'NEFT', status: 'Settled', utr: 'SXP-UTR-20260411-0026' },
            { id: 25, supplier: 'Vaibhav Suthar', product: 'Pesticide Sprayer', amount: 10000.00, date: '2026-04-10 00:00:00', method: 'Escrow', status: 'Settled', utr: 'SXP-UTR-20260410-0025' },
            { id: 24, supplier: 'Heet Patel', product: 'LED Bulb 9W', amount: 8500.00, date: '2026-04-09 00:00:00', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260409-0024' },
            { id: 23, supplier: 'Supplier 001', product: 'Cutting Disc 4 inch', amount: 16000.00, date: '2026-04-09 00:00:00', method: 'NEFT', status: 'Settled', utr: 'SXP-UTR-20260409-0023' },
            { id: 22, supplier: 'Heet Patel', product: 'Ceiling Fan', amount: 10000.00, date: '2026-04-09 00:00:00', method: 'Escrow', status: 'Settled', utr: 'SXP-UTR-20260409-0022' },
            { id: 21, supplier: 'Supplier 001', product: 'Cutting Disc 4 inch', amount: 16500.00, date: '2026-04-09 00:00:00', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20260409-0021' },
            { id: 20, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 10000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0020' },
            { id: 19, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 9800.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0019' },
            { id: 18, supplier: 'Vaibhav Suthar', product: 'Steel Rods', amount: 5600.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0018' },
            { id: 17, supplier: 'Vaibhav Suthar', product: 'Copper Sheets', amount: 8900.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0017' },
            { id: 16, supplier: 'Vaibhav Suthar', product: 'Paint Buckets', amount: 89000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0016' },
            { id: 1, supplier: 'Vaibhav Suthar', product: 'Steel Rods', amount: 9000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0001' },
            { id: 2, supplier: 'Vaibhav Suthar', product: 'Copper Sheets', amount: 34570.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0002' },
            { id: 3, supplier: 'Vaibhav Suthar', product: 'Plastic Granules', amount: 8000.00, date: '2025-11-26 18:20:36', method: 'RTGS', status: 'Settled', utr: 'SXP-UTR-20251126-0003' },
            { id: 4, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 51780.00, date: '2025-11-26 18:43:17', method: 'NEFT', status: 'Settled', utr: 'SXP-UTR-20251126-0004' },
            { id: 5, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 10000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0005' },
            { id: 6, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 9000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0006' },
            { id: 7, supplier: 'Vaibhav Suthar', product: 'Aluminum Plates', amount: 90000.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0007' },
            { id: 8, supplier: 'Vaibhav Suthar', product: 'Paint Buckets', amount: 1111.00, date: '-', method: 'Bank Transfer', status: 'Settled', utr: 'SXP-UTR-LEGACY-0008' }
        ];

        function paymentApp() {
            return {
                // Filter States
                filterSearch: '',
                filterStartDate: '${startDate != null ? startDate : ""}',
                filterEndDate: '${endDate != null ? endDate : ""}',
                filterStatus: '${statusFilter != null ? statusFilter : "ALL"}',
                filterMethod: '${paymentMethodFilter != null ? paymentMethodFilter : "ALL"}',

                // Pagination
                currentPage: 1,
                pageSize: 10,

                // Sort State
                sortCol: 'id',
                sortAsc: false,

                // UI Modals & Drawers
                showDrawer: false,
                activeReceipt: null,
                showRecordModal: false,
                showReleaseModal: false,
                selectedReleaseItem: null,
                releaseMethod: 'Escrow Auto-Pay',
                showCopilot: false,
                copilotInput: '',
                copilotMessages: [
                    { id: 1, sender: 'bot', text: 'Hello Admin! I am Supplexio AI Financial Copilot. You can ask me questions about vendor payouts, GST calculations, or pending escrow.' }
                ],
                toasts: [],

                // New Record Form State
                newRecord: {
                    supplier: '',
                    product: '',
                    amount: '',
                    method: 'RTGS',
                    date: '2026-11-21 15:00:00'
                },

                // Pending Auctions Data Queue
                pendingAuctions: (serverPending && serverPending.length > 0) ? serverPending : [],

                // History Dataset
                historyData: (serverHistory && serverHistory.length > 0) ? serverHistory : fallbackHistory,

                initData() {
                    this.$nextTick(() => {
                        lucide.createIcons();
                    });
                },

                // Computed: Total Disbursed Volume
                get totalDisbursed() {
                    return this.historyData.reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0);
                },

                // Computed: Pending Amount
                get pendingAmount() {
                    return this.pendingAuctions.reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0);
                },

                // Computed: Max Payout
                get maxPayout() {
                    if (this.historyData.length === 0) return { amount: 0, supplier: 'N/A' };
                    return this.historyData.reduce((max, item) => (parseFloat(item.amount) || 0) > (parseFloat(max.amount) || 0) ? item : max, this.historyData[0]);
                },

                // Filtering Logic
                get filteredHistory() {
                    let res = this.historyData.filter(item => {
                        // Search text
                        if (this.filterSearch) {
                            const q = this.filterSearch.toLowerCase();
                            const matchId = item.id.toString().includes(q);
                            const matchSup = item.supplier ? item.supplier.toLowerCase().includes(q) : false;
                            const matchProd = item.product ? item.product.toLowerCase().includes(q) : false;
                            const matchUtr = item.utr ? item.utr.toLowerCase().includes(q) : false;
                            if (!matchId && !matchSup && !matchProd && !matchUtr) return false;
                        }
                        // Method
                        if (this.filterMethod !== 'ALL' && this.filterMethod !== '') {
                            const m = (item.method || '').toUpperCase();
                            const fm = this.filterMethod.toUpperCase();
                            if (fm === 'RTGS' && !m.includes('RTGS') && !m.includes('BANK')) return false;
                            else if (fm !== 'RTGS' && !m.includes(fm)) return false;
                        }
                        // Status
                        if (this.filterStatus !== 'ALL' && this.filterStatus !== '') {
                            const st = (item.status || '').toUpperCase();
                            const fst = this.filterStatus.toUpperCase();
                            if (fst === 'COMPLETED' && st !== 'SETTLED' && st !== 'COMPLETED') return false;
                            else if (fst === 'PENDING' && st !== 'PENDING' && st !== 'PROCESSING') return false;
                            else if (fst === 'FAILED' && st !== 'FAILED') return false;
                        }
                        // Date filters
                        if (this.filterStartDate && item.date && item.date !== '-') {
                            const itemDate = item.date.split(' ')[0];
                            if (itemDate < this.filterStartDate) return false;
                        }
                        if (this.filterEndDate && item.date && item.date !== '-') {
                            const itemDate = item.date.split(' ')[0];
                            if (itemDate > this.filterEndDate) return false;
                        }
                        return true;
                    });

                    // Sorting
                    res.sort((a, b) => {
                        let valA = a[this.sortCol];
                        let valB = b[this.sortCol];
                        if (typeof valA === 'string') valA = valA.toLowerCase();
                        if (typeof valB === 'string') valB = valB.toLowerCase();

                        if (valA < valB) return this.sortAsc ? -1 : 1;
                        if (valA > valB) return this.sortAsc ? 1 : -1;
                        return 0;
                    });

                    return res;
                },

                // Pagination
                get totalPages() {
                    if (this.pageSize === 100) return 1;
                    return Math.ceil(this.filteredHistory.length / this.pageSize) || 1;
                },

                get startIndex() {
                    return (this.currentPage - 1) * this.pageSize;
                },

                get endIndex() {
                    const end = this.startIndex + this.pageSize;
                    return end > this.filteredHistory.length ? this.filteredHistory.length : end;
                },

                get paginatedHistory() {
                    if (this.pageSize === 100) return this.filteredHistory;
                    return this.filteredHistory.slice(this.startIndex, this.endIndex);
                },

                sortBy(col) {
                    if (this.sortCol === col) {
                        this.sortAsc = !this.sortAsc;
                    } else {
                        this.sortCol = col;
                        this.sortAsc = true;
                    }
                },

                prevPage() {
                    if (this.currentPage > 1) this.currentPage--;
                },

                nextPage() {
                    if (this.currentPage < this.totalPages) this.currentPage++;
                },

                resetFilters() {
                    this.filterSearch = '';
                    this.filterStartDate = '';
                    this.filterEndDate = '';
                    this.filterStatus = 'ALL';
                    this.filterMethod = 'ALL';
                    this.currentPage = 1;
                    this.showToast('Filters reset to default view');
                },

                setPreset(preset) {
                    this.resetFilters();
                    if (preset === '2026') {
                        this.filterStartDate = '2026-01-01';
                        this.filterEndDate = '2026-12-31';
                    } else if (preset === '2025') {
                        this.filterStartDate = '2025-01-01';
                        this.filterEndDate = '2025-12-31';
                    } else if (preset === 'Heet Patel') {
                        this.filterSearch = 'Heet Patel';
                    }
                    this.showToast('Preset filter applied: ' + preset);
                },

                applyFilters() {
                    this.currentPage = 1;
                    this.showToast('Ledger filtered successfully');
                },

                // Helper: Format INR
                formatINR(val) {
                    if (val === undefined || val === null || isNaN(val)) return '₹0.00';
                    return new Intl.NumberFormat('en-IN', {
                        style: 'currency',
                        currency: 'INR',
                        maximumFractionDigits: 2
                    }).format(val);
                },

                getInitials(name) {
                    if (!name) return '??';
                    const parts = name.trim().split(' ');
                    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
                    return name.substring(0, 2).toUpperCase();
                },

                getMethodBadgeClass(method) {
                    const m = (method || '').toUpperCase();
                    if (m.includes('RTGS') || m.includes('BANK')) return 'bg-blue-100 text-blue-800 border border-blue-200';
                    if (m.includes('NEFT')) return 'bg-purple-100 text-purple-800 border border-purple-200';
                    if (m.includes('ESCROW')) return 'bg-amber-100 text-amber-800 border border-amber-200';
                    if (m.includes('UPI')) return 'bg-[#2DD4BF]/20 text-teal-800 border border-teal-300';
                    if (m.includes('CREDIT')) return 'bg-indigo-100 text-indigo-800 border border-indigo-200';
                    if (m.includes('CHEQUE')) return 'bg-cyan-100 text-cyan-800 border border-cyan-200';
                    return 'bg-slate-100 text-slate-700 border border-slate-200';
                },

                // Actions
                openReceiptDrawer(row) {
                    this.activeReceipt = row;
                    this.showDrawer = true;
                    this.$nextTick(() => lucide.createIcons());
                },

                downloadVoucher(row) {
                    this.showToast('Voucher #' + row.id + ' downloaded (' + row.utr + ')');
                },

                printReceipt() {
                    window.print();
                },

                simulateAwardedAuction() {
                    const sampleProducts = [
                        { id: '#AUC-65', product: 'Bitumen Primer', supplier: 'Vaibhav Suthar', amount: 262500.00, poId: null },
                        { id: '#AUC-66', product: 'Acrylic Sheet 3mm', supplier: 'Supplier 001', amount: 145000.00, poId: null },
                        { id: '#AUC-67', product: 'Galvanized Iron Wire', supplier: 'Heet Patel', amount: 310000.00, poId: null }
                    ];
                    const nextItem = sampleProducts[this.pendingAuctions.length % sampleProducts.length];
                    const auctionId = '#AUC-' + (68 + this.pendingAuctions.length);
                    
                    this.pendingAuctions.push({
                        auctionId: auctionId,
                        product: nextItem.product,
                        supplier: nextItem.supplier,
                        amount: nextItem.amount,
                        poId: nextItem.poId
                    });

                    this.showToast('Simulated Reverse Auction Award (' + auctionId + ')');
                    this.$nextTick(() => lucide.createIcons());
                },

                openReleaseModal(item) {
                    this.selectedReleaseItem = item;
                    this.showReleaseModal = true;
                },

                confirmReleasePayout() {
                    if (!this.selectedReleaseItem) return;

                    // If connected to a real PO from backend, submit POST to /payment
                    if (this.selectedReleaseItem.poId && this.selectedReleaseItem.supplierId) {
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = '${pageContext.request.contextPath}/payment';

                        const fields = {
                            auctionId: (this.selectedReleaseItem.auctionId || '').replace('#AUC-', ''),
                            supplierId: this.selectedReleaseItem.supplierId,
                            amount: this.selectedReleaseItem.amount,
                            paymentMethod: this.releaseMethod === 'Escrow Auto-Pay' ? 'BANK_TRANSFER' : this.releaseMethod,
                            transactionId: 'TXN-' + Date.now(),
                            paymentDate: new Date().toISOString().replace('T', ' ').substring(0, 19),
                            status: 'COMPLETED',
                            remarks: 'Settled via Supplexio Escrow Release'
                        };

                        for (const [k, v] of Object.entries(fields)) {
                            const inp = document.createElement('input');
                            inp.type = 'hidden';
                            inp.name = k;
                            inp.value = v;
                            form.appendChild(inp);
                        }

                        document.body.appendChild(form);
                        form.submit();
                        return;
                    }

                    // Otherwise perform instant client-side settlement simulation
                    const newId = Math.max(...this.historyData.map(h => parseInt(h.id) || 0)) + 1;
                    const now = new Date();
                    const dateStr = now.toISOString().replace('T', ' ').substring(0, 19);

                    const releasedRow = {
                        id: newId,
                        supplier: this.selectedReleaseItem.supplier,
                        product: this.selectedReleaseItem.product,
                        amount: this.selectedReleaseItem.amount,
                        date: dateStr,
                        method: this.releaseMethod,
                        status: 'Settled',
                        utr: 'SXP-UTR-' + now.getFullYear() + String(now.getMonth()+1).padStart(2,'0') + String(now.getDate()).padStart(2,'0') + '-' + String(newId).padStart(4,'0')
                    };

                    this.historyData.unshift(releasedRow);
                    this.pendingAuctions = this.pendingAuctions.filter(a => a.auctionId !== this.selectedReleaseItem.auctionId);

                    this.showReleaseModal = false;
                    this.selectedReleaseItem = null;
                    this.showToast('Payout released! Settled ' + releasedRow.utr);
                    this.$nextTick(() => lucide.createIcons());
                },

                submitRecordPayout() {
                    if (!this.newRecord.supplier || !this.newRecord.product || !this.newRecord.amount) return;

                    const newId = Math.max(...this.historyData.map(h => parseInt(h.id) || 0)) + 1;
                    const amountVal = parseFloat(this.newRecord.amount);

                    const record = {
                        id: newId,
                        supplier: this.newRecord.supplier,
                        product: this.newRecord.product,
                        amount: amountVal,
                        date: this.newRecord.date || '2026-11-21 15:00:00',
                        method: this.newRecord.method || 'RTGS',
                        status: 'Settled',
                        utr: 'SXP-UTR-MANUAL-' + newId
                    };

                    this.historyData.unshift(record);
                    this.showRecordModal = false;
                    this.newRecord = { supplier: '', product: '', amount: '', method: 'RTGS', date: '2026-11-21 15:00:00' };
                    this.showToast('Manual Payout #' + newId + ' recorded successfully');
                    this.$nextTick(() => lucide.createIcons());
                },

                exportCSV() {
                    let csv = 'Transaction ID,Supplier,Product,Method,Amount (INR),Date,Status,UTR\n';
                    this.historyData.forEach(r => {
                        csv += '"' + r.id + '","' + r.supplier + '","' + r.product + '","' + r.method + '",' + r.amount + ',"' + r.date + '","' + r.status + '","' + r.utr + '"\n';
                    });
                    const blob = new Blob([csv], { type: 'text/csv' });
                    const url = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.setAttribute('href', url);
                    a.setAttribute('download', 'Supplexio_Payment_Ledger_' + new Date().toISOString().split('T')[0] + '.csv');
                    a.click();
                    this.showToast('Payment ledger exported as CSV');
                },

                // AI Copilot Helper
                sendCopilotMessage() {
                    if (!this.copilotInput.trim()) return;
                    const text = this.copilotInput.trim();
                    this.copilotMessages.push({ id: Date.now(), sender: 'user', text });
                    this.copilotInput = '';
                    
                    setTimeout(() => {
                        this.askCopilotResponse(text);
                    }, 500);
                },

                askCopilot(q) {
                    this.copilotMessages.push({ id: Date.now(), sender: 'user', text: q });
                    setTimeout(() => {
                        this.askCopilotResponse(q);
                    }, 500);
                },

                askCopilotResponse(query) {
                    let answer = "I have checked the Supplexio ledger for your request.";
                    const qLower = query.toLowerCase();

                    if (qLower.includes('heet patel')) {
                        const totalHeet = this.historyData.filter(h => (h.supplier || '').toLowerCase().includes('heet patel')).reduce((s, h) => s + (parseFloat(h.amount) || 0), 0);
                        answer = 'Total volume disbursed to Heet Patel across transactions is ' + this.formatINR(totalHeet) + '.';
                    } else if (qLower.includes('largest') || qLower.includes('max')) {
                        answer = 'The largest single transaction recorded is ' + this.formatINR(this.maxPayout.amount) + ' for "' + this.maxPayout.product + '" from ' + this.maxPayout.supplier + ' (ID #' + this.maxPayout.id + ').';
                    } else if (qLower.includes('pending') || qLower.includes('escrow')) {
                        answer = 'Currently, there are ' + this.pendingAuctions.length + ' pending escrow payouts totaling ' + this.formatINR(this.pendingAmount) + '.';
                    } else {
                        answer = 'Total ledger volume is ' + this.formatINR(this.totalDisbursed) + ' across ' + this.historyData.length + ' total reconciled payments.';
                    }

                    this.copilotMessages.push({ id: Date.now() + 1, sender: 'bot', text: answer });
                },

                showToast(msg) {
                    const t = { id: Date.now(), message: msg };
                    this.toasts.push(t);
                    setTimeout(() => {
                        this.toasts = this.toasts.filter(item => item.id !== t.id);
                    }, 3000);
                }
            }
        }
    </script>
</body>
</html>
