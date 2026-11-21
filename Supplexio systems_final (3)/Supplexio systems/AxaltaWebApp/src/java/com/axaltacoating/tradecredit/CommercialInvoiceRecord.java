package com.axaltacoating.tradecredit;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class CommercialInvoiceRecord {
    private long id;
    private long poId;
    private String invoiceNumber;
    private Date invoiceDate;
    private BigDecimal invoicePrice;
    private int invoiceQuantity;
    private BigDecimal gstRate;
    private BigDecimal gstAmount;
    private BigDecimal totalAmount;
    private String status;
    private Date dueDate;
    private Timestamp paymentUnlockedAt;
    private Timestamp paidAt;
    private PurchaseOrderRecord purchaseOrder;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getPoId() { return poId; }
    public void setPoId(long poId) { this.poId = poId; }
    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }
    public Date getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(Date invoiceDate) { this.invoiceDate = invoiceDate; }
    public BigDecimal getInvoicePrice() { return invoicePrice; }
    public void setInvoicePrice(BigDecimal invoicePrice) { this.invoicePrice = invoicePrice; }
    public int getInvoiceQuantity() { return invoiceQuantity; }
    public void setInvoiceQuantity(int invoiceQuantity) { this.invoiceQuantity = invoiceQuantity; }
    public BigDecimal getGstRate() { return gstRate; }
    public void setGstRate(BigDecimal gstRate) { this.gstRate = gstRate; }
    public BigDecimal getGstAmount() { return gstAmount; }
    public void setGstAmount(BigDecimal gstAmount) { this.gstAmount = gstAmount; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public Timestamp getPaymentUnlockedAt() { return paymentUnlockedAt; }
    public void setPaymentUnlockedAt(Timestamp paymentUnlockedAt) { this.paymentUnlockedAt = paymentUnlockedAt; }
    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }
    public PurchaseOrderRecord getPurchaseOrder() { return purchaseOrder; }
    public void setPurchaseOrder(PurchaseOrderRecord purchaseOrder) { this.purchaseOrder = purchaseOrder; }
}
