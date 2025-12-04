#!/bin/bash

echo "🚀 Starting AOT and JIT deployment to Kubernetes"

# Check if infrastructure already exists
INFRA_EXISTS=$(kubectl get namespace springboot-graalvm 2>/dev/null)

if [ -z "$INFRA_EXISTS" ]; then
    echo "📦 First run detected - setting up infrastructure..."
    SETUP_INFRA=true
else
    echo "✅ Infrastructure already exists - skipping setup for faster deployment"
    echo "💡 To force full cleanup, run: ./k8s/cleanup-full.sh"
    SETUP_INFRA=false
fi

# Clean up existing app deployments (fast, preserves infrastructure)
chmod +x ./k8s/cleanup.sh
./k8s/cleanup.sh

# Setup infrastructure only if needed
if [ "$SETUP_INFRA" = true ]; then
    echo "📊 Setting up Prometheus, Grafana, and PostgreSQL..."
    kubectl apply -f k8s/infra/namespace.yaml
    kubectl apply -f k8s/infra/database/postgres.yaml
    kubectl apply -f k8s/infra/monitoring/prometheus.yaml
    
    # Create Grafana Dashboard ConfigMap
    kubectl create configmap grafana-dashboards \
      --namespace springboot-graalvm \
      --from-file=jvm-micrometer.json=k8s/infra/monitoring/provisioning/dashboards/jvm-micrometer.json \
      --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl apply -f k8s/infra/monitoring/grafana.yaml
    
    # Wait for infrastructure to be ready
    echo "⏳ Waiting for infrastructure stack..."
    kubectl wait --for=condition=available --timeout=120s deployment/postgres -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/prometheus -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/grafana -n springboot-graalvm 2>/dev/null || true
else
    echo "⚡ Skipping infrastructure setup (already running)"
fi

# Make scripts executable
chmod +x ./scripts/build/gvm.aot.sh
chmod +x ./scripts/build/gvm.jit.sh
chmod +x ./scripts/reporting/get_startup_time.sh

# Docker login once before parallel builds (avoids TTY issues)
echo "🔐 Logging into Docker Hub..."
docker login

# Run AOT and JIT deployments sequentially to avoid database contention
echo ""
echo "🚀 Starting sequential builds to avoid database contention..."

# Ensure deploy script is executable
chmod +x ./k8s/deploy.sh

CHAOS_FLAG=""
if [[ "$1" == "--chaos" ]]; then
    CHAOS_FLAG="--chaos"
    echo "🔥 Chaos Monkey Mode Enabled! (AOT & JIT)"
else
    echo "✅ Standard Mode Enabled (No Chaos)"
fi

echo "  ⚡ Building and testing AOT first..."
./scripts/build/gvm.aot.sh $CHAOS_FLAG
AOT_EXIT=$?

echo "  ⚡ Building and testing JIT second..."
./scripts/build/gvm.jit.sh $CHAOS_FLAG
JIT_EXIT=$?

# Check if both builds succeeded
if [ $AOT_EXIT -ne 0 ]; then
    echo "❌ AOT build failed with exit code $AOT_EXIT"
    exit 1
fi

if [ $JIT_EXIT -ne 0 ]; then
    echo "❌ JIT build failed with exit code $JIT_EXIT"
    exit 1
fi

echo "✅ Both AOT and JIT builds completed successfully!"

# Generate performance report
chmod +x ./scripts/reporting/generate_report.sh
./scripts/reporting/generate_report.sh

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
echo "  Cleanup:     ./k8s/cleanup.sh"
echo "  Report:      cat report/aot_vs_jit.md"
echo "================================"
