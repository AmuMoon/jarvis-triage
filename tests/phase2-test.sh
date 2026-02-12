#!/bin/bash
# Phase 2 Test Suite
# Test auto-voice and voice command parsing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_DIR="$(dirname "$SCRIPT_DIR")/voice"

echo "========================================"
echo "Jarvis Triage - Phase 2 Test Suite"
echo "========================================"
echo ""

# Test counters
PASSED=0
FAILED=0

# Test auto-voice
test_auto_voice() {
    local level=$1
    local decisions=$2
    local expected=$3
    local desc=$4
    
    echo -n "Test: $desc ... "
    
    local result=$("$VOICE_DIR/auto-voice.sh" --level "$level" --decisions "$decisions" --voice-content "test" 2>&1 | head -1)
    
    if [[ "$result" == *"$expected"* ]]; then
        echo "✅ PASS"
        PASSED=$((PASSED + 1))
    else
        echo "❌ FAIL (got: $result)"
        FAILED=$((FAILED + 1))
    fi
}

# Test voice commands
test_command() {
    local input=$1
    local context=$2
    local expected_action=$3
    local desc=$4
    
    echo -n "Test: $desc ... "
    
    local result=$("$VOICE_DIR/parse-command.sh" "$input" "$context" 2>&1 | grep -o '"action": "[^"]*"' | head -1)
    
    if [[ "$result" == *"$expected_action"* ]]; then
        echo "✅ PASS"
        PASSED=$((PASSED + 1))
    else
        echo "❌ FAIL (got: $result)"
        FAILED=$((FAILED + 1))
    fi
}

echo "--- Auto-Voice Tests ---"
echo ""

test_auto_voice 4 2 "Triggering" "Level 4 + 2 decisions → Auto-voice ON"
test_auto_voice 4 1 "Skipped" "Level 4 + 1 decision → Auto-voice OFF"
test_auto_voice 3 2 "Skipped" "Level 3 + 2 decisions → Auto-voice OFF"
test_auto_voice 4 3 "Triggering" "Level 4 + 3 decisions → Auto-voice ON"

echo ""
echo "--- Voice Command Tests ---"
echo ""

test_command "选A" "decision" "select" "选择A"
test_command "B" "decision" "select" "直接说B"
test_command "选项二" "decision" "select" "选项二"
test_command "确认" "approval" "approve" "确认执行"
test_command "取消" "approval" "reject" "取消操作"
test_command "下一个" "navigation" "next" "下一个决策"
test_command "重复" "navigation" "repeat" "重复一遍"

echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️ Some tests failed"
    exit 1
fi
