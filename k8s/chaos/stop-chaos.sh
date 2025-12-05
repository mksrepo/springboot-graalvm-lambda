#!/bin/bash
set -e

echo "🛑 Stopping all Chaos Engineering Experiments..."

# Delete all chaos experiments
kubectl delete podchaos --all -n springboot-graalvm 2>/dev/null || true
kubectl delete networkchaos --all -n springboot-graalvm 2>/dev/null || true
kubectl delete stresschaos --all -n springboot-graalvm 2>/dev/null || true

echo ""
echo "✅ All chaos experiments stopped!"
echo ""
echo "================================"
echo "🔍 Verify Cleanup"
echo "================================"
kubectl get podchaos,networkchaos,stresschaos -n springboot-graalvm
echo ""
echo "Pods should recover to normal state:"
kubectl get pods -n springboot-graalvm
echo "================================"
