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

@WebServlet(name = "AdjustGoodsReceiptServlet", urlPatterns = {"/goods-receipts/adjust"})
public class AdjustGoodsReceiptServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdjustGoodsReceiptServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        try {
            workflow.updateReceivedQuantity(
                    TradeCreditServletUtil.requiredLong(request, "poId"),
                    TradeCreditServletUtil.requiredInt(request, "receivedQuantity"),
                    TradeCreditServletUtil.parameter(request, "warehouseLocation"),
                    TradeCreditServletUtil.currentBuyerEmail(request));
            TradeCreditServletUtil.redirectSuccess(request, response, "/user-po-view",
                    "Received quantity updated. Supplier can now upload a matching invoice.");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adjusting GRN quantity", ex);
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view",
                    "Database error while updating received quantity");
        }
    }
}
