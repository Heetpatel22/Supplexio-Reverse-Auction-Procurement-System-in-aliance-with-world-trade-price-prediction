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

@WebServlet(name = "RequestSupplierInvoiceServlet", urlPatterns = {"/invoices/request"})
public class RequestSupplierInvoiceServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RequestSupplierInvoiceServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        String returnTo = "/user-po-view";
        try {
            long poId = TradeCreditServletUtil.requiredLong(request, "poId");
            workflow.requestSupplierInvoice(poId, TradeCreditServletUtil.currentBuyerEmail(request));
            response.sendRedirect(request.getContextPath() + returnTo);
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, returnTo, ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, returnTo, ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error requesting supplier invoice", ex);
            TradeCreditServletUtil.redirectError(request, response, returnTo,
                    "Database error while requesting invoice: " + ex.getMessage());
        }
    }
}
