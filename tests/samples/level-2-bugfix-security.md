# 测试: SQL 注入漏洞修复（Level 2 - Bug 修复场景）

## 元信息
- **Level**: 2
- **类型**: bugfix
- **决策点数量**: 1
- **风险等级**: high

## 原始输入
Bug: SQL 注入漏洞（Critical）

## 问题描述
用户搜索接口存在 SQL 注入：
```javascript
// vulnerable code
const query = `SELECT * FROM products WHERE name LIKE '%${userInput}%'`;
```

攻击示例：
```
用户输入: ' OR '1'='1
实际执行: SELECT * FROM products WHERE name LIKE '%' OR '1'='1%'
结果: 返回所有产品数据
```

## 影响范围
- 受影响接口: /api/products/search
- 潜在数据泄露: 产品表全部数据
- 是否已利用: 目前未发现，但日志显示有可疑请求

## 修复方案

### 方案 A: 参数化查询（推荐）
```javascript
// 修复代码
const query = 'SELECT * FROM products WHERE name LIKE ?';
const result = await db.query(query, [`%${userInput}%`]);
```

工作量: 30 分钟
风险: 无（标准修复方案）

### 方案 B: ORM 替换（长期方案）
将原生 SQL 替换为 Prisma ORM：
```javascript
const result = await prisma.products.findMany({
  where: { name: { contains: userInput } }
});
```

工作量: 1-2 天（涉及多个接口）
风险: 需要全面回归测试

## 紧急程度
🔴 **High** - 生产环境漏洞，建议立即修复

## 验证方式
1. 修复后使用 SQLMap 扫描确认
2. 添加安全测试用例
3. 监控日志确认无类似攻击

请确认：
1. 修复方案: 参数化查询 / ORM 替换？
2. 是否立即部署？

## 期望输出

### 判定
Level 2 - 快速决策（紧急安全修复，需要立即决定）

### 语音版
发现SQL注入漏洞。两个方案：参数化查询30分钟修复，或者ORM替换1到2天。建议立即用方案A。

### HUD版
L1: 🐛 SQL注入漏洞（Critical）
L2: A: 参数化查询（30分钟）
L3: B: ORM替换（1-2天）
L4: 建议立即修复！

### 决策点
- 决策1: 修复方案 → A: 参数化查询（快速）/ B: ORM替换（长期）
- 决策2: 部署时机 → 立即 / 维护窗口

### 压缩摘要
Critical 安全漏洞，SQL注入可导致数据泄露。
- 方案A: 参数化查询，30分钟，零风险
- 方案B: ORM替换，1-2天，需回归测试

建议立即用方案A修复并部署。

## 测试说明
测试 Level 2 紧急 Bug 修复场景，考察 triage 能否：
1. 正确识别为 Level 2（快速决策，不是复杂计划）
2. 突出紧急性（Critical 标签）
3. 给出明确建议
4. 简化技术细节，聚焦决策
