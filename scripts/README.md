# Scripts

This directory contains automation scripts for building, deploying, and reporting on the Spring Boot GraalVM application.

## Structure

```
scripts/
├── build/                          # Build and deployment pipelines
│   ├── gvm.aot.sh                  # AOT (GraalVM Native Image) build pipeline
│   └── gvm.jit.sh                  # JIT (Traditional JVM) build pipeline
└── reporting/                      # Performance reporting and metrics
    ├── generate_report.sh          # Generate performance comparison report
    └── get_startup_time.sh         # Calculate pod startup time
```

## Build Scripts (`build/`)

### `gvm.aot.sh`
Builds, pushes, and deploys the AOT (Ahead-of-Time compiled) version using GraalVM Native Image.

**Steps:**
1. Builds Docker image using `dockerfiles/aot.dockerfile`
2. Pushes to Docker Hub
3. Deploys to Kubernetes
4. Runs K6 load tests
5. Captures metrics (build time, image size, startup time)

**Usage:**
```bash
./scripts/build/gvm.aot.sh
```

### `gvm.jit.sh`
Builds, pushes, and deploys the JIT (Just-in-Time compiled) version using traditional JVM.

**Steps:**
1. Builds Docker image using `dockerfiles/jit.dockerfile`
2. Pushes to Docker Hub
3. Deploys to Kubernetes
4. Runs K6 load tests
5. Captures metrics (build time, image size, startup time)

**Usage:**
```bash
./scripts/build/gvm.jit.sh
```

## Reporting Scripts (`reporting/`)

### `generate_report.sh`
Generates a comprehensive performance comparison report between AOT and JIT deployments.

**Inputs:**
- `report/k6_report_aot.txt` - K6 load test results for AOT
- `report/k6_report_jit.txt` - K6 load test results for JIT
- `report/cicd_report_aot.txt` - CI/CD metrics for AOT
- `report/cicd_report_jit.txt` - CI/CD metrics for JIT
- `report/startup_time_aot.txt` - Pod startup time for AOT
- `report/startup_time_jit.txt` - Pod startup time for JIT

**Output:**
- `report/aot_vs_jit.md` - Markdown report with comparison table and key findings

**Usage:**
```bash
./scripts/reporting/generate_report.sh
```

### `get_startup_time.sh`
Calculates the pod startup time by measuring the time between pod creation and readiness.

**Usage:**
```bash
./scripts/reporting/get_startup_time.sh <deployment-name>
```

**Example:**
```bash
./scripts/reporting/get_startup_time.sh springboot-graalvm-aot
```

## Kubernetes Management

The cleanup script has been moved to the `k8s/` folder as it's Kubernetes-specific:
- `k8s/cleanup.sh` - Deletes all Kubernetes resources in the `springboot-graalvm` namespace

**Usage:**
```bash
./k8s/cleanup.sh
```

## Running Everything

To run the complete build, deploy, and test pipeline:

```bash
./run.sh
```

This will:
1. Clean up existing resources
2. Deploy infrastructure (PostgreSQL, Prometheus, Grafana)
3. Build and deploy both AOT and JIT versions
4. Run load tests on both
5. Generate performance comparison report
