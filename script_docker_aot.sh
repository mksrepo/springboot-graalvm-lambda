#!/bin/bash
set -e

### ============================
###  CONFIGURATION
### ============================
AWS_REGION="ap-south-1"
REPO_NAME="springboot-graalvm-aot"
IMAGE_TAG="latest"
LAMBDA_FUNCTIclON="graalvm-lambda-native"
LAMBDA_ROLE="lambda-execution-role"

echo "🚀 Starting deployment..."

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
FULL_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

### ============================
### CHECK DOCKERFILE FOR COMPATIBLE GRAALVM
### ============================
if grep -q "native-image-community:25" Dockerfile.AOT || grep -q "native-image-community:24" Dockerfile.AOT; then
  echo "❌ ERROR: Your Dockerfile is using GraalVM 24 or 25."
  echo "❌ These versions require GLIBC >= 2.32 which Amazon Linux 2 DOES NOT support."
  echo "✅ FIX: Update Dockerfile base image to:"
  echo "   → ghcr.io/graalvm/native-image-community:22.3.3-ol9"
  exit 1
fi

echo "✔️ Dockerfile uses correct GraalVM version (22.x)."

### ============================
### 1️⃣ Build Docker image
### ============================
echo "🔧 Building Docker image using Amazon Linux compatible GraalVM..."
if ! docker build \
  -f Dockerfile_AOT \
  --platform linux/amd64 \
  --provenance=false \
  --sbom=false \
  -t "${REPO_NAME}:${IMAGE_TAG}" \
  .; then
    echo "❌ Docker build failed!"
    echo "This usually happens if:"
    echo " - Wrong GraalVM version is used"
    echo " - Native image failed due to missing libraries"
    exit 1
fi

echo "✔️ Docker build complete."
