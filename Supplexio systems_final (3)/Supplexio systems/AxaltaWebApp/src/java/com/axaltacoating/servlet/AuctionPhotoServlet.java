package com.axaltacoating.servlet;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

@WebServlet(name = "AuctionPhotoServlet", urlPatterns = { "/auction-photos" })
@MultipartConfig(maxFileSize = 15728640, maxRequestSize = 18874368)
public class AuctionPhotoServlet extends HttpServlet {
    private static final int BUFFER_SIZE = 8192;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ensureLoggedIn(request, response);
        if (response.isCommitted()) {
            return;
        }

        String action = request.getParameter("action");
        if ("view".equals(action)) {
            streamPhoto(request, response);
            return;
        }

        listPhotos(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ensureLoggedIn(request, response);
        if (response.isCommitted()) {
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            deletePhoto(request, response);
        } else {
            uploadPhoto(request, response);
        }
    }

    private void deletePhoto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long photoId = parseLong(request.getParameter("id"));
        if (photoId < 0) {
            sendJsonError(response, HttpServletResponse.SC_BAD_REQUEST, "Photo ID is required");
            return;
        }

        UploadUser user = getUploadUser(request);

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureTable(conn);

            PhotoOwner owner = getPhotoOwner(conn, photoId);
            if (owner == null) {
                sendJsonError(response, HttpServletResponse.SC_NOT_FOUND, "Photo not found");
                return;
            }
            if (!canDeletePhoto(user, owner)) {
                sendJsonError(response, HttpServletResponse.SC_FORBIDDEN, "Photo not found or access denied");
                return;
            }

            int deleted;
            try (PreparedStatement del = conn.prepareStatement(
                    "DELETE FROM auction_product_photos WHERE id = ?")) {
                del.setLong(1, photoId);
                deleted = del.executeUpdate();
            }

            if (deleted == 0) {
                sendJsonError(response, HttpServletResponse.SC_FORBIDDEN, "Photo not found or access denied");
                return;
            }
        } catch (SQLException e) {
            throw new ServletException("Error deleting auction photo", e);
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"ok\":true}");
    }

    private void sendJsonError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        JSONObject obj = new JSONObject();
        obj.put("error", message);
        response.getWriter().write(obj.toJSONString());
    }

    private void uploadPhoto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long auctionId = parseLong(request.getParameter("auctionId"));
        if (auctionId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Auction ID is required");
            return;
        }

        Part photoPart = findUploadedPhotoPart(request);
        if (photoPart == null || photoPart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Photo file is required");
            return;
        }

        String fileName = getSubmittedFileName(photoPart);
        String contentType = photoPart.getContentType();
        if (!isSupportedImage(contentType, fileName)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Only image files are supported");
            return;
        }

        UploadUser user = getUploadUser(request);

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureTable(conn);
            Long productId = getProductId(conn, auctionId);
            if (productId == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Auction not found");
                return;
            }

            try (PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO auction_product_photos " +
                            "(auction_id, product_id, supplier_id, uploaded_by_type, uploaded_by_key, file_name, content_type, image_data) "
                            +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)")) {
                stmt.setLong(1, auctionId);
                stmt.setLong(2, productId);
                if (user.supplierId == null) {
                    stmt.setNull(3, java.sql.Types.BIGINT);
                } else {
                    stmt.setLong(3, user.supplierId);
                }
                stmt.setString(4, user.role);
                stmt.setString(5, user.key);
                stmt.setString(6, fileName);
                stmt.setString(7, normalizeContentType(contentType, fileName));
                stmt.setBinaryStream(8, photoPart.getInputStream(), photoPart.getSize());
                stmt.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + user.returnPath + auctionId + "&photos=uploaded");
        } catch (SQLException e) {
            throw new ServletException("Error saving auction photo", e);
        }
    }

    private void listPhotos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long auctionId = parseLong(request.getParameter("auctionId"));
        response.setContentType("application/json;charset=UTF-8");

        JSONArray photos = new JSONArray();
        if (auctionId <= 0) {
            response.getWriter().write(photos.toJSONString());
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureTable(conn);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT id, file_name, content_type, uploaded_by_type, uploaded_by_key, supplier_id, created_at " +
                            "FROM auction_product_photos WHERE auction_id = ? ORDER BY created_at DESC, id DESC")) {
                stmt.setLong(1, auctionId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        JSONObject photo = new JSONObject();
                        photo.put("id", rs.getLong("id"));
                        photo.put("fileName", rs.getString("file_name"));
                        photo.put("contentType", rs.getString("content_type"));
                        photo.put("uploadedBy", rs.getString("uploaded_by_type"));
                        PhotoOwner owner = new PhotoOwner(
                                rs.getString("uploaded_by_type"),
                                rs.getString("uploaded_by_key"),
                                getNullableLong(rs, "supplier_id"));
                        photo.put("canDelete", canDeletePhoto(getUploadUser(request), owner));
                        photo.put("createdAt", String.valueOf(rs.getTimestamp("created_at")));
                        photos.add(photo);
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Error loading auction photos", e);
        }

        response.getWriter().write(photos.toJSONString());
    }

    private void streamPhoto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long photoId = parseLong(request.getParameter("id"));
        if (photoId < 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Photo ID is required");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureTable(conn);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT file_name, content_type, image_data FROM auction_product_photos WHERE id = ?")) {
                stmt.setLong(1, photoId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }

                    String contentType = rs.getString("content_type");
                    String fileName = rs.getString("file_name");
                    response.setContentType(contentType != null ? contentType : "application/octet-stream");
                    response.setHeader("Content-Disposition",
                            "inline; filename=\"" + sanitizeFileName(fileName) + "\"");

                    try (InputStream input = rs.getBinaryStream("image_data");
                            OutputStream output = response.getOutputStream()) {
                        byte[] buffer = new byte[BUFFER_SIZE];
                        int length;
                        while ((length = input.read(buffer)) != -1) {
                            output.write(buffer, 0, length);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Error streaming auction photo", e);
        }
    }

    private void ensureLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null && (session.getAttribute("user") != null || session.getAttribute("supplier") != null)) {
            return;
        }
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
    }

    private Part findUploadedPhotoPart(HttpServletRequest request)
            throws IOException, ServletException {
        for (Part part : request.getParts()) {
            String partName = part.getName();
            if ("photo".equals(partName) && part.getSize() > 0) {
                return part;
            }
        }
        return null;
    }

    private UploadUser getUploadUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Supplier supplier = session == null ? null : (Supplier) session.getAttribute("supplier");
        if (supplier != null) {
            return new UploadUser("SUPPLIER", "SUPPLIER:" + supplier.getId(), supplier.getId(), false,
                    "/bidding?action=view&id=");
        }
        return new UploadUser("BUYER", getCurrentBuyerKey(request), null, isAdmin(request), "/auction?action=view&id=");
    }

    private void ensureTable(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            // Optional: Uncomment the next line if ensureTable also needs to force reset
            // stmt.executeUpdate("DROP TABLE IF EXISTS auction_product_photos");

            stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS auction_product_photos (" +
                            "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                            "auction_id BIGINT NOT NULL, " +
                            "product_id BIGINT NOT NULL, " +
                            "supplier_id BIGINT NULL, " +
                            "uploaded_by_type VARCHAR(20) NOT NULL, " +
                            "uploaded_by_key VARCHAR(255) NULL, " +
                            "file_name VARCHAR(255) NOT NULL, " +
                            "content_type VARCHAR(120) NOT NULL, " +
                            "image_data LONGBLOB NOT NULL, " +
                            "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                            ")");
            addColumnIfMissing(conn, "auction_product_photos", "uploaded_by_key", "VARCHAR(255) NULL");
        }
    }

    private void addColumnIfMissing(Connection conn, String table, String column, String definition) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("ALTER TABLE " + table + " ADD COLUMN " + column + " " + definition);
        } catch (SQLException e) {
            String message = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (!message.contains("duplicate") && !message.contains("exists")) {
                throw e;
            }
        }
    }

    private PhotoOwner getPhotoOwner(Connection conn, long photoId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT uploaded_by_type, uploaded_by_key, supplier_id FROM auction_product_photos WHERE id = ?")) {
            stmt.setLong(1, photoId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new PhotoOwner(
                        rs.getString("uploaded_by_type"),
                        rs.getString("uploaded_by_key"),
                        getNullableLong(rs, "supplier_id"));
            }
        }
    }

    private boolean canDeletePhoto(UploadUser user, PhotoOwner owner) {
        if (user == null || owner == null) {
            return false;
        }
        if (user.admin) {
            return true;
        }
        if (!user.role.equalsIgnoreCase(owner.role)) {
            return false;
        }
        if ("SUPPLIER".equalsIgnoreCase(user.role)) {
            return user.supplierId != null && user.supplierId.equals(owner.supplierId);
        }
        return user.key != null && owner.key != null && user.key.equalsIgnoreCase(owner.key);
    }

    private Long getNullableLong(ResultSet rs, String column) throws SQLException {
        long value = rs.getLong(column);
        return rs.wasNull() ? null : value;
    }

    private Long getProductId(Connection conn, long auctionId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT product_id FROM reverse_auctions WHERE id = ?")) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getLong("product_id") : null;
            }
        }
    }

    private boolean isSupportedImage(String contentType, String fileName) {
        if (contentType != null && contentType.toLowerCase().startsWith("image/")) {
            return true;
        }
        String lowerName = fileName == null ? "" : fileName.toLowerCase();
        return lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") || lowerName.endsWith(".png")
                || lowerName.endsWith(".gif") || lowerName.endsWith(".webp") || lowerName.endsWith(".bmp")
                || lowerName.endsWith(".svg") || lowerName.endsWith(".heic") || lowerName.endsWith(".heif")
                || lowerName.endsWith(".tif") || lowerName.endsWith(".tiff");
    }

    private String normalizeContentType(String contentType, String fileName) {
        if (contentType != null && !contentType.trim().isEmpty()) {
            return contentType;
        }
        String lowerName = fileName == null ? "" : fileName.toLowerCase();
        if (lowerName.endsWith(".heic")) {
            return "image/heic";
        }
        if (lowerName.endsWith(".heif")) {
            return "image/heif";
        }
        return "application/octet-stream";
    }

    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) {
            return "product-photo";
        }
        for (String token : header.split(";")) {
            token = token.trim();
            if (token.startsWith("filename=")) {
                return sanitizeFileName(token.substring(token.indexOf('=') + 1).trim().replace("\"", ""));
            }
        }
        return "product-photo";
    }

    private String sanitizeFileName(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return "product-photo";
        }
        return fileName.replace("\\", "/").replaceAll(".*/", "").replaceAll("[\\r\\n\"]", "_");
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception e) {
            return -1;
        }
    }

    private String getCurrentBuyerKey(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        if (user instanceof com.axaltacoating.model.User) {
            com.axaltacoating.model.User buyer = (com.axaltacoating.model.User) user;
            String email = buyer.getEmail();
            if (email != null && !email.trim().isEmpty()) {
                return "BUYER:" + email.trim().toLowerCase();
            }
            String username = buyer.getUsername();
            if (username != null && !username.trim().isEmpty()) {
                return "BUYER:" + username.trim().toLowerCase();
            }
        }
        Object userId = session == null ? null : session.getAttribute("userId");
        return userId == null ? null : "BUYER:" + String.valueOf(userId).trim().toLowerCase();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object userRole = session == null ? null : session.getAttribute("userRole");
        if ("ADMIN".equalsIgnoreCase(String.valueOf(userRole))) {
            return true;
        }
        Object user = session == null ? null : session.getAttribute("user");
        return user instanceof com.axaltacoating.model.User
                && "ADMIN".equalsIgnoreCase(((com.axaltacoating.model.User) user).getRole());
    }

    private static class UploadUser {
        final String role;
        final String key;
        final Long supplierId;
        final boolean admin;
        final String returnPath;

        UploadUser(String role, String key, Long supplierId, boolean admin, String returnPath) {
            this.role = role;
            this.key = key;
            this.supplierId = supplierId;
            this.admin = admin;
            this.returnPath = returnPath;
        }
    }

    private static class PhotoOwner {
        final String role;
        final String key;
        final Long supplierId;

        PhotoOwner(String role, String key, Long supplierId) {
            this.role = role;
            this.key = key;
            this.supplierId = supplierId;
        }
    }
}
