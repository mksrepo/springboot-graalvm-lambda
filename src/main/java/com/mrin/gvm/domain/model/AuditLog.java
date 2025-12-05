package com.mrin.gvm.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Domain model for Audit Log.
 * Represents an audit trail entry for any operation in the system.
 * This is part of the hexagonal architecture core domain.
 */
@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {

    private Long id;
    private String eventId;
    private String eventType;
    private String entityType;
    private Long entityId;
    private String operation;
    private AuditStatus status;
    private String userId;
    private String requestPayload;
    private String responsePayload;
    private String errorMessage;
    private Integer httpStatusCode;
    private Instant requestTimestamp;
    private Instant completionTimestamp;
    private Long durationMs;
    private String sourceIp;
    private String podName;
    private Boolean chaosActive;
    private Instant createdAt;

    /**
     * Audit operation types
     */
    public enum Operation {
        CREATE, UPDATE, DELETE, READ
    }

    /**
     * Audit status types
     */
    public enum AuditStatus {
        ATTEMPTED, SUCCEEDED, FAILED
    }

    /**
     * Calculate duration if not already set
     */
    public void calculateDuration() {
        if (requestTimestamp != null && completionTimestamp != null && durationMs == null) {
            this.durationMs = completionTimestamp.toEpochMilli() - requestTimestamp.toEpochMilli();
        }
    }
}
