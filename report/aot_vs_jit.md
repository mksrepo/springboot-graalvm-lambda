# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 3582 | 598 |
| **Throughput (reqs/sec)** | 704.590361/s | 118.799576/s |
| **Avg Response Time** | 14.01ms | 83.88ms |
| **p95 Response Time** | p(90)=76.14ms | p(90)=103.13ms |
| **Data Received** | 157 MB | 4.5 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      358MB |      576MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    7 seconds |    7 seconds |
| **Pod Startup Time** | 5883 ms | 5807 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 152 | 117 (-35) |
| **Vulnerabilities** | 0C     0H     1M    36L | 0C     0H     1M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **704.590361/s** vs JIT **118.799576/s**.
2.  **Latency**: AOT Avg Latency **14.01ms** vs JIT **83.88ms**.
3.  **Image Size**: AOT Image is **     358MB** vs JIT **     576MB**.
4.  **Startup Time**: AOT started in **5883 ms** vs JIT **5807 ms**.

*Generated automatically by scripts/generate_report.sh*
