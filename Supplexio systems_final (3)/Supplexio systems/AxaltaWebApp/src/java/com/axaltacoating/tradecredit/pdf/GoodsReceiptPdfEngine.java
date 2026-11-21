package com.axaltacoating.tradecredit.pdf;

import com.axaltacoating.tradecredit.GoodsReceiptRecord;
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

public class GoodsReceiptPdfEngine {
    private static final BaseColor BRAND = new BaseColor(35, 96, 82);
    private static final BaseColor LIGHT = new BaseColor(236, 246, 243);
    private static final BaseColor BORDER = new BaseColor(205, 220, 216);
    private static final BaseColor TEXT = new BaseColor(55, 55, 55);

    public void generate(GoodsReceiptRecord grn, OutputStream out) throws Exception {
        PurchaseOrderRecord po = grn.getPurchaseOrder();
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(document, out);
        document.open();

        Font titleFont = new Font(Font.FontFamily.HELVETICA, 23, Font.BOLD, BRAND);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
        Font labelFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, TEXT);
        Font valueFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, TEXT);
        Font smallFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, TEXT);
        Font totalFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BRAND);

        Paragraph title = new Paragraph("GOODS RECEIPT NOTE (GRN)", titleFont);
        title.setSpacingAfter(8f);
        document.add(title);
        document.add(new Paragraph("Supplexio Warehouse Receiving\nPhysical delivery verification record", valueFont));
        document.add(spacer(10f));

        PdfPTable header = new PdfPTable(new float[]{1.35f, 1f});
        header.setWidthPercentage(100);
        PdfPCell left = block("WAREHOUSE RECEIPT", headerFont);
        left.addElement(new Paragraph("Received Quantity: " + grn.getReceivedQuantity(), labelFont));
        left.addElement(new Paragraph("Inbound Warehouse Location: " + grn.getWarehouseLocation(), valueFont));
        left.addElement(new Paragraph("Received By: " + grn.getReceivedBy(), smallFont));
        PdfPCell right = new PdfPCell();
        right.setPadding(0f);
        right.setBorderColor(BORDER);
        PdfPTable meta = new PdfPTable(2);
        meta.setWidthPercentage(100);
        addMeta(meta, "GRN Number", grn.getGrnNumber(), headerFont, valueFont);
        addMeta(meta, "PO Number", po.getPoNumber(), headerFont, valueFont);
        addMeta(meta, "Delivered At", dateTime(grn.getDeliveredAt()), headerFont, valueFont);
        addMeta(meta, "Lifecycle Status", po.getLifecycleState().name(), headerFont, valueFont);
        right.addElement(meta);
        header.addCell(left);
        header.addCell(right);
        header.setSpacingAfter(14f);
        document.add(header);

        PdfPTable shipping = new PdfPTable(2);
        shipping.setWidthPercentage(100);
        PdfPCell ship = block("ADVANCED SHIPPING NOTICE", headerFont);
        ship.addElement(new Paragraph("ASN: " + grn.getAsnNumber(), valueFont));
        ship.addElement(new Paragraph("Carrier: " + grn.getShippingCarrier(), valueFont));
        ship.addElement(new Paragraph("Tracking: " + grn.getTrackingNumber(), valueFont));
        ship.addElement(new Paragraph("Shipped At: " + dateTime(grn.getShippedAt()), smallFont));
        PdfPCell supplier = block("SUPPLIER / MATERIAL", headerFont);
        supplier.addElement(new Paragraph(po.getSupplierName(), labelFont));
        supplier.addElement(new Paragraph(po.getProductName(), valueFont));
        supplier.addElement(new Paragraph("Auction Ref: " + po.getAuctionId(), smallFont));
        shipping.addCell(ship);
        shipping.addCell(supplier);
        shipping.setSpacingAfter(14f);
        document.add(shipping);

        PdfPTable items = new PdfPTable(new float[]{0.6f, 3.2f, 0.9f, 1.1f, 1f, 1.2f});
        items.setWidthPercentage(100);
        addItemHeaders(items, headerFont);
        for (TradeCreditLineItem item : po.getItems()) {
            items.addCell(tableValue(String.valueOf(item.getSerialNumber()), valueFont, Element.ALIGN_CENTER));
            items.addCell(tableValue(item.getDescription(), valueFont, Element.ALIGN_LEFT));
            items.addCell(tableValue(String.valueOf(grn.getReceivedQuantity()), valueFont, Element.ALIGN_CENTER));
            items.addCell(tableValue(money(item.getRate()), valueFont, Element.ALIGN_RIGHT));
            items.addCell(tableValue(money(item.getGstAmount()), valueFont, Element.ALIGN_RIGHT));
            items.addCell(tableValue(money(item.getAmount()), valueFont, Element.ALIGN_RIGHT));
        }
        items.setSpacingAfter(16f);
        document.add(items);

        PdfPTable bottom = new PdfPTable(new float[]{1.7f, 1f});
        bottom.setWidthPercentage(100);
        PdfPCell remarks = new PdfPCell();
        remarks.setPadding(10f);
        remarks.setBorderColor(BORDER);
        remarks.addElement(new Paragraph("WAREHOUSE DECLARATION", labelFont));
        remarks.addElement(new Paragraph("Physical quantity above was verified at inbound receiving before invoice matching.", smallFont));
        remarks.addElement(new Paragraph("Shortage, excess, or damaged goods must remain blocked from payment activation.", smallFont));
        bottom.addCell(remarks);
        bottom.addCell(receiptSummary(po.getItems().get(0).getQuantity(), grn.getReceivedQuantity(), labelFont, valueFont, totalFont));
        document.add(bottom);

        Paragraph footer = new Paragraph("GRN is a warehouse reality document and does not represent supplier payment approval.", smallFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(12f);
        document.add(footer);
        document.close();
    }

    private PdfPCell receiptSummary(int orderedQuantity, int receivedQuantity, Font labelFont, Font valueFont, Font totalFont) {
        PdfPCell wrapper = new PdfPCell();
        wrapper.setPadding(0f);
        wrapper.setBorderColor(BORDER);
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.addCell(sumLabel("Ordered Qty", labelFont));
        table.addCell(sumValue(String.valueOf(orderedQuantity), valueFont));
        table.addCell(sumLabel("Received Qty", labelFont));
        table.addCell(sumValue(String.valueOf(receivedQuantity), valueFont));
        table.addCell(sumLabel("Receipt Status", totalFont));
        table.addCell(sumValue(orderedQuantity == receivedQuantity ? "MATCHED" : "VARIANCE", totalFont));
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

    private String dateTime(java.util.Date date) {
        return date == null ? "Not stamped" : new SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
    }

    private String money(BigDecimal value) {
        BigDecimal safe = value == null ? BigDecimal.ZERO : value;
        return "INR " + safe.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
    }
}
