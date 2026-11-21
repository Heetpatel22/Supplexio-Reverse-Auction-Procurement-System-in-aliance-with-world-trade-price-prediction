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

@WebServlet(name = "RecordGoodsReceiptServlet", urlPatterns = {"/goods-receipts/receive"})
public class RecordGoodsReceiptServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RecordGoodsReceiptServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!TradeCreditServletUtil.requireBuyer(request, response)) {
            return;
        }
        try {
            String receivedBy = TradeCreditServletUtil.parameter(request, "receivedBy");
            if (receivedBy.isEmpty()) {
                receivedBy = TradeCreditServletUtil.currentBuyerEmail(request);
            }
            long grnId = workflow.recordGoodsReceipt(
                    TradeCreditServletUtil.requiredLong(request, "poId"),
                    TradeCreditServletUtil.requiredInt(request, "receivedQuantity"),
                    TradeCreditServletUtil.parameter(request, "warehouseLocation"),
                    receivedBy);
            TradeCreditServletUtil.redirectSuccess(request, response, "/user-po-view",
                    "Goods Receipt logged. GRN id: " + grnId);
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error recording GRN", ex);
            TradeCreditServletUtil.redirectError(request, response, "/user-po-view", "Database error while recording GRN");
        }
    }
}
