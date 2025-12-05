#!/bin/bash
set -e

echo "🛑 Stopping all Chaos Engineering Experiments..."

# Delete all chaos schedules (This prevents new chaos from being created)
echo "   Cleaning up schedules..."
kubectl delete schedule --all -n springboot-graalvm 2>/dev/null || true

# Delete active chaos experiments
echo "   Cleaning up active experiments..."
kubectl delete podchaos --all -n springboot-graalvm 2>/dev/null || true
kubectl delete networkchaos --all -n springboot-graalvm 2>/dev/null || true
kubectl delete stresschaos --all -n springboot-graalvm 2>/dev/null || true

echo ""
echo "✅ All chaos experiments stopped!"
echo ""
echo "================================"
echo "🔍 Verify Cleanup"
echo "================================"
kubectl get schedule,podchaos,networkchaos,stresschaos -n springboot-graalvm
echo ""
echo "Pods should recover to normal state:"
kubectl get pods -n springboot-graalvm
echo "================================"
