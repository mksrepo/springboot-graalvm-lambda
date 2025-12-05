# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 76 | 40 | 🏆 AOT | ⬆️ +90.0% |
| **⚡ Throughput** | 4.942846/s | 1.741533/s | 🏆 AOT | ⬆️ +183.8% |
| **⏱️ Avg Response Time** | 1.66s | 5.26s | 🏆 AOT | ⬇️ -68.4% |
| **📈 p95 Response Time** | 5.6s | 18.51s | 🏆 AOT | ⬇️ -69.7% |
| **❌ Failure Count** | 0 | 0 | - | ⬇️ - |
| **📦 Data Received** | 328 MB | 173 MB | 🏆 AOT | ⬆️ +89.6% |
| **🔨 Docker Build Time** |      246 seconds |      191 seconds | 🥈 JIT | ⬇️ -22.4% |
| **💾 Docker Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **📤 Docker Push Time** |       129 seconds |       7 seconds | 🥈 JIT | ⬇️ -94.6% |
| **☸️ K8s Deployment Time** |    12 seconds |    33 seconds | 🏆 AOT | ⬇️ -63.6% |
| **🚦 Pod Startup Time** | 189 ms | 3455 ms | 🏆 AOT | ⬇️ -94.5% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **4.942846/s** vs JIT **1.741533/s**
   - Winner: **AOT** with **+183.8%** improvement

2. **⏱️ Latency**: AOT Avg Latency **1.66s** vs JIT **5.26s**
   - Winner: **AOT** with **-68.4%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **0** failures
   - Winner: **-** with **-** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     340MB** vs JIT **     573MB**
   - Winner: **AOT** with **-40.7%** improvement

5. **🚦 Startup Time**: AOT **189 ms** vs JIT **3455 ms**
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
