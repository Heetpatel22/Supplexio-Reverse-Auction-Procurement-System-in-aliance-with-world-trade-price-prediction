package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles automatic inventory replenishment and Kanban status updates
 * upon reverse auction completion and PO award.
 */
public class InventoryReplenisher {
    private static final Logger LOGGER = Logger.getLogger(InventoryReplenisher.class.getName());

    /**
     * Auto-replenishes inventory when an auction completes or is awarded.
     * Idempotent: checks stock_replenished column to prevent duplicate additions.
     *
     * @param conn Open database connection
     * @param auctionId Reverse auction ID
     * @return true if inventory was replenished, false if already replenished or skipped
     */
    public static boolean replenishFromAuction(Connection conn, long auctionId) {
        if (conn == null || auctionId <= 0) {
            return false;
        }

        try {
            ensureStockReplenishedColumn(conn);

            long productId = 0;
            int requiredQuantity = 0;
            boolean alreadyReplenished = false;

            String checkSql = "SELECT product_id, required_quantity, stock_replenished FROM reverse_auctions WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
                stmt.setLong(1, auctionId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getLong("product_id");
                        requiredQuantity = rs.getInt("required_quantity");
                        alreadyReplenished = rs.getBoolean("stock_replenished");
                    } else {
                        LOGGER.warning("Auction " + auctionId + " not found for replenishment.");
                        return false;
                    }
                }
            }

            if (alreadyReplenished) {
                LOGGER.info("Auction " + auctionId + " was already replenished into inventory. Skipping duplicate.");
                return false;
            }

            if (productId <= 0 || requiredQuantity <= 0) {
                LOGGER.warning("Auction " + auctionId + " has invalid productId (" + productId + ") or requiredQuantity (" + requiredQuantity + ").");
                return false;
            }

            // Mark auction as replenished to guarantee idempotency
            try (PreparedStatement stmt = conn.prepareStatement("UPDATE reverse_auctions SET stock_replenished = 1 WHERE id = ?")) {
                stmt.setLong(1, auctionId);
                stmt.executeUpdate();
            }

            // Find product and linked inventory
            Long inventoryId = null;
            String productName = "Item";
            try (PreparedStatement stmt = conn.prepareStatement("SELECT name, inventory_id FROM products WHERE id = ?")) {
                stmt.setLong(1, productId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        productName = rs.getString("name");
                        long invId = rs.getLong("inventory_id");
                        if (!rs.wasNull() && invId > 0) {
                            inventoryId = invId;
                        }
                    }
                }
            }

            if (inventoryId != null && inventoryId > 0) {
                // Update existing inventory item
                String updateInvSql =
                    "UPDATE inventory SET " +
                    "quantity = quantity + ?, " +
                    "kanban_status = CASE " +
                    "    WHEN (quantity + ?) <= min_threshold THEN 'Low' " +
                    "    WHEN (quantity + ?) >= max_threshold THEN 'High' " +
                    "    ELSE 'Medium' " +
                    "END, " +
                    "needs_auction = ((quantity + ?) <= min_threshold), " +
                    "auction_started = FALSE, " +
                    "updated_at = NOW() " +
                    "WHERE id = ?";

                try (PreparedStatement stmt = conn.prepareStatement(updateInvSql)) {
                    stmt.setInt(1, requiredQuantity);
                    stmt.setInt(2, requiredQuantity);
                    stmt.setInt(3, requiredQuantity);
                    stmt.setInt(4, requiredQuantity);
                    stmt.setLong(5, inventoryId);
                    int affected = stmt.executeUpdate();
                    if (affected > 0) {
                        LOGGER.info("Auto-replenished inventory item #" + inventoryId + " (" + productName + ") with +" + requiredQuantity + " units from auction #" + auctionId);
                    }
                }

                // Synchronize product stock_quantity
                try (PreparedStatement stmt = conn.prepareStatement("UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?")) {
                    stmt.setInt(1, requiredQuantity);
                    stmt.setLong(2, productId);
                    stmt.executeUpdate();
                }
            } else {
                // Create new inventory item if none existed for this product
                int minThreshold = 20;
                int maxThreshold = Math.max(requiredQuantity * 2, 100);
                String kanbanStatus = (requiredQuantity <= minThreshold) ? "Low" : (requiredQuantity >= maxThreshold ? "High" : "Medium");
                boolean needsAuction = (requiredQuantity <= minThreshold);

                String insertInvSql =
                    "INSERT INTO inventory (item_name, quantity, min_threshold, max_threshold, kanban_status, needs_auction, auction_started, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, FALSE, NOW(), NOW())";

                long newInvId = 0;
                try (PreparedStatement stmt = conn.prepareStatement(insertInvSql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, productName);
                    stmt.setInt(2, requiredQuantity);
                    stmt.setInt(3, minThreshold);
                    stmt.setInt(4, maxThreshold);
                    stmt.setString(5, kanbanStatus);
                    stmt.setBoolean(6, needsAuction);
                    stmt.executeUpdate();

                    try (ResultSet gk = stmt.getGeneratedKeys()) {
                        if (gk.next()) {
                            newInvId = gk.getLong(1);
                        }
                    }
                }

                if (newInvId > 0) {
                    try (PreparedStatement stmt = conn.prepareStatement("UPDATE products SET inventory_id = ?, stock_quantity = ? WHERE id = ?")) {
                        stmt.setLong(1, newInvId);
                        stmt.setInt(2, requiredQuantity);
                        stmt.setLong(3, productId);
                        stmt.executeUpdate();
                    }
                    LOGGER.info("Created new inventory item #" + newInvId + " (" + productName + ") with stock +" + requiredQuantity + " from auction #" + auctionId);
                }
            }

            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in replenishFromAuction for auction " + auctionId, e);
            return false;
        }
    }

    private static void ensureStockReplenishedColumn(Connection conn) {
        try {
            boolean hasCol = false;
            try (PreparedStatement stmt = conn.prepareStatement("SHOW COLUMNS FROM reverse_auctions LIKE 'stock_replenished'")) {
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        hasCol = true;
                    }
                }
            }
            if (!hasCol) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN stock_replenished TINYINT(1) DEFAULT 0");
                }
            }
        } catch (SQLException ignored) {
        }
    }
}

