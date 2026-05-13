# Persistence Boundary

Persistence Boundary 必须先于真实 database adapter 实现。

## 存储角色

| 存储 | 角色 | 说明 |
| --- | --- | --- |
| Event Log | facts | append-only 事实源 |
| SQLite | runtime state projection | 配置、订单、组合、会话状态等轻量投影 |
| DuckDB | analytical projection | market data、backtest、研究分析 |

## 规则

- 数据库只保存 facts 或 projection。
- 数据库不作为页面展示模型。
- 前端不得直接读取数据库表。
- runtime object 不得直接持久化为 UI contract。

## 当前状态

当前只定义边界，不实现 adapter。
