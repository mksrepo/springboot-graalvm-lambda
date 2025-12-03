#!/bin/bash

echo "🚀 Starting AOT and JIT deployment to Kubernetes"

# Run cleanup
chmod +x ./scripts/cleanup.sh
./scripts/cleanup.sh

# Start Monitoring Stack
echo "📊 Starting Prometheus, Grafana, and PostgreSQL in Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/prometheus.yaml

# Create Grafana Dashboard ConfigMap
kubectl create configmap grafana-dashboards \
  --namespace springboot-graalvm \
  --from-file=jvm-micrometer.json=provisioning/dashboards/jvm-micrometer.json \
  --from-file=postgres-dashboard.json=provisioning/dashboards/postgres-dashboard.json \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f k8s/grafana.yaml

# Wait for infrastructure to be ready
echo "⏳ Waiting for infrastructure stack..."
kubectl wait --for=condition=available --timeout=120s deployment/postgres -n springboot-graalvm 2>/dev/null || true
kubectl wait --for=condition=available --timeout=60s deployment/prometheus -n springboot-graalvm 2>/dev/null || true
kubectl wait --for=condition=available --timeout=60s deployment/grafana -n springboot-graalvm 2>/dev/null || true

# Make scripts executable
chmod +x ./scripts/gvm.aot.sh
chmod +x ./scripts/gvm.jit.sh
chmod +x ./scripts/get_startup_time.sh

# Run AOT and JIT deployments sequentially
./scripts/gvm.aot.sh
./scripts/gvm.jit.sh

wait

# Generate performance report
chmod +x ./scripts/generate_report.sh
./scripts/generate_report.sh

echo ""
echo "✅ Both tasks completed!"
echo ""
echo "================================"
echo "📊 Access Points"
echo "================================"
echo "  AOT Application:  http://localhost:30001/api/products"
echo "  JIT Application:  http://localhost:30002/api/products"
echo "  Prometheus:       http://localhost:30003"
echo "  Grafana:          http://localhost:30004 (admin/admin)"
echo ""
echo "================================"
echo "🔍 Useful Commands"
echo "================================"
echo "  View pods:   kubectl get pods -n springboot-graalvm"
echo "  View logs:   kubectl logs -f <pod-name> -n springboot-graalvm"
echo "  Cleanup:     ./scripts/cleanup.sh"
echo "  Report:      cat report/aot_vs_jit.md"
echo "================================"
