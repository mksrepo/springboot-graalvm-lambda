package com.mrin.gvm.adapter.out.messaging;

import com.mrin.gvm.domain.event.AuditEvent;
import com.mrin.gvm.domain.port.out.AuditEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

/**
 * Kafka adapter for publishing audit events.
 * Outbound adapter in hexagonal architecture.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class KafkaAuditEventPublisher implements AuditEventPublisher {

    private static final String AUDIT_TOPIC = "product.audit.events";
    private static final String FAILED_TOPIC = "product.audit.failed";

    private final KafkaTemplate<String, AuditEvent> kafkaTemplate;

    /**
     * Publishes a successful audit event to the configured Kafka topic.
     *
     * @param event the {@link AuditEvent} to publish
     * @return a Mono that completes when the event is sent
     */
    @Override
    public Mono<Void> publishEvent(AuditEvent event) {
        return Mono.fromRunnable(() -> {
            try {
                // Using eventId as key to ensure ordering for the same event if needed, though
                // usually events are independent
                kafkaTemplate.send(AUDIT_TOPIC, event.getEventId(), event);
                log.debug("Published audit event: {}", event.getEventType());
            } catch (Exception e) {
                log.error("Failed to publish audit event for eventId: {}", event.getEventId(), e);
            }
        });
    }

    /**
     * Publishes a failed audit event to the failure topic.
     *
     * @param event the {@link AuditEvent} representing the failure
     * @return a Mono that completes when the event is sent
     */
    @Override
    public Mono<Void> publishFailedEvent(AuditEvent event) {
        return Mono.fromRunnable(() -> {
            try {
                kafkaTemplate.send(FAILED_TOPIC, event.getEventId(), event);
                log.warn("Published failed event: {}", event.getEventType());
            } catch (Exception e) {
                log.error("Failed to publish failed event for eventId: {}", event.getEventId(), e);
            }
        });
    }
}
