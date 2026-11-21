package com.axaltacoating.tradecredit.web;

import com.axaltacoating.tradecredit.CommercialInvoiceRecord;
import com.axaltacoating.tradecredit.TradeCreditWorkflowService;
import com.axaltacoating.tradecredit.WorkflowValidationException;
import com.axaltacoating.tradecredit.pdf.CommercialInvoicePdfEngine;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "TradeCreditCommercialInvoicePdfServlet", urlPatterns = {"/documents/invoice.pdf"})
public class CommercialInvoicePdfServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CommercialInvoicePdfServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();
    private final CommercialInvoicePdfEngine engine = new CommercialInvoicePdfEngine();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            com.axaltacoating.tradecredit.CommercialInvoiceRecord invoice;
            if (request.getParameter("poId") != null) {
                long poId = Long.parseLong(request.getParameter("poId"));
                invoice = workflow.loadCommercialInvoiceByPoId(poId);
            } else {
                long invoiceId = TradeCreditServletUtil.requiredLong(request, "invoiceId");
                invoice = workflow.loadCommercialInvoice(invoiceId);
            }
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + invoice.getInvoiceNumber() + ".pdf\"");
            engine.generate(invoice, response.getOutputStream());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (WorkflowValidationException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading invoice PDF data", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while generating invoice PDF");
        } catch (Exception ex) {
            throw new ServletException("Error generating invoice PDF", ex);
        }
    }
}
