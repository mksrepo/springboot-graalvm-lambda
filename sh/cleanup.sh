#!/bin/bash

echo "🧹 Cleaning up previous deployments..."

# 1. Clean up Kubernetes resources if present (to avoid port conflicts)
if command -v kubectl &> /dev/null; then
    echo "   - Checking for lingering Kubernetes resources..."
    kubectl delete deployment --all --ignore-not-found=true &> /dev/null
    kubectl delete service --all --ignore-not-found=true &> /dev/null
fi

# 2. Clean up Docker Compose containers
echo "   - Stopping existing Docker Compose containers..."
docker compose down --remove-orphans &> /dev/null

echo "✅ Cleanup complete."
