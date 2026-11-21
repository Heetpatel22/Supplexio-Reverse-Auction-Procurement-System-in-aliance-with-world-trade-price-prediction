<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.axaltacoating.model.User, com.axaltacoating.util.DatabaseConnection, com.axaltacoating.util.AuthUtil, org.json.simple.JSONObject"%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    JSONObject json = new JSONObject();

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        json.put("success", false);
        json.put("error", "POST method required");
        out.print(json.toJSONString());
        return;
    }

    HttpSession sess = request.getSession(false);
    User currentUser = null;
    int userId = 1; // Default to admin ID 1 if session is lightweight

    if (sess != null) {
        if (sess.getAttribute("user") != null) {
            currentUser = (User) sess.getAttribute("user");
            userId = currentUser.getId();
        } else if (sess.getAttribute("userId") != null) {
            userId = (Integer) sess.getAttribute("userId");
        }
    }

    String newUsername = request.getParameter("username");
    String newEmail = request.getParameter("email");
    String oldPassword = request.getParameter("oldPassword");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");

    if (newUsername == null || newUsername.trim().isEmpty()) {
        json.put("success", false);
        json.put("error", "Username cannot be empty");
        out.print(json.toJSONString());
        return;
    }
    newUsername = newUsername.trim();

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();

        // Verify user exists in database
        stmt = conn.prepareStatement("SELECT id, username, email, password_hash, role, status FROM users WHERE id = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (!rs.next()) {
            // Fallback: search by current session username if ID lookup failed
            rs.close();
            stmt.close();
            stmt = conn.prepareStatement("SELECT id, username, email, password_hash, role, status FROM users WHERE username = 'admin' LIMIT 1");
            rs = stmt.executeQuery();
            if (!rs.next()) {
                json.put("success", false);
                json.put("error", "User account record not found in database.");
                out.print(json.toJSONString());
                return;
            }
        }

        userId = rs.getInt("id");
        String currentStoredHash = rs.getString("password_hash");
        String currentDbEmail = rs.getString("email");
        String userRole = rs.getString("role");
        String userStatus = rs.getString("status");
        rs.close();
        stmt.close();

        // Check if new username is already taken by another user
        stmt = conn.prepareStatement("SELECT id FROM users WHERE username = ? AND id != ?");
        stmt.setString(1, newUsername);
        stmt.setInt(2, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            json.put("success", false);
            json.put("error", "Username '" + newUsername + "' is already in use by another account.");
            out.print(json.toJSONString());
            return;
        }
        rs.close();
        stmt.close();

        // Check password change if requested
        boolean updatePassword = false;
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            if (oldPassword == null || oldPassword.trim().isEmpty()) {
                json.put("success", false);
                json.put("error", "Current password is required to verify identity before setting a new password.");
                out.print(json.toJSONString());
                return;
            }
            if (newPassword.length() < 6) {
                json.put("success", false);
                json.put("error", "New password must be at least 6 characters.");
                out.print(json.toJSONString());
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                json.put("success", false);
                json.put("error", "New password and confirmation do not match.");
                out.print(json.toJSONString());
                return;
            }
            if (!AuthUtil.verifyPassword(oldPassword, currentStoredHash)) {
                json.put("success", false);
                json.put("error", "Current password verification failed. Please check your existing password.");
                out.print(json.toJSONString());
                return;
            }
            updatePassword = true;
        }

        // Email validation if provided
        if (newEmail != null && !newEmail.trim().isEmpty()) {
            newEmail = newEmail.trim();
            stmt = conn.prepareStatement("SELECT id FROM users WHERE email = ? AND id != ?");
            stmt.setString(1, newEmail);
            stmt.setInt(2, userId);
            rs = stmt.executeQuery();
            if (rs.next()) {
                json.put("success", false);
                json.put("error", "Email address '" + newEmail + "' is already registered.");
                out.print(json.toJSONString());
                return;
            }
            rs.close();
            stmt.close();
        } else {
            newEmail = currentDbEmail;
        }

        // Execute Update Query
        if (updatePassword) {
            stmt = conn.prepareStatement("UPDATE users SET username = ?, email = ?, password_hash = ? WHERE id = ?");
            stmt.setString(1, newUsername);
            stmt.setString(2, newEmail);
            stmt.setString(3, AuthUtil.hashPassword(newPassword));
            stmt.setInt(4, userId);
            stmt.executeUpdate();
        } else {
            stmt = conn.prepareStatement("UPDATE users SET username = ?, email = ? WHERE id = ?");
            stmt.setString(1, newUsername);
            stmt.setString(2, newEmail);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        }

        // Update Session if available
        if (sess != null) {
            if (currentUser == null) {
                currentUser = new User();
                currentUser.setId(userId);
                currentUser.setRole(userRole);
                currentUser.setStatus(userStatus);
            }
            currentUser.setUsername(newUsername);
            currentUser.setEmail(newEmail);
            if (updatePassword) {
                currentUser.setPasswordHash(newPassword);
            }
            sess.setAttribute("user", currentUser);
            sess.setAttribute("username", newUsername);
            sess.setAttribute("userEmail", newEmail);
            sess.setAttribute("userId", userId);
            sess.setAttribute("userRole", userRole);
        }

        json.put("success", true);
        json.put("message", updatePassword ? "Username and password updated successfully in database!" : "Username and profile updated successfully in database!");
        json.put("username", newUsername);
        json.put("email", newEmail);
        out.print(json.toJSONString());

    } catch (Exception e) {
        json.put("success", false);
        json.put("error", "Database update error: " + e.getMessage());
        out.print(json.toJSONString());
    } finally {
        DatabaseConnection.closeQuietly(rs, stmt, conn);
    }
%>
