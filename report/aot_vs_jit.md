# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 72 | 40 | 🏆 AOT | ⬆️ +80.0% |
| **⚡ Throughput** | 5.123572/s | 1.614287/s | 🏆 AOT | ⬆️ +217.4% |
| **⏱️ Avg Response Time** | 1.62s | 5.65s | 🏆 AOT | ⬇️ -71.3% |
| **📈 p95 Response Time** | 5.03s | 19.73s | 🏆 AOT | ⬇️ -74.5% |
| **❌ Failure Count** | 0 | 0 | - | ⬇️ - |
| **📦 Data Received** | 310 MB | 172 MB | 🏆 AOT | ⬆️ +80.2% |
| **🔨 Docker Build Time** |      143 seconds |      15 seconds | 🥈 JIT | ⬇️ -89.5% |
| **💾 Docker Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **📤 Docker Push Time** |       22 seconds |       8 seconds | 🥈 JIT | ⬇️ -63.6% |
| **☸️ K8s Deployment Time** |    14 seconds |    33 seconds | 🏆 AOT | ⬇️ -57.6% |
| **🚦 Pod Startup Time** | 162 ms | 3411 ms | 🏆 AOT | ⬇️ -95.3% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **5.123572/s** vs JIT **1.614287/s**
   - Winner: **AOT** with **+217.4%** improvement

2. **⏱️ Latency**: AOT Avg Latency **1.62s** vs JIT **5.65s**
   - Winner: **AOT** with **-71.3%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **0** failures
   - Winner: **-** with **-** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     340MB** vs JIT **     573MB**
   - Winner: **AOT** with **-40.7%** improvement

5. **🚦 Startup Time**: AOT **162 ms** vs JIT **3411 ms**
   - Winner: **AOT** with **-95.3%** improvement

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
