# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 7791 | 7011 | 🏆 AOT | ⬆️ +11.1% |
| **⚡ Throughput** | 41.784385/s | 37.836861/s | 🏆 AOT | ⬆️ +10.4% |
| **⏱️ Avg Response Time** | 2.24s | 2.49s | 🏆 AOT | ⬇️ -10.0% |
| **📈 p95 Response Time** | 6.32s | 6.63s | 🏆 AOT | ⬇️ -4.7% |
| **❌ Failure Count** | 0 | 0 | - | ⬇️ - |
| **📦 Data Received** | 1.8 GB | 2.3 GB | 🥈 JIT | ⬆️ +27.8% |
| **🔨 Docker Build Time** |      3 seconds |      2 seconds | 🥈 JIT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **📤 Docker Push Time** |       8 seconds |       9 seconds | 🏆 AOT | ⬇️ -11.1% |
| **☸️ K8s Deployment Time** |    14 seconds |    32 seconds | 🏆 AOT | ⬇️ -56.2% |
| **🚦 Pod Startup Time** | 181 ms | 3311 ms | 🏆 AOT | ⬇️ -94.5% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **41.784385/s** vs JIT **37.836861/s**
   - Winner: **AOT** with **+10.4%** improvement

2. **⏱️ Latency**: AOT Avg Latency **2.24s** vs JIT **2.49s**
   - Winner: **AOT** with **-10.0%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **0** failures
   - Winner: **-** with **-** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     340MB** vs JIT **     573MB**
   - Winner: **AOT** with **-40.7%** improvement

5. **🚦 Startup Time**: AOT **181 ms** vs JIT **3311 ms**
   - Winner: **AOT** with **-94.5%** improvement

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
