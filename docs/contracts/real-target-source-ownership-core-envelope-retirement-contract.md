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
