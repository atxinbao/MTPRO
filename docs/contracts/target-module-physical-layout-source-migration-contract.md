# Target Module Physical Layout / Source Migration Contract

日期：2026-06-01

执行者：Codex

## 文档定位

本文是 `MTP-183 Define target module physical layout and SwiftPM migration contract` 的 migration contract 输出。

本文只定义 target physical layout、SwiftPM target migration strategy、old-to-new source map、compatibility shell policy、import direction、tests placement 和 validation anchors。

本文不移动 `Sources` 文件，不修改 `Package.swift` target graph，不写业务代码，不创建 SwiftPM target，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

MTP-191 forward-looking correction：本文的 MTP-183 layout 仍作为已完成 migration contract evidence 保留；MTP-191 之后 concrete strategy canonical path 从 `Sources/Strategies/<strategy>/` 修正为 `Sources/Trader/Strategies/<strategy>/`。旧 strategy path 只作为 compatibility / superseded source，直到后续 issue 执行源码迁移。

`MTP-183-TARGET-PHYSICAL-LAYOUT-CONTRACT`

后续 source migration 只能迁入下列目标目录；旧目录只作为 migration source / compatibility shell。

```text
Sources/
  DomainModel/
  DataClient/
    Binance/
      PublicMarketData/
      FuturePrivateStreamGate/
  DataEngine/
    Ingest/
    ScenarioReplay/
    DataQuality/
  MessageBus/
    Events/
    Commands/
    Requests/
    Replay/
  Cache/
    Instruments/
    MarketData/
    Orders/
    Positions/
    PortfolioSummary/
  Database/
    AppendOnlyEventLog/
    Snapshots/
    Projections/
      SQLite/
      DuckDB/
    ReplayProjection/
  Trader/
    Accounts/
    Strategies/
      EMA/
        Lifecycle/
        Quoter/
        Hedger/
        Signals/
        Proposals/
      <future-strategy>/
    Coordination/
    StrategyBindings/
  Portfolio/
    Positions/
    NetPositions/
    Margin/
    OpenValue/
    PaperProjection/
  RiskEngine/
    Commands/
    Events/
    PreTrade/
    LiveGate/
  ExecutionEngine/
    Commands/
    Events/
    PaperLifecycle/
    SimulatedExchange/
    OMSFutureGate/
  ExecutionClient/
    FutureGate/
    BrokerCapabilityMatrix/
  Workbench/
    ReadModels/
    Report/
    Dashboard/
    Events/
    FutureLiveProConsole/
  Dashboard/
```

`MTP-191-TRADER-OWNED-STRATEGY-CANONICAL-PATH`

MTP-191 修正后的 forward-looking target layout 把 concrete strategy definitions 放在 `Sources/Trader/Strategies/<strategy>/`。`Sources/Strategies/<strategy>/` 不再是 canonical destination，只能作为 historical MTP-171 / MTP-183 / MTP-187 evidence、compatibility envelope 和 MTP-193 / MTP-194 的待迁移来源。

`MTP-191-STRATEGYBINDINGS-NON-LANDING-GUARD`

`Sources/Trader/StrategyBindings/` 只允许 generic binding protocol / coordination adapter contract。具体 strategy lifecycle、signals、quoter、hedger、proposal implementation 和 strategy-specific business rules 必须落入 `Sources/Trader/Strategies/<strategy>/`，不得放入 `StrategyBindings/`。

## Current SwiftPM Snapshot

`MTP-183-CURRENT-SWIFTPM-SNAPSHOT`

当前 `Package.swift` 仍是早期 coarse target graph：

```text
Core
Adapters -> Core
Persistence -> Core, CSQLite, DuckDB(macOS)
Runtime -> Core, Adapters, Persistence
App -> Core, Persistence
Dashboard -> App

CoreTests -> Core
AdaptersTests -> Adapters
PersistenceTests -> Persistence
RuntimeTests -> Runtime
AppTests -> App, Core, Adapters, Persistence, Runtime
```

MTP-183 不修改上述 target graph。后续 issue 只有在 Linear execution contract 明确授权时，才允许做 `Package.swift` target graph delta。

## SwiftPM Target Migration Strategy

`MTP-183-SWIFTPM-MIGRATION-CONTRACT`

后续 source migration 按三段推进：

1. Directory-first / namespace-first：先把文件移动到目标 `Sources/*` 目录，保留旧 target buildability；必要时使用 compatibility shell 让旧 imports 继续编译。
2. Low-level target split：优先拆 `DomainModel`、`MessageBus`、`Database`、`Cache`、`DataClient` 和 `DataEngine`，因为它们是上层 engine 的依赖基础。
3. Engine / surface target split：再拆 `Strategies`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` future gate、`Workbench` 和 `Dashboard`。

目标 SwiftPM dependency direction：

| Target | Allowed dependencies |
| --- | --- |
| `DomainModel` | none |
| `MessageBus` | `DomainModel` |
| `Database` | `DomainModel`, `MessageBus`, `CSQLite`, `DuckDB` on macOS |
| `Cache` | `DomainModel`, `MessageBus`, `Database` projection inputs |
| `DataClient` | `DomainModel` |
| `DataEngine` | `DomainModel`, `DataClient`, `MessageBus`, `Cache` |
| `Portfolio` | `DomainModel`, `MessageBus`, `Cache`, `Database` projection inputs |
| `RiskEngine` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio` |
| `ExecutionClient` | `DomainModel`; future-gated boundary only |
| `ExecutionEngine` | `DomainModel`, `MessageBus`, `Cache`, `RiskEngine`, `Portfolio`, `ExecutionClient` future gate labels only |
| `Trader/Strategies` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio`, `RiskEngine` read-model inputs |
| `Trader` | `DomainModel`, `MessageBus`, `Cache`, `Trader/Strategies`, `Portfolio`, `RiskEngine`, `ExecutionEngine` |
| `Workbench` | stable ReadModel / ViewModel exports only |
| `Dashboard` | `Workbench` / presentation exports only |

`ExecutionClient` appearing in dependency planning is not current implementation authorization. It is a future-gated type / capability label until a later Linear issue explicitly authorizes broker / exchange execution client implementation.

## Old-to-new Source Map

`MTP-183-OLD-TO-NEW-SOURCE-MAP`

| Current source | Target module destination | Migration rule |
| --- | --- | --- |
| `Sources/Core/MarketPrimitives.swift`, `MarketDataModels.swift`, `CoreBaseline.swift`, value objects | `Sources/DomainModel/` | Pure domain first; no adapter / persistence / UI import. |
| `Sources/Core/DomainEvents.swift`, `CommandsAndQueries.swift`, `EventLog.swift`, `PaperRuntimeBusRouting.swift` | `Sources/MessageBus/` | Facts / commands / events / replay invariant; no live command bus. |
| `Sources/Core/ScenarioManifest.swift`, `ScenarioFixture.swift`, `ScenarioReplay*`, `ScenarioDataQualityReportInput.swift` | `Sources/DataEngine/ScenarioReplay/` and `Sources/DataEngine/DataQuality/` | Scenario replay and quality evidence only; no Runtime object or private network path. |
| `Sources/Core/MarketDataCache.swift` | `Sources/Cache/MarketData/` | Runtime-derived state only; no durable schema or real account cache. |
| `Sources/Core/PaperPreTradeRiskEngine.swift`, `LiveRiskGateContract.swift` | `Sources/RiskEngine/` | Paper risk and future live gate evidence; no broker / ExecutionClient call. |
| `Sources/Core/PaperOrder*`, `PaperExecution*`, `PaperSimulatedFillEvidence.swift`, `MarketLimitSimulatedExecutionSemantics.swift`, `PartialFillLatencyFeeSlippageParity.swift` | `Sources/ExecutionEngine/` | Paper / simulated lifecycle; no OMS implementation or real order lifecycle. |
| `Sources/Core/PaperAccountPortfolioProjectionV2.swift`, `PaperPortfolioProjectionUpdate.swift`, `SimulatedExchangePortfolioProjectionParity.swift` | `Sources/Portfolio/` | Paper / simulated financial projection; no broker portfolio state. |
| `Sources/Core/EMACross.swift`, `StrategySignals.swift`, `OrderBookImbalance.swift`, `PaperActionProposal.swift` | `Sources/Trader/Strategies/EMA/` or later `Sources/Trader/Strategies/<strategy>/` | MTP-191 corrected strategy destination; current `Sources/Strategies/<strategy>/` is compatibility / superseded source until MTP-193 / MTP-194 moves files; no direct ExecutionClient / broker command. |
| `Sources/Core/LiveTradingBoundary.swift`, `LiveMonitoring*`, `LiveExecutionControlContract.swift`, `LiveAuditIncidentStopContract.swift` | Target boundary contracts under `DomainModel`, `Workbench`, `RiskEngine`, `ExecutionEngine`, or future gate modules as authorized by later issue | Contract movement must preserve read-model-only / future-gated semantics. |
| `Sources/Adapters/*` | `Sources/DataClient/Binance/PublicMarketData/` and `Sources/DataClient/Binance/FuturePrivateStreamGate/` labels | Binance remains public read-only; no signed/account/listenKey/private runtime. |
| `Sources/Persistence/*`, `Sources/CSQLite/*` | `Sources/Database/Projections/SQLite/`, `Sources/Database/Projections/DuckDB/`, `Sources/Database/AppendOnlyEventLog/` | Database is local durable backing store; schema is not UI contract. |
| `Sources/Runtime/*` | `Sources/DataEngine/Ingest/`, `Sources/MessageBus/Replay/`, `Sources/Database/ReplayProjection/` | Runtime orchestration must be decomposed into ingest / replay / projection boundaries. |
| `Sources/App/*` | `Sources/Workbench/ReadModels/`, `Sources/Workbench/Report/`, `Sources/Workbench/Dashboard/`, `Sources/Workbench/Events/`, `Sources/Workbench/FutureLiveProConsole/` | Workbench consumes ReadModel / ViewModel only; future Live PRO Console remains a gated label; no runtime object, adapter request or schema access. |
| `Sources/Dashboard/*` | `Sources/Dashboard/` | macOS shell / smoke / presentation surface only; no broker command path. |

## Compatibility Shell Policy

`MTP-183-COMPATIBILITY-SHELL-POLICY`

Compatibility shell 是迁移期间为了保持 buildability 的旧路径薄壳。规则：

1. 旧 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 不能接收新的长期能力。
2. Compatibility shell 只能包含 forwarding imports、typealias、deprecated wrapper 或 minimal adapter glue，不新增业务语义。
3. 每个 source migration PR 必须列出 moved files、remaining compatibility shell 和 planned removal issue。
4. 一旦 downstream imports 已迁移，旧 shell 必须在同 issue 或后续明确 issue 中删除。
5. Compatibility shell 不能绕过 import direction，不能把 forbidden path 伪装成旧 target 内部访问。

## Import Direction Guard

`MTP-183-IMPORT-DIRECTION-GUARD`

后续 import guard 必须阻断：

- `Strategies -> ExecutionClient`
- `Trader -> ExecutionClient`
- `Workbench -> Runtime object`
- `Workbench -> Adapter request`
- `Workbench -> Database schema`
- `DataClient -> signed/account/listenKey/private runtime`
- `RiskEngine -> broker / ExecutionClient`
- `Portfolio -> broker account state`
- `ExecutionEngine -> current OMS / broker adapter`
- `Dashboard -> broker command / live command / order form`

## Tests Placement

`MTP-183-TESTS-PLACEMENT-CONTRACT`

Target tests placement 跟随 target module：

```text
Tests/DomainModelTests/
Tests/MessageBusTests/
Tests/DatabaseTests/
Tests/CacheTests/
Tests/DataClientTests/
Tests/DataEngineTests/
Tests/PortfolioTests/
Tests/RiskEngineTests/
Tests/ExecutionEngineTests/
Tests/ExecutionClientTests/
Tests/StrategiesTests/
Tests/TraderTests/
Tests/WorkbenchTests/
Tests/DashboardTests/
```

迁移期间允许旧 `CoreTests / AdaptersTests / PersistenceTests / RuntimeTests / AppTests` 暂留为 compatibility validation source，但不得把它们写成最终测试结构。每个后续 source migration issue 必须说明测试从旧 target 到新 target 的落点、临时 shell 覆盖和删除计划。

## Validation Anchors

`MTP-183-VALIDATION-ANCHORS`

MTP-183 的 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-183 后续 source migration PR 必须证明：

- target source layout 仍只使用本文固定目录。
- `Package.swift` target graph change 只在当前 Linear issue 明确授权时发生。
- old paths 只作为 migration source / compatibility shell。
- import direction guard 未被绕过。
- no source move / no Package.swift target graph change / no business code 对 MTP-183 本身成立。
- no Strategy runtime、no Trader runtime、no Live runtime。
- no ExecutionClient implementation、no OMS implementation。
- no signed endpoint、no account endpoint / listenKey、no private WebSocket runtime。
- no broker / exchange execution adapter、no `LiveExecutionAdapter`。
- no real order lifecycle、no real submit / cancel / replace。
- no execution report、no broker fill、no reconciliation。
- no real account / broker position / margin / leverage / real PnL。
- no Live PRO Console、no trading button、no live command、no order form。
- MTP-191 之后必须把 `Sources/Trader/Strategies/<strategy>/` 作为 concrete strategy canonical path，把 `Sources/Strategies/<strategy>/` 作为 compatibility / superseded source path。
- `Sources/Trader/StrategyBindings/` 不得作为 concrete strategy implementation landing path。

`MTP-183-NO-SOURCE-MOVE-PACKAGE-BUSINESS-CODE`

MTP-183 只证明 migration contract 已落仓，并且本 PR 没有移动 `Sources` 文件、没有修改 `Package.swift` target graph、没有写业务代码。真正的 source movement 从 MTP-184 以后按各自 Linear issue scope 执行。
