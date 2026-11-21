package com.axaltacoating.servlet;

import com.axaltacoating.tradecredit.TradeCreditWorkflowService;
import com.axaltacoating.tradecredit.WorkflowValidationException;
import com.axaltacoating.tradecredit.web.TradeCreditServletUtil;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Legacy endpoint retained for old links; delegates to the manual PO send workflow.
 */
@WebServlet(name = "SendPOToSupplierServlet", urlPatterns = {"/send-po-to-supplier"})
public class SendPOToSupplierServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SendPOToSupplierServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        try {
            long poId = TradeCreditServletUtil.requiredLong(request, "poId");
            workflow.sendPurchaseOrder(poId, TradeCreditServletUtil.currentBuyerEmail(request), true);
            TradeCreditServletUtil.redirectSuccess(request, response, "/user-po-view",
                    "PO manually sent to supplier");
        } catch (IllegalArgumentException | WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error sending PO to supplier", ex);
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", "Database error while sending PO");
        }
    }
}
