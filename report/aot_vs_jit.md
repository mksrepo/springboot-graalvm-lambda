# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 10120 | 6752 |
| **Throughput (reqs/sec)** | 336.855459/s | 224.863705/s |
| **Avg Response Time** | 29.58ms | 44.35ms |
| **p95 Response Time** | p(90)=87.8ms | p(90)=96.4ms |
| **Data Received** | 1.3 GB | 558 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      358MB |      576MB |
| **Docker Push Time** |       7 seconds |       6 seconds |
| **K8s Deployment Time** |    7 seconds |    7 seconds |
| **Pod Startup Time** | 5856 ms | 5785 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 152 | 117 (-35) |
| **Vulnerabilities** | 0C     0H     1M    36L | 0C     0H     1M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **336.855459/s** vs JIT **224.863705/s**.
2.  **Latency**: AOT Avg Latency **29.58ms** vs JIT **44.35ms**.
3.  **Image Size**: AOT Image is **     358MB** vs JIT **     576MB**.
4.  **Startup Time**: AOT started in **5856 ms** vs JIT **5785 ms**.

*Generated automatically by sh/generate_report.sh*
