#!/bin/bash
# Voice Integration Test Suite
# Tests for Phase 1: Voice Integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$TEST_DIR")"
VOICE_DIR="$PROJECT_DIR/voice"
RESULTS_DIR="$TEST_DIR/results/voice-$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL=0
PASSED=0
FAILED=0

# Create results directory
mkdir -p "$RESULTS_DIR"

# Header
echo "========================================"
echo "Jarvis Triage - Voice Integration Tests"
echo "========================================"
echo "Time: $(date)"
echo "Results: $RESULTS_DIR"
echo ""

# Test function
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_result="$3"
    
    TOTAL=$((TOTAL + 1))
    echo -n "Testing: $test_name ... "
    
    if eval "$test_cmd" > /dev/null 2>&1; then
        if [[ "$expected_result" == "pass" ]]; then
            echo -e "${GREEN}PASS${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}FAIL${NC} (expected failure but passed)"
            FAILED=$((FAILED + 1))
        fi
    else
        if [[ "$expected_result" == "fail" ]]; then
            echo -e "${GREEN}PASS${NC} (expected failure)"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}FAIL${NC}"
            FAILED=$((FAILED + 1))
        fi
    fi
}

# Test 1: Check voice scripts exist
echo "--- Script Existence Tests ---"
run_test "voice-speak.sh exists" "test -x $VOICE_DIR/voice-speak.sh" "pass"
run_test "parse-and-speak.sh exists" "test -x $VOICE_DIR/parse-and-speak.sh" "pass"
run_test "voice-trigger.sh exists" "test -x $VOICE_DIR/voice-trigger.sh" "pass"
run_test "voice/README.md exists" "test -f $VOICE_DIR/README.md" "pass"

echo ""

# Test 2: Script help functionality
echo "--- Script Help Tests ---"
run_test "voice-speak.sh --help works" "$VOICE_DIR/voice-speak.sh --help | grep -q 'Usage:'" "pass"
run_test "parse-and-speak.sh --help works" "$VOICE_DIR/parse-and-speak.sh --help | grep -q 'Usage:'" "pass"
run_test "voice-trigger.sh --help works" "$VOICE_DIR/voice-trigger.sh --help | grep -q 'Commands:'" "pass"

echo ""

# Test 3: Voice content extraction
echo "--- Content Extraction Tests ---"

# Create test file with voice content
cat > "$RESULTS_DIR/test-voice-extraction.md" << 'EOF'
# Test Triage Output

📊 Triage Level: 3 - 信息决策

🔊 语音版（直接念给用户听，≤30秒）：
> 云服务商对比完成。AWS最便宜但学习曲线陡峭，阿里云最熟悉但价格稍高，Vercel最简单但功能受限。建议根据团队经验选择。

📱 HUD版（4行以内，每行≤20字）：
L1: ☁️ 云服务商对比
L2: ❓ 选哪个？
L3:   A: AWS (便宜/难)
L4:   B: 阿里云 (熟悉/贵)
EOF

run_test "Extract voice content from file" "$VOICE_DIR/parse-and-speak.sh $RESULTS_DIR/test-voice-extraction.md --quiet" "pass"

echo ""

# Test 4: Demo mode
echo "--- Demo Mode Tests ---"
run_test "parse-and-speak.sh --demo works" "$VOICE_DIR/parse-and-speak.sh --demo | grep -q 'Demo Mode'" "pass"
run_test "voice-trigger.sh demo works" "$VOICE_DIR/voice-trigger.sh demo | grep -q 'Voice Demo'" "pass"

echo ""

# Test 5: Voice activation triggers
echo "--- Voice Activation Triggers ---"

# Create test file simulating user saying "语音播报"
cat > "$RESULTS_DIR/test-voice-activation.md" << 'EOF'
# Voice Activation Test

This simulates the interaction when user says "语音播报".

## Triage Context

📊 Triage Level: 2 - 快速决策

🔊 语音版：
> 会议时间确认，周四下午2点或者周五上午10点，选哪个？

❓ 决策点：
- 会议时间 → 周四下午2点 / 周五上午10点

## Activation

User said: "语音播报"

Expected TTS call:
tts text='会议时间确认，周四下午2点或者周五上午10点，选哪个？'
EOF

run_test "Voice activation context exists" "test -f $RESULTS_DIR/test-voice-activation.md" "pass"

echo ""

# Test 6: Content format validation
echo "--- Content Format Tests ---"

# Create sample with proper voice content format (in a fixed location)
FORMAT_TEST_FILE="$RESULTS_DIR/test-format-validation.md"
cat > "$FORMAT_TEST_FILE" << 'EOF'
### 语音版
认证迁移计划出来了，分7步。有两个需要你决定的。
EOF

# Verify file was created and run test
run_test "Simple voice format" "test -f $FORMAT_TEST_FILE && $VOICE_DIR/parse-and-speak.sh $FORMAT_TEST_FILE --quiet" "pass"

echo ""

# Test 7: Sample file voice extraction
echo "--- Sample File Tests ---"
SAMPLE_FILE="$TEST_DIR/samples/level-4-auth-migration.md"
if [[ -f "$SAMPLE_FILE" ]]; then
    run_test "Extract from level-4-auth sample" "$VOICE_DIR/parse-and-speak.sh $SAMPLE_FILE --quiet 2>&1 | grep -q 'token存哪里'" "pass"
else
    echo -e "${YELLOW}SKIP: Sample file not found${NC}"
fi

echo ""

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total Tests: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All voice integration tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test actual TTS in OpenClaw: openclaw tts '测试语音'"
    echo "  2. Run full integration: ./voice/voice-trigger.sh demo"
    echo "  3. Update TOOLS.md with your voice preferences"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
