# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 31340 | 36144 |
| **Throughput (reqs/sec)** | 104.376841/s | 120.446869/s |
| **Avg Response Time** | 95.61ms | 82.81ms |
| **p95 Response Time** | p(90)=239.4ms | p(90)=192.71ms |
| **Data Received** | 12 GB | 16 GB |
| **Docker Build Time** |      3 seconds |      2 seconds |
| **Docker Image Size** |      359MB |      579MB |
| **Docker Push Time** |       6 seconds |       7 seconds |
| **K8s Deployment Time** |    7 seconds |    6 seconds |
| **Pod Startup Time** | 5785 ms | 5798 ms |

## Key Findings

1.  **Throughput**: AOT achieved **104.376841/s** vs JIT **120.446869/s**.
2.  **Latency**: AOT Avg Latency **95.61ms** vs JIT **82.81ms**.
3.  **Image Size**: AOT Image is **     359MB** vs JIT **     579MB**.
4.  **Startup Time**: AOT started in **5785 ms** vs JIT **5798 ms**.

*Generated automatically by scripts/generate_report.sh*
