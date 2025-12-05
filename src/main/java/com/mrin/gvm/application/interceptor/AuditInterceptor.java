package com.mrin.gvm.application.interceptor;

import com.mrin.gvm.domain.event.AuditEvent;
import com.mrin.gvm.domain.port.out.AuditEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

/**
 * Interceptor for auditing operations.
 * Application layer component in hexagonal architecture.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuditInterceptor {

    private final AuditEventPublisher auditEventPublisher;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    public <T> Mono<T> auditOperation(
            Mono<T> operation,
            String operationType,
            Object requestPayload) {
        String eventId = UUID.randomUUID().toString();
        java.time.OffsetDateTime startTime = java.time.OffsetDateTime.now();

        // Publish ATTEMPTED event
        AuditEvent attemptedEvent = buildEvent(eventId, operationType, "ATTEMPTED", requestPayload, startTime);

        return auditEventPublisher.publishEvent(attemptedEvent)
                .then(operation)
                .doOnSuccess(result -> {
                    // Publish SUCCEEDED event
                    AuditEvent successEvent = buildEvent(eventId, operationType, "SUCCEEDED", requestPayload,
                            startTime);

                    if (result != null) {
                        try {
                            successEvent.setResponsePayload(
                                    objectMapper.convertValue(result, com.mrin.gvm.domain.event.ResponsePayload.class));
                        } catch (Exception e) {
                            log.warn("Failed to convert response payload", e);
                        }
                    }

                    successEvent.setCompletionTimestamp(java.time.OffsetDateTime.now());
                    successEvent.setDurationMs(
                            (int) java.time.Duration.between(startTime, java.time.OffsetDateTime.now()).toMillis());
                    successEvent.setHttpStatusCode(201);

                    auditEventPublisher.publishEvent(successEvent).subscribe();
                })
                .doOnError(error -> {
                    // Publish FAILED event
                    AuditEvent failedEvent = buildEvent(eventId, operationType, "FAILED", requestPayload, startTime);
                    failedEvent.setErrorMessage(error.getMessage());
                    failedEvent.setCompletionTimestamp(java.time.OffsetDateTime.now());
                    failedEvent.setDurationMs(
                            (int) java.time.Duration.between(startTime, java.time.OffsetDateTime.now()).toMillis());
                    failedEvent.setHttpStatusCode(500);

                    auditEventPublisher.publishFailedEvent(failedEvent).subscribe();
                });
    }

    private AuditEvent buildEvent(String eventId, String operation, String status, Object payload,
            java.time.OffsetDateTime timestamp) {
        com.mrin.gvm.domain.event.RequestPayload rp = null;
        if (payload != null) {
            try {
                rp = objectMapper.convertValue(payload, com.mrin.gvm.domain.event.RequestPayload.class);
            } catch (Exception e) {
                log.warn("Failed to convert request payload", e);
            }
        }

        return new AuditEvent()
                .withEventId(eventId)
                .withEventType("Product" + operation + status)
                .withEntityType("Product")
                .withOperation(operation)
                .withStatus(status)
                .withRequestPayload(rp)
                .withRequestTimestamp(timestamp)
                .withPodName(System.getenv("HOSTNAME"))
                .withChaosActive(false);
    }
}
