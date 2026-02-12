# Plan Mode 处理完整示例

本文档提供多种 Claude Code Plan Mode 输出类型的 Triage 处理示例。

## 类型1：新功能开发

特征：较多技术选型决策，较少风险

### 输入（Plan Mode 输出摘要）
> 为 API 添加 Rate Limiting 功能
> 1. 选择限流库（express-rate-limit vs rate-limiter-flexible）
> 2. 创建限流中间件
> 3. 配置限流规则（需要确定：固定窗口 vs 滑动窗口）
> 4. 添加到路由
> 5. 编写测试
> 6. 添加 429 错误处理和响应头

### Triage 输出
```
🔊 语音版：
Rate limiting计划分6步，建中间件、配规则、加路由、写测试。有两个要你定的：用哪个库，还有限流策略选固定窗口还是滑动窗口。

📱 HUD版（第一个决策）：
L1: 🔧 Rate Limiting (6步)
L2: ❓ 决策1/2：限流库
L3:   A: express-rate-limit（轻量）
L4:   B: rate-limiter-flexible（灵活）

❓ 决策点：
- 决策1: 限流库选择 → express-rate-limit（轻量易用）/ rate-limiter-flexible（功能强大）
- 决策2: 限流策略 → 固定窗口（简单）/ 滑动窗口（精准）
```

## 类型2：重构 / 迁移

特征：较少选型决策，较多风险点

### 输入
> 将数据库从 MongoDB 迁移到 PostgreSQL
> 1. 创建 PostgreSQL Schema（基于现有 MongoDB collections）
> 2. 编写数据迁移脚本
>    ⚠️ 需要先全量备份 MongoDB
>    ⚠️ 迁移过程中需要停止写入（预计15分钟）
> 3. 更新 ORM 层（Mongoose → Prisma）
> 4. 修改所有查询语句（37处）
> 5. 更新环境变量和连接配置
> 6. 回归测试

### Triage 输出
```
🔊 语音版：
数据库迁移计划出来了，从MongoDB迁到PostgreSQL，分6步。没有需要你选的技术方案，但有两个风险要注意：迁移前必须全量备份，而且迁移过程中需要停写入大概15分钟。确认就可以执行。

📱 HUD版：
L1: 🔧 DB迁移 MongoDB→PG (6步)
L2: ⚠️ 需先备份MongoDB
L3: ⚠️ 停写入约15分钟
L4: 说"approve"执行 / "详细"看Plan

❓ 决策点：
无技术决策，需确认接受风险

⚠️ 风险：
- 迁移前必须全量备份 MongoDB
- 迁移过程需停止写入约15分钟
- 37处查询修改，回归测试覆盖率需关注
```

## 类型3：Bug 修复

特征：通常无决策、低风险，应简化处理

### 输入
> 修复用户头像上传后不显示的问题
> 1. 问题定位：上传成功但 CDN URL 拼接错误（少了 /avatars/ 前缀）
> 2. 修改 utils/cdn.js 中的 getAvatarUrl 函数
> 3. 添加单元测试覆盖该路径
> 4. 验证现有头像 URL 不受影响

### Triage 输出
```
🔊 语音版：
头像不显示的问题找到了，CDN地址拼接少了个前缀。改一个函数就行，加个测试，不影响现有头像。

📱 HUD版：
L1: 🐛 头像Bug：CDN路径错误
L2: 改 getAvatarUrl + 加测试
L3: 说"approve"执行

❓ 决策点：
无，可直接 approve
```

## 类型4：Claude Code QA 问答

特征：不是完整Plan，而是Claude Code在开始之前先问问题

### 输入
> 在开始之前我需要确认几个问题：
> 1. 你想用 TypeScript 还是 JavaScript？
> 2. 测试框架用 Jest 还是 Vitest？
> 3. 要不要加 ESLint + Prettier 配置？

### Triage 输出（Level 2，不是 Level 4）
```
📊 Triage Level: 2 - 快速决策

🔊 语音版：
Claude Code开始前问了三个问题：用TS还是JS，测试框架选Jest还是Vitest，要不要加代码检查配置。

📱 HUD版：
L1: ❓ Claude Code 问了3个问题
L2: 1. TS / JS？
L3: 2. Jest / Vitest？
L4: 3. ESLint+Prettier 要/不要？

❓ 决策点：
- Q1: 语言 → TypeScript / JavaScript
- Q2: 测试框架 → Jest / Vitest
- Q3: 代码规范 → 要 / 不要
```

## 处理原则总结

1. **无决策的Plan** → 简化到 "确认+风险提醒+approve"
2. **有决策的Plan** → 结构概览 + 决策串行呈现
3. **纯QA问答** → 降级为 Level 2，直接列出问题
4. **Bug修复类** → 通常可以直接 approve，重点说清楚改了什么
5. **迁移/重构类** → 决策可能少，但风险提醒是重点
