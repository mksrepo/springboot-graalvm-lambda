#!/bin/bash
set -e

### ============================
###  CONFIGURATION
### ============================
REPO_NAME="springboot-graalvm-jar"   # rename if you want
IMAGE_TAG="latest"

echo "🚀 Starting local Docker build (JAR-based)..."

### ============================
### 1️⃣ Build JAR
### ============================
echo "📦 Building Spring Boot JAR..."
./mvnw clean package -DskipTests

if [ ! -f target/*.jar ]; then
  echo "❌ ERROR: No JAR produced in target/ directory!"
  exit 1
fi

### ============================
### 2️⃣ Build Docker image (JAR)
### ============================
echo "🐳 Building Docker image using local Dockerfile..."

if ! docker build \
  -f Dockerfile_JIT \
  --platform linux/amd64 \
  --provenance=false \
  --sbom=false \
  -t "${REPO_NAME}:${IMAGE_TAG}" \
  .; then
    echo "❌ Docker build failed!"
    echo "Check:"
    echo " - JAR exists in target/"
    echo " - Dockerfile COPY path matches 'target/*.jar'"
    exit 1
fi

echo "✔️ Docker build complete: ${REPO_NAME}:${IMAGE_TAG}"
echo "🎉 Done."