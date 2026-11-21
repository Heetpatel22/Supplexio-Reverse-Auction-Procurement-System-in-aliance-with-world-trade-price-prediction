package com.axaltacoating.tradecredit.web;

import com.axaltacoating.tradecredit.PurchaseOrderRecord;
import com.axaltacoating.tradecredit.TradeCreditWorkflowService;
import com.axaltacoating.tradecredit.WorkflowValidationException;
import com.axaltacoating.tradecredit.pdf.PurchaseOrderPdfEngine;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "TradeCreditPurchaseOrderPdfServlet", urlPatterns = {"/documents/po.pdf"})
public class PurchaseOrderPdfServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PurchaseOrderPdfServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();
    private final PurchaseOrderPdfEngine engine = new PurchaseOrderPdfEngine();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            long poId = TradeCreditServletUtil.requiredLong(request, "poId");
            PurchaseOrderRecord po = workflow.loadPurchaseOrder(poId);
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + po.getPoNumber() + ".pdf\"");
            engine.generate(po, response.getOutputStream());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (WorkflowValidationException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading PO PDF data", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while generating PO PDF");
        } catch (Exception ex) {
            throw new ServletException("Error generating PO PDF", ex);
        }
    }
}
