# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 2565 | 320 | 🏆 AOT | ⬆️ +701.6% |
| **⚡ Throughput** | 227.970252/s | 13.381774/s | 🏆 AOT | ⬆️ +1603.6% |
| **⏱️ Avg Response Time** | 297.98ms | 5.47s | 🏆 AOT | ⬇️ -94.6% |
| **📈 p95 Response Time** | 561.91ms | 14.87s | 🏆 AOT | ⬇️ -96.2% |
| **❌ Failure Count** | 3 | 1 | 🥈 JIT | ⬇️ -66.7% |
| **📦 Data Received** | 94 MB | 12 MB | 🏆 AOT | ⬆️ +683.3% |
| **🔨 Docker Build Time** |      150 seconds |      15 seconds | 🥈 JIT | ⬇️ -90.0% |
| **💾 Docker Image Size** |      286MB |      535MB | 🏆 AOT | ⬇️ -46.5% |
| **📤 Docker Push Time** |       148 seconds |       8 seconds | 🥈 JIT | ⬇️ -94.6% |
| **☸️ K8s Deployment Time** |    33 seconds |    34 seconds | 🏆 AOT | ⬇️ -2.9% |
| **🚦 Pod Startup Time** | 32000 ms | 34000 ms | 🏆 AOT | ⬇️ -5.9% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **227.970252/s** vs JIT **13.381774/s**
   - Winner: **AOT** with **+1603.6%** improvement

2. **⏱️ Latency**: AOT Avg Latency **297.98ms** vs JIT **5.47s**
   - Winner: **AOT** with **-94.6%** improvement

3. **✅ Reliability**: AOT had **3** failures vs JIT **1** failures
   - Winner: **JIT** with **-66.7%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     286MB** vs JIT **     535MB**
   - Winner: **AOT** with **-46.5%** improvement

5. **🚦 Startup Time**: AOT **32000 ms** vs JIT **34000 ms**
   - Winner: **AOT** with **-5.9%** improvement

---

## 📌 Legend
- 🏆 = Winner (Best Performance)
- 🥈 = Second Place
- 🤝 = Tie (Equal Performance)
- ⬆️ = Higher is better (increase)
- ⬇️ = Lower is better (decrease)
- ➡️ = No change

---

*🤖 Generated automatically by scripts/reporting/generate_report.sh*
