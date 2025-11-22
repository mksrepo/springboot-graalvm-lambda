#!/bin/bash
set -e

### ============================
### CONFIGURATION
### ============================
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-jit"
TAG="v2.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"

K8S_DIR="./k8s"
DOCKERFILE="./docker/dockerfile_jit"

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

# Update deployment image reference
sed -i '' "s|image: .*|image: ${IMAGE}|g" ${K8S_DIR}/deployment_jit.yaml

kubectl apply -f ${K8S_DIR}/deployment_jit.yaml
kubectl apply -f ${K8S_DIR}/service_jit.yaml

echo "⏳ Waiting for Kubernetes to create pod..."
sleep 5

kubectl get pods
kubectl get svc
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
echo ""
echo "📦 Image: ${IMAGE}"
echo "🌐 Service: springboot-graalvm-service-jit"
echo "🚀 App URL: https://localhost:30002/hello"
echo "==============================="

### ============================
### K6 Load Testing
### ============================
k6 run ./k6/script.js --address localhost:6566 --env URL=http://localhost:30002/hello --env TYPE=jit