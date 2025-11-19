#!/bin/bash
set -e

echo "🚀 Building GraalVM Native Docker image..."

docker build \
  -f Dockerfile_AOT \
  -t springboot-graalvm-jit:latest \
  .

echo "✔️ Build complete!"
echo "Run with:"
echo "docker run -p 8090:8080 springboot-graalvm-jit:latest"