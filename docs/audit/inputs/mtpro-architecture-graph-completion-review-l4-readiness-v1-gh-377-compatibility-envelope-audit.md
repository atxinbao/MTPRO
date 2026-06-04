# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 — GH-377 Compatibility Envelope Audit

日期：2026-06-05

执行者：Codex

GitHub Issue：[#377](https://github.com/atxinbao/MTPRO/issues/377)

类型：real module source root / boundary anchor / compatibility envelope audit

## 定位

本文档审计当前 architecture graph target 与真实 source root 的完成度，区分：

- real module source root：模块目录已经存在，并承载该模块的当前源码或 future-gate 源码。
- boundary anchor：SwiftPM target 当前只编译 `TargetGraph/*TargetBoundary.swift`，用于固定 dependency direction 和 forbidden capability。
- compatibility envelope：旧目标仍承载真实实现，主要是 `Core`、`Adapters`、`Persistence`、`Runtime`。
- future gate：目录和 target 存在，但只表达未来能力边界，不实现生产能力。

本轮只做审计，不迁移实现，不修改 `Package.swift`，不移动 `Sources`。

## 当前结论

当前架构图模块已经有对应 SwiftPM target 和真实 source root，但还不能说所有实现都已经完成模块归属迁移。原因是：

- `DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader` 都已存在 target 和 source root。
- 这些架构 target 大多仍只编译模块内 `TargetGraph/*TargetBoundary.swift`。
- 真实实现大量仍在 `Core`、`Adapters`、`Persistence`、`Runtime` 兼容壳中编译。
- `Dashboard` 是当前 active UI executable，直接承载 read-model-only surface。
- `ExecutionClient` 当前是 future gate / protocol boundary，不是 broker gateway implementation。

## Module completion inventory

| Module | Source root | SwiftPM target state | Implementation owner today | Classification |
| --- | --- | --- | --- | --- |
| `DomainModel` | `Sources/DomainModel` | target exists；编译 `TargetGraph/DomainModelTargetBoundary.swift` | `Core` 编译 `DomainModel` 实现 | real root + boundary anchor + compatibility envelope |
| `MessageBus` | `Sources/MessageBus` | target exists；编译 `TargetGraph/MessageBusTargetBoundary.swift` | `Core` 编译 commands / events / event log | real root + boundary anchor + compatibility envelope |
| `Database` | `Sources/Database` | target exists；编译 `TargetGraph/DatabaseTargetBoundary.swift` | `Persistence` 编译 SQLite / DuckDB；`Runtime` 编译 replay projection | real root + boundary anchor + compatibility envelope |
| `DataClient` | `Sources/DataClient` | target exists；编译 `TargetGraph/DataClientTargetBoundary.swift` | `Adapters` 编译 Binance public market data | real root + boundary anchor + compatibility envelope |
| `DataEngine` | `Sources/DataEngine` | target exists；编译 `TargetGraph/DataEngineTargetBoundary.swift` | `Core` 编译 ScenarioReplay / DataQuality；`Runtime` 编译 Ingest | real root + boundary anchor + compatibility envelope |
| `Cache` | `Sources/Cache` | target exists；编译 `TargetGraph/CacheTargetBoundary.swift` | `Core` 编译 MarketData cache | real root + boundary anchor + compatibility envelope |
| `Portfolio` | `Sources/Portfolio` | target exists；编译 `TargetGraph/PortfolioTargetBoundary.swift` | `Core` 编译 portfolio projection evidence | real root + boundary anchor + compatibility envelope |
| `RiskEngine` | `Sources/RiskEngine` | target exists；编译 `TargetGraph/RiskEngineTargetBoundary.swift` | `Core` 编译 PreTrade / LiveGate evidence | real root + boundary anchor + compatibility envelope |
| `ExecutionClient` | `Sources/ExecutionClient` | target exists；编译 `TargetGraph/ExecutionClientTargetBoundary.swift` | `Core` 编译 FutureGate / BrokerCapabilityMatrix evidence | future gate + boundary anchor + compatibility envelope |
| `ExecutionEngine` | `Sources/ExecutionEngine` | target exists；编译 `TargetGraph/ExecutionEngineTargetBoundary.swift` | `Core` 编译 paper lifecycle / simulated exchange / OMS future gate evidence | real root + boundary anchor + compatibility envelope |
| `TraderStrategies` | `Sources/Trader/Strategies/EMA` | target exists；编译 `TargetGraph/TraderStrategiesTargetBoundary.swift` | `Core` 编译 EMA strategy evidence | real root + boundary anchor + compatibility envelope |
| `Trader` | `Sources/Trader` | target exists；编译 `TargetGraph/TraderTargetBoundary.swift` | `Core` 编译 Accounts / EMA / Coordination/RiskBinding evidence | real root + boundary anchor + compatibility envelope |
| `Dashboard` | `Sources/Dashboard` | executable target compiles active UI/read-model source | `Dashboard` target | active real module source root |

## Compatibility envelope audit

| Envelope | Current compiled source ownership | Why it remains | L4 readiness implication |
| --- | --- | --- | --- |
| `Core` | DomainModel, MessageBus, Cache, Trader, TraderStrategies/EMA, Portfolio, RiskEngine, ExecutionEngine, ExecutionClient future-gate evidence, DataEngine scenario / data-quality evidence | Preserves current test/import surface while architecture targets are being separated | Main blocker for claiming full implementation ownership per architecture module |
| `Adapters` | `Sources/DataClient/Binance/PublicMarketData` | Keeps public read-only adapter implementation isolated from signed/broker capabilities | DataClient target is not yet the implementation owner |
| `Persistence` | `Sources/Database/Projections/SQLite`, `Sources/Database/Projections/DuckDB` | Keeps SQLite / DuckDB projection implementation and tests stable | Database target is not yet the implementation owner |
| `Runtime` | `Sources/Database/ReplayProjection`, `Sources/DataEngine/Ingest` | Keeps ingest / replay projection workflow isolated from live runtime | DataEngine / Database runtime-adjacent source ownership still needs review before L4 |

## Retired active paths check

Current active root check confirms:

- `Sources/TargetGraph` top-level directory is not present.
- `Sources/Workbench` is not present.
- `Sources/AppCompatibility` is not present.
- `Sources/Strategies` is not present.
- `Sources/Trader/StrategyBindings` is not present.

The remaining `TargetGraph/` directories are module-local boundary anchors, not top-level active architecture modules.

## Architecture completion implication

The current state is suitable for L4 readiness planning only after the next issues decide:

- whether retained compatibility envelopes are acceptable as pre-L4 compatibility scaffolding;
- whether some implementation ownership must move from `Core` / `Adapters` / `Persistence` / `Runtime` into architecture targets before L4;
- whether module-local `TargetGraph` naming should be kept as boundary-anchor evidence or renamed later;
- how much of `ExecutionClient` should remain future-gated before any broker / OMS work is planned.

## Acceptance criteria evidence

- AC1：`Core`、`Adapters`、`Persistence`、`Runtime` compatibility envelope ownership gaps are listed above.
- AC2：real source roots, boundary anchors, future gates and compatibility envelopes are separated in the module inventory.
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
