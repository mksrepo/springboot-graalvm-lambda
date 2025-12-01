# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 6566 | 2114 |
| **Throughput (reqs/sec)** | 218.01591/s | 70.163646/s |
| **Avg Response Time** | 45.66ms | 142.15ms |
| **p95 Response Time** | p(90)=102.4ms | p(90)=204.37ms |
| **Data Received** | 528 MB | 55 MB |
| **Docker Build Time** |      2 seconds |      1 seconds |
| **Docker Image Size** |      337MB |      564MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    17 seconds |    24 seconds |
| **Pod Startup Time** | 6000 ms | 12000 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 126 | 98 (-28) |
| **Vulnerabilities** | 0C     0H     1M    24L | 0C     0H     0M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **218.01591/s** vs JIT **70.163646/s**.
2.  **Latency**: AOT Avg Latency **45.66ms** vs JIT **142.15ms**.
3.  **Image Size**: AOT Image is **     337MB** vs JIT **     564MB**.
4.  **Startup Time**: AOT started in **6000 ms** vs JIT **12000 ms**.

*Generated automatically by sh/generate_report.sh*
