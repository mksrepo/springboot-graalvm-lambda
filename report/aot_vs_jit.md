# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (GraalVM Native Image) and **JIT** (JVM) versions based on the latest k6 load test results.

**🧪 Test Configuration:**
- **Virtual Users:** 10 (Simulated concurrent users)
- **Duration:** 10s
- **Tool:** k6 Load Testing

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | 105 | 30 | 🏆 AOT | ⬆️ +250.0% |
| **⚡ Throughput** | 16.882752/s | 2.800521/s | 🏆 AOT | ⬆️ +502.8% |
| **⏱️ Avg Response** | 430.07ms | 3.16s | 🏆 AOT | ⬇️ -86.4% |
| **🎯 Median Response** | 154.6ms | 599.44ms | 🏆 AOT | ⬇️ -74.2% |
| **📉 p95 Response** | 1.41s | 9.66s | 🏆 AOT | ⬇️ -85.4% |
| **💥 Max Response** | 2s | 9.8s | 🏆 AOT | ⬇️ -79.6% |
| **📦 Data Received** | 55 MB | 16 MB | 🏆 AOT | ⬆️ +243.8% |
| **❌ Failure Rate** | 0.00% | 0.00% | 🤝 Tie | ⬇️ -0.0% |
| **🔨 Build Time** |      2 seconds |      2 seconds | 🤝 Tie | ⬇️ -0.0% |
| **💾 Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **🚦 Startup Time** | 12000 ms | 32000 ms | 🏆 AOT | ⬇️ -62.5% |

---

## 🔑 Key Takeaways

1. **Throughput**: AOT is faster by +502.8%
2. **Startup**: AOT starts faster by -62.5%
3. **Efficiency**: AOT has a -40.7% smaller Docker image.

