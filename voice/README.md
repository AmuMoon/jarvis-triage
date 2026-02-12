# 🎙️ Voice Integration

Phase 1 of Jarvis Triage adds voice output capability to read the "语音版" content aloud.

## Overview

The voice module integrates with OpenClaw's TTS (Text-to-Speech) tool to convert triage "语音版" output into actual speech. This enables hands-free, mobile-friendly interaction.

## Quick Start

### Method 1: Direct TTS Tool (Recommended)

When running in OpenClaw, use the TTS tool directly:

```bash
# Simple usage
openclaw tts "认证迁移计划出来了，分7步"

# With channel context
openclaw tts "确认执行吗？" --channel=telegram
```

### Method 2: Parse and Speak Script

Extract voice content from triage output files:

```bash
# Speak a triage result file
./voice/parse-and-speak.sh tests/results/20240212-120000/level-4-auth-migration-result.md

# With channel
./voice/parse-and-speak.sh output.md --channel=telegram

# Demo mode
./voice/parse-and-speak.sh --demo
```

### Method 3: Voice Trigger Handler

Handle activation commands like "语音播报" or "read this":

```bash
# Speak the last triage output
./voice/voice-trigger.sh speak-last

# Speak a specific file
./voice/voice-trigger.sh speak-file -f tests/samples/level-4-auth-migration.md

# Run demo
./voice/voice-trigger.sh demo
```

## Integration with SKILL.md

When the skill detects voice activation keywords, it automatically triggers TTS:

**Voice Activation Triggers:**
- "语音播报" - Speak the current triage output
- "read this" - English alternative
- "念一下" - Alternative Chinese trigger

**How it works:**

1. User receives triage output with "🔊 语音版" section
2. User says "语音播报"
3. Skill extracts the voice content
4. Skill calls TTS tool: `tts text='<语音版内容>'`
5. User hears the summary via their configured audio output

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `voice-speak.sh` | Direct text-to-speech | `voice-speak.sh "text" [--channel=X]` |
| `parse-and-speak.sh` | Extract and speak from file | `parse-and-speak.sh <file>` |
| `voice-trigger.sh` | Handle activation commands | `voice-trigger.sh <command>` |

## TTS Output Format

When triggered, the TTS tool returns a MEDIA path:

```
MEDIA: /path/to/tts/output.mp3
```

This is automatically handled by OpenClaw and sent to the user's configured audio output (Telegram voice message, AirPods, etc.)

## Testing

Run the voice integration test:

```bash
# Demo mode (no actual TTS)
./voice/parse-and-speak.sh --demo

# Test with sample file
./voice/parse-and-speak.sh tests/samples/level-4-auth-migration.md

# Full voice test suite
./tests/scripts/test-voice.sh
```

## Configuration

### Channel-Specific Settings

Different channels may have different TTS behaviors:

- **Telegram**: Sends as voice message
- **WhatsApp**: Sends as audio message
- **Local**: Plays through system audio

### Voice Preferences

Voice settings are managed by OpenClaw's TTS configuration. See `TOOLS.md` in your workspace for local preferences (preferred voice, default speaker, etc.)

## Troubleshooting

### TTS Not Working

1. **Check OpenClaw session**: Ensure you're in an active OpenClaw session
2. **Verify tool availability**: Run `openclaw tools` and check for `tts`
3. **Check channel support**: Not all channels support TTS output

### Voice Content Not Found

The parser looks for these patterns in order:
1. `### 语音版` or `## 语音版` sections
2. Blockquote lines starting with `>`
3. Content after `🔊 语音版` marker

Ensure your triage output follows the format defined in SKILL.md.

## Roadmap

- [x] Basic TTS integration
- [x] Parse "语音版" from triage output
- [x] Voice activation triggers
- [ ] Voice navigation (next/pause/stop)
- [ ] Multi-language TTS support
- [ ] Voice preference per channel
