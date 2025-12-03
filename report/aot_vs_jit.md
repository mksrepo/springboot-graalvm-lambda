# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 8548 | 402 | 🏆 AOT | ⬆️ +2026.4% |
| **⚡ Throughput** | 276.28989/s | 8.681443/s | 🏆 AOT | ⬆️ +3082.5% |
| **⏱️ Avg Response Time** | 239.17ms | 9.27s | 🏆 AOT | ⬇️ -97.4% |
| **📈 p95 Response Time** | 530.36ms | 20.76s | 🏆 AOT | ⬇️ -97.4% |
| **❌ Failure Count** | 11 | 142 | 🏆 AOT | ⬇️ -92.3% |
| **📦 Data Received** | 289 MB | 11 MB | 🏆 AOT | ⬆️ +2527.3% |
| **🔨 Docker Build Time** |      2 seconds |      3 seconds | 🏆 AOT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      347MB |      576MB | 🏆 AOT | ⬇️ -39.8% |
| **📤 Docker Push Time** |       7 seconds |       7 seconds | 🤝 Tie | ➡️ 0.0% |
| **☸️ K8s Deployment Time** |    33 seconds |    34 seconds | 🏆 AOT | ⬇️ -2.9% |
| **🚦 Pod Startup Time** | 32000 ms | 32000 ms | 🤝 Tie | ➡️ 0.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **276.28989/s** vs JIT **8.681443/s**
   - Winner: **AOT** with **+3082.5%** improvement

2. **⏱️ Latency**: AOT Avg Latency **239.17ms** vs JIT **9.27s**
   - Winner: **AOT** with **-97.4%** improvement

3. **✅ Reliability**: AOT had **11** failures vs JIT **142** failures
   - Winner: **AOT** with **-92.3%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     347MB** vs JIT **     576MB**
   - Winner: **AOT** with **-39.8%** improvement

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
