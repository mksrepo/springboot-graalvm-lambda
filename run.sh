#!/bin/bash
set -e

echo "🚀 Starting AOT and JIT deployment to Kubernetes"

# ============================================================================
# FUNCTION: Install Chaos Mesh
# ============================================================================
install_chaos_mesh() {
    echo ""
    echo "🔧 Installing Chaos Mesh on Kubernetes..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl not found. Please install kubectl first."
        exit 1
    fi
    
    # Check if Helm is available
    if ! command -v helm &> /dev/null; then
        echo "📦 Helm not found. Installing Helm..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    # Add Chaos Mesh Helm repository
    echo "📦 Adding Chaos Mesh Helm repository..."
    helm repo add chaos-mesh https://charts.chaos-mesh.org 2>/dev/null || true
    helm repo update
    
    # Create chaos-mesh namespace
    echo "📁 Creating chaos-mesh namespace..."
    kubectl create namespace chaos-mesh --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Chaos Mesh
    echo "🚀 Installing Chaos Mesh..."
    helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh \
      --namespace=chaos-mesh \
      --version 2.6.3 \
      --set chaosDaemon.runtime=containerd \
      --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
      --set dashboard.create=true \
      --set dashboard.securityMode=false \
      --wait \
      --timeout 5m
    
    # Wait for Chaos Mesh to be ready
    echo "⏳ Waiting for Chaos Mesh components to be ready..."
    kubectl wait --for=condition=Ready pods --all -n chaos-mesh --timeout=300s
    
    echo "✅ Chaos Mesh installed successfully!"
}

# ============================================================================
# FUNCTION: Apply Chaos Experiments
# ============================================================================
apply_chaos_experiments() {
    echo ""
    echo "🔥 Applying Chaos Engineering Experiments..."
    
    # Apply all chaos experiments
    echo "📦 Applying Pod Kill Chaos..."
    kubectl apply -f k8s/chaos/pod-kill.yaml
    
    echo "📦 Applying Network Delay Chaos..."
    kubectl apply -f k8s/chaos/network-delay.yaml
    
    echo "📦 Applying CPU Stress Chaos..."
    kubectl apply -f k8s/chaos/cpu-stress.yaml
    
    echo "📦 Applying Memory Stress Chaos..."
    kubectl apply -f k8s/chaos/memory-stress.yaml
    
    echo "📦 Applying Database Partition Chaos..."
    kubectl apply -f k8s/chaos/database-partition.yaml
    
    echo ""
    echo "✅ All chaos experiments applied!"
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Check for chaos mode
CHAOS_MODE=false
CHAOS_FLAG=""
if [[ "$1" == "--chaos" ]]; then
    CHAOS_MODE=true
    CHAOS_FLAG="--chaos"
    echo "🌪️ Kubernetes Chaos Engineering Mode Enabled!"
else
    echo "✅ Standard Mode (No Chaos)"
fi

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
    
    # Deploy Kafka (Required for Application Audit Logs)
    echo "📦 Deploying Kafka..."
    kubectl apply -f k8s/kafka/kafka-deployment.yaml
    
    # Wait for infrastructure to be ready
    echo "⏳ Waiting for infrastructure stack..."
    kubectl wait --for=condition=available --timeout=120s deployment/postgres -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=120s deployment/kafka -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/prometheus -n springboot-graalvm 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=60s deployment/grafana -n springboot-graalvm 2>/dev/null || true
else
    echo "⚡ Skipping infrastructure setup (already running)"
fi

# Install Chaos Mesh if chaos mode is enabled
if [ "$CHAOS_MODE" = true ]; then
    if ! kubectl get namespace chaos-mesh &> /dev/null; then
        install_chaos_mesh
    else
        echo "✅ Chaos Mesh already installed"
    fi
fi

# Make scripts executable
chmod +x ./scripts/build/gvm.aot.sh
chmod +x ./scripts/build/gvm.jit.sh
chmod +x ./scripts/reporting/get_startup_time.sh
chmod +x ./k8s/deploy.sh

# Docker login once before parallel builds (avoids TTY issues)
echo "🔐 Logging into Docker Hub..."
docker login

# Run AOT and JIT deployments sequentially to avoid database contention
echo ""
echo "🚀 Starting sequential builds to avoid database contention..."

echo "  ⚡ Building and testing AOT first..."
./scripts/build/gvm.aot.sh
AOT_EXIT=$?

echo "  ⚡ Building and testing JIT second..."
./scripts/build/gvm.jit.sh
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

# Apply Kubernetes-level chaos if requested
if [ "$CHAOS_MODE" = true ]; then
    echo ""
    echo "🧹 Cleaning up any stuck chaos experiments..."
    # Delete any existing pod chaos experiments that might be stuck
    kubectl delete podchaos -n springboot-graalvm -l managed-by=pod-kill-schedule --ignore-not-found=true
    kubectl delete podchaos -n springboot-graalvm -l managed-by=pod-kill-schedule-jit --ignore-not-found=true
    
    echo "⏳ Waiting 5 seconds for cleanup to complete..."
    sleep 5
    
    apply_chaos_experiments
    echo ""
    echo "🔥 Chaos experiments are now active!"
    echo "   Monitor at: http://localhost:2333"
    echo "   Port-forward: kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333"
fi

# Generate performance report
chmod +x ./scripts/reporting/generate_report.sh
./scripts/reporting/generate_report.sh

echo ""
echo "✅ Deployment completed!"
echo ""
echo "================================"
echo "📊 Access Points"
echo "================================"
echo "  AOT Application:  http://localhost:30001/api/products"
echo "  JIT Application:  http://localhost:30002/api/products"
echo "  Prometheus:       http://localhost:30003"
echo "  Grafana:          http://localhost:30004 (admin/admin)"

if [ "$CHAOS_MODE" = true ]; then
    echo "  Chaos Dashboard:  http://localhost:2333 (port-forward required)"
fi

echo ""
echo "================================"
echo "🔍 Useful Commands"
echo "================================"
echo "  View pods:   kubectl get pods -n springboot-graalvm"
echo "  View logs:   kubectl logs -f <pod-name> -n springboot-graalvm"
echo "  Cleanup:     ./k8s/cleanup.sh"
echo "  Report:      cat report/aot_vs_jit.md"

if [ "$CHAOS_MODE" = true ]; then
    echo ""
    echo "================================"
    echo "🌪️ Chaos Engineering Commands"
    echo "================================"
    echo "  View chaos:  kubectl get podchaos,networkchaos,stresschaos -n springboot-graalvm"
    echo "  Stop chaos:  ./k8s/chaos/stop-chaos.sh"
    echo "  Dashboard:   kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333"
fi

echo "================================"
