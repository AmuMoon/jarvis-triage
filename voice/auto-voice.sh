#!/bin/bash
# Phase 2: Auto-Voice for Level 4 Plans
# Automatically triggers TTS for Level 4 triage outputs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
AUTO_VOICE_ENABLED=true
MIN_DECISIONS_FOR_AUTO_VOICE=2

# Parse arguments
LEVEL=""
DECISION_COUNT=0
VOICE_CONTENT=""
NO_VOICE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --decisions)
            DECISION_COUNT="$2"
            shift 2
            ;;
        --voice-content)
            VOICE_CONTENT="$2"
            shift 2
            ;;
        --no-voice)
            NO_VOICE=true
            shift
            ;;
        --disable)
            AUTO_VOICE_ENABLED=false
            echo "Auto-voice disabled"
            exit 0
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Auto-trigger voice for Level 4 plans"
            echo ""
            echo "Options:"
            echo "  --level N          Triage level (0-4)"
            echo "  --decisions N      Number of decisions"
            echo "  --voice-content    Voice content to speak"
            echo "  --no-voice         Skip voice (user preference)"
            echo "  --disable          Disable auto-voice globally"
            echo "  --help             Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if auto-voice should trigger
should_trigger_voice() {
    # Disabled globally
    if [[ "$AUTO_VOICE_ENABLED" != "true" ]]; then
        return 1
    fi
    
    # User disabled for this session
    if [[ "$NO_VOICE" == "true" ]]; then
        return 1
    fi
    
    # Must be Level 4
    if [[ "$LEVEL" != "4" ]]; then
        return 1
    fi
    
    # Must have minimum decisions
    if [[ "$DECISION_COUNT" -lt "$MIN_DECISIONS_FOR_AUTO_VOICE" ]]; then
        return 1
    fi
    
    return 0
}

# Main logic
if should_trigger_voice; then
    echo -e "${GREEN}[Auto-Voice]${NC} Triggering voice for Level $LEVEL Plan ($DECISION_COUNT decisions)"
    
    if [[ -n "$VOICE_CONTENT" ]]; then
        # Call TTS (in OpenClaw context, this would use the tts tool)
        if command -v tts &> /dev/null; then
            tts text="$VOICE_CONTENT"
        else
            echo "[TTS] $VOICE_CONTENT"
            echo "(TTS tool would be called here in OpenClaw context)"
        fi
    else
        echo -e "${YELLOW}Warning: No voice content provided${NC}"
    fi
else
    echo -e "${BLUE}[Auto-Voice]${NC} Skipped (Level $LEVEL, $DECISION_COUNT decisions)"
fi
