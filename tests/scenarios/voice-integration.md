# 语音集成测试用例

## 测试 1: 基本语音播报

**输入**: Triage 输出包含语音版

```
📊 Triage Level: 3 - 信息决策

🔊 语音版：
云服务商对比完成。AWS最便宜但学习曲线陡峭，阿里云最熟悉但价格稍高，Vercel最简单但功能受限。

📱 HUD版：
L1: ☁️ 云服务商对比
L2: ❓ 选哪个？
L3:   A: AWS (便宜/难)
L4:   B: 阿里云 (熟悉/贵)
```

**用户指令**: "语音播报"

**期望行为**:
1. 提取 "语音版" 内容
2. 调用 TTS: `tts text='云服务商对比完成...'`
3. 播放语音

---

## 测试 2: Level 4 Plan 审批语音

**输入**: 复杂 Plan 的 triage 输出

```
📊 Triage Level: 4 - Plan审批

🔊 语音版：
认证迁移计划出来了，分7步。安装依赖、建JWT中间件、改登录接口、迁移数据、改前端、清理旧代码、写测试。有两个需要你决定的，一个是token存哪里，一个是刷新策略。另外数据迁移那步不可逆，执行前会先备份。
```

**用户指令**: "念一下"

**期望行为**:
1. 完整提取 7 步计划概述
2. 包含 2 个决策点提醒
3. 包含风险提示（数据迁移不可逆）
4. TTS 播放完整摘要

---

## 测试 3: 快速决策语音 (Level 2)

**输入**: 简单二选一

```
📊 Triage Level: 2 - 快速决策

🔊 语音版：
会议时间确认，周四下午2点或者周五上午10点，选哪个？

📱 HUD版：
L1: 📅 会议时间确认
L2: ❓ 周四14:00 / 周五10:00
```

**用户指令**: "read this"

**期望行为**:
1. 提取简短语音内容
2. TTS 清晰朗读两个选项
3. 用户无需看屏幕即可决策

---

## 测试 4: 通知类语音 (Level 1)

**输入**: 简单通知

```
📊 Triage Level: 1 - 通知

🔊 语音版：
备份已完成，文件保存在云端存储。

📱 HUD版：
L1: ✅ 备份完成
```

**用户指令**: "语音播报"

**期望行为**:
1. 简短播报
2. 不中断用户当前活动

---

## 测试 5: 语音内容提取边界情况

### 情况 5a: 空语音版

```
🔊 语音版：
（空）
```

**期望**: 提示用户 "没有语音内容"

### 情况 5b: 超长语音版

```
🔊 语音版：
[超过200字的长文本...]
```

**期望**: 截断到 120 字或分多次播报

### 情况 5c: 特殊字符

```
🔊 语音版：
Token存储方式：Cookie vs LocalStorage (XSS风险)
```

**期望**: 处理特殊字符，TTS 能正常朗读

---

## 测试 6: 语音触发词变体

| 触发词 | 期望行为 |
|--------|----------|
| "语音播报" | ✓ 触发 |
| "念一下" | ✓ 触发 |
| "read this" | ✓ 触发 |
| "读给我听" | ✓ 触发 |
| "speak this" | ✓ 触发 |
| "播放" | ✓ 触发 |
| "speak" | ✓ 触发 |

---

## 测试 7: 多轮对话语音

**场景**: Plan 审批过程中的多轮交互

**Round 1**:
- System: Triage output with 2 decisions
- User: "语音播报"
- System: TTS plays summary

**Round 2**:
- User: "Cookie" (answers decision 1)
- System: Updated HUD with decision 2
- User: "念一下"
- System: TTS plays decision 2 options

**Round 3**:
- User: "Rotation"
- System: All decisions complete
- User: "语音播报"
- System: TTS plays final confirmation summary

---

## 自动化测试命令

```bash
# 运行所有语音测试
./tests/scripts/test-voice.sh

# 测试特定场景
./voice/parse-and-speak.sh tests/samples/level-4-auth-migration.md
./voice/parse-and-speak.sh tests/samples/level-2-meeting-time.md

# Demo 模式
./voice/voice-trigger.sh demo
```
