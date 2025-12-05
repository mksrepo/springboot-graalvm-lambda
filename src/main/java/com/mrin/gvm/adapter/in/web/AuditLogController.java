package com.mrin.gvm.adapter.in.web;

import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.in.AuditLogService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * REST Controller for managing Audit Logs.
 * <p>
 * This adapter handles incoming HTTP requests for audit log retrieval and
 * deletion,
 * delegating business logic to the {@link AuditLogService}.
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/audit-logs")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogService auditLogService;

    /**
     * Retrieves all audit logs from the system.
     * <p>
     * Currently returns all logs without pagination or filtering.
     * </p>
     *
     * @return a Flux of {@link AuditLog} objects representing the audit history.
     */
    @GetMapping
    public Flux<AuditLog> getAuditLogs() {
        log.debug("Fetching all audit logs");
        // Passing nulls to imply "find all" without filters
        return auditLogService.getAuditLogs(null, null, null, null, null);
    }

    /**
     * Deletes all audit logs.
     * <p>
     * This is a destructive operation intended for administrative use or cleanup.
     * </p>
     *
     * @return a Mono containing the count of deleted logs.
     */
    @DeleteMapping("/all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Long> deleteAllAuditLogs() {
        log.warn("Request received to delete all audit logs");
        return auditLogService.deleteAllAuditLogs();
    }
}
