# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 3712 | 650 |
| **Throughput (reqs/sec)** | 734.297613/s | 128.836963/s |
| **Avg Response Time** | 13.54ms | 77.38ms |
| **p95 Response Time** | p(90)=75.01ms | p(90)=104.74ms |
| **Data Received** | 169 MB | 5.3 MB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      358MB |      576MB |
| **Docker Push Time** |       6 seconds |       7 seconds |
| **K8s Deployment Time** |    7 seconds |    8 seconds |
| **Pod Startup Time** | 5889 ms | 6813 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 152 | 117 (-35) |
| **Vulnerabilities** | 0C     0H     1M    36L | 0C     0H     1M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **734.297613/s** vs JIT **128.836963/s**.
2.  **Latency**: AOT Avg Latency **13.54ms** vs JIT **77.38ms**.
3.  **Image Size**: AOT Image is **     358MB** vs JIT **     576MB**.
4.  **Startup Time**: AOT started in **5889 ms** vs JIT **6813 ms**.

*Generated automatically by scripts/generate_report.sh*
