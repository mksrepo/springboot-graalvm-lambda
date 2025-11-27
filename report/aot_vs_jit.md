# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 25880 | 4608 |
| **Throughput (reqs/sec)** | 5174.669075/s | 914.478226/s |
| **Avg Response Time** | 1.89ms | 10.87ms |
| **p95 Response Time** | p(90)=1.32ms | p(90)=74.11ms |
| **Data Received** | 3.8 MB | 678 kB |
| **Docker Build Time** |      1 seconds |      2 seconds |
| **Docker Image Size** |      150MB |      499MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    6 seconds |    5 seconds |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | distroless/static:nonroo | amazoncorretto:17-alpine |
| **Total Packages** | 8 | 70 (+62) |
| **Vulnerabilities** | 0C     0H     0M     0L | 0C     0H     0M     2L |

**Note**: The AOT image uses `distroless/static:nonroo` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **5174.669075/s** vs JIT **914.478226/s**.
2.  **Latency**: AOT Avg Latency **1.89ms** vs JIT **10.87ms**.
3.  **Image Size**: AOT Image is **     150MB** vs JIT **     499MB**.

*Generated automatically by sh/generate_report.sh*
