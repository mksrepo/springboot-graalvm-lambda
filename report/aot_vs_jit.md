# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 23975 | 6563 |
| **Throughput (reqs/sec)** | 4794.248262/s | 1290.24648/s |
| **Avg Response Time** | 2.04ms | 7.56ms |
| **p95 Response Time** | p(90)=1.49ms | p(90)=2.92ms |
| **Data Received** | 3.5 MB | 966 kB |
| **Docker Build Time** |      1 seconds |      3 seconds |
| **Docker Image Size** |      150MB |      499MB |
| **Docker Push Time** |       8 seconds |       7 seconds |
| **K8s Deployment Time** |    0 seconds |    0 seconds |
| **Pod Startup Time** | 2000 ms | 1000 ms |


## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | distroless/static:nonroo | amazoncorretto:17-alpine |
| **Total Packages** | 8 | 70 (+62) |
| **Vulnerabilities** | 0C     0H     0M     0L | 0C     0H     0M     2L |

**Note**: The AOT image uses `distroless/static:nonroo` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **4794.248262/s** vs JIT **1290.24648/s**.
2.  **Latency**: AOT Avg Latency **2.04ms** vs JIT **7.56ms**.
3.  **Image Size**: AOT Image is **     150MB** vs JIT **     499MB**.
4.  **Startup Time**: AOT started in **2000 ms** vs JIT **1000 ms**.

*Generated automatically by sh/generate_report.sh*
