package com.axaltacoating.tradecredit.pdf;

import com.axaltacoating.tradecredit.CommercialInvoiceRecord;
import com.axaltacoating.tradecredit.PurchaseOrderRecord;
import com.axaltacoating.tradecredit.TradeCreditLineItem;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;

public class CommercialInvoicePdfEngine {
    private static final BaseColor BRAND = new BaseColor(113, 65, 34);
    private static final BaseColor LIGHT = new BaseColor(248, 242, 236);
    private static final BaseColor BORDER = new BaseColor(224, 211, 199);
    private static final BaseColor TEXT = new BaseColor(55, 55, 55);

    public void generate(CommercialInvoiceRecord invoice, OutputStream out) throws Exception {
        PurchaseOrderRecord po = invoice.getPurchaseOrder();
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, out);
        document.open();

        Font titleFont = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD, BRAND);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
        Font labelFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, TEXT);
        Font valueFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, TEXT);
        Font smallFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, TEXT);
        Font totalFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BRAND);

        Paragraph title = new Paragraph("COMMERCIAL INVOICE", titleFont);
        title.setSpacingAfter(8f);
        document.add(title);
        document.add(new Paragraph("Supplier financial demand under approved B2B trade credit workflow", valueFont));
        document.add(spacer(10f));

        PdfPTable header = new PdfPTable(new float[]{1.35f, 1f});
        header.setWidthPercentage(100);
        PdfPCell supplier = block("INVOICE FROM", headerFont);
        supplier.addElement(new Paragraph(po.getSupplierName(), labelFont));
        supplier.addElement(new Paragraph(po.getSupplierAddress(), valueFont));
        supplier.addElement(new Paragraph("Email: " + po.getSupplierEmail(), smallFont));
        PdfPCell metaCell = new PdfPCell();
        metaCell.setPadding(0f);
        metaCell.setBorderColor(BORDER);
        PdfPTable meta = new PdfPTable(2);
        meta.setWidthPercentage(100);
        addMeta(meta, "Invoice No.", invoice.getInvoiceNumber(), headerFont, valueFont);
        addMeta(meta, "PO Number", po.getPoNumber(), headerFont, valueFont);
        addMeta(meta, "Invoice Date", dateOnly(invoice.getInvoiceDate()), headerFont, valueFont);
        addMeta(meta, "Status", invoice.getStatus(), headerFont, valueFont);
        metaCell.addElement(meta);
        header.addCell(supplier);
        header.addCell(metaCell);
        header.setSpacingAfter(14f);
        document.add(header);

        PdfPTable credit = new PdfPTable(2);
        credit.setWidthPercentage(100);
        PdfPCell billTo = block("BILL TO", headerFont);
        billTo.addElement(new Paragraph("Supplexio Accounts Payable", labelFont));
        billTo.addElement(new Paragraph("AxaltaWebApp Enterprise Purchasing System", valueFont));
        billTo.addElement(new Paragraph("Buyer: " + po.getBuyerEmail(), smallFont));
        PdfPCell terms = block("TRADE CREDIT TERMS", headerFont);
        terms.addElement(new Paragraph("Net 30 Trade Credit", labelFont));
        terms.addElement(new Paragraph("Payment Due Date: " + dateOnly(invoice.getDueDate()), valueFont));
        terms.addElement(new Paragraph("Payment unlock requires PO price, invoice price, and received quantity match.", smallFont));
        credit.addCell(billTo);
        credit.addCell(terms);
        credit.setSpacingAfter(14f);
        document.add(credit);

        PdfPTable items = new PdfPTable(new float[]{0.6f, 3.2f, 0.9f, 1.1f, 1f, 1.2f});
        items.setWidthPercentage(100);
        addItemHeaders(items, headerFont);
        for (TradeCreditLineItem item : po.getItems()) {
            items.addCell(tableValue(String.valueOf(item.getSerialNumber()), valueFont, Element.ALIGN_CENTER));
            items.addCell(tableValue(item.getDescription(), valueFont, Element.ALIGN_LEFT));
            items.addCell(tableValue(String.valueOf(invoice.getInvoiceQuantity()), valueFont, Element.ALIGN_CENTER));
            items.addCell(tableValue(money(item.getRate()), valueFont, Element.ALIGN_RIGHT));
            items.addCell(tableValue(money(invoice.getGstAmount()), valueFont, Element.ALIGN_RIGHT));
            items.addCell(tableValue(money(invoice.getInvoicePrice()), valueFont, Element.ALIGN_RIGHT));
        }
        items.setSpacingAfter(16f);
        document.add(items);

        PdfPTable bottom = new PdfPTable(new float[]{1.7f, 1f});
        bottom.setWidthPercentage(100);
        PdfPCell declaration = new PdfPCell();
        declaration.setPadding(10f);
        declaration.setBorderColor(BORDER);
        declaration.addElement(new Paragraph("INVOICE DECLARATION", labelFont));
        declaration.addElement(new Paragraph("This commercial invoice requests settlement against the accepted PO and delivered GRN.", smallFont));
        declaration.addElement(new Paragraph("Tax details are calculated at GST @ 7.5%. Net 30 credit starts after three-way match approval.", smallFont));
        bottom.addCell(declaration);
        bottom.addCell(totals(invoice.getInvoicePrice(), invoice.getGstAmount(), invoice.getTotalAmount(), labelFont, valueFont, totalFont));
        document.add(bottom);

        Paragraph footer = new Paragraph("Payment is available only while status is PAYMENT_PENDING and due date has been system stamped.", smallFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(12f);
        document.add(footer);
        document.close();
    }

    private PdfPCell totals(BigDecimal subtotal, BigDecimal gst, BigDecimal grandTotal,
            Font labelFont, Font valueFont, Font totalFont) {
        PdfPCell wrapper = new PdfPCell();
        wrapper.setPadding(0f);
        wrapper.setBorderColor(BORDER);
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.addCell(sumLabel("Invoice Subtotal", labelFont));
        table.addCell(sumValue(money(subtotal), valueFont));
        table.addCell(sumLabel("GST @ 7.5%", labelFont));
        table.addCell(sumValue(money(gst), valueFont));
        table.addCell(sumLabel("Balance Due", totalFont));
        table.addCell(sumValue(money(grandTotal), totalFont));
        wrapper.addElement(table);
        return wrapper;
    }

    private void addItemHeaders(PdfPTable table, Font headerFont) {
        table.addCell(tableHeader("S/N", headerFont));
        table.addCell(tableHeader("Description", headerFont));
        table.addCell(tableHeader("Quantity", headerFont));
        table.addCell(tableHeader("Rate", headerFont));
        table.addCell(tableHeader("GST", headerFont));
        table.addCell(tableHeader("Amount", headerFont));
    }

    private PdfPCell block(String title, Font font) {
        PdfPCell cell = new PdfPCell();
        cell.setPadding(10f);
        cell.setBorderColor(BORDER);
        PdfPCell heading = new PdfPCell(new Phrase(title, font));
        heading.setBackgroundColor(BRAND);
        heading.setPadding(7f);
        heading.setBorderColor(BORDER);
        PdfPTable inner = new PdfPTable(1);
        inner.setWidthPercentage(100);
        inner.addCell(heading);
        cell.addElement(inner);
        return cell;
    }

    private void addMeta(PdfPTable table, String label, String value, Font headerFont, Font valueFont) {
        table.addCell(metaHeader(label, headerFont));
        table.addCell(metaValue(value, valueFont));
    }

    private PdfPCell metaHeader(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(BRAND);
        cell.setPadding(7f);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell metaValue(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setPadding(7f);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell tableHeader(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(BRAND);
        cell.setPadding(8f);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell tableValue(String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setPadding(8f);
        cell.setHorizontalAlignment(align);
        cell.setBorderColor(BORDER);
        cell.setMinimumHeight(28f);
        return cell;
    }

    private PdfPCell sumLabel(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setBackgroundColor(LIGHT);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell sumValue(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private Paragraph spacer(float height) {
        Paragraph p = new Paragraph(" ");
        p.setSpacingAfter(height);
        return p;
    }

    private String dateOnly(java.util.Date date) {
        return date == null ? "Not stamped" : new SimpleDateFormat("yyyy-MM-dd").format(date);
    }

    private String money(BigDecimal value) {
        BigDecimal safe = value == null ? BigDecimal.ZERO : value;
        return "INR " + safe.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
    }
}
