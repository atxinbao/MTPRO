# Persistence Boundary

日期：2026-05-18

执行者：Codex

## 存储角色

| 存储 | 角色 | 说明 |
| --- | --- | --- |
| Event Log | facts source | append-only 事实源，所有 projection 可从它重建 |
| SQLite | runtime state projection | paper session、risk rejection、portfolio projection 等轻量运行态投影 |
| DuckDB | analytical projection | market data、backtest、research signal、analysis timeline 投影 |

## 永久规则

- 数据库只保存 facts 或 projection。
- Event Log 是 append-only facts source。
- SQLite / DuckDB projection disposable：projection 可删除并由 Event Log deterministic rebuild。
- 数据库不作为页面展示模型。
- 前端不得直接读取 database table、SQL row、schema、ORM model 或 runtime object。
- Persistence 不触发 Binance 网络、signed endpoint、broker action 或真实订单行为。

## 已完成事项压缩表

| Issue | 边界 | 契约摘要 | 不包含 |
| --- | --- | --- | --- |
| MTP-13 | SQLite / DuckDB 投影与重放边界 | `PersistenceReplayBoundary` 复用 `AppendOnlyEventLog`，按 replay command 重建 market cache、SQLite runtime projection、DuckDB analytical projection | 真实 DB driver、schema migration、ORM、UI 直连、Live execution persistence |
| MTP-17 | 文件事件日志持久化边界 | `FileEventLogStore` 逐条追加 `EventEnvelope`，读取时校验 sequence 连续性，replay 输出稳定 projection input | SQLite / DuckDB adapter、database table API、broker side effect |
| MTP-18 | SQLite 运行时投影适配器边界 | `SQLiteRuntimeProjectionAdapter` rebuild / query snapshot；SQLite 只保存 paper session、risk rejection、portfolio projection 副本 | 完整 schema、migration framework、ORM、UI 直接读库 |
| MTP-19 | DuckDB 分析投影适配器边界 | `DuckDBAnalyticalProjectionAdapter` rebuild / query snapshot；DuckDB 只保存 market data、backtest、research signal timeline 副本 | runtime adapter 扩展、UI 直接读库、Live execution persistence |
| MTP-21 | Ingest Replay Projection 边界 | market data ingest 写入 `FileEventLogStore`，再通过 `PersistenceReplayBoundary` 重建 projection snapshots | 多 run 未定义续写、signed endpoint、broker action |
| MTP-58 | Market Data Replay Event Log / Projection Consistency | replay event log 与 projection freshness / consistency evidence 对齐 | production ingestion platform、real broker stream |
| MTP-28 | Risk Blocker / Portfolio Exposure Runtime Projection | risk blocker 与 portfolio exposure 进入 runtime projection read model | live account state、broker exposure sync |
| MTP-34 | Paper-only Portfolio Projection Update Runtime Projection | paper-only portfolio update 由 event facts 重建 | real account / real PnL runtime |
| MTP-35 | Paper Session Replay Evidence Persistence | paper session replay evidence 保持可追溯 | broker fill、real reconciliation |
| MTP-42 | Paper Execution Replay Projection Persistence | paper execution lifecycle 进入 replay projection | execution report、real order lifecycle |

## Query Snapshot Contract

Projection adapter 对外只返回稳定 snapshot：

- `SQLiteRuntimeProjectionSnapshot`
- `DuckDBAnalyticalProjectionSnapshot`
- paper / risk / portfolio / market / backtest / research read model

禁止返回：

- table / column / SQL row
- file format
- ORM entity
- runtime object
- adapter request
- broker/account state

## 验证边界

Persistence 验证只证明本地 append-only facts、deterministic replay 和 projection rebuild 可用；不证明 production database、external data platform、signed endpoint、broker gateway、LiveExecutionAdapter、OMS 或 production trading 已实现。
