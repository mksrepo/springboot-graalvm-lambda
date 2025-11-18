#!/bin/bash
set -e

### ============================
###  CONFIGURATION
### ============================
AWS_REGION="ap-south-1"
REPO_NAME="springboot-graalvm-lambda"
IMAGE_TAG="latest"
LAMBDA_FUNCTION="graalvm-lambda-native"
LAMBDA_ROLE="lambda-execution-role"

echo "🚀 Starting deployment..."

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
FULL_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

### ============================
### 1️⃣ Build Docker image
### ============================
echo "🔧 Building Docker image..."
docker build --platform linux/amd64 -t ${REPO_NAME}:${IMAGE_TAG} .

### ============================
### 2️⃣ Create ECR repo if not exists
### ============================
echo "📦 Checking ECR repository..."
if ! aws ecr describe-repositories --repository-names "${REPO_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
    echo "📌 Creating ECR repository: ${REPO_NAME}"
    aws ecr create-repository --repository-name "${REPO_NAME}" --region "${AWS_REGION}"
else
    echo "✔️ ECR repo exists: ${REPO_NAME}"
fi

### ============================
### 3️⃣ Login to ECR
### ============================
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin \
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

### ============================
### 4️⃣ Tag & Push Image
### ============================
echo "🏷️ Tagging Docker image as ${FULL_URI}"
docker tag ${REPO_NAME}:${IMAGE_TAG} ${FULL_URI}

echo "⬆️ Pushing image to ECR..."
docker push ${FULL_URI}

echo "🎉 Image pushed successfully: ${FULL_URI}"

### ============================
### 5️⃣ Create Lambda Execution Role
### ============================
echo "🔑 Checking IAM role: ${LAMBDA_ROLE}"

if ! aws iam get-role --role-name "${LAMBDA_ROLE}" >/dev/null 2>&1; then
    echo "📌 Creating Lambda execution role..."
    aws iam create-role \
        --role-name "${LAMBDA_ROLE}" \
        --assume-role-policy-document '{
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": { "Service": "lambda.amazonaws.com" },
              "Action": "sts:AssumeRole"
            }
          ]
        }'

    echo "📌 Attaching AWSLambdaBasicExecutionRole policy..."
    aws iam attach-role-policy \
        --role-name "${LAMBDA_ROLE}" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

    echo "⏳ Waiting 10 seconds for IAM role propagation..."
    sleep 10
else
    echo "✔️ IAM Role exists: ${LAMBDA_ROLE}"
fi

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE}"

### ============================
### 6️⃣ Create / Update Lambda
### ============================
echo "🪄 Deploying Lambda function: ${LAMBDA_FUNCTION}"

if aws lambda get-function --function-name "${LAMBDA_FUNCTION}" --region "${AWS_REGION}" >/dev/null 2>&1; then
    echo "🔁 Updating existing Lambda..."
    aws lambda update-function-code \
        --function-name "${LAMBDA_FUNCTION}" \
        --image-uri "${FULL_URI}" \
        --region "${AWS_REGION}"
else
    echo "📌 Creating new Lambda function..."
    aws lambda create-function \
        --function-name "${LAMBDA_FUNCTION}" \
        --package-type Image \
        --code ImageUri="${FULL_URI}" \
        --role "${ROLE_ARN}" \
        --timeout 30 \
        --memory-size 512 \
        --region "${AWS_REGION}"
fi

echo "🎉 Deployment successful!"
echo "Lambda ARN:"
aws lambda get-function --function-name "${LAMBDA_FUNCTION}" --query 'Configuration.FunctionArn' --output text --region "${AWS_REGION}"