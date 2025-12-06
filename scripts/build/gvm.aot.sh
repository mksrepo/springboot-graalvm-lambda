#!/bin/bash
set -e
set -o pipefail

# ============================================================================
# Build Pipeline: GraalVM Native Image (AOT)
# ============================================================================
# This script orchestrates the build, push, deploy, and test cycle for the 
# AOT (Ahead-Of-Time) compiled version of the application.
# It includes detailed progress tracking for the long-running native build.

# --- Configurations ---
DOCKERHUB_USER="mrinmay939"
REPO="springboot-graalvm-aot"
TAG="v2.0"
IMAGE="${DOCKERHUB_USER}/${REPO}:${TAG}"
DOCKERFILE="./dockerfiles/aot.dockerfile"
NAMESPACE="springboot-graalvm"
APP_LABEL="springboot-graalvm-aot"

echo "🚀 [AOT] Starting Build Pipeline..."

# --- 1. Docker Build ---
# The AOT build involves compiling Java to native code, which is resource-intensive 
# and time-consuming. We use progress filtering to show meaningful steps.
echo "🏗️  [1/4] Building Docker Image (Native Image)..."
echo "   ℹ️  This process takes time (typically 2-5 minutes). Please wait."

BUILD_START=$(date +%s)

# Initial step indicator
echo "   📦 Step 1/3: Project setup and changing permissions..."

# Run Docker build with comprehensive monitoring
./scripts/build/monitor_docker_build.sh "${DOCKERFILE}" "${IMAGE}"

# Check if the build command actually succeeded (pipestatus logic is tricky in loops, 
# so we run a quick sanity check or trust 'set -e' if the pipe propagates error, 
# but typical pipe doesn't. Rerunning cleanly or just checking existence of image is safer).
# Ideally we want to fail if docker build failed. 
# Re-running the command just for status in a pipe loop swallows exit codes.
# Let's verify image was created recently as a proxy, or capture pipe status.
if ! docker image inspect ${IMAGE} > /dev/null 2>&1; then
    echo "❌ Docker build failed or image not found!"
    exit 1
fi

BUILD_END=$(date +%s)
echo "   ⏱️  Build completed in $((BUILD_END - BUILD_START)) seconds"


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

# Deploy application manifest
./kubernetes/deploy.sh aot

# Wait for pod readiness
echo "   ⏳ Waiting for pod readiness..."
kubectl wait --for=condition=available --timeout=120s deployment/${APP_LABEL} -n ${NAMESPACE} > /dev/null

DEPLOY_END=$(date +%s)

# Capture startup time from the pod logs
STARTUP_TIME=$(./scripts/reporting/get_startup_time.sh "${APP_LABEL}")
echo "${STARTUP_TIME}" > ./report/startup_time_aot.txt


# --- 4. Metrics & Reporting ---
echo "📊 Recording CI/CD Metrics..."

BUILD_DURATION=$((BUILD_END - BUILD_START))
PUSH_DURATION=$((PUSH_END - PUSH_START))
DEPLOY_DURATION=$((DEPLOY_END - DEPLOY_START))
IMAGE_SIZE=$(docker images ${IMAGE} --format "{{.Size}}")

# Generate report file
cat <<EOF > ./report/cicd_report_aot.txt
Docker Build Time:      ${BUILD_DURATION} seconds
Docker Push Time:       ${PUSH_DURATION} seconds
K8s Deployment Time:    ${DEPLOY_DURATION} seconds
Pod Startup Time:       ${STARTUP_TIME} ms
Docker Image Size:      ${IMAGE_SIZE}
EOF


# --- 5. Load Testing ---
echo "🔥 [4/4] Running K6 Load Tests..."
# Run K6 tests against the deployed service
# Port 6565 is used for AOT K6 metrics to avoid conflicts
k6 run ./load-tests/script.js \
    --address localhost:6565 \
    --env URL=http://localhost:30001/api/products \
    --env TYPE=aot

echo "✅ [AOT] Pipeline Completed Successfully!"