# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 4236 | 9344 | 🥈 JIT | ⬆️ +120.6% |
| **⚡ Throughput** | 22.295169/s | 51.242938/s | 🥈 JIT | ⬆️ +129.8% |
| **⏱️ Avg Response Time** | 4.28s | 1.78s | 🥈 JIT | ⬇️ -58.4% |
| **📈 p95 Response Time** | 11.93s | 7.6s | 🥈 JIT | ⬇️ -36.3% |
| **❌ Failure Count** | 3 | 6282 | 🏆 AOT | ⬇️ -100.0% |
| **📦 Data Received** | 1.7 GB | 1.6 GB | 🏆 AOT | ⬆️ +6.2% |
| **🔨 Docker Build Time** |      2 seconds |      2 seconds | 🤝 Tie | ➡️ 0.0% |
| **💾 Docker Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **📤 Docker Push Time** |       7 seconds |       7 seconds | 🤝 Tie | ➡️ 0.0% |
| **☸️ K8s Deployment Time** |    14 seconds |    33 seconds | 🏆 AOT | ⬇️ -57.6% |
| **🚦 Pod Startup Time** | 156 ms | 3285 ms | 🏆 AOT | ⬇️ -95.3% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **22.295169/s** vs JIT **51.242938/s**
   - Winner: **JIT** with **+129.8%** improvement

2. **⏱️ Latency**: AOT Avg Latency **4.28s** vs JIT **1.78s**
   - Winner: **JIT** with **-58.4%** improvement

3. **✅ Reliability**: AOT had **3** failures vs JIT **6282** failures
   - Winner: **AOT** with **-100.0%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     340MB** vs JIT **     573MB**
   - Winner: **AOT** with **-40.7%** improvement

5. **🚦 Startup Time**: AOT **156 ms** vs JIT **3285 ms**
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
