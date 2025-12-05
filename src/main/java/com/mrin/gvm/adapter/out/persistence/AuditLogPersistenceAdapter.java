package com.mrin.gvm.adapter.out.persistence;

import com.mrin.gvm.adapter.out.persistence.entity.AuditLogEntity;
import com.mrin.gvm.adapter.out.persistence.repository.R2dbcAuditLogEntityRepository;
import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.out.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

/**
 * Persistence adapter for audit logs.
 * Implements the output port using R2DBC.
 * Part of hexagonal architecture adapter layer.
 */
@Component
@RequiredArgsConstructor
public class AuditLogPersistenceAdapter implements AuditLogRepository {

    private final R2dbcAuditLogEntityRepository repository;

    @Override
    public Mono<AuditLog> save(AuditLog auditLog) {
        return repository.save(toEntity(auditLog))
                .map(this::toDomain);
    }

    @Override
    public Mono<AuditLog> findByEventId(String eventId) {
        return repository.findByEventId(eventId)
                .map(this::toDomain);
    }

    @Override
    public Flux<AuditLog> findByEntityId(Long entityId) {
        return repository.findByEntityId(entityId)
                .map(this::toDomain);
    }

    @Override
    public Flux<AuditLog> findWithFilters(String status, String operation, Boolean chaosActive, Instant startTime,
            Instant endTime) {
        // Simplified: return all for now
        return repository.findAll().map(this::toDomain);
    }

    @Override
    public Flux<AuditLog> findFailedOperations() {
        return repository.findFailedOperations()
                .map(this::toDomain);
    }

    @Override
    public Mono<Long> deleteAuditLogsBefore(Instant before) {
        return repository.deleteByRequestTimestampBefore(before);
    }

    @Override
    public Mono<Long> deleteAll() {
        return repository.deleteAll().then(Mono.just(0L));
    }

    @Override
    public Mono<Long> countByStatus(String status) {
        return repository.countByStatus(status);
    }

    @Override
    public Mono<Long> countByChaosActive() {
        return repository.countByChaosActive();
    }

    private AuditLogEntity toEntity(AuditLog domain) {
        return AuditLogEntity.builder()
                .id(domain.getId())
                .eventId(domain.getEventId())
                .eventType(domain.getEventType())
                .entityType(domain.getEntityType())
                .entityId(domain.getEntityId())
                .operation(domain.getOperation())
                .status(domain.getStatus() != null ? domain.getStatus().name() : null)
                .userId(domain.getUserId())
                .requestPayload(domain.getRequestPayload())
                .responsePayload(domain.getResponsePayload())
                .errorMessage(domain.getErrorMessage())
                .httpStatusCode(domain.getHttpStatusCode())
                .requestTimestamp(domain.getRequestTimestamp())
                .completionTimestamp(domain.getCompletionTimestamp())
                .durationMs(domain.getDurationMs())
                .sourceIp(domain.getSourceIp())
                .podName(domain.getPodName())
                .chaosActive(domain.getChaosActive())
                .createdAt(domain.getCreatedAt())
                .build();
    }

    private AuditLog toDomain(AuditLogEntity entity) {
        return AuditLog.builder()
                .id(entity.getId())
                .eventId(entity.getEventId())
                .eventType(entity.getEventType())
                .entityType(entity.getEntityType())
                .entityId(entity.getEntityId())
                .operation(entity.getOperation())
                .status(entity.getStatus() != null ? AuditLog.AuditStatus.valueOf(entity.getStatus()) : null)
                .userId(entity.getUserId())
                .requestPayload(entity.getRequestPayload())
                .responsePayload(entity.getResponsePayload())
                .errorMessage(entity.getErrorMessage())
                .httpStatusCode(entity.getHttpStatusCode())
                .requestTimestamp(entity.getRequestTimestamp())
                .completionTimestamp(entity.getCompletionTimestamp())
                .durationMs(entity.getDurationMs())
                .sourceIp(entity.getSourceIp())
                .podName(entity.getPodName())
                .chaosActive(entity.getChaosActive())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
