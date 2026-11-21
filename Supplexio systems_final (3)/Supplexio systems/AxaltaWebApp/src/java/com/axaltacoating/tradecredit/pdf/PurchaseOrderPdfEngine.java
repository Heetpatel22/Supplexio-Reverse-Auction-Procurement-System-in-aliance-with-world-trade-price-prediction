package com.axaltacoating.tradecredit.pdf;

import com.axaltacoating.tradecredit.PurchaseOrderRecord;
import com.axaltacoating.tradecredit.TradeCreditLineItem;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;

public class PurchaseOrderPdfEngine {
    private static final BaseColor BRAND = new BaseColor(31, 74, 125);
    private static final BaseColor LIGHT = new BaseColor(240, 245, 250);
    private static final BaseColor BORDER = new BaseColor(210, 220, 230);
    private static final BaseColor TEXT = new BaseColor(55, 55, 55);

    public void generate(PurchaseOrderRecord po, OutputStream out) throws Exception {
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, out);
        document.open();

        Font titleFont = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD, BRAND);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
        Font labelFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, TEXT);
        Font valueFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, TEXT);
        Font smallFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, TEXT);
        Font totalFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BRAND);

        Paragraph title = new Paragraph("PURCHASE ORDER", titleFont);
        title.setAlignment(Element.ALIGN_LEFT);
        title.setSpacingAfter(8f);
        document.add(title);
        document.add(new Paragraph("Supplexio Procurement Division\nAxaltaWebApp Enterprise Purchasing System", valueFont));
        document.add(space(10f));

        PdfPTable header = new PdfPTable(new float[]{1.5f, 1f});
        header.setWidthPercentage(100);
        PdfPCell left = block("SUPPLIER", headerFont);
        left.addElement(new Paragraph(po.getSupplierName(), labelFont));
        left.addElement(new Paragraph(po.getSupplierAddress(), valueFont));
        left.addElement(new Paragraph("Email: " + po.getSupplierEmail(), smallFont));
        PdfPCell right = new PdfPCell();
        right.setPadding(0f);
        right.setBorderColor(BORDER);
        PdfPTable meta = new PdfPTable(2);
        meta.setWidthPercentage(100);
        addMeta(meta, "PO Number", po.getPoNumber(), headerFont, valueFont);
        addMeta(meta, "Auction Ref", String.valueOf(po.getAuctionId()), headerFont, valueFont);
        addMeta(meta, "Issue Date", dateTime(po.getCreatedAt()), headerFont, valueFont);
        addMeta(meta, "Status", po.getLifecycleState().name(), headerFont, valueFont);
        right.addElement(meta);
        header.addCell(left);
        header.addCell(right);
        header.setSpacingAfter(14f);
        document.add(header);

        PdfPTable parties = new PdfPTable(2);
        parties.setWidthPercentage(100);
        parties.setWidths(new float[]{1f, 1f});
        PdfPCell issuedBy = block("ISSUED BY", headerFont);
        issuedBy.addElement(new Paragraph("Supplexio Corporate Procurement", labelFont));
        issuedBy.addElement(new Paragraph("Industrial Sourcing & Reverse Auction Operations", valueFont));
        issuedBy.addElement(new Paragraph("Buyer: " + po.getBuyerEmail(), smallFont));
        PdfPCell delivery = block("DELIVERY / COMPLIANCE", headerFont);
        delivery.addElement(new Paragraph("Inbound Materials Department", labelFont));
        delivery.addElement(new Paragraph("Quality compliance is mandatory before payment activation.", valueFont));
        delivery.addElement(new Paragraph("Terms: " + po.getQualityTerms(), smallFont));
        parties.addCell(issuedBy);
        parties.addCell(delivery);
        parties.setSpacingAfter(14f);
        document.add(parties);

        PdfPTable items = itemTable(headerFont, valueFont);
        for (TradeCreditLineItem item : po.getItems()) {
            addItem(items, item, valueFont);
        }
        items.setSpacingAfter(16f);
        document.add(items);

        PdfPTable bottom = new PdfPTable(new float[]{1.7f, 1f});
        bottom.setWidthPercentage(100);
        PdfPCell terms = new PdfPCell();
        terms.setPadding(10f);
        terms.setBorderColor(BORDER);
        terms.addElement(new Paragraph("PROCUREMENT TERMS", labelFont));
        terms.addElement(new Paragraph("1. Supplier must meet approved auction specification and quality compliance standards.", smallFont));
        terms.addElement(new Paragraph("2. Dispatch must reference the PO number and shipping notice.", smallFont));
        terms.addElement(new Paragraph("3. Payment is not available before physical receipt, invoice upload, and three-way match.", smallFont));
        bottom.addCell(terms);
        bottom.addCell(totals(po.getSubtotal(), po.getGstAmount(), po.getTotalAmount(), labelFont, valueFont, totalFont));
        document.add(bottom);

        Paragraph footer = new Paragraph("This purchase order is system generated and becomes binding only after supplier acceptance.", smallFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(12f);
        document.add(footer);
        document.close();
    }

    private PdfPTable itemTable(Font headerFont, Font valueFont) throws DocumentException {
        PdfPTable table = new PdfPTable(new float[]{0.6f, 3.2f, 0.9f, 1.1f, 1.0f, 1.2f});
        table.setWidthPercentage(100);
        table.addCell(tableHeader("S/N", headerFont));
        table.addCell(tableHeader("Description", headerFont));
        table.addCell(tableHeader("Quantity", headerFont));
        table.addCell(tableHeader("Rate", headerFont));
        table.addCell(tableHeader("GST", headerFont));
        table.addCell(tableHeader("Amount", headerFont));
        return table;
    }

    private void addItem(PdfPTable table, TradeCreditLineItem item, Font font) {
        table.addCell(tableValue(String.valueOf(item.getSerialNumber()), font, Element.ALIGN_CENTER));
        table.addCell(tableValue(item.getDescription(), font, Element.ALIGN_LEFT));
        table.addCell(tableValue(String.valueOf(item.getQuantity()), font, Element.ALIGN_CENTER));
        table.addCell(tableValue(money(item.getRate()), font, Element.ALIGN_RIGHT));
        table.addCell(tableValue(money(item.getGstAmount()), font, Element.ALIGN_RIGHT));
        table.addCell(tableValue(money(item.getAmount()), font, Element.ALIGN_RIGHT));
    }

    private PdfPCell totals(BigDecimal subtotal, BigDecimal gst, BigDecimal grandTotal,
            Font labelFont, Font valueFont, Font totalFont) {
        PdfPCell wrapper = new PdfPCell();
        wrapper.setPadding(0f);
        wrapper.setBorderColor(BORDER);
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.addCell(sumLabel("Subtotal", labelFont));
        table.addCell(sumValue(money(subtotal), valueFont));
        table.addCell(sumLabel("GST @ 7.5%", labelFont));
        table.addCell(sumValue(money(gst), valueFont));
        table.addCell(sumLabel("Grand Total", totalFont));
        table.addCell(sumValue(money(grandTotal), totalFont));
        wrapper.addElement(table);
        return wrapper;
    }

    private void addMeta(PdfPTable table, String label, String value, Font headerFont, Font valueFont) {
        table.addCell(metaHeader(label, headerFont));
        table.addCell(metaValue(value, valueFont));
    }

    private PdfPCell block(String title, Font font) {
        PdfPCell cell = new PdfPCell();
        cell.setPadding(10f);
        cell.setBorderColor(BORDER);
        Paragraph p = new Paragraph(title, font);
        PdfPTable inner = new PdfPTable(1);
        inner.setWidthPercentage(100);
        PdfPCell header = new PdfPCell(p);
        header.setBackgroundColor(BRAND);
        header.setPadding(7f);
        header.setBorder(Rectangle.NO_BORDER);
        inner.addCell(header);
        cell.addElement(inner);
        return cell;
    }

    private PdfPCell metaHeader(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(BRAND);
        cell.setPadding(7f);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell metaValue(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(nullSafe(text), font));
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
        PdfPCell cell = new PdfPCell(new Phrase(nullSafe(text), font));
        cell.setPadding(8f);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_TOP);
        cell.setBorderColor(BORDER);
        cell.setMinimumHeight(28f);
        return cell;
    }

    private PdfPCell sumLabel(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(LIGHT);
        cell.setPadding(8f);
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

    private Paragraph space(float height) {
        Paragraph p = new Paragraph(" ");
        p.setSpacingAfter(height);
        return p;
    }

    private String dateTime(java.util.Date date) {
        return date == null ? "Not stamped" : new SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
    }

    private String money(BigDecimal value) {
        BigDecimal safe = value == null ? BigDecimal.ZERO : value;
        return "INR " + safe.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
    }

    private String nullSafe(String value) {
        return value == null ? "" : value;
    }
}
