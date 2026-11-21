package com.axaltacoating.tradecredit;

/**
 * Canonical B2B trade-credit lifecycle. Keep this enum in the exact business
 * order; transition guards depend on ordinal sequencing.
 */
public enum LifecycleState {
    ACTIVE,
    AWARDED,
    PO_DRAFT,
    PO_SENT,
    PO_ACCEPTED,
    SHIPPED,
    DELIVERED,
    INVOICING_PENDING,
    PAYMENT_PENDING,
    PAYMENT_SUCCESSFUL,
    CLOSED;

    public LifecycleState next() {
        int nextOrdinal = ordinal() + 1;
        if (nextOrdinal >= values().length) {
            return null;
        }
        return values()[nextOrdinal];
    }

    public boolean canAdvanceTo(LifecycleState requestedState) {
        return requestedState != null && requestedState == next();
    }

    public static LifecycleState fromDatabase(String value) throws WorkflowValidationException {
        if (value == null || value.trim().isEmpty()) {
            throw new WorkflowValidationException("Missing lifecycle state");
        }
        String normalized = value.trim().toUpperCase();
        // Map legacy purchase-order statuses (not auction COMPLETED)
        if ("COMPLETED".equals(normalized)) return PO_DRAFT;
        if ("SENT".equals(normalized)) return PO_SENT;
        if ("PAID".equals(normalized)) return PAYMENT_SUCCESSFUL;
        if ("PENDING".equals(normalized)) return PO_DRAFT;
        
        try {
            return LifecycleState.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            throw new WorkflowValidationException("Unknown lifecycle state: " + value);
        }
    }
}
