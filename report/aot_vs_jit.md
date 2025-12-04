# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 1209 | 1152 | 🏆 AOT | ⬆️ +4.9% |
| **⚡ Throughput** | 16.206091/s | 16.531155/s | 🥈 JIT | ⬆️ +2.0% |
| **⏱️ Avg Response Time** | 5.58s | 5.61s | 🏆 AOT | ⬇️ -0.5% |
| **📈 p95 Response Time** | 15.77s | 21.84s | 🏆 AOT | ⬇️ -27.8% |
| **❌ Failure Count** | 0 | 25 | - | ⬇️ - |
| **📦 Data Received** | 807 MB | 736 MB | 🏆 AOT | ⬆️ +9.6% |
| **🔨 Docker Build Time** |      3 seconds |      3 seconds | 🤝 Tie | ➡️ 0.0% |
| **💾 Docker Image Size** |      286MB |      535MB | 🏆 AOT | ⬇️ -46.5% |
| **📤 Docker Push Time** |       8 seconds |       9 seconds | 🏆 AOT | ⬇️ -11.1% |
| **☸️ K8s Deployment Time** |    33 seconds |    32 seconds | 🥈 JIT | ⬇️ -3.0% |
| **🚦 Pod Startup Time** | 32000 ms | 32000 ms | 🤝 Tie | ➡️ 0.0% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **16.206091/s** vs JIT **16.531155/s**
   - Winner: **JIT** with **+2.0%** improvement

2. **⏱️ Latency**: AOT Avg Latency **5.58s** vs JIT **5.61s**
   - Winner: **AOT** with **-0.5%** improvement

3. **✅ Reliability**: AOT had **0** failures vs JIT **25** failures
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
