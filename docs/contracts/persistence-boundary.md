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

`Persistence` 在本事项中建立本地可测试的 persistence projection contract，不引入真实数据库 driver、schema migration 或 UI 直连数据库路径。

契约结构：

- `PersistenceReplayBoundary`：复用 `AppendOnlyEventLog`，按 `EventReplayCommand` 重放事件，并可重建 market cache、SQLite runtime projection 和 DuckDB analytical projection。
- `SQLiteRuntimeProjectionStore`：从 replay envelope 构建 paper session、risk rejection 和 portfolio runtime read model。
- `DuckDBAnalyticalProjectionStore`：从 replay envelope 构建 market data、backtest run、order book research run 和 analytical signal timeline。
- `PersistenceBoundary`：显式声明 UI 只能消费稳定 read model projection，不暴露 database table 或 runtime object。

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

## MTP-17 文件事件日志持久化边界

日期：2026-05-18

执行者：Codex

`Persistence` 在本事项中新增 append-only event log 文件事实源边界，为后续 SQLite / DuckDB adapter 提供稳定 replay 输入，但不实现真实数据库 adapter。

契约结构：

- `FileEventLogStore`：把 Core 已验证的 `EventEnvelope` 逐条追加写入本地文件。
- `FileEventLogStore.readEnvelopes()`：读取文件事实并用 `AppendOnlyEventLog` 校验 sequence 连续性。
- `FileEventLogStore.replay(_:)`：按 `EventReplayCommand` 从文件事实源输出 `EventReplayResult`。
- `PersistenceReplayBoundary.init(fileStore:)`：从文件事件日志构建现有 replay / projection rebuild 边界。

契约要求：

- 文件事实源只接受 `EventEnvelope`，不得保存 runtime object。
- append 前必须校验现有文件事实，并只允许写入 `existing.count + 1` 对应的下一个 sequence。
- replay 输出仍是稳定事件 / read model projection 输入，不暴露文件格式。
- 文件内部编码是 `Persistence` 私有实现细节，不成为 UI、数据库 schema 或外部 API contract。
- 文件事件日志不得触发 Binance 网络、signed endpoint、broker action 或真实订单行为。

本契约不包含：

- SQLite adapter。
- DuckDB adapter。
- schema migration。
- database table API。
- SwiftUI 页面。
- Live execution persistence。
- broker / exchange side effect。
