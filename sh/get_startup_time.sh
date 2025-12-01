#!/bin/bash
set -e

LABEL=$1
NAMESPACE=${2:-default}

if [ -z "$LABEL" ]; then
    echo "Usage: $0 <label_selector> [namespace]"
    exit 1
fi

# Wait for the pod to be ready
kubectl wait --for=condition=ready pod -l "$LABEL" -n "$NAMESPACE" --timeout=60s > /dev/null

# Get Pod Name (Newest one)
POD_NAME=$(kubectl get pod -l "$LABEL" -n "$NAMESPACE" --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[-1].metadata.name}")

# Get Creation Timestamp
CREATED_AT=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath="{.metadata.creationTimestamp}")

# Get Ready Condition Timestamp
READY_AT=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}')

# Calculate difference in milliseconds using Python
python3 -c "
from datetime import datetime
import sys

created_str = '$CREATED_AT'
ready_str = '$READY_AT'

# Handle potential Z suffix
created_str = created_str.replace('Z', '+00:00')
ready_str = ready_str.replace('Z', '+00:00')

created = datetime.fromisoformat(created_str)
ready = datetime.fromisoformat(ready_str)

diff = ready - created
print(int(diff.total_seconds() * 1000))
"
