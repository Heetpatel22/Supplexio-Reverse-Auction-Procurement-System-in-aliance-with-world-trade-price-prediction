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

@WebServlet(name = "UploadCommercialInvoiceServlet", urlPatterns = {"/invoices/upload"})
public class UploadCommercialInvoiceServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UploadCommercialInvoiceServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Supplier supplier = TradeCreditServletUtil.requireSupplier(request, response);
        if (supplier == null) {
            return;
        }
        try {
            long invoiceId = workflow.uploadCommercialInvoice(
                    TradeCreditServletUtil.requiredLong(request, "poId"),
                    supplier.getId(),
                    TradeCreditServletUtil.parameter(request, "invoiceNumber"),
                    TradeCreditServletUtil.requiredMoney(request, "invoicePrice"),
                    TradeCreditServletUtil.requiredInt(request, "invoiceQuantity"));
            TradeCreditServletUtil.redirectSuccess(request, response, "/supplier-po-view",
                    "Commercial invoice uploaded, three-way match passed, payment is pending. Invoice id: " + invoiceId);
        } catch (IllegalArgumentException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (WorkflowValidationException ex) {
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error uploading commercial invoice", ex);
            TradeCreditServletUtil.redirectError(request, response, "/supplier-po-view", "Database error while uploading invoice");
        }
    }
}
