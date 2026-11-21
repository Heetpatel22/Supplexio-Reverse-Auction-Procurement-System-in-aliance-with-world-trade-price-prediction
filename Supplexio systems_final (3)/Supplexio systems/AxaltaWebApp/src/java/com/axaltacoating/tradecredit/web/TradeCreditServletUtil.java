package com.axaltacoating.tradecredit.web;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.model.User;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public final class TradeCreditServletUtil {
    private TradeCreditServletUtil() {
    }

    public static long requiredLong(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing required parameter: " + name);
        }
        return Long.parseLong(value.trim());
    }

    public static int requiredInt(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing required parameter: " + name);
        }
        return Integer.parseInt(value.trim());
    }

    public static BigDecimal requiredMoney(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing required parameter: " + name);
        }
        return new BigDecimal(value.trim()).setScale(2, BigDecimal.ROUND_HALF_UP);
    }

    public static String parameter(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    public static boolean checked(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return "true".equalsIgnoreCase(value) || "on".equalsIgnoreCase(value) || "yes".equalsIgnoreCase(value) || "1".equals(value);
    }

    public static boolean requireBuyer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        Object role = session == null ? null : session.getAttribute("userRole");
        if (user != null && !"SUPPLIER".equalsIgnoreCase(String.valueOf(role))) {
            return true;
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return false;
    }

    public static Supplier requireSupplier(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object supplier = session == null ? null : session.getAttribute("supplier");
        if (supplier instanceof Supplier) {
            return (Supplier) supplier;
        }
        response.sendRedirect(request.getContextPath() + "/supplier-login.jsp");
        return null;
    }

    public static String currentBuyerEmail(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        if (user instanceof User) {
            User typed = (User) user;
            if (typed.getEmail() != null && !typed.getEmail().trim().isEmpty()) {
                return typed.getEmail().trim().toLowerCase();
            }
            if (typed.getUsername() != null && !typed.getUsername().trim().isEmpty()) {
                return typed.getUsername().trim().toLowerCase();
            }
        }
        Object userId = session == null ? null : session.getAttribute("userId");
        return userId == null ? "unknown-buyer" : String.valueOf(userId);
    }

    public static void redirectSuccess(HttpServletRequest request, HttpServletResponse response, String target, String message)
            throws IOException {
        request.getSession().setAttribute("success", message);
        response.sendRedirect(request.getContextPath() + target);
    }

    public static void redirectError(HttpServletRequest request, HttpServletResponse response, String target, String message)
            throws IOException {
        request.getSession().setAttribute("error", message);
        response.sendRedirect(request.getContextPath() + target);
    }
}
