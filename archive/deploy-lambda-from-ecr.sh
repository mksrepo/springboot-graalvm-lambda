#!/bin/bash

### CONFIG ###
AWS_REGION="ap-south-1"
FUNCTION_NAME="graalvm-lambda-native"
REPO_NAME="springboot-graalvm-lambda"
IMAGE_TAG="latest"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

echo "🚀 Deploying Lambda: ${FUNCTION_NAME}"
echo "Using Image: ${IMAGE_URI}"

### Check if Lambda exists ###
aws lambda get-function --function-name "${FUNCTION_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "📌 Lambda does NOT exist — creating function..."

  aws lambda create-function \
    --region "${AWS_REGION}" \
    --function-name "${FUNCTION_NAME}" \
    --package-type Image \
    --code ImageUri="${IMAGE_URI}" \
    --role "arn:aws:iam::${AWS_ACCOUNT_ID}:role/lambda-execution-role"

  echo "✔️ Lambda created successfully."

else
  echo "♻️ Lambda exists — updating function image..."

  aws lambda update-function-code \
    --region "${AWS_REGION}" \
    --function-name "${FUNCTION_NAME}" \
    --image-uri "${IMAGE_URI}"

  echo "✔️ Lambda updated successfully."
fi

echo ""
echo "🎉 Deployment completed successfully!"