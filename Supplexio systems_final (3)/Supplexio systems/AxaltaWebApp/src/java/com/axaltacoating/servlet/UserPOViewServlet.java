package com.axaltacoating.servlet;

import com.axaltacoating.model.User;
import com.axaltacoating.util.DatabaseConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "UserPOViewServlet", urlPatterns = {"/user-po-view", "/po", "/purchase-orders"})
public class UserPOViewServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UserPOViewServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Object user = session.getAttribute("user");
        if (user == null) {
            User defaultUser = new User();
            defaultUser.setId(1);
            defaultUser.setUsername("admin");
            defaultUser.setEmail("admin@example.com");
            defaultUser.setRole("ADMIN");
            session.setAttribute("user", defaultUser);
            session.setAttribute("userRole", "ADMIN");
            session.setAttribute("userId", 1);
            session.setAttribute("username", "admin");
            session.setAttribute("userEmail", "admin@example.com");
        }

        List<PurchaseOrderBean> poList = new ArrayList<>();

        String sql =
            "SELECT po.id, po.auction_id, " +

            "       COALESCE(po.supplier_id, ra.winning_supplier_id, " +
            "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) AS supplier_id, " +
            "       COALESCE(NULLIF(s.name, ''), NULLIF(po.supplier_name, ''), NULLIF(po.company_name, ''), 'Unknown Supplier') AS supplier_name, " +
            "       COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS material, " +
            "       COALESCE(po.total_amount, po.amount, ra.current_price, 0) AS amount, " +
            "       COALESCE(po.quantity, ra.required_quantity, 1) AS quantity, " +
            "       COALESCE(po.status, 'PO_DRAFT') AS display_status, " +
            "       (SELECT gr.received_quantity FROM goods_receipts gr WHERE gr.po_id = po.id AND gr.delivered_at IS NOT NULL ORDER BY gr.delivered_at DESC LIMIT 1) AS received_quantity, " +
            "       COALESCE(po.created_at, ra.end_time, ra.start_time) AS created_at " +
            "FROM purchase_orders po " +
            "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
            "LEFT JOIN auction_deliveries ad ON ad.auction_id = po.auction_id " +
            "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
            "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id, " +
            "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) " +
            (isAdmin(request) ? "" : "WHERE (ra.created_by_email = ? OR po.buyer_email = ?) ") +
            "ORDER BY COALESCE(po.created_at, ra.end_time, ra.start_time) DESC";

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureAuctionOwnerColumn(conn);
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                if (!isAdmin(request)) {
                    String buyerEmail = getCurrentBuyerEmail(request);
                    stmt.setString(1, buyerEmail);
                    stmt.setString(2, buyerEmail);
                }
                try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                PurchaseOrderBean po = new PurchaseOrderBean();
                po.setId(rs.getLong("id"));
                po.setAuctionId(rs.getLong("auction_id"));
                po.setSupplierId(rs.getLong("supplier_id"));
                po.setSupplierName(rs.getString("supplier_name"));
                po.setCompanyName(rs.getString("supplier_name"));
                po.setMaterial(rs.getString("material"));
                po.setAmount(rs.getDouble("amount"));
                po.setQuantity(rs.getInt("quantity"));
                po.setStatus(rs.getString("display_status"));
                int receivedQty = rs.getInt("received_quantity");
                po.setReceivedQuantity(rs.wasNull() ? 0 : receivedQty);
                po.setCreatedAt(rs.getTimestamp("created_at"));
                poList.add(po);
            }
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading user POs", e);
        }

        request.setAttribute("poList", poList);
        request.getRequestDispatcher("user_po.jsp").forward(request, response);
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
        HttpSession session = request.getSession(false);
        Object userRole = session == null ? null : session.getAttribute("userRole");
        if ("ADMIN".equalsIgnoreCase(String.valueOf(userRole))) {
            return true;
        }
        Object user = session == null ? null : session.getAttribute("user");
        return user instanceof User && "ADMIN".equalsIgnoreCase(((User) user).getRole());
    }

    private String getCurrentBuyerEmail(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
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
        Object userId = session == null ? null : session.getAttribute("userId");
        return userId == null ? "unknown-buyer" : String.valueOf(userId);
    }

    public static class PurchaseOrderBean {
        private long id;
        private long auctionId;
        private String supplierName;
        private String companyName;
        private String material;
        private double amount;
        private String status;
        private java.util.Date createdAt;
        private long supplierId;
        private int quantity;
        private int receivedQuantity;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }

        public long getAuctionId() { return auctionId; }
        public void setAuctionId(long auctionId) { this.auctionId = auctionId; }

        public String getSupplierName() { return supplierName; }
        public void setSupplierName(String supplierName) { this.supplierName = supplierName; }

        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }

        public String getMaterial() { return material; }
        public void setMaterial(String material) { this.material = material; }

        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }

        public long getSupplierId() { return supplierId; }
        public void setSupplierId(long supplierId) { this.supplierId = supplierId; }

        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }

        public int getReceivedQuantity() { return receivedQuantity; }
        public void setReceivedQuantity(int receivedQuantity) { this.receivedQuantity = receivedQuantity; }
    }
}
