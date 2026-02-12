#!/bin/bash
# Batch voice test for Level 3-4 samples
# Generates voice for all decision-heavy scenarios

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLES_DIR="$(dirname "$SCRIPT_DIR")/samples"

echo "========================================"
echo "Jarvis Triage - Batch Voice Test"
echo "========================================"
echo "Testing Level 3-4 samples (decision-heavy scenarios)"
echo ""

# Find Level 3 and 4 samples
SAMPLES=$(find "$SAMPLES_DIR" -name "level-[34]-*.md" | sort)

if [[ -z "$SAMPLES" ]]; then
    echo "Error: No Level 3-4 samples found in $SAMPLES_DIR"
    exit 1
fi

TOTAL=0
for sample in $SAMPLES; do
    TOTAL=$((TOTAL + 1))
    filename=$(basename "$sample")
    echo "[$TOTAL] Processing: $filename"
    
    # Extract voice content
    VOICE_CONTENT=$(sed -n '/### 语音版/,/###/p' "$sample" | sed '1d;$d' | sed '/^$/d' | head -3)
    
    if [[ -n "$VOICE_CONTENT" ]]; then
        echo "    Voice preview: $(echo "$VOICE_CONTENT" | head -1 | cut -c1-50)..."
        CHAR_COUNT=$(echo "$VOICE_CONTENT" | wc -c)
        echo "    Character count: $CHAR_COUNT"
        
        # Estimate duration (Chinese: ~4 chars/second)
        EST_DURATION=$((CHAR_COUNT / 4))
        if [[ $EST_DURATION -gt 30 ]]; then
            echo "    ⚠️  Warning: Estimated duration ${EST_DURATION}s exceeds 30s limit"
        else
            echo "    ✓ Estimated duration: ${EST_DURATION}s"
        fi
    else
        echo "    ✗ No voice content found"
    fi
    echo ""
done

echo "========================================"
echo "Batch test complete!"
echo "Total samples: $TOTAL"
echo "========================================"
echo ""
echo "To generate actual voice output:"
echo "1. Use './play-voice.sh <file>' for individual samples"
echo "2. In OpenClaw: say '语音播报' after triage"
