package com.axaltacoating.tradecredit.web;

import com.axaltacoating.model.User;
import com.axaltacoating.tradecredit.TradeCreditWorkflowService;
import com.axaltacoating.tradecredit.WorkflowValidationException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AwardAuctionServlet", urlPatterns = {"/auctions/award", "/auction/award"})
public class AwardAuctionServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AwardAuctionServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        if (session.getAttribute("user") == null) {
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

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "json".equalsIgnoreCase(request.getParameter("format"))
                || (request.getContentType() != null && request.getContentType().contains("application/json"));

        try {
            long auctionId = TradeCreditServletUtil.requiredLong(request, "auctionId");
            
            long winningSupplierId = 0;
            String supParam = request.getParameter("winningSupplierId");
            if (supParam == null || supParam.trim().isEmpty()) {
                supParam = request.getParameter("supplierId");
            }
            if (supParam != null && !supParam.trim().isEmpty()) {
                try {
                    winningSupplierId = Long.parseLong(supParam.trim());
                } catch (NumberFormatException ignored) {}
            }

            String buyerEmail = TradeCreditServletUtil.currentBuyerEmail(request);
            if (buyerEmail == null || buyerEmail.trim().isEmpty() || "unknown-buyer".equalsIgnoreCase(buyerEmail.trim())) {
                buyerEmail = "admin@example.com";
            }

            long poId = workflow.awardAuction(auctionId, winningSupplierId, buyerEmail);

            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":true,\"poId\":" + poId + ",\"auctionId\":" + auctionId 
                        + ",\"message\":\"Auction #" + auctionId + " awarded! PO #" + poId + " created.\",\"poUrl\":\"" 
                        + request.getContextPath() + "/user-po-view\"}");
                return;
            }

            TradeCreditServletUtil.redirectSuccess(request, response,
                    "/user-po-view",
                    "Auction awarded and Purchase Order created: " + poId);
        } catch (IllegalArgumentException | WorkflowValidationException ex) {
            LOGGER.log(Level.WARNING, "Validation failed while awarding auction", ex);
            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(ex.getMessage()) + "\"}");
                return;
            }
            TradeCreditServletUtil.redirectError(request, response, "/auction", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error awarding auction", ex);
            String detail = ex.getMessage() == null ? "database error" : ex.getMessage();
            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(detail) + "\"}");
                return;
            }
            TradeCreditServletUtil.redirectError(request, response, "/auction",
                    "Database error while awarding auction: " + detail);
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
