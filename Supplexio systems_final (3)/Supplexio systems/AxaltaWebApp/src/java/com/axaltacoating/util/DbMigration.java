package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.SQLException;

public class DbMigration {
    public static void main(String[] args) {
        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement()) {

            // Add columns to existing tables (ignoring errors if they already exist)
            try {
                stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN winning_supplier_id BIGINT NULL");
            } catch (Exception e) {
                System.out.println("Col might exist");
            }
            try {
                stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN created_by_email VARCHAR(255) NULL");
            } catch (Exception e) {
                System.out.println("Col might exist");
            }
            try {
                stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN required_quantity INT DEFAULT 1");
            } catch (Exception e) {
                System.out.println("Col might exist");
            }

            try {
                stmt.executeUpdate("ALTER TABLE bids ADD COLUMN supplier_id BIGINT NULL");
            } catch (Exception e) {
                System.out.println("Col might exist");
            }
            try {
                stmt.executeUpdate("UPDATE bids SET supplier_id = user_id WHERE supplier_id IS NULL");
            } catch (Exception e) {
                System.out.println("Col might exist");
            }

            // Create new tables
            stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS purchase_orders (" +
                            "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                            "po_number VARCHAR(100), " +
                            "auction_id BIGINT NOT NULL, " +
                            "product_id BIGINT NOT NULL, " +
                            "product_name VARCHAR(255), " +
                            "supplier_id BIGINT NOT NULL, " +
                            "supplier_name VARCHAR(255), " +
                            "company_name VARCHAR(255), " +
                            "material VARCHAR(255), " +
                            "amount DECIMAL(15,2), " +
                            "quantity INT, " +
                            "unit_price DECIMAL(15,2), " +
                            "total_amount DECIMAL(15,2), " +
                            "tax_amount DECIMAL(15,2), " +
                            "grand_total DECIMAL(15,2), " +
                            "supplier_email VARCHAR(255), " +
                            "supplier_address TEXT, " +
                            "status VARCHAR(50), " +
                            "quality_terms TEXT, " +
                            "buyer_email VARCHAR(255), " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "po_sent_at TIMESTAMP NULL, " +
                            "accepted_at TIMESTAMP NULL, " +
                            "shipped_at TIMESTAMP NULL, " +
                            "delivered_at TIMESTAMP NULL, " +
                            "invoice_requested_at TIMESTAMP NULL, " +
                            "payment_due_date DATE NULL, " +
                            "paid_at TIMESTAMP NULL, " +
                            "closed_at TIMESTAMP NULL, " +
                            "updated_at TIMESTAMP NULL)");

            // Add new columns to purchase_orders if they don't exist
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN po_sent_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN accepted_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN shipped_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN delivered_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN invoice_requested_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN payment_due_date DATE NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN paid_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN closed_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }

            stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS goods_receipts (" +
                            "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                            "po_id BIGINT NOT NULL, " +
                            "grn_number VARCHAR(100), " +
                            "asn_number VARCHAR(100), " +
                            "shipping_carrier VARCHAR(100), " +
                            "tracking_number VARCHAR(100), " +
                            "shipped_at TIMESTAMP NULL, " +
                            "delivered_at TIMESTAMP NULL, " +
                            "received_quantity INT, " +
                            "warehouse_location VARCHAR(255), " +
                            "received_by VARCHAR(255), " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS commercial_invoices (" +
                            "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                            "po_id BIGINT NOT NULL, " +
                            "invoice_number VARCHAR(100), " +
                            "invoice_date DATE, " +
                            "invoice_price DECIMAL(15,2), " +
                            "invoice_quantity INT, " +
                            "gst_rate DECIMAL(5,2), " +
                            "gst_amount DECIMAL(15,2), " +
                            "total_amount DECIMAL(15,2), " +
                            "status VARCHAR(50), " +
                            "due_date DATE, " +
                            "payment_unlocked_at TIMESTAMP NULL, " +
                            "paid_at TIMESTAMP NULL, " +
                            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Add new columns to commercial_invoices if they don't exist
            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN due_date DATE"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN payment_unlocked_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN paid_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }

            TradeCreditSchemaMigration.migrate(conn);

            System.out.println("Database migration completed successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
