# Spring Boot GraalVM Lambda Demo

## Overview
This repository demonstrates a simple Spring Boot REST service built and deployed in two ways:
- **AOT** – GraalVM native image (ahead‑of‑time compilation)
- **JIT** – Traditional JVM execution

Both variants are containerised, pushed to Docker Hub, deployed to a local Kubernetes cluster, and load‑tested with **k6**. A CI/CD‑style script captures build, push, deployment, and application start times (in milliseconds) and generates a markdown performance comparison report.

## Prerequisites
- macOS (or Linux) with **Docker Desktop** (including Kubernetes) installed
- **kubectl** configured to talk to the local cluster
- **Docker Hub** account (set `DOCKERHUB_USER` in the scripts)
- **GraalVM** (for native image builds) – the Docker base image `ghcr.io/graalvm/native-image-community:25` is used, so no local GraalVM installation is required.
- **k6** (`brew install k6` or download from https://k6.io)
- **bash**, **sed**, **date**, **python3** (standard on macOS)

## Project Structure
```
├── src/main/java/com/mrin/gvm/api/GreetingController.java   # simple "Hello" endpoint
├── pom.xml                                                # Maven build, native plugin
├── sh/gvm.aot.sh                                         # AOT build, push, deploy, report
├── sh/gvm.jit.sh                                         # JIT build, push, deploy, report
├── sh/generate_report.sh                                 # Generates aot_vs_jit.md
├── k6/script.js                                          # k6 load test (10 VUs, 5 s)
├── report/                                               # CI/CD metrics & comparison report
└── k8s/                                                 # Deployment & Service yaml files
```

## Building & Deploying
### AOT (Native Image)
```bash
chmod +x sh/gvm.aot.sh
./sh/gvm.aot.sh
```
The script will:
1. Build the native image Docker image.
2. Push it to Docker Hub.
3. Deploy to Kubernetes (`deployment_aot.yaml`).
4. Force a pod restart to capture a fresh **App Start Time**.
5. Write CI/CD metrics to `report/cicd_report_aot.txt`.

### JIT (JVM)
```bash
chmod +x sh/gvm.jit.sh
./sh/gvm.jit.sh
```
Same steps as AOT but using the standard JVM image.

## Load Testing with k6
Both scripts invoke k6 after deployment:
```bash
k6 run ./k6/script.js --address localhost:6565 \
    --env URL=http://localhost:30001/hello --env TYPE=aot
```
and similarly for JIT (port 6566, URL 30002). Results are stored in `report/k6_report_aot.txt` and `report/k6_report_jit.txt`.

## Generating the Performance Comparison Report
After both builds have completed, run:
```bash
chmod +x sh/generate_report.sh
./sh/generate_report.sh
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
# Delete deployments and services
kubectl delete -f k8s/deployment_aot.yaml k8s/service_aot.yaml
kubectl delete -f k8s/deployment_jit.yaml k8s/service_jit.yaml

# Remove Docker images locally
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-aot:${TAG}
docker rmi ${DOCKERHUB_USER}/springboot-graalvm-jit:${TAG}
```

## License
This demo project is provided under the MIT License.

---
*Generated automatically by the project scripts.*
