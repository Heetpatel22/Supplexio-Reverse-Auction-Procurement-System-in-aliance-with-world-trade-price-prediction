package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Upgrades legacy purchase_orders / payments schema for the 11-state trade-credit workflow.
 */
public final class TradeCreditSchemaMigration {
    private static final Logger LOGGER = Logger.getLogger(TradeCreditSchemaMigration.class.getName());

    private TradeCreditSchemaMigration() {
    }

    public static void migrate(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            addColumn(stmt, "purchase_orders", "po_number", "VARCHAR(100) NULL");
            addColumn(stmt, "purchase_orders", "product_id", "BIGINT NULL");
            addColumn(stmt, "purchase_orders", "product_name", "VARCHAR(255) NULL");
            addColumn(stmt, "purchase_orders", "supplier_name", "VARCHAR(255) NULL");
            addColumn(stmt, "purchase_orders", "quantity", "INT NULL");
            addColumn(stmt, "purchase_orders", "unit_price", "DECIMAL(15,2) NULL");
            addColumn(stmt, "purchase_orders", "total_amount", "DECIMAL(15,2) NULL");
            addColumn(stmt, "purchase_orders", "tax_amount", "DECIMAL(15,2) NULL");
            addColumn(stmt, "purchase_orders", "grand_total", "DECIMAL(15,2) NULL");
            addColumn(stmt, "purchase_orders", "supplier_email", "VARCHAR(255) NULL");
            addColumn(stmt, "purchase_orders", "supplier_address", "TEXT NULL");
            addColumn(stmt, "purchase_orders", "quality_terms", "TEXT NULL");
            addColumn(stmt, "purchase_orders", "buyer_email", "VARCHAR(255) NULL");
            addColumn(stmt, "purchase_orders", "po_sent_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "accepted_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "shipped_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "delivered_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "invoice_requested_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "payment_due_date", "DATE NULL");
            addColumn(stmt, "purchase_orders", "paid_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "closed_at", "TIMESTAMP NULL");
            addColumn(stmt, "purchase_orders", "updated_at", "TIMESTAMP NULL");

            try {
                stmt.executeUpdate("ALTER TABLE purchase_orders MODIFY COLUMN status VARCHAR(50) NULL");
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "purchase_orders.status widen skipped: {0}", e.getMessage());
            }

            stmt.executeUpdate(
                    "UPDATE purchase_orders SET status = 'PO_DRAFT' "
                    + "WHERE UPPER(COALESCE(status, '')) IN ('PENDING', 'COMPLETED')");
            stmt.executeUpdate(
                    "UPDATE purchase_orders SET status = 'PO_SENT' "
                    + "WHERE UPPER(COALESCE(status, '')) = 'SENT'");
            stmt.executeUpdate(
                    "UPDATE purchase_orders SET status = 'PAYMENT_SUCCESSFUL' "
                    + "WHERE UPPER(COALESCE(status, '')) = 'PAID'");

            addColumn(stmt, "payments", "po_id", "BIGINT NULL");
            addColumn(stmt, "payments", "invoice_id", "BIGINT NULL");
            addColumn(stmt, "payments", "auction_id", "BIGINT NULL");
            addColumn(stmt, "payments", "supplier_id", "BIGINT NULL");
            addColumn(stmt, "payments", "amount", "DECIMAL(15,2) NULL");
            addColumn(stmt, "payments", "status", "VARCHAR(50) NULL");
            addColumn(stmt, "payments", "payment_method", "VARCHAR(50) NULL");
            addColumn(stmt, "payments", "transaction_id", "VARCHAR(100) NULL");
            addColumn(stmt, "payments", "payment_date", "TIMESTAMP NULL");
            addColumn(stmt, "payments", "created_at", "TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP");
            addColumn(stmt, "payments", "remarks", "TEXT NULL");
            try {
                stmt.executeUpdate("ALTER TABLE payments MODIFY COLUMN auction_id BIGINT NULL");
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "payments.auction_id nullable skipped: {0}", e.getMessage());
            }
            try {
                stmt.executeUpdate("ALTER TABLE payments MODIFY COLUMN supplier_id BIGINT NULL");
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "payments.supplier_id nullable skipped: {0}", e.getMessage());
            }

            LOGGER.info("Trade credit schema migration applied");
        }
    }

    private static void addColumn(Statement stmt, String table, String column, String definition)
            throws SQLException {
        try {
            stmt.executeUpdate("ALTER TABLE " + table + " ADD COLUMN " + column + " " + definition);
        } catch (SQLException e) {
            String message = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (!message.contains("duplicate") && !message.contains("exists")) {
                throw e;
            }
        }
    }
}
