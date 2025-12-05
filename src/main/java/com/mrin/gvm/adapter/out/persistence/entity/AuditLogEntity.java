package com.mrin.gvm.adapter.out.persistence.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;

/**
 * R2DBC entity for audit logs.
 * Outbound adapter entity in hexagonal architecture.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table("audit_logs")
public class AuditLogEntity {

    @Id
    private Long id;
    private String eventId;
    private String eventType;
    private String entityType;
    private Long entityId;
    private String operation;
    private String status;
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
}
