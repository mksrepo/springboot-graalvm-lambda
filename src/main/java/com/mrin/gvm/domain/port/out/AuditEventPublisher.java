package com.mrin.gvm.domain.port.out;

import com.mrin.gvm.domain.event.AuditEvent;
import reactor.core.publisher.Mono;

/**
 * Output port for publishing audit events.
 * This is part of the hexagonal architecture - defines the contract
 * for sending events to external messaging systems (Kafka).
 * 
 * Implementations will be in the adapter layer.
 */
public interface AuditEventPublisher {

    /**
     * Publish an audit event to the messaging system
     * 
     * @param event the audit event to publish
     * @return Mono that completes when event is published
     */
    Mono<Void> publishEvent(AuditEvent event);

    /**
     * Publish a failed operation event
     * 
     * @param event the failed operation event
     * @return Mono that completes when event is published
     */
    Mono<Void> publishFailedEvent(AuditEvent event);
}
