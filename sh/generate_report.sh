#!/bin/bash

REPORT_DIR="./report"
OUTPUT_FILE="${REPORT_DIR}/aot_vs_jit.md"

# Function to extract k6 metric
get_k6_metric() {
    local file=$1
    local metric=$2
    local field=$3
    grep "${metric}" "${file}" | awk -v f="$field" '{print $f}'
}

# Function to extract CI/CD metric
get_cicd_metric() {
    local file=$1
    local key=$2
    grep "${key}" "${file}" | awk -F': ' '{print $2}' | tr -d '\n'
}

echo "Generating comparison report..."

# Read AOT Metrics
AOT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 2)
AOT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 3)
AOT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 2 | sed 's/avg=//')
AOT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 6 | sed 's/p(95)=//')
AOT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 2)
AOT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 3)

AOT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Build Time")
AOT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Push Time")
AOT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "K8s Deployment Time")
AOT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Image Size")

# Read JIT Metrics
JIT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 2)
JIT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 3)
JIT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 2 | sed 's/avg=//')
JIT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 6 | sed 's/p(95)=//')
JIT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 2)
JIT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 3)

JIT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Build Time")
JIT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Push Time")
JIT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "K8s Deployment Time")
JIT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Image Size")

echo "Generating image comparison report..."
docker scout compare local://mrinmay939/springboot-graalvm-jit:v2.0 --to local://mrinmay939/springboot-graalvm-aot:v2.0 > ./report/vulnerability_report.md

# Function to extract vulnerability metric
get_vuln_metric() {
    local key=$1
    local column=$2 # 2 for JIT, 3 for AOT
    grep "${key}" "${REPORT_DIR}/vulnerability_report.md" | head -n 1 | awk -F'│' -v c="$column" '{print $c}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Read Vulnerability Metrics
# Note: In vulnerability_report.md, Column 2 is JIT, Column 3 is AOT (based on the header analysis)
JIT_BASE_IMAGE=$(get_vuln_metric "Base image" 2)
AOT_BASE_IMAGE=$(get_vuln_metric "Base image" 3)

JIT_PACKAGES=$(get_vuln_metric "packages" 2)
AOT_PACKAGES=$(get_vuln_metric "packages" 3)

JIT_VULN=$(get_vuln_metric "vulnerabilities" 2)
AOT_VULN=$(get_vuln_metric "vulnerabilities" 3)


# Generate Markdown
cat <<EOF > "${OUTPUT_FILE}"
# Performance Comparison: AOT vs JIT

## Overview
This report compares the performance of the AOT (Ahead-of-Time, GraalVM Native Image) and JIT (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

## Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests (Iterations)** | ${AOT_REQS} | ${JIT_REQS} |
| **Throughput (reqs/sec)** | ${AOT_THROUGHPUT} | ${JIT_THROUGHPUT} |
| **Avg Response Time** | ${AOT_AVG_LATENCY} | ${JIT_AVG_LATENCY} |
| **p95 Response Time** | ${AOT_P95_LATENCY} | ${JIT_P95_LATENCY} |
| **Data Received** | ${AOT_DATA} ${AOT_DATA_UNIT} | ${JIT_DATA} ${JIT_DATA_UNIT} |
| **Docker Build Time** | ${AOT_BUILD_TIME} | ${JIT_BUILD_TIME} |
| **Docker Image Size** | ${AOT_IMAGE_SIZE} | ${JIT_IMAGE_SIZE} |
| **Docker Push Time** | ${AOT_PUSH_TIME} | ${JIT_PUSH_TIME} |
| **K8s Deployment Time** | ${AOT_DEPLOY_TIME} | ${JIT_DEPLOY_TIME} |

## Vulnerability Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Base Image** | ${AOT_BASE_IMAGE} | ${JIT_BASE_IMAGE} |
| **Total Packages** | ${AOT_PACKAGES} | ${JIT_PACKAGES} |
| **Vulnerabilities** | ${AOT_VULN} | ${JIT_VULN} |

**Note**: The AOT image uses \`${AOT_BASE_IMAGE}\` which has significantly fewer packages and vulnerabilities compared to the \`${JIT_BASE_IMAGE}\` base used for JIT.

## Key Findings

1.  **Throughput**: AOT achieved **${AOT_THROUGHPUT}** vs JIT **${JIT_THROUGHPUT}**.
2.  **Latency**: AOT Avg Latency **${AOT_AVG_LATENCY}** vs JIT **${JIT_AVG_LATENCY}**.
3.  **Image Size**: AOT Image is **${AOT_IMAGE_SIZE}** vs JIT **${JIT_IMAGE_SIZE}**.

*Generated automatically by sh/generate_report.sh*
EOF

echo "Report generated at ${OUTPUT_FILE}"
