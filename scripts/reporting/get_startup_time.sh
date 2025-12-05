#!/bin/bash

# Get pod startup time in milliseconds
# Usage: ./get_startup_time.sh <app-label>

APP_LABEL=$1
NAMESPACE="springboot-graalvm"

# Get the most recent pod
POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_LABEL} --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "0"
    exit 0
fi

# Helper function to get startup time from logs
get_log_startup_time() {
    local pod=$1
    # Try to find the standard Spring Boot startup log line
    # Matches: "Started SpringbootGraalvmLambdaApplication in 0.048 seconds"
    local log_line=$(kubectl logs -n ${NAMESPACE} ${pod} 2>/dev/null | grep "Started SpringbootGraalvmLambdaApplication")
    
    if [ -n "$log_line" ]; then
        # Extract the seconds value (e.g. 0.048)
        local seconds=$(echo "$log_line" | grep -o "[0-9]*\.[0-9]* seconds" | awk '{print $1}')
        if [ -n "$seconds" ]; then
            # Convert to milliseconds (remove decimal point, handle leading zeros)
            # Python is reliable for floating point arithmetic here
            python3 -c "print(int(float($seconds) * 1000))"
            return 0
        fi
    fi
    return 1
}

# 1. Try to get real startup time from application logs
LOG_STARTUP_MS=$(get_log_startup_time "$POD_NAME")
if [ $? -eq 0 ]; then
    echo "$LOG_STARTUP_MS"
    exit 0
fi

# 2. Fallback: Get pod creation time and container ready time (Kubernetes "Ready" time)
CREATED=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.metadata.creationTimestamp}')
READY=$(kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}')

if [ -z "$CREATED" ] || [ -z "$READY" ]; then
    echo "0"
    exit 0
fi

# Convert to seconds since epoch
CREATED_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED" "+%s" 2>/dev/null || date -d "$CREATED" "+%s" 2>/dev/null)
READY_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$READY" "+%s" 2>/dev/null || date -d "$READY" "+%s" 2>/dev/null)

# Calculate difference in milliseconds
STARTUP_MS=$(( (READY_SEC - CREATED_SEC) * 1000 ))

# Ensure positive value
if [ $STARTUP_MS -lt 0 ]; then
    STARTUP_MS=0
fi

echo $STARTUP_MS
