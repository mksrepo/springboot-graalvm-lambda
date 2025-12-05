# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 40424 | 3768 | 🏆 AOT | ⬆️ +972.8% |
| **⚡ Throughput** | 201.318827/s | 20.067991/s | 🏆 AOT | ⬆️ +903.2% |
| **⏱️ Avg Response Time** | 475.33ms | 4.78s | 🏆 AOT | ⬇️ -90.1% |
| **📈 p95 Response Time** | 1.05s | 12.94s | 🏆 AOT | ⬇️ -91.9% |
| **❌ Failure Count** | 38730 | 12 | 🥈 JIT | ⬇️ -100.0% |
| **📦 Data Received** | 999 MB | 2.3 GB | 🏆 AOT | ⬆️ +43334.8% |
| **🔨 Docker Build Time** |      3 seconds |      2 seconds | 🥈 JIT | ⬇️ -33.3% |
| **💾 Docker Image Size** |      285MB |      533MB | 🏆 AOT | ⬇️ -46.5% |
| **📤 Docker Push Time** |       6 seconds |       7 seconds | 🏆 AOT | ⬇️ -14.3% |
| **☸️ K8s Deployment Time** |    54 seconds |    32 seconds | 🥈 JIT | ⬇️ -40.7% |
| **🚦 Pod Startup Time** | 31000 ms | 32000 ms | 🏆 AOT | ⬇️ -3.1% |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **201.318827/s** vs JIT **20.067991/s**
   - Winner: **AOT** with **+903.2%** improvement

2. **⏱️ Latency**: AOT Avg Latency **475.33ms** vs JIT **4.78s**
   - Winner: **AOT** with **-90.1%** improvement

3. **✅ Reliability**: AOT had **38730** failures vs JIT **12** failures
   - Winner: **JIT** with **-100.0%** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **     285MB** vs JIT **     533MB**
   - Winner: **AOT** with **-46.5%** improvement

5. **🚦 Startup Time**: AOT **31000 ms** vs JIT **32000 ms**
   - Winner: **AOT** with **-3.1%** improvement

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
