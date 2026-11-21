<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place Bid - Supplexio Marketplace</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    <style>
    /* Removed legacy body styles to use flex sidebar layout */

    .card {
        border: none;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin-bottom: 20px;
    }

    .card-header {
        background-color: rgb(0, 51, 153);
        color: white;
        font-weight: 600;
        border-radius: 10px 10px 0 0 !important;
    }

    .btn-primary {
        background-color: rgb(0, 51, 153);
        border-color: rgb(0, 51, 153);
    }

    .btn-primary:hover {
        background-color: #00307a;
        border-color: #00307a;
    }

    .btn-secondary {
        background-color: rgb(230, 230, 235);
        border-color: rgb(230, 230, 235);
        color: #333;
    }

    .btn-secondary:hover {
        background-color: #c8c8d0;
        border-color: #c8c8d0;
        color: #333;
    }

    .form-control:focus {
        border-color: rgb(0, 51, 153);
        box-shadow: 0 0 0 0.2rem rgba(0, 51, 153, 0.25);
    }

    .alert {
        border-radius: 10px;
    }

    .detail-label {
        font-weight: bold;
        color: #555;
    }

    .countdown {
        font-weight: bold;
        color: rgb(204, 51, 51);
    }

    .bid-form {
        background-color: #f8f9fa;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
    }

    .table th {
        background-color: rgb(230, 230, 235);
    }

    .lowest-bid {
        background-color: rgba(40, 167, 69, 0.1);
    }

    .your-bid {
        background-color: rgba(0, 51, 153, 0.1);
    }

    .table td,
    .table th {
        vertical-align: middle;
    }

    .chart-container {
        background: white;
        border-radius: 8px;
    }

    .supplier-message-btn {
        position: relative;
        width: 100%;
        border: none;
        border-radius: 10px;
        padding: 12px;
        color: white;
        background-color: rgb(0, 51, 153);
        font-weight: 600;
    }

    .message-count {
        position: absolute;
        top: -8px;
        right: -8px;
        min-width: 20px;
        height: 20px;
        padding: 0 6px;
        border-radius: 999px;
        background: #dc3545;
        color: white;
        font-size: 0.72rem;
        font-weight: 700;
        line-height: 20px;
        display: none;
    }

    .auction-chat-panel {
        position: fixed;
        right: 24px;
        bottom: 24px;
        width: min(380px, calc(100vw - 32px));
        background: white;
        border-radius: 14px;
        box-shadow: 0 24px 60px rgba(0, 0, 0, 0.24);
        overflow: hidden;
        z-index: 2000;
        display: none;
    }

    .auction-chat-header {
        background-color: rgb(0, 51, 153);
        color: white;
        padding: 14px 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .auction-chat-header small {
        display: block;
        color: rgba(255, 255, 255, 0.76);
    }

    .chat-close {
        border: 0;
        background: rgba(255, 255, 255, 0.18);
        color: white;
        border-radius: 50%;
        width: 30px;
        height: 30px;
    }

    .auction-chat-thread {
        height: 280px;
        overflow-y: auto;
        padding: 16px;
        background: #f7f9ff;
    }

    .auction-chat-bubble {
        max-width: 86%;
        padding: 11px 13px;
        margin-bottom: 10px;
        border-radius: 14px;
        background: white;
        border: 1px solid rgba(0, 51, 153, 0.12);
    }

    .auction-chat-bubble.mine {
        margin-left: auto;
        background: rgba(45, 212, 191, 0.18);
    }

    .auction-chat-bubble small {
        display: block;
        font-weight: 700;
        color: rgb(0, 51, 153);
        margin-bottom: 4px;
    }

    .auction-chat-bubble p {
        margin: 0;
        line-height: 1.45;
    }

    .auction-chat-form {
        display: flex;
        gap: 10px;
        padding: 14px;
        border-top: 1px solid rgba(0, 0, 0, 0.08);
    }

    .auction-chat-form input {
        flex: 1;
        min-width: 0;
        border: 1px solid #ced4da;
        border-radius: 999px;
        padding: 10px 14px;
    }

    .auction-chat-form button {
        border: 0;
        border-radius: 50%;
        width: 42px;
        height: 42px;
        color: white;
        background: rgb(0, 51, 153);
    }

    /* ── Sidebar CSS (Modernized) ── */
    :root, [data-theme="light"] {
        --sp-sidebar:   #102047;
        --sp-sidebar-h: #1e3a8a;
        --sp-sidebar-t: rgba(255,255,255,0.75);
        --sp-bg: #edf3ff;
        --sp-text: #102047;
    }
    [data-theme="dark"] {
        --sp-sidebar:   #0a0f1d;
        --sp-sidebar-h: #131e35;
        --sp-sidebar-t: rgba(255,255,255,0.65);
        --sp-bg: #0d1424;
        --sp-text: #e2e8f5;
    }

    body {
        margin: 0;
        padding: 0;
        display: flex;
        min-height: 100vh;
        background-color: var(--sp-bg);
        color: var(--sp-text);
        font-family: 'Segoe UI', Arial, sans-serif;
    }

    .sp-sidebar {
        width: 250px;
        min-height: 100vh;
        background: var(--sp-sidebar);
        display: flex;
        flex-direction: column;
        position: fixed;
        top: 0; left: 0;
        z-index: 1100;
        padding: 1.2rem 1rem 2rem;
        box-shadow: 2px 0 12px rgba(0,0,0,0.18);
        overflow-y: auto;
        transition: all 0.3s ease;
    }
    .sp-sidebar-logo {
        display: block;
        width: 140px;
        border-radius: 12px;
        margin: 0 auto 1.4rem;
    }
    .sp-sidebar-divider {
        border-top: 1px solid rgba(255,255,255,0.10);
        margin: 0.6rem 0 0.8rem;
    }
    .sp-sidebar-toggle {
        background: none;
        border: none;
        color: var(--sp-sidebar-t);
        font-size: 1.2rem;
        cursor: pointer;
        padding: 0.5rem;
        margin-bottom: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .sp-sidebar a {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 0.65rem 0.85rem;
        border-radius: 8px;
        color: var(--sp-sidebar-t);
        text-decoration: none;
        font-size: 0.93rem;
        font-weight: 500;
        transition: background 0.18s, color 0.18s;
        margin-bottom: 2px;
    }
    .sp-sidebar a:hover {
        background: var(--sp-sidebar-h);
        color: #fff;
    }
    .sp-sidebar a.active { background: rgba(255,255,255,0.18); color:#fff; font-weight:700; }
    .sp-sidebar i { width:18px; text-align:center; }

    .sp-main {
        margin-left: 250px;
        width: calc(100% - 250px);
        min-height: 100vh;
        padding: 24px;
        transition: all 0.3s ease;
        flex: 1;
    }

    .sp-sidebar.collapsed { width: 70px; padding: 1.2rem 0.5rem 2rem; }
    .sp-sidebar.collapsed .sp-sidebar-logo { display: none; }
    .sp-sidebar.collapsed a { justify-content: center; padding: 0.65rem 0; }
    .sp-sidebar.collapsed a span { display: none; }
    .sp-sidebar.collapsed ~ .sp-main {
        margin-left: 70px;
        width: calc(100% - 70px);
    }

    .container { max-width: 1200px; margin: 0 auto; }

    /* Dark Mode overrides for view.jsp */
    [data-theme="dark"] body {
        background-color: #0d1424;
        color: #e2e8f5;
    }
    [data-theme="dark"] .card {
        background-color: #1a2540;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.4);
    }
    [data-theme="dark"] .card-header {
        background-color: #0a1020;
    }
    [data-theme="dark"] .table {
        color: #e2e8f5;
    }
    [data-theme="dark"] .table th {
        background-color: #131e35;
        border-color: rgba(255,255,255,0.1);
    }
    [data-theme="dark"] .table td {
        border-color: rgba(255,255,255,0.1);
    }
    [data-theme="dark"] .detail-label {
        color: #8898aa;
    }
    [data-theme="dark"] .breadcrumb {
        background-color: #1a2540;
    }
    [data-theme="dark"] .breadcrumb-item a {
        color: #2DD4BF;
    }
    [data-theme="dark"] .bid-form {
        background-color: #131e35;
    }
    [data-theme="dark"] .chart-container {
        background: #131e35;
    }
    [data-theme="dark"] .form-control {
        background-color: #0d1424;
        color: #e2e8f5;
        border-color: rgba(255,255,255,0.2);
    }
    [data-theme="dark"] .form-control:focus {
        background-color: #131e35;
        color: #fff;
    }
    [data-theme="dark"] .your-bid {
        background-color: rgba(45, 212, 191, 0.15);
    }
    [data-theme="dark"] .lowest-bid {
        background-color: rgba(245, 158, 11, 0.15);
    }
    [data-theme="dark"] .auction-chat-panel {
        background-color: #1a2540;
        box-shadow: 0 10px 40px rgba(0,0,0,0.6);
    }
    [data-theme="dark"] .auction-chat-header {
        background-color: #0a1020;
    }
    [data-theme="dark"] .auction-chat-thread {
        background-color: #0d1424;
    }
    [data-theme="dark"] .auction-chat-bubble {
        background-color: #131e35;
        border-color: rgba(255,255,255,0.05);
        color: #e2e8f5;
    }
    [data-theme="dark"] .auction-chat-bubble small {
        color: #2DD4BF;
    }
    [data-theme="dark"] .auction-chat-form {
        border-color: rgba(255,255,255,0.1);
    }
    [data-theme="dark"] .list-group-item {
        background-color: #1a2540;
        color: #e2e8f5;
        border-color: rgba(255,255,255,0.08);
    }
    [data-theme="dark"] .list-group-item i.text-primary {
        color: #2DD4BF !important;
    }
</style>

<script>
    (function() {
        var savedTheme = localStorage.getItem('sp-theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
    })();
</script>

</head>
<body>

<!-- ── Sidebar ── -->
<nav class="sp-sidebar" id="spSidebar">
    <a href="${pageContext.request.contextPath}/bidding"
       style="display:flex;justify-content:center;margin-bottom:0.5rem;">
        <img src="${pageContext.request.contextPath}/assets/img/supplexio-logo.png"
             alt="Supplexio" class="sp-sidebar-logo">
    </a>
    <button class="sp-sidebar-toggle" id="spSidebarToggle" title="Toggle Sidebar">
        <i class="fas fa-bars"></i>
    </button>
    <hr class="sp-sidebar-divider">
    <a href="${pageContext.request.contextPath}/bidding">
        <i class="fas fa-gavel"></i> <span>Live Auctions</span>
    </a>
    <a href="${pageContext.request.contextPath}/supplier-po-view">
        <i class="fas fa-file-invoice"></i> <span>My Purchase Orders</span>
    </a>
    <hr class="sp-sidebar-divider">
    <a href="${pageContext.request.contextPath}/bidding" title="Go back for settings">
        <i class="fas fa-cog"></i> <span>Settings</span>
    </a>
    <a href="${pageContext.request.contextPath}/bidding?action=logout" style="margin-top:auto;">
        <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
    </a>
</nav>

<div class="sp-main">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/bidding">Supplier Auction Marketplace</a></li>
                <li class="breadcrumb-item active" aria-current="page">Place Bid</li>
            </ol>
        </nav>
        
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${success}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Auction Details</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p><span class="detail-label">Product:</span> ${auction.productName}</p>
                                <p><span class="detail-label">Quantity:</span> ${auction.requiredQuantity}</p>
                                <p><span class="detail-label">Starting Price:</span> <fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></p>
                                <p><span class="detail-label">Current Price:</span> <fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></p>
                            </div>
                            <div class="col-md-6">
                                <p><span class="detail-label">Start Time:</span> <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">End Time:</span> <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">Time Left:</span> <span class="countdown" data-end="${auction.endTime.time}">Loading...</span></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Place Your Bid</h4>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${isAuctionActive}">
                                <form method="post" action="${pageContext.request.contextPath}/bidding" class="mb-4">
                                    <input type="hidden" name="action" value="bid">
                                    <input type="hidden" name="auctionId" value="${auction.id}">
                                    
                                    <div class="form-group">
                                        <label for="amount">Your Bid Amount (₹)</label>
                                        <input type="number" step="0.01" min="0" class="form-control" id="amount" name="amount" required>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-gavel"></i> Place Bid
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info">
                                    <c:choose>
                                        <c:when test="${currentTimeMillis < auction.startTime.time}">
                                            <i class="fas fa-clock"></i> This auction has not started yet. It will begin on 
                                            <fmt:formatDate value="${auction.startTime}" pattern="MMM dd, yyyy HH:mm:ss" />
                                        </c:when>
                                        <c:when test="${currentTimeMillis > auction.endTime.time || auction.status == 'COMPLETED'}">
                                            <i class="fas fa-flag-checkered"></i> This auction has ended on 
                                            <fmt:formatDate value="${auction.endTime}" pattern="MMM dd, yyyy HH:mm:ss" />
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-exclamation-circle"></i> This auction is not active
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Bid Price Trend</h4>
                    </div>
                    <div class="card-body">
                        <div class="chart-container" style="position: relative; height:300px; width:100%">
                            <canvas id="bidChart"></canvas>
                        </div>
                        <div class="text-center mt-3 mb-2">
                            <small class="text-muted">Showing bid price trend over time</small>
                        </div>
                    </div>
                </div>
                
                <div class="card">
    <div class="card-header">
        <h4 class="mb-0">All Bids</h4>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Supplier</th>
                        <th>Bid Amount</th>
                        <th>Bid Time</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="bidInfo" items="${allBids}" varStatus="status">
                        <c:set var="bid" value="${bidInfo[0]}" />
                        <c:set var="supplierName" value="${bidInfo[1]}" />
                        <tr class="${status.index == 0 ? 'lowest-bid' : ''}">
                            <td>${supplierName}</td>
                            <td>&#8377;<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2" /></td>
                            <td><fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${status.index == 0}">
                                        <span class="badge badge-success">Lowest Bid</span>
                                    </c:when>
                                    <c:when test="${bid.supplierId == sessionScope.supplier.id}">
                                        <span class="badge badge-primary">Your Bid</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">Competing Bid</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty allBids}">
                        <tr>
                            <td colspan="4" class="text-center">No bids have been placed yet</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
            </div>
            
            <div class="col-md-4">
                <jsp:include page="/WEB-INF/views/common/auction-photos.jsp" />

                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Buyer Messages</h4>
                    </div>
                    <div class="card-body">
                        <p class="text-muted">Ask clarifications, confirm documents, or respond to buyer questions for this auction.</p>
                        <button type="button"
                                class="supplier-message-btn"
                                id="openAuctionChat"
                                data-auction-id="${auction.id}"
                                data-auction-name="${auction.productName}">
                            <i class="fas fa-envelope"></i> Message Buyer
                            <span class="message-count" data-count-for="${auction.id}">0</span>
                        </button>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Your Bids</h4>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Amount</th>
                                        <th>Time</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="bid" items="${supplierBids}">
                                        <tr>
                                            <td><fmt:formatNumber value="${bid.amount}" type="currency" currencySymbol="₹" /></td>
                                            <td><fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty supplierBids}">
                                        <tr>
                                            <td colspan="2" class="text-center">You haven't placed any bids yet</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Bidding Tips</h4>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> Your bid must be lower than the current price.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> Open supplier access means faster competition, so bid early and monitor the trend.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> You can place multiple bids until the auction ends.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> All bids are binding and cannot be withdrawn.
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="auction-chat-panel" id="auctionChatPanel" aria-label="Auction buyer chat">
        <div class="auction-chat-header">
            <div>
                <strong id="chatAuctionName">${auction.productName}</strong>
                <small>Talk to buyer for this auction</small>
            </div>
            <button type="button" class="chat-close" id="chatCloseBtn" aria-label="Close chat">&times;</button>
        </div>
        <div class="auction-chat-thread" id="auctionChatThread"></div>
        <form class="auction-chat-form" id="auctionChatForm">
            <input type="text" id="auctionChatInput" placeholder="Type message to buyer..." autocomplete="off">
            <button type="submit" aria-label="Send message"><i class="fas fa-paper-plane"></i></button>
        </form>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // Current time is already set by the servlet
        // Do not try to set JSP variables from JavaScript
        
        // Update countdown timer
        function updateCountdown() {
            const now = new Date().getTime();
            const element = document.querySelector('.countdown');
            const endTime = parseInt(element.getAttribute('data-end'));
            const timeLeft = endTime - now;
            
            if (timeLeft <= 0) {
                element.innerHTML = 'Auction ended';
                element.classList.add('text-danger');
                
                // Disable the bid form if auction has ended
                const bidForm = document.querySelector('.bid-form');
                if (bidForm) {
                    const submitButton = bidForm.querySelector('button[type="submit"]');
                    if (submitButton) {
                        submitButton.disabled = true;
                        submitButton.innerHTML = '<i class="fas fa-times"></i> Auction Ended';
                    }
                }
            } else {
                const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
                
                let countdownText = '';
                if (days > 0) countdownText += days + 'd ';
                countdownText += hours + 'h ' + minutes + 'm ' + seconds + 's';
                
                element.innerHTML = countdownText;
            }
        }
        
        // Initial update and set interval
        updateCountdown();
        setInterval(updateCountdown, 1000);
        
        // Initialize bid chart
        document.addEventListener('DOMContentLoaded', function() {
            const ctx = document.getElementById('bidChart').getContext('2d');
            
            // Fetch bid data for the chart
            const auctionId = '${auction.id}';
            
            console.log('Fetching bid data for auction ID:', auctionId);
            $.ajax({
                url: '${pageContext.request.contextPath}/api/bids/chart',
                type: 'GET',
                data: { auctionId: auctionId },
                dataType: 'json',
                success: function(data) {
                    console.log('Received bid data:', data);
                    if (data && data.length > 0) {
                        renderBidChart(ctx, data);
                    } else {
                        console.log('No bid data available');
                        // No data available, show a message
                        document.querySelector('.chart-container').innerHTML = 
                            '<div class="alert alert-info text-center">No bid data available to display chart</div>';
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading bid data:', status, error);
                    console.log('Response:', xhr.responseText);
                    // Error handling
                    document.querySelector('.chart-container').innerHTML = 
                        '<div class="alert alert-danger text-center">Failed to load bid chart data</div>';
                }
            });
        });
        
        function renderBidChart(ctx, data) {
            // Process the data for the chart
            const labels = data.map(item => {
                const date = new Date(item.bidTime);
                return date.toLocaleString();
            });
            
            const amounts = data.map(item => item.bidAmount);
            
            // Create the chart
            const bidChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Bid Amounts',
                        data: amounts,
                        backgroundColor: 'rgba(0, 51, 153, 0.2)',
                        borderColor: 'rgba(0, 51, 153, 1)',
                        borderWidth: 2,
                        pointBackgroundColor: 'rgba(0, 51, 153, 1)',
                        pointRadius: 4,
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: false,
                            title: {
                                display: true,
                                text: 'Bid Amount (₹)'
                            },
                            ticks: {
                                callback: function(value) {
                                    return '₹' + value;
                                }
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'Bid Time'
                            }
                        }
                    },
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return 'Bid Amount: ₹' + context.parsed.y;
                                }
                            }
                        },
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    }
                }
            });
        }

        const messageAuctionId = '${auction.id}';

        function setMessageBadge(count) {
            const badge = document.querySelector('[data-count-for="' + messageAuctionId + '"]');
            if (!badge) return;
            badge.textContent = count;
            badge.style.display = count > 0 ? 'inline-block' : 'none';
        }

        function loadMessageCount() {
            fetch('${pageContext.request.contextPath}/auction-messages?mode=counts&auctionId=' + messageAuctionId)
                .then(response => response.json())
                .then(counts => setMessageBadge(counts[messageAuctionId] || 0));
        }

        function renderAuctionMessages(messages) {
            const thread = document.getElementById('auctionChatThread');
            thread.innerHTML = '';
            if (!messages.length) {
                thread.innerHTML = '<div class="text-muted text-center mt-5">No messages yet. Ask the buyer a clarification.</div>';
                return;
            }
            messages.forEach(item => {
                const bubble = document.createElement('div');
                bubble.className = 'auction-chat-bubble' + (item.senderType === 'SUPPLIER' ? ' mine' : '');
                bubble.innerHTML = '<small></small><p></p>';
                bubble.querySelector('small').textContent = item.senderType === 'SUPPLIER' ? 'You' : 'Buyer';
                bubble.querySelector('p').textContent = item.message;
                thread.appendChild(bubble);
            });
            thread.scrollTop = thread.scrollHeight;
        }

        function openAuctionChat() {
            document.getElementById('auctionChatPanel').style.display = 'block';
            fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + messageAuctionId)
                .then(response => response.json())
                .then(data => {
                    renderAuctionMessages(data.messages || []);
                    setMessageBadge(0);
                });
        }

        document.getElementById('openAuctionChat').addEventListener('click', openAuctionChat);
        document.getElementById('chatCloseBtn').addEventListener('click', function() {
            document.getElementById('auctionChatPanel').style.display = 'none';
        });

        document.getElementById('auctionChatForm').addEventListener('submit', function(event) {
            event.preventDefault();
            const input = document.getElementById('auctionChatInput');
            const message = input.value.trim();
            if (!message) return;

            const params = new URLSearchParams();
            params.append('action', 'send');
            params.append('auctionId', messageAuctionId);
            params.append('message', message);

            fetch('${pageContext.request.contextPath}/auction-messages', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(() => {
                input.value = '';
                return fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + messageAuctionId);
            }).then(response => response.json())
              .then(data => renderAuctionMessages(data.messages || []));
        });

        loadMessageCount();
        setInterval(loadMessageCount, 15000);

        // --- Sidebar Toggle ---
        const spSidebar = document.getElementById('spSidebar');
        const spSidebarToggle = document.getElementById('spSidebarToggle');
        if (spSidebarToggle) {
            spSidebarToggle.addEventListener('click', () => {
                spSidebar.classList.toggle('collapsed');
            });
        }
    </script>
    </div>
</div><!-- /sp-main -->
</body>
</html>
