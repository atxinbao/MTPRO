# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 — GH-378 Data / Foundation Graph Review

日期：2026-06-05

执行者：Codex

GitHub Issue：[#378](https://github.com/atxinbao/MTPRO/issues/378)

类型：DataClient / DataEngine / MessageBus / Cache / Database architecture graph alignment review

## 定位

本文档复核 architecture graph 左侧 data path 和下方 state / persistence spine：

```text
DataClient -> DataEngine -> MessageBus
DataEngine -> Cache
Database / projections -> local durable facts and replay projection
```

本轮只做 review，不实现 endpoint，不迁移源码，不修改 `Package.swift`，不拆 target graph。

## 结论

当前 data / foundation graph 已经具备 architecture-aligned target 和 source root，但还不是完整 implementation ownership split：

- `DataClient` 已固定为 public read-only market data input boundary。
- `DataEngine` 已固定为 ingest / replay / quality boundary，并禁止 private stream、signed/account endpoint 和 broker path。
- `MessageBus` 已固定为只依赖 `DomainModel` 的 command / event spine。
- `Cache` 已固定为可重建 read-model state surface，不拥有 durable facts 或 broker state。
- `Database` 已固定为 durable facts / projection boundary，不暴露 UI schema、不持久化 broker/account payload。
- 真实实现仍通过 `Adapters`、`Core`、`Persistence`、`Runtime` 兼容壳编译，因此 L4 前仍需确认这些 compatibility envelopes 是否允许保留。

## Alignment matrix

| Module | Graph role | Current source root | Allowed direction | Forbidden path status | Remaining debt |
| --- | --- | --- | --- | --- | --- |
| `DataClient` | 交易所 public data 输入适配 | `Sources/DataClient` | `DomainModel` only | forbids signed endpoint, account endpoint, listenKey, private stream runtime, broker / execution adapter | Binance implementation still compiled by `Adapters` |
| `DataEngine` | public data ingest / replay / quality | `Sources/DataEngine` | `DomainModel`, `DataClient`, `MessageBus`, `Cache` | forbids Trader, Portfolio, RiskEngine, ExecutionEngine, ExecutionClient, broker, OMS and private endpoint path | Scenario / quality compiled by `Core`; ingest compiled by `Runtime` |
| `MessageBus` | command / event spine | `Sources/MessageBus` | `DomainModel` only | forbids engines, Trader, UI, broker and OMS | commands / events / event log compiled by `Core` |
| `Cache` | read-model state surface | `Sources/Cache` | `DomainModel`, `MessageBus` | forbids durable facts ownership, broker state, UI schema and private stream | market data cache compiled by `Core` |
| `Database` | durable facts / local projection boundary | `Sources/Database` | `DomainModel`, `MessageBus`, `CSQLite`, `DuckDB(macOS)` | forbids UI schema exposure, broker/account payload, runtime/live capability | SQLite / DuckDB compiled by `Persistence`; replay projection compiled by `Runtime` |

## Read-only and endpoint guard review

DataClient / DataEngine remain read-only because current target boundary anchors explicitly preserve:

- no signed endpoint;
- no account endpoint;
- no listenKey;
- no private WebSocket runtime;
- no broker or execution adapter path;
- no ExecutionClient dependency;
- no live runtime.

Database / Cache remain read-model / facts boundaries because current target anchors explicitly preserve:

- Cache does not own durable facts;
- Cache does not own broker state;
- Cache does not expose database schema;
- Database does not expose schema to Dashboard;
- Database does not persist broker or account payload.

## Dashboard / UI consumption review

The current active UI surface is `Dashboard read-model-only boundary`.

For this issue, no Dashboard source was changed. The existing boundary remains:

- Dashboard consumes read-model / ViewModel surfaces;
- Dashboard must not consume adapter request;
- Dashboard must not consume runtime object;
- Dashboard must not consume account payload;
- Dashboard must not consume broker state;
- retired `Workbench` wording should not be used as active module wording.

## L4 blocker candidates from data / foundation path

Before claiming full architecture implementation ownership, the following need explicit decision:

1. Whether `Adapters` can remain as the public market data implementation envelope or must be folded into `DataClient`.
2. Whether `Runtime` can keep `DataEngine/Ingest` and `Database/ReplayProjection` before L4, or whether these should move into target-owned implementation roots.
3. Whether `Core` can keep `MessageBus`, `Cache`, `DataEngine/ScenarioReplay`, and `DataEngine/DataQuality` implementation before L4.
4. Whether `Persistence` can keep SQLite / DuckDB implementation before L4.
5. Whether module-local `TargetGraph` directories should remain as boundary anchors or be renamed later.

## Acceptance criteria evidence

- AC1：DataClient / DataEngine / MessageBus / Cache / Database alignment status is documented above.
- AC2：Remaining envelope debt and L4 blocker candidates are listed.
- AC3：validation output is recorded in `verification.md`.

## Boundary evidence

- No Linear write.
- No downstream GitHub issue promotion.
- No Symphony / symphony-issue.
- No Graphify / code-index.
- No Figma changes.
- No business code changes.
- No `Package.swift` changes.
- No `Sources` move.
- No SwiftPM target graph split.
- No endpoint implementation.
- No Trader runtime.
- No Strategy runtime.
- No Live runtime.
- No `ExecutionClient` implementation.
- No OMS.
- No broker gateway.
- No signed endpoint.
- No account endpoint / listenKey.
- No private WebSocket runtime.
- No real order lifecycle, submit / cancel / replace, execution report, broker fill or reconciliation.
- No Live PRO Console, trading button, live command or order form.
- No L4 implementation.
