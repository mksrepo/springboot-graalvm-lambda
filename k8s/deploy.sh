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

if [[ "$CHAOS_FLAG" == "--chaos" ]]; then
  if [[ "$APP_TYPE" == "jit" ]]; then
    echo "🔥 Enabling Chaos Monkey profile for JIT..."
    # Use sed to replace production with chaos and enable CHAOS_MONKEY_ENABLED
    # We replace 'value: "production"' with 'value: "chaos"'
    # And 'value: "false"' with 'value: "true"' specifically for CHAOS_MONKEY_ENABLED
    sed -e 's/value: "production"/value: "chaos"/' \
        -e '/name: CHAOS_MONKEY_ENABLED/{n;s/value: "false"/value: "true"/;}' \
        "$DEPLOYMENT_FILE" | kubectl apply -f -
  else
    echo "🛡️ Keeping AOT in production mode (Chaos Monkey disabled for AOT)..."
    kubectl apply -f "$DEPLOYMENT_FILE"
  fi
else
  echo "Deploying with default (production) profile..."
  kubectl apply -f "$DEPLOYMENT_FILE"
fi

echo "Deployment triggered."
