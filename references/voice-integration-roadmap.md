# Voice Integration Roadmap

## Phase 1: Basic Voice Output ✅

**Status**: Completed

### Features
- Manual voice trigger (`语音播报`, `read this`)
- TTS integration with OpenClaw's `tts` tool
- Voice length limit enforcement (≤30 seconds)
- Helper scripts for testing

### Implementation
- Added voice section to SKILL.md output format
- Created `tests/voice/` directory with helper scripts
- Documented TTS usage patterns

## Phase 2: Auto-Voice & Smart Triggers ✅

**Status**: Completed (2026-02-12)

### Features
- ✅ **Auto-voice for Level 4**: Plans automatically include voice without manual trigger
- ✅ **Voice command parsing**: Support "选择A", "选项二", "approve", "reject", etc.
- ✅ **Combo commands**: "选A，继续" for multiple actions
- ✅ **Context-aware**: Different commands for decision/approval/navigation contexts

### Implementation
- `voice/auto-voice.sh`: Auto-trigger logic for Level 4 plans
- `voice/parse-command.sh`: Voice command parser with JSON output
- `tests/phase2-test.sh`: Test suite for Phase 2 features

### Supported Commands

**Decision Commands:**
- `选A` / `选择A` / `A` / `选项一` / `第一个`
- `选B` / `选择B` / `B` / `选项二` / `第二个`
- `选C` / `选择C` / `C` / `选项三` / `第三个`

**Approval Commands:**
- `确认` / `approve` / `执行` / `可以` / `ok`
- `取消` / `reject` / `否决` / `不行` / `no`

**Navigation Commands:**
- `下一个` / `next` / `继续` / `下一步`
- `上一个` / `back` / `返回` / `上一步`
- `重复` / `repeat` / `再说一遍`
- `详细` / `detail` / `展开`

**Combo Commands:**
- `选A，继续` → Select A + Next
- `选B，确认` → Select B + Approve

## Phase 3: Voice Interaction

**Status**: Planned

### Features
- **Full voice conversation**: User speaks, agent responds with voice
- **Voice navigation**: "下一个决策", "重复一遍", "详细说明"
- **Voice shortcuts**: Pre-defined voice commands for common actions

### Technical Requirements
- Speech-to-text integration
- Intent recognition
- Conversation state management

## Phase 4: AR HUD Sync

**Status**: Planned

### Features
- **Voice + visual sync**: Voice narration matches HUD display
- **Progress indication**: Voice says "Decision 2 of 3" while HUD shows progress
- **Timing control**: Pause voice when user is reading HUD

### Technical Requirements
- Even Realities G1 integration
- AugmentOS SDK
- BLE communication

## Usage Examples by Phase

### Phase 1 (Current)
```
User: "Jarvis, triage this plan"
[Text output with 语音版 section]
User: "语音播报"
[Voice audio plays]
```

### Phase 2
```
User: "Jarvis, triage this plan"
[Auto voice plays + text output]
User: "选择A"  (voice command)
[Next decision voice + HUD update]
```

### Phase 3
```
User: [Voice] "帮我看看这个plan"
Agent: [Voice] "认证迁移计划，7步，两个决策..."
User: [Voice] "第一个选A"
Agent: [Voice] "好的，Cookie。第二个决策..."
```

### Phase 4
```
User walking, sees on AR glasses:
┌──────────────────┐
│ JWT Migration    │
│ Decision 1/2     │
│ A: Cookie ✓      │
│ B: LocalStorage  │
└──────────────────┘

Hears in AirPods:
"认证迁移计划，7步。第一个决策：
 Token存储方式。推荐选A，Cookie更安全。"

User: [Voice] "选A"
→ HUD updates to Decision 2/2
```

## TTS Configuration

### Current (Phase 1)
- Tool: `tts`
- Default voice: System default
- Language: Auto-detected from text

### Future Options
- Voice selection (male/female, accent)
- Speed control (0.8x - 1.5x)
- Emphasis tags for important words

## Testing Checklist

- [x] Manual voice trigger works
- [x] Voice content extracted correctly from samples
- [x] Voice length within 30s limit
- [x] Auto-voice for Level 4 (Phase 2)
- [x] Voice command recognition (Phase 2)
- [ ] AR HUD sync (Phase 4)
