<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invite Suppliers — Auction #${auction.id} | Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction.css">
    <style>
        .invite-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }
        .invite-card-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #1a56db 100%);
            color: white;
            padding: 1rem 1.5rem;
            font-weight: 700;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .invite-card-header .btn-header {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            font-size: 0.8rem;
            border-radius: 6px;
            padding: 0.3rem 0.8rem;
        }
        .invite-card-header .btn-header:hover { background: rgba(255,255,255,0.25); }
        .invite-card-body { padding: 1.5rem; }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.55rem 0;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-color);
        }
        .detail-row:last-child { border-bottom: none; }
        .detail-label {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--muted-text);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .detail-value { font-weight: 500; }

        .supplier-list-box {
            max-height: 420px;
            overflow-y: auto;
            border: 1.5px solid var(--input-border);
            border-radius: 10px;
            background-color: var(--input-bg);
            padding: 0.5rem;
        }
        .supplier-list-box::-webkit-scrollbar { width: 6px; }
        .supplier-list-box::-webkit-scrollbar-thumb { background: var(--border-color); border-radius: 3px; }

        .supplier-item {
            display: flex;
            align-items: center;
            padding: 0.65rem 0.85rem;
            border-radius: 8px;
            transition: background-color 0.18s;
            cursor: pointer;
            margin-bottom: 2px;
        }
        .supplier-item:hover { background-color: var(--table-hover-bg); }
        .supplier-item input[type="checkbox"] { width: 17px; height: 17px; flex-shrink: 0; margin-right: 0.85rem; accent-color: var(--primary-color); }
        .supplier-item label { margin: 0; cursor: pointer; flex: 1; }
        .supplier-name { font-weight: 600; color: var(--text-color); }
        .supplier-email { font-size: 0.82rem; color: var(--muted-text); }
        .supplier-badge {
            background: rgba(45,212,191,0.15);
            color: var(--secondary-color);
            font-size: 0.7rem;
            border-radius: 999px;
            padding: 2px 8px;
            font-weight: 600;
            flex-shrink: 0;
        }
        .already-invited .supplier-badge { display: inline-block; }

        .breadcrumb { background: transparent; padding: 0; }
        .breadcrumb-item + .breadcrumb-item::before { color: var(--muted-text); }
        .breadcrumb-item a { color: var(--primary-color); }
        .breadcrumb-item.active { color: var(--muted-text); }

        .btn-submit-invite {
            background: linear-gradient(135deg, var(--primary-color), #1a56db);
            border: none;
            color: white;
            padding: 0.65rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-submit-invite:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(30,58,138,0.35);
            color: white;
        }
        .btn-cancel-back {
            background: transparent;
            border: 1.5px solid var(--border-color);
            color: var(--text-color);
            padding: 0.6rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
        }
        .btn-cancel-back:hover { background: var(--table-hover-bg); color: var(--text-color); }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home?action=workspace">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction">Reverse Auctions</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}">Auction #${auction.id}</a></li>
                <li class="breadcrumb-item active">Invite Suppliers</li>
            </ol>
        </nav>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show mb-4">
                <i class="fas fa-exclamation-circle mr-2"></i>${error}
                <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
            </div>
        </c:if>

        <div class="row">
            <!-- Auction info column -->
            <div class="col-lg-4 mb-4">
                <div class="invite-card">
                    <div class="invite-card-header">
                        <span><i class="fas fa-gavel mr-2"></i>Auction Details</span>
                    </div>
                    <div class="invite-card-body">
                        <div class="detail-row">
                            <span class="detail-label">Product</span>
                            <span class="detail-value">${auction.productName}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Starting Price</span>
                            <span class="detail-value"><fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Current Price</span>
                            <span class="detail-value text-success font-weight-bold"><fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Start</span>
                            <span class="detail-value"><fmt:formatDate value="${auction.startTime}" pattern="dd MMM yyyy, HH:mm" /></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">End</span>
                            <span class="detail-value"><fmt:formatDate value="${auction.endTime}" pattern="dd MMM yyyy, HH:mm" /></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Status</span>
                            <span class="badge badge-pill badge-primary" style="background:var(--primary-color);">${auction.status}</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Invite form column -->
            <div class="col-lg-8">
                <div class="invite-card">
                    <div class="invite-card-header">
                        <span><i class="fas fa-user-plus mr-2"></i>Invite Suppliers to Auction #${auction.id}</span>
                        <div>
                            <button type="button" class="btn-header btn mr-1" id="selectAllBtn">
                                <i class="fas fa-check-square mr-1"></i>All
                            </button>
                            <button type="button" class="btn-header btn" id="deselectAllBtn">
                                <i class="fas fa-square mr-1"></i>None
                            </button>
                        </div>
                    </div>
                    <div class="invite-card-body">
                        <form method="post" action="${pageContext.request.contextPath}/auction">
                            <input type="hidden" name="action" value="invite">
                            <input type="hidden" name="id" value="${auction.id}">

                            <!-- Search box -->
                            <div class="form-group">
                                <div class="input-group mb-3">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="text" id="supplierSearch" class="form-control"
                                           placeholder="Search suppliers by name or email…">
                                </div>
                            </div>

                            <!-- Supplier list -->
                            <div class="supplier-list-box" id="supplierListBox">
                                <c:choose>
                                    <c:when test="${empty suppliers}">
                                        <div class="text-center py-5">
                                            <i class="fas fa-users-slash fa-2x text-muted mb-2 d-block"></i>
                                            <span class="text-muted">No active suppliers available</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <c:set var="isInvited" value="${invitedSupplierIds.contains(supplier.id)}" />
                                            <div class="supplier-item ${isInvited ? 'already-invited' : ''}" data-name="${supplier.name}" data-email="${supplier.email}">
                                                <input type="checkbox"
                                                       id="supplier${supplier.id}"
                                                       name="supplierIds"
                                                       value="${supplier.id}"
                                                       ${isInvited ? 'checked' : ''}>
                                                <label for="supplier${supplier.id}">
                                                    <div class="supplier-name">${supplier.name}</div>
                                                    <div class="supplier-email">${supplier.email}</div>
                                                </label>
                                                <c:if test="${isInvited}">
                                                    <span class="supplier-badge"><i class="fas fa-check mr-1"></i>Invited</span>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Count -->
                            <div class="mt-2 mb-3">
                                <small class="text-muted" id="selectedCount">0 supplier(s) selected</small>
                            </div>

                            <!-- Actions -->
                            <div class="d-flex justify-content-between align-items-center pt-3" style="border-top:1px solid var(--border-color);">
                                <a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}" class="btn btn-cancel-back">
                                    <i class="fas fa-arrow-left mr-2"></i>Back
                                </a>
                                <button type="submit" class="btn btn-submit-invite">
                                    <i class="fas fa-paper-plane mr-2"></i>Save Invitations
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
        function updateCount() {
            var count = document.querySelectorAll('.supplier-item input[type="checkbox"]:checked').length;
            document.getElementById('selectedCount').textContent = count + ' supplier(s) selected';
        }

        // Search filter
        document.getElementById('supplierSearch').addEventListener('input', function () {
            var val = this.value.toLowerCase();
            document.querySelectorAll('.supplier-item').forEach(function (item) {
                var name  = (item.getAttribute('data-name')  || '').toLowerCase();
                var email = (item.getAttribute('data-email') || '').toLowerCase();
                item.style.display = (name.includes(val) || email.includes(val)) ? '' : 'none';
            });
        });

        // Select/Deselect all (visible items)
        document.getElementById('selectAllBtn').addEventListener('click', function () {
            document.querySelectorAll('.supplier-item:not([style*="display: none"]) input[type="checkbox"]')
                    .forEach(function (cb) { cb.checked = true; });
            updateCount();
        });
        document.getElementById('deselectAllBtn').addEventListener('click', function () {
            document.querySelectorAll('.supplier-item:not([style*="display: none"]) input[type="checkbox"]')
                    .forEach(function (cb) { cb.checked = false; });
            updateCount();
        });

        // Live count update
        document.querySelectorAll('.supplier-item input[type="checkbox"]').forEach(function (cb) {
            cb.addEventListener('change', updateCount);
        });
        updateCount();
    </script>
</body>
</html>
