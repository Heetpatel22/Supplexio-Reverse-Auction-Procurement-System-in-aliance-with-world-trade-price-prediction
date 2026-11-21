package com.axaltacoating.tradecredit.web;

import com.axaltacoating.model.Supplier;
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

@WebServlet(name = "AcceptPurchaseOrderServlet", urlPatterns = {"/pos/accept"})
public class AcceptPurchaseOrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AcceptPurchaseOrderServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Supplier supplier = TradeCreditServletUtil.requireSupplier(request, response);
        if (supplier == null) {
            return;
        }
        try {
            long poId = TradeCreditServletUtil.requiredLong(request, "poId");
            workflow.acceptPurchaseOrder(poId, supplier.getId());
            TradeCreditServletUtil.redirectSuccess(request, response, "/supplier-po-view",
                    "PO accepted. Contract is now binding.");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error accepting purchase order", ex);
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", "Database error while accepting PO");
        }
    }
}
