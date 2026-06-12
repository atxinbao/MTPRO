# Core Compatibility Envelope Final Retirement Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-631 CEFR-01 Define final Core / Adapters / Persistence / Runtime envelope retirement contract`。

本文档只定义 `Core`、`Adapters`、`Persistence` 和 `Runtime` retained compatibility envelopes 的最终退休合同、当前 source inventory、真实 owner 分类、保留原因和退出路径。本文档不实现 runtime，不移动生产 source，不读取 secret，不连接 production endpoint，不提交真实订单，不启动 Linear / Symphony / Graphify / code-index，不修改 Figma，不创建下一 Project / Issue。

## GH-631-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT

`GH-631-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT`

CEFR 的目标不是继续把 `Core`、`Adapters`、`Persistence` 或 `Runtime` 当作长期架构模块，而是把它们全部收敛为可解释、可验证、可逐步退休的 compatibility envelope：

- `Core` 只能保留 legacy import surface、rich paper / evidence compatibility 和尚未迁出的 cross-module bridge。
- `Adapters` 只能保留 `DataClient` compatibility re-export，不拥有 active adapter implementation。
- `Persistence` 只能保留 `Database` projection adapter shim，不成为 UI schema contract 或 broker payload store。
- `Runtime` 只能保留 `DataEngine` ingest 与 `Database` replay projection workflow shim，不表示 Live runtime 或 production operations runtime。

任何新增或迁移后的 active implementation owner 必须落到真实 module owner：`DomainModel`、`MessageBus`、`DataClient`、`DataEngine`、`Cache`、`Database`、`TraderStrategies`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 或 `Dashboard`。

## GH-631-RETAINED-ENVELOPE-SOURCE-INVENTORY

`GH-631-RETAINED-ENVELOPE-SOURCE-INVENTORY`

下表是当前 retained envelope source inventory。路径均以 repository root 为准；`Sources/Adapters`、`Sources/Persistence` 和 `Sources/Runtime` 目录当前不存在，`Adapters`、`Persistence`、`Runtime` 都是 target-level compatibility envelope。

| Envelope | Retained source | Real module owner | Retention reason | Exit path |
| --- | --- | --- | --- | --- |
| `Core` | `Sources/Core/DashboardBetaDemoScenario.swift` | `Dashboard` | historical dashboard demo evidence still exported through `Core` for AppTests compatibility | move read-model fixture to `Dashboard` once AppTests no longer require `Core` import |
| `Core` | `Sources/Core/DomainModelCompatibilityImport.swift` | `DomainModel` | compatibility import surface for legacy `import Core` callers | delete after downstream tests and Dashboard no longer import `Core` for DomainModel symbols |
| `Core` | `Sources/Core/LiveMonitoringConnectionReadinessExplanation.swift` | `Dashboard` / `ExecutionClient` future gate evidence | read-model-only live monitoring explanation retained as historical blocked evidence | move to Dashboard read-model or ExecutionClient future-gate doc/test owner |
| `Core` | `Sources/Core/LiveMonitoringConsole.swift` | `Dashboard` | live monitoring read-model-only console evidence retained for compatibility | move to Dashboard report/read-model source when Core import surface is retired |
| `Core` | `Sources/Core/LiveMonitoringForbiddenCapabilityTests.swift` | `ExecutionClient` / `Dashboard` future gate evidence | forbidden live monitoring capability evidence retained in Core compatibility surface | move to future-gate validation source or retire after replacement tests exist |
| `Core` | `Sources/Core/LiveMonitoringSimulationGateHealth.swift` | `Dashboard` / `ExecutionClient` future gate evidence | simulation gate health evidence retained for historical live monitoring surface | move to Dashboard read-model or future-gate owner |
| `Core` | `Sources/Core/LiveMonitoringSourceIdentity.swift` | `Dashboard` / `ExecutionClient` future gate evidence | source identity evidence retained for historical live monitoring surface | move to Dashboard read-model or future-gate owner |
| `Core` | `Sources/Core/LiveTradingBoundary.swift` | `ExecutionClient` / `RiskEngine` future gate evidence | canonical forbidden production trading boundary still used by multiple tests | split future-gate vocabulary into owning modules, then keep only compatibility typealias if needed |
| `Core` | `Sources/Core/MarketDataCacheCoreReplayCompatibility.swift` | `Cache` / `DataEngine` | legacy replay-to-cache compatibility bridge | move remaining bridge to Cache/DataEngine read-model owner or retire after direct APIs cover tests |
| `Core` | `Sources/Core/PortfolioProjectionCompatibility.swift` | `Portfolio` | portfolio projection compatibility bridge | move remaining bridge to Portfolio owner or retire after direct Portfolio API coverage |
| `Core` | `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` | `DomainModel` / `TraderStrategies` future candidate evidence | historical research evidence for non-active strategy retained outside current EMA/RSI active scope | move to research/future-candidate owner if reactivated, otherwise keep historical evidence until retired |
| `Core` | `Sources/Core/ResearchEventFlows.swift` | `MessageBus` / `DataEngine` / `TraderStrategies` | rich research event flow crosses data, strategy and bus payloads | split neutral events to MessageBus and strategy-specific evidence to TraderStrategies |
| `Core` | `Sources/Core/ResearchResults.swift` | `DomainModel` / `TraderStrategies` | rich research result payload retained for legacy tests | move pure values to DomainModel and strategy result evidence to TraderStrategies |
| `Core` | `Sources/Core/RiskEnginePaperPreTradeRuntimeBridge.swift` | `RiskEngine` | paper pre-trade bridge retained for legacy Core imports | move bridge evidence to RiskEngine and retire Core export |
| `Core` | `Sources/Core/TradingKernel.swift` | `MessageBus` / `DataEngine` / `ExecutionEngine` | historical local trading kernel aggregates rich paper / replay / execution vocabulary | split remaining rich responsibilities into MessageBus, DataEngine and ExecutionEngine owners |
| `Core` | `Sources/MessageBus/CommandsAndQueries.swift` | `MessageBus` | rich commands/queries still reference upper-layer paper / strategy / execution payloads | split neutral bus vocabulary into MessageBus and upper-layer payloads into owners |
| `Core` | `Sources/MessageBus/DomainEvents.swift` | `MessageBus` / `DomainModel` / `ExecutionEngine` / `Portfolio` | rich domain event enum still aggregates cross-module paper and portfolio events | split event payloads by owner while preserving append-only replay invariants |
| `Core` | `Sources/MessageBus/EventLog.swift` | `MessageBus` / `Database` | append-only event log still carries rich Core event payloads | move neutral journal to MessageBus and persistence-facing records to Database |
| `Core` | `Sources/MessageBus/PaperRuntimeBusRouting.swift` | `MessageBus` / `ExecutionEngine` / `RiskEngine` | paper runtime routing still bridges risk / execution / portfolio evidence | split paper routing evidence into MessageBus contracts and owning engine evidence |
| `Core` | `Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift` | `DataEngine` | deterministic matching still compiled by Core for compatibility after DataEngine split | move into DataEngine target once dependency surface no longer requires Core |
| `Core` | `Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift` | `Portfolio` | paper account / portfolio projection v2 retained through Core for legacy Dashboard/App tests | move to Portfolio owner and expose read model through stable API |
| `Core` | `Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift` | `Portfolio` / `ExecutionEngine` | simulated exchange parity still bridges execution fill evidence and portfolio projection | split execution evidence to ExecutionEngine and projection update to Portfolio |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperExecutionDecision.swift` | `ExecutionEngine` | paper execution decision retained through Core for legacy paper workflow tests | move to ExecutionEngine owner after direct target consumers are complete |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperExecutionEventLog.swift` | `ExecutionEngine` / `MessageBus` | paper execution event log bridges lifecycle facts and append-only event streams | split lifecycle owner to ExecutionEngine and append-only contracts to MessageBus |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperOrderIntent.swift` | `ExecutionEngine` | paper order intent retained for compatibility | move to ExecutionEngine owner and retire Core compile path |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift` | `ExecutionEngine` | paper local lifecycle coordinator retained for compatibility | move to ExecutionEngine owner after target dependency surface is clean |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperSessionLifecycle.swift` | `ExecutionEngine` / `MessageBus` | paper session lifecycle facts still support legacy Core tests | split session lifecycle to ExecutionEngine and event contracts to MessageBus |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlEventLog.swift` | `ExecutionEngine` / `MessageBus` | local control event log bridges Dashboard control evidence and paper facts | split local control event evidence into ExecutionEngine and MessageBus owners |
| `Core` | `Sources/ExecutionEngine/PaperLifecycle/PaperSessionReplay.swift` | `ExecutionEngine` / `DataEngine` / `Database` | paper session replay retained as rich compatibility bridge | split replay responsibility into DataEngine / Database and paper lifecycle evidence into ExecutionEngine |
| `Core` | `Sources/ExecutionEngine/SimulatedExchange/BacktestPaperSharedOrderSemantics.swift` | `ExecutionEngine` | simulated exchange order semantics retained for compatibility | move to ExecutionEngine owner |
| `Core` | `Sources/ExecutionEngine/SimulatedExchange/MarketLimitSimulatedExecutionSemantics.swift` | `ExecutionEngine` | market / limit simulated execution semantics retained for compatibility | move to ExecutionEngine owner |
| `Core` | `Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift` | `ExecutionEngine` | simulated fill evidence retained for compatibility | move to ExecutionEngine owner |
| `Core` | `Sources/ExecutionEngine/SimulatedExchange/PartialFillLatencyFeeSlippageParity.swift` | `ExecutionEngine` | partial fill / latency / fee / slippage parity retained for compatibility | move to ExecutionEngine owner |
| `Adapters` | `Sources/DataClient/AdaptersCompatibility.swift` | `DataClient` | re-export compatibility surface only | delete target or keep typealias-only shim after `Adapters` imports disappear |
| `Persistence` | `Sources/Database/Projections/ReleaseV020SpotPerpDatabaseProjections.swift` | `Database` | release v0.2.0 projection adapter shim still exposed through Persistence target | move public ownership fully to Database product and retire Persistence dependency |
| `Persistence` | `Sources/Database/Projections/SQLite/Persistence.swift` | `Database` | SQLite projection adapter shim still exposed through Persistence target | move callers to Database and retire Persistence target |
| `Persistence` | `Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift` | `Database` | DuckDB analytical projection adapter shim still exposed through Persistence target | move callers to Database and retire Persistence target |
| `Runtime` | `Sources/Database/ReplayProjection/MarketDataReplayProjectionConsistency.swift` | `Database` / `DataEngine` | replay projection consistency workflow still exposed through Runtime target | move replay projection proof to Database/DataEngine owner and retire Runtime source |
| `Runtime` | `Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift` | `DataEngine` / `Database` | ingest -> replay -> projection workflow composition still exposed through Runtime target | move orchestration proof to DataEngine / Database owner and retire Runtime source |

## GH-631-REAL-MODULE-OWNER-CLASSIFICATION

`GH-631-REAL-MODULE-OWNER-CLASSIFICATION`

Owner classification rules:

- `DomainModel` owns pure value semantics, identifiers, product / instrument primitives and strategy-neutral value objects.
- `MessageBus` owns neutral facts, commands, events, request-response and replay contracts, but not upper-layer execution or portfolio payload ownership.
- `DataClient` owns venue-scoped external input capability and compatibility re-export shims.
- `DataEngine` owns ingest, scenario replay, freshness, quality and deterministic data workflow evidence.
- `Cache` owns runtime-derived read state and cache replay compatibility.
- `Database` owns local durable facts, projections, SQLite / DuckDB adapters and replay projection consistency evidence.
- `TraderStrategies` owns EMA / RSI strategy proposal evidence under `Trader/Strategies/<strategy>`.
- `Trader` owns account context, strategy instance coordination and risk binding, not execution client access.
- `Portfolio` owns portfolio projection and exposure read-model evidence.
- `RiskEngine` owns pre-trade risk and blocked evidence.
- `ExecutionEngine` owns paper / simulated lifecycle and internal execution evidence.
- `ExecutionClient` owns gated external execution boundary; production remains disabled by default.
- `Dashboard` owns read-model-only UI evidence surfaces and must not consume runtime object, adapter request or schema.

## GH-631-RETENTION-REASON-AND-EXIT-PATH

`GH-631-RETENTION-REASON-AND-EXIT-PATH`

Every retained source above has exactly one retention reason and one exit path. The acceptable reasons are limited to:

- `legacy import surface`
- `re-export compatibility surface`
- `rich cross-module payload bridge`
- `read-model-only historical evidence`
- `projection adapter shim`
- `ingest / replay workflow shim`
- `deterministic validation bridge`

The acceptable exit paths are limited to:

- move the source to the real module owner;
- split mixed payloads into owner-specific sources;
- replace the compatibility surface with a typealias-only shim;
- delete the retained source once direct real-module APIs cover all consumers.

No CEFR issue may add new retained envelope source without updating this inventory, retention reason and exit path.

## GH-631-FIRST-EXECUTABLE-CANDIDATE-ONLY

`GH-631-FIRST-EXECUTABLE-CANDIDATE-ONLY`

At CEFR startup, `GH-631` is the only executable candidate because it has no blocker. `GH-632` through `GH-636` remain blocked by the previous CEFR issue and must stay `backlog / non-executable` until the preceding issue is closed / done, PR checks pass, the PR is merged, `main == origin/main`, and WIP=1 has no `todo`, `in-progress` or `in-review` conflict.

## GH-631-NO-PRODUCTION-AUTHORIZATION

`GH-631-NO-PRODUCTION-AUTHORIZATION`

GH-631 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- signed endpoint, account endpoint, listenKey or private WebSocket runtime;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form;
- non-Binance venue;
- non-Spot / non-USDⓈ-M product expansion;
- non-EMA / non-RSI active strategy;
- RiskEngine, ExecutionEngine, CommandGateway, OMS, Event Store, kill switch or no-trade bypass.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `productionBrokerConnectionEnabledByDefault == false`

## GH-631-VALIDATION-ANCHORS

`GH-631-VALIDATION-ANCHORS`

Required anchors:

- `GH-631-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT`
- `GH-631-RETAINED-ENVELOPE-SOURCE-INVENTORY`
- `GH-631-REAL-MODULE-OWNER-CLASSIFICATION`
- `GH-631-RETENTION-REASON-AND-EXIT-PATH`
- `GH-631-FIRST-EXECUTABLE-CANDIDATE-ONLY`
- `GH-631-NO-PRODUCTION-AUTHORIZATION`
- `TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT`

Required validation:

- `swift test --filter TargetGraphTests/testGH631FinalEnvelopeRetirementContractClassifiesEveryRetainedSource`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-631-NON-AUTHORIZATION

`GH-631-NON-AUTHORIZATION`

GH-631 不授权 Linear 使用或状态修改，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不实现 runtime，不移动生产 source，不创建下一 Project / Issue，不推进 CEFR-02，不开启 production trading，不读取 production secret，不连接 production endpoint，不启用真实 broker、真实订单、production OMS、Live PRO Console production command、trading button、live command 或 order form。
