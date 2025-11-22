#!/bin/bash
set -e

### ============================
### CONFIGURATION
### ============================
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-aot"
TAG="v1.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"

K8S_DIR="./k8s"
DOCKER_DIR="./docker"

### ============================
echo "🚀 Step 1: Build Docker Image"
### ============================

docker build -f ${DOCKER_DIR}/dockerfile_aot -t ${IMAGE} .

echo "✔️ Build complete: ${IMAGE}"


### ============================
echo "🔐 Step 2: Docker Hub Login"
### ============================
docker login


### ============================
echo "📤 Step 3: Push to Docker Hub"
### ============================
docker push ${IMAGE}

echo "✔️ Image pushed successfully!"


### ============================
echo "📥 Step 4: Deploy to Kubernetes"
### ============================
# Update the deployment file with the correct image tag
sed -i '' "s|image: .*|image: ${IMAGE}|g" ${K8S_DIR}/aot_deployment.yaml

kubectl apply -f ${K8S_DIR}/deployment_aot.yaml
kubectl apply -f ${K8S_DIR}/service_aot.yaml

echo "⏳ Waiting for pods..."
sleep 4

kubectl get pods
kubectl get svc

echo "🎉 AOT Deployment complete!"
echo "🌍 Access your app at: https://localhost:30000/"