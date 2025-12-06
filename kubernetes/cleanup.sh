#!/usr/bin/env bash
set -euo pipefail

# Simple cleanup script
# Usage:
#   ./cleanup.sh          # Clean up only AOT & JIT deployments (keep infra)
#   ./cleanup.sh --full   # Delete the entire namespace (full cleanup)

NAMESPACE="springboot-graalvm"
APP_DEPLOYMENTS=("kubernetes/apps/deployment-aot.yaml" "kubernetes/apps/deployment-jit.yaml")

if [[ "$#" -gt 0 && "$1" == "--full" ]]; then
  echo "🧹 Full cleanup: Removing all Kubernetes resources in namespace $NAMESPACE..."
  kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
  echo "⏳ Waiting for namespace deletion..."
  kubectl wait --for=delete namespace/$NAMESPACE --timeout=60s 2>/dev/null || true
  echo "✅ Full cleanup complete!"
  echo "⚠️  All infrastructure (Prometheus, Grafana, PostgreSQL, Kafka) has been removed"
else
  echo "🧹 Cleaning up application deployments only..."
  for dep in "${APP_DEPLOYMENTS[@]}"; do
    if [[ -f $dep ]]; then
      kubectl delete -f "$dep" --ignore-not-found=true
    fi
  done
  echo "✅ Application cleanup complete! (Infrastructure preserved)"
  echo "ℹ️  Prometheus, Grafana, and PostgreSQL are still running"
  echo "💡 For full cleanup, run: ./cleanup.sh --full"
fi
