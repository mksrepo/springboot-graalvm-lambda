# Spring Boot GraalVM Lambda Demo

## Overview
This repository demonstrates a simple Spring Boot REST service built and deployed in two ways:
- **AOT** – GraalVM native image (ahead‑of‑time compilation)
- **JIT** – Traditional JVM execution

## Running the Complete Pipeline
The `run.sh` script orchestrates the entire deployment and testing process:

```bash
chmod +x run.sh
./run.sh
```

**Smart Infrastructure Management:**
- **First run**: Sets up complete infrastructure (Prometheus, Grafana, PostgreSQL)
- **Subsequent runs**: Preserves infrastructure, only redeploys applications
- **Time saved**: ~90-120 seconds per run after first deployment!

## Cleaning Up

### Quick Cleanup (Recommended for Development)
Removes only application deployments, preserves infrastructure:
```bash
./k8s/cleanup.sh
# or
./k8s/cleanup-apps.sh
```

**Benefits:**
- ⚡ Fast (~5-10 seconds)
- 📊 Preserves monitoring data
- 🗄️ Preserves database
- Perfect for iterative testing

### Full Cleanup (Complete Teardown)
Removes everything including infrastructure:
```bash
./k8s/cleanup-full.sh
```

**When to use:**
- End of testing session
- Freeing up cluster resources
- Starting fresh

### Manual Cleanup
```bash
# Remove Docker images locally
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-aot:${TAG}
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-jit:${TAG}
```

## Prerequisites
- macOS (or Linux) with **Docker Desktop** (including Kubernetes) installed
- **kubectl** configured to talk to the local cluster
- **Docker Hub** account (set `DOCKERHUB_USER` in the scripts)
- **GraalVM** (for native image builds) – the Docker base image `ghcr.io/graalvm/native-image-community:25` is used, so no local GraalVM installation is required.
- **k6** (`brew install k6` or download from https://k6.io)
- **bash**, **sed**, **date**, **python3** (standard on macOS)

## Project Structure
```
├── pom.xml                             # Maven build configuration
├── src/                                # Spring Boot source code
├── run.sh                              # Main deployment script
├── dockerfiles/                        # Docker build files
│   ├── aot.dockerfile                  # GraalVM native image build
│   └── jit.dockerfile                  # Standard JVM build
├── k8s/                                # Kubernetes manifests
│   ├── apps/                           # Application deployments
│   │   ├── deployment-aot.yaml         # AOT deployment
│   │   └── deployment-jit.yaml         # JIT deployment
│   └── infra/                          # Infrastructure components
│       ├── namespace.yaml              # Namespace definition
│       ├── database/                   # Database configurations
│       │   └── postgres.yaml           # PostgreSQL database
│       └── monitoring/                 # Observability stack
│           ├── prometheus.yaml         # Prometheus monitoring
│           ├── grafana.yaml            # Grafana dashboards
│           └── provisioning/           # Grafana provisioning files
│               ├── dashboards/         # Dashboard JSON files
│               └── datasources/        # Datasource configurations
├── scripts/                            # Build and deployment scripts
│   ├── build/                          # Build and deployment pipelines
│   │   ├── gvm.aot.sh                  # AOT build pipeline
│   │   └── gvm.jit.sh                  # JIT build pipeline
│   └── reporting/                      # Performance reporting
│       ├── generate_report.sh          # Performance report generator
│       └── get_startup_time.sh         # Startup time calculator
├── load-tests/                         # K6 load testing scripts
│   └── script.js                       # Load test configuration
└── report/                             # Generated reports and metrics
```

## Building & Deploying
### AOT (Native Image)
```bash
chmod +x scripts/build/gvm.aot.sh
./scripts/build/gvm.aot.sh
```
The script will:
1. Build the native image Docker image.
2. Push it to Docker Hub.
3. Deploy to Kubernetes (`deployment_aot.yaml`).
4. Force a pod restart to capture a fresh **App Start Time**.
5. Write CI/CD metrics to `report/cicd_report_aot.txt`.

### JIT (JVM)
```bash
chmod +x scripts/build/gvm.jit.sh
./scripts/build/gvm.jit.sh
```
Same steps as AOT but using the standard JVM image.

## Load Testing with k6
Both scripts invoke k6 after deployment:
```bash
k6 run ./load-tests/script.js --address localhost:6565 \
    --env URL=http://localhost:30001/hello --env TYPE=aot
```
and similarly for JIT (port 6566, URL 30002). Results are stored in `report/k6_report_aot.txt` and `report/k6_report_jit.txt`.

## Generating the Performance Comparison Report
After both builds have completed, run:
```bash
chmod +x scripts/reporting/generate_report.sh
./scripts/reporting/generate_report.sh
```
The script reads the k6 and CI/CD metric files and creates `report/aot_vs_jit.md` containing a side‑by‑side table of:
- Total requests, throughput, latency
- Data received
- Docker build/push/deployment times (ms)
- Docker image size
- **App Start Time** (ms)

## CI/CD Metrics
All timings are recorded in **milliseconds** in the `report/cicd_report_*.txt` files, e.g.:
```
Docker Build Time:      2000 ms
Docker Push Time:       6000 ms
K8s Deployment Time:    5000 ms
Docker Image Size:      241MB
App Start Time:         85 ms
```
These values are automatically pulled into the markdown report.

## Cleaning Up
```bash
# Cleanup all resources
./k8s/cleanup.sh

# Remove Docker images locally
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-aot:${TAG}
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-jit:${TAG}
```

## License
This demo project is provided under the MIT License.

---
*Generated automatically by the project scripts.*
