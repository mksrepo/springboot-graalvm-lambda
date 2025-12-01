# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 6538 | 2668 |
| **Throughput (reqs/sec)** | 217.16095/s | 88.433633/s |
| **Avg Response Time** | 45.91ms | 112.76ms |
| **p95 Response Time** | p(90)=100.78ms | p(90)=200.42ms |
| **Data Received** | 524 MB | 87 MB |
| **Docker Build Time** |      10 seconds |      126 seconds |
| **Docker Image Size** |      358MB |      576MB |
| **Docker Push Time** |       25 seconds |       24 seconds |
| **K8s Deployment Time** |    23 seconds |    24 seconds |
| **Pod Startup Time** | 17884 ms | 17783 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 152 | 117 (-35) |
| **Vulnerabilities** | 0C     0H     1M    36L | 0C     0H     1M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **217.16095/s** vs JIT **88.433633/s**.
2.  **Latency**: AOT Avg Latency **45.91ms** vs JIT **112.76ms**.
3.  **Image Size**: AOT Image is **     358MB** vs JIT **     576MB**.
4.  **Startup Time**: AOT started in **17884 ms** vs JIT **17783 ms**.

*Generated automatically by sh/generate_report.sh*
