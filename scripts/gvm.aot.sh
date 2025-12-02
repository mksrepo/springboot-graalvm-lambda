#!/bin/bash
set -e

### ============================
### CONFIGURATION
### ============================
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-aot"
TAG="v2.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"

DOCKERFILE="./docker/dockerfile_aot"

### ============================
### Time Tracking
### ============================
BUILD_START=$(date +%s)

echo "🚀 Step 1: Docker Build"
docker build -f ${DOCKERFILE} -t ${IMAGE} .
BUILD_END=$(date +%s)

echo "🔐 Step 2: Docker Hub Login"
docker login

PUSH_START=$(date +%s)
echo "📤 Step 3: Push to Docker Hub"
docker push ${IMAGE}
PUSH_END=$(date +%s)

### ============================
### Docker Compose Deployment
### ============================
DEPLOY_START=$(date +%s)
echo "📥 Step 4: Deploy with Docker Compose"

# Deploy AOT service
docker compose up -d --build springboot-graalvm-aot

# Calculate Startup Time
STARTUP_TIME=$(./scripts/get_startup_time.sh "springboot-graalvm-aot")
echo "${STARTUP_TIME}" > ./report/startup_time_aot.txt
echo "✅ Container Started in ${STARTUP_TIME} ms"

docker compose ps
DEPLOY_END=$(date +%s)

### ============================
### Summary
### ============================
echo ""
echo "==============================="
echo "📊 FINAL SUMMARY"
echo "==============================="
echo "Docker Build Time:      $((BUILD_END - BUILD_START)) seconds" > ./report/cicd_report_aot.txt
echo "Docker Push Time:       $((PUSH_END - PUSH_START)) seconds" >> ./report/cicd_report_aot.txt
echo "K8s Deployment Time:    $((DEPLOY_END - DEPLOY_START)) seconds" >> ./report/cicd_report_aot.txt
echo "Pod Startup Time:       ${STARTUP_TIME} ms" >> ./report/cicd_report_aot.txt
echo "Docker Image Size:      $(docker images ${IMAGE} --format "{{.Size}}")" >> ./report/cicd_report_aot.txt
echo ""
echo "📦 Image: ${IMAGE}"
echo "🌐 Service: springboot-graalvm-service-aot"
echo "🚀 App URL: https://localhost:30001/hello"
echo "==============================="

### ============================
### K6 Load Testing
### ============================
k6 run ./load-tests/script.js --address localhost:6565 --env URL=http://localhost:30001/api/products --env TYPE=aot