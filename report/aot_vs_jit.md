# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 17124 | 21965 |
| **Throughput (reqs/sec)** | 3411.309635/s | 4376.547682/s |
| **Avg Response Time** | 2.9ms | 2.08ms |
| **p95 Response Time** | p(90)=2.36ms | p(90)=2.04ms |
| **Data Received** | 2.5 MB | 38 kB |
| **Docker Build Time** |      1 seconds |      1 seconds |
| **Docker Image Size** |      241MB |      499MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    6 seconds |    5 seconds |

## Key Findings

1.  **Throughput**: AOT achieved **3411.309635/s** vs JIT **4376.547682/s**.
2.  **Latency**: AOT Avg Latency **2.9ms** vs JIT **2.08ms**.
3.  **Image Size**: AOT Image is **     241MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
