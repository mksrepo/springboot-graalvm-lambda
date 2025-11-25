# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 20710 | 7102 |
| **Throughput (reqs/sec)** | 4141.19992/s | 1412.856758/s |
| **Avg Response Time** | 2.38ms | 7.04ms |
| **p95 Response Time** | p(90)=1.47ms | p(90)=5.88ms |
| **Data Received** | 3.0 MB | 1.0 MB |
| **Docker Build Time** |      2000 ms |      2000 ms |
| **Docker Image Size** |      241MB |      499MB |
| **Docker Push Time** |       7000 ms |       6000 ms |
| **K8s Deployment Time** |    5000 ms |    5000 ms |
| **App Start Time** |         0 ms |         0 ms |

## Key Findings

1.  **Throughput**: AOT achieved **4141.19992/s** vs JIT **1412.856758/s**.
2.  **Latency**: AOT Avg Latency **2.38ms** vs JIT **7.04ms**.
3.  **Image Size**: AOT Image is **     241MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
