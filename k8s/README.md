# Kubernetes Resources

This directory contains all Kubernetes manifests and management scripts for the Spring Boot GraalVM application.

## Structure

```
k8s/
├── apps/                           # Application deployments
│   ├── deployment-aot.yaml         # AOT (GraalVM Native) deployment
│   └── deployment-jit.yaml         # JIT (Traditional JVM) deployment
├── infra/                          # Infrastructure components
│   ├── namespace.yaml              # Namespace definition
│   ├── database/
│   │   └── postgres.yaml           # PostgreSQL database
│   └── monitoring/
│       ├── prometheus.yaml         # Prometheus metrics
│       ├── grafana.yaml            # Grafana dashboards
│       └── provisioning/           # Grafana configs
├── cleanup-apps.sh                 # 🚀 Fast cleanup (apps only)
├── cleanup-full.sh                 # 🧹 Full cleanup (everything)
└── cleanup.sh                      # Alias to cleanup-apps.sh
```

## Cleanup Scripts

### 🚀 `cleanup-apps.sh` (Recommended for Development)
**Use this for iterative testing and development.**

Deletes only the application deployments (AOT and JIT) while preserving infrastructure.

**Benefits:**
- ⚡ **Fast**: ~5-10 seconds
- 📊 **Preserves monitoring data**: Grafana history retained
- 🗄️ **Preserves database**: PostgreSQL data intact
- 🔄 **Quick iterations**: No infrastructure recreation needed

**Usage:**
```bash
./k8s/cleanup-apps.sh
```

**When to use:**
- Testing code changes
- Comparing AOT vs JIT performance
- Iterative development
- Running multiple benchmarks

---

### 🧹 `cleanup-full.sh` (Complete Teardown)
**Use this for a fresh start or when done testing.**

Deletes the entire namespace including all infrastructure.

**Benefits:**
- 🔄 **Fresh state**: Completely clean environment
- 💾 **Frees resources**: Removes all pods and services
- 🧪 **Reproducible**: Ensures consistent baseline

**Drawbacks:**
- ⏱️ **Slow**: ~60-120 seconds
- 📉 **Loses monitoring data**: All Grafana/Prometheus history deleted
- 🗄️ **Loses database**: All PostgreSQL data deleted

**Usage:**
```bash
./k8s/cleanup-full.sh
```

**When to use:**
- End of testing session
- Before committing results
- Troubleshooting infrastructure issues
- Freeing up cluster resources

---

### 🔗 `cleanup.sh` (Default)
Symlink to `cleanup-apps.sh` for backward compatibility.

---

## Deployment Workflow

### Quick Development Cycle (Recommended)
```bash
# First time setup
./run.sh

# Subsequent iterations (much faster!)
./k8s/cleanup-apps.sh
./scripts/build/gvm.aot.sh
./scripts/build/gvm.jit.sh
./scripts/reporting/generate_report.sh
```

**Time saved per iteration: ~90-120 seconds!**

### Full Clean Deployment
```bash
# Complete teardown and rebuild
./k8s/cleanup-full.sh
./run.sh
```

---

## Performance Impact

| Cleanup Type | Time | Infrastructure | Data | Use Case |
|--------------|------|----------------|------|----------|
| **Apps Only** | ~5-10s | ✅ Preserved | ✅ Preserved | Development/Testing |
| **Full** | ~60-120s | ❌ Deleted | ❌ Deleted | Fresh start/Cleanup |

---

## Tips

1. **For benchmarking**: Use `cleanup-apps.sh` to preserve monitoring data across runs
2. **For CI/CD**: Use `cleanup-full.sh` to ensure reproducible environments
3. **For development**: Use `cleanup-apps.sh` for faster iterations
4. **End of day**: Use `cleanup-full.sh` to free up resources

---

## Troubleshooting

### Pods stuck in Terminating state
```bash
# Force delete stuck pods
kubectl delete pods --all -n springboot-graalvm --force --grace-period=0
```

### Namespace stuck in Terminating
```bash
# Remove finalizers
kubectl get namespace springboot-graalvm -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/springboot-graalvm/finalize" -f -
```

### Check resource usage
```bash
kubectl top pods -n springboot-graalvm
kubectl get all -n springboot-graalvm
```
