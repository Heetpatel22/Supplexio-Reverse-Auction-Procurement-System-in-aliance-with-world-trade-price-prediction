package com.axaltacoating.servlet;

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

/**
 * Servlet for managing the 5,384+ global trade product catalog
 * integrated with BACI lakehouse and 1D-ResNet neural price forecasting.
 */
@WebServlet(name = "ProductServlet", urlPatterns = {"/product"})
public class ProductServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProductServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "ajaxData":
            case "data":
                handleAjaxData(request, response);
                break;
            case "new":
            case "edit":
                // Custom product creation is disabled because arbitrary products lack
                // historical BACI trade data required for 1D-ResNet neural price forecasting.
                response.sendRedirect(request.getContextPath() + "/product");
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Lists product catalog overview with chapter categories and total count.
     */
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<String> categories = new ArrayList<>();
        int totalCount = 5384;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            
            // Distinct chapters/categories across all commodities
            rs = stmt.executeQuery(
                "SELECT DISTINCT chapter_name FROM global_trade_products " +
                "WHERE chapter_name IS NOT NULL AND chapter_name != '' " +
                "ORDER BY chapter_name"
            );
            while (rs.next()) {
                String cat = rs.getString("chapter_name");
                if (cat != null && !cat.trim().isEmpty()) {
                    categories.add(cat.trim());
                }
            }
            rs.close();
            
            // Total commodity count
            rs = stmt.executeQuery("SELECT COUNT(*) FROM global_trade_products");
            if (rs.next()) {
                totalCount = rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading product catalog metadata", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        request.setAttribute("categories", categories);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/WEB-INF/views/product/list.jsp").forward(request, response);
    }

    /**
     * Server-side DataTables AJAX handler querying 5,384+ commodities.
     * Supports real-time search across commodity name, HSN code, chapter, and description.
     */
    private void handleAjaxData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        
        int draw = 1;
        try {
            String drawParam = request.getParameter("draw");
            if (drawParam != null && !drawParam.isEmpty()) {
                draw = Integer.parseInt(drawParam);
            }
        } catch (NumberFormatException ignored) {}
        
        int start = 0;
        try {
            String startParam = request.getParameter("start");
            if (startParam != null && !startParam.isEmpty()) {
                start = Math.max(0, Integer.parseInt(startParam));
            }
        } catch (NumberFormatException ignored) {}
        
        int length = 10;
        try {
            String lengthParam = request.getParameter("length");
            if (lengthParam != null && !lengthParam.isEmpty()) {
                length = Math.min(100, Math.max(1, Integer.parseInt(lengthParam)));
            }
        } catch (NumberFormatException ignored) {}
        
        // Search term (from DataTables search[value] or custom search param)
        String searchValue = request.getParameter("search[value]");
        if (searchValue == null || searchValue.trim().isEmpty()) {
            searchValue = request.getParameter("search");
        }
        
        // Category filter
        String category = request.getParameter("category");
        if (category != null && category.trim().isEmpty()) {
            category = null;
        }
        
        // Sorting column
        String orderColIndex = request.getParameter("order[0][column]");
        String orderDir = request.getParameter("order[0][dir]");
        String orderByColumn = "id";
        if ("0".equals(orderColIndex)) {
            orderByColumn = "id";
        } else if ("1".equals(orderColIndex)) {
            orderByColumn = "name";
        } else if ("2".equals(orderColIndex)) {
            orderByColumn = "description";
        } else if ("3".equals(orderColIndex)) {
            orderByColumn = "benchmark_price_inr";
        } else if ("4".equals(orderColIndex)) {
            orderByColumn = "unit";
        } else if ("5".equals(orderColIndex)) {
            orderByColumn = "trend";
        }
        
        String orderDirection = "ASC";
        if (orderDir != null && "desc".equalsIgnoreCase(orderDir.trim())) {
            orderDirection = "DESC";
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        int recordsTotal = 5384;
        int recordsFiltered = 0;
        List<Map<String, Object>> dataList = new ArrayList<>();
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Total records in master catalog
            Statement totalStmt = conn.createStatement();
            ResultSet totalRs = totalStmt.executeQuery("SELECT COUNT(*) FROM global_trade_products");
            if (totalRs.next()) {
                recordsTotal = totalRs.getInt(1);
            }
            totalRs.close();
            totalStmt.close();
            
            // Build WHERE clause
            StringBuilder whereClause = new StringBuilder(" WHERE 1=1 ");
            List<Object> params = new ArrayList<>();
            
            if (category != null && !category.trim().isEmpty()) {
                whereClause.append(" AND chapter_name = ? ");
                params.add(category.trim());
            }
            
            if (searchValue != null && !searchValue.trim().isEmpty()) {
                String like = "%" + searchValue.trim() + "%";
                whereClause.append(" AND (name LIKE ? OR hsn_code LIKE ? OR description LIKE ? OR chapter_name LIKE ?) ");
                params.add(like);
                params.add(like);
                params.add(like);
                params.add(like);
            }
            
            // Filtered records count
            String countSql = "SELECT COUNT(*) FROM global_trade_products " + whereClause.toString();
            stmt = conn.prepareStatement(countSql);
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            rs = stmt.executeQuery();
            if (rs.next()) {
                recordsFiltered = rs.getInt(1);
            }
            rs.close();
            stmt.close();
            
            // Paginated data query
            String dataSql = "SELECT id, hsn_code, name, description, chapter, chapter_name, benchmark_price_inr, unit, trend, trend_pct, top_suppliers "
                    + "FROM global_trade_products " + whereClause.toString()
                    + " ORDER BY " + orderByColumn + " " + orderDirection
                    + " LIMIT ? OFFSET ?";
            stmt = conn.prepareStatement(dataSql);
            int pIdx = 1;
            for (Object p : params) {
                stmt.setObject(pIdx++, p);
            }
            stmt.setInt(pIdx++, length);
            stmt.setInt(pIdx++, start);
            
            rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("hsnCode", rs.getString("hsn_code"));
                row.put("name", rs.getString("name"));
                
                String desc = rs.getString("description");
                if (desc == null || desc.trim().isEmpty()) {
                    desc = rs.getString("name");
                }
                row.put("description", desc);
                
                row.put("chapter", rs.getString("chapter"));
                row.put("chapterName", rs.getString("chapter_name"));
                row.put("benchmarkPriceInr", rs.getDouble("benchmark_price_inr"));
                row.put("unit", rs.getString("unit") != null ? rs.getString("unit") : "pcs");
                row.put("trend", rs.getString("trend") != null ? rs.getString("trend") : "STABLE");
                row.put("trendPct", rs.getDouble("trend_pct"));
                row.put("topSuppliers", rs.getString("top_suppliers"));
                row.put("status", "Active");
                dataList.add(row);
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error querying global trade products", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("draw", draw);
        result.put("recordsTotal", recordsTotal);
        result.put("recordsFiltered", recordsFiltered);
        result.put("data", dataList);
        
        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(result));
    }

    /**
     * Deletes product (legacy fallback).
     */
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            Connection conn = null;
            PreparedStatement stmt = null;
            try {
                long id = Long.parseLong(idParam);
                conn = DatabaseConnection.getConnection();
                stmt = conn.prepareStatement("DELETE FROM products WHERE id = ?");
                stmt.setLong(1, id);
                stmt.executeUpdate();
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Delete product skipped or failed", e);
            } finally {
                DatabaseConnection.closeQuietly(null, stmt, conn);
            }
        }
        response.sendRedirect(request.getContextPath() + "/product");
    }
}
