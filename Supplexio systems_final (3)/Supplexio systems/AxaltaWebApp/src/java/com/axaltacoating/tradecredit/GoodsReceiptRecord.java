package com.axaltacoating.tradecredit;

import java.sql.Timestamp;

public class GoodsReceiptRecord {
    private long id;
    private long poId;
    private String grnNumber;
    private int receivedQuantity;
    private String warehouseLocation;
    private String asnNumber;
    private String shippingCarrier;
    private String trackingNumber;
    private Timestamp shippedAt;
    private Timestamp deliveredAt;
    private String receivedBy;
    private PurchaseOrderRecord purchaseOrder;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getPoId() { return poId; }
    public void setPoId(long poId) { this.poId = poId; }
    public String getGrnNumber() { return grnNumber; }
    public void setGrnNumber(String grnNumber) { this.grnNumber = grnNumber; }
    public int getReceivedQuantity() { return receivedQuantity; }
    public void setReceivedQuantity(int receivedQuantity) { this.receivedQuantity = receivedQuantity; }
    public String getWarehouseLocation() { return warehouseLocation; }
    public void setWarehouseLocation(String warehouseLocation) { this.warehouseLocation = warehouseLocation; }
    public String getAsnNumber() { return asnNumber; }
    public void setAsnNumber(String asnNumber) { this.asnNumber = asnNumber; }
    public String getShippingCarrier() { return shippingCarrier; }
    public void setShippingCarrier(String shippingCarrier) { this.shippingCarrier = shippingCarrier; }
    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }
    public Timestamp getShippedAt() { return shippedAt; }
    public void setShippedAt(Timestamp shippedAt) { this.shippedAt = shippedAt; }
    public Timestamp getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(Timestamp deliveredAt) { this.deliveredAt = deliveredAt; }
    public String getReceivedBy() { return receivedBy; }
    public void setReceivedBy(String receivedBy) { this.receivedBy = receivedBy; }
    public PurchaseOrderRecord getPurchaseOrder() { return purchaseOrder; }
    public void setPurchaseOrder(PurchaseOrderRecord purchaseOrder) { this.purchaseOrder = purchaseOrder; }
}
