#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

APP_TYPE=$1
CHAOS_FLAG=$2

if [[ -z "$APP_TYPE" ]]; then
  echo "Usage: ./deploy.sh [jit|aot] [--chaos]"
  exit 1
fi

DEPLOYMENT_FILE="apps/deployment-${APP_TYPE}.yaml"

if [[ ! -f "$DEPLOYMENT_FILE" ]]; then
  echo "Deployment file $DEPLOYMENT_FILE not found!"
  exit 1
fi

echo "Deploying $APP_TYPE..."
kubectl apply -f "$DEPLOYMENT_FILE"

echo "Deployment triggered."
