<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String errorMsg = (String) request.getSession().getAttribute("error");
    if (errorMsg != null) request.getSession().removeAttribute("error");
%>
<!DOCTYPE html>
<html data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Purchase Orders - Supplexio</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        /* ── Dark / Light theme tokens ── */
        :root, [data-theme="light"] {
            --sp-bg:        #edf3ff;
            --sp-surface:   #fff;
            --sp-card:      #fff;
            --sp-text:      #102047;
            --sp-muted:     #64748b;
            --sp-border:    #e2e8f0;
            --sp-table-bd:  #dee2e6;
            --sp-sidebar:   #102047;
            --sp-sidebar-h: #1e3a8a;
            --sp-sidebar-t: rgba(255,255,255,0.75);
            --supplexio-gold: #F59E0B;
        }
        [data-theme="dark"] {
            --sp-bg:        #0d1424;
            --sp-surface:   #131e35;
            --sp-card:      #1a2540;
            --sp-text:      #e2e8f5;
            --sp-muted:     #8898aa;
            --sp-border:    rgba(255,255,255,0.1);
            --sp-table-bd:  rgba(255,255,255,0.1);
            --sp-sidebar:   #0a0f1d;
            --sp-sidebar-h: #131e35;
            --sp-sidebar-t: rgba(255,255,255,0.65);
        }

        * { box-sizing: border-box; }

        body { 
            background: var(--sp-bg); 
            color: var(--sp-text);
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            min-height: 100vh;
            padding-left: 250px;
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

        /* ── Main content ── */
        .sp-main {
            margin-left: 0;
            min-height: 100vh;
            padding: 24px 32px;
            max-width: 1280px;
            width: 100%;
            transition: padding-left 0.3s ease;
        }
        .sp-main .card {
            width: 100%;
        }

        /* Sidebar collapsed state overrides */
        .sp-sidebar.collapsed { width: 70px; padding: 1.2rem 0.5rem 2rem; }
        .sp-sidebar.collapsed .sp-sidebar-logo { display: none; }
        .sp-sidebar.collapsed a { justify-content: center; padding: 0.65rem 0; }
        .sp-sidebar.collapsed a span { display: none; }
        body.sidebar-collapsed { padding-left: 70px; }

        .shipping-trigger-box {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border: 2px dashed #f59e0b;
            border-radius: 10px;
            background: rgba(245, 158, 11, 0.08);
            color: #b45309;
            font-weight: 700;
            font-size: 0.85rem;
            cursor: pointer;
            transition: background 0.2s, transform 0.15s;
        }
        .shipping-trigger-box:hover {
            background: rgba(245, 158, 11, 0.16);
            transform: translateY(-1px);
        }
        [data-theme="dark"] .shipping-trigger-box {
            color: #fbbf24;
            border-color: #f59e0b;
        }
        .invoice-trigger-box {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border: 2px dashed #dc3545;
            border-radius: 10px;
            background: rgba(220, 53, 69, 0.08);
            color: #dc3545;
            font-weight: 700;
            font-size: 0.82rem;
            cursor: pointer;
        }
        .po-actions-cell { white-space: nowrap; }

        .po-header-bar {
            background: linear-gradient(135deg, #1E3A8A 0%, #0f766e 100%);
            color: white;
            padding: 1.5rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .po-header-bar i { font-size: 1.6rem; }
        .po-header-bar span { font-size: 1.4rem; font-weight: 700; }
        
        .card {
            background: var(--sp-card);
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }
        
        .table {
            color: var(--sp-text);
        }
        .table-bordered th, .table-bordered td {
            border-color: var(--sp-table-bd) !important;
            vertical-align: middle;
        }
        .thead-dark th {
            background-color: var(--sp-surface) !important;
            color: var(--sp-text) !important;
            border-bottom: 2px solid var(--sp-table-bd) !important;
            font-weight: 600;
        }

        [data-theme="dark"] .table-striped tbody tr:nth-of-type(odd) {
            background-color: rgba(255,255,255,0.02);
        }
        [data-theme="dark"] .table-hover tbody tr:hover {
            background-color: rgba(255,255,255,0.05);
        }

        .badge-sent      { background:#007bff; color:white; padding:6px 12px; border-radius:6px; font-weight: 600; }
        .badge-pending   { background:#ffc107; color:#333; padding:6px 12px; border-radius:6px; font-weight: 600; }
        .badge-confirmed { background:#28a745; color:white; padding:6px 12px; border-radius:6px; font-weight: 600; }
        .badge-delivered { background:#17a2b8; color:white; padding:6px 12px; border-radius:6px; font-weight: 600; }
        .badge-draft     { background:#6c757d; color:white; padding:6px 12px; border-radius:6px; font-weight: 600; }
        
        .btn-sm { border-radius: 6px; font-weight: 600; }
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
    <a href="<%= request.getContextPath() %>/bidding"
       style="display:flex;justify-content:center;margin-bottom:0.5rem;">
        <img src="<%= request.getContextPath() %>/assets/img/supplexio-logo.png"
             alt="Supplexio" class="sp-sidebar-logo">
    </a>
    <button class="sp-sidebar-toggle" id="spSidebarToggle" title="Toggle Sidebar">
        <i class="fas fa-bars"></i>
    </button>
    <hr class="sp-sidebar-divider">
    <a href="<%= request.getContextPath() %>/bidding">
        <i class="fas fa-gavel"></i> <span>Live Auctions</span>
    </a>
    <a href="<%= request.getContextPath() %>/supplier-po-view" class="active">
        <i class="fas fa-file-invoice"></i> <span>My Purchase Orders</span>
    </a>
    <hr class="sp-sidebar-divider">
    <a href="<%= request.getContextPath() %>/bidding" title="Go to Auctions for settings">
        <i class="fas fa-cog"></i> <span>Settings</span>
    </a>
    <a href="<%= request.getContextPath() %>/bidding?action=logout" style="margin-top:auto;">
        <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
    </a>
</nav>

<div class="sp-main">
    <!-- Blue header bar -->
    <div class="po-header-bar">
        <i class="fas fa-file-invoice"></i>
        <span>My Purchase Orders</span>
    </div>

    <% if (errorMsg != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
    <% } %>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-hover table-bordered mb-0">
                    <thead class="thead-dark">
                        <tr>
                            <th>PO ID</th>
                            <th>PO Number</th>
                            <th>Material</th>
                            <th>Qty</th>
                            <th>Amount</th>
                            <th>GST (7.5%)</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (poList != null && !poList.isEmpty()) {
                        for (Object obj : poList) {
                            Class<?> bc = obj.getClass();
                            long   poId     = (Long)   bc.getMethod("getId").invoke(obj);
                            String material = (String) bc.getMethod("getMaterial").invoke(obj);
                            String poNumber = "";
                            try { poNumber = (String) bc.getMethod("getPoNumber").invoke(obj); } catch(Exception e) {}
                            if (poNumber == null || poNumber.isEmpty()) poNumber = "PO-" + poId;
                            double amount   = (Double) bc.getMethod("getAmount").invoke(obj);
                            int    qty      = (Integer)bc.getMethod("getQuantity").invoke(obj);
                            String status   = (String) bc.getMethod("getStatus").invoke(obj);
                            if ("COMPLETED".equalsIgnoreCase(status)) status = "PO_DRAFT";
                            if ("SENT".equalsIgnoreCase(status)) status = "PO_SENT";
                            if ("PAID".equalsIgnoreCase(status)) status = "PAYMENT_SUCCESSFUL";
                            if ("PENDING".equalsIgnoreCase(status)) status = "PO_DRAFT";
                            
                            java.util.Date createdAt = (java.util.Date) bc.getMethod("getCreatedAt").invoke(obj);
                            double gst   = amount * 0.075;
                            double total = amount + gst;
                            String badgeClass = "badge-draft";
                            if ("PO_SENT".equalsIgnoreCase(status)) badgeClass = "badge-pending";
                            if ("PO_ACCEPTED".equalsIgnoreCase(status)) badgeClass = "badge-sent";
                            if ("SHIPPED".equalsIgnoreCase(status)) badgeClass = "badge-pending";
                            if ("DELIVERED".equalsIgnoreCase(status)) badgeClass = "badge-delivered";
                            if ("INVOICING_PENDING".equalsIgnoreCase(status)) badgeClass = "badge-pending";
                            if ("PAYMENT_PENDING".equalsIgnoreCase(status)) badgeClass = "badge-pending";
                            if ("PAYMENT_SUCCESSFUL".equalsIgnoreCase(status)) badgeClass = "badge-confirmed";
                            if ("CLOSED".equalsIgnoreCase(status)) badgeClass = "badge-draft";
                    %>
                        <tr>
                            <td><strong><%= poId %></strong></td>
                            <td><%= poNumber %></td>
                            <td><%= material != null ? material : "N/A" %></td>
                            <td><%= qty %></td>
                            <td>₹<%= String.format("%.2f", amount) %></td>
                            <td>₹<%= String.format("%.2f", gst) %></td>
                            <td><strong>₹<%= String.format("%.2f", total) %></strong></td>
                            <td><span class="<%= badgeClass %>"><%= status %></span></td>
                            <td><span style="font-size:0.9rem; color:var(--sp-muted)"><%= createdAt != null ? sdf.format(createdAt) : "-" %></span></td>
                            <td class="po-actions-cell">
    <% if ("PO_SENT".equalsIgnoreCase(status)) { %>
        <form method="post" action="<%= request.getContextPath() %>/pos/accept" style="display:inline;">
            <input type="hidden" name="poId" value="<%= poId %>"/>
            <button type="submit" class="btn btn-primary btn-sm mb-1"><i class="fas fa-check"></i> Accept PO</button>
        </form>
    <% } else if ("PO_ACCEPTED".equalsIgnoreCase(status)) { %>
        <button type="button" class="shipping-trigger-box js-open-ship-modal mb-1"
                data-po-id="<%= poId %>">
            <i class="fas fa-truck"></i> FILL SHIPPING DETAILS
        </button>
    <% } else if ("DELIVERED".equalsIgnoreCase(status) || "INVOICING_PENDING".equalsIgnoreCase(status)) { %>
        <button type="button" class="invoice-trigger-box js-open-invoice-modal mb-1"
                data-po-id="<%= poId %>"
                data-amount="<%= String.format("%.2f", amount) %>"
                data-qty="<%= qty %>">
            <i class="fas fa-file-invoice"></i> UPLOAD INVOICE
        </button>
    <% } %>

    <% if (!"PO_DRAFT".equalsIgnoreCase(status)) { %>
        <a href="<%= request.getContextPath() %>/documents/po.pdf?poId=<%= poId %>" class="btn btn-outline-primary btn-sm mb-1" target="_blank" title="Download PO"><i class="fas fa-file-pdf"></i> PO</a>
    <% } %>
    
    <% if ("DELIVERED".equalsIgnoreCase(status) || "INVOICING_PENDING".equalsIgnoreCase(status) || "PAYMENT_PENDING".equalsIgnoreCase(status) || "PAYMENT_SUCCESSFUL".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status)) { %>
        <a href="<%= request.getContextPath() %>/documents/grn.pdf?poId=<%= poId %>" class="btn btn-outline-success btn-sm mb-1" target="_blank" title="Download GRN"><i class="fas fa-file-pdf"></i> GRN</a>
    <% } %>
    
    <% if ("PAYMENT_PENDING".equalsIgnoreCase(status) || "PAYMENT_SUCCESSFUL".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status)) { %>
        <a href="<%= request.getContextPath() %>/documents/invoice.pdf?poId=<%= poId %>" class="btn btn-outline-danger btn-sm mb-1" target="_blank" title="Download Invoice"><i class="fas fa-file-pdf"></i> INV</a>
    <% } %>
</td>

                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="10" class="text-center py-5" style="color:var(--sp-muted);">
                                <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.5;"></i>
                                <h5 style="font-weight:600;">No purchase orders found</h5>
                                <p>You have not received any purchase orders yet.</p>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

</div><!-- /sp-main -->

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // --- Sidebar Toggle ---
        const spSidebar = document.getElementById('spSidebar');
        const spSidebarToggle = document.getElementById('spSidebarToggle');
        if (spSidebarToggle) {
            spSidebarToggle.addEventListener('click', () => {
                spSidebar.classList.toggle('collapsed');
                document.body.classList.toggle('sidebar-collapsed', spSidebar.classList.contains('collapsed'));
            });
        }

        document.querySelectorAll('.js-open-ship-modal').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.getElementById('shipPoId').value = btn.getAttribute('data-po-id');
                document.getElementById('shipAsn').value = '';
                document.getElementById('shipCarrier').value = '';
                document.getElementById('shipTracking').value = '';
                $('#shipModal').modal('show');
            });
        });
        document.querySelectorAll('.js-open-invoice-modal').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.getElementById('invPoId').value = btn.getAttribute('data-po-id');
                document.getElementById('invPrice').value = btn.getAttribute('data-amount');
                document.getElementById('invQty').value = btn.getAttribute('data-qty');
                document.getElementById('invNumber').value = '';
                $('#invoiceModal').modal('show');
            });
        });
    });
</script>

<!-- Shipping details modal -->
<div class="modal fade" id="shipModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <form method="post" action="<%= request.getContextPath() %>/shipments/ship">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title text-dark"><i class="fas fa-truck mr-2"></i>Shipping Details (ASN)</h5>
                    <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="poId" id="shipPoId" />
                    <div class="form-group">
                        <label>ASN Number</label>
                        <input type="text" class="form-control" name="asnNumber" id="shipAsn" required placeholder="e.g. ASN-2026-001" />
                    </div>
                    <div class="form-group">
                        <label>Carrier</label>
                        <input type="text" class="form-control" name="carrier" id="shipCarrier" required placeholder="e.g. BlueDart / DHL" />
                    </div>
                    <div class="form-group mb-0">
                        <label>Tracking Number</label>
                        <input type="text" class="form-control" name="trackingNumber" id="shipTracking" required placeholder="Tracking / AWB number" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning text-dark font-weight-bold"><i class="fas fa-shipping-fast mr-1"></i> SHIP</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Invoice upload modal -->
<div class="modal fade" id="invoiceModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <form method="post" action="<%= request.getContextPath() %>/invoices/upload">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="fas fa-file-invoice mr-2"></i>Commercial Invoice</h5>
                    <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="poId" id="invPoId" />
                    <p class="small text-muted mb-3">Invoice quantity must match the PO ordered quantity and warehouse received quantity for three-way match.</p>
                    <div class="form-group">
                        <label>Invoice Number</label>
                        <input type="text" class="form-control" name="invoiceNumber" id="invNumber" required />
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label>Invoice Price (excl. GST)</label>
                            <input type="number" class="form-control" name="invoicePrice" id="invPrice" step="0.01" required />
                        </div>
                        <div class="form-group col-md-6">
                            <label>Invoice Quantity</label>
                            <input type="number" class="form-control" name="invoiceQuantity" id="invQty" min="1" required />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger"><i class="fas fa-upload mr-1"></i> Upload Invoice</button>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>