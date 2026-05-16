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

## MTP-13 SQLite / DuckDB 投影与重放边界

日期：2026-05-17

执行者：Codex

`MTPROPersistence` 在本事项中建立本地可测试的 persistence projection contract，不引入真实数据库 driver、schema migration 或 UI 直连数据库路径。

契约结构：

- `MTPROPersistenceReplayBoundary`：复用 `AppendOnlyEventLog`，按 `EventReplayCommand` 重放事件，并可重建 market cache、SQLite runtime projection 和 DuckDB analytical projection。
- `MTPROSQLiteRuntimeProjectionStore`：从 replay envelope 构建 paper session、risk rejection 和 portfolio runtime read model。
- `MTPRODuckDBAnalyticalProjectionStore`：从 replay envelope 构建 market data、backtest run、order book research run 和 analytical signal timeline。
- `MTPROPersistenceBoundary`：显式声明 UI 只能消费稳定 read model projection，不暴露 database table 或 runtime object。

契约要求：

- Event Log 仍是 append-only facts source。
- SQLite projection 只承载运行状态和轻量投影，不作为 UI 数据表契约。
- DuckDB projection 只承载行情、回测和研究分析投影，不保存运行时对象。
- 投影必须可从同一 replay envelope 确定性重建。
- UI 后续只能消费 read model projection，不得直接读取 SQLite / DuckDB schema。

本契约不包含：

- 真实 SQLite driver。
- 真实 DuckDB driver。
- schema migration。
- ORM model。
- SwiftUI 页面。
- Live execution persistence。
- broker / exchange action。
