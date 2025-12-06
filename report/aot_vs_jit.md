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
| **🚀 Total Requests** | 219 | 90 | 🏆 AOT | ⬆️ +143.3% |
| **⚡ Throughput** | 20.571371/s | 8.040522/s | 🏆 AOT | ⬆️ +155.8% |
| **⏱️ Avg Response** | 355.05ms | 1.07s | 🏆 AOT | ⬇️ -66.8% |
| **🎯 Median Response** | 150.16ms | 442.63ms | 🏆 AOT | ⬇️ -66.1% |
| **📉 p95 Response** | 1.52s | 6.06s | 🏆 AOT | ⬇️ -74.9% |
| **💥 Max Response** | 2.11s | 6.7s | 🏆 AOT | ⬇️ -68.5% |
| **📦 Data Received** | 142 MB | 59 MB | 🏆 AOT | ⬆️ +140.7% |
| **❌ Failure Rate** | 0.00% | 0.00% | 🤝 Tie | ⬇️ -0.0% |
| **🔨 Build Time** |      3 seconds |      3 seconds | 🤝 Tie | ⬇️ -0.0% |
| **💾 Image Size** |      340MB |      573MB | 🏆 AOT | ⬇️ -40.7% |
| **🚦 Startup Time** | 242 ms | 1998 ms | 🏆 AOT | ⬇️ -87.9% |

---

## 🔑 Key Takeaways

1. **Throughput**: AOT is faster by +155.8%
2. **Startup**: AOT starts faster by -87.9%
3. **Efficiency**: AOT has a -40.7% smaller Docker image.

