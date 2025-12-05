#!/bin/bash
# ============================================================================
# Pod Startup Time Calculator
#
# Calculates the startup time of a Spring Boot pod in milliseconds by:
# 1. Parsing application logs for "Started ... in X seconds"
# 2. Fallback: Calculating formatted CreationTimestamp vs Ready Condition time
#
# Usage: ./get_startup_time.sh <app-label>
# ============================================================================

APP_LABEL=$1
NAMESPACE="springboot-graalvm"

if [ -z "$APP_LABEL" ]; then
    echo "Usage: $0 <app-label>"
    exit 1
fi

# Get the most recent pod for the given label
POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_LABEL} --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "0"
    exit 0
fi

# --- Strategy 1: Log Parsing (More Accurate) ---
# Spring Boot logs the exact startup time, e.g., "Started Application in 0.45 seconds"
LOG_LINE=$(kubectl logs -n ${NAMESPACE} ${POD_NAME} 2>/dev/null | grep "Started SpringbootGraalvmLambdaApplication")

if [ -n "$LOG_LINE" ]; then
    # Extract seconds (e.g., 0.048) and convert to ms
    SECONDS=$(echo "$LOG_LINE" | grep -o "[0-9]*\.[0-9]* seconds" | awk '{print $1}')
    if [ -n "$SECONDS" ]; then
        python3 -c "print(int(float($SECONDS) * 1000))"
        exit 0
    fi
fi

# --- Strategy 2: K8s Events (Fallback) ---
# Calculates (Ready Timestamp - Creation Timestamp)
CREATED=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.metadata.creationTimestamp}')
READY=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}')

if [ -n "$CREATED" ] && [ -n "$READY" ]; then
    # Convert timestamps to seconds since epoch (Handles macOS/BSD date vs GNU date)
    CREATED_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED" "+%s" 2>/dev/null || date -d "$CREATED" "+%s" 2>/dev/null)
    READY_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$READY" "+%s" 2>/dev/null || date -d "$READY" "+%s" 2>/dev/null)
    
    STARTUP_MS=$(( (READY_SEC - CREATED_SEC) * 1000 ))
    
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
