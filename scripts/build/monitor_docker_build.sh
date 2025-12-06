#!/bin/bash
# ============================================================================
# Docker Build Monitor - Real-time build progress viewer
# ============================================================================
# Usage: ./monitor_docker_build.sh <dockerfile> <image-tag>
#
# This script monitors a Docker build in real-time and provides detailed
# progress updates including timestamps, phase detection, and resource usage.

DOCKERFILE=$1
IMAGE=$2

if [ -z "$DOCKERFILE" ] || [ -z "$IMAGE" ]; then
    echo "Usage: $0 <dockerfile> <image-tag>"
    exit 1
fi

BUILD_START=$(date +%s)
LAST_HEARTBEAT=$(date +%s)
COMPILATION_PHASE=false

echo "📊 Starting monitored Docker build..."
echo "   Dockerfile: $DOCKERFILE"
echo "   Image: $IMAGE"
echo "   Started: $(date '+%H:%M:%S')"
echo ""

# Function to show elapsed time
show_elapsed() {
    local current=$(date +%s)
    local elapsed=$((current - BUILD_START))
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))
    printf "%02d:%02d" $mins $secs
}

# Function to show timestamp
timestamp() {
    date '+%H:%M:%S'
}

# Run docker build with full output capture and intelligent filtering
docker build --progress=plain -f "$DOCKERFILE" -t "$IMAGE" . 2>&1 | while IFS= read -r line; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - BUILD_START))
    
    # Always show important Maven/GraalVM phases
    if echo "$line" | grep -qE "Downloading from|Downloaded from"; then
        # Summarize dependency downloads
        if [[ "$line" =~ Downloaded.*from.*(.*KB|.*MB) ]]; then
            SIZE=$(echo "$line" | grep -oE '[0-9]+\s*(KB|MB|GB)' | head -1)
            echo "[$(timestamp)] [$(show_elapsed)] ⬇️  Downloaded: $SIZE"
        fi
        
    elif echo "$line" | grep -qE "\[INFO\] Building|Building jar"; then
        echo "[$(timestamp)] [$(show_elapsed)] 🔨 $(echo "$line" | sed 's/.*\[INFO\] //')"
        
    elif echo "$line" | grep -qE "native:compile|native-image|GraalVM Native Image"; then
        if [ "$COMPILATION_PHASE" = false ]; then
            echo ""
            echo "[$(timestamp)] [$(show_elapsed)] ⚙️  ═══ GRAALVM NATIVE COMPILATION STARTED ═══"
            echo "[$(timestamp)] [$(show_elapsed)] 💡 This phase takes 3-8 minutes on average"
            echo ""
            COMPILATION_PHASE=true
        fi
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Performing analysis|analysis.*ms"; then
        echo "[$(timestamp)] [$(show_elapsed)] 🔍 Phase: Analyzing application reachability..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Building universe|universe.*ms"; then
        echo "[$(timestamp)] [$(show_elapsed)] 🌌 Phase: Building object universe..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Parsing methods|parsing.*methods"; then
        echo "[$(timestamp)] [$(show_elapsed)] 📝 Phase: Parsing bytecode methods..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Inlining methods|inlining.*ms"; then
        echo "[$(timestamp)] [$(show_elapsed)] 🔄 Phase: Optimizing (inlining methods)..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Compiling methods|compilation.*ms"; then
        echo "[$(timestamp)] [$(show_elapsed)] ⚡ Phase: Compiling to native code..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qiE "Creating image|Producing image|image.*ms"; then
        echo "[$(timestamp)] [$(show_elapsed)] 🖼️  Phase: Creating native executable image..."
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qE "Finished generating|BUILD SUCCESS"; then
        echo ""
        echo "[$(timestamp)] [$(show_elapsed)] ✅ ═══ COMPILATION COMPLETED SUCCESSFULLY ═══"
        echo ""
        COMPILATION_PHASE=false
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qE "Total time:"; then
        MAVEN_TIME=$(echo "$line" | grep -oE '[0-9]+(\.[0-9]+)?\s*(s|min)' | head -1)
        echo "[$(timestamp)] [$(show_elapsed)] ⏱️  Maven build time: $MAVEN_TIME"
        LAST_HEARTBEAT=$CURRENT_TIME
        
    elif echo "$line" | grep -qE "ERROR|FAILED|Exception"; then
        echo "[$(timestamp)] [$(show_elapsed)] ❌ ERROR: $line"
        
    elif echo "$line" | grep -qE "WARNING|WARN"; then
        echo "[$(timestamp)] [$(show_elapsed)] ⚠️  WARN: $(echo "$line" | sed 's/.*WARNING//' | sed 's/.*WARN//')"
    fi
    
    # Heartbeat: Show we're alive every 45 seconds during compilation
    if [ "$COMPILATION_PHASE" = true ] && [ $((CURRENT_TIME - LAST_HEARTBEAT)) -gt 45 ]; then
        echo "[$(timestamp)] [$(show_elapsed)] 💓 Compilation in progress... ($(show_elapsed) elapsed)"
        LAST_HEARTBEAT=$CURRENT_TIME
    fi
done

BUILD_END=$(date +%s)
TOTAL_TIME=$((BUILD_END - BUILD_START))
echo ""
echo "═══════════════════════════════════════════════════"
echo "Build completed in: $(show_elapsed)"
echo "Finished at: $(date '+%H:%M:%S')"
echo "═══════════════════════════════════════════════════"

exit ${PIPESTATUS[0]}
