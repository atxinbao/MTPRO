# MTPRO Real Target Source Ownership / Core Envelope Retirement Contract

日期：2026-06-05

执行者：Codex

本文档服务 GitHub fallback issue `GH-391 Define real target ownership and dependency direction contract`。它只定义 real target source ownership、retained compatibility envelope、target dependency correction 和后续 migration / validation 顺序；不修改 `Package.swift`，不移动 `Sources`，不写业务代码，不实现 runtime / live / broker / L4 capability。

## GH-391-REAL-TARGET-OWNERSHIP-CONTRACT

当前 MTPRO 已完成 architecture-graph-aligned source roots 和 SwiftPM target names 的主体对齐，但这不等于所有真实实现已经由对应 module target 独立承载。当前状态必须拆成四类：

| 类型 | 含义 | 当前例子 |
| --- | --- | --- |
| Real module source root | 最终模块目录和后续实现归属目标。 | `Sources/Trader/`、`Sources/DataEngine/`、`Sources/ExecutionEngine/`。 |
| Target boundary anchor | SwiftPM target 当前可编译的边界声明 / validation anchor。 | `Sources/*/TargetGraph/*TargetBoundary.swift`。 |
| Retained compatibility envelope | 仍承载既有 implementation / import surface 的过渡 target。 | `Core`、`Adapters`、`Persistence`、`Runtime`。 |
| Future gate | 只表达未来能力边界，不实现当前能力。 | `ExecutionClient` broker / exchange outgoing adapter boundary。 |

GH-391 的目标是先固定这四类语言，避免把 target name 或 boundary anchor 误读成 implementation ownership 已完成。

## GH-391-CURRENT-BLOCKERS

当前阻塞 L4 readiness 的主要问题是：

- 多数 architecture target 已存在，但很多 target 只编译 module-local `TargetGraph/*TargetBoundary.swift`，真实 implementation 仍由 `Core`、`Adapters`、`Persistence` 或 `Runtime` compatibility envelope 承载。
- GH-392 已移除 direct `Trader -> ExecutionEngine` target dependency。该 before-state 只能作为 GH-391 / MTP-220 历史 evidence；当前目标方向是 Trader 只管理 account context、EMA strategy proposal 和 coordination evidence，下游 Risk / Execution context 通过 contract / MessageBus / read-model evidence 消费，不让 Trader 直接拥有 ExecutionEngine implementation。
- `TargetGraphTests` 当前主要证明 target boundary anchors、allowed dependency strings 和 active path retirement，不足以证明每个 target 能独立 import 并使用自己的核心类型。
- Dashboard active source 中仍存在 Workbench 历史命名 residue；后续应单独清理到 `Dashboard read-model-only boundary` 口径。
- 大文件仍集中在 `Sources/Core/LiveTradingBoundary.swift` 和 `Sources/Dashboard/ReadModels/App.swift` 等 compatibility / read-model surfaces，需要后续按子边界拆文件，但不能和 target ownership migration 混在同一个 issue。
- `try!` / `preconditionFailure` 仍大量出现在 deterministic fixture / evidence helper 中。后续需要验证规则，确保它们不会进入 runtime-facing path。

## GH-391-AUTHORITATIVE-TARGET-OWNERSHIP-MODEL

当前 authoritative target names 是：

```text
DomainModel
MessageBus
Database
DataClient
Cache
DataEngine
TraderStrategies
Trader
Portfolio
RiskEngine
ExecutionClient
ExecutionEngine
Dashboard
```

当前 authoritative source ownership target 是：

```text
Sources/DomainModel/
Sources/MessageBus/
Sources/Database/
Sources/DataClient/
Sources/Cache/
Sources/DataEngine/
Sources/Trader/Strategies/EMA/
Sources/Trader/
Sources/Portfolio/
Sources/RiskEngine/
Sources/ExecutionClient/
Sources/ExecutionEngine/
Sources/Dashboard/
```

当前 active strategy only `EMA`，canonical path only `Sources/Trader/Strategies/EMA/`。`Trader = Accounts + Strategies/EMA + Coordination`。`ExecutionClient` remains future gate / protocol boundary only; it is not a broker gateway, OMS implementation, signed endpoint client, account endpoint client, listenKey runtime, private WebSocket runtime, order submit / cancel / replace client, execution report parser, broker fill parser or reconciliation runtime.

## GH-391-DEPENDENCY-DIRECTION-CORRECTION

GH-391 登记的 `Trader -> ExecutionEngine` correction blocker 已由 GH-392 处理。当前 `Package.swift` 中 `Trader` target 不再直接依赖 `ExecutionEngine`。

后续目标方向：

```text
Trader = Accounts + Strategies/EMA + Coordination
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
RiskEngine -> Portfolio / Cache / MessageBus / DomainModel
ExecutionEngine -> RiskEngine / Portfolio / Cache / MessageBus / DomainModel / ExecutionClient future-gate vocabulary
ExecutionClient -> DomainModel / MessageBus future-gate vocabulary only
```

大白话：Trader 负责组织账户、策略和协调上下文；策略只产出 proposal / signal；RiskEngine 做风险门；ExecutionEngine 处理 paper / simulated execution lifecycle；ExecutionClient 未来才可能负责把订单发到外部 broker / exchange。Trader 不应该直接拥有 ExecutionEngine implementation。

## GH-391-REAL-TARGET-SMOKE-TEST-CONTRACT

后续 real target smoke tests 不能只检查 `Package.swift` 字符串或 boundary struct。它们必须证明对应 target 能独立 import 并使用该 target 自己拥有的核心类型。

后续 smoke-test expectation：

- Foundation：只 import `DomainModel` / `MessageBus` / `Database`，能使用领域值对象、event / command envelope 和 event-log / projection contract。
- Data：只 import `DataClient` / `DataEngine` / `Cache`，能使用 public read-only venue data boundary、ingest / replay / quality contract 和 cache read-model contract。
- Trader / Portfolio / Risk：只 import `TraderStrategies` / `Trader` / `Portfolio` / `RiskEngine`，能使用 EMA strategy signal / proposal、account context、coordination evidence、portfolio projection 和 risk gate contract。
- Execution：只 import `ExecutionEngine` / `ExecutionClient`，能使用 paper / simulated lifecycle boundary 和 ExecutionClient future-gate vocabulary；不能 create broker gateway, OMS, signed endpoint or live order command.
- Dashboard：只 import / build `Dashboard` read-model-only surface，不能读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload or broker state.

## GH-391-MIGRATION-SEQUENCE

后续 issue 顺序固定为：

1. `GH-392` Remove direct Trader to ExecutionEngine target dependency. Done：current `Trader` allowed dependencies are `DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine`.
2. `GH-393` Add real target smoke tests for foundation targets.
3. `GH-394` Migrate DomainModel and MessageBus implementation ownership out of Core.
4. `GH-395` Add real target smoke tests for data targets.
5. `GH-396` Migrate DataClient / DataEngine / Cache implementation ownership out of Core / Adapters / Runtime.
6. `GH-397` Add real target smoke tests for Trader / Portfolio / Risk / Execution boundaries.
7. `GH-398` Migrate Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient implementation ownership.
8. `GH-399` Clean Dashboard Workbench naming residue.
9. `GH-400` Add try! and preconditionFailure allowed-path validation.
10. `GH-401` Close Core envelope retirement matrix / stage audit input.

每个 migration issue 都必须保持 WIP=1，并且只能在前置 PR merged、required check `checks` success、main fast-forward 后执行。

## GH-391-CORE-ENVELOPE-RETIREMENT-RULE

`Core`、`Adapters`、`Persistence` 和 `Runtime` 当前仍是 retained compatibility envelopes。后续 retirement 只能按目标模块逐段进行：

- 先加 real target smoke tests，证明目标 target 可独立使用核心类型。
- 再迁移 implementation ownership。
- 再更新 compatibility envelope exclude / dependency。
- 最后清理 stale docs / validation anchors。

不能为了“看起来完成架构拆分”而直接删除 `Core` 或一次性移动大批实现。任何 source move 都必须由对应 issue 明确授权。

## GH-391-FORBIDDEN-CAPABILITY-GUARD

GH-391 和后续 Core envelope retirement planning 不授权：

- Trader runtime、Strategy runtime、Live runtime。
- ExecutionClient implementation、OMS、broker gateway。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- real account read、real order lifecycle、submit / cancel / replace。
- execution report、broker fill、reconciliation。
- Live PRO Console、trading button、live command、order form。
- L4 implementation。
- Symphony / symphony-issue、Graphify / code-index、Figma。
- `.codex/*`、`.build/*`、`graphify-out/*` 提交。

## GH-391-VALIDATION-ANCHORS

GH-391 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-391 readiness anchors：

- `GH-391-REAL-TARGET-OWNERSHIP-CONTRACT`
- `GH-391-CURRENT-BLOCKERS`
- `GH-391-AUTHORITATIVE-TARGET-OWNERSHIP-MODEL`
- `GH-391-DEPENDENCY-DIRECTION-CORRECTION`
- `GH-391-REAL-TARGET-SMOKE-TEST-CONTRACT`
- `GH-391-MIGRATION-SEQUENCE`
- `GH-391-CORE-ENVELOPE-RETIREMENT-RULE`
- `GH-391-FORBIDDEN-CAPABILITY-GUARD`
- `GH-391-VALIDATION-ANCHORS`

## GH-392-TRADER-NO-DIRECT-EXECUTIONENGINE-DEPENDENCY

GH-392 退休了 GH-391 记录的 direct `Trader -> ExecutionEngine` correction blocker：

- `Package.swift` 的 `Trader` target dependency list 只保留 `DomainModel`、`MessageBus`、`Cache`、`TraderStrategies`、`Portfolio` 和 `RiskEngine`。
- `Sources/Trader/TargetGraph/TraderTargetBoundary.swift` 不再 `import ExecutionEngine`，也不再保存 `executionEngineBoundary`。
- `TraderTargetBoundary.requiredForbiddenDependencies` 显式包含 `ExecutionEngine`，表示 direct target dependency 已被禁止。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 增加 `testGH392TraderTargetPackageDoesNotDependDirectlyOnExecutionEngine`，用源码级断言防止 Package.swift 和 Trader boundary 回退。

## GH-392-TRADER-PROPOSAL-MESSAGEBUS-COORDINATION-BOUNDARY

Trader 当前只表达 `Accounts + Strategies/EMA + Coordination` 容器。EMA strategy 只产出 signal / proposal / evidence；RiskEngine / ExecutionEngine 是下游 context，通过 contract / MessageBus / read-model evidence 消费，不由 Trader 直接拥有 ExecutionEngine implementation。

## GH-393-FOUNDATION-REAL-TARGET-SMOKE-TESTS

GH-393 开始把 foundation target 从“只有 target boundary anchor”推进到“target 内存在可独立 import / compile / use 的最小真实 API”：

- `DomainModel` target 编译 `Sources/DomainModel/FoundationTargetOwnership.swift`，暴露 `FoundationTargetID`、`FoundationTargetSourceOwnership` 和 shared foundation smoke error vocabulary。
- `MessageBus` target 编译 `Sources/MessageBus/FoundationMessageStream.swift`，依赖 `DomainModel`，暴露本地 `FoundationMessageTopic`、`FoundationMessageEnvelope` 和 append-only `FoundationMessageStream`。
- `Database` target 编译 `Sources/Database/FoundationDatabaseCheckpoint.swift`，依赖 `DomainModel` / `MessageBus`，暴露本地 monotonic projection checkpoint。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 增加 `testGH393FoundationTargetsExposeRealAPIsBeyondBoundaryAnchors`，直接 import `DomainModel`、`MessageBus` 和 `Database` 并使用上述 public APIs。

这些 smoke APIs 只证明 foundation targets 已经拥有可调用的最小真实 source ownership。它们不替代仍由 `Core` / `Persistence` compatibility envelope 承载的完整 DomainModel、MessageBus、event log、projection 或 database implementation。

## GH-393-FOUNDATION-COMPATIBILITY-ENVELOPE-PRESERVED

GH-393 只把三个最小 smoke files 从 compatibility envelopes 中排除，避免 SwiftPM source overlap：

- `Core` exclude `DomainModel/FoundationTargetOwnership.swift`。
- `Core` exclude `MessageBus/FoundationMessageStream.swift`。
- `Persistence` / `Runtime` exclude `FoundationDatabaseCheckpoint.swift`。

`Core`、`Persistence` 和 `Runtime` 仍保留为 compatibility envelopes；GH-393 不迁移完整 implementation ownership，不拆 runtime，不改 behavior。

## GH-393-FOUNDATION-NO-RUNTIME-LIVE-BROKER-L4-GUARD

GH-393 不授权：

- Trader runtime、Strategy runtime、Live runtime。
- ExecutionClient implementation、OMS、broker gateway。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- real account read、real order lifecycle、submit / cancel / replace。
- execution report、broker fill、reconciliation。
- Live PRO Console、trading button、live command、order form。
- L4 implementation。

## GH-393-FOUNDATION-VALIDATION-ANCHORS

GH-393 required validation：

- `swift test --filter TargetGraphTests/testGH393FoundationTargetsExposeRealAPIsBeyondBoundaryAnchors`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## GH-394-DOMAINMODEL-MESSAGEBUS-IMPLEMENTATION-OWNERSHIP

GH-394 把 foundation implementation ownership 从 `Core` compatibility envelope 进一步迁回真实 targets：

- `DomainModel` target 直接编译 `CoreBaseline.swift`、`MarketPrimitives.swift`、`MarketDataModels.swift`、`DomainModelContractError.swift` 和 `FoundationTargetOwnership.swift`。
- `Core` target 不再把 `Sources/DomainModel` 作为 source directory 编译，只依赖 `DomainModel` 并通过 `DomainModelCompatibilityImport.swift` 保留旧 `import Core` 可见性。
- Foundation value object validation errors are owned by `DomainModelContractError`; `Core` compatibility preserves value visibility, not `CoreError` as the foundation error owner.
- `MessageBus` target 直接编译 `MessageBusAppendOnlyJournal.swift` 和 `FoundationMessageStream.swift`。
- `MessageBusAppendOnlyJournal` 只表达中立 append-only journal，不引用 Trader、RiskEngine、ExecutionEngine、ExecutionClient、broker payload、account payload、OMS、Live runtime 或 UI command。

## GH-394-CORE-COMPATIBILITY-ENVELOPE-PRESERVED

GH-394 没有一次性迁移所有 MessageBus rich events / commands：

- `CommandsAndQueries.swift`、`DomainEvents.swift`、`EventLog.swift` 和 `PaperRuntimeBusRouting.swift` 仍留在 `Core` compatibility envelope，因为它们当前引用 paper、strategy、portfolio、risk、execution 等下游 payload。
- 这些 rich event / command 类型的 ownership 需要后续按依赖方向拆解，不能在 foundation issue 中反向塞进 `MessageBus` target。
- `Core` 仍是兼容导入面，不再是 DomainModel primary source owner。

## GH-394-VALIDATION-ANCHORS

GH-394 required validation：

- `swift build --target DomainModel`
- `swift build --target MessageBus`
- `swift build --target Core`
- `swift test --filter TargetGraphTests/testGH394DomainModelAndMessageBusOwnRealImplementationSource`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-394 readiness anchors：

- `GH-394-DOMAINMODEL-MESSAGEBUS-IMPLEMENTATION-OWNERSHIP`
- `GH-394-DOMAINMODEL-REAL-IMPLEMENTATION-OWNERSHIP`
- `GH-394-MESSAGEBUS-NEUTRAL-JOURNAL-OWNERSHIP`
- `GH-394-CORE-COMPATIBILITY-ENVELOPE-PRESERVED`
- `GH-394-VALIDATION-ANCHORS`

## GH-395-DATA-TARGET-REAL-SMOKE-TESTS

GH-395 把 data targets 从“只有 target boundary anchor”推进到“target 内存在可独立 import / compile / use 的最小真实 API”：

- `DataClient` target 编译 `Sources/DataClient/DataClientReadOnlyMarketDataSource.swift`，暴露 Binance public read-only source identity、symbol、timeframe 和 dataset version。
- `Cache` target 编译 `Sources/Cache/CacheReadModelSnapshot.swift`，依赖 `DomainModel` / `MessageBus`，暴露可由 replay 重建的 read-model snapshot。
- `DataEngine` target 编译 `Sources/DataEngine/DataEngineReadOnlyReplayPlan.swift`，依赖 `DomainModel` / `DataClient` / `MessageBus` / `Cache`，暴露 public data ingest / replay plan。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 增加 `testGH395DataTargetsExposeRealAPIsBeyondBoundaryAnchors`，直接 import `DataClient`、`DataEngine` 和 `Cache` 并使用上述 public APIs。

这些 smoke APIs 只证明 data targets 已经拥有可调用的最小真实 source ownership。它们不替代仍由 `Adapters`、`Core` 和 `Runtime` compatibility envelope 承载的完整 DataClient adapter、DataEngine ingest / replay / quality 或 Cache market-data implementation。

## GH-395-DATA-COMPATIBILITY-ENVELOPE-PRESERVED

GH-395 不迁移完整 implementation ownership：

- `Adapters` 仍承载 `Sources/DataClient/Binance/PublicMarketData/`。
- `Core` 仍承载 `Sources/Cache/MarketData/`、`Sources/DataEngine/ScenarioReplay/` 和 `Sources/DataEngine/DataQuality/`。
- `Runtime` 仍承载 `Sources/DataEngine/Ingest/`。

后续 GH-396 才处理 DataClient / DataEngine / Cache implementation ownership migration。本 issue 不实现 streaming runtime、private stream、signed/account endpoint、listenKey、broker path、ExecutionClient implementation、OMS、real order lifecycle 或 L4 capability。

## GH-395-DATA-VALIDATION-ANCHORS

GH-395 required validation：

- `swift build --target DataClient`
- `swift build --target Cache`
- `swift build --target DataEngine`
- `swift test --filter TargetGraphTests/testGH395DataTargetsExposeRealAPIsBeyondBoundaryAnchors`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-395 readiness anchors：

- `GH-395-DATA-TARGET-REAL-SMOKE-TESTS`
- `GH-395-DATACLIENT-REAL-TARGET-SMOKE`
- `GH-395-CACHE-REAL-TARGET-SMOKE`
- `GH-395-DATAENGINE-REAL-TARGET-SMOKE`
- `GH-395-DATA-COMPATIBILITY-ENVELOPE-PRESERVED`
- `GH-395-DATA-VALIDATION-ANCHORS`

## GH-396-DATA-TARGET-IMPLEMENTATION-OWNERSHIP

GH-396 将 data targets 从 smoke API 推进到 partial implementation ownership：

- `DataClient` target 直接编译 `Sources/DataClient/Binance/PublicMarketData/` 的 Binance public read-only implementation 和 `DataClientReadOnlyMarketDataSource.swift`。
- `Adapters` target 退为 `DataClient` compatibility re-export，只编译 `Sources/DataClient/AdaptersCompatibility.swift`，不再拥有 Binance public market data implementation。
- `Cache` target 直接编译 `Sources/Cache/MarketData/MarketDataCache.swift`、`Sources/Cache/MarketData/OrderBookReadModel.swift`、`Sources/Cache/MarketData/CacheContractError.swift` 和 `CacheReadModelSnapshot.swift`。
- `Core` target 通过 `DomainModelCompatibilityImport.swift` re-export `Cache`，并只保留 `MarketDataCacheCoreReplayCompatibility.swift` 作为旧 `EventEnvelope` replay helper bridge。
- `DataEngine` target 仍只拥有 `DataEngineReadOnlyReplayPlan.swift`；`ScenarioReplay` / `DataQuality` 仍由 `Core` compatibility envelope 承载，`Ingest` 仍由 `Runtime` compatibility envelope 承载。

该 issue 不实现 streaming DataEngine runtime、private stream、signed/account endpoint、listenKey、broker path、ExecutionClient implementation、OMS、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP

`DataClient` 是 Binance public read-only implementation owner。验证必须证明：

- `Package.swift` 的 `DataClient` target 编译 `Binance/PublicMarketData/Adapters.swift` 和 replay/freshness/parity public read-only implementation files。
- `Adapters` target 只依赖 `DataClient`，并只编译 `AdaptersCompatibility.swift`。
- `Sources/DataClient/TargetGraph/DataClientTargetBoundary.swift` 包含 `GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP` 和 `GH-396-ADAPTERS-REEXPORT-ONLY`。

## GH-396-CACHE-MARKETDATA-IMPLEMENTATION-OWNERSHIP

`Cache` 是 market-data cache / order-book read-model implementation owner。验证必须证明：

- `Package.swift` 的 `Cache` target 编译 `MarketData/MarketDataCache.swift`、`MarketData/OrderBookReadModel.swift` 和 `MarketData/CacheContractError.swift`。
- `Core` target 不再编译 `Cache/MarketData`，只通过 compatibility import / helper bridge 保留旧调用面。
- `Sources/Cache/TargetGraph/CacheTargetBoundary.swift` 包含 `GH-396-CACHE-MARKETDATA-IMPLEMENTATION-OWNERSHIP` 和 `GH-396-CORE-CACHE-REEXPORT-ONLY`。

## GH-396-DATAENGINE-COMPATIBILITY-ENVELOPE-DOCUMENTED

GH-396 不把 DataEngine scenario replay / data quality / ingest 伪装成已经完全迁移：

- `DataEngine` target 继续编译 `DataEngineReadOnlyReplayPlan.swift`。
- `Sources/DataEngine/ScenarioReplay/` 和 `Sources/DataEngine/DataQuality/` 仍在 `Core` compatibility envelope 中，因为它们仍依赖 `CoreError` 和 legacy evidence payload。
- `Sources/DataEngine/Ingest/` 仍在 `Runtime` compatibility envelope 中，因为它仍负责跨 DataClient / Persistence workflow 编排。
- `Sources/DataEngine/TargetGraph/DataEngineTargetBoundary.swift` 必须包含 `GH-396-DATAENGINE-REPLAY-QUALITY-COREERROR-ENVELOPE-DOCUMENTED` 和 `GH-396-DATAENGINE-INGEST-RUNTIME-ENVELOPE-DOCUMENTED`。

## GH-396-VALIDATION-ANCHORS

GH-396 required validation：

- `swift build --target DataClient`
- `swift build --target Cache`
- `swift build --target DataEngine`
- `swift build --target Core`
- `swift test --filter TargetGraphTests/testGH396DataClientAndCacheOwnImplementationSourceWhileDataEngineEnvelopeIsExplicit`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-396 readiness anchors：

- `GH-396-DATA-TARGET-IMPLEMENTATION-OWNERSHIP`
- `GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP`
- `GH-396-CACHE-MARKETDATA-IMPLEMENTATION-OWNERSHIP`
- `GH-396-DATAENGINE-COMPATIBILITY-ENVELOPE-DOCUMENTED`
- `GH-396-DATAENGINE-REPLAY-QUALITY-COREERROR-ENVELOPE-DOCUMENTED`
- `GH-396-DATAENGINE-INGEST-RUNTIME-ENVELOPE-DOCUMENTED`
- `GH-396-VALIDATION-ANCHORS`

## GH-397-TRADER-PORTFOLIO-RISK-EXECUTION-REAL-SMOKE-TESTS

GH-397 为 Trader / Portfolio / Risk / Execution targets 建立 real target smoke test baseline。验证必须证明：

- `Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `TraderStrategies`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionClient` 和 `ExecutionEngine`。
- `testGH397TraderPortfolioRiskExecutionTargetsExposeUsableBoundaryAPIs` 能读取并断言这些 targets 的 public boundary APIs。
- 该 smoke test 验证 target dependency direction、EMA-only strategy boundary、Trader no-direct-execution boundary、Portfolio / Risk pre-execution boundary、ExecutionClient future gate 和 ExecutionEngine paper / simulated lifecycle boundary。

GH-397 不迁移 implementation ownership，不移动 source，不修改 `Package.swift` target graph。它只证明 targets 已具备可独立 import / compile / use 的 boundary APIs，为 GH-398 implementation migration 提供 baseline。

## GH-397-TRADER-EMA-COORDINATION-SMOKE

Trader-side smoke requirements：

- `Trader = Accounts + Strategies/EMA + Coordination`。
- `TraderTargetBoundary` must expose `GH-397-TRADER-REAL-TARGET-SMOKE`。
- `TraderStrategiesTargetBoundary` must expose `GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE`。
- `TraderStrategies` active concrete strategies remain exactly `["EMA"]`。
- Non-EMA active strategy roots remain empty.
- `Trader` target must not depend on `ExecutionEngine` or `ExecutionClient`.

## GH-397-PORTFOLIO-RISK-PREEXECUTION-SMOKE

Portfolio / Risk smoke requirements：

- `PortfolioTargetBoundary` must expose `GH-397-PORTFOLIO-REAL-TARGET-SMOKE`。
- `RiskEngineTargetBoundary` must expose `GH-397-RISKENGINE-REAL-TARGET-SMOKE`。
- `Portfolio` must remain financial state projection boundary only.
- `RiskEngine` must remain pre-execution guard only.
- Neither target may read broker / account payload or route executable order command.

## GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE

Execution smoke requirements：

- `ExecutionClientTargetBoundary` must expose `GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE`。
- `ExecutionEngineTargetBoundary` must expose `GH-397-EXECUTIONENGINE-REAL-TARGET-SMOKE`。
- `ExecutionClient` remains future gate / protocol boundary only.
- `ExecutionEngine` remains paper / simulated lifecycle boundary only.
- No broker gateway, OMS, signed endpoint, account endpoint / listenKey, private WebSocket runtime, submit / cancel / replace, execution report, broker fill or reconciliation implementation is authorized.

## GH-397-COMPATIBILITY-ENVELOPE-PRESERVED

GH-397 keeps these retained compatibility envelopes explicit:

- Trader / TraderStrategies implementation remains under `Core` compatibility envelope until GH-398.
- Portfolio implementation remains under `Core` compatibility envelope until GH-398.
- RiskEngine implementation remains under `Core` compatibility envelope until GH-398.
- ExecutionEngine / ExecutionClient implementation remains under `Core` compatibility envelope until GH-398.

This issue must not claim implementation ownership migration. It only adds smoke coverage and boundary anchors.

## GH-397-VALIDATION-ANCHORS

GH-397 required validation：

- `swift test --filter TargetGraphTests/testGH397TraderPortfolioRiskExecutionTargetsExposeUsableBoundaryAPIs`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-397 readiness anchors：

- `GH-397-TRADER-PORTFOLIO-RISK-EXECUTION-REAL-SMOKE-TESTS`
- `GH-397-TRADER-EMA-COORDINATION-SMOKE`
- `GH-397-TRADER-REAL-TARGET-SMOKE`
- `GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE`
- `GH-397-PORTFOLIO-REAL-TARGET-SMOKE`
- `GH-397-RISKENGINE-REAL-TARGET-SMOKE`
- `GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE`
- `GH-397-EXECUTIONENGINE-REAL-TARGET-SMOKE`
- `GH-397-COMPATIBILITY-ENVELOPE-PRESERVED`
- `GH-397-VALIDATION-ANCHORS`

## GH-398-TRADER-RISK-EXECUTION-IMPLEMENTATION-OWNERSHIP

GH-398 将 Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient 从 smoke coverage 推进到 partial implementation ownership：

- `TraderStrategies` 保持 `EMA` 为唯一 active concrete strategy。
- Strategy signal / proposal shared contracts moved to `MessageBus`，不再落在 strategy source 内部。
- `Trader` 保持 `Accounts + Strategies/EMA + Coordination` 容器，不直接依赖 `ExecutionEngine` 或 `ExecutionClient`。
- `Portfolio` owns financial state projection boundary。
- `RiskEngine` owns pre-trade risk ownership boundary。
- `ExecutionEngine` owns paper / simulated lifecycle ownership boundary。
- `ExecutionClient` remains future gate / protocol boundary only。

GH-398 不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation 或 L4 capability。

## GH-399-DASHBOARD-READ-MODEL-ONLY-NAMING-CLEANUP

GH-399 清理 active Dashboard source 中的 Workbench naming residue：

- Active UI surface 统一为 `Dashboard read-model-only boundary`。
- `Workbench` / `AppCompatibility` 不再作为 active module 口径。
- Historical docs 可保留旧项目名，但 active source / contract / validation wording 必须避免把 Workbench 写成当前 active module。

## GH-400-UNSAFE-CONSTRUCT-ALLOWED-PATH-VALIDATION

GH-400 增加 `try!` / `preconditionFailure` allowed-path validation：

- `Tests/TargetGraphTests/TargetGraphTests.swift` 扫描 `Sources` / `Tests` 中的 Swift source。
- `Tests/` 默认允许 deterministic assertion / fixture usage。
- `Sources/` 只允许 deterministic fixture、evidence、future gate、read-model-only guard、paper / simulated boundary 等显式白名单路径。
- Runtime-facing path 不得新增未经授权的 `try!` 或 `preconditionFailure`。

## GH-401-CORE-ENVELOPE-RETIREMENT-MATRIX-STAGE-AUDIT-INPUT

GH-401 只收口 project-level matrix 和 Stage Code Audit input material：

- Canonical stage audit input file：`docs/audit/inputs/mtpro-real-target-source-ownership-core-envelope-retirement-v1-stage-audit-input.md`。
- `GH-401-ISSUE-EVIDENCE-CHAIN` 汇总 GH-391 到 GH-401 的 evidence chain。
- `GH-401-CORE-ENVELOPE-RETIREMENT-MATRIX` 明确哪些 implementation ownership 已迁移，哪些 envelope 仍保留。
- `GH-401-RETAINED-COMPATIBILITY-ENVELOPE-SNAPSHOT` 明确 `Core`、`Adapters`、`Persistence`、`Runtime` 仍是 retained compatibility envelopes。
- `GH-401-L4-READINESS-BLOCKERS` 明确 L4 仍为 future gated，需要后续单独 planning。
- `GH-401-STAGE-AUDIT-INPUT` 明确本 issue 只准备审计输入，不输出最终 Stage Code Audit Report。

GH-401 不创建下一 Project / Issue，不推进 L4，不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private WebSocket runtime、real order lifecycle 或 UI command surface。

## GH-413-CORE-ENVELOPE-RETIREMENT-CONTRACT

GH-413 启动第二轮 Core envelope retirement / real module ownership completion queue。它只定义后续 GH-414 至 GH-422 的 real ownership acceptance criteria、dependency direction、retained compatibility envelope exit criteria 和 forbidden capability guard；不修改 `Package.swift`，不移动 `Sources`，不写业务代码，不实现 runtime / live / broker / L4 capability。

本轮的核心判断是：architecture module target names 和 real source roots 已经基本存在，但最终完成标准不是“目录存在”，而是每个模块能在自己的 SwiftPM target 中承载核心实现、通过独立 smoke / behavior tests，并且不再让 `Core`、`Adapters`、`Persistence` 或 `Runtime` 继续作为该模块 primary implementation owner。

## GH-413-REAL-MODULE-OWNERSHIP-ACCEPTANCE-CRITERIA

| Module | Real ownership acceptance criteria | Retained envelope exit criteria |
| --- | --- | --- |
| `MessageBus` | Owns neutral command / event / request-response spine, append-only journal, proposal / risk decision contracts, and paper routing vocabulary that does not import downstream module implementation. | `CommandsAndQueries.swift`、`DomainEvents.swift`、`EventLog.swift` 和 `PaperRuntimeBusRouting.swift` must no longer be primary `Core` ownership, or must be split so only explicitly legacy compatibility shims remain in `Core`. |
| `DataEngine` | Owns ingest / replay / quality contracts and executable read-only replay evidence without requiring `Core` as implementation owner. | `ScenarioReplay`、`DataQuality` and `Ingest` must no longer be primary `Core` / `Runtime` ownership, except explicitly documented compatibility shims. |
| `Database` | Owns durable facts / projection / replay projection boundaries and database checkpoint vocabulary; schema details remain hidden from UI. | `Projections` and `ReplayProjection` must no longer depend on `Persistence` / `Runtime` as primary source owners, except compatibility shims with explicit labels. |
| `Portfolio` | Owns financial state projection boundary, paper portfolio projection evidence, and portfolio parity vocabulary. | Paper projection and parity files must no longer be primary `Core` ownership. |
| `RiskEngine` | Owns pre-execution risk gate boundary and paper pre-trade risk evidence without owning broker or live risk runtime. | `PreTrade/PaperPreTradeRiskEngine.swift` must no longer be primary `Core` ownership. |
| `ExecutionEngine` | Owns paper / simulated execution lifecycle and simulated exchange evidence while keeping real order lifecycle future-gated. | `PaperLifecycle` and `SimulatedExchange` must no longer be primary `Core` ownership. |
| `ExecutionClient` | Remains future gate / protocol boundary only; owns vocabulary for future broker capability, not implementation. | No broker gateway, OMS, signed request client, account endpoint client, listenKey runtime, private WebSocket runtime, submit / cancel / replace, execution report, broker fill or reconciliation implementation is allowed. |
| `Trader` | Owns `Accounts + Strategies/EMA + Coordination`; strategy output remains proposal / signal, not executable order command. | Trader must not directly depend on `ExecutionEngine` / `ExecutionClient`, broker, OMS, live command or UI command surface. |
| `Dashboard` | Consumes read model / ViewModel only and remains the active UI surface. | No active `Workbench` / `AppCompatibility` module restoration; any historical wording must remain clearly non-active. |
| `Core` / `Adapters` / `Persistence` / `Runtime` | Retained compatibility envelopes only. | They may keep temporary re-export / bridge shims, but cannot be described as final owners for architecture module implementation. |

## GH-413-SOURCE-ROOT-BOUNDARY-ANCHOR-FUTURE-GATE-MATRIX

GH-413 requires future PRs to label every touched path as exactly one of:

| Category | Meaning | Allowed use |
| --- | --- | --- |
| Real module source root | The module's intended implementation home. | `Sources/MessageBus/`、`Sources/DataEngine/`、`Sources/Trader/` and other architecture source roots. |
| Boundary anchor | Compile-time / validation declaration proving target shape. | `Sources/*/TargetGraph/*TargetBoundary.swift`; these anchors prove shape, not full implementation ownership. |
| Retained compatibility envelope | Temporary compatibility target carrying old import surface or shims. | `Core`、`Adapters`、`Persistence`、`Runtime`; every retained file must have an explicit reason and exit path. |
| Future gate | Current vocabulary for future capability only. | `ExecutionClient` broker capability, OMS, live order lifecycle, live command and L4 production trading remain future-gated. |

This matrix is the acceptance baseline for GH-414 through GH-422. A module is not complete merely because its target builds or because a `TargetGraph` boundary exists; it is complete only when its implementation ownership, dependency direction and forbidden capability guards are proven by tests and readiness anchors.

## GH-413-DEPENDENCY-DIRECTION-AND-EXIT-GATES

Dependency direction remains:

```text
DataClient -> DataEngine -> MessageBus -> Cache / Database
Trader = Accounts + Strategies/EMA + Coordination
Trader / Portfolio / RiskEngine -> proposal / risk / projection contracts
RiskEngine -> ExecutionEngine -> ExecutionClient future gate
Dashboard -> ReadModel / ViewModel only
```

Exit gates for retained envelopes:

- `Core` exits a module area only after the real target can independently compile and use its core types, focused tests prove behavior, and old `Core` callers are either updated or covered by a clearly labeled compatibility shim.
- `Adapters` exits DataClient ownership when venue implementations compile from `DataClient/<venue>/` and `Adapters` is reduced to historical or re-export compatibility only.
- `Persistence` / `Runtime` exit Database / DataEngine ownership when projection, replay and ingest source roots compile from their real targets or are explicitly split into smaller authorized targets.
- Dashboard exits old UI wording when active source and validation use `Dashboard read-model-only boundary` and do not restore Workbench / AppCompatibility active modules.

## GH-413-NO-L4-RUNTIME-BROKER-GUARD

GH-413 and the downstream Core envelope retirement queue do not authorize:

- Trader runtime、Strategy runtime、Live runtime。
- ExecutionClient implementation、OMS、broker gateway。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- real account read、real order lifecycle、submit / cancel / replace。
- execution report、broker fill、reconciliation。
- Live PRO Console、trading button、live command、order form。
- L4 implementation。
- Symphony / symphony-issue、Graphify / code-index、Figma。
- `.codex/*`、`.build/*`、`graphify-out/*` 提交。

## GH-413-VALIDATION-ANCHORS

GH-413 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-413 readiness anchors：

- `GH-413-CORE-ENVELOPE-RETIREMENT-CONTRACT`
- `GH-413-REAL-MODULE-OWNERSHIP-ACCEPTANCE-CRITERIA`
- `GH-413-SOURCE-ROOT-BOUNDARY-ANCHOR-FUTURE-GATE-MATRIX`
- `GH-413-DEPENDENCY-DIRECTION-AND-EXIT-GATES`
- `GH-413-NO-L4-RUNTIME-BROKER-GUARD`
- `GH-413-VALIDATION-ANCHORS`
