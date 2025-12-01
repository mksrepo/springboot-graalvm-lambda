# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 18968 | 5434 |
| **Throughput (reqs/sec)** | 3757.18015/s | 1068.673796/s |
| **Avg Response Time** | 2.63ms | 9.16ms |
| **p95 Response Time** | p(90)=1.42ms | p(90)=22.93ms |
| **Data Received** | 2.8 MB | 800 kB |
| **Docker Build Time** |      1 seconds |      2 seconds |
| **Docker Image Size** |      337MB |      564MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    0 seconds |    0 seconds |
| **Pod Startup Time** | 0 ms | 434578000 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 126 | 98 (-28) |
| **Vulnerabilities** | 0C     0H     1M    24L | 0C     0H     0M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **3757.18015/s** vs JIT **1068.673796/s**.
2.  **Latency**: AOT Avg Latency **2.63ms** vs JIT **9.16ms**.
3.  **Image Size**: AOT Image is **     337MB** vs JIT **     564MB**.
4.  **Startup Time**: AOT started in **0 ms** vs JIT **434578000 ms**.

*Generated automatically by sh/generate_report.sh*
