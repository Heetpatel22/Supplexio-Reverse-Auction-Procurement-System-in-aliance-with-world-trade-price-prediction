package com.axaltacoating.tradecredit.web;

import com.axaltacoating.tradecredit.GoodsReceiptRecord;
import com.axaltacoating.tradecredit.TradeCreditWorkflowService;
import com.axaltacoating.tradecredit.WorkflowValidationException;
import com.axaltacoating.tradecredit.pdf.GoodsReceiptPdfEngine;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "TradeCreditGoodsReceiptPdfServlet", urlPatterns = {"/documents/grn.pdf"})
public class GoodsReceiptPdfServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(GoodsReceiptPdfServlet.class.getName());
    private final TradeCreditWorkflowService workflow = new TradeCreditWorkflowService();
    private final GoodsReceiptPdfEngine engine = new GoodsReceiptPdfEngine();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            GoodsReceiptRecord grn;
            if (request.getParameter("poId") != null) {
                long poId = Long.parseLong(request.getParameter("poId"));
                grn = workflow.loadGoodsReceiptByPoId(poId);
            } else {
                long grnId = TradeCreditServletUtil.requiredLong(request, "grnId");
                grn = workflow.loadGoodsReceipt(grnId);
            }
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + grn.getGrnNumber() + ".pdf\"");
            engine.generate(grn, response.getOutputStream());
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (WorkflowValidationException ex) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading GRN PDF data", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while generating GRN PDF");
        } catch (Exception ex) {
            throw new ServletException("Error generating GRN PDF", ex);
        }
    }
}
