#!/bin/bash
set -e

### CONFIG ###
AWS_REGION="ap-south-1"          # change if needed
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REPO_NAME="springboot-graalvm-lambda"
IMAGE_TAG="latest"
LAMBDA_FUNCTION="graalvm-lambda-native"
LAMBDA_ROLE="lambda-execution-role"

### 1️⃣ Build Docker Image ###
echo "🔧 Building Docker image..."
docker build -t ${REPO_NAME}:${IMAGE_TAG} .

### 2️⃣ Create ECR Repo If Not Exists ###
echo "📦 Checking ECR repo..."
aws ecr describe-repositories --repository-names "${REPO_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1 || {
  echo "📌 Creating ECR repository ${REPO_NAME}..."
  aws ecr create-repository --repository-name "${REPO_NAME}" --region "${AWS_REGION}"
}

### 3️⃣ Login to ECR ###
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

### 4️⃣ Tag & Push Image ###
FULL_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"
echo "🏷️ Tagging image as ${FULL_URI}"
docker tag ${REPO_NAME}:${IMAGE_TAG} ${FULL_URI}

echo "⬆️ Pushing image to ECR..."
docker push ${FULL_URI}
echo "🎉 Docker image pushed to ECR: ${FULL_URI}"
echo ""

### 5️⃣ Create Lambda Execution Role (if missing) ###
echo "🔑 Checking Lambda execution role..."
if ! aws iam get-role --role-name "${LAMBDA_ROLE}" >/dev/null 2>&1; then
  echo "📌 Creating Lambda execution role: ${LAMBDA_ROLE}..."
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
  echo "✔️ Lambda execution role exists: ${LAMBDA_ROLE}"
fi

### 6️⃣ Deploy Lambda Function ###
echo "🚀 Deploying Lambda function: ${LAMBDA_FUNCTION}"
if ! aws lambda get-function --function-name "${LAMBDA_FUNCTION}" >/dev/null 2>&1; then
  echo "📌 Lambda does NOT exist — creating function..."
  aws lambda create-function \
    --function-name "${LAMBDA_FUNCTION}" \
    --package-type Image \
    --code ImageUri="${FULL_URI}" \
    --role "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE}"
else
  echo "📌 Lambda exists — updating image..."
  aws lambda update-function-code \
    --function-name "${LAMBDA_FUNCTION}" \
    --image-uri "${FULL_URI}"
fi

echo "🎉 Deployment completed successfully!"