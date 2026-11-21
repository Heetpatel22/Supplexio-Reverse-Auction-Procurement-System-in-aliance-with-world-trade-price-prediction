package com.axaltacoating.tradecredit;

public class WorkflowValidationException extends Exception {
    public WorkflowValidationException(String message) {
        super(message);
    }

    public WorkflowValidationException(String message, Throwable cause) {
        super(message, cause);
    }
}
