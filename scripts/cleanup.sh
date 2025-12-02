#!/bin/bash

echo "🧹 Cleaning up Kubernetes resources..."

# Delete all resources in the namespace
kubectl delete namespace springboot-graalvm --ignore-not-found=true

# Wait for namespace to be deleted
echo "⏳ Waiting for namespace deletion..."
kubectl wait --for=delete namespace/springboot-graalvm --timeout=60s 2>/dev/null || true

echo "✅ Cleanup complete!"
