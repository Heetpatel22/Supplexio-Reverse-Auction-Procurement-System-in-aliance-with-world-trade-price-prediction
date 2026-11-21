package com.axaltacoating.servlet;

import com.axaltacoating.model.User;
import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet for handling auction completion and inventory updates.
 */
@WebServlet(name = "AuctionCompletionServlet", urlPatterns = {"/auction-completion"})
public class AuctionCompletionServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(AuctionCompletionServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (!"checkCompletedAuctions".equals(action) && !requireBuyerLogin(request, response)) {
            return;
        }
        
        switch (action) {
            case "completeAuction":
                completeAuction(request, response);
                break;
            case "markDelivered":
                markDelivered(request, response);
                break;
            case "checkCompletedAuctions":
                checkCompletedAuctions(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("checkCompletedAuctions".equals(action)) {
            checkCompletedAuctions(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    /**
     * Completes an auction and determines the winning bid.
     */
    private void completeAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionIdParam = request.getParameter("auctionId");
        
        if (auctionIdParam == null || auctionIdParam.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Auction ID is required\"}");
            return;
        }
        
        long auctionId = Long.parseLong(auctionIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            ensureAuctionOwnerColumn(conn);
            if (request.getSession(false) != null && !canAccessAuction(conn, auctionId, request)) {
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
                return;
            }
            LOGGER.info("Starting completeAuction for auctionId=" + auctionId);
            // Get the winning bid (lowest amount)
            stmt = conn.prepareStatement(
                "SELECT b.*, s.name as supplier_name, s.email as supplier_email " +
                "FROM bids b " +
                "JOIN suppliers s ON b.supplier_id = s.id " +
                "WHERE b.auction_id = ? " +
                "ORDER BY b.amount ASC, b.bid_time ASC " +
                "LIMIT 1"
            );
            stmt.setLong(1, auctionId);
            rs = stmt.executeQuery();
            LOGGER.info("Executed winning bid query for auctionId=" + auctionId);
            if (rs.next()) {
                long winningSupplierId = rs.getLong("supplier_id");
                double winningAmount = rs.getDouble("amount");
                String supplierName = rs.getString("supplier_name");
                String supplierEmail = rs.getString("supplier_email");
                LOGGER.info("Winning supplier: " + winningSupplierId + ", amount: " + winningAmount);
                if (supplierName == null || supplierName.trim().isEmpty()) {
                    supplierName = "Unknown Supplier";
                    LOGGER.warning("Winning supplier name is null or empty for auction " + auctionId + ". Using 'Unknown Supplier'.");
                }
                if (supplierEmail == null || supplierEmail.trim().isEmpty()) {
                    supplierEmail = "unknown@example.com";
                    LOGGER.warning("Winning supplier email is null or empty for auction " + auctionId + ". Using 'unknown@example.com'.");
                }
                // No company name column, use supplierName for PO
                String supplierCompanyName = supplierName;
                // Get material (product) name, product_id, and quantity from auction
                String materialName = null;
                long productId = -1;
                int poQuantity = 1;
                stmt = conn.prepareStatement(
                    "SELECT p.id as product_id, p.name as product_name, ra.required_quantity as auction_quantity " +
                    "FROM reverse_auctions ra " +
                    "JOIN products p ON ra.product_id = p.id " +
                    "WHERE ra.id = ?"
                );
                stmt.setLong(1, auctionId);
                ResultSet rsProduct = stmt.executeQuery();
                if (rsProduct.next()) {
                    productId = rsProduct.getLong("product_id");
                    materialName = rsProduct.getString("product_name");
                    poQuantity = rsProduct.getInt("auction_quantity");
                    LOGGER.info("Product found: " + productId + ", name: " + materialName + ", quantity: " + poQuantity);
                } else {
                    materialName = "Unknown";
                    LOGGER.warning("No product found for auction " + auctionId);
                }
                rsProduct.close();
                // Safety: If poQuantity is zero or less, fetch from reverse_auctions directly
                if (poQuantity <= 0) {
                    stmt = conn.prepareStatement("SELECT required_quantity FROM reverse_auctions WHERE id = ?");
                    stmt.setLong(1, auctionId);
                    ResultSet rsQty = stmt.executeQuery();
                    if (rsQty.next()) {
                        poQuantity = rsQty.getInt("required_quantity");
                        LOGGER.info("Fetched required_quantity from reverse_auctions: " + poQuantity);
                    }
                    rsQty.close();
                }
                // Update auction status to COMPLETED and persist winning supplier snapshot
                stmt = conn.prepareStatement(
                    "UPDATE reverse_auctions " +
                    "SET status = 'COMPLETED', winning_supplier_id = ?, current_price = ? " +
                    "WHERE id = ?"
                );
                stmt.setLong(1, winningSupplierId);
                stmt.setDouble(2, winningAmount);
                stmt.setLong(3, auctionId);
                stmt.executeUpdate();
                LOGGER.info("Updated reverse_auctions status to COMPLETED for auctionId=" + auctionId);
                
                // Auto-replenish inventory upon auction completion
                com.axaltacoating.util.InventoryReplenisher.replenishFromAuction(conn, auctionId);
                
                conn.commit();
                LOGGER.info("Transaction committed for auctionId=" + auctionId);
                LOGGER.log(Level.INFO, "Auction {0} completed. Winner: {1} with amount: {2}", 
                    new Object[]{auctionId, supplierName, winningAmount});
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"message\": \"Auction completed. Winner: %s (%.2f). Open the auction and click Award PO to create a draft purchase order.\", \"winnerId\": %d, \"winningAmount\": %.2f}",
                    supplierName, winningAmount, winningSupplierId, winningAmount
                ));
            } else {
                LOGGER.warning("No bids found for auction " + auctionId);
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"No bids found for this auction\"}");
            }
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            LOGGER.log(Level.SEVERE, "Error completing auction", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error completing auction: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            LOGGER.log(Level.SEVERE, "Unexpected error in completeAuction", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    /**
     * Marks an auction delivery as completed and updates inventory.
     */
    private void markDelivered(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionIdParam = request.getParameter("auctionId");
        String quantityParam = request.getParameter("quantity");
        
        if (auctionIdParam == null || auctionIdParam.isEmpty() || 
            quantityParam == null || quantityParam.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Auction ID and quantity are required\"}");
            return;
        }
        
        long auctionId = Long.parseLong(auctionIdParam);
        int deliveredQuantity = Integer.parseInt(quantityParam);
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            ensureAuctionOwnerColumn(conn);
            if (!canAccessAuction(conn, auctionId, request)) {
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
                return;
            }
            
            // Get auction and product details
            stmt = conn.prepareStatement(
                "SELECT ra.product_id, p.name as product_name, p.inventory_id, ad.supplier_id " +
"FROM reverse_auctions ra " +
"JOIN products p ON ra.product_id = p.id " +
"JOIN auction_deliveries ad ON ra.id = ad.auction_id " +
"JOIN purchase_orders po ON po.auction_id = ra.id " +
"WHERE ra.id = ? AND ad.status = 'PENDING' AND po.status = 'PAID'"

            );
            stmt.setLong(1, auctionId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                long productId = rs.getLong("product_id");
                String productName = rs.getString("product_name");
                Long inventoryId = rs.getLong("inventory_id");
                
                // Update inventory if inventory_id exists
                if (inventoryId != null && inventoryId > 0) {
                    stmt = conn.prepareStatement(
                        "UPDATE inventory SET quantity = quantity + ?, updated_at = NOW() WHERE id = ?"
                    );
                    stmt.setInt(1, deliveredQuantity);
                    stmt.setLong(2, inventoryId);
                    int inventoryUpdated = stmt.executeUpdate();
                    
                    if (inventoryUpdated > 0) {
                        // Update kanban status based on new quantity
                        stmt = conn.prepareStatement(
                            "UPDATE inventory " +
                            "SET kanban_status = CASE " +
                            "    WHEN quantity <= min_threshold THEN 'Low' " +
                            "    WHEN quantity >= max_threshold THEN 'High' " +
                            "    ELSE 'Medium' " +
                            "END, " +
                            "needs_auction = (quantity <= min_threshold), " +
                            "auction_started = FALSE " +
                            "WHERE id = ?"
                        );
                        stmt.setLong(1, inventoryId);
                        stmt.executeUpdate();
                    }
                }
                
                // Update product stock quantity
                stmt = conn.prepareStatement(
                    "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?"
                );
                stmt.setInt(1, deliveredQuantity);
                stmt.setLong(2, productId);
                stmt.executeUpdate();
                
                // Mark delivery as completed
                stmt = conn.prepareStatement(
                    "UPDATE auction_deliveries SET status = 'DELIVERED', delivered_quantity = ?, delivery_date = NOW() WHERE auction_id = ?"
                );
                stmt.setInt(1, deliveredQuantity);
                stmt.setLong(2, auctionId);
                stmt.executeUpdate();
                stmt = conn.prepareStatement(
    "UPDATE purchase_orders SET status = 'DELIVERED' WHERE auction_id = ? AND status = 'PAID'"
);
stmt.setLong(1, auctionId);
stmt.executeUpdate();

                
                conn.commit();
                
                LOGGER.log(Level.INFO, "Delivery completed for auction {0}. Added {1} units of {2} to inventory", 
                    new Object[]{auctionId, deliveredQuantity, productName});
                
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"message\": \"Delivery marked as completed. Added %d units of %s to inventory\"}",
                    deliveredQuantity, productName
                ));
                
            } else {
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"No pending delivery found for this auction\"}");
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            
            LOGGER.log(Level.SEVERE, "Error marking delivery as completed", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error updating delivery: " + e.getMessage() + "\"}");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    private boolean requireBuyerLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        Object userRole = session == null ? null : session.getAttribute("userRole");

        if (user != null && !"SUPPLIER".equals(userRole)) {
            return true;
        }

        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login required");
        return false;
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

    private boolean isAuctionOwner(Connection conn, long auctionId, String buyerEmail) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT 1 FROM reverse_auctions WHERE id = ? AND created_by_email = ?")) {
            stmt.setLong(1, auctionId);
            stmt.setString(2, buyerEmail);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean canAccessAuction(Connection conn, long auctionId, HttpServletRequest request) throws SQLException {
        return isAdmin(request) || isAuctionOwner(conn, auctionId, getCurrentBuyerEmail(request));
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

    /**
     * Checks for auctions that have ended and automatically completes them.
     */
    private void checkCompletedAuctions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Find auctions that have ended but are still marked as ACTIVE
            stmt = conn.prepareStatement(
                "SELECT id FROM reverse_auctions " +
                "WHERE status = 'ACTIVE' AND end_time < NOW()"
            );
            rs = stmt.executeQuery();
            
            int completedCount = 0;
            while (rs.next()) {
                long auctionId = rs.getLong("id");
                
                // Complete each auction
                MockHttpServletRequest mockRequest = new MockHttpServletRequest();
                mockRequest.setParameter("auctionId", String.valueOf(auctionId));
                
                MockHttpServletResponse mockResponse = new MockHttpServletResponse();
                completeAuction(mockRequest, mockResponse);
                
                completedCount++;
            }
            
            response.setContentType("application/json");
            response.getWriter().write(String.format(
                "{\"success\": true, \"message\": \"Checked and completed %d auctions\", \"completedCount\": %d}",
                completedCount, completedCount
            ));
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking completed auctions", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error checking auctions: " + e.getMessage() + "\"}");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    // Mock classes for internal method calls
    private static class MockHttpServletRequest implements HttpServletRequest {
        private java.util.Map<String, String> parameters = new java.util.HashMap<>();
        
        public void setParameter(String name, String value) {
            parameters.put(name, value);
        }
        
        @Override
        public String getParameter(String name) {
            return parameters.get(name);
        }
        
        // Implement other required methods with default/empty implementations
        @Override public String getAuthType() { return null; }
        @Override public javax.servlet.http.Cookie[] getCookies() { return null; }
        @Override public long getDateHeader(String name) { return 0; }
        @Override public String getHeader(String name) { return null; }
        @Override public java.util.Enumeration<String> getHeaders(String name) { return null; }
        @Override public java.util.Enumeration<String> getHeaderNames() { return null; }
        @Override public int getIntHeader(String name) { return 0; }
        @Override public String getMethod() { return null; }
        @Override public String getPathInfo() { return null; }
        @Override public String getPathTranslated() { return null; }
        @Override public String getContextPath() { return null; }
        @Override public String getQueryString() { return null; }
        @Override public String getRemoteUser() { return null; }
        @Override public boolean isUserInRole(String role) { return false; }
        @Override public java.security.Principal getUserPrincipal() { return null; }
        @Override public String getRequestedSessionId() { return null; }
        @Override public String getRequestURI() { return null; }
        @Override public StringBuffer getRequestURL() { return null; }
        @Override public String getServletPath() { return null; }
        @Override public javax.servlet.http.HttpSession getSession(boolean create) { return null; }
        @Override public javax.servlet.http.HttpSession getSession() { return null; }
        @Override public String changeSessionId() { return null; }
        @Override public boolean isRequestedSessionIdValid() { return false; }
        @Override public boolean isRequestedSessionIdFromCookie() { return false; }
        @Override public boolean isRequestedSessionIdFromURL() { return false; }
        @Override public boolean isRequestedSessionIdFromUrl() { return false; }
        @Override public boolean authenticate(HttpServletResponse response) { return false; }
        @Override public void login(String username, String password) {}
        @Override public void logout() {}
        @Override public java.util.Collection<javax.servlet.http.Part> getParts() { return null; }
        @Override public javax.servlet.http.Part getPart(String name) { return null; }
        @Override public <T extends javax.servlet.http.HttpUpgradeHandler> T upgrade(Class<T> handlerClass) { return null; }
        @Override public Object getAttribute(String name) { return null; }
        @Override public java.util.Enumeration<String> getAttributeNames() { return null; }
        @Override public String getCharacterEncoding() { return null; }
        @Override public void setCharacterEncoding(String env) {}
        @Override public int getContentLength() { return 0; }
        @Override public long getContentLengthLong() { return 0; }
        @Override public String getContentType() { return null; }
        @Override public javax.servlet.ServletInputStream getInputStream() { return null; }
        @Override public String[] getParameterValues(String name) { return null; }
        @Override public java.util.Map<String, String[]> getParameterMap() { return null; }
        @Override public java.util.Enumeration<String> getParameterNames() { return null; }
        @Override public String getProtocol() { return null; }
        @Override public String getScheme() { return null; }
        @Override public String getServerName() { return null; }
        @Override public int getServerPort() { return 0; }
        @Override public java.io.BufferedReader getReader() { return null; }
        @Override public String getRemoteAddr() { return null; }
        @Override public String getRemoteHost() { return null; }
        @Override public void setAttribute(String name, Object o) {}
        @Override public void removeAttribute(String name) {}
        @Override public java.util.Locale getLocale() { return null; }
        @Override public java.util.Enumeration<java.util.Locale> getLocales() { return null; }
        @Override public boolean isSecure() { return false; }
        @Override public javax.servlet.RequestDispatcher getRequestDispatcher(String path) { return null; }
        @Override public String getRealPath(String path) { return null; }
        @Override public int getRemotePort() { return 0; }
        @Override public String getLocalName() { return null; }
        @Override public String getLocalAddr() { return null; }
        @Override public int getLocalPort() { return 0; }
        @Override public javax.servlet.ServletContext getServletContext() { return null; }
        @Override public javax.servlet.AsyncContext startAsync() { return null; }
        @Override public javax.servlet.AsyncContext startAsync(javax.servlet.ServletRequest servletRequest, javax.servlet.ServletResponse servletResponse) { return null; }
        @Override public boolean isAsyncStarted() { return false; }
        @Override public boolean isAsyncSupported() { return false; }
        @Override public javax.servlet.AsyncContext getAsyncContext() { return null; }
        @Override public javax.servlet.DispatcherType getDispatcherType() { return null; }
    }

    private static class MockHttpServletResponse implements HttpServletResponse {
        private java.io.StringWriter writer = new java.io.StringWriter();
        
        @Override public java.io.PrintWriter getWriter() { return new java.io.PrintWriter(writer); }
        @Override public void setContentType(String type) {}
        
        // Implement other required methods with default/empty implementations
        @Override public void addCookie(javax.servlet.http.Cookie cookie) {}
        @Override public boolean containsHeader(String name) { return false; }
        @Override public String encodeURL(String url) { return null; }
        @Override public String encodeRedirectURL(String url) { return null; }
        @Override public String encodeUrl(String url) { return null; }
        @Override public String encodeRedirectUrl(String url) { return null; }
        @Override public void sendError(int sc, String msg) {}
        @Override public void sendError(int sc) {}
        @Override public void sendRedirect(String location) {}
        @Override public void setDateHeader(String name, long date) {}
        @Override public void addDateHeader(String name, long date) {}
        @Override public void setHeader(String name, String value) {}
        @Override public void addHeader(String name, String value) {}
        @Override public void setIntHeader(String name, int value) {}
        @Override public void addIntHeader(String name, int value) {}
        @Override public void setStatus(int sc) {}
        @Override public void setStatus(int sc, String sm) {}
        @Override public int getStatus() { return 0; }
        @Override public String getHeader(String name) { return null; }
        @Override public java.util.Collection<String> getHeaders(String name) { return null; }
        @Override public java.util.Collection<String> getHeaderNames() { return null; }
        @Override public String getCharacterEncoding() { return null; }
        @Override public String getContentType() { return null; }
        @Override public javax.servlet.ServletOutputStream getOutputStream() { return null; }
        @Override public void setCharacterEncoding(String charset) {}
        @Override public void setContentLength(int len) {}
        @Override public void setContentLengthLong(long len) {}
        @Override public void setBufferSize(int size) {}
        @Override public int getBufferSize() { return 0; }
        @Override public void flushBuffer() {}
        @Override public void resetBuffer() {}
        @Override public boolean isCommitted() { return false; }
        @Override public void reset() {}
        @Override public void setLocale(java.util.Locale loc) {}
        @Override public java.util.Locale getLocale() { return null; }
    }
}
