# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 20947 | 64733 |
| **Throughput (reqs/sec)** | 4167.647381/s | 12943.529795/s |
| **Avg Response Time** | 2.37ms | 751.64µs |
| **p95 Response Time** | p(90)=1.65ms | p(90)=1.18ms |
| **Data Received** | 3.1 MB | 9.5 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      241MB |      499MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    5 seconds |    5 seconds |

## Key Findings

1.  **Throughput**: AOT achieved **4167.647381/s** vs JIT **12943.529795/s**.
2.  **Latency**: AOT Avg Latency **2.37ms** vs JIT **751.64µs**.
3.  **Image Size**: AOT Image is **     241MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
