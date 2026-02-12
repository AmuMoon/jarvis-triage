# Even Realities G2 适配指南

本指南说明如何将 Jarvis Triage 适配到 Even Realities G2 智能眼镜 + Even R1 戒指。

## 设备规格

### G2 显示能力

| 参数 | 值 | 说明 |
|------|-----|------|
| **显示宽度** | 488 像素 | 单眼显示区域 |
| **推荐字体** | 21px | Demo App 默认值 |
| **每屏行数** | 5 行 | 最佳阅读体验 |
| **每行中文** | 20-24 字 | 约 488/21 |
| **每行英文** | 40-50 字符 | 约 488/10 |

### 与 G1 的差异

- G2 显示区域比 G1 大 **75%**
- 文字更清晰，边缘不模糊
- 支持更复杂的 HUD 布局

## Jarvis Triage G2 格式

### 标准 5 行 HUD

```
L1: [标题/状态栏] - 图标 + 简短描述
L2: [主要内容] - 问题或决策描述
L3: [选项A] - 缩进显示
L4: [选项B] - 缩进显示
L5: [操作提示] - 戒指/语音交互提示
```

### 示例：Level 4 Plan 审批

**决策中：**
```
L1: 🔧 JWT迁移 Plan (7步)
L2: ❓ 决策1/2：Token存储方式
L3:   A: Cookie（安全/CORS麻烦）
L4:   B: LocalStorage（简单/XSS风险）
L5: 💍 轻触翻页 | 说"选A/选B"
```

**最终确认：**
```
L1: ✅ 决策完成：Cookie + Silent
L2: ⚠️ 风险：数据迁移不可逆
L3: 确认执行开始迁移？
L4: 说"确认"或💍双击
L5: 说"详细"查看完整Plan
```

## Even R1 戒指交互

### 戒指操作详解

#### 1. 轻触 (Tap)
- **触发**：手指轻触戒指表面
- **功能**：翻页 / 下一个 / 继续
- **使用**：浏览多个决策、查看详细内容

#### 2. 双击 (Double Tap)
- **触发**：快速连续轻触两次
- **功能**：确认 / 选择 / 执行
- **使用**：确认决策、批准 Plan

#### 3. 滑动 (Swipe)
- **触发**：手指在戒指表面滑动
- **功能**：快速滚动 / 翻页
- **使用**：浏览长内容、快速跳过

#### 4. 长按 (Long Press)
- **触发**：按住戒指 1-2 秒
- **功能**：激活语音输入
- **使用**：说出命令（"选A"、"确认"等）

### 戒指 + HUD 配合流程

**完整审批流程示例：**

```
[语音] "JWT迁移计划，7步，2个决策"

[HUD] 
L1: 🔧 JWT迁移 Plan
L2: ❓ 决策1/2：Token存储
L3:   A: Cookie
L4:   B: LocalStorage
L5: 💍 轻触翻页 | 长按语音

User: 💍 长按戒指
[语音输入] "选A"

[语音] "已选择 Cookie"

[HUD]
L1: ✅ 决策1: Cookie
L2: ❓ 决策2/2：刷新策略
L3:   A: Rotation
L4:   B: Silent
L5: 💍 轻触翻页 | 长按语音

User: 💍 长按戒指
[语音输入] "选B"

[语音] "已选择 Silent，所有决策完成"

[HUD]
L1: ✅ 决策完成
L2: Cookie + Silent Refresh
L3: 风险：数据迁移不可逆
L4: 确认开始执行？
L5: 💍 双击确认 | 说"详细"

User: 💍 双击戒指

[执行] Claude Code 开始执行
```

## 开发准备

### 方案 A: Even Hub SDK (推荐)

等待 Even Hub 批准后：
- 使用官方高阶 API
- 更简单的 HUD 控制
- 内置 Even AI 集成

### 方案 B: Even Demo App

基于开源 Demo App 开发：
```bash
git clone https://github.com/even-realities/EvenDemoApp.git
```

需要处理：
- 蓝牙协议（参考 Demo 中的实现）
- 文本分包发送（每包 194 字节）
- 图片传输（如需自定义图标）

### 方案 C: 混合架构

- iOS/Android App：处理蓝牙连接、Even AI
- OpenClaw：处理决策逻辑、生成 HUD 内容
- Webhook/App Link：两者通信

## 蓝牙协议要点

### 文本发送流程

参考 EvenDemoApp，文本发送分为3步：

1. **分行**：按显示宽度（488px）和字体大小（21px）分行
2. **分包**：每 5 行为一屏，每屏分 2 个数据包（194 字节/包）
3. **发送**：通过双 BLE 通道发送，左右眼独立

### 关键命令

```
[0xF5, 0x17]     - 眼镜进入 Even AI 激活状态
[0x0E, 0x01]     - 开启右侧麦克风
[0x15, ...]      - 发送 BMP 图片数据包
[0x20, 0x0d, 0x0e] - 数据包发送完成
[0x16, ...]      - CRC 校验
```

## 测试清单

### 显示测试

- [ ] 5 行文字完整显示
- [ ] 每行 24 个中文字符不溢出
- [ ] 图标（🔧❓✅⚠️💍）显示正常
- [ ] 户外阳光下的可视性
- [ ] 行走时的稳定性

### 交互测试

- [ ] 戒指轻触翻页响应
- [ ] 戒指长按激活语音
- [ ] 语音命令识别准确
- [ ] 双击确认不误触发
- [ ] 滑动滚动的流畅度

### 场景测试

- [ ] 走路时审批 Plan
- [ ] 会议中快速查看通知
- [ ] 户外阳光下使用
- [ ] 连续多个决策的处理
- [ ] 语音 + 戒指混合操作

## 与 OpenClaw 集成

### 架构设计

```
User (G2 + R1)
    ↓ 语音/戒指操作
Even AI / Demo App
    ↓ HTTP/WebSocket
OpenClaw Gateway
    ↓ Function Call
Jarvis Triage Skill
    ↓ Generate
5-Line HUD + Voice
    ↓
User sees/hears result
```

### API 设计

**Jarvis Triage → G2**
```json
{
  "level": 4,
  "voice": "JWT迁移计划，7步...",
  "hud": {
    "lines": [
      "🔧 JWT迁移 Plan (7步)",
      "❓ 决策1/2：Token存储",
      "  A: Cookie",
      "  B: LocalStorage",
      "💍 轻触翻页 | 长按语音"
    ]
  },
  "decisions": [
    {"id": 1, "question": "Token存储", "options": ["A", "B"]}
  ],
  "ring_action": "tap_to_continue"
}
```

## 参考资源

- Even Demo App: https://github.com/even-realities/EvenDemoApp
- Even Hub: https://evenhub.evenrealities.com/
- G2 规格: https://www.evenrealities.com/smart-glasses
- Even R1 戒指: https://www.evenrealities.com/even-r1

## 更新日志

### 2026-02-12
- 初始版本
- 基于 EvenDemoApp 开源代码分析
- 适配 Jarvis Triage 5 行格式
