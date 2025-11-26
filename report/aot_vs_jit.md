# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 23559 | 7900 |
| **Throughput (reqs/sec)** | 4696.422036/s | 1579.621839/s |
| **Avg Response Time** | 2.09ms | 6.28ms |
| **p95 Response Time** | p(90)=1.36ms | p(90)=2.59ms |
| **Data Received** | 3.5 MB | 1.2 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      241MB |      499MB |
| **Docker Push Time** |       7 seconds |       6 seconds |
| **K8s Deployment Time** |    5 seconds |    5 seconds |
| **App Start Time** |  |  |

## Key Findings

1.  **Throughput**: AOT achieved **4696.422036/s** vs JIT **1579.621839/s**.
2.  **Latency**: AOT Avg Latency **2.09ms** vs JIT **6.28ms**.
3.  **Image Size**: AOT Image is **     241MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
*For more details, please refer to the k6 and cicd reports.*
