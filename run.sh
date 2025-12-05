#!/bin/bash
set -e

# ============================================================================
# GraalVM Spring Boot Lambda - Deployment Orchestrator
#
# This script orchestrates the end-to-end deployment lifecycle:
# 1. Infrastructure Setup (PostgreSQL, Kafka, Prometheus, Grafana)
# 2. Chaos Mesh Installation (optional via --chaos)
# 3. Application Build & Test (AOT and JIT sequentially)
# 4. Performance Reporting
# ============================================================================

echo "🚀 Starting Deployment Orchestrator..."

# --- Function: Apply Chaos Experiments ---
apply_chaos_experiments() {
    echo "🔥 Applying Chaos Engineering Experiments..."
    
    # Apply resiliency tests
    kubectl apply -f kubernetes/chaos/pod-kill.yaml
    kubectl apply -f kubernetes/chaos/network-delay.yaml
    kubectl apply -f kubernetes/chaos/cpu-stress.yaml
    kubectl apply -f kubernetes/chaos/memory-stress.yaml
    kubectl apply -f kubernetes/chaos/database-partition.yaml
    
    echo "✅ Chaos experiments scheduled successfully."
}

# --- 1. Parse Arguments ---
CHAOS_MODE=false
if [[ "$1" == "--chaos" ]]; then
    CHAOS_MODE=true
    echo "🌪️ Chaos Mode: ENABLED"
else
    echo "✅ Chaos Mode: DISABLED"
fi

# --- 2. Infrastructure Check ---
# Checks if the namespace exists to determine if full setup is needed
INFRA_EXISTS=$(kubectl get namespace springboot-graalvm 2>/dev/null)

if [ -z "$INFRA_EXISTS" ]; then
    echo "📦 New environment detected. Starting full setup..."
    SETUP_INFRA=true
else
    echo "✅ Environment exists. Skipping infra setup."
    SETUP_INFRA=false
fi

# --- 3. Cleanup Previous Deployments ---
# Always clean up application pods to ensure fresh deployment
chmod +x ./kubernetes/cleanup.sh
./kubernetes/cleanup.sh

# --- 4. Infrastructure Provisioning ---
if [ "$SETUP_INFRA" = true ]; then
    echo "🛠️ Provisioning infrastructure resources..."
    
    # Base Namespace & Database
    kubectl apply -f kubernetes/infra/namespace.yaml
    kubectl apply -f kubernetes/infra/database/postgres.yaml
    
    # Monitoring Stack (Prometheus & Grafana)
    kubectl apply -f kubernetes/infra/monitoring/prometheus.yaml
    
    # Grafana Dashboard Injection
    kubectl create configmap grafana-dashboards \
      --namespace springboot-graalvm \
      --from-file=jvm-micrometer.json=kubernetes/infra/monitoring/provisioning/dashboards/jvm-micrometer.json \
      --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl apply -f kubernetes/infra/monitoring/grafana.yaml
    
    # Event Streaming (Kafka)
    kubectl apply -f kubernetes/kafka/kafka-deployment.yaml
    
    # Wait for completion
    echo "hourglass_flowing_sand Waiting for services to stabilize..."
    # Suppress output unless error
    kubectl wait --for=condition=available --timeout=120s deployment/postgres -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=120s deployment/kafka -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/prometheus -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/grafana -n springboot-graalvm 2>/dev/null || true
fi

# --- 5. Chaos Mesh Setup (Conditional) ---
if [ "$CHAOS_MODE" = true ]; then
    if ! kubectl get namespace chaos-mesh &> /dev/null; then
        ./kubernetes/chaos/install-chaos-mesh.sh
    fi
fi

# --- 6. Execution Permissions ---
chmod +x ./scripts/build/gvm.aot.sh
chmod +x ./scripts/build/gvm.jit.sh
chmod +x ./scripts/reporting/get_startup_time.sh
chmod +x ./kubernetes/deploy.sh
chmod +x ./scripts/reporting/generate_report.sh

# --- 7. Docker Authentication ---
# Required for pushing images to registry
docker login

# --- 8. Build & Deploy (Sequential) ---
# Running sequentially prevents resource contention on local docker daemon/DB
echo "🏗️ Starting sequential build pipeline..."

echo "⚡ [1/2] Processing AOT Build..."
./scripts/build/gvm.aot.sh
AOT_EXIT=$?

echo "⚡ [2/2] Processing JIT Build..."
./scripts/build/gvm.jit.sh
JIT_EXIT=$?

# Validate Build Status
if [ $AOT_EXIT -ne 0 ]; then
    echo "❌ AOT build failed ($AOT_EXIT). Aborting."
    exit 1
fi

if [ $JIT_EXIT -ne 0 ]; then
    echo "❌ JIT build failed ($JIT_EXIT). Aborting."
    exit 1
fi

echo "✅ Build pipeline completed successfully."

# --- 9. Activate Chaos Experiments (Conditional) ---
if [ "$CHAOS_MODE" = true ]; then
    echo "🧹 Resetting chaos state..."
    kubectl delete podchaos,networkchaos,stresschaos -n springboot-graalvm --all --ignore-not-found=true
    
    sleep 5
    apply_chaos_experiments
fi

# --- 10. Generate Report ---
./scripts/reporting/generate_report.sh

# --- 11. Summary & Access Points ---
echo ""
echo "=================================================="
echo "🎉 Deployment Complete"
echo "=================================================="
echo "📊 Dashboard Access:"
echo "  • AOT API:         http://localhost:30001/api/products"
echo "  • JIT API:         http://localhost:30002/api/products"
echo "  • Prometheus:      http://localhost:30003"
echo "  • Grafana:         http://localhost:30004 (admin/admin)"
if [ "$CHAOS_MODE" = true ]; then
echo "  • Chaos Dashboard: http://localhost:2333"
fi
echo ""
echo "📝 Report: cat report/aot_vs_jit.md"
echo "=================================================="
