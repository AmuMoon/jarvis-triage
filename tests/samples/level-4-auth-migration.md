# 测试: JWT 认证迁移（Level 4 - Plan 审批）

## 元信息
- **Level**: 4
- **类型**: plan
- **决策点数量**: 2
- **风险等级**: high

## 原始输入
Plan: 将用户认证从 Session 迁移到 JWT

## 分析
当前使用 Express Session + Redis 存储用户状态，需要迁移到 JWT 以支持：
- 移动端 API 认证
- 微服务间无状态认证
- 第三方集成（OAuth2）

## 实施计划

### Step 1: 安装依赖
```bash
npm install jsonwebtoken bcryptjs
npm install -D @types/jsonwebtoken
```

### Step 2: 创建 JWT 中间件 (middleware/auth.js)
**需要决策1: Token 存储方式**

选项 A: HttpOnly Cookie
- 优点: 防 XSS，自动随请求发送
- 缺点: CORS 配置复杂，移动端需要 withCredentials

选项 B: LocalStorage
- 优点: 实现简单，跨域友好
- 缺点: XSS 风险，需要手动添加到请求头

推荐 Cookie（安全性优先），但需要确认。

### Step 3: 重写登录接口 (routes/auth.js)
- 生成 access token (15min) + refresh token (7d)

**需要决策2: Refresh Token 策略**

选项 A: Token Rotation
- 每次使用 refresh token 都生成新的 pair
- 更安全（被盗后只能用一次）
- 实现复杂，需要处理并发刷新

选项 B: Silent Refresh
- Refresh token 固定，只更新 access token
- 实现简单
- 风险: refresh token 被盗可长期滥用

### Step 4: 数据迁移脚本 (scripts/migrate-sessions.js)
⚠️ **风险警告**: 此步骤不可逆
- 备份现有 Redis session 数据
- 为所有活跃用户生成 JWT secret
- 清理过期 session
- **必须先备份数据库**

### Step 5: 更新前端 Token 处理
- 统一封装 API 请求，自动处理 token refresh
- 添加登出时清除 token 逻辑

### Step 6: 废弃 Session 相关代码
- 移除 express-session 中间件
- 清理 Redis 中的 session 数据
- 更新环境变量

### Step 7: 集成测试
- 登录/登出流程
- Token 过期处理
- 并发请求处理
- 移动端兼容性

## 预估工作量
- 开发: 2-3 天
- 测试: 1 天
- 迁移执行: 2 小时（需维护窗口）

## 回滚计划
如出现问题，可在 30 分钟内回滚到 Session 方案：
1. 切换环境变量启用旧认证
2. 恢复 Redis session 数据（已备份）
3. 重启服务

请确认以下决策后执行：
1. Token 存储: Cookie / LocalStorage ?
2. Refresh 策略: Rotation / Silent ?

## 期望输出

### 判定
Level 4 - Plan审批（多步骤实施计划，有依赖关系）

### 语音版
认证迁移，分7步。两个决策：token存哪里，刷新策略怎么选。数据迁移不可逆，会先备份。

### HUD版（第一个决策）
L1: 🔧 JWT迁移 Plan (7步)
L2: ❓ 决策1/2：Token存储方式
L3:   A: Cookie（安全/CORS麻烦）
L4:   B: LocalStorage（简单/XSS风险）

### 决策点
- 决策1: Token存储方式 → Cookie（更安全但CORS复杂）/ LocalStorage（简单但有XSS风险）
- 决策2: Refresh策略 → Rotation（更安全）/ Silent Refresh（更简单）

### 风险
- Step 4 数据迁移不可逆，需先备份数据库

### 压缩摘要
7步计划：
1. 安装 jsonwebtoken + bcryptjs
2. 创建 JWT 中间件 [决策1：Token存储方式]
3. 重写登录接口 [决策2：Refresh策略]
4. 数据迁移 [⚠️ 不可逆，需备份]
5. 更新前端 Token 处理
6. 废弃 Session 代码
7. 集成测试

预估3-4天工作量，需维护窗口执行迁移。

## 测试说明
这是 Jarvis Triage 的核心场景。需要：
1. 正确识别为 Level 4
2. 提取所有决策点
3. 识别破坏性操作并提醒
4. 将7步计划压缩为可管理的决策流程
