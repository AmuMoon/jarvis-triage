# Phase 3: AR HUD Integration

## Overview

Phase 3 integrates Jarvis Triage with Even Realities G1 AR glasses via AugmentOS SDK, creating a synchronized voice + visual experience for hands-free plan approval.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interaction                         │
├─────────────────────────────────────────────────────────────┤
│  Voice Input (AirPods)                                      │
│       ↓                                                     │
│  OpenClaw + Jarvis Triage (this repo)                       │
│       ↓                                                     │
│  ┌──────────────┐    BLE    ┌──────────────┐               │
│  │  Voice Out   │◄─────────►│  AR HUD      │               │
│  │  (AirPods)   │   Sync    │  (G1 Glasses)│               │
│  └──────────────┘           └──────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

## Hardware Requirements

### Required
- **Even Realities G1** AR glasses
- **iOS/Android phone** with AugmentOS app
- **Bluetooth earbuds** (AirPods recommended)
- **OpenClaw host** (Mac/PC/Raspberry Pi)

### Specifications
- BLE 5.0+ for low-latency sync (< 200ms)
- Glasses display: 640x400 resolution, 60Hz
- Field of view: 30° diagonal
- Battery: 8 hours continuous use

## Software Stack

### AugmentOS SDK Integration

```javascript
// SDK initialization
const augmentOS = new AugmentOS({
  deviceId: 'g1-glasses-001',
  bleAdapter: 'default'
});

// HUD layout registration
augmentOS.registerLayout('jarvis-triage', {
  type: '4-line-display',
  template: `
    L1: {icon} {title}
    L2: {status} {current}/{total}
    L3: {option_a}
    L4: {option_b}
  `
});
```

### HUD Display Format

```
┌──────────────────────────────┐
│ 🔧 JWT Migration             │  L1: Icon + Title
│ ❓ Decision 2/3              │  L2: Status
│   A: Cookie (secure/CORS)    │  L3: Option A
│   B: LocalStorage (simple)   │  L4: Option B
└──────────────────────────────┘
```

## Synchronization Protocol

### Voice-HUD Sync

```
Timeline:
T+0ms    Voice starts: "认证迁移，分7步..."
T+200ms  HUD updates: Show "Decision 1/2"
T+3000ms Voice: "第一个决策：Token存储..."
T+3200ms HUD highlight: Option A row
T+5000ms Voice: "选项A，Cookie..."
T+5200ms HUD: Show Cookie details
T+8000ms Voice: "选项B，LocalStorage..."
T+8200ms HUD: Show LocalStorage details
T+12000ms Voice: "你选哪个？"
T+12200ms HUD: Blink cursor, wait input
```

### BLE Message Format

```json
{
  "type": "triage-update",
  "timestamp": 1770912000000,
  "payload": {
    "level": 4,
    "title": "JWT Migration",
    "icon": "🔧",
    "current_decision": 1,
    "total_decisions": 2,
    "options": [
      {"id": "A", "label": "Cookie", "detail": "secure/CORS"},
      {"id": "B", "label": "LocalStorage", "detail": "simple"}
    ],
    "highlight": null
  }
}
```

## Implementation Plan

### Phase 3.1: SDK Integration (Week 1)

**Goals**:
- Set up AugmentOS development environment
- Establish BLE connection between OpenClaw and G1
- Implement basic message passing

**Tasks**:
1. Install AugmentOS SDK
2. Pair G1 glasses with development device
3. Create `hud/augmentos-bridge.js`
4. Test basic HUD display

**Deliverable**: "Hello World" on G1 display from OpenClaw

### Phase 3.2: HUD Layouts (Week 2)

**Goals**:
- Implement all triage Level layouts
- Create visual assets (icons, progress bars)

**Layouts**:
```
Level 0-1: Single line notification
Level 2:   2-line decision
Level 3:   3-line info + decision
Level 4:   4-line plan review (main focus)
```

**Files**:
- `hud/layouts/level0.js`
- `hud/layouts/level2.js`
- `hud/layouts/level3.js`
- `hud/layouts/level4.js`

### Phase 3.3: Voice-HUD Sync (Week 3)

**Goals**:
- Synchronize TTS timing with HUD updates
- Implement smooth transitions

**Features**:
- Auto-scroll with voice narration
- Highlight current topic
- Show progress indicators

**Testing**:
- Latency < 200ms
- No desync during long voice clips
- Graceful degradation if BLE drops

### Phase 3.4: Voice Commands + Visual (Week 4)

**Goals**:
- Visual feedback for voice commands
- HUD updates on user voice input

**Interactions**:
```
User: "选A"
→ HUD: Option A highlighted
→ HUD: Checkmark appears
→ Voice: "已选择 Cookie"
→ HUD: Progress to next decision

User: "下一个"
→ HUD: Slide transition
→ HUD: Show Decision 2/2
```

### Phase 3.5: Real-World Testing (Week 5-6)

**Test Scenarios**:
1. Walking indoors (office)
2. Walking outdoors (street)
3. Low light conditions
4. Background noise (cafe)
5. Long session (30+ minutes)

**Metrics**:
- Command recognition accuracy > 95%
- HUD visibility in various lighting
- Comfort after extended use
- Battery life impact

## HUD Design Specifications

### Visual Style

```css
/* HUD Theme */
:root {
  --bg-color: #000000;
  --text-primary: #00FF00;      /* Green - main text */
  --text-secondary: #888888;    /* Gray - details */
  --accent-active: #00FFFF;     /* Cyan - selected */
  --accent-warning: #FFAA00;    /* Orange - warnings */
  --accent-error: #FF0000;      /* Red - errors */
}

/* Typography */
font-family: 'SF Mono', monospace;
font-size: 14px;
line-height: 1.4;
```

### Icons

| Icon | Meaning |
|------|---------|
| 🔧 | Plan/Implementation |
| 🐛 | Bug Fix |
| 🔄 | Refactor |
| ☁️ | Cloud/Infrastructure |
| 🗄️ | Database |
| ⚠️ | Warning/Risk |
| ✅ | Completed |
| ❓ | Decision Pending |

### Animations

```
Transition Types:
- Slide: Left/right for navigation
- Fade: Subtle for content updates
- Pulse: Highlight for user attention
- Check: Completion confirmation

Timing:
- Transitions: 200ms
- Pulses: 500ms loop
- Auto-scroll: Sync with voice (±100ms)
```

## Testing Without Hardware

### Simulator Setup

```bash
# AugmentOS provides a simulator
npm install -g augmentos-simulator
augmentos-simulator --resolution 640x400

# Connect OpenClaw to simulator
export AUGMENTOS_DEVICE=simulator:localhost:8080
```

### Mock HUD Display

```javascript
// Terminal-based HUD for development
const mockHUD = {
  render(lines) {
    console.clear();
    console.log('┌──────────────────────────────┐');
    lines.forEach(line => {
      console.log('│ ' + line.padEnd(28) + ' │');
    });
    console.log('└──────────────────────────────┘');
  }
};
```

### Testing Checklist (No Hardware)

- [ ] BLE message format validation
- [ ] Layout rendering in simulator
- [ ] Voice-HUD timing sync
- [ ] Command response latency
- [ ] Error handling (disconnection)
- [ ] Long session stability

## Files to Create

```
hud/
├── README.md
├── augmentos-bridge.js      # BLE connection
├── message-formatter.js     # Format triage to HUD
├── layouts/
│   ├── index.js
│   ├── base.js
│   ├── level0.js
│   ├── level1.js
│   ├── level2.js
│   ├── level3.js
│   └── level4.js
├── animations.js
├── icons.js
└── simulator.js             # Mock for testing

tests/hud/
├── test-bridge.js
├── test-layouts.js
├── test-sync.js
└── README.md
```

## API Reference

### `HUDBridge`

```javascript
class HUDBridge {
  constructor(options);
  
  // Connection
  connect(): Promise<void>;
  disconnect(): Promise<void>;
  isConnected(): boolean;
  
  // Display
  showLayout(level: number, data: object): void;
  updateLine(line: number, content: string): void;
  highlightOption(option: string): void;
  clear(): void;
  
  // Sync
  syncWithVoice(voiceText: string, timing: object): void;
}
```

### `MessageFormatter`

```javascript
class MessageFormatter {
  // Convert triage output to HUD format
  static format(triageOutput: object): HUDMessage;
  
  // Extract timing for voice sync
  static extractTiming(voiceContent: string): TimingMarkers;
}
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| BLE latency > 200ms | Voice-HUD desync | Local buffering, predictive updates |
| Glasses battery drain | Short session | Optimize update frequency, sleep mode |
| Outdoor visibility | Can't read HUD | High contrast theme, brightness auto-adjust |
| Background noise | Voice commands fail | Visual confirmation, repeat command |
| SDK breaking changes | Integration breaks | Version pinning, abstraction layer |

## Success Metrics

### Technical
- BLE latency: < 200ms
- Voice-HUD sync: ±100ms
- Command recognition: > 95%
- Uptime: > 99%

### User Experience
- Task completion time reduced 30%
- User satisfaction > 4/5
- Walking speed maintained during interaction
- No safety incidents

## Timeline

| Week | Milestone | Deliverable |
|------|-----------|-------------|
| 1 | SDK Integration | BLE connection working |
| 2 | HUD Layouts | All Level layouts implemented |
| 3 | Voice-HUD Sync | Smooth synchronized experience |
| 4 | Voice + Visual | Complete interaction loop |
| 5-6 | Real-World Testing | Validated in actual use |

## Budget Estimate

- Even Realities G1: $600-800
- Development time: 6 weeks
- SDK license: Free (developer tier)
- **Total**: ~$800 + labor

## Next Steps

1. **Acquire hardware**: Order Even Realities G1
2. **SDK access**: Apply for AugmentOS developer account
3. **Development setup**: Install SDK, pair glasses
4. **Begin Phase 3.1**: SDK integration

---

**Status**: Ready to start (pending hardware)  
**Dependencies**: Even Realities G1, AugmentOS SDK  
**Estimated completion**: 6 weeks after hardware receipt
