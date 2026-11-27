package com.axaltacoating.servlet;

import com.axaltacoating.model.User;
import com.axaltacoating.util.AuthUtil;
import com.axaltacoating.util.DatabaseConnection;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 * Servlet for handling settings and user management.
 */
@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 12582912)
public class SettingsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SettingsServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        boolean isAdmin = "ADMIN".equals(currentUser.getRole());
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "users"; // Default action
        }
        
        switch (action) {
            case "users":
                if (isAdmin) {
                    listUsers(request, response);
                } else {
                    showPersonalSettings(request, response);
                }
                break;
            case "editUser":
                if (!isAdmin) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                editUser(request, response);
                break;
            case "newUser":
                if (!isAdmin) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                showNewUserForm(request, response);
                break;
            case "viewBuyerDocument":
                viewBuyerDocument(request, response, currentUser);
                break;
            default:
                if (isAdmin) {
                    listUsers(request, response);
                } else {
                    showPersonalSettings(request, response);
                }
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        boolean isAdmin = "ADMIN".equals(currentUser.getRole());
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action is required");
            return;
        }
        
        switch (action) {
            case "createUser":
                if (!isAdmin) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                createUser(request, response);
                break;
            case "updateUser":
                if (!isAdmin) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                updateUser(request, response);
                break;
            case "deleteUser":
                if (!isAdmin) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                deleteUser(request, response);
                break;
            case "changePassword":
                changePassword(request, response, currentUser);
                break;
            case "updateBuyerProfile":
                updateBuyerProfile(request, response, currentUser);
                break;
            case "uploadBuyerDocument":
                uploadBuyerDocument(request, response, currentUser);
                break;
            case "deleteBuyerDocument":
                deleteBuyerDocument(request, response, currentUser);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }

    private void showPersonalSettings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("user");
        try (Connection conn = DatabaseConnection.getConnection()) {
            loadBuyerWorkspaceAttributes(conn, request, currentUser);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading buyer settings", e);
        }
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("isAdmin", false);
        request.getRequestDispatcher("/WEB-INF/views/settings/users.jsp").forward(request, response);
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        User currentUser = (User) request.getSession().getAttribute("user");
        
        try {
            conn = DatabaseConnection.getConnection();
            loadBuyerWorkspaceAttributes(conn, request, currentUser);
            
            // Get all users
            stmt = conn.prepareStatement(
                "SELECT * FROM users ORDER BY username"
            );
            rs = stmt.executeQuery();
            
            List<User> users = new ArrayList<>();
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setEmail(rs.getString("email"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                users.add(user);
            }
            
            request.setAttribute("users", users);
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("isAdmin", true);
            request.getRequestDispatcher("/WEB-INF/views/settings/users.jsp").forward(request, response);
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing users", e);
            throw new ServletException("Error listing users", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void editUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Get user by ID
            stmt = conn.prepareStatement(
                "SELECT * FROM users WHERE id = ?"
            );
            stmt.setInt(1, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setEmail(rs.getString("email"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                request.setAttribute("user", user);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user", e);
            throw new ServletException("Error getting user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void showNewUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
    }
    
    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String status = request.getParameter("status");
        
        // Validate input
        List<String> errors = validateUserInput(username, password, confirmPassword, role, email, status, true);
        
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("username", username);
            request.setAttribute("role", role);
            request.setAttribute("email", email);
            request.setAttribute("status", status);
            request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if username already exists
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE username = ?"
            );
            stmt.setString(1, username);
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Username already exists");
                request.setAttribute("errors", errors);
                request.setAttribute("username", username);
                request.setAttribute("role", role);
                request.setAttribute("email", email);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists
            stmt.close();
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE email = ?"
            );
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Email already exists");
                request.setAttribute("errors", errors);
                request.setAttribute("username", username);
                request.setAttribute("role", role);
                request.setAttribute("email", email);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
                return;
            }
            
            // Hash password
            String passwordHash = AuthUtil.hashPassword(password);
            
            // Insert new user
            stmt.close();
            stmt = conn.prepareStatement(
                "INSERT INTO users (username, password_hash, role, status, email) VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            stmt.setString(1, username);
            stmt.setString(2, passwordHash);
            stmt.setString(3, role);
            stmt.setString(4, status);
            stmt.setString(5, email);
            stmt.executeUpdate();
            
            // If user is a supplier, create supplier record
            if ("SUPPLIER".equals(role)) {
                rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int userId = rs.getInt(1);
                    createSupplierRecord(conn, userId, username, email);
                }
            }
            
            // Redirect to user list with success message
            request.getSession().setAttribute("successMessage", "User created successfully");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user", e);
            throw new ServletException("Error creating user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String status = request.getParameter("status");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        // Validate input (password can be empty for update)
        boolean passwordRequired = password != null && !password.trim().isEmpty();
        List<String> errors = validateUserInput(username, password, confirmPassword, role, email, status, passwordRequired);
        
        if (!errors.isEmpty()) {
            User user = new User();
            user.setId(Integer.parseInt(userId));
            user.setUsername(username);
            user.setRole(role);
            user.setStatus(status);
            user.setEmail(email);
            
            request.setAttribute("user", user);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if username already exists for another user
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE username = ? AND id != ?"
            );
            stmt.setString(1, username);
            stmt.setInt(2, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Username already exists");
                User user = new User();
                user.setId(Integer.parseInt(userId));
                user.setUsername(username);
                user.setRole(role);
                user.setStatus(status);
                user.setEmail(email);
                
                request.setAttribute("user", user);
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists for another user
            stmt.close();
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE email = ? AND id != ?"
            );
            stmt.setString(1, email);
            stmt.setInt(2, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Email already exists");
                User user = new User();
                user.setId(Integer.parseInt(userId));
                user.setUsername(username);
                user.setRole(role);
                user.setStatus(status);
                user.setEmail(email);
                
                request.setAttribute("user", user);
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
                return;
            }
            
            // Update user
            String sql;
            if (passwordRequired) {
                // Update with new password
                String passwordHash = AuthUtil.hashPassword(password);
                sql = "UPDATE users SET username = ?, password_hash = ?, role = ?, status = ?, email = ? WHERE id = ?";
                stmt.close();
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, passwordHash);
                stmt.setString(3, role);
                stmt.setString(4, status);
                stmt.setString(5, email);
                stmt.setInt(6, Integer.parseInt(userId));
            } else {
                // Update without changing password
                sql = "UPDATE users SET username = ?, role = ?, status = ?, email = ? WHERE id = ?";
                stmt.close();
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, role);
                stmt.setString(3, status);
                stmt.setString(4, email);
                stmt.setInt(5, Integer.parseInt(userId));
            }
            
            stmt.executeUpdate();
            
            // Check if user is a supplier and create supplier record if needed
            if ("SUPPLIER".equals(role)) {
                stmt.close();
                stmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM suppliers WHERE user_id = ?"
                );
                stmt.setInt(1, Integer.parseInt(userId));
                rs = stmt.executeQuery();
                rs.next();
                if (rs.getInt(1) == 0) {
                    createSupplierRecord(conn, Integer.parseInt(userId), username, email);
                }
            }
            
            // Redirect to user list with success message
            request.getSession().setAttribute("successMessage", "User updated successfully");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user", e);
            throw new ServletException("Error updating user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        // Don't allow deleting the admin user
        if ("1".equals(userId)) {
            request.getSession().setAttribute("errorMessage", "Cannot delete the admin user");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Delete user
            stmt = conn.prepareStatement(
                "DELETE FROM users WHERE id = ?"
            );
            stmt.setInt(1, Integer.parseInt(userId));
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                request.getSession().setAttribute("successMessage", "User deleted successfully");
            } else {
                request.getSession().setAttribute("errorMessage", "User not found");
            }
            
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting user", e);
            throw new ServletException("Error deleting user", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isBlank(oldPassword) || isBlank(newPassword) || isBlank(confirmPassword)) {
            request.getSession().setAttribute("pwdError", "Current password, new password, and confirmation are required.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }

        if (newPassword.length() < 6) {
            request.getSession().setAttribute("pwdError", "Password must be at least 6 characters.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.getSession().setAttribute("pwdError", "Passwords do not match.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT password_hash FROM users WHERE id = ?");
            stmt.setInt(1, currentUser.getId());
            rs = stmt.executeQuery();

            if (!rs.next()) {
                request.getSession().setAttribute("pwdError", "User account not found.");
                response.sendRedirect(request.getContextPath() + "/settings?action=users");
                return;
            }

            String storedPassword = rs.getString("password_hash");
            if (!AuthUtil.verifyPassword(oldPassword, storedPassword)) {
                request.getSession().setAttribute("pwdError", "Current password is incorrect.");
                response.sendRedirect(request.getContextPath() + "/settings?action=users");
                return;
            }

            rs.close();
            stmt.close();

            stmt = conn.prepareStatement("UPDATE users SET password_hash = ? WHERE id = ?");
            stmt.setString(1, AuthUtil.hashPassword(newPassword));
            stmt.setInt(2, currentUser.getId());
            stmt.executeUpdate();

            request.getSession().setAttribute("pwdSuccess", "Password updated successfully.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error changing password", e);
            throw new ServletException("Error changing password", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private List<String> validateUserInput(String username, String password, String confirmPassword, 
                                         String role, String email, String status, boolean passwordRequired) {
        List<String> errors = new ArrayList<>();
        
        if (username == null || username.trim().isEmpty()) {
            errors.add("Username is required");
        } else if (username.length() < 3 || username.length() > 50) {
            errors.add("Username must be between 3 and 50 characters");
        }
        
        if (passwordRequired) {
            if (password == null || password.trim().isEmpty()) {
                errors.add("Password is required");
            } else if (password.length() < 6) {
                errors.add("Password must be at least 6 characters");
            }
            
            if (confirmPassword == null || !confirmPassword.equals(password)) {
                errors.add("Passwords do not match");
            }
        }
        
        if (role == null || role.trim().isEmpty()) {
            errors.add("Role is required");
        } else if (!"ADMIN".equals(role) && !"USER".equals(role) && !"SUPPLIER".equals(role)) {
            errors.add("Invalid role");
        }
        
        if (email == null || email.trim().isEmpty()) {
            errors.add("Email is required");
        } else if (!email.matches("^[\\w.-]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            errors.add("Invalid email format");
        }
        
        if (status == null || status.trim().isEmpty()) {
            errors.add("Status is required");
        } else if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status) && !"BLOCKED".equals(status)) {
            errors.add("Invalid status");
        }
        
        return errors;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
    
    private void createSupplierRecord(Connection conn, int userId, String username, String email) throws SQLException {
        PreparedStatement stmt = null;
        
        try {
            stmt = conn.prepareStatement(
                "INSERT INTO suppliers (user_id, name, email, company_name, contact_person, status) VALUES (?, ?, ?, ?, ?, 'PENDING')"
            );
            stmt.setInt(1, userId);
            stmt.setString(2, username); // Supplier name
            stmt.setString(3, email); // Email
            stmt.setString(4, username + " Company"); // Default company name
            stmt.setString(5, email); // Use email as contact person
            stmt.executeUpdate();
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, null);
        }
    }

    private void ensureBuyerTables(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS buyer_documents (" +
                "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                "user_id INT NOT NULL, " +
                "doc_type VARCHAR(32) NOT NULL, " +
                "file_name VARCHAR(255) NOT NULL, " +
                "content_type VARCHAR(100), " +
                "file_data LONGBLOB, " +
                "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                "UNIQUE KEY uq_buyer_doc (user_id, doc_type)" +
                ")"
            );
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS buyer_workspace_profile (" +
                "user_id INT PRIMARY KEY, " +
                "company_name VARCHAR(255), " +
                "business_type VARCHAR(120), " +
                "designation VARCHAR(120), " +
                "phone VARCHAR(40), " +
                "gstin VARCHAR(32), " +
                "sourcing_category VARCHAR(150), " +
                "address TEXT, " +
                "monthly_spend VARCHAR(80), " +
                "payment_terms VARCHAR(80), " +
                "website VARCHAR(255), " +
                "buyer_brief TEXT, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );
        }
    }

    private void loadBuyerWorkspaceAttributes(Connection conn, HttpServletRequest request, User currentUser) throws SQLException {
        ensureBuyerTables(conn);
        Map<String, String> buyerDocs = new HashMap<>();
        try (PreparedStatement docStmt = conn.prepareStatement(
                "SELECT doc_type, file_name FROM buyer_documents WHERE user_id = ?")) {
            docStmt.setInt(1, currentUser.getId());
            try (ResultSet drs = docStmt.executeQuery()) {
                while (drs.next()) {
                    buyerDocs.put(drs.getString("doc_type"), drs.getString("file_name"));
                }
            }
        }
        Map<String, String> buyerProfile = new HashMap<>();
        try (PreparedStatement pStmt = conn.prepareStatement(
                "SELECT * FROM buyer_workspace_profile WHERE user_id = ?")) {
            pStmt.setInt(1, currentUser.getId());
            try (ResultSet prs = pStmt.executeQuery()) {
                if (prs.next()) {
                    buyerProfile.put("companyName", prs.getString("company_name"));
                    buyerProfile.put("businessType", prs.getString("business_type"));
                    buyerProfile.put("designation", prs.getString("designation"));
                    buyerProfile.put("phone", prs.getString("phone"));
                    buyerProfile.put("gstin", prs.getString("gstin"));
                    buyerProfile.put("sourcingCategory", prs.getString("sourcing_category"));
                    buyerProfile.put("address", prs.getString("address"));
                    buyerProfile.put("monthlySpend", prs.getString("monthly_spend"));
                    buyerProfile.put("paymentTerms", prs.getString("payment_terms"));
                    buyerProfile.put("website", prs.getString("website"));
                    buyerProfile.put("buyerBrief", prs.getString("buyer_brief"));
                }
            }
        }
        request.setAttribute("buyerDocs", buyerDocs);
        request.setAttribute("buyerProfile", buyerProfile);
    }

    private void updateBuyerProfile(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String companyName = request.getParameter("companyName");
        String businessType = request.getParameter("businessType");
        String designation = request.getParameter("designation");
        String phone = request.getParameter("phone");
        String gstin = request.getParameter("gstin");
        String sourcingCategory = request.getParameter("sourcingCategory");
        String address = request.getParameter("address");
        String monthlySpend = request.getParameter("monthlySpend");
        String paymentTerms = request.getParameter("paymentTerms");
        String website = request.getParameter("website");
        String buyerBrief = request.getParameter("buyerBrief");

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureBuyerTables(conn);
            if (!isBlank(email)) {
                try (PreparedStatement uStmt = conn.prepareStatement(
                        "UPDATE users SET email = ? WHERE id = ?")) {
                    uStmt.setString(1, email.trim());
                    uStmt.setInt(2, currentUser.getId());
                    uStmt.executeUpdate();
                    currentUser.setEmail(email.trim());
                    request.getSession().setAttribute("user", currentUser);
                }
            }
            try (PreparedStatement pStmt = conn.prepareStatement(
                    "INSERT INTO buyer_workspace_profile (user_id, company_name, business_type, designation, phone, gstin, sourcing_category, address, monthly_spend, payment_terms, website, buyer_brief) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE company_name=VALUES(company_name), business_type=VALUES(business_type), designation=VALUES(designation), " +
                    "phone=VALUES(phone), gstin=VALUES(gstin), sourcing_category=VALUES(sourcing_category), address=VALUES(address), " +
                    "monthly_spend=VALUES(monthly_spend), payment_terms=VALUES(payment_terms), website=VALUES(website), buyer_brief=VALUES(buyer_brief)")) {
                pStmt.setInt(1, currentUser.getId());
                pStmt.setString(2, companyName != null ? companyName.trim() : "");
                pStmt.setString(3, businessType != null ? businessType.trim() : "");
                pStmt.setString(4, designation != null ? designation.trim() : "");
                pStmt.setString(5, phone != null ? phone.trim() : "");
                pStmt.setString(6, gstin != null ? gstin.trim().toUpperCase() : "");
                pStmt.setString(7, sourcingCategory != null ? sourcingCategory.trim() : "");
                pStmt.setString(8, address != null ? address.trim() : "");
                pStmt.setString(9, monthlySpend != null ? monthlySpend.trim() : "");
                pStmt.setString(10, paymentTerms != null ? paymentTerms.trim() : "");
                pStmt.setString(11, website != null ? website.trim() : "");
                pStmt.setString(12, buyerBrief != null ? buyerBrief.trim() : "");
                pStmt.executeUpdate();
            }
            request.getSession().setAttribute("successMessage", "Buyer Workspace settings saved & synchronized!");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating buyer profile", e);
            request.getSession().setAttribute("errorMessage", "Unable to save buyer settings.");
        }
        response.sendRedirect(request.getContextPath() + "/settings?action=users");
    }

    private void uploadBuyerDocument(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String docType = request.getParameter("docType");
        if (!"PAN".equals(docType) && !"AADHAR".equals(docType) && !"REG_CERT".equals(docType)) {
            request.getSession().setAttribute("errorMessage", "Invalid document type.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }
        Part filePart = request.getPart("docFile");
        if (filePart == null || filePart.getSize() == 0) {
            request.getSession().setAttribute("errorMessage", "Please select a valid document file.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }
        String submittedName = filePart.getSubmittedFileName();
        String fileName = (submittedName != null && !submittedName.trim().isEmpty())
                ? new java.io.File(submittedName).getName()
                : docType + "_document.pdf";
        String contentType = filePart.getContentType();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (InputStream in = filePart.getInputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                baos.write(buf, 0, len);
            }
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureBuyerTables(conn);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO buyer_documents (user_id, doc_type, file_name, content_type, file_data) " +
                    "VALUES (?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE file_name = VALUES(file_name), content_type = VALUES(content_type), file_data = VALUES(file_data), uploaded_at = CURRENT_TIMESTAMP")) {
                stmt.setInt(1, currentUser.getId());
                stmt.setString(2, docType);
                stmt.setString(3, fileName);
                stmt.setString(4, contentType != null ? contentType : "application/octet-stream");
                stmt.setBytes(5, baos.toByteArray());
                stmt.executeUpdate();
            }
            request.getSession().setAttribute("successMessage", "Document \"" + fileName + "\" uploaded successfully!");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error uploading buyer document", e);
            request.getSession().setAttribute("errorMessage", "Error uploading document.");
        }
        response.sendRedirect(request.getContextPath() + "/settings?action=users");
    }

    private void viewBuyerDocument(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String docType = request.getParameter("docType");
        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureBuyerTables(conn);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT file_name, content_type, file_data FROM buyer_documents WHERE user_id = ? AND doc_type = ?")) {
                stmt.setInt(1, currentUser.getId());
                stmt.setString(2, docType);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String fileName = rs.getString("file_name");
                        String contentType = rs.getString("content_type");
                        byte[] data = rs.getBytes("file_data");
                        response.setContentType(contentType != null ? contentType : "application/octet-stream");
                        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName.replace("\"", "") + "\"");
                        if (data != null) {
                            response.setContentLength(data.length);
                            response.getOutputStream().write(data);
                        }
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error viewing buyer document", e);
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Document not found");
    }

    private void deleteBuyerDocument(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String docType = request.getParameter("docType");
        if (!"PAN".equals(docType) && !"AADHAR".equals(docType) && !"REG_CERT".equals(docType)) {
            request.getSession().setAttribute("errorMessage", "Invalid document type.");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }
        try (Connection conn = DatabaseConnection.getConnection()) {
            ensureBuyerTables(conn);
            try (PreparedStatement stmt = conn.prepareStatement(
                    "DELETE FROM buyer_documents WHERE user_id = ? AND doc_type = ?")) {
                stmt.setInt(1, currentUser.getId());
                stmt.setString(2, docType);
                stmt.executeUpdate();
            }
            request.getSession().setAttribute("successMessage", "Uploaded document removed successfully.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting buyer document", e);
            request.getSession().setAttribute("errorMessage", "Error deleting document.");
        }
        response.sendRedirect(request.getContextPath() + "/settings?action=users");
    }
}
