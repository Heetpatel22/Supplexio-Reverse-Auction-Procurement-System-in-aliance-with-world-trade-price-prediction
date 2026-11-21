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

@WebServlet(name = "CloseTransactionServlet", urlPatterns = {"/transactions/close"})
public class CloseTransactionServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CloseTransactionServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        try {
            workflow.closeTransaction(
                    TradeCreditServletUtil.requiredLong(request, "poId"),
                    TradeCreditServletUtil.currentBuyerEmail(request));
            TradeCreditServletUtil.redirectSuccess(request, response, "/user-po-view",
                    "Transaction lifecycle finalized and closed");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error closing transaction", ex);
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", "Database error while closing transaction");
        }
    }
}
