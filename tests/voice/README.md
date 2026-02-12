# Voice Integration Guide (Phase 1)

This document describes how Jarvis Triage integrates with OpenClaw's TTS (Text-to-Speech) system for voice output.

## Overview

Jarvis Triage generates a "语音版" (voice version) of every triage output. Phase 1 integrates this with OpenClaw's `tts` tool to actually speak the content aloud.

## How It Works

### User Triggers Voice Output

Users can request voice output by saying:
- `"语音播报"` (Chinese)
- `"read this"` or `"voice"` (English)
- `"播报"` (short form)

### The Flow

```
User: "Jarvis, triage this plan"
→ Agent generates triage output with 语音版

User: "语音播报"
→ Agent extracts 语音版 content
→ Agent calls tts tool
→ User hears voice briefing
```

## SKILL.md Integration

The SKILL.md has been updated to include voice output generation. When the skill generates triage output, it automatically includes:

```
🔊 语音版（直接念给用户听，≤30秒）：
[语音内容，口语化，自然流畅]
```

## Voice Scripts

Located in `tests/voice/`:

### play-voice.sh

Converts a triage sample's 语音版 to actual speech:

```bash
./tests/voice/play-voice.sh tests/samples/level-4-auth-migration.md
```

### batch-voice-test.sh

Generates voice for all Level 3-4 samples (decision-heavy scenarios):

```bash
./tests/voice/batch-voice-test.sh
```

## TTS Configuration

The `tts` tool is available in OpenClaw:

```javascript
// Example tool call
tts({
  text: "认证迁移计划出来了，分7步...",
  channel: "telegram"  // Optional, for channel-specific format
})
```

Returns: `MEDIA: /path/to/audio.mp3`

## Usage Examples

### Example 1: Single Triage Voice

```bash
# Triage a plan
"Jarvis, 审批一下这个 plan"

# Request voice output
"语音播报"

# Agent responds with voice audio
```

### Example 2: Test Voice Generation

```bash
cd ~/Projects/jarvis-triage
./tests/voice/play-voice.sh tests/samples/level-3-cloud-provider.md
```

## Phase 1 Implementation Status

✅ **Completed:**
- Voice trigger keywords added to SKILL.md
- Voice output format defined
- Helper scripts created in `tests/voice/`
- Documentation added

⬜ **Future (Phase 2):**
- Auto-voice for Level 4 plans (no manual trigger needed)
- Voice speed/pitch tuning
- Multi-language voice selection
- AR HUD sync with voice timing

## Testing Voice Output

Run the voice test suite:

```bash
./tests/voice/batch-voice-test.sh
```

This will generate voice files for all high-level samples and play them sequentially.

## Limitations

1. **Voice Length**: Maximum ~30 seconds (100-120 Chinese characters)
2. **Language**: Currently optimized for Chinese
3. **Trigger**: Requires manual voice command (not automatic)
4. **Channel**: TTS format depends on current channel (Telegram/WhatsApp/etc)

## Next Steps

See `../references/voice-integration-roadmap.md` for Phase 2 plans.
