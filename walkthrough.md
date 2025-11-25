# Walkthrough - Automated Report Generation

## Changes

### Scripts
#### [NEW] [compare_performance.sh](file:///Users/mrinmaysantra/Documents/Workspace/Antigravity/springboot-graalvm-lambda/sh/compare_performance.sh)
- Created a Bash script that parses the k6 and CI/CD text reports.
- Extracts key metrics: Requests, Throughput, Latency, Build Time, and Image Size.
- Generates a formatted Markdown report at `report/performance_comparison.md`.

#### [MODIFY] [run.sh](file:///Users/mrinmaysantra/Documents/Workspace/Antigravity/springboot-graalvm-lambda/run.sh)
- Updated the main execution script to call `compare_performance.sh` automatically after the AOT and JIT tasks complete.

## Verification Results

### Automated Verification
- Ran `sh/compare_performance.sh` manually to test the logic.
- **Result**: The script successfully generated `report/performance_comparison.md` with populated values from the existing report files.

### Generated Report Content
The generated report now includes a dynamic table and key findings section:
```markdown
| Metric | AOT (GraalVM Native Image) | JIT (JVM) |
| :--- | :--- | :--- |
| **Total Requests** | 28096 | 52482 |
| **Throughput** | 5616.59/s | 10494.25/s |
...
```
*(Note: The values in the verification run reflect the current state of the text files, which might differ from the initial manual analysis if tests were re-run or files changed.)*
