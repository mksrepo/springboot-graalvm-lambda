# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 11822 | 449 | 🏆 AOT | ⬆️ +2533.0% |
| **⚡ Throughput** | 384.943267/s | 9.541213/s | 🏆 AOT | ⬆️ +3934.5% |
| **⏱️ Avg Response Time** | 139ms | 8.44s | 🏆 AOT | ⬇️ -98.4% |
| **📈 p95 Response Time** | 300.05ms | 19.04s | 🏆 AOT | ⬇️ -98.4% |
| **❌ Failure Count** | 22 | 154 | 🏆 AOT | ⬇️ -85.7% |
| **📦 Data Received** | 406 MB | 12 MB | 🏆 AOT | ⬆️ +3283.3% |
| **🔨 Docker Build Time** |      3 seconds |      2 seconds | 🥈 JIT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      347MB |      576MB | 🏆 AOT | ⬇️ -39.8% |
| **📤 Docker Push Time** |       10 seconds |       8 seconds | 🥈 JIT | ⬇️ -20.0% |
| **☸️ K8s Deployment Time** |    33 seconds |    33 seconds | 🤝 Tie | ➡️ 0.0% |
| **🚦 Pod Startup Time** | 32000 ms | 33000 ms | 🏆 AOT | ⬇️ -3.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **384.943267/s** vs JIT **9.541213/s**
   - Winner: **AOT** with **+3934.5%** improvement

2. **⏱️ Latency**: AOT Avg Latency **139ms** vs JIT **8.44s**
   - Winner: **AOT** with **-98.4%** improvement

3. **✅ Reliability**: AOT had **22** failures vs JIT **154** failures
   - Winner: **AOT** with **-85.7%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     347MB** vs JIT **     576MB**
   - Winner: **AOT** with **-39.8%** improvement

5. **🚦 Startup Time**: AOT **32000 ms** vs JIT **33000 ms**
   - Winner: **AOT** with **-3.0%** improvement

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
