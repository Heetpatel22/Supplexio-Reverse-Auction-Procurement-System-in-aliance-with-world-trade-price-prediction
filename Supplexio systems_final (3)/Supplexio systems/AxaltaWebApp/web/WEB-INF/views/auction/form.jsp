<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${not empty auction}">Edit Auction #${auction.id}</c:when><c:otherwise>Create New Auction</c:otherwise></c:choose> - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        .form-page-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }
        .form-page-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #1a56db 100%);
            color: white;
            padding: 1.75rem 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.12);
        }
        .form-page-header h2 { font-weight: 700; margin: 0; font-size: 1.5rem; }
        .form-page-header p   { margin: 0.35rem 0 0; opacity: 0.82; font-size: 0.9rem; }
        .form-page-body { padding: 2rem; }

        .form-section-title {
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--muted-text);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border-color);
        }
        .form-group label {
            font-weight: 600;
            font-size: 0.875rem;
            color: var(--text-color);
            margin-bottom: 0.4rem;
        }
        .form-control, .custom-select {
            background-color: var(--input-bg);
            color: var(--input-text);
            border: 1.5px solid var(--input-border);
            border-radius: 8px;
            padding: 0.6rem 0.85rem;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-control:focus, .custom-select:focus {
            background-color: var(--input-bg);
            color: var(--input-text);
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 3px rgba(45, 212, 191, 0.18);
            outline: none;
        }
        .input-group-text {
            background-color: var(--table-header-bg);
            border-color: var(--input-border);
            color: var(--muted-text);
            border-radius: 8px 0 0 8px;
        }
        .datetime-hint {
            font-size: 0.78rem;
            color: var(--muted-text);
            margin-top: 0.3rem;
        }
        .btn-create {
            background: linear-gradient(135deg, var(--primary-color), #1a56db);
            border: none;
            color: white;
            padding: 0.7rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-create:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(30, 58, 138, 0.35);
            color: white;
        }
        .btn-back {
            background-color: transparent;
            border: 1.5px solid var(--border-color);
            color: var(--text-color);
            padding: 0.65rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 0.2s;
        }
        .btn-back:hover {
            background-color: var(--table-hover-bg);
            color: var(--text-color);
        }
        .product-opt-badge {
            display: inline-block;
            background-color: var(--accent-color);
            color: #fff;
            border-radius: 4px;
            font-size: 0.7rem;
            padding: 2px 7px;
            margin-left: 6px;
            vertical-align: middle;
        }
        .alert-themed {
            background-color: var(--table-hover-bg);
            border: 1px solid var(--border-color);
            color: var(--text-color);
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb" style="background:transparent; padding:0;">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home?action=workspace" style="color:var(--primary-color);">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction" style="color:var(--primary-color);">Reverse Auctions</a></li>
                <li class="breadcrumb-item active" style="color:var(--muted-text);">
                    <c:choose>
                        <c:when test="${not empty auction}">Edit Auction #${auction.id}</c:when>
                        <c:otherwise>Create New Auction</c:otherwise>
                    </c:choose>
                </li>
            </ol>
        </nav>

        <!-- Alert Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-exclamation-circle mr-2"></i>${error}
                <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
            </div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle mr-2"></i>${success}
                <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
            </div>
        </c:if>

        <div class="row justify-content-center">
            <div class="col-lg-8 col-xl-7">
                <div class="form-page-card">
                    <div class="form-page-header">
                        <h2>
                            <i class="fas fa-gavel mr-2"></i>
                            <c:choose>
                                <c:when test="${not empty auction}">Edit Auction #${auction.id}</c:when>
                                <c:otherwise>Create New Auction</c:otherwise>
                            </c:choose>
                        </h2>
                        <p>Fill in the details below to
                            <c:choose>
                                <c:when test="${not empty auction}">update this reverse auction.</c:when>
                                <c:otherwise>launch a new reverse auction and invite suppliers to bid.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>

                    <div class="form-page-body">
                        <form id="auctionForm"
                              action="${pageContext.request.contextPath}/auction"
                              method="post"
                              onsubmit="return prepareForm()">

                            <input type="hidden" name="action" value="${not empty auction ? 'update' : 'create'}">
                            <c:if test="${not empty auction}">
                                <input type="hidden" name="id" value="${auction.id}">
                            </c:if>

                            <!-- Section: Product & Volume Specification -->
                            <p class="form-section-title"><i class="fas fa-box mr-1"></i> Product & Volume Specification</p>

                            <!-- Live Search Across 5,384 BACI Commodities -->
                            <div class="form-group mb-2 position-relative">
                                <label class="d-flex justify-content-between align-items-center">
                                    <span>Product Selection <span class="text-danger">*</span></span>
                                    <span class="badge badge-info" style="font-size:0.75rem;"><i class="fas fa-globe mr-1"></i> 5,384 Global BACI Commodities Available</span>
                                </label>
                                <div class="input-group mb-2">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search text-primary"></i></span>
                                    </div>
                                    <input type="text" id="globalProductSearch" class="form-control" placeholder="Search by name or HSN code (e.g. 'Shower Head', 'Flush Door', 'Titanium', '441820', '848180')..." autocomplete="off">
                                </div>
                                <div id="searchResultsDropdown" class="list-group shadow-lg" style="display:none; position:absolute; z-index:1050; width:100%; max-height:280px; overflow-y:auto; top:100%; border:1px solid #cbd5e1;"></div>
                            </div>

                            <div class="form-group mb-3">
                                <label for="productId" class="text-muted small">Or Pick from Active Catalog:</label>
                                <select class="form-control custom-select" id="productId" name="productId" required>
                                    <option value="">— Select from Enterprise Catalog or Search Above —</option>
                                    <c:forEach var="product" items="${products}">
                                        <option value="${product.id}"
                                            <c:if test="${not empty auction and auction.productId == product.id}">selected</c:if>
                                            <c:if test="${empty auction and param.productId == product.id}">selected</c:if>>
                                            ${product.name}
                                            <c:if test="${product.needsAuction}"> ⚠ Low Stock</c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Accept Quantity & Starting Ceiling Price First -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="quantity" class="font-weight-bold text-dark">
                                            <i class="fas fa-cubes text-primary mr-1"></i> Required Quantity <span class="text-danger">*</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="quantity" name="quantity"
                                                   min="1" step="1" required
                                                   placeholder="e.g. 50"
                                                   value="${not empty auction ? auction.requiredQuantity : ''}">
                                            <div class="input-group-append">
                                                <span class="input-group-text font-weight-bold" id="quantityUnitLabel">units</span>
                                            </div>
                                        </div>
                                        <small class="form-text text-muted">Enter procurement volume to activate AI Oracle</small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label for="startingPrice" class="font-weight-bold text-dark mb-0">
                                                <i class="fas fa-tag text-success mr-1"></i> Starting Ceiling Price (₹) <span class="text-danger">*</span>
                                            </label>
                                            <div class="btn-group btn-group-sm" role="group" id="pricingModeToggle">
                                                <button type="button" class="btn btn-sm btn-primary active py-0 px-2 font-weight-bold" id="btnModeTotal" style="font-size:0.75rem;">Total Lot</button>
                                                <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" id="btnModeUnit" style="font-size:0.75rem;">Per Unit</button>
                                            </div>
                                        </div>
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text"><i class="fas fa-rupee-sign"></i></span>
                                            </div>
                                            <input type="number" class="form-control font-weight-bold" id="startingPrice" name="startingPrice"
                                                   step="0.01" min="0" required
                                                   placeholder="Auto-set for entire lot"
                                                   value="${not empty auction ? auction.startingPrice : ''}">
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-1 flex-wrap">
                                            <small class="form-text text-muted mb-0" id="startingPriceHint">Total procurement lot ceiling for entered quantity</small>
                                            <small class="font-weight-bold text-primary mb-0" id="unitPriceBreakdown"></small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Prompt banner when product is selected but quantity is missing -->
                            <div id="aiQuantityPromptBanner" class="alert alert-info py-2 px-3 mb-3" style="display:none; border-radius:8px; border-left:4px solid #0284c7; background:#e0f2fe;">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-info-circle fa-lg mr-2 text-primary"></i>
                                    <span class="small font-weight-bold text-dark">Enter Required Quantity above to generate real-time AI Market Benchmark, Contract Lot Totals &amp; Optimal Ceiling Pricing.</span>
                                </div>
                            </div>

                            <!-- AI Market Oracle & Predictive Pricing Widget (World Trade Intelligence Integration) -->
                            <div id="aiOracleCard" class="card mt-2 mb-4 shadow-sm" style="display:none; border: 1.5px solid #0284c7; background: linear-gradient(180deg, #f0f9ff 0%, #ffffff 100%); border-radius: 12px;">
                                <div class="card-header py-2 px-3 d-flex justify-content-between align-items-center" style="background:#0284c7; color:#fff; border-radius:10px 10px 0 0;">
                                    <span class="font-weight-bold"><i class="fas fa-brain mr-1"></i> AI Market Oracle (1D-ResNet &amp; BACI Lakehouse Engine)</span>
                                    <span id="aiOracleBadge" class="badge badge-warning">Predictive Pricing</span>
                                </div>
                                <div class="card-body p-3">
                                    <div class="row align-items-center">
                                        <div class="col-md-7">
                                            <div class="d-flex justify-content-between align-items-center p-2 mb-3" style="background:rgba(255,255,255,0.7); border:1px solid #e2e8f0; border-radius:10px;">
                                                <div style="flex:1; text-align:left; padding-right:8px; border-right:1px solid #cbd5e1;">
                                                    <small class="text-muted d-block font-weight-bold" style="font-size:0.75rem;">Benchmark Spot</small>
                                                    <div class="font-weight-bold text-dark" style="font-size:1.05rem; white-space:nowrap;" id="aiBenchmarkPrice">--</div>
                                                    <small class="text-primary font-weight-bold d-block mt-1" style="font-size:0.75rem; white-space:nowrap;" id="aiTotalBenchmark">Lot: --</small>
                                                </div>
                                                <div style="flex:1; text-align:center; padding:0 8px; border-right:1px solid #cbd5e1;">
                                                    <small class="text-muted d-block font-weight-bold" style="font-size:0.75rem;">30-Day Trend</small>
                                                    <div class="font-weight-bold" style="font-size:1.05rem; white-space:nowrap;" id="aiTrendVal">--</div>
                                                    <small class="text-muted font-weight-bold d-block mt-1" style="font-size:0.75rem; white-space:nowrap;" id="aiRiskLevel">Risk: --</small>
                                                </div>
                                                <div style="flex:1; text-align:right; padding-left:8px;">
                                                    <small class="text-muted d-block font-weight-bold" style="font-size:0.75rem;">Suggested Ceiling</small>
                                                    <div class="font-weight-bold text-primary" style="font-size:1.05rem; white-space:nowrap;" id="aiCeilingPrice">--</div>
                                                    <small class="text-success font-weight-bold d-block mt-1" style="font-size:0.75rem; white-space:nowrap;" id="aiTotalCeiling">Lot: --</small>
                                                </div>
                                            </div>
                                            <p id="aiRecommendationText" class="small text-muted mb-2 font-italic" style="line-height:1.4;"></p>
                                            <div class="d-flex align-items-center flex-wrap mt-2">
                                                <button type="button" class="btn btn-sm btn-primary font-weight-bold shadow-sm mr-2 mb-1" id="btnApplyTotalCeiling">
                                                    <i class="fas fa-boxes mr-1"></i> Apply Total Lot Ceiling (<span id="btnTotalCeilingSpan">--</span>)
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-secondary font-weight-bold mr-2 mb-1" id="btnApplyUnitCeiling">
                                                    <i class="fas fa-tag mr-1"></i> Per Unit (<span id="btnUnitCeilingSpan">--</span>)
                                                </button>
                                                <span class="badge badge-success p-1 px-2 mb-1" id="aiSavingsBadge" style="font-size:0.75rem;">
                                                    <i class="fas fa-piggy-bank mr-1"></i> Est. Savings: --
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-md-5">
                                            <small class="text-muted font-weight-bold d-block mb-1 text-center">Price Trajectory Sparkline (₹)</small>
                                            <div style="height: 110px;">
                                                <canvas id="aiOracleSparkline"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                    <hr class="my-2">
                                    <div class="d-flex align-items-center justify-content-between flex-wrap">
                                        <small class="text-muted font-weight-bold"><i class="fas fa-shield-alt text-success mr-1"></i> Recommended Supplier Clusters (PCA-KMeans):</small>
                                        <div id="aiSupplierBadges" class="d-flex flex-wrap mt-1"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Section: Schedule -->
                            <p class="form-section-title mt-3"><i class="fas fa-calendar-alt mr-1"></i> Auction Schedule (IST)</p>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="startDateInput">Start Date <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="startDateInput" name="startDate" required
                                               value="${not empty auction ? startDateStr : ''}">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="startTimeInput">Start Time <span class="text-danger">*</span></label>
                                        <input type="time" class="form-control" id="startTimeInput" name="startTime" required
                                               value="${not empty auction ? startTimeStr : ''}">
                                        <div class="datetime-hint"><i class="fas fa-info-circle mr-1"></i>All times are in IST (UTC+5:30)</div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="endDateInput">End Date <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="endDateInput" name="endDate" required
                                               value="${not empty auction ? endDateStr : ''}">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="endTimeInput">End Time <span class="text-danger">*</span></label>
                                        <input type="time" class="form-control" id="endTimeInput" name="endTime" required
                                               value="${not empty auction ? endTimeStr : ''}">
                                    </div>
                                </div>
                            </div>

                            <c:if test="${not empty auction}">
                                <div class="form-group">
                                    <label for="status">Status <span class="text-danger">*</span></label>
                                    <select class="form-control custom-select" id="status" name="status" required>
                                        <option value="ACTIVE"   ${auction.status == 'ACTIVE'    ? 'selected' : ''}>Active</option>
                                        <option value="COMPLETED"${auction.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                        <option value="CANCELLED"${auction.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                    </select>
                                </div>
                            </c:if>

                            <!-- Actions -->
                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3" style="border-top:1px solid var(--border-color);">
                                <a href="${pageContext.request.contextPath}/auction" class="btn btn-back">
                                    <i class="fas fa-arrow-left mr-2"></i>Back
                                </a>
                                <button type="submit" class="btn btn-create">
                                    <i class="fas ${not empty auction ? 'fa-save' : 'fa-gavel'} mr-2"></i>
                                    <c:choose>
                                        <c:when test="${not empty auction}">Save Changes</c:when>
                                        <c:otherwise>Create Auction</c:otherwise>
                                    </c:choose>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        (function () {
            // Pre-fill today's date and now + 10 minutes as default start
            var now = new Date();
            var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
            var toDateStr = function(d) {
                return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
            };
            var toTimeStr = function(d) {
                return pad(d.getHours()) + ':' + pad(d.getMinutes());
            };

            var startDate = document.getElementById('startDateInput');
            var startTime = document.getElementById('startTimeInput');
            var endDate   = document.getElementById('endDateInput');
            var endTime   = document.getElementById('endTimeInput');

            // Set default start = now (already in browser's local/IST if user is in IST)
            if (!startDate.value) startDate.value = toDateStr(now);
            if (!startTime.value) startTime.value = toTimeStr(now);

            // Set default end = 7 days later
            if (!endDate.value) {
                var later = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
                endDate.value = toDateStr(later);
            }
            if (!endTime.value) endTime.value = toTimeStr(now);

            // Set min date on start/end to today
            startDate.min = toDateStr(now);
            endDate.min   = toDateStr(now);

            // Keep end date >= start date
            startDate.addEventListener('change', function () {
                if (endDate.value < startDate.value) {
                    endDate.value = startDate.value;
                }
                endDate.min = startDate.value;
            });
        })();

        // Form validation before submit
        function prepareForm() {
            var sDate = document.getElementById('startDateInput').value;
            var sTime = document.getElementById('startTimeInput').value;
            var eDate = document.getElementById('endDateInput').value;
            var eTime = document.getElementById('endTimeInput').value;

            if (!sDate || !sTime || !eDate || !eTime) {
                alert('Please fill in all date and time fields.');
                return false;
            }

            var startDT = new Date(sDate + 'T' + sTime);
            var endDT   = new Date(eDate + 'T' + eTime);

            if (endDT <= startDT) {
                alert('End date/time must be after start date/time.');
                return false;
            }
            return true;
        }

        // ── AI Market Oracle Integration (World Trade Intelligence) ──
        var aiChart = null;
        var currentHsnCode = '';
        var currentProductName = '';
        var currentProductId = '';
        var oracleData = null;
        var pricingMode = 'TOTAL'; // default: 'TOTAL' lot ceiling

        function applyPriceMode(mode) {
            pricingMode = mode;
            if (!oracleData) return;
            var unit = oracleData.unit || 'pcs';
            var qty = parseFloat($('#quantity').val()) || oracleData.quantity || 1;

            if (mode === 'TOTAL') {
                $('#btnModeTotal').addClass('active btn-primary font-weight-bold').removeClass('btn-outline-primary');
                $('#btnModeUnit').removeClass('active btn-primary font-weight-bold').addClass('btn-outline-secondary');
                $('#startingPrice').val(oracleData.total_ceiling_inr);
                $('#startingPriceHint').text('Total lot ceiling for ' + qty + ' ' + unit);
                $('#unitPriceBreakdown').html('(₹' + Number(oracleData.suggested_ceiling_inr).toLocaleString() + ' / ' + unit + ' × ' + qty + ' ' + unit + ')');
            } else {
                $('#btnModeUnit').addClass('active btn-primary font-weight-bold').removeClass('btn-outline-secondary');
                $('#btnModeTotal').removeClass('active btn-primary font-weight-bold').addClass('btn-outline-primary');
                $('#startingPrice').val(oracleData.suggested_ceiling_inr);
                $('#startingPriceHint').text('Per-unit ceiling for reverse auction');
                $('#unitPriceBreakdown').html('(Total Lot: ₹' + Number(oracleData.total_ceiling_inr).toLocaleString() + ' for ' + qty + ' ' + unit + ')');
            }

            $('#startingPrice').css('border-color', '#10b981').css('background-color', '#ecfdf5');
            setTimeout(function() {
                $('#startingPrice').css('border-color', '').css('background-color', '');
            }, 1500);
        }

        function checkAndRunOracle() {
            var pId = $('#productId').val() || currentProductId;
            var pText = $('#productId').find('option:selected').text();
            var pName = (pText && pText.indexOf('—') === -1) ? pText.split('(')[0].trim() : (currentProductName || '');
            var qty = parseFloat($('#quantity').val()) || 0;

            if (!pId && !pName && !currentHsnCode) {
                $('#aiQuantityPromptBanner').slideUp();
                $('#aiOracleCard').slideUp();
                return;
            }

            if (qty <= 0) {
                // Product selected, but quantity is required before calculating results!
                $('#aiOracleCard').slideUp();
                $('#aiQuantityPromptBanner').slideDown();
                $('#quantity').css('border-color', '#0284c7').css('box-shadow', '0 0 0 3px rgba(2, 132, 199, 0.25)');
                return;
            }

            // Both product and quantity are available
            $('#quantity').css('border-color', '').css('box-shadow', '');
            $('#aiQuantityPromptBanner').slideUp();
            fetchAiOracle(pId, pName, currentHsnCode, qty);
        }

        function fetchAiOracle(productId, productName, hsnCode, quantity) {
            $('#aiOracleCard').slideDown();
            $('#aiRecommendationText').text('Consulting 1D-ResNet neural inference & BACI trade lakehouse for ' + (productName || 'selected commodity') + ' (' + quantity + ' units)...');

            var url = 'http://localhost:5000/api/procurement-oracle?';
            if (productId) url += 'product_id=' + encodeURIComponent(productId) + '&';
            if (productName) url += 'product_name=' + encodeURIComponent(productName) + '&';
            if (hsnCode) url += 'hsn=' + encodeURIComponent(hsnCode) + '&';
            url += 'quantity=' + encodeURIComponent(quantity);

            fetch(url)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.status === 'success') {
                        oracleData = data;
                        var unit = data.unit || 'pcs';
                        $('#quantityUnitLabel').text(unit);
                        $('#aiOracleBadge').text('Qty: ' + Number(data.quantity).toLocaleString() + ' ' + unit);

                        // Benchmark Unit & Total Lot
                        $('#aiBenchmarkPrice').html('₹' + Number(data.benchmark_price_inr).toLocaleString() + ' <small class="text-muted" style="font-size:0.75rem;">/' + unit + '</small>');
                        $('#aiTotalBenchmark').html('<i class="fas fa-boxes mr-1"></i>Lot: ₹' + Number(data.total_benchmark_inr).toLocaleString());

                        // Trend & Risk
                        var trendColor = data.trend === 'SURGE' ? 'text-danger' : (data.trend === 'DECLINE' ? 'text-success' : 'text-primary');
                        $('#aiTrendVal').attr('class', 'font-weight-bold mb-0 ' + trendColor).html(data.trend + ' (' + data.trend_pct + ')');
                        $('#aiRiskLevel').html('Risk: <span class="badge badge-light border">' + (data.risk_level || 'MODERATE') + '</span>');

                        // Suggested Opening Ceiling Unit & Total Lot
                        $('#aiCeilingPrice').html('₹' + Number(data.suggested_ceiling_inr).toLocaleString() + ' <small class="text-muted" style="font-size:0.75rem;">/' + unit + '</small>');
                        $('#aiTotalCeiling').html('<i class="fas fa-shield-alt mr-1"></i>Lot: ₹' + Number(data.total_ceiling_inr).toLocaleString());

                        // Button text & Savings
                        $('#btnTotalCeilingSpan').text('₹' + Number(data.total_ceiling_inr).toLocaleString());
                        $('#btnUnitCeilingSpan').text('₹' + Number(data.suggested_ceiling_inr).toLocaleString() + '/' + unit);
                        $('#aiSavingsBadge').html('<i class="fas fa-piggy-bank mr-1"></i>Est. Savings: ~₹' + Number(data.estimated_savings_inr).toLocaleString());

                        $('#aiRecommendationText').text(data.ai_recommendation);

                        // Automatically apply according to current mode (default: Total Lot)
                        applyPriceMode(pricingMode);

                        $('#btnApplyTotalCeiling').off('click').on('click', function() {
                            applyPriceMode('TOTAL');
                        });

                        $('#btnApplyUnitCeiling').off('click').on('click', function() {
                            applyPriceMode('UNIT');
                        });

                        // Render supplier cluster badges
                        var badgesHtml = '';
                        (data.recommended_suppliers || []).forEach(function(s) {
                            badgesHtml += '<span class="badge badge-light border mr-1 mb-1 p-1"><i class="fas fa-check-circle text-success mr-1"></i>' + s.country + ' (' + s.cluster + ')</span>';
                        });
                        $('#aiSupplierBadges').html(badgesHtml);

                        // Render Sparkline
                        var ctx = document.getElementById('aiOracleSparkline').getContext('2d');
                        if (aiChart) { aiChart.destroy(); }
                        aiChart = new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels: data.sparkline_months,
                                datasets: [{
                                    label: 'Forecast Price (₹)',
                                    data: data.sparkline_data,
                                    borderColor: data.trend === 'SURGE' ? '#ef4444' : '#0284c7',
                                    backgroundColor: data.trend === 'SURGE' ? 'rgba(239, 68, 68, 0.12)' : 'rgba(2, 132, 199, 0.12)',
                                    fill: true,
                                    tension: 0.35,
                                    borderWidth: 2,
                                    pointRadius: 3
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: { legend: { display: false } },
                                scales: {
                                    x: { grid: { display: false }, ticks: { font: { size: 9 } } },
                                    y: { grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { font: { size: 9 } } }
                                }
                            }
                        });
                    }
                })
                .catch(function(err) {
                    console.error('AI Oracle offline or error:', err);
                });
        }

        // Mode toggle buttons
        $('#btnModeTotal').off('click').on('click', function() {
            applyPriceMode('TOTAL');
        });
        $('#btnModeUnit').off('click').on('click', function() {
            applyPriceMode('UNIT');
        });

        // Dynamic helper on starting price manual input
        $('#startingPrice').on('input change keyup', function() {
            var val = parseFloat($(this).val()) || 0;
            var qty = parseFloat($('#quantity').val()) || (oracleData ? oracleData.quantity : 1);
            var unit = (oracleData && oracleData.unit) ? oracleData.unit : 'units';
            if (val > 0 && qty > 0) {
                if (pricingMode === 'TOTAL') {
                    var unitEq = (val / qty).toFixed(2);
                    $('#unitPriceBreakdown').html('(₹' + Number(unitEq).toLocaleString() + ' / ' + unit + ')');
                } else {
                    var totalEq = (val * qty).toFixed(2);
                    $('#unitPriceBreakdown').html('(Total: ₹' + Number(totalEq).toLocaleString() + ')');
                }
            } else {
                $('#unitPriceBreakdown').empty();
            }
        });

        // Listener for Quantity changes (live update with debounce)
        var qtyDebounceTimer = null;
        $('#quantity').on('input change keyup', function() {
            clearTimeout(qtyDebounceTimer);
            qtyDebounceTimer = setTimeout(checkAndRunOracle, 250);
        });

        // Dropdown selection change
        $('#productId').on('change', function() {
            var pId = $(this).val();
            var pText = $(this).find('option:selected').text();
            currentProductId = pId;
            currentProductName = pText ? pText.split('(')[0].trim() : '';
            currentHsnCode = '';
            checkAndRunOracle();
        });

        // Live product search across 5,384 BACI products + Axalta catalog
        var searchTimer = null;
        $('#globalProductSearch').on('input', function() {
            var q = $(this).val().trim();
            clearTimeout(searchTimer);
            if (q.length < 2) {
                $('#searchResultsDropdown').hide().empty();
                return;
            }
            searchTimer = setTimeout(function() {
                fetch('http://localhost:5000/api/search-products?q=' + encodeURIComponent(q))
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        var $drop = $('#searchResultsDropdown');
                        $drop.empty();
                        if (data.products && data.products.length > 0) {
                            data.products.forEach(function(item) {
                                var badgeClass = item.catalog_type === 'Enterprise Catalog' ? 'badge-primary' : 'badge-secondary';
                                var priceStr = Number(item.base_price).toLocaleString();
                                var html = '<a href="#" class="list-group-item list-group-item-action py-2 px-3 search-result-item" data-id="' + item.id + '" data-name="' + item.name + '" data-hsn="' + item.hsn_code + '" data-price="' + item.base_price + '" data-unit="' + item.unit + '">';
                                html += '<div class="d-flex justify-content-between align-items-center">';
                                html += '  <strong class="text-dark">' + item.name + '</strong>';
                                html += '  <span class="badge ' + badgeClass + '">' + item.catalog_type + '</span>';
                                html += '</div>';
                                html += '<small class="text-muted">HSN ' + item.hsn_code + ' | ' + (item.category || '') + ' | Est: ₹' + priceStr + '/' + item.unit + '</small>';
                                html += '</a>';
                                $drop.append(html);
                            });
                            $drop.show();
                        } else {
                            $drop.html('<div class="list-group-item py-2 text-muted small">No commodities found matching "' + q + '"</div>').show();
                        }
                    });
            }, 250);
        });

        $(document).on('click', '.search-result-item', function(e) {
            e.preventDefault();
            var pId = $(this).data('id');
            var pName = $(this).data('name');
            var pHsn = $(this).data('hsn');
            var pUnit = $(this).data('unit');

            currentProductId = pId;
            currentProductName = pName;
            currentHsnCode = pHsn;

            if (pUnit) {
                $('#quantityUnitLabel').text(pUnit);
            }

            // If option exists in dropdown, select it; else add it as dynamic option
            var $opt = $('#productId option[value="' + pId + '"]');
            if ($opt.length === 0) {
                $('#productId').append('<option value="' + pId + '" selected>' + pName + ' (HSN ' + pHsn + ')</option>');
            } else {
                $('#productId').val(pId);
            }

            $('#globalProductSearch').val(pName + ' (HSN ' + pHsn + ')');
            $('#searchResultsDropdown').hide();

            checkAndRunOracle();
            if (!($('#quantity').val() > 0)) {
                $('#quantity').focus();
            }
        });

        // Close search dropdown on click outside
        $(document).on('click', function(e) {
            if (!$(e.target).closest('#globalProductSearch, #searchResultsDropdown').length) {
                $('#searchResultsDropdown').hide();
            }
        });

        $(document).ready(function() {
            if ($('#productId').val()) {
                checkAndRunOracle();
            }
        });
    </script>
</body>
</html>
