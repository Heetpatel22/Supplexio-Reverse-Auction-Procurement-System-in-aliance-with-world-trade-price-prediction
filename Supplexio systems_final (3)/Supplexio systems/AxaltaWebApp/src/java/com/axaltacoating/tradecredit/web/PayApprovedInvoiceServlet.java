package com.axaltacoating.tradecredit.web;

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

@WebServlet(name = "PayApprovedInvoiceServlet", urlPatterns = {"/payments/pay"})
public class PayApprovedInvoiceServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PayApprovedInvoiceServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        String returnTo = safeReturnPath(TradeCreditServletUtil.parameter(request, "returnTo"), "/user-po-view");
        try {
            String paymentMethod = TradeCreditServletUtil.parameter(request, "paymentMethod");
            if (paymentMethod.isEmpty()) {
                paymentMethod = "BANK_TRANSFER";
            }
            String transactionId = TradeCreditServletUtil.parameter(request, "transactionId");
            if (transactionId.isEmpty()) {
                transactionId = "TXN-" + System.currentTimeMillis();
            }
            String buyerEmail = TradeCreditServletUtil.currentBuyerEmail(request);
            if (request.getParameter("invoiceId") != null && !request.getParameter("invoiceId").trim().isEmpty()) {
                workflow.recordPayment(
                        TradeCreditServletUtil.requiredLong(request, "invoiceId"),
                        paymentMethod, transactionId, buyerEmail);
            } else {
                workflow.recordPaymentByPoId(
                        TradeCreditServletUtil.requiredLong(request, "poId"),
                        paymentMethod, transactionId, buyerEmail);
            }
            TradeCreditServletUtil.redirectSuccess(request, response, returnTo,
                    "Approved invoice paid successfully");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, returnTo, ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, returnTo, ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error paying invoice", ex);
            String detail = ex.getMessage() == null ? "unknown database error" : ex.getMessage();
            TradeCreditServletUtil.redirectError(request, response, returnTo,
                    "Database error while paying invoice: " + detail);
        }
    }

    private static String safeReturnPath(String path, String defaultPath) {
        if (path == null || path.trim().isEmpty()) {
            return defaultPath;
        }
        String trimmed = path.trim();
        if (!trimmed.startsWith("/") || trimmed.contains("://")) {
            return defaultPath;
        }
        return trimmed;
    }
}
