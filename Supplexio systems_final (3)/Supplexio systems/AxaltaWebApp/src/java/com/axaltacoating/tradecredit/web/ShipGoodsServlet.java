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

@WebServlet(name = "ShipGoodsServlet", urlPatterns = {"/shipments/ship"})
public class ShipGoodsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ShipGoodsServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Supplier supplier = TradeCreditServletUtil.requireSupplier(request, response);
        if (supplier == null) {
            return;
        }
        try {
            workflow.uploadAdvancedShippingNotice(
                    TradeCreditServletUtil.requiredLong(request, "poId"),
                    supplier.getId(),
                    TradeCreditServletUtil.parameter(request, "asnNumber"),
                    TradeCreditServletUtil.parameter(request, "carrier"),
                    TradeCreditServletUtil.parameter(request, "trackingNumber"));
            TradeCreditServletUtil.redirectSuccess(request, response, "/supplier-po-view",
                    "Advanced Shipping Notice uploaded and PO moved to SHIPPED");
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error uploading ASN", ex);
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", "Database error while shipping goods");
        }
    }
}
