package com.mrin.gvm.application.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mrin.gvm.domain.event.AuditEvent;
import com.mrin.gvm.domain.event.RequestPayload;
import com.mrin.gvm.domain.event.ResponsePayload;
import com.mrin.gvm.domain.port.out.AuditEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Interceptor for auditing business operations.
 * <p>
 * This application service intercepts operations to publish audit events
 * (ATTEMPTED, SUCCEEDED, FAILED)
 * to the {@link AuditEventPublisher}. It handles payload serialization and
 * timestamp calculation.
 * </p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuditInterceptor {

    private final AuditEventPublisher auditEventPublisher;
    private final ObjectMapper objectMapper;

    /**
     * Audits a reactive operation.
     *
     * @param operation      the reactive operation to audit
     * @param operationType  the type of operation (e.g., "CREATE", "UPDATE")
     * @param requestPayload the payload of the request
     * @param <T>            the type of the result
     * @return a Mono that emits the result of the operation after auditing
     */
    public <T> Mono<T> auditOperation(
            Mono<T> operation,
            String operationType,
            Object requestPayload) {
        String eventId = UUID.randomUUID().toString();
        OffsetDateTime startTime = OffsetDateTime.now();

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
                                    objectMapper.convertValue(result, ResponsePayload.class));
                        } catch (Exception e) {
                            log.warn("Failed to convert response payload to ResponsePayload class", e);
                        }
                    }

                    successEvent.setCompletionTimestamp(OffsetDateTime.now());
                    successEvent.setDurationMs(
                            (int) Duration.between(startTime, OffsetDateTime.now()).toMillis());
                    successEvent.setHttpStatusCode(201); // Assuming 201 for creation context, ideally should adapt

                    auditEventPublisher.publishEvent(successEvent).subscribe();
                })
                .doOnError(error -> {
                    // Publish FAILED event
                    AuditEvent failedEvent = buildEvent(eventId, operationType, "FAILED", requestPayload, startTime);
                    failedEvent.setErrorMessage(error.getMessage());
                    failedEvent.setCompletionTimestamp(OffsetDateTime.now());
                    failedEvent.setDurationMs(
                            (int) Duration.between(startTime, OffsetDateTime.now()).toMillis());
                    failedEvent.setHttpStatusCode(500);

                    auditEventPublisher.publishFailedEvent(failedEvent).subscribe();
                });
    }

    private AuditEvent buildEvent(String eventId, String operation, String status, Object payload,
            OffsetDateTime timestamp) {
        RequestPayload rp = null;
        if (payload != null) {
            try {
                rp = objectMapper.convertValue(payload, RequestPayload.class);
            } catch (Exception e) {
                log.warn("Failed to convert request payload to RequestPayload class", e);
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
