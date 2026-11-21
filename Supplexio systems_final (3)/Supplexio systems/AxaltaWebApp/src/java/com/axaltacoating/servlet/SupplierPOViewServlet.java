package com.axaltacoating.servlet;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.util.DatabaseConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "SupplierPOViewServlet", urlPatterns = {"/supplier-po-view"})
public class SupplierPOViewServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SupplierPOViewServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Supplier supplier = (Supplier) request.getSession().getAttribute("supplier");
        if (supplier == null) {
            response.sendRedirect(request.getContextPath() +  "/supplier-po-view");
            return;
        }

        long supplierId = supplier.getId();
        String supplierName = supplier.getName();
        List<PurchaseOrderBean> poList = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                "SELECT po.id, " +
                "       COALESCE(po.supplier_id, ra.winning_supplier_id) AS supplier_id, " +
                "       COALESCE(NULLIF(po.po_number, ''), CONCAT('PO-', po.id)) AS po_number, " +
                "       COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS product_name, " +
                "       COALESCE(po.total_amount, po.amount, po.grand_total, 0) AS amount, " +
                "       COALESCE(po.quantity, ra.required_quantity, 1) AS quantity, " +
                "       COALESCE(NULLIF(po.supplier_name, ''), s.name, po.company_name, ?) AS company_name, " +
                "       po.status, po.created_at " +
                "FROM purchase_orders po " +
                "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
                "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
                "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id) " +
                "WHERE COALESCE(po.supplier_id, ra.winning_supplier_id) = ? " +
                "AND po.status IN ('PO_SENT', 'PO_ACCEPTED', 'SHIPPED', 'DELIVERED', 'INVOICING_PENDING', 'PAYMENT_PENDING', 'PAYMENT_SUCCESSFUL', 'CLOSED', 'SENT', 'PAID') " +
"ORDER BY po.created_at DESC"
)) {

            stmt.setString(1, supplierName != null ? supplierName : "Unknown Supplier");
            stmt.setLong(2, supplierId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    PurchaseOrderBean po = new PurchaseOrderBean();
                    po.setId(rs.getLong("id"));
                    po.setSupplierId(rs.getLong("supplier_id"));
                    po.setPoNumber(rs.getString("po_number"));
                    po.setMaterial(rs.getString("product_name"));
                    po.setAmount(rs.getDouble("amount"));
                    po.setQuantity(rs.getInt("quantity"));
                    po.setCompanyName(rs.getString("company_name"));
                    po.setStatus(rs.getString("status"));
                    po.setCreatedAt(rs.getTimestamp("created_at"));
                    poList.add(po);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading supplier POs", e);
        }

        request.setAttribute("poList", poList);
        request.getRequestDispatcher("/supplier_po.jsp").forward(request, response);
    }

    public static class PurchaseOrderBean {
        private long id;
        private long supplierId;
        private String poNumber;
        private String material;
        private double amount;
        private int quantity;
        private String status;
        private java.util.Date createdAt;
        private String companyName;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public long getSupplierId() { return supplierId; }
        public void setSupplierId(long supplierId) { this.supplierId = supplierId; }
        public String getPoNumber() { return poNumber; }
        public void setPoNumber(String poNumber) { this.poNumber = poNumber; }
        public String getMaterial() { return material; }
        public void setMaterial(String material) { this.material = material; }
        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }
    }
}
