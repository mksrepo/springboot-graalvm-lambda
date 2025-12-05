# Spring Boot GraalVM Lambda - Resiliency & Performance Lab

## Overview
This repository provides a comprehensive lab environment for comparing **GraalVM Native Image (AOT)** and **Standard JVM (JIT)** deployments on Kubernetes. It goes beyond simple benchmarks by integrating **Chaos Engineering** and **Full-stack Observability** to simulate realistic production scenarios.

## Key Features
- **Dual-Mode Deployment**: Sequential AOT and JIT deployment pipelines.
- **Chaos Engineering**: Integration with [Chaos Mesh](https://chaos-mesh.org/) for determining system resilience.
- **Observability Stack**: Pre-configured Prometheus and Grafana for metrics visualization.
- **Event-Driven Architecture**: Uses Kafka for asynchronous auditing of domain events.
- **Automated Reporting**: Generates side-by-side performance comparison reports (Startup time, Throughput, Latency, Image Size).

## Quick Start

### Prerequisites
- **Docker Desktop** (Kubernetes enabled)
- **kubectl**
- **Java 17+** & **Maven 3.8+**
- **k6** (for load testing)
- **Docker Hub** account (logged in via `docker login`)

### Running the Orchestrator
The `run.sh` script handles the entire lifecycle: provisioning infrastructure, building images, deploying apps, and running tests.

```bash
# Standard Run (Deploy Apps + Infra + Tests)
./run.sh

# Run with Chaos Engineering Enabled
./run.sh --chaos
```

**What happens next?**
1. **Infra Setup**: Deploys PostgreSQL, Kafka, Prometheus, and Grafana (only on first run).
2. **Chaos Setup**: Installs Chaos Mesh (if `--chaos` flag is used).
3. **Build & Deploy**:
   - Builds AOT Native Image & JIT Jar.
   - Pushes to Docker Hub.
   - Deploys to Kubernetes.
4. **Validation**: Runs K6 load tests against both deployments.
5. **Reporting**: Generates a performance comparison report in `report/aot_vs_jit.md`.

## Architecture & Access Points

| Service | Local URL | Credentials |
|:---|:---|:---|
| **AOT API** | http://localhost:30001/api/products | - |
| **JIT API** | http://localhost:30002/api/products | - |
| **Grafana** | http://localhost:30004 | `admin` / `admin` |
| **Prometheus** | http://localhost:30003 | - |
| **Chaos Dashboard** | http://localhost:2333 | - |

## Chaos Engineering Experiments
When running with `--chaos`, the system applies the following Stress & Fault Injection scenarios:
- **Pod Kill**: Randomly terminates application pods.
- **Network Delay**: Injects latency into service-to-service calls.
- **CPU Stress**: Consumes CPU cycles to test autoscaling/throttling.
- **Memory Stress**: Consumes memory to test OOM behavior.
- **DB Partition**: Simulates network failure between App and Database.

## Project Structure
```
├── src/                        # Spring Boot Application (Hexagonal Architecture)
├── kubernetes/
│   ├── apps/                   # App Deployment Manifests
│   ├── chaos/                  # Chaos Mesh Experiments
│   ├── infra/                  # Postgres, Prometheus, Grafana
│   └── kafka/                  # Kafka Cluster
├── scripts/
│   ├── build/                  # Docker Build & Push Scripts
│   └── reporting/              # Performance Analysis Scripts
├── run.sh                      # Main Orchestration Script
└── report/                     # Generated Test Reports
```

## Cleanup
To remove all resources and free up your cluster:

```bash
# Remove Apps only (Fast)
./kubernetes/cleanup.sh

# Remove Apps + Infrastructure (Deep Clean)
./kubernetes/cleanup-full.sh
```

## License
MIT License
