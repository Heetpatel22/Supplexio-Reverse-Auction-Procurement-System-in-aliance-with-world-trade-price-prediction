package com.axaltacoating.servlet;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.util.DatabaseConnection;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AuctionMessageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        ensureTable();

        String mode = request.getParameter("mode");
        try (PrintWriter out = response.getWriter()) {
            if ("counts".equalsIgnoreCase(mode)) {
                out.write(getUnreadCounts(request).toJSONString());
                return;
            }
            out.write(getConversation(request).toJSONString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Unable to load auction messages\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        ensureTable();

        String action = request.getParameter("action");
        try (PrintWriter out = response.getWriter()) {
            if ("send".equalsIgnoreCase(action)) {
                sendMessage(request);
                out.write("{\"success\":true}");
                return;
            }
            if ("read".equalsIgnoreCase(action)) {
                markRead(request);
                out.write("{\"success\":true}");
                return;
            }
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\":\"Unsupported message action\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Unable to save auction message\"}");
        }
    }

    private JSONObject getConversation(HttpServletRequest request) throws SQLException {
        long auctionId = parseLong(request.getParameter("auctionId"));
        long supplierId = resolveSupplierId(request);
        String viewer = resolveViewer(request);

        markRead(auctionId, supplierId, viewer);

        JSONObject result = new JSONObject();
        JSONArray messages = new JSONArray();

        String sql = "SELECT sender_type, message, created_at FROM auction_messages " +
                "WHERE auction_id = ? AND supplier_id = ? ORDER BY created_at ASC, id ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, auctionId);
            stmt.setLong(2, supplierId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    JSONObject message = new JSONObject();
                    message.put("senderType", rs.getString("sender_type"));
                    message.put("message", rs.getString("message"));
                    message.put("createdAt", rs.getTimestamp("created_at").getTime());
                    messages.add(message);
                }
            }
        }

        result.put("messages", messages);
        return result;
    }

    private JSONObject getUnreadCounts(HttpServletRequest request) throws SQLException {
        long auctionId = parseLong(request.getParameter("auctionId"));
        String viewer = resolveViewer(request);
        Supplier supplier = getSessionSupplier(request);

        JSONObject result = new JSONObject();
        String sql;

        try (Connection conn = DatabaseConnection.getConnection()) {
            if (supplier != null) {
                sql = "SELECT auction_id AS target_id, COUNT(*) AS unread_count FROM auction_messages " +
                        "WHERE supplier_id = ? AND sender_type = 'BUYER' AND is_read = FALSE " +
                        (auctionId > 0 ? "AND auction_id = ? " : "") +
                        "GROUP BY auction_id";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setLong(1, supplier.getId());
                    if (auctionId > 0) {
                        stmt.setLong(2, auctionId);
                    }
                    appendCounts(result, stmt);
                }
            } else if ("BUYER".equals(viewer)) {
                sql = "SELECT supplier_id AS target_id, COUNT(*) AS unread_count FROM auction_messages " +
                        "WHERE auction_id = ? AND sender_type = 'SUPPLIER' AND is_read = FALSE GROUP BY supplier_id";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setLong(1, auctionId);
                    appendCounts(result, stmt);
                }
            }
        }
        return result;
    }

    private void appendCounts(JSONObject result, PreparedStatement stmt) throws SQLException {
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                result.put(String.valueOf(rs.getLong("target_id")), rs.getInt("unread_count"));
            }
        }
    }

    private void sendMessage(HttpServletRequest request) throws SQLException {
        long auctionId = parseLong(request.getParameter("auctionId"));
        long supplierId = resolveSupplierId(request);
        String senderType = getSessionSupplier(request) != null ? "SUPPLIER" : "BUYER";
        String message = request.getParameter("message");

        if (auctionId <= 0 || supplierId <= 0 || message == null || message.trim().isEmpty()) {
            throw new SQLException("Missing message fields");
        }

        String sql = "INSERT INTO auction_messages (auction_id, supplier_id, sender_type, message, is_read) " +
                "VALUES (?, ?, ?, ?, FALSE)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, auctionId);
            stmt.setLong(2, supplierId);
            stmt.setString(3, senderType);
            stmt.setString(4, message.trim());
            stmt.executeUpdate();
        }
    }

    private void markRead(HttpServletRequest request) throws SQLException {
        markRead(parseLong(request.getParameter("auctionId")), resolveSupplierId(request), resolveViewer(request));
    }

    private void markRead(long auctionId, long supplierId, String viewer) throws SQLException {
        String otherSender = "BUYER".equals(viewer) ? "SUPPLIER" : "BUYER";
        String sql = "UPDATE auction_messages SET is_read = TRUE " +
                "WHERE auction_id = ? AND supplier_id = ? AND sender_type = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, auctionId);
            stmt.setLong(2, supplierId);
            stmt.setString(3, otherSender);
            stmt.executeUpdate();
        }
    }

    private long resolveSupplierId(HttpServletRequest request) {
        Supplier supplier = getSessionSupplier(request);
        if (supplier != null) {
            return supplier.getId();
        }
        return parseLong(request.getParameter("supplierId"));
    }

    private String resolveViewer(HttpServletRequest request) {
        return getSessionSupplier(request) != null ? "SUPPLIER" : "BUYER";
    }

    private Supplier getSessionSupplier(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object supplier = session.getAttribute("supplier");
        return supplier instanceof Supplier ? (Supplier) supplier : null;
    }

    private long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void ensureTable() {
        String sql = "CREATE TABLE IF NOT EXISTS auction_messages (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "sender_type VARCHAR(20) NOT NULL, " +
                "message TEXT NOT NULL, " +
                "is_read BOOLEAN NOT NULL DEFAULT FALSE, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.executeUpdate();
        } catch (SQLException ignored) {
            // The API response will surface database issues on the active request path.
        }
    }
}
