#!/bin/bash

### CONFIG ###
AWS_REGION="ap-south-1"          # change if needed
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REPO_NAME="springboot-graalvm-lambda"
IMAGE_TAG="latest"

### 1. Build Docker Image ###
echo "🔧 Building Docker image..."
docker build -t ${REPO_NAME}:${IMAGE_TAG} .

### 2. Create ECR Repo If Not Exists ###
echo "📦 Checking ECR repo..."
aws ecr describe-repositories --repository-names "${REPO_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "📌 Creating ECR repository ${REPO_NAME}..."
  aws ecr create-repository --repository-name "${REPO_NAME}" --region "${AWS_REGION}"
else
  echo "✔️ ECR repository exists."
fi

### 3. Login to ECR ###
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

### 4. Tag Image ###
FULL_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"
echo "🏷️ Tagging image as ${FULL_URI}"
docker tag ${REPO_NAME}:${IMAGE_TAG} ${FULL_URI}

### 5. Push Image ###
echo "⬆️ Pushing image to ECR..."
docker push ${FULL_URI}

echo ""
echo "🎉 SUCCESS! Image pushed to ECR:"
echo "${FULL_URI}"
echo ""