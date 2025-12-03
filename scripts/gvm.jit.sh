#!/bin/bash
set -e

### ============================
### CONFIGURATION
### ============================
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-jit"
TAG="v2.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"

DOCKERFILE="./dockerfiles/jit.dockerfile"

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
### Kubernetes Deployment
### ============================
DEPLOY_START=$(date +%s)
echo "📥 Step 4: Deploy to Kubernetes"

# Apply namespace
kubectl apply -f k8s/namespace.yaml

# Deploy JIT application
kubectl apply -f k8s/deployment-jit.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for JIT deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/springboot-graalvm-jit -n springboot-graalvm

# Get pod startup time
POD_NAME=$(kubectl get pods -n springboot-graalvm -l app=springboot-graalvm-jit -o jsonpath='{.items[0].metadata.name}')
echo "📦 Pod Name: ${POD_NAME}"

# Calculate startup time
STARTUP_TIME=$(./scripts/get_startup_time.sh "springboot-graalvm-jit")
echo "${STARTUP_TIME}" > ./report/startup_time_jit.txt
echo "✅ Pod started in ${STARTUP_TIME} ms"

kubectl get pods -n springboot-graalvm
DEPLOY_END=$(date +%s)

### ============================
### Summary
### ============================
echo ""
echo "==============================="
echo "📊 FINAL SUMMARY"
echo "==============================="
echo "Docker Build Time:      $((BUILD_END - BUILD_START)) seconds" > ./report/cicd_report_jit.txt
echo "Docker Push Time:       $((PUSH_END - PUSH_START)) seconds" >> ./report/cicd_report_jit.txt
echo "K8s Deployment Time:    $((DEPLOY_END - DEPLOY_START)) seconds" >> ./report/cicd_report_jit.txt
echo "Pod Startup Time:       ${STARTUP_TIME} ms" >> ./report/cicd_report_jit.txt
echo "Docker Image Size:      $(docker images ${IMAGE} --format "{{.Size}}")" >> ./report/cicd_report_jit.txt
echo ""
echo "📦 Image: ${IMAGE}"
echo "🌐 Service: springboot-graalvm-jit"
echo "🚀 App URL: http://localhost:30002/api/products"
echo "==============================="

### ============================
### K6 Load Testing
### ============================
k6 run ./load-tests/script.js --address localhost:6566 --env URL=http://localhost:30002/api/products --env TYPE=jit