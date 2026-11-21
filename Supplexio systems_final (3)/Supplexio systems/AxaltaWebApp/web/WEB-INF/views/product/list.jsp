<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - Supplexio</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/animate.css@4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product.css">
    
    <style>
        .product-description-cell {
            max-width: 320px;
            font-size: 0.86rem;
            line-height: 1.45;
            color: #334155;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        [data-theme="dark"] .product-description-cell {
            color: #cbd5e1;
        }
        .quick-chip {
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 0.78rem;
            padding: 4px 10px;
            border-radius: 20px;
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
            display: inline-block;
            margin: 2px 4px 2px 0;
            font-weight: 500;
        }
        .quick-chip:hover {
            background: #0284c7;
            color: #ffffff;
            border-color: #0284c7;
            transform: translateY(-1px);
        }
        [data-theme="dark"] .quick-chip {
            background: #1e293b;
            color: #94a3b8;
            border-color: #334155;
        }
        [data-theme="dark"] .quick-chip:hover {
            background: #38bdf8;
            color: #0f172a;
            border-color: #38bdf8;
        }
        .dataTables_processing {
            background: rgba(255, 255, 255, 0.9) !important;
            border: 1px solid #0284c7 !important;
            border-radius: 8px !important;
            color: #0284c7 !important;
            font-weight: 700 !important;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important;
            z-index: 1050 !important;
            padding: 12px 24px !important;
        }
        [data-theme="dark"] .dataTables_processing {
            background: rgba(15, 23, 42, 0.95) !important;
            border-color: #38bdf8 !important;
            color: #38bdf8 !important;
        }
        .badge-trend-surge {
            background-color: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            font-weight: 600;
        }
        .badge-trend-dip {
            background-color: #e0f2fe;
            color: #0369a1;
            border: 1px solid #7dd3fc;
            font-weight: 600;
        }
        .badge-trend-stable {
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
            font-weight: 600;
        }
        [data-theme="dark"] .badge-trend-surge {
            background-color: rgba(239, 68, 68, 0.2);
            color: #f87171;
            border-color: rgba(239, 68, 68, 0.4);
        }
        [data-theme="dark"] .badge-trend-dip {
            background-color: rgba(56, 189, 248, 0.2);
            color: #38bdf8;
            border-color: rgba(56, 189, 248, 0.4);
        }
        [data-theme="dark"] .badge-trend-stable {
            background-color: rgba(148, 163, 184, 0.15);
            color: #94a3b8;
            border-color: rgba(148, 163, 184, 0.3);
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Page header -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="page-header-card animate__animated animate__fadeIn">
                        <div class="d-flex justify-content-between align-items-center flex-wrap">
                            <div class="mb-2 mb-md-0">
                                <h1 class="page-title">
                                    <i class="fas fa-boxes text-primary mr-2"></i>Product Management
                                </h1>
                                <p class="text-muted mb-0">
                                    Master Global Commodity Catalog & 1D-ResNet Neural Forecasting Engine (UN Comtrade / BACI HS-6)
                                </p>
                            </div>
                            <!-- Real-time Lakehouse Indicator (Add Product button permanently removed to preserve forecast integrity) -->
                            <div class="d-flex align-items-center flex-wrap">
                                <span class="badge badge-primary px-3 py-2 mr-2 shadow-sm" style="font-size: 0.88rem; border-radius: 8px;">
                                    <i class="fas fa-satellite-dish mr-1"></i> BACI Lakehouse Connected
                                </span>
                                <span class="badge badge-dark px-3 py-2 shadow-sm" style="font-size: 0.88rem; border-radius: 8px; background: #0f172a; color: #38bdf8;">
                                    <i class="fas fa-layer-group text-warning mr-1"></i> 5,384 Commodities Active
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Search and filter section -->
            <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
                <div class="col-12">
                    <div class="card filter-card shadow-sm border-0">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-7">
                                    <label class="font-weight-bold text-muted small text-uppercase mb-1">
                                        <i class="fas fa-search text-primary mr-1"></i>Search All 5,384 Commodities
                                    </label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text bg-white border-right-0"><i class="fas fa-search text-muted"></i></span>
                                        </div>
                                        <input type="text" id="productSearch" class="form-control border-left-0" 
                                               placeholder="Search by commodity name, HSN code (e.g. 320611, 721420), chapter, or description...">
                                        <div class="input-group-append" id="clearSearchBtnContainer" style="display: none;">
                                            <button class="btn btn-outline-secondary" type="button" id="clearSearchBtn">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-5 mt-3 mt-md-0">
                                    <label class="font-weight-bold text-muted small text-uppercase mb-1">
                                        <i class="fas fa-filter text-primary mr-1"></i>Filter by Trade Category / Chapter
                                    </label>
                                    <select id="categoryFilter" class="form-control custom-select">
                                        <option value="">All Categories (97 Global Trade Chapters)</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat}">${cat}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            
                            <!-- Quick Search Suggestion Chips -->
                            <div class="mt-3 pt-2 border-top">
                                <span class="small font-weight-bold text-muted mr-2">
                                    <i class="fas fa-bolt text-warning mr-1"></i>Popular Commodities:
                                </span>
                                <span class="quick-chip" data-query="Titanium Dioxide">Titanium Dioxide (320611)</span>
                                <span class="quick-chip" data-query="Steel Rods">Steel Rods (721420)</span>
                                <span class="quick-chip" data-query="Copper Cathode">Copper Cathode (740311)</span>
                                <span class="quick-chip" data-query="Laptop">Commercial Laptops (847130)</span>
                                <span class="quick-chip" data-query="Polyethylene">Polymers & Plastics (390110)</span>
                                <span class="quick-chip" data-query="Bitumen">Bitumen & Primers (271500)</span>
                                <span class="quick-chip" data-query="Aluminum">Aluminum Ingots (760110)</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Products table card -->
            <div class="row animate__animated animate__fadeIn animate__delay-2s">
                <div class="col-12">
                    <div class="card product-table-card shadow-sm border-0">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                            <div>
                                <h5 class="mb-0 font-weight-bold text-dark">
                                    <i class="fas fa-table text-primary mr-2"></i>Global Commodity Catalog
                                </h5>
                                <small class="text-muted">Directly mapped to 1D-ResNet AI Spot Arbitrage & Reverse Auction Engine</small>
                            </div>
                            <span id="tableCountBadge" class="badge badge-primary badge-pill px-3 py-2 font-weight-bold" style="font-size: 0.88rem;">
                                Loading 5,384 Commodities...
                            </span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table id="productsTable" class="table table-hover table-striped mb-0 w-100">
                                    <thead class="thead-light">
                                        <tr>
                                            <th style="width: 100px;">HSN / ID</th>
                                            <th style="min-width: 200px;">Commodity Name</th>
                                            <th style="min-width: 280px;">Official Description</th>
                                            <th style="min-width: 130px;">Benchmark Spot</th>
                                            <th style="width: 80px;">Unit</th>
                                            <th style="min-width: 140px;">1D-ResNet Trend</th>
                                            <th style="width: 80px;">Status</th>
                                            <th style="min-width: 130px;" class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Rendered asynchronously via DataTables Server-Side Processing -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- JavaScript Dependencies -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
    
    <script>
        function escapeHtml(str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        $(document).ready(function() {
            var contextPath = '${pageContext.request.contextPath}';
            
            // Initialize DataTables with Server-Side Processing
            var table = $('#productsTable').DataTable({
                "processing": true,
                "serverSide": true,
                "ajax": {
                    "url": contextPath + "/product?action=ajaxData",
                    "type": "GET",
                    "data": function(d) {
                        d.category = $('#categoryFilter').val();
                    },
                    "error": function(xhr, error, code) {
                        console.error('DataTables AJAX error:', error, code);
                    }
                },
                "columns": [
                    {
                        "data": "id",
                        "render": function(data, type, row) {
                            var hsn = row.hsnCode ? row.hsnCode : 'N/A';
                            return '<div class="font-weight-bold text-dark">#' + data + '</div>' +
                                   '<span class="badge badge-secondary font-weight-bold" style="letter-spacing: 0.5px;">' + escapeHtml(hsn) + '</span>';
                        }
                    },
                    {
                        "data": "name",
                        "render": function(data, type, row) {
                            var cat = row.chapterName ? '<div class="mt-1"><span class="badge badge-light border text-muted" style="font-size: 0.75rem;"><i class="fas fa-tag text-primary mr-1"></i>' + escapeHtml(row.chapterName) + '</span></div>' : '';
                            return '<div class="d-flex align-items-start">' +
                                   '<div class="product-color-dot mr-2 mt-1" style="background-color: var(--supplexio-primary, #0284c7);"></div>' +
                                   '<div><strong class="text-dark" style="font-size: 0.95rem;">' + escapeHtml(data) + '</strong>' + cat + '</div>' +
                                   '</div>';
                        }
                    },
                    {
                        "data": "description",
                        "render": function(data, type, row) {
                            var desc = data || row.name || '';
                            return '<div class="product-description-cell" title="' + escapeHtml(desc) + '">' +
                                   escapeHtml(desc) +
                                   '</div>';
                        }
                    },
                    {
                        "data": "benchmarkPriceInr",
                        "render": function(data, type, row) {
                            var price = parseFloat(data) || 0;
                            var formatted = price.toLocaleString('en-IN', { maximumFractionDigits: 2, minimumFractionDigits: 0 });
                            return '<div class="font-weight-bold text-dark" style="font-size: 0.95rem;">₹' + formatted + '</div>' +
                                   '<div class="small text-muted">spot / ' + escapeHtml(row.unit || 'pcs') + '</div>';
                        }
                    },
                    {
                        "data": "unit",
                        "render": function(data, type, row) {
                            return '<span class="badge badge-info px-2 py-1 font-weight-bold">' + escapeHtml(data || 'pcs') + '</span>';
                        }
                    },
                    {
                        "data": "trend",
                        "render": function(data, type, row) {
                            var trend = (data || 'STABLE').toUpperCase();
                            var pctVal = parseFloat(row.trendPct) || 0;
                            var pctStr = (pctVal > 0 ? '+' : '') + pctVal.toFixed(1) + '%';
                            
                            if (trend === 'SURGE') {
                                return '<span class="badge badge-trend-surge px-2 py-1"><i class="fas fa-arrow-up mr-1"></i>SURGE ' + pctStr + '</span>';
                            } else if (trend === 'DIP') {
                                return '<span class="badge badge-trend-dip px-2 py-1"><i class="fas fa-arrow-down mr-1"></i>DIP ' + pctStr + '</span>';
                            } else {
                                return '<span class="badge badge-trend-stable px-2 py-1"><i class="fas fa-equals mr-1 text-success"></i>STABLE ' + pctStr + '</span>';
                            }
                        }
                    },
                    {
                        "data": "status",
                        "orderable": false,
                        "render": function(data, type, row) {
                            return '<span class="badge badge-success px-2 py-1"><i class="fas fa-check-circle mr-1"></i>Active</span>';
                        }
                    },
                    {
                        "data": null,
                        "orderable": false,
                        "className": "text-center",
                        "render": function(data, type, row) {
                            var auctionUrl = contextPath + '/auction?action=new&commodity=' + encodeURIComponent(row.name) + '&hsn=' + encodeURIComponent(row.hsnCode || '');
                            return '<div class="btn-group" role="group">' +
                                   '<a href="' + auctionUrl + '" class="btn btn-sm btn-primary shadow-sm" data-toggle="tooltip" title="Launch Reverse Auction for ' + escapeHtml(row.name) + '">' +
                                   '<i class="fas fa-gavel mr-1"></i> Source' +
                                   '</a>' +
                                   '</div>';
                        }
                    }
                ],
                "paging": true,
                "ordering": true,
                "order": [[0, "asc"]],
                "info": true,
                "searching": true,
                "lengthChange": true,
                "pageLength": 10,
                "lengthMenu": [[10, 25, 50, 100], ["10 rows", "25 rows", "50 rows", "100 rows"]],
                "language": {
                    "search": "",
                    "searchPlaceholder": "Search 5,384 commodities...",
                    "lengthMenu": "_MENU_",
                    "info": "Showing _START_ to _END_ of _TOTAL_ commodities",
                    "infoEmpty": "Showing 0 to 0 of 0 commodities",
                    "infoFiltered": "(filtered from _MAX_ total commodities)",
                    "processing": "<div class='spinner-border spinner-border-sm text-primary mr-2' role='status'></div> Querying Lakehouse Commodities...",
                    "paginate": {
                        "previous": "<i class='fas fa-chevron-left'></i>",
                        "next": "<i class='fas fa-chevron-right'></i>"
                    }
                },
                "dom": "<'table-responsive't>" +
                       "<'d-flex flex-column flex-md-row justify-content-between align-items-center p-3 table-footer-controls'<'d-flex align-items-center mb-2 mb-md-0'<'mr-3'l>i>p>",
                "drawCallback": function(settings) {
                    $('[data-toggle="tooltip"]').tooltip();
                    
                    var api = this.api();
                    var pageInfo = api.page.info();
                    if (pageInfo.recordsTotal > 0) {
                        if (pageInfo.recordsFiltered < pageInfo.recordsTotal) {
                            $('#tableCountBadge').html('<i class="fas fa-filter mr-1"></i> ' + pageInfo.recordsFiltered.toLocaleString() + ' of ' + pageInfo.recordsTotal.toLocaleString() + ' Commodities');
                        } else {
                            $('#tableCountBadge').html('<i class="fas fa-check-circle mr-1"></i> ' + pageInfo.recordsTotal.toLocaleString() + ' Commodities');
                        }
                    }
                }
            });
            
            // Connect search input with 250ms debounce
            var searchDebounceTimer = null;
            $('#productSearch').on('input keyup', function() {
                var query = this.value;
                if (query && query.trim().length > 0) {
                    $('#clearSearchBtnContainer').show();
                } else {
                    $('#clearSearchBtnContainer').hide();
                }
                
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(function() {
                    table.search(query).draw();
                }, 250);
            });
            
            // Clear search button
            $('#clearSearchBtn').on('click', function() {
                $('#productSearch').val('');
                $('#clearSearchBtnContainer').hide();
                table.search('').draw();
            });
            
            // Connect category filter
            $('#categoryFilter').on('change', function() {
                table.ajax.reload();
            });
            
            // Connect quick chip suggestions
            $('.quick-chip').on('click', function() {
                var query = $(this).data('query');
                $('#productSearch').val(query);
                $('#clearSearchBtnContainer').show();
                table.search(query).draw();
            });
        });
    </script>
</body>
</html>
