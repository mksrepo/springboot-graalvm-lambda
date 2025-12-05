package com.mrin.gvm.adapter.in.web;

import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.in.AuditLogUseCase;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.Map;

/**
 * REST Controller for Audit Log operations.
 * Inbound adapter in hexagonal architecture.
 */
@RestController
@RequestMapping("/api/audit-logs")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogUseCase auditLogUseCase;

    /**
     * Get all audit logs with optional filters
     */
    @GetMapping
    public Flux<AuditLog> getAuditLogs(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String operation,
            @RequestParam(required = false) Boolean chaosActive,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant startTime,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant endTime) {
        return auditLogUseCase.getAuditLogs(status, operation, chaosActive, startTime, endTime);
    }

    /**
     * Get audit logs for specific product
     */
    @GetMapping("/product/{productId}")
    public Flux<AuditLog> getProductAuditLogs(@PathVariable Long productId) {
        return auditLogUseCase.getAuditLogsByEntityId(productId);
    }

    /**
     * Get failed operations (chaos-related)
     */
    @GetMapping("/failures")
    public Flux<AuditLog> getFailedOperations() {
        return auditLogUseCase.getFailedOperations();
    }

    /**
     * Get chaos impact statistics
     */
    @GetMapping("/chaos-stats")
    public Mono<Map<String, Object>> getChaosStatistics() {
        return auditLogUseCase.getChaosStatistics();
    }

    /**
     * Delete old audit logs
     */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Long> deleteOldAuditLogs(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant before) {
        return auditLogUseCase.deleteAuditLogsBefore(before);
    }

    /**
     * Delete all audit logs (admin only)
     */
    @DeleteMapping("/all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Long> deleteAllAuditLogs() {
        return auditLogUseCase.deleteAllAuditLogs();
    }
}
