package com.mrin.gvm.adapter.in.messaging;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mrin.gvm.domain.event.AuditEvent;
import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.out.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Kafka consumer for audit events.
 * Inbound adapter in hexagonal architecture.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class KafkaAuditEventConsumer {

    private final AuditLogRepository auditLogRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "product.audit.events", groupId = "audit-logger")
    public void consumeAuditEvent(AuditEvent event) {
        try {
            log.debug("Consuming audit event: {}", event.getEventType());

            AuditLog auditLog = mapToAuditLog(event);
            auditLogRepository.save(auditLog).subscribe(
                    saved -> log.debug("Saved audit log: {}", saved.getId()),
                    error -> log.error("Failed to save audit log", error));
        } catch (Exception e) {
            log.error("Error consuming audit event", e);
        }
    }

    private AuditLog mapToAuditLog(AuditEvent event) {
        return AuditLog.builder()
                .eventId(event.getEventId())
                .eventType(event.getEventType())
                .entityType(event.getEntityType())
                .entityId(event.getEntityId())
                .operation(event.getOperation())
                .status(event.getStatus() != null ? AuditLog.AuditStatus.valueOf(event.getStatus()) : null)
                .userId(event.getUserId())
                .requestPayload(toJson(event.getRequestPayload()))
                .responsePayload(toJson(event.getResponsePayload()))
                .errorMessage(event.getErrorMessage())
                .httpStatusCode(event.getHttpStatusCode())
                .requestTimestamp(event.getRequestTimestamp())
                .completionTimestamp(event.getCompletionTimestamp())
                .durationMs(event.getDurationMs())
                .sourceIp(event.getSourceIp())
                .podName(event.getPodName())
                .chaosActive(event.getChaosActive())
                .build();
    }

    private String toJson(Object obj) {
        if (obj == null)
            return null;
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return obj.toString();
        }
    }
}
