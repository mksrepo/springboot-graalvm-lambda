# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 23375 | 1099 |
| **Throughput (reqs/sec)** | 4622.182323/s | 217.277495/s |
| **Avg Response Time** | 2.12ms | 45.92ms |
| **p95 Response Time** | p(90)=1.32ms | p(90)=98.34ms |
| **Data Received** | 3.4 MB | 162 kB |
| **Docker Build Time** |      3 seconds |      2 seconds |
| **Docker Image Size** |      337MB |      564MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    17 seconds |    23 seconds |
| **Pod Startup Time** | 5000 ms | 12000 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 126 | 98 (-28) |
| **Vulnerabilities** | 0C     0H     1M    24L | 0C     0H     0M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **4622.182323/s** vs JIT **217.277495/s**.
2.  **Latency**: AOT Avg Latency **2.12ms** vs JIT **45.92ms**.
3.  **Image Size**: AOT Image is **     337MB** vs JIT **     564MB**.
4.  **Startup Time**: AOT started in **5000 ms** vs JIT **12000 ms**.

*Generated automatically by sh/generate_report.sh*
