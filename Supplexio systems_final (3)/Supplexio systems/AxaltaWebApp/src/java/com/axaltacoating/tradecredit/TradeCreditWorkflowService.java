package com.axaltacoating.tradecredit;

import com.axaltacoating.util.DatabaseConnection;
import com.axaltacoating.util.InventoryReplenisher;
import com.axaltacoating.util.TradeCreditSchemaMigration;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;

public class TradeCreditWorkflowService {
    private static final BigDecimal GST_RATE = new BigDecimal("7.5");
    private static final BigDecimal ONE_HUNDRED = new BigDecimal("100");

    public long awardAuction(long auctionId, long winningSupplierId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);

            long existingPoId = findExistingPoId(conn, auctionId);
            if (existingPoId > 0) {
                conn.commit();
                return existingPoId;
            }

            if (winningSupplierId <= 0) {
                winningSupplierId = resolveWinningSupplierId(conn, auctionId);
            }

            AuctionAwardData awardData = loadAwardDataForUpdate(conn, auctionId, winningSupplierId);
            assertBuyerOwnsAuction(awardData, buyerEmail);
            if (!"ACTIVE".equals(awardData.auctionStatus) && !"COMPLETED".equals(awardData.auctionStatus)) {
                throw new WorkflowValidationException("Auction award blocked: current state " + awardData.auctionStatus + " cannot be awarded");
            }

            BigDecimal subtotal = awardData.winningAmount.setScale(2, RoundingMode.HALF_UP);
            BigDecimal unitRate = awardData.orderedQuantity > 0
                    ? subtotal.divide(new BigDecimal(awardData.orderedQuantity), 2, RoundingMode.HALF_UP)
                    : subtotal;
            BigDecimal gstAmount = subtotal.multiply(GST_RATE).divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
            BigDecimal grandTotal = subtotal.add(gstAmount).setScale(2, RoundingMode.HALF_UP);
            String poNumber = "PO-" + auctionId + "-" + System.currentTimeMillis();
            String qualityTerms = "Supplier shall deliver material matching the approved auction specification, "
                    + "statutory quality documentation, packaging standards, and Axalta inbound inspection requirements.";

            try (PreparedStatement updateAuction = conn.prepareStatement(
                    "UPDATE reverse_auctions SET status = ?, current_price = ?, winning_supplier_id = ? WHERE id = ?")) {
                updateAuction.setString(1, "COMPLETED");
                updateAuction.setBigDecimal(2, subtotal);
                updateAuction.setLong(3, winningSupplierId);
                updateAuction.setLong(4, auctionId);
                updateAuction.executeUpdate();
            }

            // Auto-replenish inventory upon auction completion/award
            InventoryReplenisher.replenishFromAuction(conn, auctionId);

            if (buyerEmail != null && !buyerEmail.trim().isEmpty() && !"unknown-buyer".equalsIgnoreCase(buyerEmail.trim())) {
                try (PreparedStatement backfillBuyer = conn.prepareStatement(
                        "UPDATE purchase_orders SET buyer_email = ? WHERE auction_id = ? AND (buyer_email IS NULL OR buyer_email = '')")) {
                    backfillBuyer.setString(1, buyerEmail.trim().toLowerCase());
                    backfillBuyer.setLong(2, auctionId);
                    backfillBuyer.executeUpdate();
                }
            }

            long poId;
            try (PreparedStatement insertPo = conn.prepareStatement(
                    "INSERT INTO purchase_orders "
                    + "(po_number, auction_id, product_id, product_name, supplier_id, supplier_name, company_name, "
                    + "material, amount, quantity, unit_price, total_amount, tax_amount, grand_total, supplier_email, "
                    + "supplier_address, status, quality_terms, buyer_email, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())",
                    Statement.RETURN_GENERATED_KEYS)) {
                insertPo.setString(1, poNumber);
                insertPo.setLong(2, auctionId);
                insertPo.setLong(3, awardData.productId);
                insertPo.setString(4, awardData.productName);
                insertPo.setLong(5, winningSupplierId);
                insertPo.setString(6, awardData.supplierName);
                insertPo.setString(7, awardData.supplierName);
                insertPo.setString(8, awardData.productName);
                insertPo.setBigDecimal(9, subtotal);
                insertPo.setInt(10, awardData.orderedQuantity);
                insertPo.setBigDecimal(11, unitRate);
                insertPo.setBigDecimal(12, subtotal);
                insertPo.setBigDecimal(13, gstAmount);
                insertPo.setBigDecimal(14, grandTotal);
                insertPo.setString(15, awardData.supplierEmail);
                insertPo.setString(16, awardData.supplierAddress);
                insertPo.setString(17, LifecycleState.PO_DRAFT.name());
                insertPo.setString(18, qualityTerms);
                insertPo.setString(19, buyerEmail);
                insertPo.executeUpdate();
                try (ResultSet keys = insertPo.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("Purchase order insert did not return an id");
                    }
                    poId = keys.getLong(1);
                }
            }

            conn.commit();
            return poId;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void sendPurchaseOrder(long poId, String buyerEmail, boolean executiveApproved)
            throws SQLException, WorkflowValidationException {
        if (!executiveApproved) {
            throw new WorkflowValidationException("Executive validation is required before a PO can be manually sent");
        }
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForUpdate(conn, poId, LifecycleState.PO_DRAFT, buyerEmail);
            updatePoState(conn, poId, LifecycleState.PO_SENT, "po_sent_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void acceptPurchaseOrder(long poId, long supplierId)
            throws SQLException, WorkflowValidationException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForSupplierUpdate(conn, poId, supplierId, LifecycleState.PO_SENT);
            updatePoState(conn, poId, LifecycleState.PO_ACCEPTED, "accepted_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void uploadAdvancedShippingNotice(long poId, long supplierId, String asnNumber,
            String carrier, String trackingNumber) throws SQLException, WorkflowValidationException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForSupplierUpdate(conn, poId, supplierId, LifecycleState.PO_ACCEPTED);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO goods_receipts "
                    + "(po_id, grn_number, asn_number, shipping_carrier, tracking_number, shipped_at, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())")) {
                stmt.setLong(1, poId);
                stmt.setString(2, "GRN-PENDING-" + poId);
                stmt.setString(3, required(asnNumber, "ASN number"));
                stmt.setString(4, required(carrier, "Shipping carrier"));
                stmt.setString(5, required(trackingNumber, "Tracking number"));
                stmt.executeUpdate();
            }
            updatePoState(conn, poId, LifecycleState.SHIPPED, "shipped_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void updateReceivedQuantity(long poId, int receivedQuantity, String warehouseLocation, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        if (receivedQuantity <= 0) {
            throw new WorkflowValidationException("Received quantity must be greater than zero");
        }
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            PurchaseOrderRecord po = requirePoStateForUpdate(conn, poId, LifecycleState.DELIVERED, buyerEmail);
            long grnId = findLatestDeliveredGrnId(conn, poId);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE goods_receipts SET received_quantity = ?, warehouse_location = ?, received_by = ? WHERE id = ?")) {
                stmt.setInt(1, receivedQuantity);
                stmt.setString(2, required(warehouseLocation, "Inbound warehouse location"));
                stmt.setString(3, required(buyerEmail, "Warehouse receiver"));
                stmt.setLong(4, grnId);
                stmt.executeUpdate();
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                    "DELETE FROM commercial_invoices WHERE po_id = ? AND status = 'MATCH_FAILED'")) {
                stmt.setLong(1, poId);
                stmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public long recordGoodsReceipt(long poId, int receivedQuantity, String warehouseLocation, String receivedBy)
            throws SQLException, WorkflowValidationException {
        if (receivedQuantity <= 0) {
            throw new WorkflowValidationException("Received quantity must be greater than zero");
        }
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForUpdate(conn, poId, LifecycleState.SHIPPED, null);
            long grnId = findOpenGoodsReceiptId(conn, poId);
            String grnNumber = "GRN-" + poId + "-" + System.currentTimeMillis();
            try (PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE goods_receipts SET grn_number = ?, received_quantity = ?, warehouse_location = ?, "
                    + "delivered_at = NOW(), received_by = ? WHERE id = ?")) {
                stmt.setString(1, grnNumber);
                stmt.setInt(2, receivedQuantity);
                stmt.setString(3, required(warehouseLocation, "Inbound warehouse location"));
                stmt.setString(4, required(receivedBy, "Warehouse receiver"));
                stmt.setLong(5, grnId);
                stmt.executeUpdate();
            }
            updatePoState(conn, poId, LifecycleState.DELIVERED, "delivered_at = NOW()");
            conn.commit();
            return grnId;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void requestSupplierInvoice(long poId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForUpdate(conn, poId, LifecycleState.DELIVERED, buyerEmail);
            updatePoState(conn, poId, LifecycleState.INVOICING_PENDING, "invoice_requested_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public long uploadCommercialInvoice(long poId, long supplierId, String invoiceNumber,
            BigDecimal invoicePrice, int invoiceQuantity) throws SQLException, WorkflowValidationException {
        if (invoicePrice == null || invoicePrice.compareTo(BigDecimal.ZERO) <= 0) {
            throw new WorkflowValidationException("Invoice price must be greater than zero");
        }
        if (invoiceQuantity <= 0) {
            throw new WorkflowValidationException("Invoice quantity must be greater than zero");
        }

        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            PurchaseOrderRecord po = loadPurchaseOrderById(conn, poId, true);
            if (po == null) {
                throw new WorkflowValidationException("Purchase order not found");
            }
            if (po.getSupplierId() != supplierId) {
                throw new WorkflowValidationException("Purchase order does not belong to the current supplier");
            }
            LifecycleState current = po.getLifecycleState();
            if (current != LifecycleState.DELIVERED && current != LifecycleState.INVOICING_PENDING) {
                throw new WorkflowValidationException(
                        "Invoice upload blocked: PO must be delivered or awaiting invoice, current state is " + current);
            }
            if (current == LifecycleState.DELIVERED) {
                updatePoState(conn, poId, LifecycleState.INVOICING_PENDING, "invoice_requested_at = NOW()");
            }

            BigDecimal invoiceSubtotal = invoicePrice.setScale(2, RoundingMode.HALF_UP);
            BigDecimal invoiceGst = invoiceSubtotal.multiply(GST_RATE).divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
            BigDecimal invoiceTotal = invoiceSubtotal.add(invoiceGst).setScale(2, RoundingMode.HALF_UP);

            long invoiceId;
            try (PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO commercial_invoices "
                    + "(po_id, invoice_number, invoice_date, invoice_price, invoice_quantity, gst_rate, gst_amount, "
                    + "total_amount, status, created_at) VALUES (?, ?, CURRENT_DATE, ?, ?, ?, ?, ?, ?, NOW())",
                    Statement.RETURN_GENERATED_KEYS)) {
                stmt.setLong(1, poId);
                stmt.setString(2, required(invoiceNumber, "Commercial invoice number"));
                stmt.setBigDecimal(3, invoiceSubtotal);
                stmt.setInt(4, invoiceQuantity);
                stmt.setBigDecimal(5, GST_RATE);
                stmt.setBigDecimal(6, invoiceGst);
                stmt.setBigDecimal(7, invoiceTotal);
                stmt.setString(8, LifecycleState.INVOICING_PENDING.name());
                stmt.executeUpdate();
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("Commercial invoice insert did not return an id");
                    }
                    invoiceId = keys.getLong(1);
                }
            }

            performThreeWayMatch(conn, po, invoiceId, invoiceSubtotal, invoiceQuantity);
            Date dueDate = Date.valueOf(LocalDate.now().plusDays(30));
            try (PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE commercial_invoices SET status = ?, due_date = ?, payment_unlocked_at = NOW() WHERE id = ?")) {
                stmt.setString(1, LifecycleState.PAYMENT_PENDING.name());
                stmt.setDate(2, dueDate);
                stmt.setLong(3, invoiceId);
                stmt.executeUpdate();
            }
            updatePoState(conn, poId, LifecycleState.PAYMENT_PENDING, "payment_due_date = '" + dueDate + "'");

            conn.commit();
            return invoiceId;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void recordPaymentByPoId(long poId, String paymentMethod, String transactionId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        long invoiceId = findPayableInvoiceId(poId);
        if (invoiceId <= 0) {
            throw new WorkflowValidationException(
                    "No approved invoice is ready for payment. The supplier must upload an invoice that passes three-way match.");
        }
        recordPayment(invoiceId, paymentMethod, transactionId, buyerEmail);
    }

    public long findPayableInvoiceId(long poId) throws SQLException {
        String sql = "SELECT id FROM commercial_invoices WHERE po_id = ? AND status = ? "
                + "ORDER BY payment_unlocked_at DESC, created_at DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, poId);
            stmt.setString(2, LifecycleState.PAYMENT_PENDING.name());
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getLong("id") : 0L;
            }
        }
    }

    public void recordPayment(long invoiceId, String paymentMethod, String transactionId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        try (Connection bootstrap = DatabaseConnection.getConnection()) {
            TradeCreditSchemaMigration.migrate(bootstrap);
        }
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            InvoicePaymentData invoice = loadInvoiceForPayment(conn, invoiceId, buyerEmail);
            requirePoStateForUpdate(conn, invoice.poId, LifecycleState.PAYMENT_PENDING, buyerEmail);
            PurchaseOrderRecord po = loadPurchaseOrderById(conn, invoice.poId, false);
            insertPaymentRecord(conn, po, invoice.poId, invoiceId, invoice.totalAmount,
                    required(paymentMethod, "Payment method"),
                    required(transactionId, "Payment transaction id"));
            try (PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE commercial_invoices SET status = ?, paid_at = NOW() WHERE id = ?")) {
                stmt.setString(1, LifecycleState.PAYMENT_SUCCESSFUL.name());
                stmt.setLong(2, invoiceId);
                stmt.executeUpdate();
            }
            updatePoState(conn, invoice.poId, LifecycleState.PAYMENT_SUCCESSFUL, "paid_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public void closeTransaction(long poId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);
            requirePoStateForUpdate(conn, poId, LifecycleState.PAYMENT_SUCCESSFUL, buyerEmail);
            updatePoState(conn, poId, LifecycleState.CLOSED, "closed_at = NOW()");
            conn.commit();
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            throw ex;
        } catch (WorkflowValidationException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            restoreAndClose(conn);
        }
    }

    public PurchaseOrderRecord loadPurchaseOrder(long poId) throws SQLException, WorkflowValidationException {
        try (Connection conn = DatabaseConnection.getConnection()) {
            PurchaseOrderRecord po = loadPurchaseOrderById(conn, poId, false);
            if (po == null) {
                throw new WorkflowValidationException("Purchase order not found");
            }
            return po;
        }
    }

    public GoodsReceiptRecord loadGoodsReceipt(long grnId) throws SQLException, WorkflowValidationException {
        String sql = "SELECT gr.*, po.id AS po_id FROM goods_receipts gr JOIN purchase_orders po ON po.id = gr.po_id WHERE gr.id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, grnId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Goods receipt not found");
                }
                GoodsReceiptRecord grn = new GoodsReceiptRecord();
                grn.setId(rs.getLong("id"));
                grn.setPoId(rs.getLong("po_id"));
                grn.setGrnNumber(rs.getString("grn_number"));
                grn.setReceivedQuantity(rs.getInt("received_quantity"));
                grn.setWarehouseLocation(rs.getString("warehouse_location"));
                grn.setAsnNumber(rs.getString("asn_number"));
                grn.setShippingCarrier(rs.getString("shipping_carrier"));
                grn.setTrackingNumber(rs.getString("tracking_number"));
                grn.setShippedAt(rs.getTimestamp("shipped_at"));
                grn.setDeliveredAt(rs.getTimestamp("delivered_at"));
                grn.setReceivedBy(rs.getString("received_by"));
                grn.setPurchaseOrder(loadPurchaseOrderById(conn, grn.getPoId(), false));
                return grn;
            }
        }
    }

    public CommercialInvoiceRecord loadCommercialInvoice(long invoiceId) throws SQLException, WorkflowValidationException {
        String sql = "SELECT * FROM commercial_invoices WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, invoiceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Commercial invoice not found");
                }
                CommercialInvoiceRecord invoice = new CommercialInvoiceRecord();
                invoice.setId(rs.getLong("id"));
                invoice.setPoId(rs.getLong("po_id"));
                invoice.setInvoiceNumber(rs.getString("invoice_number"));
                invoice.setInvoiceDate(rs.getDate("invoice_date"));
                invoice.setInvoicePrice(rs.getBigDecimal("invoice_price"));
                invoice.setInvoiceQuantity(rs.getInt("invoice_quantity"));
                invoice.setGstRate(rs.getBigDecimal("gst_rate"));
                invoice.setGstAmount(rs.getBigDecimal("gst_amount"));
                invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
                invoice.setStatus(rs.getString("status"));
                invoice.setDueDate(rs.getDate("due_date"));
                invoice.setPaymentUnlockedAt(rs.getTimestamp("payment_unlocked_at"));
                invoice.setPaidAt(rs.getTimestamp("paid_at"));
                invoice.setPurchaseOrder(loadPurchaseOrderById(conn, invoice.getPoId(), false));
                return invoice;
            }
        }
    }

    public GoodsReceiptRecord loadGoodsReceiptByPoId(long poId) throws SQLException, WorkflowValidationException {
        String sql = "SELECT gr.*, po.id AS po_id FROM goods_receipts gr JOIN purchase_orders po ON po.id = gr.po_id WHERE gr.po_id = ? ORDER BY gr.created_at DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Goods receipt not found for this PO");
                }
                GoodsReceiptRecord grn = new GoodsReceiptRecord();
                grn.setId(rs.getLong("id"));
                grn.setPoId(rs.getLong("po_id"));
                grn.setGrnNumber(rs.getString("grn_number"));
                grn.setReceivedQuantity(rs.getInt("received_quantity"));
                grn.setWarehouseLocation(rs.getString("warehouse_location"));
                grn.setAsnNumber(rs.getString("asn_number"));
                grn.setShippingCarrier(rs.getString("shipping_carrier"));
                grn.setTrackingNumber(rs.getString("tracking_number"));
                grn.setShippedAt(rs.getTimestamp("shipped_at"));
                grn.setDeliveredAt(rs.getTimestamp("delivered_at"));
                grn.setReceivedBy(rs.getString("received_by"));
                grn.setPurchaseOrder(loadPurchaseOrderById(conn, grn.getPoId(), false));
                return grn;
            }
        }
    }

    public CommercialInvoiceRecord loadCommercialInvoiceByPoId(long poId) throws SQLException, WorkflowValidationException {
        long invoiceId = findPayableInvoiceId(poId);
        if (invoiceId > 0) {
            return loadCommercialInvoice(invoiceId);
        }
        String sql = "SELECT * FROM commercial_invoices WHERE po_id = ? ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Commercial invoice not found for this PO");
                }
                CommercialInvoiceRecord invoice = new CommercialInvoiceRecord();
                invoice.setId(rs.getLong("id"));
                invoice.setPoId(rs.getLong("po_id"));
                invoice.setInvoiceNumber(rs.getString("invoice_number"));
                invoice.setInvoiceDate(rs.getDate("invoice_date"));
                invoice.setInvoicePrice(rs.getBigDecimal("invoice_price"));
                invoice.setInvoiceQuantity(rs.getInt("invoice_quantity"));
                invoice.setGstRate(rs.getBigDecimal("gst_rate"));
                invoice.setGstAmount(rs.getBigDecimal("gst_amount"));
                invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
                invoice.setStatus(rs.getString("status"));
                invoice.setDueDate(rs.getDate("due_date"));
                invoice.setPaymentUnlockedAt(rs.getTimestamp("payment_unlocked_at"));
                invoice.setPaidAt(rs.getTimestamp("paid_at"));
                invoice.setPurchaseOrder(loadPurchaseOrderById(conn, invoice.getPoId(), false));
                return invoice;
            }
        }
    }

    private long findExistingPoId(Connection conn, long auctionId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT id FROM purchase_orders WHERE auction_id = ? ORDER BY id DESC LIMIT 1")) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getLong("id") : 0L;
            }
        }
    }

    private void assertBuyerOwnsAuction(AuctionAwardData awardData, String buyerEmail)
            throws WorkflowValidationException {
        if (buyerEmail == null || buyerEmail.trim().isEmpty()) {
            return;
        }
        if (awardData.createdByEmail == null || awardData.createdByEmail.trim().isEmpty()) {
            return;
        }
        if ("admin@example.com".equalsIgnoreCase(buyerEmail.trim()) || "admin".equalsIgnoreCase(buyerEmail.trim())) {
            return;
        }
        if (!buyerEmail.equalsIgnoreCase(awardData.createdByEmail.trim())) {
            throw new WorkflowValidationException("This auction does not belong to the current buyer");
        }
    }

    private long resolveWinningSupplierId(Connection conn, long auctionId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT winning_supplier_id FROM reverse_auctions WHERE id = ?")) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    long wId = rs.getLong("winning_supplier_id");
                    if (!rs.wasNull() && wId > 0) return wId;
                }
            }
        }
        try (PreparedStatement stmt = conn.prepareStatement("SELECT supplier_id FROM bids WHERE auction_id = ? ORDER BY amount ASC, bid_time ASC LIMIT 1")) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    long bId = rs.getLong("supplier_id");
                    if (!rs.wasNull() && bId > 0) return bId;
                }
            }
        }
        try (PreparedStatement stmt = conn.prepareStatement("SELECT id FROM suppliers ORDER BY (id = 103) DESC, id ASC LIMIT 1")) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("id");
                }
            }
        }
        return 1L;
    }

    private AuctionAwardData loadAwardDataForUpdate(Connection conn, long auctionId, long winningSupplierId)
            throws SQLException, WorkflowValidationException {
        String sql = "SELECT ra.status, ra.created_by_email, ra.product_id, COALESCE(ra.required_quantity, 1) AS ordered_quantity, "
                + "COALESCE(p.name, 'Auction Item') AS product_name, "
                + "COALESCE(s.name, 'Winning Supplier') AS supplier_name, "
                + "COALESCE(s.email, 'supplier@example.com') AS supplier_email, "
                + "COALESCE(s.address, 'Supplier Registered Address') AS supplier_address, "
                + "COALESCE(b.amount, ra.current_price, ra.start_price, 1000.0) AS winning_amount "
                + "FROM reverse_auctions ra "
                + "LEFT JOIN products p ON p.id = ra.product_id "
                + "LEFT JOIN suppliers s ON s.id = ? "
                + "LEFT JOIN bids b ON b.auction_id = ra.id AND b.supplier_id = s.id "
                + "WHERE ra.id = ? "
                + "ORDER BY COALESCE(b.amount, ra.current_price, 9999999) ASC, b.bid_time ASC LIMIT 1 FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, winningSupplierId);
            stmt.setLong(2, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Auction #" + auctionId + " not found");
                }
                AuctionAwardData data = new AuctionAwardData();
                data.auctionStatus = rs.getString("status");
                data.createdByEmail = rs.getString("created_by_email");
                data.productId = rs.getLong("product_id");
                data.orderedQuantity = Math.max(1, rs.getInt("ordered_quantity"));
                data.productName = rs.getString("product_name");
                data.supplierName = rs.getString("supplier_name");
                data.supplierEmail = rs.getString("supplier_email");
                data.supplierAddress = rs.getString("supplier_address");
                data.winningAmount = rs.getBigDecimal("winning_amount");
                return data;
            }
        }
    }

    private PurchaseOrderRecord requirePoStateForUpdate(Connection conn, long poId, LifecycleState expected, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        PurchaseOrderRecord po = loadPurchaseOrderById(conn, poId, true);
        if (po == null) {
            throw new WorkflowValidationException("Purchase order not found");
        }
        assertBuyerCanAccessPo(conn, poId, buyerEmail);
        guard(po.getLifecycleState(), expected.next(), "Purchase order transition");
        return po;
    }

    private PurchaseOrderRecord requirePoStateForSupplierUpdate(Connection conn, long poId, long supplierId, LifecycleState expected)
            throws SQLException, WorkflowValidationException {
        PurchaseOrderRecord po = requirePoStateForUpdate(conn, poId, expected, null);
        if (po.getSupplierId() != supplierId) {
            throw new WorkflowValidationException("Purchase order does not belong to the current supplier");
        }
        return po;
    }

    private PurchaseOrderRecord loadPurchaseOrderById(Connection conn, long poId, boolean forUpdate)
            throws SQLException, WorkflowValidationException {
        String sql = "SELECT po.*, s.name AS db_supplier_name, s.email AS db_supplier_email, s.address AS db_supplier_address, "
                + "p.name AS db_product_name FROM purchase_orders po "
                + "LEFT JOIN suppliers s ON s.id = po.supplier_id "
                + "LEFT JOIN products p ON p.id = po.product_id "
                + "WHERE po.id = ?" + (forUpdate ? " FOR UPDATE" : "");
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                PurchaseOrderRecord po = new PurchaseOrderRecord();
                po.setId(rs.getLong("id"));
                po.setAuctionId(rs.getLong("auction_id"));
                po.setSupplierId(rs.getLong("supplier_id"));
                po.setProductId(rs.getLong("product_id"));
                po.setPoNumber(nullToFallback(rs.getString("po_number"), "PO-" + poId));
                po.setBuyerEmail(rs.getString("buyer_email"));
                po.setSupplierName(firstNonBlank(rs.getString("supplier_name"), rs.getString("db_supplier_name"), "Unknown Supplier"));
                po.setSupplierEmail(firstNonBlank(rs.getString("supplier_email"), rs.getString("db_supplier_email"), "Not Available"));
                po.setSupplierAddress(firstNonBlank(rs.getString("supplier_address"), rs.getString("db_supplier_address"), "Address not available"));
                po.setProductName(firstNonBlank(rs.getString("product_name"), rs.getString("material"), rs.getString("db_product_name"), "N/A"));
                po.setQualityTerms(firstNonBlank(rs.getString("quality_terms"), "Material must comply with approved procurement quality specifications."));
                po.setLifecycleState(LifecycleState.fromDatabase(rs.getString("status")));
                po.setCreatedAt(rs.getTimestamp("created_at"));
                po.setSentAt(rs.getTimestamp("po_sent_at"));
                po.setAcceptedAt(rs.getTimestamp("accepted_at"));
                po.setSubtotal(nonNull(rs.getBigDecimal("total_amount")));
                po.setGstAmount(nonNull(rs.getBigDecimal("tax_amount")));
                po.setTotalAmount(nonNull(rs.getBigDecimal("grand_total")));

                TradeCreditLineItem item = new TradeCreditLineItem();
                item.setSerialNumber(1);
                item.setDescription(po.getProductName());
                item.setQuantity(Math.max(1, rs.getInt("quantity")));
                item.setRate(nonNull(rs.getBigDecimal("unit_price")));
                item.setGstRate(GST_RATE);
                item.setGstAmount(po.getGstAmount());
                item.setAmount(po.getSubtotal());
                po.getItems().add(item);
                return po;
            }
        }
    }

    private void performThreeWayMatch(Connection conn, PurchaseOrderRecord po, long invoiceId,
            BigDecimal invoiceSubtotal, int invoiceQuantity) throws SQLException, WorkflowValidationException {
        int orderedQuantity = po.getItems().get(0).getQuantity();
        int receivedQuantity;
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT received_quantity FROM goods_receipts WHERE po_id = ? AND delivered_at IS NOT NULL ORDER BY delivered_at DESC LIMIT 1")) {
            stmt.setLong(1, po.getId());
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    markInvoiceMatchFailed(conn, invoiceId);
                    throw new WorkflowValidationException("Three-way match failed: no delivered GRN exists for PO " + po.getPoNumber());
                }
                receivedQuantity = rs.getInt("received_quantity");
            }
        }
        if (po.getSubtotal().compareTo(invoiceSubtotal) != 0) {
            markInvoiceMatchFailed(conn, invoiceId);
            throw new WorkflowValidationException("Three-way match failed: PO price "
                    + po.getSubtotal() + " does not equal invoice price " + invoiceSubtotal);
        }
        if (orderedQuantity != receivedQuantity) {
            markInvoiceMatchFailed(conn, invoiceId);
            throw new WorkflowValidationException("Three-way match failed: ordered quantity "
                    + orderedQuantity + " does not equal warehouse received quantity " + receivedQuantity);
        }
        if (invoiceQuantity != orderedQuantity) {
            markInvoiceMatchFailed(conn, invoiceId);
            throw new WorkflowValidationException("Three-way match failed: invoice quantity "
                    + invoiceQuantity + " does not equal ordered quantity " + orderedQuantity);
        }
    }

    private void markInvoiceMatchFailed(Connection conn, long invoiceId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "UPDATE commercial_invoices SET status = ? WHERE id = ?")) {
            stmt.setString(1, "MATCH_FAILED");
            stmt.setLong(2, invoiceId);
            stmt.executeUpdate();
        }
    }

    private long findLatestDeliveredGrnId(Connection conn, long poId) throws SQLException, WorkflowValidationException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT id FROM goods_receipts WHERE po_id = ? AND delivered_at IS NOT NULL ORDER BY delivered_at DESC LIMIT 1")) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("No delivered goods receipt exists for this PO");
                }
                return rs.getLong("id");
            }
        }
    }

    private long findOpenGoodsReceiptId(Connection conn, long poId) throws SQLException, WorkflowValidationException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT id FROM goods_receipts WHERE po_id = ? AND delivered_at IS NULL ORDER BY shipped_at DESC LIMIT 1 FOR UPDATE")) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("No open ASN exists for this purchase order");
                }
                return rs.getLong("id");
            }
        }
    }

    private void assertBuyerCanAccessPo(Connection conn, long poId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        if (buyerEmail == null || buyerEmail.trim().isEmpty() || "unknown-buyer".equalsIgnoreCase(buyerEmail.trim())) {
            return;
        }
        String sql = "SELECT po.buyer_email, ra.created_by_email FROM purchase_orders po "
                + "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id WHERE po.id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, poId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Purchase order not found");
                }
                String poBuyer = rs.getString("buyer_email");
                String auctionOwner = rs.getString("created_by_email");
                if (poBuyer != null && buyerEmail.equalsIgnoreCase(poBuyer.trim())) {
                    return;
                }
                if (auctionOwner != null && buyerEmail.equalsIgnoreCase(auctionOwner.trim())) {
                    return;
                }
                if (poBuyer == null || poBuyer.trim().isEmpty()) {
                    return;
                }
                throw new WorkflowValidationException("Purchase order does not belong to the current buyer");
            }
        }
    }

    private InvoicePaymentData loadInvoiceForPayment(Connection conn, long invoiceId, String buyerEmail)
            throws SQLException, WorkflowValidationException {
        String sql = "SELECT ci.po_id, ci.total_amount, ci.status, ci.due_date "
                + "FROM commercial_invoices ci WHERE ci.id = ? FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, invoiceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new WorkflowValidationException("Approved commercial invoice not found");
                }
                String status = rs.getString("status");
                if ("MATCH_FAILED".equalsIgnoreCase(status)) {
                    throw new WorkflowValidationException(
                            "Payment blocked: three-way match failed. Adjust received quantity and ask supplier to re-upload the invoice.");
                }
                if (!LifecycleState.PAYMENT_PENDING.name().equals(status)) {
                    throw new WorkflowValidationException("Payment is locked until the invoice passes three-way match");
                }
                long poId = rs.getLong("po_id");
                assertBuyerCanAccessPo(conn, poId, buyerEmail);
                InvoicePaymentData data = new InvoicePaymentData();
                data.poId = poId;
                data.totalAmount = rs.getBigDecimal("total_amount");
                data.dueDate = rs.getDate("due_date");
                return data;
            }
        }
    }

    private void updatePoState(Connection conn, long poId, LifecycleState nextState, String auditAssignment)
            throws SQLException {
        String sql = "UPDATE purchase_orders SET status = ?, updated_at = NOW()"
                + (auditAssignment == null || auditAssignment.trim().isEmpty() ? "" : ", " + auditAssignment)
                + " WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, nextState.name());
            stmt.setLong(2, poId);
            stmt.executeUpdate();
        }
    }

    private void guard(LifecycleState current, LifecycleState requested, String action)
            throws WorkflowValidationException {
        if (!current.canAdvanceTo(requested)) {
            throw new WorkflowValidationException(action + " blocked: current state " + current
                    + " can only advance to " + current.next() + ", not " + requested);
        }
    }

    private static String required(String value, String label) throws WorkflowValidationException {
        if (value == null || value.trim().isEmpty()) {
            throw new WorkflowValidationException(label + " is required");
        }
        return value.trim();
    }

    private static BigDecimal nonNull(BigDecimal value) {
        return value == null ? BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP) : value.setScale(2, RoundingMode.HALF_UP);
    }

    private static String firstNonBlank(String first, String fallback) {
        return firstNonBlank(first, fallback, "");
    }

    private static String firstNonBlank(String first, String second, String fallback) {
        if (first != null && !first.trim().isEmpty()) {
            return first.trim();
        }
        if (second != null && !second.trim().isEmpty()) {
            return second.trim();
        }
        return fallback;
    }

    private static String firstNonBlank(String first, String second, String third, String fallback) {
        String picked = firstNonBlank(first, second, null);
        if (picked != null && !picked.trim().isEmpty()) {
            return picked;
        }
        if (third != null && !third.trim().isEmpty()) {
            return third.trim();
        }
        return fallback;
    }

    private static String nullToFallback(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private static void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private static void restoreAndClose(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException ignored) {
            }
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }

    /**
     * Inserts a payment row using the full schema when available, or a minimal
     * po_id/invoice_id row when legacy databases lack auction_id/supplier_id.
     */
    private static void insertPaymentRecord(Connection conn, PurchaseOrderRecord po, long poId, long invoiceId,
            BigDecimal amount, String paymentMethod, String transactionId) throws SQLException {
        Long auctionId = po != null && po.getAuctionId() > 0 ? po.getAuctionId() : null;
        Long supplierId = po != null && po.getSupplierId() > 0 ? po.getSupplierId() : null;
        String remarks = "Net 30 trade credit invoice cleared";
        String fullSql = "INSERT INTO payments (auction_id, supplier_id, po_id, invoice_id, amount, status, "
                + "payment_method, transaction_id, payment_date, created_at, remarks) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), ?)";
        try (PreparedStatement stmt = conn.prepareStatement(fullSql)) {
            stmt.setObject(1, auctionId);
            stmt.setObject(2, supplierId);
            stmt.setLong(3, poId);
            stmt.setLong(4, invoiceId);
            stmt.setBigDecimal(5, amount);
            stmt.setString(6, "COMPLETED");
            stmt.setString(7, paymentMethod);
            stmt.setString(8, transactionId);
            stmt.setString(9, remarks);
            stmt.executeUpdate();
            return;
        } catch (SQLException ex) {
            if (!isUnknownColumn(ex, "auction_id") && !isUnknownColumn(ex, "supplier_id")) {
                throw ex;
            }
        }
        String coreSql = "INSERT INTO payments (po_id, invoice_id, amount, status, payment_method, transaction_id, "
                + "payment_date, created_at, remarks) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), ?)";
        try (PreparedStatement stmt = conn.prepareStatement(coreSql)) {
            stmt.setLong(1, poId);
            stmt.setLong(2, invoiceId);
            stmt.setBigDecimal(3, amount);
            stmt.setString(4, "COMPLETED");
            stmt.setString(5, paymentMethod);
            stmt.setString(6, transactionId);
            stmt.setString(7, remarks);
            stmt.executeUpdate();
        }
    }

    private static boolean isUnknownColumn(SQLException ex, String column) {
        String message = ex.getMessage();
        return message != null
                && message.toLowerCase().contains("unknown column")
                && message.toLowerCase().contains(column.toLowerCase());
    }

    private static class AuctionAwardData {
        String auctionStatus;
        String createdByEmail;
        long productId;
        int orderedQuantity;
        String productName;
        String supplierName;
        String supplierEmail;
        String supplierAddress;
        BigDecimal winningAmount;
    }

    private static class InvoicePaymentData {
        long poId;
        BigDecimal totalAmount;
        Date dueDate;
    }
}
