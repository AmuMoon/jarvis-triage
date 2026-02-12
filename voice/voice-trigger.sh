#!/bin/bash
# Jarvis Triage - Voice Trigger Handler
# Handle voice activation commands like "语音播报" or "read this"

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
COMMAND=""
CONTEXT_FILE=""
CHANNEL=""

print_help() {
    echo "Jarvis Triage - Voice Trigger Handler"
    echo ""
    echo "Handle voice activation commands."
    echo ""
    echo "Usage: voice-trigger.sh <command> [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  speak-last    Speak the last triage output"
    echo "  speak-file    Speak a specific file"
    echo "  demo          Run voice demo"
    echo ""
    echo "Options:"
    echo "  --channel, -c   Target channel for TTS"
    echo "  --file, -f      File to speak (for speak-file command)"
    echo "  --help, -h      Show this help"
    echo ""
    echo "Examples:"
    echo '  voice-trigger.sh speak-last              # Speak last triage'
    echo '  voice-trigger.sh speak-file -f result.md # Speak specific file'
    echo '  voice-trigger.sh demo                     # Demo mode'
}

# Parse arguments
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
        --file=*)
            CONTEXT_FILE="${1#*=}"
            shift
            ;;
        --file|-f)
            CONTEXT_FILE="$2"
            shift 2
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        speak-last|speak-file|demo)
            COMMAND="$1"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            print_help
            exit 1
            ;;
    esac
done

# Validate command
if [[ -z "$COMMAND" ]]; then
    echo -e "${RED}Error: No command specified${NC}" >&2
    print_help
    exit 1
fi

# Execute command
case "$COMMAND" in
    speak-last)
        echo -e "${BLUE}🎙️  Speaking last triage output...${NC}"
        
        # Look for recent triage output files
        LAST_FILE=$(find "$PROJECT_DIR/tests/results" -name "*-result.md" 2>/dev/null | sort -r | head -1)
        
        if [[ -z "$LAST_FILE" ]]; then
            echo -e "${YELLOW}⚠️  No recent triage output found${NC}"
            echo "Run tests first: ./tests/scripts/run-tests.sh"
            exit 1
        fi
        
        echo "Found: $(basename "$LAST_FILE")"
        "$SCRIPT_DIR/parse-and-speak.sh" "$LAST_FILE" --quiet
        ;;
        
    speak-file)
        if [[ -z "$CONTEXT_FILE" ]]; then
            echo -e "${RED}Error: --file required for speak-file command${NC}" >&2
            exit 1
        fi
        
        if [[ ! -f "$CONTEXT_FILE" ]]; then
            echo -e "${RED}Error: File not found: $CONTEXT_FILE${NC}" >&2
            exit 1
        fi
        
        echo -e "${BLUE}🎙️  Speaking file: $(basename "$CONTEXT_FILE")${NC}"
        "$SCRIPT_DIR/parse-and-speak.sh" "$CONTEXT_FILE" --quiet
        ;;
        
    demo)
        echo -e "${BLUE}🎙️  Jarvis Triage Voice Demo${NC}"
        echo ""
        echo "This demo shows how voice integration works:"
        echo ""
        
        # Simulate triage output
        echo "1. Simulated triage output:"
        echo "   📊 Triage Level: 4 - Plan审批"
        echo "   🔊 语音版: 认证迁移计划出来了，分7步..."
        echo "   📱 HUD版: 4 lines..."
        echo ""
        
        echo "2. User says: 语音播报"
        echo ""
        
        echo "3. Voice output:"
        DEMO_TEXT="认证迁移计划出来了，分7步。有两个需要你决定的，一个是token存哪里，一个是刷新策略。"
        echo "   \"$DEMO_TEXT\""
        echo ""
        
        # Run actual demo
        "$SCRIPT_DIR/parse-and-speak.sh" --demo
        ;;
        
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}" >&2
        exit 1
        ;;
esac
