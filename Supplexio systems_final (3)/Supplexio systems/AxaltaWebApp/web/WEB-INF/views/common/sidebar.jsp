<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String curUri = request.getRequestURI();
    String curQuery = request.getQueryString();
    if (curQuery == null) curQuery = "";

    boolean isSettings = curUri.contains("/settings");
    boolean isPO = curUri.contains("/user-po-view") || curUri.contains("/po");
    boolean isInventory = curUri.contains("/inventory");
    boolean isTodo = curUri.contains("/todo");
    boolean isPayments = curUri.contains("/payment") || curUri.contains("/payments");
    boolean isSuppliers = curUri.contains("/supplier") || curUri.contains("/suppliers");
    boolean isAuctions = curUri.contains("/auction") || curUri.contains("/bidding");
    boolean isProducts = curUri.contains("/product") || curUri.contains("/products");
    boolean isDashboard = !isSettings && !isPO && !isInventory && !isTodo && !isPayments && !isSuppliers && !isAuctions && !isProducts;

    int poCount = 54;
    try {
        Object poAttr = request.getAttribute("poCount");
        if (poAttr instanceof Number) {
            poCount = ((Number) poAttr).intValue();
        } else {
            Object poListObj = request.getAttribute("poList");
            if (poListObj instanceof java.util.List) {
                poCount = ((java.util.List) poListObj).size();
            }
        }
    } catch(Exception ignored) {}

    String sessionUser = (String) session.getAttribute("username");
    if (sessionUser == null || sessionUser.trim().isEmpty()) sessionUser = "admin";
    String userInitials = sessionUser.length() >= 2 ? sessionUser.substring(0, 2).toUpperCase() : sessionUser.toUpperCase();
%>

<!-- Google Fonts: Inter -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<!-- Lucide Icons -->
<script src="https://unpkg.com/lucide@latest"></script>

<style>
/* -------------------------------------------------------------
   SUPPLEXIO UNIFIED SIDEBAR (EXACT PURCHASE ORDERS THEME 1:1)
   ------------------------------------------------------------- */
body {
    padding-left: 256px !important;
}
.main-content {
    margin-left: 0 !important;
}

#sp-unified-sidebar {
    width: 256px !important;
    min-width: 256px !important;
    max-width: 256px !important;
    height: 100vh !important;
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    bottom: 0 !important;
    z-index: 9999 !important;
    display: flex !important;
    flex-direction: column !important;
    background: linear-gradient(180deg, #172E6E 0%, #1E3E96 50%, #1B3680 100%) !important;
    color: #ffffff !important;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04) !important;
    border-right: 1px solid rgba(30, 58, 138, 0.4) !important;
    font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
    box-sizing: border-box !important;
    overflow: hidden !important;
}

#sp-unified-sidebar * {
    box-sizing: border-box !important;
    font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
}

/* Brand Card Header */
.sp-brand-header {
    padding: 16px !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
}
.sp-brand-card {
    background: #0B1E3D !important;
    border-radius: 12px !important;
    padding: 12px !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
    display: flex !important;
    flex-direction: column !important;
    align-items: center !important;
    text-align: center !important;
    text-decoration: none !important;
}
.sp-brand-title {
    display: flex !important;
    align-items: center !important;
    gap: 4px !important;
    line-height: 32px !important;
}
.sp-brand-white {
    font-size: 24px !important;
    font-weight: 900 !important;
    letter-spacing: -0.025em !important;
    color: #ffffff !important;
    line-height: 32px !important;
}
.sp-brand-teal {
    font-size: 24px !important;
    font-weight: 900 !important;
    letter-spacing: -0.025em !important;
    color: #2DD4BF !important;
    line-height: 32px !important;
}
.sp-brand-sub {
    font-size: 9px !important;
    font-weight: 700 !important;
    letter-spacing: 0.1em !important;
    color: #cbd5e1 !important;
    text-transform: uppercase !important;
    margin-top: 2px !important;
    line-height: 13.5px !important;
    display: block !important;
}

/* Launch Dashboard CTA */
.sp-cta-wrapper {
    padding: 16px 16px 8px 16px !important;
}
.sp-cta-btn {
    width: 100% !important;
    background: #F59E0B !important;
    color: #020617 !important;
    font-weight: 700 !important;
    font-size: 14px !important;
    line-height: 20px !important;
    padding: 10px 16px !important;
    border-radius: 8px !important;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06) !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 8px !important;
    text-decoration: none !important;
    transition: all 0.15s ease !important;
    cursor: pointer !important;
    border: none !important;
    box-sizing: border-box !important;
    height: 40px !important;
}
.sp-cta-btn:hover {
    background: #D97706 !important;
    color: #020617 !important;
    text-decoration: none !important;
    transform: scale(0.98) !important;
}
.sp-cta-icon {
    width: 16px !important;
    height: 16px !important;
    color: #020617 !important;
    fill: #020617 !important;
    flex-shrink: 0 !important;
}

/* Nav Menu */
.sp-nav-list {
    flex: 1 1 0% !important;
    padding: 8px 12px !important;
    overflow-y: auto !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 0px !important;
}
.sp-nav-list::-webkit-scrollbar {
    width: 4px;
}
.sp-nav-list::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 4px;
}

.sp-nav-item {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    padding: 10px 12px !important;
    border-radius: 8px !important;
    font-size: 14px !important;
    font-weight: 500 !important;
    line-height: 20px !important;
    color: #e2e8f0 !important;
    text-decoration: none !important;
    transition: background-color 0.15s ease, color 0.15s ease !important;
    border: none !important;
    margin-top: 4px !important;
    margin-bottom: 0px !important;
    box-sizing: border-box !important;
}
.sp-nav-item:first-child {
    margin-top: 0px !important;
}
.sp-nav-item:hover {
    background: rgba(255, 255, 255, 0.1) !important;
    color: #ffffff !important;
    text-decoration: none !important;
}
.sp-nav-item.active {
    background: rgba(255, 255, 255, 0.15) !important;
    color: #ffffff !important;
    font-weight: 600 !important;
    box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.06) !important;
    border: 1px solid rgba(255, 255, 255, 0.2) !important;
    backdrop-filter: blur(4px) !important;
    padding: 9px 11px !important;
}
.sp-nav-item.sp-nav-between {
    justify-content: space-between !important;
}
.sp-nav-left {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
}
.sp-nav-icon {
    width: 16px !important;
    height: 16px !important;
    color: #cbd5e1 !important;
    flex-shrink: 0 !important;
}
.sp-nav-item.active .sp-nav-icon {
    color: #2DD4BF !important;
}

/* Reverse Auctions LIVE Badge */
.sp-badge-live {
    background: rgba(245, 158, 11, 0.3) !important;
    color: #fcd34d !important;
    font-size: 10px !important;
    font-weight: 700 !important;
    line-height: 20px !important;
    padding: 2px 8px !important;
    height: 24px !important;
    border-radius: 9999px !important;
    border: 1px solid rgba(251, 191, 36, 0.4) !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    box-sizing: border-box !important;
    letter-spacing: 0 !important;
    flex-shrink: 0 !important;
}
/* Global Trade Intel Pulsing Dot */
.sp-badge-pulse {
    width: 8px !important;
    height: 8px !important;
    border-radius: 9999px !important;
    background: #2DD4BF !important;
    box-shadow: 0 0 8px #2DD4BF !important;
    animation: spPulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite !important;
    display: block !important;
    flex-shrink: 0 !important;
}
/* Purchase Orders 54 Badge - Exact Plump Oval from Auction, PO & Inventory */
.sp-badge-po {
    background: #2DD4BF !important;
    color: #020617 !important;
    font-size: 10px !important;
    font-weight: 800 !important;
    line-height: 20px !important;
    padding: 2px 8px !important;
    height: 24px !important;
    min-width: 29.2px !important;
    border-radius: 9999px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    box-sizing: border-box !important;
    letter-spacing: 0 !important;
    flex-shrink: 0 !important;
}
@keyframes spPulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.4; transform: scale(1.15); }
}

/* User Profile Footer (Username Only, Clickable) */
.sp-profile-footer {
    padding: 12px !important;
    border-top: 1px solid rgba(255, 255, 255, 0.1) !important;
    background: rgba(0, 0, 0, 0.2) !important;
    margin-top: auto !important;
}
.sp-profile-pill {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    padding: 10px !important;
    border-radius: 12px !important;
    background: rgba(255, 255, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    cursor: pointer !important;
    transition: all 0.15s ease !important;
}
.sp-profile-pill:hover {
    background: rgba(255, 255, 255, 0.15) !important;
    border-color: rgba(255, 255, 255, 0.2) !important;
}
.sp-profile-avatar {
    width: 36px !important;
    height: 36px !important;
    border-radius: 9999px !important;
    background: #2DD4BF !important;
    color: #020617 !important;
    font-weight: 900 !important;
    font-size: 12px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    letter-spacing: 0.05em !important;
    flex-shrink: 0 !important;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1) !important;
}
.sp-profile-username {
    font-size: 14px !important;
    font-weight: 700 !important;
    color: #ffffff !important;
    letter-spacing: 0.025em !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    margin: 0 !important;
    flex: 1 1 0% !important;
    line-height: 20px !important;
}
.sp-profile-pill:hover .sp-profile-username {
    color: #2DD4BF !important;
}
.sp-profile-cog {
    width: 16px !important;
    height: 16px !important;
    color: #2DD4BF !important;
    flex-shrink: 0 !important;
}

/* User Profile Modal Styles */
.sp-modal-backdrop {
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    right: 0 !important;
    bottom: 0 !important;
    background: rgba(15, 23, 42, 0.65) !important;
    backdrop-filter: blur(4px) !important;
    z-index: 10000 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 16px !important;
}
.sp-modal-backdrop.hidden {
    display: none !important;
}
.sp-modal-box {
    background: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
    border-radius: 16px !important;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25) !important;
    width: 100% !important;
    max-width: 440px !important;
    overflow: hidden !important;
    animation: spModalSlide 0.2s ease-out !important;
}
@keyframes spModalSlide {
    from { opacity: 0; transform: translateY(10px) scale(0.98); }
    to { opacity: 1; transform: translateY(0) scale(1); }
}
.sp-modal-head {
    background: #0B1E3D !important;
    padding: 16px 20px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
}
.sp-modal-body {
    padding: 20px !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 16px !important;
}
.sp-modal-footer {
    padding: 14px 20px !important;
    background: #f8fafc !important;
    border-top: 1px solid #e2e8f0 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: flex-end !important;
    gap: 10px !important;
}
.sp-form-input {
    width: 100% !important;
    padding: 9px 12px !important;
    font-size: 14px !important;
    background: #f8fafc !important;
    border: 1px solid #cbd5e1 !important;
    border-radius: 8px !important;
    color: #0f172a !important;
    outline: none !important;
    box-sizing: border-box !important;
}
.sp-form-input:focus {
    border-color: #2563EB !important;
    background: #ffffff !important;
    box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2) !important;
}
.sp-form-label {
    display: block !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    color: #475569 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
    margin-bottom: 6px !important;
}
</style>

<!-- ASIDE: Unified Supplexio Navigation Sidebar -->
<aside id="sp-unified-sidebar">
    <!-- Brand Badge Header -->
    <div class="sp-brand-header">
        <a href="${pageContext.request.contextPath}/home?action=workspace" class="sp-brand-card">
            <div class="sp-brand-title">
                <span class="sp-brand-white">Supple</span><span class="sp-brand-teal">xio</span>
            </div>
            <span class="sp-brand-sub">BID BOLD • SOURCE SMART</span>
        </a>
    </div>

    <!-- Top CTA Button: Launch Dashboard -->
    <div class="sp-cta-wrapper">
        <a href="${pageContext.request.contextPath}/home" class="sp-cta-btn">
            <i data-lucide="rocket" class="sp-cta-icon"></i>
            <span>Launch Dashboard</span>
        </a>
    </div>

    <!-- Navigation Links -->
    <nav class="sp-nav-list">
        <!-- 1. Dashboard -->
        <a href="${pageContext.request.contextPath}/home?action=workspace" class="sp-nav-item <%= isDashboard ? "active" : "" %>">
            <i data-lucide="layout-dashboard" class="sp-nav-icon"></i>
            <span>Dashboard</span>
        </a>

        <!-- 2. Products -->
        <a href="${pageContext.request.contextPath}/product" class="sp-nav-item <%= isProducts ? "active" : "" %>">
            <i data-lucide="package" class="sp-nav-icon"></i>
            <span>Products</span>
        </a>

        <!-- 3. Reverse Auctions -->
        <a href="${pageContext.request.contextPath}/auction" class="sp-nav-item sp-nav-between <%= isAuctions ? "active" : "" %>">
            <div class="sp-nav-left">
                <i data-lucide="gavel" class="sp-nav-icon"></i>
                <span>Reverse Auctions</span>
            </div>
            <span class="sp-badge-live">LIVE</span>
        </a>

        <!-- 4. Suppliers -->
        <a href="${pageContext.request.contextPath}/supplier" class="sp-nav-item <%= isSuppliers ? "active" : "" %>">
            <i data-lucide="users" class="sp-nav-icon"></i>
            <span>Suppliers</span>
        </a>

        <!-- 5. Payments -->
        <a href="${pageContext.request.contextPath}/payment" class="sp-nav-item <%= isPayments ? "active" : "" %>">
            <i data-lucide="credit-card" class="sp-nav-icon"></i>
            <span>Payments</span>
        </a>

        <!-- 6. To-Do List -->
        <a href="${pageContext.request.contextPath}/todo" class="sp-nav-item <%= isTodo ? "active" : "" %>">
            <i data-lucide="check-square" class="sp-nav-icon"></i>
            <span>To-Do List</span>
        </a>

        <!-- 7. Inventory Management -->
        <a href="${pageContext.request.contextPath}/inventory" class="sp-nav-item <%= isInventory ? "active" : "" %>">
            <i data-lucide="boxes" class="sp-nav-icon"></i>
            <span>Inventory Management</span>
        </a>

        <!-- 8. Global Trade Intel -->
        <a href="http://localhost:8501" target="_blank" class="sp-nav-item sp-nav-between">
            <div class="sp-nav-left">
                <i data-lucide="globe-2" class="sp-nav-icon" style="color:#2DD4BF !important;"></i>
                <span>Global Trade Intel</span>
            </div>
            <span class="sp-badge-pulse"></span>
        </a>

        <!-- 9. Purchase Orders -->
        <a href="${pageContext.request.contextPath}/user-po-view" class="sp-nav-item sp-nav-between <%= isPO ? "active" : "" %>">
            <div class="sp-nav-left">
                <i data-lucide="file-text" class="sp-nav-icon"></i>
                <span>Purchase Orders</span>
            </div>
            <span class="sp-badge-po" id="sidebar-po-badge"><%= poCount %></span>
        </a>

        <!-- 10. Settings -->
        <a href="${pageContext.request.contextPath}/settings" class="sp-nav-item <%= isSettings ? "active" : "" %>">
            <i data-lucide="settings" class="sp-nav-icon"></i>
            <span>Settings</span>
        </a>
    </nav>

    <!-- Sidebar User Profile Footer (Clickable to Edit Profile & Password) -->
    <div class="sp-profile-footer">
        <div onclick="openUserProfileModal()" class="sp-profile-pill" title="Click to update username or change password">
            <div class="sp-profile-avatar" id="sidebar-user-avatar"><%= userInitials %></div>
            <p class="sp-profile-username" id="sidebar-username-display"><%= sessionUser %></p>
            <i data-lucide="settings" class="sp-profile-cog"></i>
        </div>
    </div>
</aside>

<!-- User Profile & Password Modal (Supplexio Theme) -->
<div id="userProfileModal" class="sp-modal-backdrop hidden">
    <div class="sp-modal-box">
        <div class="sp-modal-head">
            <div style="display:flex; align-items:center; gap:8px;">
                <div style="background:#1E3E96; padding:6px; border-radius:8px; display:flex;">
                    <i data-lucide="user-check" style="width:16px; height:16px; color:#2DD4BF;"></i>
                </div>
                <div>
                    <h3 style="font-size:14px; font-weight:700; color:#ffffff; margin:0; line-height:1.2;">Account Profile & Security</h3>
                    <p style="font-size:11px; color:#cbd5e1; margin:0;">Manage your account credentials</p>
                </div>
            </div>
            <button type="button" onclick="closeUserProfileModal()" style="background:none; border:none; color:#cbd5e1; font-size:20px; cursor:pointer; line-height:1;">&times;</button>
        </div>

        <div class="sp-modal-body">
            <div id="profileModalAlert" style="display:none; padding:10px 12px; border-radius:8px; font-size:12px; font-weight:600;"></div>

            <div>
                <label class="sp-form-label">Username <span style="color:#ef4444;">*</span></label>
                <input type="text" id="profileModalUsername" value="<%= sessionUser %>" class="sp-form-input" placeholder="Enter username" />
                <p style="font-size:11px; color:#94a3b8; margin:4px 0 0 0;">This is your primary login name and account identifier across Supplexio.</p>
            </div>

            <div style="border-top:1px dashed #e2e8f0; padding-top:12px;">
                <label class="sp-form-label" style="display:flex; align-items:center; gap:6px;">
                    <i data-lucide="key" style="width:12px; height:12px; color:#f59e0b;"></i>
                    Change Password (Optional)
                </label>
                <p style="font-size:11px; color:#94a3b8; margin:0 0 10px 0;">Leave password fields blank if you only want to update your username.</p>

                <div style="display:flex; flex-direction:column; gap:10px;">
                    <div>
                        <span style="font-size:11px; color:#64748b; font-weight:500;">Current Password</span>
                        <input type="password" id="profileModalCurrentPass" class="sp-form-input" placeholder="Current password" style="margin-top:2px;" />
                    </div>
                    <div>
                        <span style="font-size:11px; color:#64748b; font-weight:500;">New Password</span>
                        <input type="password" id="profileModalNewPass" class="sp-form-input" placeholder="New password (min 6 chars)" style="margin-top:2px;" />
                    </div>
                    <div>
                        <span style="font-size:11px; color:#64748b; font-weight:500;">Confirm New Password</span>
                        <input type="password" id="profileModalConfirmPass" class="sp-form-input" placeholder="Re-type new password" style="margin-top:2px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="sp-modal-footer">
            <button type="button" onclick="closeUserProfileModal()" style="padding:8px 14px; background:#ffffff; border:1px solid #cbd5e1; border-radius:8px; font-size:12px; font-weight:600; color:#334155; cursor:pointer;">
                Cancel
            </button>
            <button type="button" id="btnSaveProfile" onclick="submitUserProfileUpdate()" style="padding:8px 16px; background:#F59E0B; border:none; border-radius:8px; font-size:12px; font-weight:700; color:#020617; cursor:pointer; display:flex; align-items:center; gap:6px; box-shadow:0 2px 4px rgba(245, 158, 11, 0.3);">
                <i data-lucide="check" style="width:14px; height:14px;"></i>
                <span>Save Account Changes</span>
            </button>
        </div>
    </div>
</div>

<script>
    if (window.lucide) {
        lucide.createIcons();
    } else {
        document.addEventListener('DOMContentLoaded', function() {
            if (window.lucide) lucide.createIcons();
        });
    }

    function openUserProfileModal() {
        var modal = document.getElementById('userProfileModal');
        if (!modal) return;
        var alertBox = document.getElementById('profileModalAlert');
        if (alertBox) { alertBox.style.display = 'none'; alertBox.innerHTML = ''; }
        var currentPass = document.getElementById('profileModalCurrentPass');
        var newPass = document.getElementById('profileModalNewPass');
        var confirmPass = document.getElementById('profileModalConfirmPass');
        if (currentPass) currentPass.value = '';
        if (newPass) newPass.value = '';
        if (confirmPass) confirmPass.value = '';
        modal.classList.remove('hidden');
        if (window.lucide) lucide.createIcons();
    }

    function closeUserProfileModal() {
        var modal = document.getElementById('userProfileModal');
        if (modal) modal.classList.add('hidden');
    }

    function showProfileAlert(type, message) {
        var alertBox = document.getElementById('profileModalAlert');
        if (!alertBox) return;
        if (type === 'error') {
            alertBox.style.background = '#fef2f2';
            alertBox.style.border = '1px solid #fecaca';
            alertBox.style.color = '#991b1b';
        } else {
            alertBox.style.background = '#ecfdf5';
            alertBox.style.border = '1px solid #a7f3d0';
            alertBox.style.color = '#065f46';
        }
        alertBox.innerHTML = message;
        alertBox.style.display = 'block';
    }

    function submitUserProfileUpdate() {
        var username = (document.getElementById('profileModalUsername') || {}).value || '';
        var currentPass = (document.getElementById('profileModalCurrentPass') || {}).value || '';
        var newPass = (document.getElementById('profileModalNewPass') || {}).value || '';
        var confirmPass = (document.getElementById('profileModalConfirmPass') || {}).value || '';
        var btn = document.getElementById('btnSaveProfile');

        if (!username.trim()) {
            showProfileAlert('error', 'Username cannot be blank.');
            return;
        }

        if (newPass || confirmPass || currentPass) {
            if (!currentPass) {
                showProfileAlert('error', 'Please enter your current password to verify this change.');
                return;
            }
            if (newPass.length < 6) {
                showProfileAlert('error', 'New password must be at least 6 characters.');
                return;
            }
            if (newPass !== confirmPass) {
                showProfileAlert('error', 'New password and confirmation do not match.');
                return;
            }
        }

        var origBtnHtml = btn ? btn.innerHTML : '';
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<span>Saving...</span>';
        }

        var formData = new URLSearchParams();
        formData.append('username', username.trim());
        if (newPass) {
            formData.append('currentPassword', currentPass);
            formData.append('newPassword', newPass);
        }

        fetch('${pageContext.request.contextPath}/update_profile.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (btn) { btn.disabled = false; btn.innerHTML = origBtnHtml; }
            if (data.status === 'success') {
                showProfileAlert('success', data.message || 'Profile updated successfully!');
                var disp = document.getElementById('sidebar-username-display');
                if (disp) disp.innerText = data.username || username.trim();
                var avt = document.getElementById('sidebar-user-avatar');
                if (avt) {
                    var u = data.username || username.trim();
                    avt.innerText = (u.length >= 2 ? u.substring(0, 2) : u).toUpperCase();
                }
                setTimeout(function() {
                    closeUserProfileModal();
                }, 1200);
            } else {
                showProfileAlert('error', data.message || 'Error updating profile.');
            }
        })
        .catch(function(err) {
            if (btn) { btn.disabled = false; btn.innerHTML = origBtnHtml; }
            showProfileAlert('error', 'Network error while updating profile.');
        });
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeUserProfileModal();
    });
</script>
<jsp:include page="/WEB-INF/views/common/dark-mode.jsp" />
<jsp:include page="/WEB-INF/views/common/ai-chatbot.jsp" />
