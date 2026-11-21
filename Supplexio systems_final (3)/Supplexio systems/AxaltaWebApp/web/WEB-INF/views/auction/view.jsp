<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auction #${auction.id} - ${auction.productName} | Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction.css">
    <style>
        /* ── Detail page overrides ─────────────────────────────── */
        .detail-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            box-shadow: var(--card-shadow);
            margin-bottom: 1.5rem;
            overflow: hidden;
        }
        .detail-card-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #1a56db 100%);
            color: white;
            padding: 1rem 1.5rem;
            font-weight: 700;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .detail-card-header .btn-light {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            font-size: 0.8rem;
            border-radius: 6px;
        }
        .detail-card-header .btn-light:hover {
            background: rgba(255,255,255,0.25);
        }
        .detail-card-body {
            padding: 1.5rem;
            color: var(--text-color);
        }
        .detail-label {
            font-weight: 600;
            color: var(--muted-text);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .detail-value {
            color: var(--text-color);
            font-size: 1rem;
            font-weight: 500;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.6rem 0;
            border-bottom: 1px solid var(--border-color);
        }
        .detail-row:last-child { border-bottom: none; }

        /* Status pill */
        .status-pill {
            display: inline-block;
            padding: 0.3rem 0.85rem;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 600;
            letter-spacing: 0.02em;
        }
        .status-ACTIVE    { background: #d1fae5; color: #065f46; }
        .status-COMPLETED { background: #e0e7ff; color: #3730a3; }
        .status-CANCELLED { background: #fee2e2; color: #991b1b; }
        .status-SCHEDULED { background: #fef3c7; color: #92400e; }
        .status-SENT      { background: #fff3cd; color: #856404; }
        .status-PAID      { background: #cce5ff; color: #004085; }
        .status-DELIVERED { background: #d4edda; color: #155724; }

        [data-theme="dark"] .status-ACTIVE    { background: rgba(16,185,129,0.18); color: #6ee7b7; }
        [data-theme="dark"] .status-COMPLETED { background: rgba(99,102,241,0.18); color: #a5b4fc; }
        [data-theme="dark"] .status-CANCELLED { background: rgba(239,68,68,0.18);  color: #fca5a5; }
        [data-theme="dark"] .status-SCHEDULED { background: rgba(245,158,11,0.18); color: #fcd34d; }
        [data-theme="dark"] .status-SENT      { background: rgba(245,158,11,0.18); color: #fcd34d; }
        [data-theme="dark"] .status-PAID      { background: rgba(59,130,246,0.18); color: #93c5fd; }
        [data-theme="dark"] .status-DELIVERED { background: rgba(34,197,94,0.18);  color: #86efac; }

        /* Bids table */
        .bids-table { color: var(--text-color); }
        .bids-table thead th {
            background-color: var(--table-header-bg);
            color: var(--table-header-text);
            font-weight: 600;
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            border-bottom: 2px solid var(--border-color);
        }
        .bids-table tbody td {
            background-color: var(--table-cell-bg);
            color: var(--text-color);
            border-color: var(--table-cell-border);
            vertical-align: middle;
        }
        .lowest-bid td { background-color: rgba(16,185,129,0.08) !important; }
        [data-theme="dark"] .lowest-bid td { background-color: rgba(16,185,129,0.12) !important; }

        /* Supplier list */
        .list-group-item {
            background-color: var(--card-bg);
            color: var(--text-color);
            border-color: var(--border-color);
        }
        .list-group-item:hover {
            background-color: var(--table-hover-bg);
        }

        /* Chat panel */
        .auction-chat-panel {
            position: fixed;
            right: 24px;
            bottom: 24px;
            width: min(380px, calc(100vw - 32px));
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            box-shadow: 0 24px 60px rgba(0,0,0,0.28);
            overflow: hidden;
            z-index: 2000;
            display: none;
        }
        .auction-chat-header {
            background: linear-gradient(135deg, var(--primary-color), #1a56db);
            color: white;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .auction-chat-header small { display: block; color: rgba(255,255,255,0.76); }
        .chat-close {
            border: 0;
            background: rgba(255,255,255,0.18);
            color: white;
            border-radius: 50%;
            width: 30px;
            height: 30px;
        }
        .auction-chat-thread {
            height: 280px;
            overflow-y: auto;
            padding: 16px;
            background: var(--bg-color);
        }
        .auction-chat-bubble {
            max-width: 86%;
            padding: 11px 13px;
            margin-bottom: 10px;
            border-radius: 14px;
            background: var(--card-bg);
            border: 1px solid var(--border-color);
        }
        .auction-chat-bubble.mine {
            margin-left: auto;
            background: rgba(45,212,191,0.15);
        }
        .auction-chat-bubble small {
            display: block;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 4px;
            font-size: 0.78rem;
        }
        .auction-chat-bubble p { margin: 0; line-height: 1.45; color: var(--text-color); }
        .auction-chat-form {
            display: flex;
            gap: 10px;
            padding: 14px;
            border-top: 1px solid var(--border-color);
            background: var(--card-bg);
        }
        .auction-chat-form input {
            flex: 1;
            min-width: 0;
            border: 1.5px solid var(--input-border);
            background: var(--input-bg);
            color: var(--input-text);
            border-radius: 999px;
            padding: 10px 14px;
        }
        .auction-chat-form button {
            border: 0;
            border-radius: 50%;
            width: 42px;
            height: 42px;
            color: white;
            background: var(--primary-color);
            flex-shrink: 0;
        }
        .message-btn {
            position: relative;
            width: 38px;
            height: 34px;
            border: none;
            border-radius: 10px;
            color: white;
            background-color: var(--primary-color);
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .message-count {
            position: absolute;
            top: -8px; right: -8px;
            min-width: 20px; height: 20px;
            padding: 0 6px;
            border-radius: 999px;
            background: #dc3545;
            color: white;
            font-size: 0.72rem;
            font-weight: 700;
            line-height: 20px;
            display: none;
        }
        /* Breadcrumb */
        .breadcrumb { background: transparent; padding: 0; margin: 0; }
        .breadcrumb-item + .breadcrumb-item::before { color: var(--muted-text); }
        .breadcrumb-item a { color: var(--primary-color); }
        .breadcrumb-item.active { color: var(--muted-text); }
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
                <li class="breadcrumb-item active">Auction #${auction.id}</li>
            </ol>
        </nav>

        <!-- Alerts -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle mr-2"></i>${success}
                <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-exclamation-circle mr-2"></i>${error}
                <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
            </div>
        </c:if>

        <div class="row">
            <!-- Left column: details + bids -->
            <div class="col-lg-8">

                <!-- Auction Details Card -->
                <div class="detail-card">
                    <div class="detail-card-header">
                        <span><i class="fas fa-gavel mr-2"></i>Auction #${auction.id} — ${auction.productName}</span>
                        <div>
                            <a href="${pageContext.request.contextPath}/auction?action=edit&id=${auction.id}" class="btn btn-light btn-sm mr-1">
                                <i class="fas fa-edit mr-1"></i>Edit
                            </a>
                            <a href="${pageContext.request.contextPath}/auction?action=invite&id=${auction.id}" class="btn btn-light btn-sm">
                                <i class="fas fa-user-plus mr-1"></i>Invite
                            </a>
                        </div>
                    </div>
                    <div class="detail-card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="detail-row">
                                    <span class="detail-label">Product</span>
                                    <span class="detail-value">${auction.productName}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Quantity</span>
                                    <span class="detail-value">${auction.requiredQuantity} ${auction.unit}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Starting Price</span>
                                    <span class="detail-value"><fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Current Price</span>
                                    <span class="detail-value text-success font-weight-bold">
                                        <fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" />
                                    </span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="detail-row">
                                    <span class="detail-label">Status</span>
                                    <span class="status-pill status-${auction.status}">${auction.status}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Start Time</span>
                                    <span class="detail-value">
                                        <i class="far fa-calendar-alt mr-1 text-muted"></i>
                                        <fmt:formatDate value="${auction.startTime}" pattern="dd MMM yyyy, HH:mm" />
                                    </span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">End Time</span>
                                    <span class="detail-value">
                                        <i class="far fa-clock mr-1 text-muted"></i>
                                        <fmt:formatDate value="${auction.endTime}" pattern="dd MMM yyyy, HH:mm" />
                                    </span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Created</span>
                                    <span class="detail-value text-muted">
                                        <fmt:formatDate value="${auction.startTime}" pattern="dd MMM yyyy" />
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bids Card -->
                <div class="detail-card">
                    <div class="detail-card-header">
                        <span><i class="fas fa-hand-paper mr-2"></i>Bids</span>
                        <span class="badge badge-light" style="background:rgba(255,255,255,0.2);color:white;border-radius:999px;padding:4px 12px;">
                            ${fn:length(bids)} bids
                        </span>
                    </div>
                    <%-- fn taglib declared at top of page --%>
                    <div class="detail-card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover bids-table mb-0">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Supplier</th>
                                        <th>Bid Amount</th>
                                        <th>Bid Time</th>
                                        <th>Rank</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="bidInfo" items="${bids}" varStatus="status">
                                        <c:set var="bid" value="${bidInfo[0]}" />
                                        <c:set var="supplierName" value="${bidInfo[1]}" />
                                        <c:set var="supplierEmail" value="${bidInfo[2]}" />
                                        <tr class="${status.index == 0 ? 'lowest-bid' : ''}">
                                            <td><span class="badge badge-secondary">${status.index + 1}</span></td>
                                            <td>
                                                <div><strong>${supplierName}</strong></div>
                                                <small class="text-muted">${supplierEmail}</small>
                                            </td>
                                            <td>
                                                <strong class="${status.index == 0 ? 'text-success' : ''}">
                                                    &#8377;<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2" />
                                                </strong>
                                            </td>
                                            <td><small><fmt:formatDate value="${bid.bidTime}" pattern="dd MMM yyyy, HH:mm:ss" /></small></td>
                                            <td>
                                                <c:if test="${status.index == 0}">
                                                    <span class="badge badge-success mb-2 d-inline-block"><i class="fas fa-trophy mr-1"></i>Lowest</span>
                                                    <c:if test="${auction.status == 'ACTIVE' || auction.status == 'COMPLETED'}">
                                                        <c:choose>
                                                            <c:when test="${poAwarded && awardedSupplierId == bid.supplierId}">
                                                                <button type="button" class="btn btn-sm btn-secondary mt-1" disabled title="PO already awarded for this auction">
                                                                    <i class="fas fa-check-circle mr-1"></i>PO Awarded
                                                                </button>
                                                            </c:when>
                                                            <c:when test="${poAwarded}">
                                                                <button type="button" class="btn btn-sm btn-outline-secondary mt-1" disabled title="Another supplier was awarded">
                                                                    Award PO
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button type="button"
                                                                        class="btn btn-sm btn-primary mt-1 js-award-po-btn"
                                                                        data-auction-id="${auction.id}"
                                                                        data-supplier-id="${bid.supplierId}"
                                                                        data-supplier-name="${supplierName}">
                                                                    Award PO
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty bids}">
                                        <tr>
                                            <td colspan="5" class="text-center py-4">
                                                <i class="fas fa-inbox fa-2x text-muted mb-2 d-block"></i>
                                                <span class="text-muted">No bids placed yet. Invite suppliers to get started.</span>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Right column: photos + supplier messages -->
            <div class="col-lg-4">
                <jsp:include page="/WEB-INF/views/common/auction-photos.jsp" />

                <!-- Supplier Messages -->
                <div class="detail-card">
                    <div class="detail-card-header">
                        <span><i class="fas fa-comments mr-2"></i>Supplier Messages</span>
                        <a href="${pageContext.request.contextPath}/auction?action=invite&id=${auction.id}" class="btn btn-light btn-sm">
                            <i class="fas fa-cog mr-1"></i>Manage
                        </a>
                    </div>
                    <div class="detail-card-body p-0">
                        <ul class="list-group list-group-flush">
                            <c:forEach var="supplier" items="${auctionChatSuppliers}">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="font-weight-600">${supplier.name}</div>
                                        <small class="text-muted">${supplier.email}</small>
                                    </div>
                                    <button type="button"
                                            class="message-btn"
                                            data-supplier-id="${supplier.id}"
                                            data-supplier-name="${supplier.name}">
                                        <i class="fas fa-envelope"></i>
                                        <span class="message-count" data-count-for="${supplier.id}">0</span>
                                    </button>
                                </li>
                            </c:forEach>
                            <c:if test="${empty auctionChatSuppliers}">
                                <li class="list-group-item text-center py-4">
                                    <i class="fas fa-user-slash fa-2x text-muted mb-2 d-block"></i>
                                    <span class="text-muted">No supplier conversations yet</span>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Chat Panel -->
    <div class="auction-chat-panel" id="auctionChatPanel" aria-label="Auction supplier chat">
        <div class="auction-chat-header">
            <div>
                <strong id="chatSupplierName">Supplier Chat</strong>
                <small>Auction #${auction.id}</small>
            </div>
            <button type="button" class="chat-close" id="chatCloseBtn" aria-label="Close chat">&times;</button>
        </div>
        <div class="auction-chat-thread" id="auctionChatThread"></div>
        <form class="auction-chat-form" id="auctionChatForm">
            <input type="text" id="auctionChatInput" placeholder="Type message to supplier..." autocomplete="off">
            <button type="submit" aria-label="Send message"><i class="fas fa-paper-plane"></i></button>
        </form>
    </div>

    <form id="awardPoForm" action="${pageContext.request.contextPath}/auctions/award" method="post" class="d-none">
        <input type="hidden" name="auctionId" id="awardAuctionId" value="" />
        <input type="hidden" name="winningSupplierId" id="awardSupplierId" value="" />
    </form>

    <div class="modal fade" id="awardPoModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-trophy text-warning mr-2"></i>Award Purchase Order</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <div class="modal-body">
                    <p class="mb-2">Award PO to <strong id="awardPoSupplierName">this supplier</strong>?</p>
                    <p class="text-muted small mb-0">This creates a draft PO and starts the B2B procurement cycle.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="awardPoConfirmBtn"><i class="fas fa-check mr-1"></i>Confirm Award</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        const auctionId = '${auction.id}';
        let activeSupplierId = null;

        function setBadge(supplierId, count) {
            const badge = document.querySelector('[data-count-for="' + supplierId + '"]');
            if (!badge) return;
            badge.textContent = count;
            badge.style.display = count > 0 ? 'inline-block' : 'none';
        }

        function loadUnreadCounts() {
            fetch('${pageContext.request.contextPath}/auction-messages?mode=counts&auctionId=' + auctionId)
                .then(r => r.json())
                .then(counts => {
                    document.querySelectorAll('[data-count-for]').forEach(badge => {
                        const sid = badge.getAttribute('data-count-for');
                        setBadge(sid, counts[sid] || 0);
                    });
                });
        }

        function renderMessages(messages) {
            const thread = document.getElementById('auctionChatThread');
            thread.innerHTML = '';
            if (!messages.length) {
                thread.innerHTML = '<div class="text-muted text-center mt-5">No messages yet.</div>';
                return;
            }
            messages.forEach(item => {
                const bubble = document.createElement('div');
                bubble.className = 'auction-chat-bubble' + (item.senderType === 'BUYER' ? ' mine' : '');
                bubble.innerHTML = '<small></small><p></p>';
                bubble.querySelector('small').textContent = item.senderType === 'BUYER' ? 'You (Buyer)' : 'Supplier';
                bubble.querySelector('p').textContent = item.message;
                thread.appendChild(bubble);
            });
            thread.scrollTop = thread.scrollHeight;
        }

        function openChat(button) {
            activeSupplierId = button.getAttribute('data-supplier-id');
            document.getElementById('chatSupplierName').textContent = button.getAttribute('data-supplier-name');
            document.getElementById('auctionChatPanel').style.display = 'block';
            fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + auctionId + '&supplierId=' + activeSupplierId)
                .then(r => r.json())
                .then(data => {
                    renderMessages(data.messages || []);
                    setBadge(activeSupplierId, 0);
                });
        }

        document.querySelectorAll('.message-btn').forEach(btn => btn.addEventListener('click', () => openChat(btn)));
        document.getElementById('chatCloseBtn').addEventListener('click', () => {
            document.getElementById('auctionChatPanel').style.display = 'none';
        });

        document.getElementById('auctionChatForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const input = document.getElementById('auctionChatInput');
            const message = input.value.trim();
            if (!message || !activeSupplierId) return;
            const params = new URLSearchParams();
            params.append('action', 'send');
            params.append('auctionId', auctionId);
            params.append('supplierId', activeSupplierId);
            params.append('message', message);
            fetch('${pageContext.request.contextPath}/auction-messages', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(() => {
                input.value = '';
                return fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + auctionId + '&supplierId=' + activeSupplierId);
            }).then(r => r.json()).then(data => renderMessages(data.messages || []));
        });

        loadUnreadCounts();
        setInterval(loadUnreadCounts, 15000);

        document.querySelectorAll('.js-award-po-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.getElementById('awardPoSupplierName').textContent = btn.getAttribute('data-supplier-name') || 'this supplier';
                document.getElementById('awardAuctionId').value = btn.getAttribute('data-auction-id');
                document.getElementById('awardSupplierId').value = btn.getAttribute('data-supplier-id');
                $('#awardPoModal').modal('show');
            });
        });
        document.getElementById('awardPoConfirmBtn').addEventListener('click', function() {
            document.getElementById('awardPoForm').submit();
        });
    </script>
</body>
</html>
