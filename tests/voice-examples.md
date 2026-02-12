# Voice Integration Examples

This directory contains examples of voice integration for Jarvis Triage Phase 1.

## Usage Examples

### Example 1: Direct TTS from Triage Output

When a user receives triage output and says "语音播报":

```javascript
// Pseudo-code for SKILL.md execution
if (userMessage.includes('语音播报') || userMessage.includes('read this')) {
    const voiceContent = extractVoiceSection(lastTriageOutput);
    // Returns: "认证迁移计划出来了，分7步..."
    
    tts({ text: voiceContent });
    // Output: MEDIA: /path/to/audio.mp3
}
```

### Example 2: Shell Script Integration

```bash
# Extract and speak from a triage file
./voice/parse-and-speak.sh tests/samples/level-4-auth-migration.md

# Expected output:
# 🔊 Speaking: 认证迁移计划出来了，分7步...
# MEDIA: /tmp/tts-xxx.mp3
```

### Example 3: Voice Trigger Handler

```bash
# Handle "语音播报" command
./voice/voice-trigger.sh speak-last

# This will:
# 1. Find the most recent triage output
# 2. Extract the voice section
# 3. Call TTS tool
```

### Example 4: OpenClaw TTS Tool Direct Usage

```
User: 帮我triage一下这个plan
[Skill generates triage output with 语音版 section]

User: 语音播报
[Skill detects trigger word]

[Skill executes]
tts text='认证迁移计划出来了，分7步。安装依赖、建JWT中间件、改登录接口、迁移数据、改前端、清理旧代码、写测试。有两个需要你决定的，一个是token存哪里，一个是刷新策略。另外数据迁移那步不可逆，执行前会先备份。'

[User hears voice through their audio device]
```

## Sample Voice Content

### Level 4 Plan (Authentication Migration)

**Original Text**:
```
认证迁移计划出来了，分7步。安装依赖、建JWT中间件、改登录接口、
迁移数据、改前端、清理旧代码、写测试。有两个需要你决定的，
一个是token存哪里，一个是刷新策略。另外数据迁移那步不可逆，
执行前会先备份。
```

**Characteristics**:
- ~100 Chinese characters
- ~25 seconds speaking time
- 2 decision points highlighted
- Risk warning included
- Conversational tone

### Level 2 Quick Decision (Meeting Time)

**Original Text**:
```
会议时间确认，周四下午2点或者周五上午10点，选哪个？
```

**Characteristics**:
- ~25 Chinese characters
- ~5 seconds speaking time
- Clear options presented
- Question format

## Testing Commands

```bash
# Make scripts executable
chmod +x voice/*.sh

# Run voice demo
./voice/parse-and-speak.sh --demo

# Test with sample files
for sample in tests/samples/level-*.md; do
    echo "Testing: $sample"
    ./voice/parse-and-speak.sh "$sample" --quiet
done

# Full voice test suite
./tests/scripts/test-voice.sh
```

## Expected TTS Output Format

When the TTS tool is called, it returns:

```
MEDIA: /path/to/generated/audio/file.mp3
```

This media reference is automatically handled by OpenClaw and sent to the appropriate channel (Telegram voice message, WhatsApp audio, etc.)

## Voice Content Guidelines

### Do's ✓

- Use conversational Chinese (口语化)
- Keep under 30 seconds (100-120 characters)
- Include decision count ("有两个需要你决定的")
- Warn about risks ("数据迁移不可逆")
- Use natural pauses (commas for breathing)

### Don'ts ✗

- Technical jargon without explanation
- Abbreviations (JWT → "认证令牌")
- Bullet points or lists
- Code snippets
- URLs or file paths

### Example Conversion

**Before** (screen format):
```
Steps:
1. Install jsonwebtoken
2. Create middleware
3. Update routes
```

**After** (voice format):
```
一共7步。安装依赖、建中间件、改登录接口、迁移数据、改前端、清理旧代码、最后写测试。
```
