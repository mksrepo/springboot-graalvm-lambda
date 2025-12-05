# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 18551 | 2967 | 🏆 AOT | ⬆️ +525.2% |
| **⚡ Throughput** | 102.519642/s | 15.503026/s | 🏆 AOT | ⬆️ +561.3% |
| **⏱️ Avg Response Time** | 963.25ms | 6.17s | 🏆 AOT | ⬇️ -84.4% |
| **📈 p95 Response Time** | 4.53s | 16.48s | 🏆 AOT | ⬇️ -72.5% |
| **❌ Failure Count** | 16936 | 19 | 🥈 JIT | ⬇️ -99.9% |
| **📦 Data Received** | 1.3 GB | 2.6 GB | 🥈 JIT | ⬆️ +100.0% |
| **🔨 Docker Build Time** |      3 seconds |      2 seconds | 🥈 JIT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **📤 Docker Push Time** |       7 seconds |       8 seconds | 🏆 AOT | ⬇️ -12.5% |
| **☸️ K8s Deployment Time** |    32 seconds |    32 seconds | 🤝 Tie | ➡️ 0.0% |
| **🚦 Pod Startup Time** | 32000 ms | 32000 ms | 🤝 Tie | ➡️ 0.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **102.519642/s** vs JIT **15.503026/s**
   - Winner: **AOT** with **+561.3%** improvement

2. **⏱️ Latency**: AOT Avg Latency **963.25ms** vs JIT **6.17s**
   - Winner: **AOT** with **-84.4%** improvement

3. **✅ Reliability**: AOT had **16936** failures vs JIT **19** failures
   - Winner: **JIT** with **-99.9%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     340MB** vs JIT **     573MB**
   - Winner: **AOT** with **-40.7%** improvement

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
