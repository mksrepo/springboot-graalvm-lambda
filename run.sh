#!/bin/bash

echo "Starting AOT and JIT tasks in parallel"

# Run cleanup
chmod +x ./sh/cleanup.sh
./sh/cleanup.sh

# Start Monitoring Stack
echo "🚀 Starting Prometheus and Grafana..."
docker compose up -d prometheus grafana

# Copy Grafana Dashboard (workaround for Docker Desktop permission issues)
echo "📊 Configuring Grafana Dashboard..."
sleep 5 # Wait for containers to initialize
docker cp docker/grafana/provisioning/dashboards/jvm-micrometer.json grafana:/etc/grafana/provisioning/dashboards/
docker restart grafana

chmod +x ./sh/gvm.aot.sh
chmod +x ./sh/gvm.jit.sh

./sh/gvm.aot.sh
./sh/gvm.jit.sh

wait

chmod +x ./sh/generate_report.sh
./sh/generate_report.sh

echo "Both tasks completed!"

# su docker login
# chmod +x run.sh
# ./run.sh
