# Spring Boot GraalVM - Resiliency & Performance Lab

## Overview
This walkthrough guides you through a hands-on lab comparing **GraalVM Native Image (AOT)** vs **Standard JVM (JIT)**. We will use **Chaos Mesh** to inject failures and observe how each deployment handles stress.

---

## 🚀 Phase 1: Deployment

### 1. Start the Environment
Deploy the full stack (Infrastructure + Apps + Chaos Mesh):

```bash
./run.sh --chaos
```

*This will take ~5-10 minutes on the first run as it pulls images and builds the application.*

### 2. Verify Deployment
Check that everything is running:

```bash
kubectl get pods -n springboot-graalvm
```
You should see:
- `postgres` & `kafka` (Persistence)
- `prometheus` & `grafana` (Observability)
- `springboot-graalvm-aot` (Native App)
- `springboot-graalvm-jit` (JVM App)

---

## 📊 Phase 2: Observability

### Access Dashboards
Open the following links in your browser:

1. **Grafana (Metrics)**: [http://localhost:30004](http://localhost:30004)
   - Login: `admin` / `admin`
   - Go to **Dashboards** -> **JVM (Micrometer)**
   - View memory usage, CPU, and GC metrics in real-time.

2. **Chaos Dashboard**: [http://localhost:2333](http://localhost:2333)
   - View active experiments and their schedule.

---

## 🔥 Phase 3: Chaos Engineering

The script automatically schedules the following attacks using Chaos Mesh. You can verify them:

```bash
kubectl get schedule -n springboot-graalvm
```

### Experiment 1: Pod Kill (Resilience)
- **What happens:** Randomly kills application pods.
- **Goal:** Verify that Kubernetes restarts them and the app recovers quickly.
- **Observation:** Check **"App Start Time"** in the final report. AOT should recover much faster (ms vs seconds).

### Experiment 2: Network Latency (Performance)
- **What happens:** Injects 500ms delay into network calls.
- **Goal:** See if the application times out or queues handling requests.
- **Observation:** Check P99 Latency in Grafana.

### Experiment 3: Resource Stress (Stability)
- **What happens:** Consumes 80% CPU and 256MB Memory.
- **Goal:** Trigger OOM kills or CPU throttling.
- **Observation:** Native images often use significantly less memory, surviving where JVM might crash or GC thrash.

---

## 📈 Phase 4: Analysis

After the `run.sh` script completes, it generates a report.

### View the Report
```bash
cat report/aot_vs_jit.md
```

### Key Metrics to Compare
1. **Startup Time**: AOT is typically < 100ms. JIT is > 2000ms.
2. **Image Size**: AOT is smaller (no JVM bundled).
3. **Throughput (Chaos)**: How many requests succeeded during the attacks?
4. **Latency (Chaos)**: Did JIT GC pauses compound the network latency?

---

## 🧹 Cleanup

When finished, remove the resources to save battery/memory on your machine:

```bash
./kubernetes/cleanup-full.sh
```

---
**Happy Testing!** 🧪
