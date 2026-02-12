#!/bin/bash
# Jarvis Triage - Parse and Speak
# Extract "语音版" content from triage output and convert to speech

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
INPUT_FILE=""
CHANNEL=""
QUIET=false
DEMO_MODE=false

print_help() {
    echo "Jarvis Triage - Parse and Speak"
    echo ""
    echo "Extract voice content from triage output and speak it."
    echo ""
    echo "Usage: parse-and-speak.sh [OPTIONS] <input_file>"
    echo "       parse-and-speak.sh --demo"
    echo ""
    echo "Options:"
    echo "  --channel, -c   Target channel for TTS"
    echo "  --demo, -d      Run demo with sample text"
    echo "  --quiet, -q     Suppress non-essential output"
    echo "  --help, -h      Show this help"
    echo ""
    echo "Examples:"
    echo "  parse-and-speak.sh ../tests/samples/level-4-auth-migration.md"
    echo "  parse-and-speak.sh triage-output.txt --channel=telegram"
    echo "  parse-and-speak.sh --demo"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --channel=*)
            CHANNEL="${1#*=}"
            shift
            ;;
        --channel|-c)
            CHANNEL="$2"
            shift 2
            ;;
        --demo|-d)
            DEMO_MODE=true
            shift
            ;;
        --quiet|-q)
            QUIET=true
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            fi
            shift
            ;;
    esac
done

# Demo mode
if [[ "$DEMO_MODE" == true ]]; then
    echo -e "${BLUE}🎙️  Demo Mode${NC}"
    echo ""
    
    DEMO_TEXT="认证迁移计划出来了，分7步。安装依赖、建JWT中间件、改登录接口、迁移数据、改前端、清理旧代码、写测试。有两个需要你决定的，一个是token存哪里，一个是刷新策略。另外数据迁移那步不可逆，执行前会先备份。"
    
    echo "Sample voice content:"
    echo "  $DEMO_TEXT"
    echo ""
    
    if command -v openclaw &> /dev/null; then
        echo -e "${GREEN}✓ OpenClaw detected - would send TTS${NC}"
        # Uncomment to actually send:
        # openclaw tts "$DEMO_TEXT"
    else
        echo -e "${YELLOW}⚠️  OpenClaw not in PATH${NC}"
        echo "In OpenClaw session, this would trigger:"
        echo "  tts text='$DEMO_TEXT'"
    fi
    exit 0
fi

# Validate input file
if [[ -z "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: No input file provided${NC}" >&2
    print_help
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: File not found: $INPUT_FILE${NC}" >&2
    exit 1
fi

# Extract voice content
# Pattern 1: "### 语音版" or "## 语音版" section
# Pattern 2: "🔊 语音版" section
# Pattern 3: Lines starting with ">" after voice marker

extract_voice_content() {
    local file="$1"
    
    # Try various patterns to extract voice content
    # Pattern 1: Markdown section header followed by content
    local content=$(sed -n '/^###* 语音版/,/^$/p' "$file" 2>/dev/null | sed '1d' | sed '/^$/d' | head -20)
    
    if [[ -n "$content" ]]; then
        echo "$content"
        return 0
    fi
    
    # Pattern 2: Blockquote format
    content=$(grep -E '^> ' "$file" 2>/dev/null | sed 's/^> //' | head -5)
    
    if [[ -n "$content" ]]; then
        echo "$content"
        return 0
    fi
    
    # Pattern 3: Simple text after marker
    content=$(grep -A 5 '🔊 语音版' "$file" 2>/dev/null | tail -n +2 | head -5)
    
    if [[ -n "$content" ]]; then
        echo "$content"
        return 0
    fi
    
    return 1
}

if [[ "$QUIET" == false ]]; then
    echo -e "${BLUE}🎙️  Parsing triage output...${NC}"
fi

VOICE_CONTENT=$(extract_voice_content "$INPUT_FILE")

if [[ -z "$VOICE_CONTENT" ]]; then
    echo -e "${RED}Error: Could not extract voice content from $INPUT_FILE${NC}" >&2
    echo "Expected markers: '### 语音版', '🔊 语音版', or blockquote '> '" >&2
    exit 1
fi

# Clean up content - remove markdown formatting
VOICE_CONTENT=$(echo "$VOICE_CONTENT" | sed 's/\*\*//g' | sed 's/__//g' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')

if [[ "$QUIET" == false ]]; then
    echo ""
    echo -e "${GREEN}✓ Extracted voice content:${NC}"
    echo "  $VOICE_CONTENT"
    echo ""
    echo -e "${BLUE}🎵 Playing...${NC}"
fi

# Call voice-speak.sh or OpenClaw TTS directly
if [[ -x "$SCRIPT_DIR/voice-speak.sh" ]]; then
    "$SCRIPT_DIR/voice-speak.sh" "$VOICE_CONTENT" --quiet
else
    echo "$VOICE_CONTENT"
fi

if [[ "$QUIET" == false ]]; then
    echo ""
    echo -e "${GREEN}✓ Voice output complete${NC}"
fi
