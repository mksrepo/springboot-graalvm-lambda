package com.mrin.gvm.domain.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Domain event for audit logging.
 * Published to Kafka for asynchronous processing.
 * Part of the hexagonal architecture domain layer.
 */
@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class AuditEvent {

    private String eventId;
    private String eventType;
    private String entityType;
    private Long entityId;
    private String operation;
    private String status;
    private String userId;
    private Object requestPayload;
    private Object responsePayload;
    private String errorMessage;
    private Integer httpStatusCode;
    private Instant requestTimestamp;
    private Instant completionTimestamp;
    private Long durationMs;
    private String sourceIp;
    private String podName;
    private Boolean chaosActive;
}
