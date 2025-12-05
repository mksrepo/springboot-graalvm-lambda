package com.mrin.gvm.domain.port.out;

import com.mrin.gvm.domain.model.AuditLog;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

/**
 * Output port for audit log persistence.
 * This is part of the hexagonal architecture - defines the contract
 * for persisting audit logs to the database.
 * 
 * Implementations will be in the adapter layer (R2DBC).
 */
public interface AuditLogRepository {

    /**
     * Save an audit log entry
     * 
     * @param auditLog the audit log to save
     * @return Mono of saved audit log
     */
    Mono<AuditLog> save(AuditLog auditLog);

    /**
     * Find audit log by event ID
     * 
     * @param eventId the event ID
     * @return Mono of audit log
     */
    Mono<AuditLog> findByEventId(String eventId);

    /**
     * Find all audit logs for a specific entity
     * 
     * @param entityId the entity ID
     * @return Flux of audit logs
     */
    Flux<AuditLog> findByEntityId(Long entityId);

    /**
     * Find all audit logs with filters
     * 
     * @param status      filter by status (optional)
     * @param operation   filter by operation (optional)
     * @param chaosActive filter by chaos active (optional)
     * @param startTime   filter by start time (optional)
     * @param endTime     filter by end time (optional)
     * @return Flux of audit logs
     */
    Flux<AuditLog> findWithFilters(
            String status,
            String operation,
            Boolean chaosActive,
            Instant startTime,
            Instant endTime);

    /**
     * Find all failed operations
     * 
     * @return Flux of failed audit logs
     */
    Flux<AuditLog> findFailedOperations();

    /**
     * Delete audit logs before a specific timestamp
     * 
     * @param before the timestamp
     * @return Mono of number of deleted records
     */
    Mono<Long> deleteAuditLogsBefore(Instant before);

    /**
     * Delete all audit logs
     * 
     * @return Mono of number of deleted records
     */
    Mono<Long> deleteAll();

    /**
     * Count audit logs by status
     * 
     * @param status the status
     * @return Mono of count
     */
    Mono<Long> countByStatus(String status);

    /**
     * Count audit logs where chaos was active
     * 
     * @return Mono of count
     */
    Mono<Long> countByChaosActive();
}
