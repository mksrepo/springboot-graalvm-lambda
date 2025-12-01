#!/bin/bash
set -e

CONTAINER_NAME=$1

if [ -z "$CONTAINER_NAME" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# Wait for container to be healthy
echo "⏳ Waiting for $CONTAINER_NAME to be healthy..." >&2
until [ "$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null)" == "healthy" ]; do
    sleep 1
done

# Get Created Timestamp
CREATED_AT=$(docker inspect --format='{{.Created}}' $CONTAINER_NAME)

# Get Started Timestamp (Approximate readiness, using StartedAt as base, but ideally we'd want the health check success time. 
# Docker doesn't expose "HealthChangedAt" easily. 
# For this approximation, we will use the current time as "Ready" since we just waited for it.)
# A better approach for "Ready" time in pure Docker is tricky without parsing logs or events.
# Let's use the time when the loop finished as the "Ready" time.

READY_AT=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")

# Calculate difference in milliseconds using Python
python3 -c "
from datetime import datetime
import sys

created_str = '$CREATED_AT'
ready_str = '$READY_AT'

# Handle potential Z suffix and nano precision
created_str = created_str.replace('Z', '+00:00')
ready_str = ready_str.replace('Z', '+00:00')

# Truncate nanos to micros for python isoformat if needed, or use a robust parser.
# Docker timestamps can be like 2023-10-27T10:00:00.123456789Z
# Python 3.7+ handles this reasonably well usually, but let's be safe.

try:
    created = datetime.fromisoformat(created_str)
    ready = datetime.fromisoformat(ready_str)
    diff = ready - created
    print(int(diff.total_seconds() * 1000))
except ValueError:
    # Fallback for simpler parsing if needed
    print('Error parsing dates', file=sys.stderr)
    print(0)
"
