#!/bin/bash

# Deploy Kafka and Zookeeper to Kubernetes

echo "🚀 Deploying Kafka infrastructure..."

# Apply Kafka deployment
kubectl apply -f k8s/kafka/kafka-deployment.yaml

echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka -n springboot-graalvm --timeout=120s

echo "✅ Kafka deployment complete!"
echo ""
echo "📊 Kafka Status:"
kubectl get pods -n springboot-graalvm -l app=kafka
kubectl get pods -n springboot-graalvm -l app=zookeeper
echo ""
echo "🔗 Kafka Service:"
kubectl get svc -n springboot-graalvm kafka
