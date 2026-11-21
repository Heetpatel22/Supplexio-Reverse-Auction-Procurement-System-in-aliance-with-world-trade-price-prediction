<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html data-theme="light">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Bidding Portal - Supplexio Marketplace</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        /* ── Dark / Light theme tokens ── */
        :root, [data-theme="light"] {
            --sp-bg:        #edf3ff;
            --sp-surface:   #fff;
            --sp-card:      #fff;
            --sp-border:    rgba(30,58,138,0.10);
            --sp-text:      #102047;
            --sp-muted:     #64748b;
            --sp-sidebar:   #1E3A8A;
            --sp-sidebar-t: rgba(255,255,255,0.80);
            --sp-sidebar-h: rgba(255,255,255,0.14);
            --sp-input-bg:  #fff;
            --sp-input-bd:  rgba(100,116,139,0.30);
        }
        [data-theme="dark"] {
            --sp-bg:        #0d1424;
            --sp-surface:   #131e35;
            --sp-card:      #1a2540;
            --sp-border:    rgba(255,255,255,0.07);
            --sp-text:      #e2e8f5;
            --sp-muted:     #8898aa;
            --sp-sidebar:   #0a1020;
            --sp-sidebar-t: rgba(255,255,255,0.75);
            --sp-sidebar-h: rgba(255,255,255,0.10);
            --sp-input-bg:  #1a2540;
            --sp-input-bd:  rgba(255,255,255,0.12);
        }
        :root {
            --supplexio-blue: #1E3A8A;
            --supplexio-teal: #2DD4BF;
            --supplexio-gold: #F59E0B;
            --supplexio-ink: #102047;
            --supplexio-muted: #64748b;
            --supplexio-surface: #f4f7fb;
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            background: var(--sp-bg);
            color: var(--sp-text);
            font-family: 'Segoe UI', Arial, sans-serif;
            padding: 0;
            display: flex;
        }

        /* ── Sidebar ── */
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
        .sp-sidebar a, .sp-sidebar button.sp-nav-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 0.65rem 0.85rem;
            border-radius: 8px;
            color: var(--sp-sidebar-t);
            text-decoration: none;
            font-size: 0.93rem;
            font-weight: 500;
            width: 100%;
            background: none;
            border: none;
            cursor: pointer;
            transition: background 0.18s, color 0.18s;
            margin-bottom: 2px;
        }
        .sp-sidebar a:hover, .sp-sidebar button.sp-nav-btn:hover {
            background: var(--sp-sidebar-h);
            color: #fff;
        }
        .sp-sidebar a.active { background: rgba(255,255,255,0.18); color:#fff; font-weight:700; }
        .sp-sidebar a.sp-launch {
            background: linear-gradient(135deg,#F59E0B,#ffd47c);
            color: #102047;
            font-weight: 700;
            margin-bottom: 0.7rem;
        }
        .sp-sidebar a.sp-launch:hover { background: linear-gradient(135deg,#f1b638,#ffe0a3); }
        .sp-sidebar i { width:18px; text-align:center; }

        /* ── Main content area ── */
        .sp-main {
            margin-left: 250px;
            width: calc(100% - 250px);
            min-height: 100vh;
            padding: 24px 24px 48px;
            transition: all 0.3s ease;
        }

        /* Sidebar collapsed state overrides */
        .sp-sidebar.collapsed {
            width: 70px;
            padding: 1.2rem 0.5rem 2rem;
        }
        .sp-sidebar.collapsed .sp-sidebar-logo {
            display: none;
        }
        .sp-sidebar.collapsed a, .sp-sidebar.collapsed button.sp-nav-btn {
            justify-content: center;
            padding: 0.65rem 0;
        }
        .sp-sidebar.collapsed a span, .sp-sidebar.collapsed button.sp-nav-btn span {
            display: none;
        }
        .sp-sidebar.collapsed ~ .sp-main {
            margin-left: 70px;
            width: calc(100% - 70px);
        }
        .supplier-marketplace-shell {
            max-width: 1160px;
        }

        /* ── Settings panel (slide-in drawer) ── */
        .sp-settings-overlay {
            position: fixed; inset: 0;
            background: rgba(10,20,50,0.45);
            backdrop-filter: blur(4px);
            z-index: 3000;
            opacity: 0; pointer-events: none;
            transition: opacity 0.22s;
        }
        .sp-settings-overlay.open { opacity:1; pointer-events:auto; }
        .sp-settings-drawer {
            position: fixed;
            top: 0; right: 0;
            width: min(430px, 100vw);
            height: 100vh;
            background: var(--sp-surface);
            z-index: 3100;
            box-shadow: -12px 0 40px rgba(0,0,0,0.22);
            overflow-y: auto;
            transform: translateX(100%);
            transition: transform 0.28s cubic-bezier(0.4,0,0.2,1);
            padding: 0;
        }
        .sp-settings-overlay.open .sp-settings-drawer { transform: translateX(0); }
        .sp-settings-header {
            background: linear-gradient(135deg,#1E3A8A,#0f766e);
            color: #fff;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .sp-settings-header h5 { margin:0; font-weight:700; }
        .sp-settings-body { padding: 24px; }
        .sp-settings-section {
            background: var(--sp-card);
            border: 1px solid var(--sp-border);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .sp-settings-section h6 {
            font-weight: 700;
            color: var(--sp-text);
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .sp-settings-section h6 i { color: #1E3A8A; }
        .sp-settings-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--sp-input-bd);
            border-radius: 8px;
            background: var(--sp-input-bg);
            color: var(--sp-text);
            margin-bottom: 12px;
            font-size: 0.93rem;
        }
        .sp-settings-input:focus { outline: none; border-color: #1E3A8A; }
        .sp-settings-save {
            width: 100%;
            padding: 10px;
            border-radius: 8px;
            border: none;
            background: linear-gradient(135deg,#1E3A8A,#0f766e);
            color: #fff;
            font-weight: 700;
            cursor: pointer;
        }
        .sp-settings-save:hover { opacity: 0.9; }
        .sp-feedback { font-size:0.85rem; margin-top:8px; }
        .sp-feedback.ok { color:#16a34a; }
        .sp-feedback.err { color:#dc2626; }
        /* Theme toggle switch */
        .sp-theme-toggle {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--sp-card);
            border: 1px solid var(--sp-border);
            border-radius: 14px;
            padding: 16px 20px;
            margin-bottom: 20px;
        }
        .sp-theme-toggle span { color: var(--sp-text); font-weight:600; display:flex; align-items:center; gap:8px; }
        .sp-toggle-switch {
            position: relative;
            width: 52px; height: 28px;
        }
        .sp-toggle-switch input { opacity:0; width:0; height:0; }
        .sp-toggle-slider {
            position: absolute; inset:0;
            background: #cbd5e1;
            border-radius: 999px;
            cursor: pointer;
            transition: background 0.22s;
        }
        .sp-toggle-slider::before {
            content:'';
            position:absolute;
            width:20px; height:20px;
            left:4px; top:4px;
            background:#fff;
            border-radius:50%;
            transition: transform 0.22s;
        }
        .sp-toggle-switch input:checked + .sp-toggle-slider { background:#1E3A8A; }
        .sp-toggle-switch input:checked + .sp-toggle-slider::before { transform:translateX(24px); }

        /* Dark mode tweaks for existing cards */
        [data-theme="dark"] .card {
            background: var(--sp-card) !important;
            color: var(--sp-text);
            border-color: var(--sp-border);
        }
        [data-theme="dark"] .supplier-info,
        [data-theme="dark"] .auction-stat { background: var(--sp-card) !important; border-color: var(--sp-border); }
        [data-theme="dark"] .supplier-info strong, [data-theme="dark"] .auction-stat strong { color: var(--sp-text); }
        [data-theme="dark"] table { color: var(--sp-text); }
        [data-theme="dark"] .auction-chat-thread { background: #0d1424; }
        [data-theme="dark"] .auction-chat-bubble { background: var(--sp-card); border-color: var(--sp-border); }
        [data-theme="dark"] .no-auctions { color: var(--sp-muted); }

        .supplier-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 22px;
            padding: 24px;
            border-radius: 22px;
            color: #fff;
            background:
                linear-gradient(135deg, rgba(16, 32, 71, 0.98), rgba(30, 58, 138, 0.96)),
                linear-gradient(135deg, rgba(45, 212, 191, 0.22), transparent);
            box-shadow: 0 22px 50px rgba(19, 40, 93, 0.18);
            overflow: hidden;
        }

        .supplier-topbar h2 {
            margin: 8px 0 6px;
            font-size: clamp(1.8rem, 3.6vw, 3.1rem);
            line-height: 1.05;
            font-weight: 700;
        }

        .supplier-topbar p {
            margin: 0;
            color: rgba(255, 255, 255, 0.76);
        }

        .supplier-kicker,
        .auction-section-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 999px;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            font-size: 0.72rem;
            font-weight: 800;
        }

        .supplier-kicker {
            background: rgba(255, 255, 255, 0.12);
            color: rgba(255, 255, 255, 0.88);
        }

        .card {
            border: none;
            border-radius: 18px;
            box-shadow: 0 16px 40px rgba(19, 40, 93, 0.12);
            margin-bottom: 20px;
            transition: transform 0.3s ease;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-3px);
        }

        .card-header {
            background: linear-gradient(135deg, var(--supplexio-blue), #0f766e);
            color: white;
            font-weight: 600;
            border-radius: 18px 18px 0 0 !important;
            padding: 16px 20px;
        }

        .btn-primary {
            background: var(--supplexio-blue);
            border-color: var(--supplexio-blue);
        }

        .btn-primary:hover {
            background-color: #00307a;
            border-color: #00307a;
        }

        .btn-danger {
            background-color: rgb(204, 51, 51);
            border-color: rgb(204, 51, 51);
        }

        .btn-danger:hover {
            background-color: #b32e2e;
            border-color: #b32e2e;
        }

        .alert {
            border-radius: 10px;
        }

        .supplier-info {
            position: relative;
            background: rgba(255, 255, 255, 0.92);
            padding: 18px;
            border-radius: 18px;
            margin-bottom: 26px;
            border: 1px solid rgba(30, 58, 138, 0.08);
            box-shadow: 0 14px 34px rgba(19, 40, 93, 0.1);
        }

        .supplier-name {
            font-weight: 600;
            color: var(--supplexio-blue);
        }

        .supplier-info strong {
            color: var(--supplexio-ink);
        }

        .auction-section-head {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 16px;
            margin: 8px 0 22px;
        }

        .auction-section-head h4 {
            margin: 8px 0 6px;
            font-size: 1.75rem;
            font-weight: 700;
        }

        .auction-section-head p {
            margin: 0;
            color: var(--supplexio-muted);
        }

        .auction-section-kicker {
            color: var(--supplexio-blue);
            background: rgba(30, 58, 138, 0.08);
        }

        .countdown {
            font-weight: bold;
            color: rgb(204, 51, 51);
        }

        .no-auctions {
            text-align: center;
            padding: 50px 0;
            color: #666;
        }

        .no-auctions i {
            font-size: 3rem;
            color: rgb(230, 230, 235);
            margin-bottom: 20px;
        }

        .supplier-message-btn {
            position: relative;
            border: none;
            border-radius: 10px;
            padding: 11px 13px;
            color: white;
            background: linear-gradient(135deg, var(--supplexio-blue), #0f766e);
            font-weight: 600;
        }

        .auction-market-card .card-header {
            min-height: 78px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .auction-market-card h5 {
            font-size: 1.1rem;
            line-height: 1.3;
        }

        .auction-live-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 6px 9px;
            color: #102047;
            background: #9df0e4;
            font-size: 0.72rem;
            font-weight: 800;
            white-space: nowrap;
        }

        .auction-stat-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
            margin-bottom: 16px;
        }

        .auction-stat {
            min-width: 0;
            padding: 12px;
            border-radius: 12px;
            background: #f8fbff;
            border: 1px solid rgba(30, 58, 138, 0.08);
        }

        .auction-stat span {
            display: block;
            color: var(--supplexio-muted);
            font-size: 0.78rem;
            margin-bottom: 4px;
        }

        .auction-stat strong {
            color: var(--supplexio-ink);
            font-size: 0.96rem;
        }

        .auction-card-actions {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 46px;
            gap: 10px;
            margin-top: auto;
        }

        .auction-card-actions .btn,
        .auction-card-actions .supplier-message-btn {
            min-height: 44px;
            border-radius: 12px;
        }

        .auction-card-actions .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 700;
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

        @media (max-width: 767px) {
            body {
                padding-top: 12px;
            }

            .supplier-topbar,
            .auction-section-head {
                align-items: flex-start;
                flex-direction: column;
            }

            .auction-stat-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<!-- ── Settings overlay + drawer ── -->
<div class="sp-settings-overlay" id="spSettingsOverlay">
    <div class="sp-settings-drawer" id="spSettingsDrawer">
        <div class="sp-settings-header">
            <h5><i class="fas fa-cog"></i> Settings</h5>
            <button id="spSettingsClose" style="background:rgba(255,255,255,0.14);border:none;border-radius:50%;width:34px;height:34px;color:#fff;cursor:pointer;"><i class="fas fa-times"></i></button>
        </div>
        <div class="sp-settings-body">

            <!-- Theme toggle -->
            <div class="sp-theme-toggle">
                <span><i class="fas fa-moon"></i> Dark Mode</span>
                <label class="sp-toggle-switch" title="Toggle dark mode">
                    <input type="checkbox" id="spDarkToggle">
                    <span class="sp-toggle-slider"></span>
                </label>
            </div>

            <!-- Change Password -->
            <div class="sp-settings-section">
                <h6><i class="fas fa-lock"></i> Change Password</h6>
                <c:choose>
                    <c:when test="${fn:startsWith(supplierPassword, 'GOOGLE_') or supplierIsGoogle}"> 
                        <%-- Google-auth supplier: allow setting a password (no old password needed) --%>
                        <p style="font-size:0.88rem;color:var(--sp-muted);">Your account uses Google Sign-In. You can set a local password below.</p>
                        <form id="spPwdForm" method="post" action="${pageContext.request.contextPath}/bidding">
                            <input type="hidden" name="action" value="changePassword">
                            <input type="password" name="newPassword" id="spNewPwdG" class="sp-settings-input" placeholder="New Password" required minlength="6">
                            <input type="password" name="confirmPassword" id="spConfPwdG" class="sp-settings-input" placeholder="Confirm New Password" required minlength="6">
                            <button type="submit" class="sp-settings-save"><i class="fas fa-save"></i> Set Password</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <form id="spPwdForm" method="post" action="${pageContext.request.contextPath}/bidding">
                            <input type="hidden" name="action" value="changePassword">
                            <input type="password" name="oldPassword" id="spOldPwd" class="sp-settings-input" placeholder="Current Password" required>
                            <input type="password" name="newPassword" id="spNewPwd" class="sp-settings-input" placeholder="New Password" required minlength="6">
                            <input type="password" name="confirmPassword" id="spConfPwd" class="sp-settings-input" placeholder="Confirm New Password" required minlength="6">
                            <button type="submit" class="sp-settings-save"><i class="fas fa-save"></i> Update Password</button>
                        </form>
                    </c:otherwise>
                </c:choose>
                <c:if test="${not empty pwdSuccess}">
                    <p class="sp-feedback ok"><i class="fas fa-check-circle"></i> ${pwdSuccess}</p>
                </c:if>
                <c:if test="${not empty pwdError}">
                    <p class="sp-feedback err"><i class="fas fa-exclamation-circle"></i> ${pwdError}</p>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- ── Sidebar ── -->
<nav class="sp-sidebar" id="spSidebar">
    <a href="${pageContext.request.contextPath}/bidding"
       style="display:flex;justify-content:center;margin-bottom:0.5rem;" id="sidebarLogoLink">
        <img src="${pageContext.request.contextPath}/assets/img/supplexio-logo.png"
             alt="Supplexio" class="sp-sidebar-logo" id="sidebarLogo">
    </a>
    <button class="sp-sidebar-toggle" id="spSidebarToggle" title="Toggle Sidebar">
        <i class="fas fa-bars"></i>
    </button>
    <hr class="sp-sidebar-divider">
    <a href="${pageContext.request.contextPath}/bidding" class="active">
        <i class="fas fa-gavel"></i> <span>Live Auctions</span>
    </a>
    <a href="${pageContext.request.contextPath}/supplier-po-view">
        <i class="fas fa-file-invoice"></i> <span>My Purchase Orders</span>
    </a>
    <hr class="sp-sidebar-divider">
    <button class="sp-nav-btn" id="spOpenSettings">
        <i class="fas fa-cog"></i> <span>Settings</span>
    </button>
    <a href="${pageContext.request.contextPath}/bidding?action=logout" style="margin-top:auto;">
        <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
    </a>
</nav>

<!-- ── Main content ── -->
<div class="sp-main">
    <div class="supplier-marketplace-shell">
        <div class="supplier-topbar">
            <div>
                <span class="supplier-kicker"><i class="fas fa-store"></i> Supplier portal</span>
                <h2>Live auction marketplace</h2>
                <p>Track active sourcing events, message buyers, review POs, and place competitive bids.</p>
            </div>
        </div>

        <div id="purchaseOrdersSection" style="display:none; width:100%; max-width:1100px;">
            <c:if test="${not empty purchaseOrders}">
                <div class="card mb-4">
                    <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-file-invoice"></i> My Purchase Orders</span>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped mb-0">
                                <thead>
                                    <tr>
                                        <th>PO Number</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Quantity</th>
                                        <th>Amount</th>
                                        <th>GST (7.5%)</th>
                                        <th>Total (incl. GST)</th>
                                        <th>Supplier Name</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="po" items="${purchaseOrders}">
                                        <tr>
                                            <td>${po.poNumber}</td>
                                            <td><fmt:formatDate value="${po.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${po.status eq 'CONFIRMED'}">
                                                        <span class="badge badge-success">CONFIRMED</span>
                                                    </c:when>
                                                    <c:when test="${po.status eq 'SENT'}">
                                                        <span class="badge badge-primary">SENT</span>
                                                    </c:when>
                                                    <c:when test="${po.status eq 'DELIVERED'}">
                                                        <span class="badge badge-info">DELIVERED</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-warning">${po.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${po.quantity}</td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount * 0.075}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount * 1.075}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>${po.supplierName}</td>
                                            <td>
                                                <c:if test="${po.status eq 'PENDING' or po.status eq 'SENT'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/supplier-po-view" style="display:inline;">
                                                        <input type="hidden" name="poId" value="${po.id}">
                                                        <button type="submit" class="btn btn-success btn-sm">Confirm Order</button>
                                                    </form>
                                                </c:if>

                                                <a href="${pageContext.request.contextPath}/download-po-pdf?poId=${po.id}" class="btn btn-outline-primary btn-sm ml-1">
                                                    <i class="fas fa-download"></i> PDF
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty purchaseOrders}">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle"></i> You have no purchase orders yet.
                </div>
            </c:if>
        </div>

        <div class="supplier-info">
            <div class="row">
                <div class="col-md-6">
                    <p class="mb-1">Welcome, <span class="supplier-name">${supplier.name}</span></p>
                    <p class="mb-1"><strong>Marketplace Access:</strong> Open to all active auctions</p>
                </div>
                <div class="col-md-6 text-md-right">
                    <p class="mb-1"><strong>Email:</strong> ${supplier.email}</p>
                    <p class="mb-1"><strong>Phone:</strong> ${supplier.phone}</p>
                </div>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <div class="auction-section-head">
            <div>
                <span class="auction-section-kicker"><i class="fas fa-bolt"></i> Active auctions</span>
                <h4>Bid opportunities open now</h4>
                <p>Every active auction is visible here for approved supplier accounts.</p>
            </div>
            <span class="badge badge-primary badge-pill px-3 py-2"><c:out value="${auctions.size()}" /> live</span>
        </div>

        <div class="row">
            <c:forEach var="auction" items="${auctions}">
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 auction-market-card">
                        <div class="card-header">
                            <h5 class="mb-0">${auction.productName}</h5>
                            <span class="auction-live-badge"><i class="fas fa-circle"></i> Live</span>
                        </div>
                        <div class="card-body d-flex flex-column">
                            <div class="auction-stat-grid">
                                <div class="auction-stat">
                                    <span>Quantity</span>
                                    <strong>${auction.requiredQuantity} ${auction.unit}</strong>
                                </div>
                                <div class="auction-stat">
                                    <span>Current Price</span>
                                    <strong>&#8377;<fmt:formatNumber value="${auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                </div>
                                <div class="auction-stat">
                                    <span>End Time</span>
                                    <strong><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></strong>
                                </div>
                                <div class="auction-stat">
                                    <span>Time Left</span>
                                    <strong class="countdown" data-end="${auction.endTime.time}">Loading...</strong>
                                </div>
                            </div>

                            <div class="auction-card-actions">
                                <a href="${pageContext.request.contextPath}/bidding?action=view&id=${auction.id}" class="btn btn-primary">
                                    <i class="fas fa-gavel"></i> Place Bid
                                </a>
                                <button type="button"
                                        class="supplier-message-btn"
                                        data-auction-id="${auction.id}"
                                        data-auction-name="${auction.productName}">
                                    <i class="fas fa-envelope"></i>
                                    <span class="message-count" data-count-for="${auction.id}">0</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty auctions}">
                <div class="col-12">
                    <div class="no-auctions">
                        <i class="fas fa-search"></i>
                        <h4>No Active Auctions</h4>
                        <p>There are no open auctions in the marketplace at the moment.</p>
                        <p>Check back later for new sourcing opportunities.</p>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
    </div><!-- /sp-main -->

    <div class="auction-chat-panel" id="auctionChatPanel" aria-label="Auction buyer chat">
        <div class="auction-chat-header">
            <div>
                <strong id="chatAuctionName">Buyer Chat</strong>
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

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // ── Dark mode init ──
        (function() {
            var saved = localStorage.getItem('sp-theme') || 'light';
            document.documentElement.setAttribute('data-theme', saved);
            document.addEventListener('DOMContentLoaded', function() {
                var tog = document.getElementById('spDarkToggle');
                if (tog) tog.checked = (saved === 'dark');
            });
        })();

        document.addEventListener('DOMContentLoaded', function() {
            // --- Sidebar Toggle ---
            const spSidebar = document.getElementById('spSidebar');
            const spSidebarToggle = document.getElementById('spSidebarToggle');
            spSidebarToggle.addEventListener('click', () => {
                spSidebar.classList.toggle('collapsed');
            });

            // Settings drawer open/close
            var overlay  = document.getElementById('spSettingsOverlay');
            var openBtn  = document.getElementById('spOpenSettings');
            var closeBtn = document.getElementById('spSettingsClose');
            function openSettings()  { overlay.classList.add('open'); }
            function closeSettings() { overlay.classList.remove('open'); }
            if (openBtn)  openBtn.addEventListener('click', openSettings);
            if (closeBtn) closeBtn.addEventListener('click', closeSettings);
            overlay.addEventListener('click', function(e) {
                if (e.target === overlay) closeSettings();
            });

            // Open settings if redirected back with pwd message
            if (document.querySelector('.sp-feedback')) openSettings();

            // Dark mode toggle
            var darkTog = document.getElementById('spDarkToggle');
            if (darkTog) {
                darkTog.addEventListener('change', function() {
                    var theme = this.checked ? 'dark' : 'light';
                    document.documentElement.setAttribute('data-theme', theme);
                    localStorage.setItem('sp-theme', theme);
                });
            }

            <c:if test="${not empty pwdSuccess or not empty pwdError}">
            // Re-open settings drawer if password feedback is present
            if(openBtn) openBtn.click();
            </c:if>
        });
    </script>
    <script>
        function updateCountdowns() {
            var now = new Date().getTime();

            document.querySelectorAll('.countdown').forEach(function(element) {
                var endTime = parseInt(element.getAttribute('data-end'));
                var timeLeft = endTime - now;

                if (timeLeft <= 0) {
                    element.innerHTML = 'Auction ended';
                    element.classList.add('text-danger');
                } else {
                    var days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

                    var countdownText = '';
                    if (days > 0) {
                        countdownText += days + 'd ';
                    }
                    countdownText += hours + 'h ' + minutes + 'm ' + seconds + 's';

                    element.innerHTML = countdownText;
                }
            });
        }

        updateCountdowns();
        setInterval(updateCountdowns, 1000);

        document.getElementById('showPOBtn').addEventListener('click', function() {
            var section = document.getElementById('purchaseOrdersSection');
            if (section.style.display === 'none' || section.style.display === '') {
                section.style.display = 'block';
                this.classList.add('active');
            } else {
                section.style.display = 'none';
                this.classList.remove('active');
            }
        });

        let activeAuctionId = null;

        function setBadge(auctionId, count) {
            const badge = document.querySelector('[data-count-for="' + auctionId + '"]');
            if (!badge) return;
            badge.textContent = count;
            badge.style.display = count > 0 ? 'inline-block' : 'none';
        }

        function loadUnreadCounts() {
            fetch('${pageContext.request.contextPath}/auction-messages?mode=counts')
                .then(response => response.json())
                .then(counts => {
                    document.querySelectorAll('[data-count-for]').forEach(badge => {
                        const auctionId = badge.getAttribute('data-count-for');
                        setBadge(auctionId, counts[auctionId] || 0);
                    });
                });
        }

        function renderMessages(messages) {
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

        function openChat(button) {
            activeAuctionId = button.getAttribute('data-auction-id');
            document.getElementById('chatAuctionName').textContent = button.getAttribute('data-auction-name');
            document.getElementById('auctionChatPanel').style.display = 'block';
            fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + activeAuctionId)
                .then(response => response.json())
                .then(data => {
                    renderMessages(data.messages || []);
                    setBadge(activeAuctionId, 0);
                });
        }

        document.querySelectorAll('.supplier-message-btn').forEach(button => {
            button.addEventListener('click', function() {
                openChat(this);
            });
        });

        document.getElementById('chatCloseBtn').addEventListener('click', function() {
            document.getElementById('auctionChatPanel').style.display = 'none';
        });

        document.getElementById('auctionChatForm').addEventListener('submit', function(event) {
            event.preventDefault();
            const input = document.getElementById('auctionChatInput');
            const message = input.value.trim();
            if (!message || !activeAuctionId) return;

            const params = new URLSearchParams();
            params.append('action', 'send');
            params.append('auctionId', activeAuctionId);
            params.append('message', message);

            fetch('${pageContext.request.contextPath}/auction-messages', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(() => {
                input.value = '';
                return fetch('${pageContext.request.contextPath}/auction-messages?auctionId=' + activeAuctionId);
            }).then(response => response.json())
              .then(data => renderMessages(data.messages || []));
        });

        loadUnreadCounts();
        setInterval(loadUnreadCounts, 15000);
    </script>
</body>
</html>
