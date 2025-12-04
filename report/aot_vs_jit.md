# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 1353 | 1290 | 🏆 AOT | ⬆️ +4.9% |
| **⚡ Throughput** | 18.907703/s | 19.070955/s | 🥈 JIT | ⬆️ +0.9% |
| **⏱️ Avg Response Time** | 4.82s | 4.88s | 🏆 AOT | ⬇️ -1.2% |
| **📈 p95 Response Time** | 14.14s | 19.76s | 🏆 AOT | ⬇️ -28.4% |
| **❌ Failure Count** | 0 | 12 | - | ⬇️ - |
| **📦 Data Received** | 658 MB | 630 MB | 🏆 AOT | ⬆️ +4.4% |
| **🔨 Docker Build Time** |      3 seconds |      2 seconds | 🥈 JIT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      286MB |      535MB | 🏆 AOT | ⬇️ -46.5% |
| **📤 Docker Push Time** |       7 seconds |       7 seconds | 🤝 Tie | ➡️ 0.0% |
| **☸️ K8s Deployment Time** |    33 seconds |    33 seconds | 🤝 Tie | ➡️ 0.0% |
| **🚦 Pod Startup Time** | 32000 ms | 32000 ms | 🤝 Tie | ➡️ 0.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **18.907703/s** vs JIT **19.070955/s**
   - Winner: **JIT** with **+0.9%** improvement

2. **⏱️ Latency**: AOT Avg Latency **4.82s** vs JIT **4.88s**
   - Winner: **AOT** with **-1.2%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **12** failures
   - Winner: **-** with **-** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     286MB** vs JIT **     535MB**
   - Winner: **AOT** with **-46.5%** improvement

5. **🚦 Startup Time**: AOT **32000 ms** vs JIT **32000 ms**
   - Winner: **Tie** with **0.0%** improvement

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
