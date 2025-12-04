#!/bin/bash

REPORT_DIR="./report"
OUTPUT_FILE="${REPORT_DIR}/aot_vs_jit.md"

DOCKERHUB_USER="mrinmay939"
TAG="v2.0"
JIT_IMAGE="local://${DOCKERHUB_USER}/springboot-graalvm-jit:${TAG}"
AOT_IMAGE="local://${DOCKERHUB_USER}/springboot-graalvm-aot:${TAG}"

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

# Function to normalize time values to milliseconds
normalize_time() {
    local value=$1
    # Extract number and unit
    if [[ $value =~ ([0-9.]+)(ms|s|µs|m) ]]; then
        local num="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"
        
        case $unit in
            µs) python3 -c "print($num / 1000)" ;;
            ms) echo "$num" ;;
            s) python3 -c "print($num * 1000)" ;;
            m) python3 -c "print($num * 60000)" ;;
            *) echo "$num" ;;
        esac
    else
        echo "$value" | sed 's/[^0-9.]//g'
    fi
}

# Function to calculate comparison with winner indication
# $1 = AOT value, $2 = JIT value, $3 = metric type (higher_better/lower_better)
# Returns: "WINNER|IMPROVEMENT"
calc_comparison() {
    local aot=$1
    local jit=$2
    local metric_type=$3
    
    # Normalize time values if they contain time units
    if [[ $aot =~ (ms|s|µs|m)$ ]] || [[ $jit =~ (ms|s|µs|m)$ ]]; then
        local aot_clean=$(normalize_time "$aot")
        local jit_clean=$(normalize_time "$jit")
    else
        # Strip non-numeric for non-time values
        local aot_clean=$(echo "$aot" | sed 's/[^0-9.]//g')
        local jit_clean=$(echo "$jit" | sed 's/[^0-9.]//g')
    fi
    
    if [[ -z "$aot_clean" || -z "$jit_clean" || "$aot_clean" == "0" || "$jit_clean" == "0" ]]; then
        echo "-|-"
        return
    fi
    
    # Calculate difference percentage and determine winner
    local result=$(python3 -c "
aot = $aot_clean
jit = $jit_clean
if '$metric_type' == 'higher_better':
    if aot > jit:
        improvement = ((aot - jit) / jit) * 100
        print(f'AOT|+{improvement:.1f}%')
    elif jit > aot:
        improvement = ((jit - aot) / aot) * 100
        print(f'JIT|+{improvement:.1f}%')
    else:
        print('Tie|0.0%')
else:  # lower_better
    if aot < jit:
        improvement = ((jit - aot) / jit) * 100
        print(f'AOT|-{improvement:.1f}%')
    elif jit < aot:
        improvement = ((aot - jit) / aot) * 100
        print(f'JIT|-{improvement:.1f}%')
    else:
        print('Tie|0.0%')
")
    echo "$result"
}

echo "Generating comparison report..."

# Read AOT Metrics (with error handling)
if [ -f "${REPORT_DIR}/k6_report_aot.txt" ]; then
    AOT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 2)
    AOT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 3)
    AOT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 2 | sed 's/avg=//')
    AOT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 7 | sed 's/p(95)=//')
    AOT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 2)
    AOT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 3)
    AOT_FAILURES=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_failed" 4)
    AOT_FAILURE_RATE=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_failed" 2)
else
    echo "⚠️  Warning: AOT K6 report not found, using N/A values"
    AOT_REQS="N/A"
    AOT_THROUGHPUT="N/A"
    AOT_AVG_LATENCY="N/A"
    AOT_P95_LATENCY="N/A"
    AOT_DATA="N/A"
    AOT_DATA_UNIT=""
    AOT_FAILURES="N/A"
    AOT_FAILURE_RATE="N/A"
fi

if [ -f "${REPORT_DIR}/cicd_report_aot.txt" ]; then
    AOT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Build Time")
    AOT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Push Time")
    AOT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "K8s Deployment Time")
    AOT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Image Size")
else
    echo "⚠️  Warning: AOT CI/CD report not found, using N/A values"
    AOT_BUILD_TIME="N/A"
    AOT_PUSH_TIME="N/A"
    AOT_DEPLOY_TIME="N/A"
    AOT_IMAGE_SIZE="N/A"
fi
AOT_STARTUP_TIME=$(cat "${REPORT_DIR}/startup_time_aot.txt" 2>/dev/null || echo "N/A")

# Read JIT Metrics (with error handling)
if [ -f "${REPORT_DIR}/k6_report_jit.txt" ]; then
    JIT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 2)
    JIT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 3)
    JIT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 2 | sed 's/avg=//')
    JIT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 7 | sed 's/p(95)=//')
    JIT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 2)
    JIT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 3)
    JIT_FAILURES=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_failed" 4)
    JIT_FAILURE_RATE=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_failed" 2)
else
    echo "⚠️  Warning: JIT K6 report not found, using N/A values"
    JIT_REQS="N/A"
    JIT_THROUGHPUT="N/A"
    JIT_AVG_LATENCY="N/A"
    JIT_P95_LATENCY="N/A"
    JIT_DATA="N/A"
    JIT_DATA_UNIT=""
    JIT_FAILURES="N/A"
    JIT_FAILURE_RATE="N/A"
fi

if [ -f "${REPORT_DIR}/cicd_report_jit.txt" ]; then
    JIT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Build Time")
    JIT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Push Time")
    JIT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "K8s Deployment Time")
    JIT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Image Size")
else
    echo "⚠️  Warning: JIT CI/CD report not found, using N/A values"
    JIT_BUILD_TIME="N/A"
    JIT_PUSH_TIME="N/A"
    JIT_DEPLOY_TIME="N/A"
    JIT_IMAGE_SIZE="N/A"
fi
JIT_STARTUP_TIME=$(cat "${REPORT_DIR}/startup_time_jit.txt" 2>/dev/null || echo "N/A")

# Calculate Comparisons (higher is better)
CMP_REQS=$(calc_comparison "$AOT_REQS" "$JIT_REQS" "higher_better")
CMP_THROUGHPUT=$(calc_comparison "$AOT_THROUGHPUT" "$JIT_THROUGHPUT" "higher_better")
CMP_DATA=$(calc_comparison "$AOT_DATA" "$JIT_DATA" "higher_better")

# Calculate Comparisons (lower is better)
CMP_AVG_LATENCY=$(calc_comparison "$AOT_AVG_LATENCY" "$JIT_AVG_LATENCY" "lower_better")
CMP_P95_LATENCY=$(calc_comparison "$AOT_P95_LATENCY" "$JIT_P95_LATENCY" "lower_better")
CMP_FAILURES=$(calc_comparison "$AOT_FAILURES" "$JIT_FAILURES" "lower_better")
CMP_BUILD_TIME=$(calc_comparison "$AOT_BUILD_TIME" "$JIT_BUILD_TIME" "lower_better")
CMP_IMAGE_SIZE=$(calc_comparison "$AOT_IMAGE_SIZE" "$JIT_IMAGE_SIZE" "lower_better")
CMP_PUSH_TIME=$(calc_comparison "$AOT_PUSH_TIME" "$JIT_PUSH_TIME" "lower_better")
CMP_DEPLOY_TIME=$(calc_comparison "$AOT_DEPLOY_TIME" "$JIT_DEPLOY_TIME" "lower_better")
CMP_STARTUP_TIME=$(calc_comparison "$AOT_STARTUP_TIME" "$JIT_STARTUP_TIME" "lower_better")

# Extract winner and improvement from comparison results
WIN_REQS=$(echo "$CMP_REQS" | cut -d'|' -f1)
IMP_REQS=$(echo "$CMP_REQS" | cut -d'|' -f2)
WIN_THROUGHPUT=$(echo "$CMP_THROUGHPUT" | cut -d'|' -f1)
IMP_THROUGHPUT=$(echo "$CMP_THROUGHPUT" | cut -d'|' -f2)
WIN_AVG_LATENCY=$(echo "$CMP_AVG_LATENCY" | cut -d'|' -f1)
IMP_AVG_LATENCY=$(echo "$CMP_AVG_LATENCY" | cut -d'|' -f2)
WIN_P95_LATENCY=$(echo "$CMP_P95_LATENCY" | cut -d'|' -f1)
IMP_P95_LATENCY=$(echo "$CMP_P95_LATENCY" | cut -d'|' -f2)
WIN_FAILURES=$(echo "$CMP_FAILURES" | cut -d'|' -f1)
IMP_FAILURES=$(echo "$CMP_FAILURES" | cut -d'|' -f2)
WIN_DATA=$(echo "$CMP_DATA" | cut -d'|' -f1)
IMP_DATA=$(echo "$CMP_DATA" | cut -d'|' -f2)
WIN_BUILD_TIME=$(echo "$CMP_BUILD_TIME" | cut -d'|' -f1)
IMP_BUILD_TIME=$(echo "$CMP_BUILD_TIME" | cut -d'|' -f2)
WIN_IMAGE_SIZE=$(echo "$CMP_IMAGE_SIZE" | cut -d'|' -f1)
IMP_IMAGE_SIZE=$(echo "$CMP_IMAGE_SIZE" | cut -d'|' -f2)
WIN_PUSH_TIME=$(echo "$CMP_PUSH_TIME" | cut -d'|' -f1)
IMP_PUSH_TIME=$(echo "$CMP_PUSH_TIME" | cut -d'|' -f2)
WIN_DEPLOY_TIME=$(echo "$CMP_DEPLOY_TIME" | cut -d'|' -f1)
IMP_DEPLOY_TIME=$(echo "$CMP_DEPLOY_TIME" | cut -d'|' -f2)
WIN_STARTUP_TIME=$(echo "$CMP_STARTUP_TIME" | cut -d'|' -f1)
IMP_STARTUP_TIME=$(echo "$CMP_STARTUP_TIME" | cut -d'|' -f2)

# Add emojis to winners
add_winner_emoji() {
    local winner=$1
    case $winner in
        "AOT") echo "🏆 AOT" ;;
        "JIT") echo "🥈 JIT" ;;
        "Tie") echo "🤝 Tie" ;;
        *) echo "$winner" ;;
    esac
}

# Add visual indicators to improvements
add_improvement_indicator() {
    local improvement=$1
    if [[ $improvement == +* ]]; then
        echo "⬆️ $improvement"
    elif [[ $improvement == -* ]]; then
        echo "⬇️ $improvement"
    elif [[ $improvement == "0.0%" ]]; then
        echo "➡️ $improvement"
    else
        echo "$improvement"
    fi
}

# Apply formatting
WIN_REQS_EMOJI=$(add_winner_emoji "$WIN_REQS")
IMP_REQS_ICON=$(add_improvement_indicator "$IMP_REQS")
WIN_THROUGHPUT_EMOJI=$(add_winner_emoji "$WIN_THROUGHPUT")
IMP_THROUGHPUT_ICON=$(add_improvement_indicator "$IMP_THROUGHPUT")
WIN_AVG_LATENCY_EMOJI=$(add_winner_emoji "$WIN_AVG_LATENCY")
IMP_AVG_LATENCY_ICON=$(add_improvement_indicator "$IMP_AVG_LATENCY")
WIN_P95_LATENCY_EMOJI=$(add_winner_emoji "$WIN_P95_LATENCY")
IMP_P95_LATENCY_ICON=$(add_improvement_indicator "$IMP_P95_LATENCY")
WIN_FAILURES_EMOJI=$(add_winner_emoji "$WIN_FAILURES")
IMP_FAILURES_ICON=$(add_improvement_indicator "$IMP_FAILURES")
WIN_DATA_EMOJI=$(add_winner_emoji "$WIN_DATA")
IMP_DATA_ICON=$(add_improvement_indicator "$IMP_DATA")
WIN_BUILD_TIME_EMOJI=$(add_winner_emoji "$WIN_BUILD_TIME")
IMP_BUILD_TIME_ICON=$(add_improvement_indicator "$IMP_BUILD_TIME")
WIN_IMAGE_SIZE_EMOJI=$(add_winner_emoji "$WIN_IMAGE_SIZE")
IMP_IMAGE_SIZE_ICON=$(add_improvement_indicator "$IMP_IMAGE_SIZE")
WIN_PUSH_TIME_EMOJI=$(add_winner_emoji "$WIN_PUSH_TIME")
IMP_PUSH_TIME_ICON=$(add_improvement_indicator "$IMP_PUSH_TIME")
WIN_DEPLOY_TIME_EMOJI=$(add_winner_emoji "$WIN_DEPLOY_TIME")
IMP_DEPLOY_TIME_ICON=$(add_improvement_indicator "$IMP_DEPLOY_TIME")
WIN_STARTUP_TIME_EMOJI=$(add_winner_emoji "$WIN_STARTUP_TIME")
IMP_STARTUP_TIME_ICON=$(add_improvement_indicator "$IMP_STARTUP_TIME")

# Generate Markdown
cat <<EOF > "${OUTPUT_FILE}"
# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (Ahead-of-Time, GraalVM Native Image) and **JIT** (Just-in-Time, JVM) versions of the application based on the latest k6 load test results.

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM Native Image) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | ${AOT_REQS} | ${JIT_REQS} | ${WIN_REQS_EMOJI} | ${IMP_REQS_ICON} |
| **⚡ Throughput** | ${AOT_THROUGHPUT} | ${JIT_THROUGHPUT} | ${WIN_THROUGHPUT_EMOJI} | ${IMP_THROUGHPUT_ICON} |
| **⏱️ Avg Response Time** | ${AOT_AVG_LATENCY} | ${JIT_AVG_LATENCY} | ${WIN_AVG_LATENCY_EMOJI} | ${IMP_AVG_LATENCY_ICON} |
| **📈 p95 Response Time** | ${AOT_P95_LATENCY} | ${JIT_P95_LATENCY} | ${WIN_P95_LATENCY_EMOJI} | ${IMP_P95_LATENCY_ICON} |
| **❌ Failure Count** | ${AOT_FAILURES} | ${JIT_FAILURES} | ${WIN_FAILURES_EMOJI} | ${IMP_FAILURES_ICON} |
| **📦 Data Received** | ${AOT_DATA} ${AOT_DATA_UNIT} | ${JIT_DATA} ${JIT_DATA_UNIT} | ${WIN_DATA_EMOJI} | ${IMP_DATA_ICON} |
| **🔨 Docker Build Time** | ${AOT_BUILD_TIME} | ${JIT_BUILD_TIME} | ${WIN_BUILD_TIME_EMOJI} | ${IMP_BUILD_TIME_ICON} |
| **💾 Docker Image Size** | ${AOT_IMAGE_SIZE} | ${JIT_IMAGE_SIZE} | ${WIN_IMAGE_SIZE_EMOJI} | ${IMP_IMAGE_SIZE_ICON} |
| **📤 Docker Push Time** | ${AOT_PUSH_TIME} | ${JIT_PUSH_TIME} | ${WIN_PUSH_TIME_EMOJI} | ${IMP_PUSH_TIME_ICON} |
| **☸️ K8s Deployment Time** | ${AOT_DEPLOY_TIME} | ${JIT_DEPLOY_TIME} | ${WIN_DEPLOY_TIME_EMOJI} | ${IMP_DEPLOY_TIME_ICON} |
| **🚦 Pod Startup Time** | ${AOT_STARTUP_TIME} ms | ${JIT_STARTUP_TIME} ms | ${WIN_STARTUP_TIME_EMOJI} | ${IMP_STARTUP_TIME_ICON} |

---

## 🔑 Key Findings

### 🏆 Performance Metrics
1. **⚡ Throughput**: AOT achieved **${AOT_THROUGHPUT}** vs JIT **${JIT_THROUGHPUT}**
   - Winner: **${WIN_THROUGHPUT}** with **${IMP_THROUGHPUT}** improvement

2. **⏱️ Latency**: AOT Avg Latency **${AOT_AVG_LATENCY}** vs JIT **${JIT_AVG_LATENCY}**
   - Winner: **${WIN_AVG_LATENCY}** with **${IMP_AVG_LATENCY}** improvement

3. **✅ Reliability**: AOT had **${AOT_FAILURES}** failures vs JIT **${JIT_FAILURES}** failures
   - Winner: **${WIN_FAILURES}** with **${IMP_FAILURES}** improvement

### 📦 Deployment Metrics
4. **💾 Image Size**: AOT **${AOT_IMAGE_SIZE}** vs JIT **${JIT_IMAGE_SIZE}**
   - Winner: **${WIN_IMAGE_SIZE}** with **${IMP_IMAGE_SIZE}** improvement

5. **🚦 Startup Time**: AOT **${AOT_STARTUP_TIME} ms** vs JIT **${JIT_STARTUP_TIME} ms**
   - Winner: **${WIN_STARTUP_TIME}** with **${IMP_STARTUP_TIME}** improvement

---

## 📌 Legend
- 🏆 = Winner (Best Performance)
- 🥈 = Second Place
- 🤝 = Tie (Equal Performance)
- ⬆️ = Higher is better (increase)
- ⬇️ = Lower is better (decrease)
- ➡️ = No change

---

*🤖 Generated automatically by scripts/reporting/generate_report.sh*
EOF

echo "Report generated at ${OUTPUT_FILE}"
