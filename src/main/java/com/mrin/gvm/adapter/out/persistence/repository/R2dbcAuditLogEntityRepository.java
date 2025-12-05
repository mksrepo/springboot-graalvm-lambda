package com.mrin.gvm.adapter.out.persistence.repository;

import com.mrin.gvm.adapter.out.persistence.entity.AuditLogEntity;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

/**
 * R2DBC repository for audit logs.
 * Spring Data R2DBC interface.
 */
@Repository
public interface R2dbcAuditLogEntityRepository extends R2dbcRepository<AuditLogEntity, Long> {

    Mono<AuditLogEntity> findByEventId(String eventId);

    Flux<AuditLogEntity> findByEntityId(Long entityId);

    Flux<AuditLogEntity> findByStatus(String status);

    @Query("SELECT * FROM audit_logs WHERE status = 'FAILED' ORDER BY request_timestamp DESC")
    Flux<AuditLogEntity> findFailedOperations();

    @Query("DELETE FROM audit_logs WHERE request_timestamp < :before")
    Mono<Long> deleteByRequestTimestampBefore(Instant before);

    @Query("SELECT COUNT(*) FROM audit_logs WHERE status = :status")
    Mono<Long> countByStatus(String status);

    @Query("SELECT COUNT(*) FROM audit_logs WHERE chaos_active = true")
    Mono<Long> countByChaosActive();
}
