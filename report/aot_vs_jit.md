# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 648 | 513 | 🏆 AOT | ⬆️ +26.3% |
| **⚡ Throughput** | 14.441723/s | 12.590066/s | 🏆 AOT | ⬆️ +14.7% |
| **⏱️ Avg Response Time** | 5.86s | 7.09s | 🏆 AOT | ⬇️ -17.3% |
| **📈 p95 Response Time** | 17.8s | 26.99s | 🏆 AOT | ⬇️ -34.0% |
| **❌ Failure Count** | 0 | 9 | - | ⬇️ - |
| **📦 Data Received** | 458 MB | 349 MB | 🏆 AOT | ⬆️ +31.2% |
| **🔨 Docker Build Time** |      2 seconds |      1 seconds | 🥈 JIT | ⬇️ -50.0% |
| **💾 Docker Image Size** |      286MB |      536MB | 🏆 AOT | ⬇️ -46.6% |
| **📤 Docker Push Time** |       7 seconds |       7 seconds | 🤝 Tie | ➡️ 0.0% |
| **☸️ K8s Deployment Time** |    34 seconds |    34 seconds | 🤝 Tie | ➡️ 0.0% |
| **🚦 Pod Startup Time** | 34000 ms | 34000 ms | 🤝 Tie | ➡️ 0.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **14.441723/s** vs JIT **12.590066/s**
   - Winner: **AOT** with **+14.7%** improvement

2. **⏱️ Latency**: AOT Avg Latency **5.86s** vs JIT **7.09s**
   - Winner: **AOT** with **-17.3%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **9** failures
   - Winner: **-** with **-** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     286MB** vs JIT **     536MB**
   - Winner: **AOT** with **-46.6%** improvement

5. **🚦 Startup Time**: AOT **34000 ms** vs JIT **34000 ms**
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
