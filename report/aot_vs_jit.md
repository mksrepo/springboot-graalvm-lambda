# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | 25336 | 29508 |
| **Throughput (reqs/sec)** | 140.600935/s | 163.846449/s |
| **Avg Response Time** | 70.95ms | 60.86ms |
| **p95 Response Time** | p(90)=183.18ms | p(90)=123.88ms |
| **Data Received** | 7.9 GB | 11 GB |
| **Docker Build Time** |      2 seconds |      3 seconds |
| **Docker Image Size** |      358MB |      576MB |
| **Docker Push Time** |       7 seconds |       7 seconds |
| **K8s Deployment Time** |    7 seconds |    7 seconds |
| **Pod Startup Time** | 5861 ms | 5773 ms |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | debian:12-slim | amazoncorretto:17-alpine |
| **Total Packages** | 152 | 117 (-35) |
| **Vulnerabilities** | 0C     0H     1M    36L | 0C     0H     1M     2L |

**Note**: The AOT image uses `debian:12-slim` which has significantly fewer packages and vulnerabilities compared to the `amazoncorretto:17-alpine` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **140.600935/s** vs JIT **163.846449/s**.
2.  **Latency**: AOT Avg Latency **70.95ms** vs JIT **60.86ms**.
3.  **Image Size**: AOT Image is **     358MB** vs JIT **     576MB**.
4.  **Startup Time**: AOT started in **5861 ms** vs JIT **5773 ms**.

*Generated automatically by sh/generate_report.sh*
