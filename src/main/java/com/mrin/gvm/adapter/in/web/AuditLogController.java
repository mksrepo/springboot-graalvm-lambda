package com.mrin.gvm.adapter.in.web;

import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.in.AuditLogService;

import lombok.RequiredArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * REST Controller for Audit Log operations.
 * Inbound adapter in hexagonal architecture.
 */
@RestController
@RequestMapping("/api/audit-logs")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogService auditLogService;

    /**
     * Get all audit logs
     */
    @GetMapping
    public Flux<AuditLog> getAuditLogs() {
        // Passing nulls to imply "find all" without filters
        return auditLogService.getAuditLogs(null, null, null, null, null);
    }

    /**
     * Delete all audit logs (admin only)
     */
    @DeleteMapping("/all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Long> deleteAllAuditLogs() {
        return auditLogService.deleteAllAuditLogs();
    }
}
