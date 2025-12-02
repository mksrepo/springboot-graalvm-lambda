# Spring Boot GraalVM - AOT vs JIT Performance Comparison

## Overview

This project compares the performance of **GraalVM Native Image (AOT)** vs **Standard JVM (JIT)** for a Spring Boot application with **Chaos Engineering** enabled. The application is deployed to **Kubernetes (Docker Desktop)** for realistic production-like testing.

## Key Features

✅ **Kubernetes Deployment** - Full K8s manifests with health checks and resource limits  
✅ **Chaos Engineering** - Custom CPU & Memory burn assaults using Chaos Monkey  
✅ **Automated Testing** - K6 load testing with performance metrics collection  
✅ **Monitoring** - Prometheus + Grafana stack for observability  
✅ **Automated Reporting** - Side-by-side comparison of AOT vs JIT performance  

---

## Quick Start

### Prerequisites

1. **Docker Desktop** with Kubernetes enabled
2. **kubectl** CLI tool
3. **k6** for load testing
4. **Maven** and **Java 17**
5. Docker Hub account

### Deploy Everything

```bash
./run.sh
```

This single command will:
1. Clean up any existing K8s resources
2. Deploy Prometheus and Grafana monitoring
3. Build Docker images for AOT and JIT versions
4. Push images to Docker Hub
5. Deploy both versions to Kubernetes
6. Run K6 load tests against both
7. Generate a performance comparison report

---

## Project Structure

```
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace isolation
│   ├── deployment-aot.yaml       # AOT deployment + service
│   ├── deployment-jit.yaml       # JIT deployment + service
│   ├── prometheus.yaml           # Prometheus monitoring
│   └── grafana.yaml              # Grafana visualization
├── scripts/
│   ├── gvm.aot.k8s.sh           # AOT build & K8s deployment
│   ├── gvm.jit.k8s.sh           # JIT build & K8s deployment
│   ├── get_k8s_startup_time.sh  # Pod startup time calculator
│   ├── cleanup_k8s.sh           # K8s resource cleanup
│   └── generate_report.sh       # Performance report generator
├── load-tests/
│   └── script.js                # K6 load testing script
├── docker/
│   ├── dockerfile_aot           # GraalVM Native Image build
│   └── dockerfile_jit           # Standard JVM build
└── report/                      # Generated performance reports
```

---

## Access Points

Once deployed, access your applications at:

- **AOT Application**: http://localhost:30001/api/products
- **JIT Application**: http://localhost:30002/api/products
- **Prometheus**: http://localhost:30003
- **Grafana**: http://localhost:30004 (admin/admin)

---

## Monitoring & Debugging

### View Kubernetes Resources

```bash
# View all pods
kubectl get pods -n springboot-graalvm

# View services
kubectl get svc -n springboot-graalvm

# View deployments
kubectl get deployments -n springboot-graalvm
```

### View Logs

```bash
# Get pod name
kubectl get pods -n springboot-graalvm

# View logs
kubectl logs -f <pod-name> -n springboot-graalvm

# View logs for AOT specifically
kubectl logs -f deployment/springboot-graalvm-aot -n springboot-graalvm
```

### Restart Deployments

```bash
kubectl rollout restart deployment/springboot-graalvm-aot -n springboot-graalvm
kubectl rollout restart deployment/springboot-graalvm-jit -n springboot-graalvm
```

---

## Chaos Engineering

The application includes **Chaos Monkey for Spring Boot** with custom assaults:

### Built-in Assaults
- **Exception Injection** - Random exceptions thrown
- **Latency Injection** - 1-3 second delays added
- **Kill Application** - Random pod restarts

### Custom Assaults
- **CPU Burn** (`CpuBurnAssault`) - 3 seconds of intensive CPU computation
- **Memory Burn** (`MemoryBurnAssault`) - Allocates 50MB of memory

### Configuration

See `src/main/resources/application.yaml`:
```yaml
chaos:
  monkey:
    enabled: true
    watcher:
      controller: true
      service: true
    assaults:
      level: 2
      exceptions-active: true
      latency-active: true
      killApplicationActive: true
```

### Observing Chaos

Watch the logs to see chaos in action:
```bash
kubectl logs -f deployment/springboot-graalvm-jit -n springboot-graalvm | grep "🔥\|🧠"
```

---

## Performance Reports

After running `./run.sh`, check the generated report:

```bash
cat report/aot_vs_jit.md
```

The report includes:
- **Throughput** (requests/sec)
- **Latency** (avg and p95)
- **Docker Build Time**
- **Image Size**
- **Pod Startup Time**
- **Total Requests Handled**

---

## Clean Up

Remove all Kubernetes resources:

```bash
./scripts/cleanup_k8s.sh
```

Or manually:
```bash
kubectl delete namespace springboot-graalvm
```

---

## Architecture

### Deployment Flow

```
run.sh
  ├── cleanup_k8s.sh (remove old resources)
  ├── Deploy Monitoring (Prometheus + Grafana)
  ├── gvm.aot.k8s.sh
  │     ├── Docker Build (Native Image)
  │     ├── Docker Push
  │     ├── kubectl apply (deployment-aot.yaml)
  │     └── k6 Load Test
  ├── gvm.jit.k8s.sh
  │     ├── Docker Build (JVM)
  │     ├── Docker Push
  │     ├── kubectl apply (deployment-jit.yaml)
  │     └── k6 Load Test
  └── generate_report.sh (compare metrics)
```

### Kubernetes Resources

For each application (AOT/JIT):
- **Deployment**: 1 replica with health checks
- **Service**: NodePort (30001 for AOT, 30002 for JIT)
- **Resource Limits**: Memory & CPU constraints
- **Probes**: Liveness & Readiness checks

---

## Troubleshooting

### Kubernetes Not Running

```bash
# Check cluster status
kubectl cluster-info

# If not running, enable in Docker Desktop:
# Settings → Kubernetes → Enable Kubernetes
```

### Image Pull Errors

```bash
# Check if logged into Docker Hub
docker login

# Verify images exist
docker images | grep springboot-graalvm
```

### Pod CrashLoopBackOff

```bash
# Check pod events
kubectl describe pod <pod-name> -n springboot-graalvm

# Check logs
kubectl logs <pod-name> -n springboot-graalvm
```

### Load Test Failures

```bash
# Check if services are exposed
kubectl get svc -n springboot-graalvm

# Test connectivity
curl http://localhost:30001/actuator/health
curl http://localhost:30002/actuator/health
```

---

## Technical Details

### AOT Build Optimizations
- **GraalVM Native Image Community 25**
- **Build Arguments**: Default Spring Boot AOT configuration
- **Base Image**: `debian:bookworm-slim`
- **Size**: ~359MB

### JIT Build
- **Base Image**: `amazoncorretto:17-alpine`
- **Layered JAR**: Optimized for Docker caching
- **Size**: ~579MB

### Load Testing
- **Tool**: K6
- **Configuration**: 10 VUs for 5 seconds (configurable in `load-tests/script.js`)
- **Endpoints**: `/api/products` (CRUD operations)

---

## Next Steps

- [ ] Enable Horizontal Pod Autoscaling (HPA)
- [ ] Add Ingress for external access
- [ ] Configure persistent storage for Prometheus
- [ ] Set up Grafana dashboards automatically
- [ ] Implement CI/CD pipeline (GitHub Actions)

---

## Scripts Reference

### Main Scripts

| Script | Purpose |
|--------|---------|
| `run.sh` | Master deployment script (runs everything) |
| `scripts/cleanup_k8s.sh` | Remove all K8s resources |
| `scripts/generate_report.sh` | Generate performance comparison |

### Deployment Scripts

| Script | Purpose |
|--------|---------|
| `scripts/gvm.aot.k8s.sh` | Build, push, deploy AOT to K8s |
| `scripts/gvm.jit.k8s.sh` | Build, push, deploy JIT to K8s |
| `scripts/get_k8s_startup_time.sh` | Calculate pod startup time |

---

## Report Output Example

```markdown
# Performance Comparison: AOT vs JIT

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests** | 32,996 | 38,028 |
| **Throughput** | 109.92 req/s | 126.61 req/s |
| **Avg Response Time** | 90.75ms | 78.76ms |
| **Pod Startup Time** | 5,865 ms | 5,824 ms |
| **Docker Image Size** | 359MB | 579MB |
```

---

## Credits

Built with:
- **Spring Boot 3.5.7**
- **GraalVM Native Image**
- **Chaos Monkey for Spring Boot**
- **Kubernetes**
- **Prometheus & Grafana**
- **K6 Load Testing**
