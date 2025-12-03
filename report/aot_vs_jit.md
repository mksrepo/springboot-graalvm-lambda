# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 3522 | 622 |
| **Throughput (reqs/sec)** | 701.378601/s | 121.370093/s |
| **Avg Response Time** | 14.18ms | 81.56ms |
| **p95 Response Time** | p(90)=40.59ms | p(90)=103.94ms |
| **Data Received** | 152 MB | 4.9 MB |
| **Docker Build Time** |      4 seconds |      2 seconds |
| **Docker Image Size** |      359MB |      579MB |
| **Docker Push Time** |       28 seconds |       6 seconds |
| **K8s Deployment Time** |    10 seconds |    15 seconds |
| **Pod Startup Time** | 10000 ms | 14000 ms |

## Key Findings

1.  **Throughput**: AOT achieved **701.378601/s** vs JIT **121.370093/s**.
2.  **Latency**: AOT Avg Latency **14.18ms** vs JIT **81.56ms**.
3.  **Image Size**: AOT Image is **     359MB** vs JIT **     579MB**.
4.  **Startup Time**: AOT started in **10000 ms** vs JIT **14000 ms**.

*Generated automatically by scripts/generate_report.sh*
