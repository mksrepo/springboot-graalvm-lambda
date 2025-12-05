# 🌪️ Kubernetes-Level Chaos Engineering with Chaos Mesh

This directory contains Kubernetes-native chaos engineering experiments using **Chaos Mesh** to test the resilience of both AOT and JIT deployments.

## 🎯 Why Kubernetes-Level Chaos?

### **Advantages over Application-Level Chaos (Chaos Monkey):**

| Aspect | Application-Level | Kubernetes-Level |
|--------|------------------|------------------|
| **AOT Compatibility** | ❌ Doesn't work with GraalVM | ✅ Works with any container |
| **Technology Independence** | ❌ Requires framework support | ✅ Language/framework agnostic |
| **Realistic Scenarios** | ⚠️ Simulated failures | ✅ Real infrastructure failures |
| **Scope** | 🔹 Single application | 🔹 Entire cluster |
| **Production Ready** | ⚠️ May impact app stability | ✅ Isolated, controlled chaos |

## 📦 Installation

### 1. Install Chaos Mesh
```bash
chmod +x k8s/chaos/install-chaos-mesh.sh
./k8s/chaos/install-chaos-mesh.sh
```

This will:
- Install Helm (if not present)
- Add Chaos Mesh Helm repository
- Deploy Chaos Mesh to your cluster
- Create the Chaos Mesh dashboard

### 2. Verify Installation
```bash
kubectl get pods -n chaos-mesh
```

Expected output:
```
NAME                                        READY   STATUS    RESTARTS   AGE
chaos-controller-manager-xxx                1/1     Running   0          1m
chaos-daemon-xxx                            1/1     Running   0          1m
chaos-dashboard-xxx                         1/1     Running   0          1m
```

## 🔥 Available Chaos Experiments

### 1. **Pod Kill Chaos** (`pod-kill.yaml`)
Randomly kills pods to test recovery and restart behavior.

**What it tests:**
- Pod restart time
- Application resilience
- Kubernetes self-healing
- Load balancer behavior

**Schedule:** Every 2 minutes, kills one pod for 30 seconds

### 2. **Network Delay Chaos** (`network-delay.yaml`)
Injects network latency to simulate slow networks.

**What it tests:**
- Timeout handling
- Response time degradation
- Connection pool behavior
- User experience under latency

**Schedule:** Every 3 minutes, adds 500ms ± 100ms latency for 1 minute

### 3. **CPU Stress Chaos** (`cpu-stress.yaml`)
Stresses CPU to test performance under high load.

**What it tests:**
- CPU efficiency (AOT vs JIT)
- Response time under load
- Resource limits enforcement
- Throttling behavior

**Schedule:** Every 4 minutes, 80% CPU load for 45 seconds

### 4. **Memory Stress Chaos** (`memory-stress.yaml`)
Consumes memory to test memory pressure scenarios.

**What it tests:**
- Memory efficiency (AOT vs JIT)
- OOM killer behavior
- Garbage collection impact
- Memory leak detection

**Schedule:** Every 5 minutes, allocates 256MB for 30 seconds

### 5. **Database Partition Chaos** (`database-partition.yaml`)
Simulates network partition between app and database.

**What it tests:**
- Database connection handling
- Connection pool recovery
- Error handling
- Retry mechanisms

**Schedule:** Every 6 minutes, partitions database for 20 seconds

## 🚀 Running Chaos Experiments

### Apply All Experiments
```bash
chmod +x k8s/chaos/apply-chaos.sh
./k8s/chaos/apply-chaos.sh
```

### Apply Individual Experiments
```bash
kubectl apply -f k8s/chaos/pod-kill.yaml
kubectl apply -f k8s/chaos/network-delay.yaml
kubectl apply -f k8s/chaos/cpu-stress.yaml
kubectl apply -f k8s/chaos/memory-stress.yaml
kubectl apply -f k8s/chaos/database-partition.yaml
```

### Stop All Experiments
```bash
chmod +x k8s/chaos/stop-chaos.sh
./k8s/chaos/stop-chaos.sh
```

## 📊 Monitoring Chaos

### 1. **Chaos Mesh Dashboard** (Recommended)
```bash
# Port forward in a separate terminal
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333

# Open in browser
open http://localhost:2333
```

The dashboard shows:
- Active experiments
- Experiment history
- Real-time chaos events
- Visual timeline

### 2. **Command Line Monitoring**

**View all experiments:**
```bash
kubectl get podchaos,networkchaos,stresschaos -n springboot-graalvm
```

**Watch pod restarts:**
```bash
kubectl get pods -n springboot-graalvm -w
```

**View experiment details:**
```bash
kubectl describe podchaos pod-kill-chaos -n springboot-graalvm
```

**Check application logs during chaos:**
```bash
kubectl logs -f -l app=springboot-graalvm-aot -n springboot-graalvm
kubectl logs -f -l app=springboot-graalvm-jit -n springboot-graalvm
```

### 3. **Prometheus & Grafana**

Monitor metrics during chaos:
```bash
# Prometheus
open http://localhost:30003

# Grafana
open http://localhost:30004
```

Key metrics to watch:
- `http_server_requests_seconds_count` - Request rate
- `http_server_requests_seconds_sum` - Response time
- `jvm_memory_used_bytes` - Memory usage
- `process_cpu_usage` - CPU usage

## 🧪 Testing Workflow

### Full Chaos Testing Cycle

```bash
# 1. Deploy applications
./run.sh

# 2. Start chaos experiments
./k8s/chaos/apply-chaos.sh

# 3. Run load tests (in another terminal)
k6 run ./load-tests/script.js \
  --address localhost:6565 \
  --env URL=http://localhost:30001/api/products \
  --env TYPE=aot

k6 run ./load-tests/script.js \
  --address localhost:6566 \
  --env URL=http://localhost:30002/api/products \
  --env TYPE=jit

# 4. Monitor chaos dashboard
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333

# 5. Stop chaos
./k8s/chaos/stop-chaos.sh

# 6. Generate report
./scripts/reporting/generate_report.sh
```

## 📈 Expected Results

### **AOT (GraalVM Native Image)**
✅ **Strengths:**
- Faster pod restart (instant startup)
- Lower memory usage during stress
- Consistent performance under CPU stress
- Quick recovery from failures

⚠️ **Potential Weaknesses:**
- May be less flexible during runtime changes

### **JIT (Traditional JVM)**
✅ **Strengths:**
- Adaptive optimization during stress
- Better long-running performance

⚠️ **Potential Weaknesses:**
- Slower pod restart (JVM warmup)
- Higher memory usage
- GC pauses during stress
- Slower recovery from failures

## 🎓 Chaos Engineering Best Practices

### 1. **Start Small**
Begin with one experiment type, then gradually increase complexity.

### 2. **Monitor Everything**
Always watch:
- Application logs
- Prometheus metrics
- Kubernetes events
- Chaos Mesh dashboard

### 3. **Define Success Criteria**
Before running chaos:
- What should happen?
- What's acceptable degradation?
- What's a failure?

### 4. **Run During Load**
Chaos is most effective when combined with load testing.

### 5. **Document Findings**
Record:
- What failed?
- How did it recover?
- What needs improvement?

## 🔧 Customizing Experiments

### Adjust Chaos Frequency
Edit the `scheduler.cron` field:
```yaml
scheduler:
  cron: "@every 5m"  # Change to your desired interval
```

### Adjust Chaos Intensity
Edit experiment parameters:
```yaml
# CPU stress intensity
stressors:
  cpu:
    workers: 4      # Increase workers
    load: 90        # Increase load percentage

# Network delay amount
delay:
  latency: "1000ms"  # Increase latency
  jitter: "200ms"    # Increase jitter
```

### Target Specific Pods
Modify the selector:
```yaml
selector:
  namespaces:
    - springboot-graalvm
  labelSelectors:
    "app": "springboot-graalvm-aot"  # Target only AOT
```

## 🚨 Troubleshooting

### Chaos Mesh Not Working?

**Check Chaos Mesh status:**
```bash
kubectl get pods -n chaos-mesh
kubectl logs -n chaos-mesh -l app.kubernetes.io/component=controller-manager
```

**Verify CRDs are installed:**
```bash
kubectl get crd | grep chaos-mesh
```

### Experiments Not Triggering?

**Check experiment status:**
```bash
kubectl get podchaos pod-kill-chaos -n springboot-graalvm -o yaml
```

**Look for events:**
```bash
kubectl get events -n springboot-graalvm --sort-by='.lastTimestamp'
```

### Pods Not Recovering?

**Check pod status:**
```bash
kubectl describe pod <pod-name> -n springboot-graalvm
```

**Force delete stuck pods:**
```bash
kubectl delete pod <pod-name> -n springboot-graalvm --force --grace-period=0
```

## 📚 Additional Resources

- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [Chaos Engineering Principles](https://principlesofchaos.org/)
- [Kubernetes Chaos Engineering](https://kubernetes.io/blog/2021/12/22/kubernetes-1-23-release-announcement/)

## 🎯 Next Steps

1. **Install Chaos Mesh**: `./k8s/chaos/install-chaos-mesh.sh`
2. **Deploy Applications**: `./run.sh`
3. **Start Chaos**: `./k8s/chaos/apply-chaos.sh`
4. **Monitor Dashboard**: `kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333`
5. **Run Load Tests**: Use k6 scripts
6. **Analyze Results**: Compare AOT vs JIT resilience
7. **Stop Chaos**: `./k8s/chaos/stop-chaos.sh`

---

**Happy Chaos Engineering! 🌪️**
