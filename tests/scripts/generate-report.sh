#!/bin/bash
# Generate test report for Jarvis Triage

RESULTS_DIR="${1:-$(ls -td tests/results/*/ 2>/dev/null | head -1)}"

if [[ -z "$RESULTS_DIR" || ! -d "$RESULTS_DIR" ]]; then
    echo "Error: No results directory found."
    echo "Usage: $0 <results-directory>"
    exit 1
fi

REPORT_FILE="$RESULTS_DIR/report.md"

cat > "$REPORT_FILE" << EOF
# Jarvis Triage Test Report

**Generated**: $(date)
**Results Directory**: $RESULTS_DIR

## Summary

EOF

# 统计结果
total=$(find "$RESULTS_DIR" -name "*-result.md" | wc -l)
passed=$(grep -l "Status: PASS" "$RESULTS_DIR"/*-result.md 2>/dev/null | wc -l)
failed=$((total - passed))

cat >> "$REPORT_FILE" << EOF
| Metric | Value |
|--------|-------|
| Total Samples | $total |
| Passed | $passed |
| Failed | $failed |
| Pass Rate | $(awk "BEGIN {printf \"%.1f%%\", ($passed/$total)*100}") |

## Level Distribution

EOF

# 按 level 统计
for level in 0 1 2 3 4; do
    count=$(find "$RESULTS_DIR" -name "level-$level-*-result.md" | wc -l)
    echo "- **Level $level**: $count samples" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## Detailed Results

EOF

# 添加每个测试的详细结果
for result in "$RESULTS_DIR"/*-result.md; do
    if [[ -f "$result" ]]; then
        filename=$(basename "$result" -result.md)
        echo "### $filename" >> "$REPORT_FILE"
        cat "$result" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
done

echo "Report generated: $REPORT_FILE"
cat "$REPORT_FILE"
