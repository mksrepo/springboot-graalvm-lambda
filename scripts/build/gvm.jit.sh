#!/bin/bash
set -e

# ============================================================================
# Build Pipeline: Standard JVM (JIT)
# ============================================================================

# --- Configurations ---
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-jit"
TAG="v2.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"
DOCKERFILE="./dockerfiles/jit.dockerfile"
NAMESPACE="springboot-graalvm"
APP_LABEL="springboot-graalvm-jit"

echo "🚀 [JIT] Starting Build Pipeline..."

# --- 1. Docker Build ---
echo "🏗️  [1/4] Building Docker Image..."
BUILD_START=$(date +%s)
docker build -q -f ${DOCKERFILE} -t ${IMAGE} . > /dev/null
BUILD_END=$(date +%s)

# --- 2. Docker Push ---
echo "📤 [2/4] Pushing to Registry..."
PUSH_START=$(date +%s)
docker push -q ${IMAGE} > /dev/null
PUSH_END=$(date +%s)

# --- 3. Kubernetes Deployment ---
echo "🚀 [3/4] Deploying to Kubernetes..."
DEPLOY_START=$(date +%s)

# Ensure namespace exists
kubectl apply -f kubernetes/infra/namespace.yaml > /dev/null

# Deploy application
./kubernetes/deploy.sh jit

# Wait for readiness
echo "⏳ Waiting for pod readiness..."
kubectl wait --for=condition=available --timeout=120s deployment/${APP_LABEL} -n ${NAMESPACE} > /dev/null

# Calculate timings
DEPLOY_END=$(date +%s)
STARTUP_TIME=$(./scripts/reporting/get_startup_time.sh "${APP_LABEL}")
echo "${STARTUP_TIME}" > ./report/startup_time_jit.txt

# --- 4. Metrics & Reporting ---
echo "📊 Recording CI/CD Metrics..."

BUILD_DURATION=$((BUILD_END - BUILD_START))
PUSH_DURATION=$((PUSH_END - PUSH_START))
DEPLOY_DURATION=$((DEPLOY_END - DEPLOY_START))
IMAGE_SIZE=$(docker images ${IMAGE} --format "{{.Size}}")

# Write report
cat <<EOF > ./report/cicd_report_jit.txt
Docker Build Time:      ${BUILD_DURATION} seconds
Docker Push Time:       ${PUSH_DURATION} seconds
K8s Deployment Time:    ${DEPLOY_DURATION} seconds
Pod Startup Time:       ${STARTUP_TIME} ms
Docker Image Size:      ${IMAGE_SIZE}
EOF

# --- 5. Load Testing ---
echo "🔥 [4/4] Running K6 Load Tests..."
# Specific port 6566 for JIT
k6 run ./load-tests/script.js \
    --quiet \
    --address localhost:6566 \
    --env URL=http://localhost:30002/api/products \
    --env TYPE=jit

echo "✅ [JIT] Pipeline Completed Successfully!"