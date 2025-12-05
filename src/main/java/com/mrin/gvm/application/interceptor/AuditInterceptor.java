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

    public <T> Mono<T> auditOperation(
            Mono<T> operation,
            String operationType,
            Object requestPayload) {
        String eventId = UUID.randomUUID().toString();
        Instant startTime = Instant.now();

        // Publish ATTEMPTED event
        AuditEvent attemptedEvent = buildEvent(eventId, operationType, "ATTEMPTED", requestPayload, startTime);

        return auditEventPublisher.publishEvent(attemptedEvent)
                .then(operation)
                .doOnSuccess(result -> {
                    // Publish SUCCEEDED event
                    AuditEvent successEvent = buildEvent(eventId, operationType, "SUCCEEDED", requestPayload,
                            startTime);
                    successEvent.setResponsePayload(result);
                    successEvent.setCompletionTimestamp(Instant.now());
                    successEvent.setDurationMs(Duration.between(startTime, Instant.now()).toMillis());
                    successEvent.setHttpStatusCode(201);

                    auditEventPublisher.publishEvent(successEvent).subscribe();
                })
                .doOnError(error -> {
                    // Publish FAILED event
                    AuditEvent failedEvent = buildEvent(eventId, operationType, "FAILED", requestPayload, startTime);
                    failedEvent.setErrorMessage(error.getMessage());
                    failedEvent.setCompletionTimestamp(Instant.now());
                    failedEvent.setDurationMs(Duration.between(startTime, Instant.now()).toMillis());
                    failedEvent.setHttpStatusCode(500);

                    auditEventPublisher.publishFailedEvent(failedEvent).subscribe();
                });
    }

    private AuditEvent buildEvent(String eventId, String operation, String status, Object payload, Instant timestamp) {
        return AuditEvent.builder()
                .eventId(eventId)
                .eventType("Product" + operation + status)
                .entityType("Product")
                .operation(operation)
                .status(status)
                .requestPayload(payload)
                .requestTimestamp(timestamp)
                .podName(System.getenv("HOSTNAME"))
                .chaosActive(false) // Can be enhanced to detect chaos
                .build();
    }
}
