#!/bin/bash
# ============================================================================
# Performance Report Generator
#
# Generates a Markdown comparison report (AOT vs JIT) by parsing:
# 1. K6 Load Test Reports (report/k6_report_*.txt)
# 2. CI/CD Metrics (report/cicd_report_*.txt)
# 3. Startup Time Logs (report/startup_time_*.txt)
# ============================================================================

REPORT_DIR="./report"
OUTPUT_FILE="${REPORT_DIR}/aot_vs_jit.md"

# --- Utility Functions ---

# Extracts a specific metric from a K6 stdout text file
# Usage: get_k6_metric <file> <metric_name> <awk_field_index>
# Extracts a specific metric from a K6 stdout text file
# Usage: get_k6_metric <file> <metric_name> <awk_field_index>
get_k6_metric() {
    local file=$1
    local metric=$2
    local field=$3
    # Remove checkmarks/crosses to normalize field positions
    sed 's/[✓✗]//g' "${file}" | grep "${metric}" | awk -v f="$field" '{print $f}'
}

# Extracts a metric key-value pair from the Custom CI/CD text file
# Usage: get_cicd_metric <file> <key_string>
get_cicd_metric() {
    local file=$1
    local key=$2
    grep "${key}" "${file}" | awk -F': ' '{print $2}' | tr -d '\n'
}

# Normalizes various time units (s, ms, µs, m) to a unified number for comparison
normalize_time() {
    local value=$1
    if [[ $value =~ ([0-9.]+)(ms|s|µs|m) ]]; then
        local num="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"
        case $unit in
            µs) python3 -c "print($num / 1000)" ;;
            ms) echo "$num" ;;
            s)  python3 -c "print($num * 1000)" ;;
            m)  python3 -c "print($num * 60000)" ;;
            *)  echo "$num" ;;
        esac
    else
        echo "$value" | sed 's/[^0-9.]//g'
    fi
}

# Compares two values and formats the output string: "WINNER_NAME|PCT_IMPROVEMENT"
# Usage: calc_comparison <aot_val> <jit_val> <higher_better|lower_better>
calc_comparison() {
    local aot=$1
    local jit=$2
    local metric_type=$3
    
    # Normalize inputs if they resemble time strings
    if [[ $aot =~ (ms|s|µs|m)$ ]] || [[ $jit =~ (ms|s|µs|m)$ ]]; then
        local aot_clean=$(normalize_time "$aot")
        local jit_clean=$(normalize_time "$jit")
    else
        local aot_clean=$(echo "$aot" | sed 's/[^0-9.]//g')
        local jit_clean=$(echo "$jit" | sed 's/[^0-9.]//g')
    fi

    # Validation: Ensure they are valid numbers (not just dots)
    if [[ ! "$aot_clean" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then aot_clean="0"; fi
    if [[ ! "$jit_clean" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then jit_clean="0"; fi
    
    # Handle missing/zero data
    if [[ -z "$aot_clean" || -z "$jit_clean" || "$aot_clean" == "0" || "$jit_clean" == "0" ]]; then
        echo "-|-"
        return
    fi
    
    # Calculate delta percentage using Python for floating-point precision
    python3 -c "
aot = $aot_clean
jit = $jit_clean
type = '$metric_type'

# Determine Winner
diff = 0
winner = 'Tie'
pct = 0.0

if aot != jit:
    if type == 'higher_better':
        if aot > jit:
            winner = 'AOT'
            pct = ((aot - jit) / jit) * 100
        else:
            winner = 'JIT'
            pct = ((jit - aot) / aot) * 100
    else: # lower_better
        if aot < jit:
            winner = 'AOT'
            pct = ((jit - aot) / jit) * 100
        else:
            winner = 'JIT'
            pct = ((aot - jit) / aot) * 100

symbol = '+' if type == 'higher_better' else '-'
print(f'{winner}|{symbol}{pct:.1f}%')
"
}

echo "📝 Generting comparison report..."

# --- 1. Data Collection ---

# AOT Metrics extraction
if [ -f "${REPORT_DIR}/k6_report_aot.txt" ]; then
    AOT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 2)
    AOT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_reqs" 3)
    AOT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 2 | sed 's/avg=//')
    AOT_MED_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 4 | sed 's/med=//')
    AOT_MAX_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 5 | sed 's/max=//')
    AOT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_duration" 7 | sed 's/p(95)=//')
    AOT_FAILURES=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "http_req_failed" 2)
    AOT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 2)
    AOT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "data_received" 3)
    
    # Extract Test Config from AOT report (assuming same for JIT)
    TEST_VUS=$(get_k6_metric "${REPORT_DIR}/k6_report_aot.txt" "vus_max" 2 | sed 's/min=//' | head -1)
    TEST_DURATION="10s" # Hardcoded based on script, or could be parsed
else
    AOT_REQS="N/A"
    AOT_THROUGHPUT="N/A"
    AOT_AVG_LATENCY="N/A"
    AOT_MED_LATENCY="N/A"
    AOT_MAX_LATENCY="N/A"
    AOT_P95_LATENCY="N/A"
    AOT_FAILURES="N/A"
    AOT_DATA="N/A"
    TEST_VUS="N/A"
    TEST_DURATION="N/A"
fi

if [ -f "${REPORT_DIR}/cicd_report_aot.txt" ]; then
    AOT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Build Time")
    AOT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Push Time")
    AOT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "K8s Deployment Time")
    AOT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_aot.txt" "Docker Image Size")
else
    AOT_BUILD_TIME="N/A"
    AOT_PUSH_TIME="N/A"
    AOT_DEPLOY_TIME="N/A"
    AOT_IMAGE_SIZE="N/A"
fi
AOT_STARTUP_TIME=$(cat "${REPORT_DIR}/startup_time_aot.txt" 2>/dev/null || echo "N/A")

# JIT Metrics extraction
if [ -f "${REPORT_DIR}/k6_report_jit.txt" ]; then
    JIT_REQS=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 2)
    JIT_THROUGHPUT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_reqs" 3)
    JIT_AVG_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 2 | sed 's/avg=//')
    JIT_MED_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 4 | sed 's/med=//')
    JIT_MAX_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 5 | sed 's/max=//')
    JIT_P95_LATENCY=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_duration" 7 | sed 's/p(95)=//')
    JIT_FAILURES=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "http_req_failed" 2)
    JIT_DATA=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 2)
    JIT_DATA_UNIT=$(get_k6_metric "${REPORT_DIR}/k6_report_jit.txt" "data_received" 3)
else
    JIT_REQS="N/A"
    JIT_THROUGHPUT="N/A"
    JIT_AVG_LATENCY="N/A"
    JIT_MED_LATENCY="N/A"
    JIT_MAX_LATENCY="N/A"
    JIT_P95_LATENCY="N/A"
    JIT_FAILURES="N/A"
    JIT_DATA="N/A"
fi

if [ -f "${REPORT_DIR}/cicd_report_jit.txt" ]; then
    JIT_BUILD_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Build Time")
    JIT_PUSH_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Push Time")
    JIT_DEPLOY_TIME=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "K8s Deployment Time")
    JIT_IMAGE_SIZE=$(get_cicd_metric "${REPORT_DIR}/cicd_report_jit.txt" "Docker Image Size")
else
    JIT_BUILD_TIME="N/A"
    JIT_PUSH_TIME="N/A"
    JIT_DEPLOY_TIME="N/A"
    JIT_IMAGE_SIZE="N/A"
fi
JIT_STARTUP_TIME=$(cat "${REPORT_DIR}/startup_time_jit.txt" 2>/dev/null || echo "N/A")

# ... [Comparisons] ...
CMP_MAX_LATENCY=$(calc_comparison "$AOT_MAX_LATENCY" "$JIT_MAX_LATENCY" "lower_better")
CMP_REQS=$(calc_comparison "$AOT_REQS" "$JIT_REQS" "higher_better")
CMP_THROUGHPUT=$(calc_comparison "$AOT_THROUGHPUT" "$JIT_THROUGHPUT" "higher_better")
CMP_DATA=$(calc_comparison "$AOT_DATA" "$JIT_DATA" "higher_better")
CMP_AVG_LATENCY=$(calc_comparison "$AOT_AVG_LATENCY" "$JIT_AVG_LATENCY" "lower_better")
CMP_MED_LATENCY=$(calc_comparison "$AOT_MED_LATENCY" "$JIT_MED_LATENCY" "lower_better")
CMP_P95_LATENCY=$(calc_comparison "$AOT_P95_LATENCY" "$JIT_P95_LATENCY" "lower_better")
CMP_FAILURES=$(calc_comparison "$AOT_FAILURES" "$JIT_FAILURES" "lower_better")
CMP_BUILD_TIME=$(calc_comparison "$AOT_BUILD_TIME" "$JIT_BUILD_TIME" "lower_better")
CMP_IMAGE_SIZE=$(calc_comparison "$AOT_IMAGE_SIZE" "$JIT_IMAGE_SIZE" "lower_better")
CMP_PUSH_TIME=$(calc_comparison "$AOT_PUSH_TIME" "$JIT_PUSH_TIME" "lower_better")
CMP_DEPLOY_TIME=$(calc_comparison "$AOT_DEPLOY_TIME" "$JIT_DEPLOY_TIME" "lower_better")
CMP_STARTUP_TIME=$(calc_comparison "$AOT_STARTUP_TIME" "$JIT_STARTUP_TIME" "lower_better")

# Helper: Parse winner string "WINNER|IMPROVEMENT"
get_win() { echo "$1" | cut -d'|' -f1; }
get_imp() { echo "$1" | cut -d'|' -f2; }

# Helper: Visual Logic
fmt_winner() {
    case "$1" in
        "AOT") echo "🏆 AOT" ;;
        "JIT") echo "🥈 JIT" ;;
        "Tie") echo "🤝 Tie" ;;
        *) echo "$1" ;;
    esac
}

fmt_imp() {
    local val=$1
    if [[ $val == +* ]]; then echo "⬆️ $val";
    elif [[ $val == -* ]]; then echo "⬇️ $val";
    else echo "➡️ $val"; fi
}

# --- 3. Report Generation ---
cat <<EOF > "${OUTPUT_FILE}"
# 📊 Performance Comparison: AOT vs JIT

## 📋 Overview
This report compares the performance of the **AOT** (GraalVM Native Image) and **JIT** (JVM) versions based on the latest k6 load test results.

**🧪 Test Configuration:**
- **Virtual Users:** ${TEST_VUS} (Simulated concurrent users)
- **Duration:** ${TEST_DURATION}
- **Tool:** k6 Load Testing

---

## 🎯 Metrics Comparison

| Metric | AOT (GraalVM) | JIT (JVM) | Winner | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **🚀 Total Requests** | ${AOT_REQS} | ${JIT_REQS} | $(fmt_winner "$(get_win "$CMP_REQS")") | $(fmt_imp "$(get_imp "$CMP_REQS")") |
| **⚡ Throughput** | ${AOT_THROUGHPUT} | ${JIT_THROUGHPUT} | $(fmt_winner "$(get_win "$CMP_THROUGHPUT")") | $(fmt_imp "$(get_imp "$CMP_THROUGHPUT")") |
| **⏱️ Avg Response** | ${AOT_AVG_LATENCY} | ${JIT_AVG_LATENCY} | $(fmt_winner "$(get_win "$CMP_AVG_LATENCY")") | $(fmt_imp "$(get_imp "$CMP_AVG_LATENCY")") |
| **🎯 Median Response** | ${AOT_MED_LATENCY} | ${JIT_MED_LATENCY} | $(fmt_winner "$(get_win "$CMP_MED_LATENCY")") | $(fmt_imp "$(get_imp "$CMP_MED_LATENCY")") |
| **📉 p95 Response** | ${AOT_P95_LATENCY} | ${JIT_P95_LATENCY} | $(fmt_winner "$(get_win "$CMP_P95_LATENCY")") | $(fmt_imp "$(get_imp "$CMP_P95_LATENCY")") |
| **💥 Max Response** | ${AOT_MAX_LATENCY} | ${JIT_MAX_LATENCY} | $(fmt_winner "$(get_win "$CMP_MAX_LATENCY")") | $(fmt_imp "$(get_imp "$CMP_MAX_LATENCY")") |
| **📦 Data Received** | ${AOT_DATA} ${AOT_DATA_UNIT} | ${JIT_DATA} ${JIT_DATA_UNIT} | $(fmt_winner "$(get_win "$CMP_DATA")") | $(fmt_imp "$(get_imp "$CMP_DATA")") |
| **❌ Failure Rate** | ${AOT_FAILURES} | ${JIT_FAILURES} | $(fmt_winner "$(get_win "$CMP_FAILURES")") | $(fmt_imp "$(get_imp "$CMP_FAILURES")") |
| **🔨 Build Time** | ${AOT_BUILD_TIME} | ${JIT_BUILD_TIME} | $(fmt_winner "$(get_win "$CMP_BUILD_TIME")") | $(fmt_imp "$(get_imp "$CMP_BUILD_TIME")") |
| **💾 Image Size** | ${AOT_IMAGE_SIZE} | ${JIT_IMAGE_SIZE} | $(fmt_winner "$(get_win "$CMP_IMAGE_SIZE")") | $(fmt_imp "$(get_imp "$CMP_IMAGE_SIZE")") |
| **🚦 Startup Time** | ${AOT_STARTUP_TIME} ms | ${JIT_STARTUP_TIME} ms | $(fmt_winner "$(get_win "$CMP_STARTUP_TIME")") | $(fmt_imp "$(get_imp "$CMP_STARTUP_TIME")") |

---

## 🔑 Key Takeaways

1. **Throughput**: $(get_win "$CMP_THROUGHPUT") is faster by $(get_imp "$CMP_THROUGHPUT")
2. **Startup**: $(get_win "$CMP_STARTUP_TIME") starts faster by $(get_imp "$CMP_STARTUP_TIME")
3. **Efficiency**: $(get_win "$CMP_IMAGE_SIZE") has a $(get_imp "$CMP_IMAGE_SIZE") smaller Docker image.

EOF

echo "✅ Report ready: ${OUTPUT_FILE}"
