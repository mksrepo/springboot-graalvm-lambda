# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 19191 | 63307 |
| **Throughput (reqs/sec)** | 3836.648459/s | 12660.270704/s |
| **Avg Response Time** | 2.58ms | 768.26µs |
| **p95 Response Time** | p(90)=1.64ms | p(90)=1.19ms |
| **Data Received** | 2.8 MB | 9.3 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      241MB |      499MB |
| **Docker Push Time** |       7 seconds |       6 seconds |
| **K8s Deployment Time** |    5 seconds |    5 seconds |

## Key Findings

1.  **Throughput**: AOT achieved **3836.648459/s** vs JIT **12660.270704/s**.
2.  **Latency**: AOT Avg Latency **2.58ms** vs JIT **768.26µs**.
3.  **Image Size**: AOT Image is **     241MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
