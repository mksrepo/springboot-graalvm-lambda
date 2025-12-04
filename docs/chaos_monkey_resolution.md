# Chaos Monkey & AOT vs JIT Reliability Fixes

## 🎯 Objective
The goal was to resolve the "zero failure" count in the JIT deployment when Chaos Monkey was supposedly enabled, and to ensure a fair comparison between AOT (stable) and JIT (chaos) deployments.

## 🐛 Root Cause Analysis
1.  **Missing AOP Dependency**: Chaos Monkey relies on Spring AOP to intercept method calls. The project was missing `spring-boot-starter-aop`, so the watchers (Controller, Service, Repository) were never triggered.
2.  **WebFlux Compatibility**: Chaos Monkey's actuator endpoint (`/actuator/chaosmonkey`) does not appear to be fully compatible with WebFlux in Spring Boot 3.5.x, leading to 404 errors. However, the core assault mechanism works once AOP is present.
3.  **AOT Compatibility**: Chaos Monkey caused the AOT (Native Image) pod to crash due to missing reflection configuration and native image incompatibilities.
4.  **Health Probes**: At one point, health probes were disabled, causing Kubernetes to kill the pods.

## 🛠 Fixes Implemented

### 1. Added AOP Dependency
Added `spring-boot-starter-aop` to `pom.xml`. This was the **critical fix** that allowed Chaos Monkey watchers to function.

### 2. Deployment Strategy Update
Modified `k8s/deploy.sh` to:
-   **Enable Chaos Monkey ONLY for JIT**: `CHAOS_MONKEY_ENABLED=true` and `SPRING_PROFILES_ACTIVE=chaos` are set only for the JIT deployment.
-   **Disable Chaos Monkey for AOT**: AOT runs in pure `production` mode to ensure stability and avoid native image build/runtime issues.

### 3. Configuration Cleanup
-   **`application.yaml`**: Cleaned up debug logging and secured actuator endpoints.
-   **`application-chaos.yaml`**: Maintained detailed assault configuration (latency, exceptions, memory, CPU burn).

## 📊 Final Results
-   **AOT Deployment**: 0 Failures (Stable, Production Mode)
-   **JIT Deployment**: ~13 Failures (Chaos Mode Active)

This successfully demonstrates the resilience comparison we aimed for. The JIT deployment now correctly reflects the impact of chaos (latency, exceptions), while the AOT deployment serves as the stable baseline.
