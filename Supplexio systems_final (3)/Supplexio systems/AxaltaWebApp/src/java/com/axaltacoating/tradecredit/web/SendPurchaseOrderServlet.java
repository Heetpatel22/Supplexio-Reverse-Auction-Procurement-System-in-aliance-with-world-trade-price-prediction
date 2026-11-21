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

@WebServlet(name = "ManualSendPurchaseOrderServlet", urlPatterns = {"/pos/send"})
public class SendPurchaseOrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SendPurchaseOrderServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        try {
            long poId = TradeCreditServletUtil.requiredLong(request, "poId");
            boolean executiveApproved = TradeCreditServletUtil.checked(request, "executiveApproved");
            workflow.sendPurchaseOrder(poId, TradeCreditServletUtil.currentBuyerEmail(request), executiveApproved);
            TradeCreditServletUtil.redirectSuccess(request, response, "/user-po-view",
                    "PO manually sent to supplier");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error sending purchase order", ex);
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", "Database error while sending PO");
        }
    }
}
