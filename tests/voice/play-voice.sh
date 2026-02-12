#!/bin/bash
# Play voice for a triage sample
# Usage: ./play-voice.sh <sample-file.md>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE_FILE="$1"

if [[ -z "$SAMPLE_FILE" ]]; then
    echo "Usage: $0 <sample-file.md>"
    echo "Example: $0 ../samples/level-4-auth-migration.md"
    exit 1
fi

if [[ ! -f "$SAMPLE_FILE" ]]; then
    echo "Error: File not found: $SAMPLE_FILE"
    exit 1
fi

# Extract 语音版 content from the sample file
# Look for content between "### 语音版" and the next section
VOICE_CONTENT=$(sed -n '/### 语音版/,/###/p' "$SAMPLE_FILE" | sed '1d;$d' | sed '/^$/d' | head -5)

if [[ -z "$VOICE_CONTENT" ]]; then
    # Try alternative format (期望输出 section)
    VOICE_CONTENT=$(sed -n '/语音版/,/###/p' "$SAMPLE_FILE" | sed '1d;$d' | sed '/^$/d' | head -5)
fi

if [[ -z "$VOICE_CONTENT" ]]; then
    echo "Error: No 语音版 content found in $SAMPLE_FILE"
    exit 1
fi

echo "========================================"
echo "Voice Content Extracted:"
echo "========================================"
echo "$VOICE_CONTENT"
echo ""
echo "Length: $(echo "$VOICE_CONTENT" | wc -c) characters"
echo ""

# Check if TTS tool is available (we're in OpenClaw context)
if command -v tts &> /dev/null; then
    echo "Generating voice with TTS..."
    tts --text "$VOICE_CONTENT"
else
    echo "Note: TTS tool not available in shell context."
    echo "In OpenClaw, this content would be passed to the tts tool."
    echo ""
    echo "To test voice in OpenClaw:"
    echo "1. Start an OpenClaw session"
    echo "2. Say: 'Jarvis, triage this plan'"
    echo "3. Then: '语音播报'"
fi
