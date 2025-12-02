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

# Get pod creation time and container ready time
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
