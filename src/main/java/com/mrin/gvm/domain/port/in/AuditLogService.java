package com.mrin.gvm.domain.port.in;

import com.mrin.gvm.domain.model.AuditLog;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.Map;

/**
 * Input port (use case) for audit log operations.
 * This is part of the hexagonal architecture - defines the business logic
 * interface.
 * 
 * Implementations will be in the domain/application layer.
 */
public interface AuditLogService {

    /**
     * Get audit logs with optional filters
     * 
     * @param status      filter by status
     * @param operation   filter by operation
     * @param chaosActive filter by chaos active
     * @param startTime   filter by start time
     * @param endTime     filter by end time
     * @return Flux of audit logs
     */
    Flux<AuditLog> getAuditLogs(
            String status,
            String operation,
            Boolean chaosActive,
            Instant startTime,
            Instant endTime);

    /**
     * Get audit logs for a specific entity
     * 
     * @param entityId the entity ID
     * @return Flux of audit logs
     */
    Flux<AuditLog> getAuditLogsByEntityId(Long entityId);

    /**
     * Get all failed operations
     * 
     * @return Flux of failed audit logs
     */
    Flux<AuditLog> getFailedOperations();

    /**
     * Get chaos impact statistics
     * 
     * @return Mono of statistics map
     */
    Mono<Map<String, Object>> getChaosStatistics();

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
    Mono<Long> deleteAllAuditLogs();
}
