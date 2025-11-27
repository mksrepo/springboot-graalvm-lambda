# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 26283 | 5390 |
| **Throughput (reqs/sec)** | 5249.904272/s | 1062.866272/s |
| **Avg Response Time** | 1.86ms | 9.34ms |
| **p95 Response Time** | p(90)=1.31ms | p(90)=4.97ms |
| **Data Received** | 3.9 MB | 793 kB |
| **Docker Build Time** |      2 seconds |      2 seconds |
| **Docker Image Size** |      150MB |      499MB |
| **Docker Push Time** |       7 seconds |       6 seconds |
| **K8s Deployment Time** |    6 seconds |    5 seconds |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | distroless/static:nonroo | amazoncorretto:17-alpine |
| **Total Packages** | 8 | 70 (+62) |
| **Vulnerabilities** | 0C     0H     0M     0L | 0C     0H     0M     2L |

**Note**: The AOT image uses `distroless/static:nonroo` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **5249.904272/s** vs JIT **1062.866272/s**.
2.  **Latency**: AOT Avg Latency **1.86ms** vs JIT **9.34ms**.
3.  **Image Size**: AOT Image is **     150MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
