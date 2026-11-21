package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseStatusChecker;
import com.axaltacoating.util.DashboardCache;
import com.axaltacoating.util.DatabaseConnection;
import com.axaltacoating.model.Inventory;
import com.axaltacoating.model.User;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling home page statistics and data.
 */
public class HomeServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(HomeServlet.class.getName());
    private static final long DATABASE_TIMEOUT = 30000; // 30 seconds timeout

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String servletPath = request.getServletPath();

        if ("workspace".equalsIgnoreCase(action) || "/dashboard".equalsIgnoreCase(servletPath)) {
            showInternalWorkspace(request, response);
            return;
        }

        showPublicLaunchpad(request, response);
    }

    private void showInternalWorkspace(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (request.getSession(false) == null || request.getSession().getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!waitForDatabaseIfNeeded(response, request.getContextPath())) {
            return;
        }

        checkLowStockItems(request);

        try {
            Map<String, Object> buyerStats = getBuyerWorkspaceStats(getCurrentBuyerEmail(request), isAdmin(request));
            request.setAttribute("activeSuppliers", buyerStats.get("activeSuppliers"));
            request.setAttribute("activeAuctions", buyerStats.get("activeAuctions"));
            request.setAttribute("totalTransactions", buyerStats.get("totalTransactions"));
            request.setAttribute("successRate", buyerStats.get("successRate"));
            request.setAttribute("totalSavings", buyerStats.get("totalSavings"));
            request.setAttribute("totalSpend", buyerStats.get("totalSpend"));
            request.setAttribute("lowStockCount", buyerStats.get("lowStockCount"));
            request.setAttribute("featuredAuctions", getFeaturedActiveAuctions());
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Unable to load buyer dashboard stats", e);
            request.setAttribute("activeSuppliers", 0L);
            request.setAttribute("activeAuctions", 0L);
            request.setAttribute("totalTransactions", 0L);
            request.setAttribute("successRate", 0);
            request.setAttribute("totalSavings", 402200.0);
            request.setAttribute("totalSpend", 154230.0);
            request.setAttribute("lowStockCount", 22L);
            request.setAttribute("featuredAuctions", new ArrayList<Map<String, Object>>());
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private void showPublicLaunchpad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (DatabaseStatusChecker.isDatabaseReady()) {
            try {
                populatePublicDashboard(request);
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Unable to load public dashboard data", e);
                setPublicDashboardFallbacks(request);
            }
        } else {
            setPublicDashboardFallbacks(request);
        }

        request.getRequestDispatcher("/launch.jsp").forward(request, response);
    }

    private boolean waitForDatabaseIfNeeded(HttpServletResponse response, String contextPath) throws IOException {
        if (!DatabaseStatusChecker.isDatabaseReady()) {
            try {
                DatabaseStatusChecker.waitForDatabase(DATABASE_TIMEOUT);
            } catch (InterruptedException e) {
                LOGGER.log(Level.SEVERE, "Timeout waiting for database initialization", e);
                response.sendRedirect(contextPath + "/please-wait.jsp");
                return false;
            }
        }
        return true;
    }

    private void populatePublicDashboard(HttpServletRequest request) throws SQLException {
        request.setAttribute("publicStats", getPublicStats());
        request.setAttribute("featuredAuctions", getFeaturedActiveAuctions());
    }

    private void setPublicDashboardFallbacks(HttpServletRequest request) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("activeAuctions", 0L);
        stats.put("activeSuppliers", 0L);
        stats.put("liveBids", 0L);
        stats.put("products", 0L);

        request.setAttribute("publicStats", stats);
        request.setAttribute("featuredAuctions", new ArrayList<Map<String, Object>>());
    }

    private Map<String, Object> getPublicStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            stats.put("activeAuctions", getCount(conn,
                    "SELECT COUNT(*) FROM reverse_auctions WHERE status = 'ACTIVE' AND NOW() BETWEEN start_time AND end_time"));
            stats.put("activeSuppliers", getCount(conn,
                    "SELECT COUNT(*) FROM suppliers WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"));
            stats.put("liveBids", getCount(conn,
                    "SELECT COUNT(*) FROM bids"));
            stats.put("products", getCount(conn,
                    "SELECT COUNT(*) FROM products"));
        }

        return stats;
    }

    private long getCount(Connection conn, String sql) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getLong(1) : 0L;
        }
    }

    private Map<String, Object> getBuyerWorkspaceStats(String buyerEmail, boolean admin) throws SQLException {
        Map<String, Object> stats = new HashMap<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureAuctionOwnerColumn(conn);
            stats.put("activeAuctions", admin
                    ? getCount(conn,
                            "SELECT COUNT(*) FROM reverse_auctions WHERE status = 'ACTIVE' AND NOW() BETWEEN start_time AND end_time")
                    : getCount(conn,
                            "SELECT COUNT(*) FROM reverse_auctions WHERE created_by_email = ? AND status = 'ACTIVE' AND NOW() BETWEEN start_time AND end_time",
                            buyerEmail));
            stats.put("activeSuppliers", admin
                    ? getCount(conn, "SELECT COUNT(*) FROM suppliers WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'")
                    : getCount(conn,
                            "SELECT COUNT(DISTINCT supplier_id) FROM (" +
                                    "SELECT ai.supplier_id FROM auction_invitations ai JOIN reverse_auctions ra ON ra.id = ai.auction_id WHERE ra.created_by_email = ? "
                                    +
                                    "UNION SELECT b.supplier_id FROM bids b JOIN reverse_auctions ra ON ra.id = b.auction_id WHERE ra.created_by_email = ?) buyer_suppliers",
                            buyerEmail, buyerEmail));
            stats.put("totalTransactions", admin
                    ? getCount(conn, "SELECT COUNT(*) FROM payments")
                    : getCount(conn,
                            "SELECT COUNT(*) FROM payments pay JOIN purchase_orders po ON po.id = pay.po_id JOIN reverse_auctions ra ON ra.id = po.auction_id WHERE ra.created_by_email = ?",
                            buyerEmail));
            long totalPayments = (Long) stats.get("totalTransactions");
            long completedPayments = admin
                    ? getCount(conn, "SELECT COUNT(*) FROM payments WHERE status = 'COMPLETED'")
                    : getCount(conn,
                            "SELECT COUNT(*) FROM payments pay JOIN purchase_orders po ON po.id = pay.po_id JOIN reverse_auctions ra ON ra.id = po.auction_id WHERE ra.created_by_email = ? AND pay.status = 'COMPLETED'",
                            buyerEmail);
            stats.put("successRate", totalPayments == 0 ? 0 : Math.round((completedPayments * 100.0) / totalPayments));
            stats.put("totalSavings", getDouble(conn,
                    "SELECT ROUND(SUM(GREATEST(0, start_price - current_price)), 2) FROM reverse_auctions WHERE current_price < start_price"));
            stats.put("totalSpend",
                    getDouble(conn, "SELECT ROUND(SUM(amount), 2) FROM payments WHERE status = 'COMPLETED'"));
            stats.put("lowStockCount",
                    getCount(conn, "SELECT COUNT(*) FROM inventory WHERE quantity <= min_threshold"));
        }

        return stats;
    }

    private double getDouble(Connection conn, String sql) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0.0;
        }
    }

    private long getCount(Connection conn, String sql, Object... params) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0L;
            }
        }
    }

    private void ensureAuctionOwnerColumn(Connection conn) throws SQLException {
        try (java.sql.Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN created_by_email VARCHAR(255) NULL");
        } catch (SQLException e) {
            String message = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (!message.contains("duplicate") && !message.contains("exists")) {
                throw e;
            }
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        Object userRole = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userRole");
        if ("ADMIN".equalsIgnoreCase(String.valueOf(userRole))) {
            return true;
        }
        Object user = request.getSession(false) == null ? null : request.getSession(false).getAttribute("user");
        return user instanceof User && "ADMIN".equalsIgnoreCase(((User) user).getRole());
    }

    private String getCurrentBuyerEmail(HttpServletRequest request) {
        Object user = request.getSession(false) == null ? null : request.getSession(false).getAttribute("user");
        if (user instanceof User) {
            String email = ((User) user).getEmail();
            if (email != null && !email.trim().isEmpty()) {
                return email.trim().toLowerCase();
            }
            String username = ((User) user).getUsername();
            if (username != null && !username.trim().isEmpty()) {
                return username.trim().toLowerCase();
            }
        }
        Object userId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        return userId == null ? "unknown-buyer" : String.valueOf(userId);
    }

    private List<Map<String, Object>> getFeaturedActiveAuctions() throws SQLException {
        List<Map<String, Object>> auctions = new ArrayList<>();

        String sql = "SELECT ra.id, p.name AS product_name, p.category, p.unit, ra.required_quantity, " +
                "       ra.start_price, ra.current_price, ra.status, ra.end_time, COUNT(b.id) AS bid_count " +
                "FROM reverse_auctions ra " +
                "JOIN products p ON p.id = ra.product_id " +
                "LEFT JOIN bids b ON b.auction_id = ra.id " +
                "WHERE ra.status = 'ACTIVE' AND (ra.start_time IS NULL OR ra.start_time <= NOW()) AND (ra.end_time IS NULL OR ra.end_time >= NOW()) "
                +
                "GROUP BY ra.id, p.name, p.category, p.unit, ra.required_quantity, ra.start_price, ra.current_price, ra.status, ra.end_time "
                +
                "ORDER BY ra.id DESC " +
                "LIMIT 8";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> auction = new HashMap<>();
                auction.put("id", rs.getLong("id"));
                auction.put("productName", rs.getString("product_name"));
                auction.put("category", rs.getString("category"));
                auction.put("unit", rs.getString("unit"));
                auction.put("requiredQuantity", rs.getInt("required_quantity"));
                double start = rs.getDouble("start_price");
                double curr = rs.getDouble("current_price");
                auction.put("startPrice", start);
                auction.put("currentPrice", curr);
                double savingsPct = (start > 0 && curr < start) ? Math.round(((start - curr) / start) * 1000.0) / 10.0
                        : 0.0;
                auction.put("savingsPct", savingsPct);
                auction.put("status", rs.getString("status"));
                auction.put("endTime", rs.getTimestamp("end_time"));
                auction.put("bidCount", rs.getLong("bid_count"));
                auctions.add(auction);
            }
        }

        return auctions;
    }

    private void checkLowStockItems(HttpServletRequest request) {
        try {
            List<Inventory> lowStockItems = getLowStockItemsFromDatabase();

            if (!lowStockItems.isEmpty()) {
                request.setAttribute("lowStockItems", lowStockItems);
                request.setAttribute("hasLowStockAlert", true);

                // Also set a simple message for backward compatibility
                StringBuilder itemNames = new StringBuilder();
                for (Inventory item : lowStockItems) {
                    itemNames.append(item.getItemName()).append(", ");
                }
                if (itemNames.length() > 0) {
                    String items = itemNames.substring(0, itemNames.length() - 2);
                    request.setAttribute("inventoryAlert", "Low stock for: " + items);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking low stock items", e);
        }
    }

    private List<Inventory> getLowStockItemsFromDatabase() throws SQLException {
        List<Inventory> lowStockItems = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                    "SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, " +
                            "needs_auction, auction_started FROM inventory " +
                            "WHERE kanban_status = 'Low' OR needs_auction = true " +
                            "ORDER BY quantity ASC");
            rs = stmt.executeQuery();

            while (rs.next()) {
                Inventory item = new Inventory(
                        rs.getInt("id"),
                        rs.getString("item_name"),
                        rs.getInt("quantity"),
                        rs.getInt("min_threshold"),
                        rs.getInt("max_threshold"));
                item.setKanbanStatus(rs.getString("kanban_status"));
                item.setNeedsAuction(rs.getBoolean("needs_auction"));
                item.setAuctionStarted(rs.getBoolean("auction_started"));

                lowStockItems.add(item);
            }
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }

        return lowStockItems;
    }
}
