#!/bin/bash

echo "🧹 Cleaning up application deployments only..."

# Delete only AOT and JIT deployments (keep infrastructure)
kubectl delete -f kubernetes/apps/deployment-aot.yaml --ignore-not-found=true
kubectl delete -f kubernetes/apps/deployment-jit.yaml --ignore-not-found=true

echo "✅ Application cleanup complete! (Infrastructure preserved)"
echo "ℹ️  Prometheus, Grafana, and PostgreSQL are still running"
echo "💡 For full cleanup, use: ./kubernetes/cleanup-full.sh"
