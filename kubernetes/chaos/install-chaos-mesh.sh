#!/bin/bash
set -e

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
