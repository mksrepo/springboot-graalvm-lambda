package com.mrin.gvm.application.service;

import com.mrin.gvm.domain.model.AuditLog;
import com.mrin.gvm.domain.port.in.AuditLogService;
import com.mrin.gvm.domain.port.out.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Application service implementing audit log use cases.
 * Part of hexagonal architecture application layer.
 */
@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    public Flux<AuditLog> getAuditLogs(
            String status,
            String operation,
            Boolean chaosActive,
            Instant startTime,
            Instant endTime) {
        return auditLogRepository.findWithFilters(status, operation, chaosActive, startTime, endTime);
    }

    @Override
    public Flux<AuditLog> getAuditLogsByEntityId(Long entityId) {
        return auditLogRepository.findByEntityId(entityId);
    }

    @Override
    public Flux<AuditLog> getFailedOperations() {
        return auditLogRepository.findFailedOperations();
    }

    @Override
    public Mono<Map<String, Object>> getChaosStatistics() {
        return Mono.zip(
                auditLogRepository.countByStatus("SUCCEEDED"),
                auditLogRepository.countByStatus("FAILED"),
                auditLogRepository.countByChaosActive()).map(tuple -> {
                    Map<String, Object> stats = new HashMap<>();
                    stats.put("totalSucceeded", tuple.getT1());
                    stats.put("totalFailed", tuple.getT2());
                    stats.put("chaosImpacted", tuple.getT3());
                    stats.put("successRate", calculateSuccessRate(tuple.getT1(), tuple.getT2()));
                    return stats;
                });
    }

    @Override
    public Mono<Long> deleteAuditLogsBefore(Instant before) {
        return auditLogRepository.deleteAuditLogsBefore(before);
    }

    @Override
    public Mono<Long> deleteAllAuditLogs() {
        return auditLogRepository.deleteAll();
    }

    private double calculateSuccessRate(Long succeeded, Long failed) {
        long total = succeeded + failed;
        return total == 0 ? 0.0 : (succeeded * 100.0) / total;
    }
}
