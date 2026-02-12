# Jarvis Triage Test Suite

Phase 0.5 测试框架 - 用于验证 triage 逻辑在实际场景中的表现。

## 快速开始

```bash
# 运行所有测试
./scripts/run-tests.sh

# 测试特定 Level
./scripts/run-tests.sh --level 4

# 测试特定场景类型
./scripts/run-tests.sh --type plan

# 验证特定输出
./scripts/validate-output.sh tests/samples/level-4-auth-migration.md
```

## 测试目录结构

```
tests/
├── samples/                    # 测试样本（各种输入场景）
│   ├── level-0-*.md           # 静默级别样本
│   ├── level-1-*.md           # 通知级别样本
│   ├── level-2-*.md           # 快速决策样本
│   ├── level-3-*.md           # 信息决策样本
│   └── level-4-*.md           # Plan 审批样本
├── expected/                   # 期望输出（人工审核后的标准答案）
│   └── level-4-*/
├── results/                    # 测试结果（自动生成，不提交到 git）
│   └── $(date +%Y%m%d-%H%M%S)/
├── scripts/                    # 测试脚本
│   ├── run-tests.sh
│   ├── validate-output.sh
│   └── generate-report.sh
├── scenarios/                  # 场景定义
│   ├── new-feature.md         # 新功能开发场景
│   ├── refactor.md            # 代码重构场景
│   ├── bugfix.md              # Bug 修复场景
│   └── qa.md                  # QA/测试场景
└── README.md                   # 本文件
```

## 测试样本规范

每个测试样本是一个 Markdown 文件，包含：

```markdown
# 测试标题

## 元信息
- **Level**: 期望的 triage 级别 (0-4)
- **类型**: new-feature / refactor / bugfix / qa / mixed
- **决策点数量**: N
- **风险等级**: none / low / medium / high

## 原始输入
（这里放 Claude Code 的原始输出或模拟输出）

## 期望输出（人工审核后填写）

### 语音版
...

### HUD版
...

### 决策点
...

## 实际测试结果（自动化填写）

### Triage 输出
...

### 信息保留率
- 决策点保留: X/Y (X%)
- 风险提示保留: X/Y (X%)
- 步骤完整性: X/Y (X%)

### 质量问题
- [ ] 语音版超过30秒
- [ ] HUD超过4行
- [ ] 决策点遗漏
- [ ] 风险未识别
```

## 测试覆盖目标

### Level 0 (静默)
- [ ] Cron job 成功执行
- [ ] 备份完成
- [ ] 文件同步完成

### Level 1 (通知)
- [ ] 邮件发送成功
- [ ] 文件保存成功
- [ ] 推送完成

### Level 2 (快速决策)
- [ ] 会议时间二选一
- [ ] 简单功能开关
- [ ] 版本号选择

### Level 3 (信息决策)
- [ ] 云服务商选择
- [ ] 技术栈选型
- [ ] 第三方库评估

### Level 4 (Plan 审批)
- [x] 认证迁移 (JWT)
- [ ] 数据库迁移
- [ ] API 重构
- [ ] 前端框架升级
- [ ] 微服务拆分
- [ ] 安全加固

## 信息保留率指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 决策点保留率 | ≥95% | 不能遗漏需要用户决定的事 |
| 风险提示保留率 | 100% | 破坏性操作必须提醒 |
| 步骤完整性 | ≥90% | 关键步骤不能丢 |
| 压缩比 | 10:1 | 原文50行 → HUD 4行 |
| 语音时长 | ≤30秒 |  walking 场景可接受 |

## 运行测试并生成报告

```bash
# 完整测试流程
./scripts/run-tests.sh --full

# 生成对比报告
./scripts/generate-report.sh

# 输出示例:
# ========================================
# Jarvis Triage Test Report
# 2026-02-12 07:30:00
# ========================================
# 
# Total Samples: 25
# Passed: 22
# Failed: 3
# 
# Level 4 Plan Review:
#   - Auth Migration: PASS (决策点 2/2, 风险 1/1)
#   - Database Migration: FAIL (遗漏 rollback 步骤)
#   - API Refactor: PASS
# 
# Common Issues:
#   1. Level 3 场景有时误判为 Level 4
#   2. 中文语音版偶尔超过30秒
#   3. 多决策点场景的 HUD 更新逻辑需要优化
# ========================================
```
