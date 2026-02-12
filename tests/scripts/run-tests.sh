#!/bin/bash
# Jarvis Triage Test Runner
# Phase 0.5 - Real-world testing framework

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$TEST_DIR")"
SAMPLES_DIR="$TEST_DIR/samples"
RESULTS_DIR="$TEST_DIR/results/$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认参数
LEVEL="all"
TYPE="all"
FULL_MODE=false
VERBOSE=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        --full)
            FULL_MODE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --level N       Test only level N (0-4)"
            echo "  --type TYPE     Test only specific type (new-feature, refactor, bugfix, qa)"
            echo "  --full          Run full test suite with validation"
            echo "  --verbose, -v   Show detailed output"
            echo "  --help, -h      Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 创建结果目录
mkdir -p "$RESULTS_DIR"

echo "========================================"
echo "Jarvis Triage Test Suite"
echo "========================================"
echo "Time: $(date)"
echo "Level Filter: $LEVEL"
echo "Type Filter: $TYPE"
echo "Results: $RESULTS_DIR"
echo ""

# 统计样本
TOTAL_SAMPLES=0
PASSED=0
FAILED=0

# 查找测试样本
find_samples() {
    local pattern="$SAMPLES_DIR/level-"
    if [[ "$LEVEL" != "all" ]]; then
        pattern="${pattern}${LEVEL}-*.md"
    else
        pattern="${pattern}*.md"
    fi
    
    find "$SAMPLES_DIR" -name "level-*.md" -type f 2>/dev/null | sort
}

# 运行单个测试
run_test() {
    local sample_file="$1"
    local filename=$(basename "$sample_file")
    local level=$(echo "$filename" | grep -oE 'level-[0-4]' | head -1)
    
    TOTAL_SAMPLES=$((TOTAL_SAMPLES + 1))
    
    echo -n "Testing $filename ... "
    
    # 解析样本文件
    local input_content=$(sed -n '/## 原始输入/,/## 期望输出/p' "$sample_file" | sed '1d;$d' | sed '/^$/d')
    local expected_level=$(grep -E '^\- \*\*Level\*\*:' "$sample_file" | grep -oE '[0-4]' | head -1)
    local expected_decisions=$(grep -E '^\- \*\*决策点数量\*\*:' "$sample_file" | grep -oE '[0-9]+' | head -1)
    
    # 模拟 triage 处理（实际使用时，这里会调用 OpenClaw）
    # 目前只是验证文件格式
    local result_file="$RESULTS_DIR/${filename%.md}-result.md"
    
    cat > "$result_file" << EOF
# Test Result: $filename

## 样本信息
- **File**: $sample_file
- **Expected Level**: $expected_level
- **Expected Decisions**: $expected_decisions

## 验证结果
EOF

    # 基础验证
    local errors=()
    
    if [[ -z "$input_content" ]]; then
        errors+=("Missing input content")
    fi
    
    if [[ -z "$expected_level" ]]; then
        errors+=("Missing expected level metadata")
    fi
    
    # 输出结果
    if [[ ${#errors[@]} -eq 0 ]]; then
        echo -e "${GREEN}PASS${NC}"
        echo "- Status: PASS" >> "$result_file"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "- Status: FAIL" >> "$result_file"
        for error in "${errors[@]}"; do
            echo "  - $error"
            echo "  - Error: $error" >> "$result_file"
        done
        FAILED=$((FAILED + 1))
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        echo "  Expected Level: $expected_level"
        echo "  Input Length: $(echo "$input_content" | wc -l) lines"
    fi
}

# 主测试循环
echo "Running tests..."
echo ""

samples=$(find_samples)

if [[ -z "$samples" ]]; then
    echo -e "${YELLOW}Warning: No test samples found in $SAMPLES_DIR${NC}"
    echo "Run ./scripts/generate-samples.sh to create initial samples."
    exit 0
fi

for sample in $samples; do
    run_test "$sample"
done

# 生成汇总报告
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total Samples: $TOTAL_SAMPLES"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed. Check $RESULTS_DIR for details.${NC}"
    exit 1
fi

# 生成详细报告
if [[ "$FULL_MODE" == true ]]; then
    echo ""
    echo "Generating full report..."
    "$SCRIPT_DIR/generate-report.sh" "$RESULTS_DIR"
fi
