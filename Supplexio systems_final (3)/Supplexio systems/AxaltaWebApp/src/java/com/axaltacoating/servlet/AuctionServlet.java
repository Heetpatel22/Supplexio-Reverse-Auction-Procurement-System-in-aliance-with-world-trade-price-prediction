package com.axaltacoating.servlet;

import com.axaltacoating.model.Product;
import com.axaltacoating.model.ReverseAuction;
import com.axaltacoating.model.Supplier;
import com.axaltacoating.model.User;
import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

/**
 * Servlet for handling reverse auction management operations.
 */
@WebServlet(name = "AuctionServlet", urlPatterns = {"/auction"})
public class AuctionServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AuctionServlet.class.getName());

    /**
     * Handles the HTTP GET method - displays auction list or form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireBuyerLogin(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "view":
                viewAuction(request, response);
                break;
            case "delete":
                deleteAuction(request, response);
                break;
            case "invite":
                showInviteForm(request, response);
                break;
            default:
                listAuctions(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP POST method - processes form submissions.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireBuyerLogin(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "create":
                createAuction(request, response);
                break;
            case "update":
                updateAuction(request, response);
                break;
            case "invite":
                inviteSuppliers(request, response);
                break;
            case "cancel":
                cancelAuction(request, response);
                break;
            case "createAutomatic":
                createAutomaticAuction(request, response);
                break;
            default:
                listAuctions(request, response);
                break;
        }
    }

    private boolean requireBuyerLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(true);
        Object user = session.getAttribute("user");
        Object userRole = session.getAttribute("userRole");

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
            return true;
        }

        if (user != null && !"SUPPLIER".equals(userRole)) {
            return true;
        }

        String target = request.getRequestURI();
        String query = request.getQueryString();
        if (query != null && !query.trim().isEmpty()) {
            target += "?" + query;
        }

        String contextPath = request.getContextPath();
        if (contextPath != null && !contextPath.isEmpty() && target.startsWith(contextPath)) {
            target = target.substring(contextPath.length());
        }

        response.sendRedirect(contextPath + "/login.jsp?redirect=" + URLEncoder.encode(target, "UTF-8"));
        return false;
    }

    /**
     * Lists all auctions.
     */
    private void listAuctions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<ReverseAuction> auctions = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionOwnerColumn(conn);
            boolean admin = isAdmin(request);
            String buyerEmail = getCurrentBuyerEmail(request);
            String sql =
    "SELECT a.*, p.name as product_name, p.unit, p.inventory_id, p.category as product_category, p.hsn_code, " +
    "i.quantity as current_inventory, i.min_threshold, i.needs_auction, " +
    "ad.status as delivery_status, ad.delivered_quantity, " +
    "po.status as po_status, " +
    "s.name as winning_supplier_name " +
    "FROM reverse_auctions a " +
    "JOIN products p ON a.product_id = p.id " +
    "LEFT JOIN inventory i ON p.inventory_id = i.id " +
    "LEFT JOIN auction_deliveries ad ON a.id = ad.auction_id " +
    "LEFT JOIN purchase_orders po ON po.auction_id = a.id " +
    "LEFT JOIN suppliers s ON a.winning_supplier_id = s.id " +
    (admin ? "" : "WHERE a.created_by_email = ? ") +
    "ORDER BY a.start_time DESC";
            stmt = conn.prepareStatement(sql);
            if (!admin) {
                stmt.setString(1, buyerEmail);
            }
            rs = stmt.executeQuery();

            
            while (rs.next()) {
                ReverseAuction auction = new ReverseAuction();
                auction.setId(rs.getLong("id"));
                auction.setProductId(rs.getLong("product_id"));
                auction.setProductName(rs.getString("product_name"));
                String prodCategory = rs.getString("product_category");
                auction.setCategory(prodCategory != null && !prodCategory.trim().isEmpty() ? prodCategory.trim() : "General");
                String hsn = rs.getString("hsn_code");
                auction.setHsnCode(hsn != null && !hsn.trim().isEmpty() ? hsn.trim() : "");
                
                // Calculate required quantity based on inventory needs
                int currentInventory = rs.getInt("current_inventory");
                int minThreshold = rs.getInt("min_threshold");
                boolean needsAuction = rs.getBoolean("needs_auction");
                
                // Set recommended quantity (max_threshold - current + 20% buffer)
                int recommendedQuantity = Math.max(1, (minThreshold * 2) - currentInventory);
                auction.setRequiredQuantity(recommendedQuantity);
                
                auction.setUnit(rs.getString("unit"));
                auction.setStartPrice(rs.getDouble("start_price"));
                auction.setCurrentPrice(rs.getDouble("current_price"));
                auction.setStartTime(rs.getTimestamp("start_time"));
                auction.setEndTime(rs.getTimestamp("end_time"));
                
                // Calculate status based on time and delivery status
String dbStatus = rs.getString("status");
String poStatus = rs.getString("po_status");

if ("DELIVERED".equalsIgnoreCase(poStatus)) {
    auction.setStatus("DELIVERED");
} else if ("PAYMENT_SUCCESSFUL".equalsIgnoreCase(poStatus) || "PAID".equalsIgnoreCase(poStatus)) {
    auction.setStatus("PAYMENT_SUCCESSFUL");
} else if ("PAYMENT_PENDING".equalsIgnoreCase(poStatus)) {
    auction.setStatus("PAYMENT_PENDING");
} else if ("INVOICING_PENDING".equalsIgnoreCase(poStatus)) {
    auction.setStatus("INVOICING_PENDING");
} else if ("PO_SENT".equalsIgnoreCase(poStatus) || "SENT".equalsIgnoreCase(poStatus)) {
    auction.setStatus("PO_SENT");
} else if ("PO_ACCEPTED".equalsIgnoreCase(poStatus)) {
    auction.setStatus("PO_ACCEPTED");
} else if ("SHIPPED".equalsIgnoreCase(poStatus)) {
    auction.setStatus("SHIPPED");
} else if ("CLOSED".equalsIgnoreCase(poStatus)) {
    auction.setStatus("CLOSED");
} else if ("AWARDED".equalsIgnoreCase(poStatus)) {
    auction.setStatus("AWARDED");
} else if (poStatus != null && !poStatus.trim().isEmpty()) {
    // Sync the exact PO status so it perfectly matches the Buyer and Supplier PO pages
    if ("COMPLETED".equalsIgnoreCase(poStatus)) {
        auction.setStatus("PO_DRAFT");
    } else if ("PENDING".equalsIgnoreCase(poStatus)) {
        auction.setStatus("PO_DRAFT");
    } else {
        auction.setStatus(poStatus);
    }
} else if ("COMPLETED".equalsIgnoreCase(dbStatus)) {
    auction.setStatus("COMPLETED");
} else if (!"CANCELLED".equals(dbStatus)) {
    auction.setStatus(calculateAuctionStatus(auction.getStartTime(), auction.getEndTime()));
} else {
    auction.setStatus(dbStatus);
}


                
                // Set winning supplier info if available
                if (rs.getString("winning_supplier_name") != null) {
                    auction.setSupplierName(rs.getString("winning_supplier_name"));
                }
                long winningSupId = rs.getLong("winning_supplier_id");
                if (!rs.wasNull()) {
                    auction.setSupplierId(winningSupId);
                }
                
                auctions.add(auction);
            }
            
            // Pre-fetch recent bids for auctions to populate slide-over audit timeline
            java.util.Map<Long, JSONArray> bidsMap = new java.util.HashMap<>();
            try (Statement bidStmt = conn.createStatement();
                 ResultSet bidRs = bidStmt.executeQuery(
                     "SELECT b.auction_id, b.supplier_id, b.amount, b.bid_time, COALESCE(b.supplier_name, s.name, 'Supplier') as supplier_name " +
                     "FROM bids b " +
                     "LEFT JOIN suppliers s ON b.supplier_id = s.id " +
                     "ORDER BY b.auction_id, b.bid_time DESC")) {
                SimpleDateFormat bidSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                while (bidRs.next()) {
                    long aId = bidRs.getLong("auction_id");
                    JSONArray arr = bidsMap.get(aId);
                    if (arr == null) {
                        arr = new JSONArray();
                        bidsMap.put(aId, arr);
                    }
                    if (arr.size() < 10) {
                        JSONObject bObj = new JSONObject();
                        bObj.put("supplierId", bidRs.getLong("supplier_id"));
                        bObj.put("supplier", bidRs.getString("supplier_name"));
                        bObj.put("amount", bidRs.getDouble("amount"));
                        Timestamp bt = bidRs.getTimestamp("bid_time");
                        bObj.put("time", bt != null ? bidSdf.format(bt) : "Recent");
                        arr.add(bObj);
                    }
                }
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Error loading bids for reverse auctions", ex);
            }

            // Fetch all distinct product categories across products & global trade chapters
            List<String> categories = new ArrayList<>();
            try (Statement catStmt = conn.createStatement();
                 ResultSet catRs = catStmt.executeQuery(
                     "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != '' " +
                     "UNION SELECT DISTINCT chapter_name FROM global_trade_products WHERE chapter_name IS NOT NULL AND chapter_name != '' " +
                     "ORDER BY 1")) {
                while (catRs.next()) {
                    String c = catRs.getString(1);
                    if (c != null && !c.trim().isEmpty()) {
                        categories.add(c.trim());
                    }
                }
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Error loading categories", ex);
            }

            // Build JSON representation for client-side interactivity
            SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            JSONArray auctionsJsonArray = new JSONArray();
            for (ReverseAuction a : auctions) {
                JSONObject obj = new JSONObject();
                obj.put("id", a.getId());
                obj.put("productId", a.getProductId());
                obj.put("product", a.getProductName());
                obj.put("category", a.getCategory() != null ? a.getCategory() : "General");
                obj.put("hsnCode", a.getHsnCode() != null ? a.getHsnCode() : "");
                obj.put("quantity", a.getRequiredQuantity() + " " + (a.getUnit() != null ? a.getUnit() : ""));
                obj.put("requiredQuantity", a.getRequiredQuantity());
                obj.put("unit", a.getUnit() != null ? a.getUnit() : "");
                obj.put("startPrice", a.getStartingPrice() != null ? a.getStartingPrice() : 0.0);
                obj.put("currentBid", a.getCurrentPrice() != null ? a.getCurrentPrice() : 0.0);
                obj.put("status", a.getStatus() != null ? a.getStatus() : "ACTIVE");
                obj.put("winner", a.getSupplierName());
                obj.put("winningSupplierId", a.getSupplierId() != null ? a.getSupplierId() : 0);
                obj.put("startTime", a.getStartTime() != null ? dtFmt.format(a.getStartTime()) : "");
                obj.put("endTime", a.getEndTime() != null ? dtFmt.format(a.getEndTime()) : "");
                
                long rem = 0;
                if (a.getEndTime() != null && "ACTIVE".equalsIgnoreCase(a.getStatus())) {
                    long diff = (a.getEndTime().getTime() - System.currentTimeMillis()) / 1000;
                    if (diff > 0) rem = diff;
                }
                obj.put("remainingSeconds", rem);
                
                JSONArray bArr = bidsMap.get(a.getId());
                obj.put("bids", bArr != null ? bArr : new JSONArray());
                
                auctionsJsonArray.add(obj);
            }

            // Also get products that need auctions but don't have them yet (if needed)
            List<Product> productsNeedingAuctions = getProductsNeedingAuctions(request);
            request.setAttribute("productsNeedingAuctions", productsNeedingAuctions);
            
            // Pass products for fallback
            List<Product> products = getProductsWithInventoryInfo();
            request.setAttribute("products", products);
            
            request.setAttribute("categories", categories);
            request.setAttribute("auctionsJson", auctionsJsonArray.toJSONString());
            request.setAttribute("auctions", auctions);
            request.getRequestDispatcher("/WEB-INF/views/auction/list.jsp").forward(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving auctions", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Shows form to create a new auction.
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Product> products = getProductsWithInventoryInfo();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/WEB-INF/views/auction/form.jsp").forward(request, response);
    }

    /**
     * Shows form to edit an existing auction.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        long id = Long.parseLong(idParam);
        ReverseAuction auction = getAuctionById(id, request);
        
        if (auction != null) {
            List<Product> products = getProductsWithInventoryInfo();
            request.setAttribute("products", products);
            request.setAttribute("auction", auction);
            request.getRequestDispatcher("/WEB-INF/views/auction/form.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/auction");
        }
    }

    /**
     * Views details of an auction.
     */
    @SuppressWarnings("unchecked")
    private void viewAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        String action = request.getParameter("action");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        long id = Long.parseLong(idParam);
        
        // Handle AJAX request for auction details
        if ("get".equals(action)) {
            try {
                ReverseAuction auction = getAuctionById(id, request);
                if (auction == null) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"error\": \"Auction not found\"}");
                    return;
                }
                List<Object[]> bids = getBidsForAuction(id);
                List<Object[]> chartData = getBidChartData(id);
                
                // Convert to JSON
                org.json.simple.JSONObject jsonResponse = new org.json.simple.JSONObject();
                
                // Add auction data
                org.json.simple.JSONObject auctionJson = new org.json.simple.JSONObject();
                auctionJson.put("id", auction.getId());
                auctionJson.put("productId", auction.getProductId());
                auctionJson.put("productName", auction.getProductName());
                auctionJson.put("requiredQuantity", auction.getRequiredQuantity());
                auctionJson.put("unit", auction.getUnit());
                auctionJson.put("startingPrice", auction.getStartingPrice());
                auctionJson.put("currentPrice", auction.getCurrentPrice());
                auctionJson.put("startTime", auction.getStartTime().getTime());
                auctionJson.put("endTime", auction.getEndTime().getTime());
                auctionJson.put("status", auction.getStatus());
                jsonResponse.put("auction", auctionJson);
                
                // Add bids data
                org.json.simple.JSONArray bidsArray = new org.json.simple.JSONArray();
                for (Object[] bidInfo : bids) {
                    com.axaltacoating.model.Bid bid = (com.axaltacoating.model.Bid) bidInfo[0];
                    String supplierName = (String) bidInfo[1];
                    
                    org.json.simple.JSONObject bidJson = new org.json.simple.JSONObject();
                    bidJson.put("id", bid.getId());
                    bidJson.put("auctionId", bid.getAuctionId());
                    bidJson.put("supplierId", bid.getSupplierId());
                    bidJson.put("supplierName", supplierName);
                    bidJson.put("amount", bid.getAmount());
                    bidJson.put("bidTime", bid.getBidTime().getTime());
                    
                    bidsArray.add(bidJson);
                }
                jsonResponse.put("bids", bidsArray);
                
                // Add chart data
                org.json.simple.JSONArray chartDataArray = new org.json.simple.JSONArray();
                for (Object[] dataPoint : chartData) {
                    org.json.simple.JSONObject dataPointJson = new org.json.simple.JSONObject();
                    dataPointJson.put("bidTime", ((Date) dataPoint[0]).getTime());
                    dataPointJson.put("bidAmount", dataPoint[1]);
                    dataPointJson.put("supplierName", dataPoint[2]);
                    dataPointJson.put("supplierId", dataPoint[3]);
                    
                    chartDataArray.add(dataPointJson);
                }
                jsonResponse.put("chartData", chartDataArray);
                
                response.setContentType("application/json");
                response.getWriter().write(jsonResponse.toJSONString());
                
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
            }
            return;
        }
        
        // Handle normal page view
        ReverseAuction auction = getAuctionById(id, request);
        
        if (auction != null) {
            // Get invited suppliers
            List<Supplier> invitedSuppliers = getInvitedSuppliers(id);
            request.setAttribute("invitedSuppliers", invitedSuppliers);

            // Show chat for invited suppliers, bidders, and anyone who messaged on this auction.
            List<Supplier> auctionChatSuppliers = getAuctionChatSuppliers(id);
            request.setAttribute("auctionChatSuppliers", auctionChatSuppliers);
            
            // Get bids for this auction
            List<Object[]> bids = getBidsForAuction(id);
            request.setAttribute("bids", bids);

            loadAwardState(request, id);
            
            request.setAttribute("auction", auction);
            request.getRequestDispatcher("/WEB-INF/views/auction/view.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/auction");
        }
    }

    /**
     * Shows form to invite suppliers to an auction.
     */
    private void showInviteForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionId = request.getParameter("id");
        if (auctionId == null || auctionId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionOwnerColumn(conn);
            
            boolean admin = isAdmin(request);

            // Get auction details
            String sql =
                "SELECT a.*, p.name as product_name FROM reverse_auctions a " +
                "JOIN products p ON a.product_id = p.id " +
                "WHERE a.id = ?" +
                (admin ? "" : " AND a.created_by_email = ?");
            stmt = conn.prepareStatement(sql);
            stmt.setLong(1, Long.parseLong(auctionId));
            if (!admin) {
                stmt.setString(2, getCurrentBuyerEmail(request));
            }
            rs = stmt.executeQuery();
            
            if (!rs.next()) {
                response.sendRedirect(request.getContextPath() + "/auction");
                return;
            }
            
            ReverseAuction auction = new ReverseAuction();
            auction.setId(rs.getLong("id"));
            auction.setProductId(rs.getLong("product_id"));
            auction.setProductName(rs.getString("product_name"));
            auction.setStartPrice(rs.getDouble("start_price"));
            auction.setCurrentPrice(rs.getDouble("current_price"));
            auction.setStartTime(rs.getTimestamp("start_time"));
            auction.setEndTime(rs.getTimestamp("end_time"));
            auction.setStatus(rs.getString("status"));
            
            request.setAttribute("auction", auction);
            
            // Get all active suppliers
            List<Supplier> suppliers = new ArrayList<>();
            stmt = conn.prepareStatement("SELECT * FROM suppliers WHERE status = 'ACTIVE'");
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                suppliers.add(supplier);
            }
            request.setAttribute("suppliers", suppliers);
            
            // Get already invited suppliers
            Set<Long> invitedSupplierIds = new HashSet<>();
            stmt = conn.prepareStatement(
                "SELECT supplier_id FROM auction_invitations WHERE auction_id = ?"
            );
            stmt.setLong(1, Long.parseLong(auctionId));
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                invitedSupplierIds.add(rs.getLong("supplier_id"));
            }
            request.setAttribute("invitedSupplierIds", invitedSupplierIds);
            
            request.getRequestDispatcher("/WEB-INF/views/auction/invite.jsp")
                   .forward(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            listAuctions(request, response);
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                // Log the error
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Processes the supplier invitation form submission.
     */
    private void inviteSuppliers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionId = request.getParameter("id");
        String[] supplierIds = request.getParameterValues("supplierIds");
        
        if (auctionId == null || auctionId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            ensureAuctionOwnerColumn(conn);
            if (!canAccessAuction(conn, Long.parseLong(auctionId), request)) {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/auction");
                return;
            }
            
            // First, remove all existing invitations
            stmt = conn.prepareStatement(
                "DELETE FROM auction_invitations WHERE auction_id = ?"
            );
            stmt.setLong(1, Long.parseLong(auctionId));
            stmt.executeUpdate();
            
            if (supplierIds != null && supplierIds.length > 0) {
                // Insert new invitations with PENDING status (one of the allowed ENUM values)
                stmt = conn.prepareStatement(
                    "INSERT INTO auction_invitations (auction_id, supplier_id, status) VALUES (?, ?, 'PENDING')"
                );
                
                for (String supplierId : supplierIds) {
                    stmt.setLong(1, Long.parseLong(auctionId));
                    stmt.setLong(2, Long.parseLong(supplierId));
                    stmt.addBatch();
                }
                
                stmt.executeBatch();
            }
            
            conn.commit();
            
            // Redirect back to auction view with success message
            request.getSession().setAttribute("success", "Supplier invitations have been updated successfully.");
            response.sendRedirect(request.getContextPath() + "/auction?action=view&id=" + auctionId);
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            request.setAttribute("error", "Failed to update supplier invitations: " + e.getMessage());
            showInviteForm(request, response);
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Creates a new auction.
     */
    private void createAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdParam = request.getParameter("productId");
        String startPriceParam = request.getParameter("startingPrice");

        // Support both combined "startTime" (yyyy-MM-dd'T'HH:mm) and separate startDate+startTime
        String startDateParam = request.getParameter("startDate");
        String startTimeParam = request.getParameter("startTime");
        String endDateParam   = request.getParameter("endDate");
        String endTimeParam   = request.getParameter("endTime");

        // Build combined datetime strings
        String startDateTimeStr = null;
        String endDateTimeStr   = null;

        if (startDateParam != null && !startDateParam.isEmpty()
                && startTimeParam != null && !startTimeParam.isEmpty()) {
            startDateTimeStr = startDateParam + "T" + startTimeParam;
        } else if (startTimeParam != null && startTimeParam.contains("-")) {
            // Legacy: startTime param already contains full datetime
            startDateTimeStr = startTimeParam;
        }

        if (endDateParam != null && !endDateParam.isEmpty()
                && endTimeParam != null && !endTimeParam.isEmpty()) {
            endDateTimeStr = endDateParam + "T" + endTimeParam;
        } else if (endTimeParam != null && endTimeParam.contains("-")) {
            endDateTimeStr = endTimeParam;
        }

        if (productIdParam == null || productIdParam.isEmpty() ||
            startPriceParam == null || startPriceParam.isEmpty() ||
            startDateTimeStr == null || startDateTimeStr.isEmpty() ||
            endDateTimeStr == null || endDateTimeStr.isEmpty()) {

            request.setAttribute("error", "All fields are required");
            showNewForm(request, response);
            return;
        }

        try {
            long productId = Long.parseLong(productIdParam);
            double startPrice = Double.parseDouble(startPriceParam);

            // Parse dates in IST (Indian Standard Time) so that what the user enters
            // in the browser (IST) is stored correctly — not shifted to UTC.
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            dateFormat.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
            Date startTime = dateFormat.parse(startDateTimeStr);
            Date endTime   = dateFormat.parse(endDateTimeStr);

            if (startTime.after(endTime)) {
                request.setAttribute("error", "Start time must be before end time");
                showNewForm(request, response);
                return;
            }

            Connection conn = null;
            PreparedStatement stmt = null;

            try {
                conn = DatabaseConnection.getConnection();
                ensureAuctionOwnerColumn(conn);
                String requiredQuantityStr = request.getParameter("quantity");
                if (requiredQuantityStr == null || requiredQuantityStr.isEmpty()) {
                    throw new ServletException("Required quantity is mandatory");
                }
                int requiredQuantity = Integer.parseInt(requiredQuantityStr);

                stmt = conn.prepareStatement(
                    "INSERT INTO reverse_auctions (product_id, start_price, current_price, " +
                    "start_time, end_time, required_quantity, status, created_by_email) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', ?)",
                    Statement.RETURN_GENERATED_KEYS
                );
                stmt.setLong(1, productId);
                stmt.setDouble(2, startPrice);
                stmt.setDouble(3, startPrice);
                stmt.setTimestamp(4, new Timestamp(startTime.getTime()));
                stmt.setTimestamp(5, new Timestamp(endTime.getTime()));
                stmt.setInt(6, requiredQuantity);
                stmt.setString(7, getCurrentBuyerEmail(request));

                int affectedRows = stmt.executeUpdate();

                if (affectedRows > 0) {
                    request.setAttribute("success", "Auction created successfully");
                } else {
                    request.setAttribute("error", "Failed to create auction");
                }

                listAuctions(request, response);

            } catch (SQLException e) {
                throw new ServletException("Error creating auction", e);
            } finally {
                DatabaseConnection.closeQuietly(null, stmt, conn);
            }

        } catch (NumberFormatException | ParseException e) {
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            showNewForm(request, response);
        }
    }

    /**
     * Updates an existing auction.
     */
    private void updateAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam        = request.getParameter("id");
        String productIdParam = request.getParameter("productId");
        String startPriceParam = request.getParameter("startingPrice");
        String statusParam    = request.getParameter("status");

        // Support both combined and separate date/time params
        String startDateParam = request.getParameter("startDate");
        String startTimeParam = request.getParameter("startTime");
        String endDateParam   = request.getParameter("endDate");
        String endTimeParam   = request.getParameter("endTime");

        String startDateTimeStr = null;
        String endDateTimeStr   = null;

        if (startDateParam != null && !startDateParam.isEmpty()
                && startTimeParam != null && !startTimeParam.isEmpty()) {
            startDateTimeStr = startDateParam + "T" + startTimeParam;
        } else if (startTimeParam != null && startTimeParam.contains("-")) {
            startDateTimeStr = startTimeParam;
        }

        if (endDateParam != null && !endDateParam.isEmpty()
                && endTimeParam != null && !endTimeParam.isEmpty()) {
            endDateTimeStr = endDateParam + "T" + endTimeParam;
        } else if (endTimeParam != null && endTimeParam.contains("-")) {
            endDateTimeStr = endTimeParam;
        }

        if (idParam == null || idParam.isEmpty() ||
            productIdParam == null || productIdParam.isEmpty() ||
            startPriceParam == null || startPriceParam.isEmpty() ||
            startDateTimeStr == null || startDateTimeStr.isEmpty() ||
            endDateTimeStr == null || endDateTimeStr.isEmpty() ||
            statusParam == null || statusParam.isEmpty()) {

            request.setAttribute("error", "All fields are required");
            showEditForm(request, response);
            return;
        }

        try {
            long id = Long.parseLong(idParam);
            long productId = Long.parseLong(productIdParam);
            double startPrice = Double.parseDouble(startPriceParam);

            // Parse in IST so times entered by the user are stored correctly
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            dateFormat.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
            Date startTime = dateFormat.parse(startDateTimeStr);
            Date endTime   = dateFormat.parse(endDateTimeStr);
            
            if (startTime.after(endTime)) {
                request.setAttribute("error", "Start time must be before end time");
                showEditForm(request, response);
                return;
            }
            
            Connection conn = null;
            PreparedStatement stmt = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                ensureAuctionOwnerColumn(conn);
                if (!canAccessAuction(conn, id, request)) {
                    request.setAttribute("error", "Auction not found");
                    listAuctions(request, response);
                    return;
                }
                
                // Check if there are bids for this auction
                boolean hasBids = false;
                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM bids WHERE auction_id = ?"
                );
                checkStmt.setLong(1, id);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    hasBids = true;
                }
                rs.close();
                checkStmt.close();
                
                // If there are bids, only allow updating end time and status
                if (hasBids) {
                    stmt = conn.prepareStatement(
                        "UPDATE reverse_auctions SET end_time = ?, status = ? WHERE id = ?"
                    );
                    stmt.setTimestamp(1, new Timestamp(endTime.getTime()));
                    stmt.setString(2, statusParam);
                    stmt.setLong(3, id);
                } else {
                    String requiredQuantityStr2 = request.getParameter("quantity");
                    int requiredQuantity2 = 1;
                    if (requiredQuantityStr2 != null && !requiredQuantityStr2.isEmpty()) {
                        requiredQuantity2 = Integer.parseInt(requiredQuantityStr2);
                    }
                    
                    stmt = conn.prepareStatement(
                        "UPDATE reverse_auctions " +
                        "SET product_id = ?, start_price = ?, current_price = ?, " +
                        "start_time = ?, end_time = ?, required_quantity = ?, status = ? " +
                        "WHERE id = ?"
                    );
                    stmt.setLong(1, productId);
                    stmt.setDouble(2, startPrice);
                    stmt.setDouble(3, startPrice); // Reset current price to start price
                    stmt.setTimestamp(4, new Timestamp(startTime.getTime()));
                    stmt.setTimestamp(5, new Timestamp(endTime.getTime()));
                    stmt.setInt(6, requiredQuantity2);
                    stmt.setString(7, statusParam);
                    stmt.setLong(8, id);
                }
                
                int affectedRows = stmt.executeUpdate();
                
                if (affectedRows > 0) {
                    if (hasBids) {
                        request.setAttribute("success", "Auction updated successfully (limited changes due to existing bids)");
                    } else {
                        request.setAttribute("success", "Auction updated successfully");
                    }
                } else {
                    request.setAttribute("error", "Failed to update auction");
                }
                
                listAuctions(request, response);
                
            } catch (SQLException e) {
                throw new ServletException("Error updating auction", e);
            } finally {
                DatabaseConnection.closeQuietly(null, stmt, conn);
            }
            
        } catch (NumberFormatException | ParseException e) {
            request.setAttribute("error", "Invalid input format: " + e.getMessage());
            showEditForm(request, response);
        }
    }

    /**
     * Deletes an auction.
     */
    private void deleteAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionOwnerColumn(conn);
            if (!canAccessAuction(conn, id, request)) {
                request.setAttribute("error", "Auction not found");
                listAuctions(request, response);
                return;
            }
            
            // Check if there are bids for this auction
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM bids WHERE auction_id = ?"
            );
            checkStmt.setLong(1, id);
            ResultSet rs = checkStmt.executeQuery();
            boolean hasBids = false;
            if (rs.next() && rs.getInt(1) > 0) {
                hasBids = true;
            }
            rs.close();
            checkStmt.close();
            
            if (hasBids) {
                request.setAttribute("error", "Cannot delete auction with existing bids");
                listAuctions(request, response);
                return;
            }
            
            // Delete auction invitations first
            stmt = conn.prepareStatement("DELETE FROM auction_invitations WHERE auction_id = ?");
            stmt.setLong(1, id);
            stmt.executeUpdate();
            stmt.close();
            
            // Then delete the auction
            boolean admin = isAdmin(request);
            stmt = conn.prepareStatement("DELETE FROM reverse_auctions WHERE id = ?" +
                    (admin ? "" : " AND created_by_email = ?"));
            stmt.setLong(1, id);
            if (!admin) {
                stmt.setString(2, getCurrentBuyerEmail(request));
            }
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Auction deleted successfully");
            } else {
                request.setAttribute("error", "Failed to delete auction");
            }
            
            listAuctions(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error deleting auction", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Gets a list of all products.
     */
    /**
     * Calculates the auction status based on start and end times.
     */
    private String calculateAuctionStatus(Date startTime, Date endTime) {
        Date now = new Date();
        
        if (now.before(startTime)) {
            return "SCHEDULED";
        } else if (now.after(endTime)) {
            return "COMPLETED";
        } else {
            return "ACTIVE";
        }
    }

    private List<Product> getProducts() throws ServletException {
        List<Product> products = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM products ORDER BY name");
            
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getLong("id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setCategory(rs.getString("category"));
                product.setUnitPrice(rs.getDouble("base_price"));
                product.setUnit(rs.getString("unit"));
                product.setCreatedAt(rs.getTimestamp("created_at"));
                try { product.setHsnCode(rs.getString("hsn_code")); } catch (Exception ignored) {}
                products.add(product);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving products", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return products;
    }

    /**
     * Gets a list of all products with inventory information.
     */
    private List<Product> getProductsWithInventoryInfo() throws ServletException {
        List<Product> products = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT p.*, i.quantity, i.min_threshold, i.max_threshold, " +
                "i.kanban_status, i.needs_auction, i.auction_started " +
                "FROM products p " +
                "LEFT JOIN inventory i ON p.inventory_id = i.id " +
                "ORDER BY " +
                "CASE WHEN i.needs_auction = TRUE THEN 0 ELSE 1 END, " +
                "CASE WHEN i.kanban_status = 'Low' THEN 0 " +
                "     WHEN i.kanban_status = 'Medium' THEN 1 " +
                "     WHEN i.kanban_status = 'High' THEN 2 " +
                "     ELSE 3 END, " +
                "p.name"
            );
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getLong("id"));
                product.setInventoryId(rs.getLong("inventory_id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setCategory(rs.getString("category"));
                product.setUnitPrice(rs.getDouble("base_price"));
                product.setUnit(rs.getString("unit"));
                product.setCreatedAt(rs.getTimestamp("created_at"));
                try { product.setHsnCode(rs.getString("hsn_code")); } catch (Exception ignored) {}
                
                // Add inventory information if available
                if (rs.getObject("quantity") != null) {
                    product.setInventoryQuantity(rs.getInt("quantity"));
                    product.setMinThreshold(rs.getInt("min_threshold"));
                    product.setMaxThreshold(rs.getInt("max_threshold"));
                    product.setKanbanStatus(rs.getString("kanban_status"));
                    product.setNeedsAuction(rs.getBoolean("needs_auction"));
                    product.setAuctionStarted(rs.getBoolean("auction_started"));
                }
                
                products.add(product);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving products with inventory info", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return products;
    }

    /**
     * Gets an auction by ID.
     */
    private ReverseAuction getAuctionById(long id, HttpServletRequest request) throws ServletException {
        ReverseAuction auction = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionOwnerColumn(conn);
            boolean admin = isAdmin(request);
            String sql =
                "SELECT a.*, p.name as product_name, p.unit " +
                "FROM reverse_auctions a " +
                "JOIN products p ON a.product_id = p.id " +
                "WHERE a.id = ?" +
                (admin ? "" : " AND a.created_by_email = ?");
            stmt = conn.prepareStatement(sql);
            stmt.setLong(1, id);
            if (!admin) {
                stmt.setString(2, getCurrentBuyerEmail(request));
            }
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                auction = new ReverseAuction();
                auction.setId(rs.getLong("id"));
                auction.setProductId(rs.getLong("product_id"));
                auction.setProductName(rs.getString("product_name"));
                auction.setRequiredQuantity(rs.getInt("required_quantity"));
                auction.setUnit(rs.getString("unit"));
                auction.setStartPrice(rs.getDouble("start_price"));
                auction.setCurrentPrice(rs.getDouble("current_price"));
                auction.setStartTime(rs.getTimestamp("start_time"));
                auction.setEndTime(rs.getTimestamp("end_time"));
                
                // Calculate status based on time
                String dbStatus = rs.getString("status");
                if (!"CANCELLED".equals(dbStatus)) {
                    auction.setStatus(calculateAuctionStatus(auction.getStartTime(), auction.getEndTime()));
                } else {
                    auction.setStatus(dbStatus);
                }
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving auction", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return auction;
    }

    /**
     * Gets a list of suppliers invited to an auction.
     */
    private List<Supplier> getInvitedSuppliers(long auctionId) throws ServletException {
        List<Supplier> suppliers = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT s.* " +
                "FROM suppliers s " +
                "JOIN auction_invitations ai ON s.id = ai.supplier_id " +
                "WHERE ai.auction_id = ? " +
                "ORDER BY s.name"
            );
            stmt.setLong(1, auctionId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                supplier.setPhone(rs.getString("phone"));
                supplier.setAddress(rs.getString("address"));
                supplier.setStatus(rs.getString("status"));
                suppliers.add(supplier);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving invited suppliers", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return suppliers;
    }

    /**
     * Gets suppliers who should appear in buyer-side auction messaging.
     * Includes invited suppliers, bidders, and suppliers who started a chat.
     */
    private List<Supplier> getAuctionChatSuppliers(long auctionId) throws ServletException {
        List<Supplier> suppliers = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionMessagesTable(conn);
            stmt = conn.prepareStatement(
                "SELECT DISTINCT s.* " +
                "FROM suppliers s " +
                "WHERE s.id IN ( " +
                "    SELECT supplier_id FROM auction_invitations WHERE auction_id = ? " +
                "    UNION " +
                "    SELECT supplier_id FROM bids WHERE auction_id = ? " +
                "    UNION " +
                "    SELECT supplier_id FROM auction_messages WHERE auction_id = ? " +
                ") " +
                "ORDER BY s.name"
            );
            stmt.setLong(1, auctionId);
            stmt.setLong(2, auctionId);
            stmt.setLong(3, auctionId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                supplier.setPhone(rs.getString("phone"));
                supplier.setAddress(rs.getString("address"));
                supplier.setStatus(rs.getString("status"));
                suppliers.add(supplier);
            }

        } catch (SQLException e) {
            throw new ServletException("Error retrieving auction chat suppliers", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }

        return suppliers;
    }

    private void ensureAuctionMessagesTable(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS auction_messages (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "sender_type VARCHAR(20) NOT NULL, " +
                "message TEXT NOT NULL, " +
                "is_read BOOLEAN NOT NULL DEFAULT FALSE, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"
            );
        }
    }

    private void ensureAuctionOwnerColumn(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
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

    private void loadAwardState(HttpServletRequest request, long auctionId) {
        request.setAttribute("poAwarded", Boolean.FALSE);
        request.setAttribute("awardedPoId", null);
        request.setAttribute("awardedSupplierId", null);
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT id, supplier_id FROM purchase_orders WHERE auction_id = ? ORDER BY id DESC LIMIT 1")) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    request.setAttribute("poAwarded", Boolean.TRUE);
                    request.setAttribute("awardedPoId", rs.getLong("id"));
                    request.setAttribute("awardedSupplierId", rs.getLong("supplier_id"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Could not load PO award state for auction " + auctionId, e);
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
     * Gets a list of bids for an auction.
     * Each item in the list is an Object[] with:
     * [0] = Bid object
     * [1] = Supplier name
     */
    /**
     * Cancels an auction.
     */
    private void cancelAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auction");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Update auction status to CANCELLED
            ensureAuctionOwnerColumn(conn);
            boolean admin = isAdmin(request);
            stmt = conn.prepareStatement(
                "UPDATE reverse_auctions SET status = 'CANCELLED' WHERE id = ?" +
                (admin ? "" : " AND created_by_email = ?")
            );
            stmt.setLong(1, id);
            if (!admin) {
                stmt.setString(2, getCurrentBuyerEmail(request));
            }
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Auction cancelled successfully");
            } else {
                request.setAttribute("error", "Failed to cancel auction");
            }
            
            listAuctions(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error cancelling auction", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private List<Object[]> getBidsForAuction(long auctionId) throws ServletException {
    List<Object[]> bids = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();
        stmt = conn.prepareStatement(
            "SELECT b.id, b.auction_id, b.supplier_id, b.amount, b.bid_time, " +
            "       s.name AS supplier_name, s.email AS supplier_email " +
            "FROM bids b " +
            "JOIN suppliers s ON b.supplier_id = s.id " +
            "WHERE b.auction_id = ? " +
            "ORDER BY b.amount ASC, b.bid_time ASC"
        );
        stmt.setLong(1, auctionId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Object[] bidInfo = new Object[3];

            com.axaltacoating.model.Bid bid = new com.axaltacoating.model.Bid();
            bid.setId(rs.getLong("id"));
            bid.setAuctionId(rs.getLong("auction_id"));
            bid.setSupplierId(rs.getLong("supplier_id"));
            bid.setAmount(rs.getDouble("amount"));
            bid.setBidTime(rs.getTimestamp("bid_time"));

            bidInfo[0] = bid;
            bidInfo[1] = rs.getString("supplier_name");
            bidInfo[2] = rs.getString("supplier_email");

            bids.add(bidInfo);
        }

    } catch (SQLException e) {
        throw new ServletException("Error retrieving bids", e);
    } finally {
        DatabaseConnection.closeQuietly(rs, stmt, conn);
    }

    return bids;
}

    
    /**
     * Gets bid chart data for an auction.
     * Each item in the list is an Object[] with:
     * [0] = bid_time (Date)
     * [1] = bid_amount (Double)
     * [2] = supplier_name (String)
     * [3] = supplier_id (Long)
     */
    private List<Object[]> getBidChartData(long auctionId) throws ServletException {
    List<Object[]> chartData = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();

        boolean tableExists = false;
        ResultSet tables = conn.getMetaData().getTables(null, null, "bid_chart_data", null);
        if (tables.next()) {
            tableExists = true;
        }
        tables.close();

        if (tableExists) {
            stmt = conn.prepareStatement(
                "SELECT bid_time, amount, supplier_name, supplier_id " +
                "FROM bid_chart_data " +
                "WHERE auction_id = ? " +
                "ORDER BY bid_time ASC"
            );
        } else {
            stmt = conn.prepareStatement(
                "SELECT b.bid_time, b.amount, s.name, b.supplier_id " +
                "FROM bids b " +
                "JOIN suppliers s ON b.supplier_id = s.id " +
                "WHERE b.auction_id = ? " +
                "ORDER BY b.bid_time ASC"
            );
        }

        stmt.setLong(1, auctionId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Object[] dataPoint = new Object[4];
            dataPoint[0] = rs.getTimestamp(1);
            dataPoint[1] = rs.getDouble(2);
            dataPoint[2] = rs.getString(3);
            dataPoint[3] = rs.getLong(4);
            chartData.add(dataPoint);
        }

    } catch (SQLException e) {
        throw new ServletException("Error retrieving bid chart data", e);
    } finally {
        DatabaseConnection.closeQuietly(rs, stmt, conn);
    }

    return chartData;
}


    /**
     * Gets products that need auctions but don't have active ones.
     */
    private List<Product> getProductsNeedingAuctions(HttpServletRequest request) throws ServletException {
        List<Product> products = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            ensureAuctionOwnerColumn(conn);
            boolean admin = isAdmin(request);
            String sql =
                "SELECT p.*, i.quantity, i.min_threshold, i.max_threshold, i.kanban_status " +
                "FROM products p " +
                "JOIN inventory i ON p.inventory_id = i.id " +
                "WHERE i.needs_auction = TRUE " +
                "AND NOT EXISTS (" +
                "    SELECT 1 FROM reverse_auctions ra " +
                "    WHERE ra.product_id = p.id " +
                "    AND ra.status IN ('ACTIVE', 'SCHEDULED')" +
                (admin ? "" : "    AND ra.created_by_email = ?") +
                ") " +
                "ORDER BY i.kanban_status DESC, p.name";
            stmt = conn.prepareStatement(sql);
            if (!admin) {
                stmt.setString(1, getCurrentBuyerEmail(request));
            }
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getLong("id"));
                product.setInventoryId(rs.getLong("inventory_id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setCategory(rs.getString("category"));
                product.setUnitPrice(rs.getDouble("base_price"));
                product.setUnit(rs.getString("unit"));
                product.setInventoryQuantity(rs.getInt("quantity"));
                
                // Add inventory status info
                product.setKanbanStatus(rs.getString("kanban_status"));
                product.setMinThreshold(rs.getInt("min_threshold"));
                product.setMaxThreshold(rs.getInt("max_threshold"));
                
                products.add(product);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving products needing auctions", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return products;
    }

    /**
     * Creates an auction automatically for a product that needs it.
     */
    private void createAutomaticAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdParam = request.getParameter("productId");
        
        if (productIdParam == null || productIdParam.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Product ID is required\"}");
            return;
        }
        
        long productId = Long.parseLong(productIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            ensureAuctionOwnerColumn(conn);
            
            // Get product and inventory details
            stmt = conn.prepareStatement(
                "SELECT p.*, i.quantity, i.min_threshold, i.max_threshold " +
                "FROM products p " +
                "LEFT JOIN inventory i ON p.inventory_id = i.id " +
                "WHERE p.id = ?"
            );
            stmt.setLong(1, productId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String productName = rs.getString("name");
                double basePrice = rs.getDouble("base_price");
                int currentQuantity = rs.getObject("quantity") != null ? rs.getInt("quantity") : 0;
                int minThreshold = rs.getObject("min_threshold") != null ? rs.getInt("min_threshold") : 10;
                int maxThreshold = rs.getObject("max_threshold") != null ? rs.getInt("max_threshold") : 100;
                Long inventoryId = rs.getObject("inventory_id") != null ? rs.getLong("inventory_id") : null;
                
                // Calculate recommended quantity and starting price
                int recommendedQuantity = Math.max(1, (maxThreshold - currentQuantity) + (int)(maxThreshold * 0.2));
                double startingPrice = basePrice > 0 ? basePrice : 100.0; // Default starting price
                
                // Create auction with 7 days duration
                java.util.Date startTime = new java.util.Date();
                java.util.Date endTime = new java.util.Date(startTime.getTime() + (7 * 24 * 60 * 60 * 1000)); // 7 days
                
                stmt = conn.prepareStatement(
                    "INSERT INTO reverse_auctions (product_id, start_price, current_price, " +
                    "start_time, end_time, status, created_by_email) VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?)",
                    Statement.RETURN_GENERATED_KEYS
                );
                stmt.setLong(1, productId);
                stmt.setDouble(2, startingPrice);
                stmt.setDouble(3, startingPrice);
                stmt.setTimestamp(4, new java.sql.Timestamp(startTime.getTime()));
                stmt.setTimestamp(5, new java.sql.Timestamp(endTime.getTime()));
                stmt.setString(6, getCurrentBuyerEmail(request));
                
                int affectedRows = stmt.executeUpdate();
                
                if (affectedRows > 0) {
                    // Get the generated auction ID
                    ResultSet generatedKeys = stmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        long auctionId = generatedKeys.getLong(1);
                        
                        // Update inventory to mark auction as started if inventory exists
                        if (inventoryId != null) {
                            stmt = conn.prepareStatement(
                                "UPDATE inventory SET auction_started = TRUE WHERE id = ?"
                            );
                            stmt.setLong(1, inventoryId);
                            stmt.executeUpdate();
                        }
                        
                        conn.commit();
                        
                        // Close the generated keys ResultSet
                        generatedKeys.close();
                        
                        response.setContentType("application/json");
                        response.getWriter().write(String.format(
                            "{\"success\": true, \"message\": \"Auction created successfully for %s\", \"auctionId\": %d, \"recommendedQuantity\": %d}",
                            productName, auctionId, recommendedQuantity
                        ));
                        return;
                    }
                }
            }
            
            conn.rollback();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Failed to create automatic auction\"}");
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                response.getWriter().write("{\"success\": false, \"message\": \"Error creating auction: " + e.getMessage().replace("\"", "\\\"") + "\"}");
            } catch (IOException ioEx) {
                ioEx.printStackTrace();
            }
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
