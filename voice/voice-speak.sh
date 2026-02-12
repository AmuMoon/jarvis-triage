#!/bin/bash
# Jarvis Triage Voice Integration Script
# Phase 1 - Convert "语音版" output to actual speech

# Usage: voice-speak.sh "<text>" [--channel=<channel_id>]
# Example: voice-speak.sh "认证迁移计划出来了，分7步。" --channel=telegram

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
TEXT=""
CHANNEL=""
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --channel=*)
            CHANNEL="${1#*=}"
            shift
            ;;
        --channel)
            CHANNEL="$2"
            shift 2
            ;;
        --quiet|-q)
            QUIET=true
            shift
            ;;
        --help|-h)
            echo "Jarvis Triage Voice Integration"
            echo ""
            echo "Usage: voice-speak.sh [OPTIONS] <text>"
            echo ""
            echo "Options:"
            echo "  --channel, -c   Target channel for TTS (e.g., telegram, whatsapp)"
            echo "  --quiet, -q     Suppress output (for scripting)"
            echo "  --help, -h      Show this help"
            echo ""
            echo "Examples:"
            echo '  voice-speak.sh "认证迁移计划出来了，分7步"'
            echo '  voice-speak.sh "确认执行备份操作吗？" --channel=telegram'
            echo ""
            echo "Note: This script uses OpenClaw's TTS tool."
            echo "      Run from within an OpenClaw session or use openclaw command."
            exit 0
            ;;
        *)
            if [[ -z "$TEXT" ]]; then
                TEXT="$1"
            else
                TEXT="$TEXT $1"
            fi
            shift
            ;;
    esac
done

# Validate input
if [[ -z "$TEXT" ]]; then
    echo -e "${RED}Error: No text provided${NC}" >&2
    echo "Usage: voice-speak.sh <text> [--channel=<channel>]"
    exit 1
fi

# Check if running in OpenClaw session
if [[ "$QUIET" == false ]]; then
    echo -e "${BLUE}🎙️  Jarvis TTS${NC}"
    echo "Text: ${TEXT:0:60}$([[ ${#TEXT} -gt 60 ]] && echo "...")"
    [[ -n "$CHANNEL" ]] && echo "Channel: $CHANNEL"
    echo ""
fi

# Method 1: Direct OpenClaw TTS tool call (when running inside OpenClaw)
if command -v openclaw &> /dev/null; then
    if [[ -n "$CHANNEL" ]]; then
        # Send with channel context
        openclaw tts "$TEXT" --channel "$CHANNEL"
    else
        openclaw tts "$TEXT"
    fi
    exit 0
fi

# Method 2: Fallback - output instructions
if [[ "$QUIET" == false ]]; then
    echo -e "${YELLOW}⚠️  OpenClaw TTS not directly available${NC}"
    echo ""
    echo "To use voice integration, run one of:"
    echo ""
    echo "1. In OpenClaw CLI session:"
    echo "   Use the 'tts' tool:"
    echo "   tts text='认证迁移计划出来了，分7步'"
    echo ""
    echo "2. In SKILL.md execution:"
    echo "   The skill will automatically call TTS for '语音版' content"
    echo ""
    echo "3. For external scripts, use:"
    echo '   openclaw message send --channel=<channel> --tts "text here"'
fi

# Output the text that would be spoken
echo ""
echo "📝 Text ready for TTS:"
echo "$TEXT"
