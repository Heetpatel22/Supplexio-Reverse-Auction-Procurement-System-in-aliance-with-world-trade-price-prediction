package com.axaltacoating.servlet;

import com.axaltacoating.model.Inventory;
import com.axaltacoating.util.DatabaseConnection;
import com.google.gson.Gson;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/inventory"})
public class InventoryServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(InventoryServlet.class.getName());
    private static final int ITEMS_PER_PAGE = 20;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "delete":
                deleteInventoryItem(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "list":
                listInventory(request, response);
                break;
            case "ajaxList":
                ajaxListInventory(request, response);
                break;
            default:
                listInventory(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "delete":
                deleteInventoryItem(request, response);
                break;
            case "add":
                addInventoryItem(request, response);
                break;
            case "adjustStock":
                adjustStock(request, response);
                break;
            case "update":
                updateInventory(request, response);
                break;
            case "startAuction":
                startAuction(request, response);
                break;
            case "getProductId":
                getProductId(request, response);
                break;
            default:
                listInventory(request, response);
                break;
        }
    }

    private void listInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int totalItems = getTotalInventoryCount();
            int totalPages = (int) Math.ceil((double) totalItems / ITEMS_PER_PAGE);
            
            // Get initial inventory data for the first page
            List<Inventory> inventoryList = getInventoryPage(1, ITEMS_PER_PAGE);

            request.setAttribute("totalItems", totalItems);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("inventory", inventoryList);
            List<Map<String, Object>> catalogProducts = getCatalogProducts();
            request.setAttribute("catalogProducts", catalogProducts);
            request.setAttribute("catalogProductsJson", gson.toJson(catalogProducts));

            List<Map<String, Object>> allClientItems = getAllInventoryForClient();
            request.setAttribute("inventoryJson", gson.toJson(allClientItems));

            request.getRequestDispatcher("/WEB-INF/views/inventory/list.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory count", e);
        }
    }

    private List<Map<String, Object>> getAllInventoryForClient() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT i.id, i.item_name, i.quantity, i.min_threshold, i.max_threshold, i.kanban_status, i.needs_auction, i.auction_started, "
                   + "MAX(p.hsn_code) AS hsn_code, MAX(p.category) AS category, MAX(p.base_price) AS base_price, MAX(p.unit) AS unit "
                   + "FROM inventory i "
                   + "LEFT JOIN products p ON (p.inventory_id = i.id OR p.name COLLATE utf8mb4_unicode_ci = i.item_name COLLATE utf8mb4_unicode_ci) "
                   + "GROUP BY i.id, i.item_name, i.quantity, i.min_threshold, i.max_threshold, i.kanban_status, i.needs_auction, i.auction_started "
                   + "ORDER BY i.id ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                int id = rs.getInt("id");
                String name = rs.getString("item_name");
                int qty = rs.getInt("quantity");
                int min = rs.getInt("min_threshold");
                int max = rs.getInt("max_threshold");
                if (max <= 0) max = min * 2;
                String status = rs.getString("kanban_status");
                if (status == null || status.trim().isEmpty()) {
                    if (qty <= min) status = "Low";
                    else if (qty >= max * 0.85) status = "High";
                    else status = "Medium";
                }
                boolean needsAuction = rs.getBoolean("needs_auction") || "Low".equalsIgnoreCase(status);
                String hsn = rs.getString("hsn_code");
                if (hsn == null || hsn.trim().isEmpty()) {
                    hsn = "N/A";
                }
                double basePrice = rs.getDouble("base_price");
                if (basePrice <= 0) basePrice = 2625.0;
                String unit = rs.getString("unit");
                if (unit == null || unit.trim().isEmpty()) {
                    unit = "pcs";
                }

                map.put("id", id);
                map.put("name", name);
                map.put("qty", qty);
                map.put("min", min);
                map.put("max", max);
                map.put("hsn", hsn);
                map.put("status", status);
                map.put("auction", needsAuction ? "Auction Needed" : "Not Needed");
                map.put("unit", unit);
                map.put("price", basePrice);

                if (name != null && name.toLowerCase().contains("bitumen")) {
                    map.put("surge", 7.4);
                    map.put("priceCeiling", 2625.0);
                } else if (name != null && name.toLowerCase().contains("titanium")) {
                    map.put("surge", 6.4);
                    map.put("priceCeiling", 3291.75);
                }

                list.add(map);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading inventory for client", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        return list;
    }

    private void ajaxListInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            page = Integer.parseInt(pageStr);
        }

        String searchTerm = request.getParameter("search");
        String kanbanFilter = request.getParameter("filter");
        String auctionFilter = request.getParameter("auctionFilter");

        try {
            List<Inventory> inventoryList = getFilteredInventoryPage(page, ITEMS_PER_PAGE, searchTerm, kanbanFilter, auctionFilter);
            int totalItems = getFilteredInventoryCount(searchTerm, kanbanFilter, auctionFilter);
            int totalPages = (int) Math.ceil((double) totalItems / ITEMS_PER_PAGE);

            // Calculate summary counts from all inventory (not just current page)
            Map<String, Integer> summaryCounts = getInventorySummaryCounts();

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("inventory", inventoryList);
            responseData.put("currentPage", page);
            responseData.put("totalPages", totalPages);
            responseData.put("totalItems", totalItems);
            responseData.put("lowCount", summaryCounts.get("lowCount"));
            responseData.put("mediumCount", summaryCounts.get("mediumCount"));
            responseData.put("highCount", summaryCounts.get("highCount"));
            responseData.put("auctionNeededCount", summaryCounts.get("auctionNeededCount"));

            Gson gson = new Gson();
            String jsonResponse = gson.toJson(responseData);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonResponse);

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory", e);
        }
    }

    private int getTotalInventoryCount() throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM inventory");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private List<Inventory> getInventoryPage(int page, int itemsPerPage) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        int offset = (page - 1) * itemsPerPage;

        String sql = "SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, auction_started, needs_auction " +
                     "FROM inventory ORDER BY item_name LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemsPerPage);
            stmt.setInt(2, offset);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Inventory item = new Inventory(
                        rs.getInt("id"),
                        rs.getString("item_name"),
                        rs.getInt("quantity"),
                        rs.getInt("min_threshold"),
                        rs.getInt("max_threshold")
                    );
                    item.setKanbanStatus(rs.getString("kanban_status"));
                    item.setAuctionStarted(rs.getBoolean("auction_started"));
                    boolean dbNeeds = rs.getBoolean("needs_auction");
                    if (item.getQuantity() <= item.getMinThreshold() || "Low".equalsIgnoreCase(item.getKanbanStatus())) {
                        item.setNeedsAuction(true);
                    } else {
                        item.setNeedsAuction(dbNeeds);
                    }
                    inventoryList.add(item);
                }
            }
        }

        return inventoryList;
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inventory");
            return;
        }

        int id = Integer.parseInt(idParam);
        Inventory item = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM inventory WHERE id = ?");
            stmt.setInt(1, id);
            rs = stmt.executeQuery();

            if (rs.next()) {
                item = new Inventory(
                    rs.getInt("id"),
                    rs.getString("item_name"),
                    rs.getInt("quantity"),
                    rs.getInt("min_threshold"),
                    rs.getInt("max_threshold")
                );
                item.setKanbanStatus(rs.getString("kanban_status"));
                item.setAuctionStarted(rs.getBoolean("auction_started"));
            }

            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("/WEB-INF/views/inventory/edit.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/inventory");
            }

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory item for edit", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String quantityParam = request.getParameter("quantity");
        String minThresholdParam = request.getParameter("minThreshold");
        String maxThresholdParam = request.getParameter("maxThreshold");

        if (idParam == null || idParam.isEmpty() || quantityParam == null || quantityParam.isEmpty() ||
            minThresholdParam == null || minThresholdParam.isEmpty() || maxThresholdParam == null || maxThresholdParam.isEmpty()) {
            request.setAttribute("error", "All fields are required");
            listInventory(request, response);
            return;
        }

        int id = Integer.parseInt(idParam);
        int quantity = Integer.parseInt(quantityParam);
        int minThreshold = Integer.parseInt(minThresholdParam);
        int maxThreshold = Integer.parseInt(maxThresholdParam);

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            Inventory updatedItem = new Inventory(id, "", quantity, minThreshold, maxThreshold);
            updatedItem.setQuantity(quantity); // This will trigger the Kanban status update

            stmt = conn.prepareStatement("UPDATE inventory SET quantity = ?, min_threshold = ?, max_threshold = ?, kanban_status = ?, needs_auction = ? WHERE id = ?");
            stmt.setInt(1, quantity);
            stmt.setInt(2, minThreshold);
            stmt.setInt(3, maxThreshold);
            stmt.setString(4, updatedItem.getKanbanStatus());
            stmt.setBoolean(5, updatedItem.getNeedsAuction());
            stmt.setInt(6, id);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                // Synchronize product stock_quantity
                try (PreparedStatement prodStmt = conn.prepareStatement("UPDATE products SET stock_quantity = ? WHERE inventory_id = ?")) {
                    prodStmt.setInt(1, quantity);
                    prodStmt.setLong(2, id);
                    prodStmt.executeUpdate();
                } catch (SQLException pe) {
                    LOGGER.log(Level.WARNING, "Failed to sync product stock_quantity for inventory id=" + id, pe);
                }

                LOGGER.log(Level.INFO, "Inventory item updated: ID = {0}, New Quantity = {1}, New Kanban Status = {2}", 
                    new Object[]{id, quantity, updatedItem.getKanbanStatus()});
                
                if (checkIfAuctionNeeded(updatedItem)) {
                    request.setAttribute("auctionNeeded", true);
                    request.setAttribute("itemId", id);
                    LOGGER.log(Level.WARNING, "Auction needed for item: ID = {0}", id);
                    triggerAutomaticAuction(id);
                }

                request.setAttribute("success", "Inventory updated successfully");
            } else {
                LOGGER.log(Level.WARNING, "Failed to update inventory item: ID = {0}", id);
                request.setAttribute("error", "Failed to update inventory");
            }

            listInventory(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating inventory", e);
            throw new ServletException("Error updating inventory", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private boolean checkIfAuctionNeeded(Inventory item) {
        return "Low".equals(item.getKanbanStatus()) && !item.isAuctionStarted();
    }

    private void triggerAutomaticAuction(int itemId) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("UPDATE inventory SET auction_started = TRUE WHERE id = ?");
            stmt.setInt(1, itemId);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                LOGGER.log(Level.INFO, "Automatic auction triggered for item: ID = {0}", itemId);
            } else {
                LOGGER.log(Level.WARNING, "Failed to trigger automatic auction for item: ID = {0}", itemId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error triggering automatic auction", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private void startAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String itemIdParam = request.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            sendJsonResponse(response, false, "Item ID is required");
            return;
        }

        int itemId = Integer.parseInt(itemIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("UPDATE inventory SET auction_started = TRUE WHERE id = ?");
            stmt.setInt(1, itemId);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                sendJsonResponse(response, true, "Auction started successfully");
            } else {
                sendJsonResponse(response, false, "Failed to start auction");
            }

        } catch (SQLException e) {
            sendJsonResponse(response, false, "Error starting auction: " + e.getMessage());
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Gets the product ID associated with an inventory item.
     */
    private void getProductId(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String itemIdParam = request.getParameter("itemId");
        
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            sendJsonResponse(response, false, "Item ID is required");
            return;
        }
        
        int itemId = Integer.parseInt(itemIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT p.id as product_id FROM products p " +
                "WHERE p.inventory_id = ?"
            );
            stmt.setInt(1, itemId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                long productId = rs.getLong("product_id");
                
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"productId\": %d}",
                    productId
                ));
            } else {
                sendJsonResponse(response, false, "No product found for this inventory item");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting product ID", e);
            sendJsonResponse(response, false, "Error getting product ID: " + e.getMessage());
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

    private List<Inventory> getFilteredInventoryPage(int page, int itemsPerPage, String searchTerm, String kanbanFilter, String auctionFilter) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        int offset = (page - 1) * itemsPerPage;

        StringBuilder sql = new StringBuilder("SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, auction_started, needs_auction FROM inventory WHERE 1=1");
        List<Object> parameters = new ArrayList<>();

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND LOWER(item_name) LIKE ?");
            parameters.add("%" + searchTerm.toLowerCase() + "%");
        }

        // Add kanban status filter
        if (kanbanFilter != null && !kanbanFilter.trim().isEmpty()) {
            sql.append(" AND kanban_status = ?");
            parameters.add(kanbanFilter);
        }

        // Add auction filter
        if (auctionFilter != null && !auctionFilter.trim().isEmpty()) {
            switch (auctionFilter) {
                case "needed":
                    sql.append(" AND needs_auction = TRUE");
                    break;
                case "started":
                    sql.append(" AND auction_started = TRUE");
                    break;
                case "none":
                    sql.append(" AND needs_auction = FALSE AND auction_started = FALSE");
                    break;
            }
        }

        sql.append(" ORDER BY item_name LIMIT ? OFFSET ?");
        parameters.add(itemsPerPage);
        parameters.add(offset);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Inventory item = new Inventory(
                        rs.getInt("id"),
                        rs.getString("item_name"),
                        rs.getInt("quantity"),
                        rs.getInt("min_threshold"),
                        rs.getInt("max_threshold")
                    );
                    item.setKanbanStatus(rs.getString("kanban_status"));
                    item.setAuctionStarted(rs.getBoolean("auction_started"));
                    boolean dbNeeds = rs.getBoolean("needs_auction");
                    if (item.getQuantity() <= item.getMinThreshold() || "Low".equalsIgnoreCase(item.getKanbanStatus())) {
                        item.setNeedsAuction(true);
                    } else {
                        item.setNeedsAuction(dbNeeds);
                    }
                    inventoryList.add(item);
                }
            }
        }

        return inventoryList;
    }

    private int getFilteredInventoryCount(String searchTerm, String kanbanFilter, String auctionFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM inventory WHERE 1=1");
        List<Object> parameters = new ArrayList<>();

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND LOWER(item_name) LIKE ?");
            parameters.add("%" + searchTerm.toLowerCase() + "%");
        }

        // Add kanban status filter
        if (kanbanFilter != null && !kanbanFilter.trim().isEmpty()) {
            sql.append(" AND kanban_status = ?");
            parameters.add(kanbanFilter);
        }

        // Add auction filter
        if (auctionFilter != null && !auctionFilter.trim().isEmpty()) {
            switch (auctionFilter) {
                case "needed":
                    sql.append(" AND needs_auction = TRUE");
                    break;
                case "started":
                    sql.append(" AND auction_started = TRUE");
                    break;
                case "none":
                    sql.append(" AND needs_auction = FALSE AND auction_started = FALSE");
                    break;
            }
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private Map<String, Integer> getInventorySummaryCounts() throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("lowCount", 0);
        counts.put("mediumCount", 0);
        counts.put("highCount", 0);
        counts.put("auctionNeededCount", 0);

        String sql = "SELECT kanban_status, needs_auction, COUNT(*) as count FROM inventory GROUP BY kanban_status, needs_auction";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("kanban_status");
                boolean needsAuction = rs.getBoolean("needs_auction");
                int count = rs.getInt("count");

                switch (status) {
                    case "Low":
                        counts.put("lowCount", counts.get("lowCount") + count);
                        break;
                    case "Medium":
                        counts.put("mediumCount", counts.get("mediumCount") + count);
                        break;
                    case "High":
                        counts.put("highCount", counts.get("highCount") + count);
                        break;
                }

                if (needsAuction) {
                    counts.put("auctionNeededCount", counts.get("auctionNeededCount") + count);
                }
            }
        }

        return counts;
    }

    private void addInventoryItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productIdStr = request.getParameter("productId");
        String customName = request.getParameter("itemName");
        String quantityStr = request.getParameter("quantity");
        String minThresholdStr = request.getParameter("minThreshold");
        String maxThresholdStr = request.getParameter("maxThreshold");
        String unit = request.getParameter("unit");
        String category = request.getParameter("category");
        String hsnCode = request.getParameter("hsn");
        if (hsnCode == null || hsnCode.trim().isEmpty()) {
            hsnCode = request.getParameter("hsnCode");
        }

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With")) ||
                         "application/json".equalsIgnoreCase(request.getHeader("Accept")) ||
                         "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (quantityStr == null || quantityStr.trim().isEmpty() ||
            minThresholdStr == null || minThresholdStr.trim().isEmpty() ||
            maxThresholdStr == null || maxThresholdStr.trim().isEmpty()) {
            if (isAjax) {
                sendJsonResponse(response, false, "Stock quantity, Min Threshold, and Max Threshold are required.");
            } else {
                request.setAttribute("error", "Stock quantity, Min Threshold, and Max Threshold are required.");
                listInventory(request, response);
            }
            return;
        }

        try {
            int quantity = Integer.parseInt(quantityStr.trim());
            int minThreshold = Integer.parseInt(minThresholdStr.trim());
            int maxThreshold = Integer.parseInt(maxThresholdStr.trim());

            if (minThreshold >= maxThreshold) {
                if (isAjax) {
                    sendJsonResponse(response, false, "Minimum threshold must be less than Maximum threshold.");
                } else {
                    request.setAttribute("error", "Minimum threshold must be less than Maximum threshold.");
                    listInventory(request, response);
                }
                return;
            }

            String itemName = "";
            Long productId = null;
            if (productIdStr != null && !productIdStr.trim().isEmpty() && !"custom".equalsIgnoreCase(productIdStr.trim())) {
                try {
                    productId = Long.parseLong(productIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                if (customName != null && !customName.trim().isEmpty()) {
                    itemName = customName.trim();
                }
                if (itemName == null || itemName.trim().isEmpty()) {
                    String reqItemName = request.getParameter("itemName");
                    if (reqItemName != null && !reqItemName.trim().isEmpty()) {
                        itemName = reqItemName.trim();
                    }
                }

                if ((itemName == null || itemName.trim().isEmpty()) && productId != null && productId > 0) {
                    try (PreparedStatement stmt = conn.prepareStatement("SELECT name, chapter_name, unit, hsn_code FROM global_trade_products WHERE id = ?")) {
                        stmt.setLong(1, productId);
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                itemName = rs.getString("name");
                                if (category == null || category.trim().isEmpty()) category = rs.getString("chapter_name");
                                if (unit == null || unit.trim().isEmpty()) unit = rs.getString("unit");
                                if (hsnCode == null || hsnCode.trim().isEmpty()) hsnCode = rs.getString("hsn_code");
                            }
                        }
                    }
                    if (itemName == null || itemName.trim().isEmpty()) {
                        try (PreparedStatement stmt = conn.prepareStatement("SELECT name, category, unit, hsn_code FROM products WHERE id = ?")) {
                            stmt.setLong(1, productId);
                            try (ResultSet rs = stmt.executeQuery()) {
                                if (rs.next()) {
                                    itemName = rs.getString("name");
                                    if (category == null || category.trim().isEmpty()) category = rs.getString("category");
                                    if (unit == null || unit.trim().isEmpty()) unit = rs.getString("unit");
                                    if (hsnCode == null || hsnCode.trim().isEmpty()) hsnCode = rs.getString("hsn_code");
                                }
                            }
                        }
                    }
                }

                if (itemName == null || itemName.trim().isEmpty()) {
                    if (isAjax) {
                        sendJsonResponse(response, false, "Please select a catalog product or enter an item name.");
                    } else {
                        request.setAttribute("error", "Please select a catalog product or enter an item name.");
                        listInventory(request, response);
                    }
                    return;
                }

                Inventory item = new Inventory(0, itemName, quantity, minThreshold, maxThreshold);
                String kanbanStatus = item.getKanbanStatus();
                boolean needsAuction = item.getNeedsAuction();

                long inventoryId = 0;
                String insertSql = "INSERT INTO inventory (item_name, quantity, min_threshold, max_threshold, kanban_status, needs_auction, auction_started, created_at, updated_at) " +
                                   "VALUES (?, ?, ?, ?, ?, ?, FALSE, NOW(), NOW())";
                try (PreparedStatement stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, itemName);
                    stmt.setInt(2, quantity);
                    stmt.setInt(3, minThreshold);
                    stmt.setInt(4, maxThreshold);
                    stmt.setString(5, kanbanStatus);
                    stmt.setBoolean(6, needsAuction);
                    stmt.executeUpdate();

                    try (ResultSet gk = stmt.getGeneratedKeys()) {
                        if (gk.next()) {
                            inventoryId = gk.getLong(1);
                        }
                    }
                }

                Long existingProdId = null;
                if (hsnCode != null && !hsnCode.trim().isEmpty()) {
                    try (PreparedStatement stmt = conn.prepareStatement("SELECT id FROM products WHERE hsn_code = ? LIMIT 1")) {
                        stmt.setString(1, hsnCode.trim());
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) existingProdId = rs.getLong("id");
                        }
                    }
                }
                if (existingProdId == null && itemName != null && !itemName.trim().isEmpty()) {
                    try (PreparedStatement stmt = conn.prepareStatement("SELECT id FROM products WHERE name = ? LIMIT 1")) {
                        stmt.setString(1, itemName.trim());
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) existingProdId = rs.getLong("id");
                        }
                    }
                }

                double priceVal = 1000.0;
                try {
                    String pStr = request.getParameter("price");
                    if (pStr != null && !pStr.trim().isEmpty()) priceVal = Double.parseDouble(pStr.trim());
                } catch (Exception ignored) {}

                if (existingProdId != null) {
                    try (PreparedStatement stmt = conn.prepareStatement(
                        "UPDATE products SET inventory_id = ?, stock_quantity = ?, category = COALESCE(?, category), unit = COALESCE(?, unit), hsn_code = COALESCE(?, hsn_code) WHERE id = ?")) {
                        stmt.setLong(1, inventoryId);
                        stmt.setInt(2, quantity);
                        stmt.setString(3, category);
                        stmt.setString(4, unit);
                        stmt.setString(5, hsnCode);
                        stmt.setLong(6, existingProdId);
                        stmt.executeUpdate();
                    }
                } else {
                    try (PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO products (name, category, unit, base_price, stock_quantity, inventory_id, hsn_code, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())")) {
                        stmt.setString(1, itemName);
                        stmt.setString(2, (category != null && !category.trim().isEmpty()) ? category : "General");
                        stmt.setString(3, (unit != null && !unit.trim().isEmpty()) ? unit : "pcs");
                        stmt.setDouble(4, priceVal);
                        stmt.setInt(5, quantity);
                        stmt.setLong(6, inventoryId);
                        stmt.setString(7, (hsnCode != null && !hsnCode.trim().isEmpty()) ? hsnCode.trim() : null);
                        stmt.executeUpdate();
                    }
                }

                conn.commit();
                String successMsg = "Successfully added '" + itemName + "' to inventory with stock: " + quantity + " " + (unit != null ? unit : "units") + " (" + kanbanStatus + " stock level).";
                if (isAjax) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    String cleanName = itemName != null ? itemName.replace("\"", "\\\"") : "";
                    String cleanHsn = hsnCode != null ? hsnCode.replace("\"", "\\\"") : "N/A";
                    String cleanMsg = successMsg.replace("\"", "\\\"");
                    response.getWriter().write(String.format(
                        "{\"success\": true, \"status\": \"success\", \"message\": \"%s\", \"itemId\": %d, \"name\": \"%s\", \"quantity\": %d, \"minThreshold\": %d, \"maxThreshold\": %d, \"kanbanStatus\": \"%s\", \"needsAuction\": %b, \"hsnCode\": \"%s\"}",
                        cleanMsg, inventoryId, cleanName, quantity, minThreshold, maxThreshold, kanbanStatus, needsAuction, cleanHsn
                    ));
                    return;
                }
                request.setAttribute("success", successMsg);
            }
        } catch (NumberFormatException e) {
            if (isAjax) {
                sendJsonResponse(response, false, "Quantity and thresholds must be valid integers.");
            } else {
                request.setAttribute("error", "Quantity and thresholds must be valid integers.");
                listInventory(request, response);
            }
            return;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding inventory item", e);
            if (isAjax) {
                sendJsonResponse(response, false, "Database error: " + e.getMessage());
            } else {
                request.setAttribute("error", "Database error: " + e.getMessage());
                listInventory(request, response);
            }
            return;
        }

        listInventory(request, response);
    }

    private void adjustStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String op = request.getParameter("operation"); // "add", "deduct", "set"
        String amountStr = request.getParameter("amount");
        String reason = request.getParameter("reason");

        if (idStr == null || idStr.trim().isEmpty() || amountStr == null || amountStr.trim().isEmpty()) {
            sendJsonResponse(response, false, "Item ID and adjustment amount are required");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            int amount = Integer.parseInt(amountStr.trim());
            if (op == null || op.trim().isEmpty()) {
                op = "set";
            }

            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                int currentQty = 0;
                int minThreshold = 0;
                int maxThreshold = 0;
                String itemName = "";

                try (PreparedStatement stmt = conn.prepareStatement("SELECT item_name, quantity, min_threshold, max_threshold FROM inventory WHERE id = ? FOR UPDATE")) {
                    stmt.setInt(1, id);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            itemName = rs.getString("item_name");
                            currentQty = rs.getInt("quantity");
                            minThreshold = rs.getInt("min_threshold");
                            maxThreshold = rs.getInt("max_threshold");
                        } else {
                            conn.rollback();
                            sendJsonResponse(response, false, "Inventory item not found");
                            return;
                        }
                    }
                }

                int newQty;
                if ("add".equalsIgnoreCase(op)) {
                    newQty = currentQty + amount;
                } else if ("deduct".equalsIgnoreCase(op)) {
                    newQty = Math.max(0, currentQty - amount);
                } else { // "set"
                    newQty = Math.max(0, amount);
                }

                Inventory helper = new Inventory(id, itemName, newQty, minThreshold, maxThreshold);
                String newStatus = helper.getKanbanStatus();
                boolean needsAuction = helper.getNeedsAuction();

                try (PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE inventory SET quantity = ?, kanban_status = ?, needs_auction = ?, " +
                    "auction_started = CASE WHEN ? > min_threshold THEN FALSE ELSE auction_started END, " +
                    "updated_at = NOW() WHERE id = ?")) {
                    stmt.setInt(1, newQty);
                    stmt.setString(2, newStatus);
                    stmt.setBoolean(3, needsAuction);
                    stmt.setInt(4, newQty);
                    stmt.setInt(5, id);
                    stmt.executeUpdate();
                }

                // Sync products table
                try (PreparedStatement stmt = conn.prepareStatement("UPDATE products SET stock_quantity = ? WHERE inventory_id = ?")) {
                    stmt.setInt(1, newQty);
                    stmt.setLong(2, id);
                    stmt.executeUpdate();
                }

                conn.commit();

                String message = "Stock for '" + itemName + "' updated to " + newQty + " (Status: " + newStatus + ")";
                boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With")) ||
                                 "application/json".equalsIgnoreCase(request.getHeader("Accept")) ||
                                 "true".equalsIgnoreCase(request.getParameter("ajax"));

                if (isAjax) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write(String.format(
                        "{\"success\": true, \"message\": \"%s\", \"id\": %d, \"newQuantity\": %d, \"kanbanStatus\": \"%s\", \"needsAuction\": %b}",
                        message, id, newQty, newStatus, needsAuction
                    ));
                } else {
                    request.setAttribute("success", message);
                    listInventory(request, response);
                }
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "Invalid number format for item ID or amount");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adjusting stock", e);
            sendJsonResponse(response, false, "Database error: " + e.getMessage());
        }
    }

    private List<Map<String, Object>> getCatalogProducts() {
        List<Map<String, Object>> products = new ArrayList<>();
        String sql = "SELECT p.id, COALESCE(p.hsn_code, '') AS hsn_code, p.name, " +
                     "COALESCE(p.category, 'General') AS chapter_name, COALESCE(p.unit, 'pcs') AS unit, " +
                     "COALESCE(p.base_price, 1000.0) AS benchmark_price_inr, COALESCE(p.description, p.name) AS description " +
                     "FROM products p WHERE p.hsn_code NOT IN (SELECT hsn_code FROM global_trade_products WHERE hsn_code IS NOT NULL) OR p.hsn_code IS NULL " +
                     "UNION ALL " +
                     "SELECT g.id, g.hsn_code, g.name, COALESCE(g.chapter_name, 'General') AS chapter_name, " +
                     "COALESCE(g.unit, 'pcs') AS unit, COALESCE(g.benchmark_price_inr, 1000.0) AS benchmark_price_inr, " +
                     "COALESCE(g.description, g.name) AS description " +
                     "FROM global_trade_products g " +
                     "ORDER BY name ASC, hsn_code ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("id", rs.getLong("id"));
                p.put("hsnCode", rs.getString("hsn_code"));
                String name = rs.getString("name");
                p.put("name", name != null ? name.replace("\"", "&quot;") : "");
                String cat = rs.getString("chapter_name");
                p.put("category", cat != null ? cat.replace("\"", "&quot;") : "General");
                p.put("unit", rs.getString("unit"));
                p.put("basePrice", rs.getDouble("benchmark_price_inr"));
                p.put("description", rs.getString("description"));
                products.add(p);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error loading catalog products from global_trade_products", e);
        }
        return products;
    }

    private void deleteInventoryItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            sendJsonResponse(response, false, "Item ID is required");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            String itemName = "";

            try (Connection conn = DatabaseConnection.getConnection()) {
                conn.setAutoCommit(false);

                // Get item name first
                try (PreparedStatement stmt = conn.prepareStatement("SELECT item_name FROM inventory WHERE id = ?")) {
                    stmt.setInt(1, id);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            itemName = rs.getString("item_name");
                        } else {
                            conn.rollback();
                            sendJsonResponse(response, false, "Inventory item not found");
                            return;
                        }
                    }
                }

                // Unlink any products pointing to this inventory item
                try (PreparedStatement stmt = conn.prepareStatement("UPDATE products SET inventory_id = NULL, stock_quantity = 0 WHERE inventory_id = ?")) {
                    stmt.setLong(1, id);
                    stmt.executeUpdate();
                }

                // Delete from inventory
                try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM inventory WHERE id = ?")) {
                    stmt.setInt(1, id);
                    stmt.executeUpdate();
                }

                conn.commit();

                String message = "Product '" + itemName + "' (ID #" + id + ") removed from inventory successfully.";
                LOGGER.info(message);

                boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With")) ||
                                 "application/json".equalsIgnoreCase(request.getHeader("Accept")) ||
                                 "true".equalsIgnoreCase(request.getParameter("ajax"));

                if (isAjax) {
                    sendJsonResponse(response, true, message);
                } else {
                    request.setAttribute("success", message);
                    listInventory(request, response);
                }
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "Invalid item ID format");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting inventory item", e);
            sendJsonResponse(response, false, "Database error: " + e.getMessage());
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String jsonResponse = String.format("{\"success\": %b, \"message\": \"%s\"}", success, message);
        response.getWriter().write(jsonResponse);
    }

}