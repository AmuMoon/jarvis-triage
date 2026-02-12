#!/bin/bash
# Phase 2: Voice Command Parser
# Parse voice commands for Jarvis Triage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse input
INPUT="$1"
CONTEXT="${2:-decision}"  # decision, approval, navigation

if [[ -z "$INPUT" ]]; then
    echo "Usage: $0 '<voice command>' [context]"
    echo ""
    echo "Examples:"
    echo "  $0 '选A' decision"
    echo "  $0 '确认执行' approval"
    echo "  $0 '下一个' navigation"
    exit 1
fi

# Normalize input (remove punctuation, keep original case for CJK)
# Note: Chinese doesn't have case, English will be matched case-insensitively
NORMALIZED=$(echo "$INPUT" | sed 's/[，。！？.,!?]//g')

echo "Input: $INPUT"
echo "Normalized: $NORMALIZED"
echo "Context: $CONTEXT"
echo ""

# Decision commands
parse_decision() {
    # Convert to lowercase for English matching
    local lower=$(echo "$NORMALIZED" | tr '[:upper:]' '[:lower:]')
    
    case "$NORMALIZED" in
        # Option A (Chinese + English)
        "选A"|"选择A"|"A"|"选项一"|"第一个"|"第一个选项")
            echo '{"action": "select", "option": "A", "confidence": "high"}'
            return 0
            ;;
    esac
    
    case "$lower" in
        # Option A (English variants)
        "option a"|"first"|"a")
            echo '{"action": "select", "option": "A", "confidence": "high"}'
            return 0
            ;;
        # Option B (English variants)
        "option b"|"second"|"b")
            echo '{"action": "select", "option": "B", "confidence": "high"}'
            return 0
            ;;
        # Option C (English variants)
        "option c"|"third"|"c")
            echo '{"action": "select", "option": "C", "confidence": "high"}'
            return 0
            ;;
    esac
    
    # Check for Chinese Option A, B and C using pattern matching
    # Handle UTF-8 encoding issues by checking for character presence
    if echo "$INPUT" | grep -qE "(选|選).*[Aa]|[Aa].*(选|選)|选项一|第一|option a|^a$"; then
        echo '{"action": "select", "option": "A", "confidence": "high"}'
        return 0
    fi
    
    if echo "$INPUT" | grep -qE "(选|選).*[Bb]|[Bb].*(选|選)|选项二|第二|option b|^b$"; then
        echo '{"action": "select", "option": "B", "confidence": "high"}'
        return 0
    fi
    
    if echo "$INPUT" | grep -qE "(选|選).*[Cc]|[Cc].*(选|選)|选项三|第三|option c|^c$"; then
        echo '{"action": "select", "option": "C", "confidence": "high"}'
        return 0
    fi
    
    return 1
}

# Approval commands
parse_approval() {
    case "$NORMALIZED" in
        "approve"|"确认"|"执行"|"可以"|"ok"|"好的"|"没问题"|"就这么办"|"行"|"yes")
            echo '{"action": "approve", "confidence": "high"}'
            return 0
            ;;
        "reject"|"取消"|"否决"|"不行"|"不要"|"否"|"no"|"算了")
            echo '{"action": "reject", "confidence": "high"}'
            return 0
            ;;
    esac
    return 1
}

# Navigation commands
parse_navigation() {
    case "$NORMALIZED" in
        "next"|"下一个"|"继续"|"下一步"|"往下"|"forward")
            echo '{"action": "next", "confidence": "high"}'
            return 0
            ;;
        "back"|"上一个"|"返回"|"上一步"|"回去"|"backward")
            echo '{"action": "back", "confidence": "high"}'
            return 0
            ;;
        "repeat"|"重复"|"再说一遍"|"没听清"|"重新说")
            echo '{"action": "repeat", "confidence": "high"}'
            return 0
            ;;
        "detail"|"详细"|"展开"|"详细信息"|"更多细节")
            echo '{"action": "detail", "confidence": "high"}'
            return 0
            ;;
    esac
    return 1
}

# Combo commands (multiple actions)
parse_combo() {
    # "选A，继续" -> select A + next
    if [[ "$NORMALIZED" =~ ^(选[a-c]|选择[a-c]|[a-c])(，|,?)(继续|下一步|next|确认|执行|approve)$ ]]; then
        local option=$(echo "$NORMALIZED" | grep -oE '[abc]' | head -1 | tr '[:lower:]' '[:upper:]')
        local second_action=$(echo "$NORMALIZED" | grep -oE '(继续|下一步|next|确认|执行|approve)' | tail -1)
        
        local action2="next"
        case "$second_action" in
            "确认"|"执行"|"approve") action2="approve" ;;
        esac
        
        echo "{\"action\": \"combo\", \"actions\": [{\"type\": \"select\", \"option\": \"$option\"}, {\"type\": \"$action2\"}], \"confidence\": \"high\"}"
        return 0
    fi
    
    return 1
}

# Main parsing logic
echo -e "${BLUE}[Voice Parser]${NC} Analyzing command..."
echo ""

# Try combo commands first
if parse_combo; then
    exit 0
fi

# Try context-specific parsing
case "$CONTEXT" in
    "decision")
        if parse_decision; then
            exit 0
        fi
        if parse_approval; then
            exit 0
        fi
        ;;
    "approval")
        if parse_approval; then
            exit 0
        fi
        ;;
    "navigation")
        if parse_navigation; then
            exit 0
        fi
        ;;
esac

# Try all parsers as fallback
if parse_decision; then
    exit 0
elif parse_approval; then
    exit 0
elif parse_navigation; then
    exit 0
fi

# Unknown command
echo -e "${YELLOW}{\"action\": \"unknown\", \"confidence\": \"low\", \"input\": \"$INPUT\"}${NC}"
exit 1
