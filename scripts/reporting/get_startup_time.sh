#!/bin/bash
# ============================================================================
# Pod Startup Time Calculator
#
# Calculates the startup time of a Spring Boot pod in milliseconds by:
# 1. Waiting for the pod to be ready
# 2. Parsing application logs for "Started ... in X seconds"
# 3. Fallback: Calculating Container StartedAt vs Ready Condition time
#
# Usage: ./get_startup_time.sh <app-label>
# ============================================================================

APP_LABEL=$1
NAMESPACE="springboot-graalvm"

if [ -z "$APP_LABEL" ]; then
    echo "Usage: $0 <app-label>"
    exit 1
fi

# Wait for pod to be ready (with timeout)
echo "⏳ Waiting for ${APP_LABEL} pod to be ready..."
kubectl wait --for=condition=ready pod -l app=${APP_LABEL} -n ${NAMESPACE} --timeout=60s 2>/dev/null

# Give the pod a moment to flush logs
sleep 5

# Get the most recent pod for the given label
POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_LABEL} --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "0"
    exit 0
fi

# --- Strategy 1: Log Parsing (More Accurate) ---
# Spring Boot logs the exact startup time, e.g., "Started Application in 0.45 seconds"
LOG_LINE=$(kubectl logs -n ${NAMESPACE} ${POD_NAME} 2>/dev/null | grep -i "Started.*Application in")

if [ -n "$LOG_LINE" ]; then
    # Extract seconds (e.g., 0.048) and convert to ms
    STARTUP_SECONDS=$(echo "$LOG_LINE" | grep -oE "[0-9]+\.[0-9]+ seconds" | awk '{print $1}')
    if [ -n "$STARTUP_SECONDS" ]; then
        python3 -c "print(int(float($STARTUP_SECONDS) * 1000))"
        exit 0
    fi
fi

# --- Strategy 2: Container Start Time (Fallback) ---
# Calculate (Ready Timestamp - Container Started Timestamp)
# This is more accurate than pod creation time as it excludes image pull time
CONTAINER_STARTED=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.status.containerStatuses[0].state.running.startedAt}' 2>/dev/null)
READY=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}' 2>/dev/null)

if [ -n "$CONTAINER_STARTED" ] && [ -n "$READY" ]; then
    # Convert timestamps to seconds since epoch (Handles macOS/BSD date vs GNU date)
    STARTED_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CONTAINER_STARTED" "+%s" 2>/dev/null || date -d "$CONTAINER_STARTED" "+%s" 2>/dev/null)
    READY_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$READY" "+%s" 2>/dev/null || date -d "$READY" "+%s" 2>/dev/null)
    
    STARTUP_MS=$(( (READY_SEC - STARTED_SEC) * 1000 ))
    
    # Return 0 if calculation goes negative (clock skew/race condition)
    if [ $STARTUP_MS -lt 0 ]; then
        echo "0"
    else
        echo "$STARTUP_MS"
    fi
    exit 0
fi

# Default if all else fails
echo "0"
