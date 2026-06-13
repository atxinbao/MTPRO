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
| `Core` | `Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift` | `DataEngine` / `ExecutionEngine` | deterministic matching still consumes simulated exchange / shared order payloads while active ScenarioReplay / DataQuality ownership has moved to DataEngine | split DataEngine replay inputs from ExecutionEngine simulated parity payloads before target migration |
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

## GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT

`GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT`

GH-632 收窄 `Sources/MessageBus` 中仍由 `Core` compatibility envelope 编译的 rich routing surface。当前不能把这些文件整体迁入 `MessageBus` target，因为它们仍引用 strategy、paper execution、risk、portfolio 和 persistence-facing rich payload；整体迁移会让 `MessageBus` 反向依赖上层模块。

本 issue 的 active ownership 迁移点是：`MessageBus` target 现在直接拥有 `Sources/MessageBus/RichRoutingCompatibilityContract.swift`，由 `MessageBusRichRoutingCompatibilityContract.gh632` 记录 retained rich routing surfaces、真实 owner、保留理由、退出路径和 no-production authorization。`Core` 只继续编译 legacy rich payload files，不再作为 active routing ownership decision 的来源。

## GH-632-CORE-RICH-ROUTING-COMPATIBILITY-ONLY

`GH-632-CORE-RICH-ROUTING-COMPATIBILITY-ONLY`

GH-632 后，以下文件仍由 `Core` compatibility envelope 编译，但只能解释为 compatibility-only retained source：

| Retained source | Compatibility envelope | Real module owners | Retention reason | Exit path |
| --- | --- | --- | --- | --- |
| `Sources/MessageBus/CommandsAndQueries.swift` | `Core` | `MessageBus` / `TraderStrategies` / `ExecutionEngine` / `RiskEngine` / `Portfolio` | rich commands and queries still reference upper-layer strategy, paper execution, risk and portfolio payloads | split neutral command/query vocabulary into MessageBus and upper-layer payloads into their owning modules |
| `Sources/MessageBus/DomainEvents.swift` | `Core` | `MessageBus` / `DomainModel` / `ExecutionEngine` / `Portfolio` | rich event enum still aggregates cross-module paper lifecycle, simulated fill and portfolio facts | split neutral event envelope semantics into MessageBus and rich event payloads into owner modules |
| `Sources/MessageBus/EventLog.swift` | `Core` | `MessageBus` / `Database` / `ExecutionEngine` | append-only log remains coupled to rich Core event payloads during compatibility retirement | move neutral journal semantics to MessageBus and persistence-facing records to Database |
| `Sources/MessageBus/PaperRuntimeBusRouting.swift` | `Core` | `MessageBus` / `ExecutionEngine` / `RiskEngine` / `Portfolio` | paper runtime routing still bridges risk, execution and portfolio evidence for legacy Core imports | split routing contracts into MessageBus and move engine-specific evidence to the owning targets |

## GH-632-MESSAGEBUS-OWNED-ROUTING-CLASSIFICATION

`GH-632-MESSAGEBUS-OWNED-ROUTING-CLASSIFICATION`

`MessageBus` target now owns the classification and validation evidence for rich routing compatibility:

- `Package.swift` lists `RichRoutingCompatibilityContract.swift` in the `MessageBus` target.
- `Package.swift` excludes `MessageBus/RichRoutingCompatibilityContract.swift` from the `Core` target.
- `MessageBusTargetBoundary.requiredValidationAnchors` includes `GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT`.
- `Tests/TargetGraphTests/TargetGraphTests.swift` includes `testGH632MessageBusOwnsRichRoutingCompatibilityContractAndKeepsCoreCompatibilityOnly`.

This does not retire the four rich files yet. It prevents drift by making the retained state explicit and mechanically checked before later CEFR issues split payload ownership further.

## GH-632-DASHBOARD-CLI-BOUNDARY-HELD

`GH-632-DASHBOARD-CLI-BOUNDARY-HELD`

GH-632 does not change product surfaces:

- `Dashboard` remains an executable target depending on `Core` and `Persistence`.
- `MTPROCLI` remains an executable target depending on `Database`.
- `Dashboard` is still read-model-only and must not consume `MessageBusRichRoutingCompatibilityContract` as runtime command authority.
- `MTPROCLI` must not gain `Core`, `MessageBus`, `ExecutionEngine`, `ExecutionClient`, broker or OMS dependency through this issue.

## GH-632-NO-PRODUCTION-AUTHORIZATION

`GH-632-NO-PRODUCTION-AUTHORIZATION`

GH-632 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- signed endpoint, account endpoint, listenKey or private WebSocket runtime;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `brokerGatewayEnabledByDefault == false`
- `realOrderCommandEnabledByDefault == false`
- `omsRuntimeEnabledByDefault == false`
- `dashboardCommandSurfaceEnabledByDefault == false`

## GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT

`GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT`

GH-633 收窄 DataEngine / ScenarioReplay / DataQuality compatibility ownership。`DataEngine` target 现在直接拥有 `Sources/DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift`，由 `ScenarioReplayDataQualityOwnershipContract.gh633` 记录 active DataEngine-owned scenario / quality sources、Core retained deterministic matching bridge、退出路径和 no-production authorization。

## GH-633-ACTIVE-DATAENGINE-SCENARIO-QUALITY-SOURCES

`GH-633-ACTIVE-DATAENGINE-SCENARIO-QUALITY-SOURCES`

以下 source 是 DataEngine active ownership，不再由 `Core` 解释为 active DataEngine business implementation：

| Active source | Owner target | Ownership reason |
| --- | --- | --- |
| `Sources/DataEngine/DataQuality/ScenarioDataQualityReportInput.swift` | `DataEngine` | scenario replay quality gates and report input evidence belong to DataEngine |
| `Sources/DataEngine/ScenarioReplay/DataCatalogScenarioReplayBoundary.swift` | `DataEngine` | data catalog and scenario replay boundary belongs to DataEngine |
| `Sources/DataEngine/ScenarioReplay/ScenarioFixture.swift` | `DataEngine` | deterministic local scenario fixture identity belongs to DataEngine |
| `Sources/DataEngine/ScenarioReplay/ScenarioManifest.swift` | `DataEngine` | scenario manifest identity and scope belongs to DataEngine |
| `Sources/DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift` | `DataEngine` | CEFR ownership classification is owned by DataEngine |
| `Sources/DataEngine/ScenarioReplay/ScenarioReplayEvidence.swift` | `DataEngine` | replay window, cursor, checksum and freshness evidence belongs to DataEngine |

`Package.swift` lists these sources in the `DataEngine` target, and `Core` excludes the DataEngine-owned ownership contract from its compatibility compile path.

## GH-633-CORE-DETERMINISTIC-MATCHING-COMPATIBILITY-ONLY

`GH-633-CORE-DETERMINISTIC-MATCHING-COMPATIBILITY-ONLY`

`Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift` remains compiled by `Core` only as compatibility bridge. It is not active DataEngine business ownership because the file still consumes upper-layer simulated exchange / shared order payloads. The exit path is to split DataEngine replay input semantics from ExecutionEngine simulated parity payloads before a future target migration.

## GH-633-NO-PRODUCTION-AUTHORIZATION

`GH-633-NO-PRODUCTION-AUTHORIZATION`

GH-633 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- signed endpoint, account endpoint, listenKey or private WebSocket runtime;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `signedEndpointEnabledByDefault == false`
- `privateStreamRuntimeEnabledByDefault == false`
- `brokerGatewayEnabledByDefault == false`
- `realOrderCommandEnabledByDefault == false`

## GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT

`GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT`

GH-634 收窄 Portfolio / Execution simulated parity compatibility ownership。`Portfolio` target 现在直接拥有 `Sources/Portfolio/PortfolioParityOwnershipContract.swift`，由 `PortfolioParityOwnershipContract.gh634` 记录 active Portfolio projection sources、Core retained Portfolio parity bridges、退出路径和 no-production authorization。

## GH-634-PORTFOLIO-ACTIVE-PROJECTION-SOURCES

`GH-634-PORTFOLIO-ACTIVE-PROJECTION-SOURCES`

以下 source 是 Portfolio active ownership，不再由 `Core` 解释为 active portfolio implementation：

| Active source | Owner target | Ownership reason |
| --- | --- | --- |
| `Sources/Portfolio/PaperPortfolioProjectionUpdate.swift` | `Portfolio` | paper portfolio projection update is active Portfolio-owned read-model evidence |
| `Sources/Portfolio/PortfolioFinancialStateProjection.swift` | `Portfolio` | financial state projection is active Portfolio-owned read-model evidence |
| `Sources/Portfolio/PortfolioParityOwnershipContract.swift` | `Portfolio` | CEFR portfolio parity ownership classification belongs to Portfolio |
| `Sources/Portfolio/ReleaseV030PortfolioProjectionRehearsal.swift` | `Portfolio` | GH-665 Portfolio projection rehearsal evidence is active Portfolio-owned projection logic |
| `Sources/Portfolio/ReleaseV030RehearsalSurface.swift` | `Portfolio` | GH-666 shared Dashboard / CLI rehearsal surface evidence is active Portfolio-owned read-model logic |

以下 source 仍由 `Core` compatibility envelope 编译，但只能解释为 compatibility-only retained bridge：

- `Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift`
- `Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift`

## GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT

`GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT`

`ExecutionEngine` target 现在直接拥有 `Sources/ExecutionEngine/Ownership/ExecutionParityOwnershipContract.swift`，由 `ExecutionParityOwnershipContract.gh634` 记录 active paper / simulated execution sources、Core retained execution parity bridges、退出路径和 no-production authorization。

## GH-634-EXECUTION-ACTIVE-SIMULATED-SOURCES

`GH-634-EXECUTION-ACTIVE-SIMULATED-SOURCES`

以下 source 是 ExecutionEngine active ownership：

| Active source | Owner target | Ownership reason |
| --- | --- | --- |
| `Sources/ExecutionEngine/Ownership/ExecutionEnginePaperOwnership.swift` | `ExecutionEngine` | paper execution ownership matrix belongs to ExecutionEngine |
| `Sources/ExecutionEngine/Ownership/ExecutionParityOwnershipContract.swift` | `ExecutionEngine` | CEFR execution parity ownership classification belongs to ExecutionEngine |
| `Sources/ExecutionEngine/PaperLifecycle/PaperExecutionWorkflowContract.swift` | `ExecutionEngine` | paper execution workflow contract belongs to ExecutionEngine |
| `Sources/ExecutionEngine/PaperLifecycle/PaperRuntimeKernelBoundary.swift` | `ExecutionEngine` | paper runtime kernel boundary belongs to ExecutionEngine |
| `Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlCommand.swift` | `ExecutionEngine` | paper session local control command belongs to ExecutionEngine |
| `Sources/ExecutionEngine/SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift` | `ExecutionEngine` | simulated exchange parity boundary belongs to ExecutionEngine |

以下 source 仍由 `Core` compatibility envelope 编译，但只能解释为 compatibility-only retained bridge：

- `Sources/ExecutionEngine/PaperLifecycle/PaperExecutionDecision.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperExecutionEventLog.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperOrderIntent.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperSessionLifecycle.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlEventLog.swift`
- `Sources/ExecutionEngine/PaperLifecycle/PaperSessionReplay.swift`
- `Sources/ExecutionEngine/SimulatedExchange/BacktestPaperSharedOrderSemantics.swift`
- `Sources/ExecutionEngine/SimulatedExchange/MarketLimitSimulatedExecutionSemantics.swift`
- `Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift`
- `Sources/ExecutionEngine/SimulatedExchange/PartialFillLatencyFeeSlippageParity.swift`

## GH-634-CORE-PORTFOLIO-EXECUTION-PARITY-COMPATIBILITY-ONLY

`GH-634-CORE-PORTFOLIO-EXECUTION-PARITY-COMPATIBILITY-ONLY`

`GH-634-CORE-PORTFOLIO-PARITY-COMPATIBILITY-ONLY`

`GH-634-CORE-EXECUTION-PARITY-COMPATIBILITY-ONLY`

GH-634 后，Core 不再作为 active portfolio / execution parity owner。Core 只保留 legacy import、event/replay bridge 和 cross-module deterministic parity bridge 编译路径。后续 CEFR issue 只能在 owner-specific dependency surface 可拆分后迁移 retained bridge，不能通过 Core 新增 active parity implementation。

## GH-634-NO-PRODUCTION-AUTHORIZATION

`GH-634-NO-PRODUCTION-AUTHORIZATION`

GH-634 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- signed endpoint, account endpoint, listenKey or private WebSocket runtime;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `brokerGatewayEnabledByDefault == false`
- `omsRuntimeEnabledByDefault == false`
- `realOrderCommandEnabledByDefault == false`
- `executionReportRuntimeEnabledByDefault == false`
- `brokerFillRuntimeEnabledByDefault == false`
- `reconciliationRuntimeEnabledByDefault == false`

## GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT

`GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT`

GH-635 收窄 `Persistence` / `Runtime` compatibility envelope。`Database` target 现在直接拥有 `Sources/Database/PersistenceRuntimeEnvelopeRetirementContract.swift`，由 `PersistenceRuntimeEnvelopeRetirementContract.gh635` 记录 retained Persistence adapter shim、retained Runtime workflow shim、Package source overlap guard 和 no-production authorization。

## GH-635-PERSISTENCE-ADAPTER-SHIM-ONLY

`GH-635-PERSISTENCE-ADAPTER-SHIM-ONLY`

`Persistence` target 只允许继续编译 Database projection adapter shim；它不是 active Database implementation owner、UI schema contract、broker payload store 或 account payload store：

| Retained source | Envelope target | Real module owner | Shim role |
| --- | --- | --- | --- |
| `Sources/Database/Projections/ReleaseV020SpotPerpDatabaseProjections.swift` | `Persistence` | `Database` | Database projection adapter shim |
| `Sources/Database/Projections/SQLite/Persistence.swift` | `Persistence` | `Database` | Database projection adapter shim |
| `Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift` | `Persistence` | `Database` | Database projection adapter shim |

## GH-635-RUNTIME-WORKFLOW-SHIM-ONLY

`GH-635-RUNTIME-WORKFLOW-SHIM-ONLY`

`Runtime` target 只允许继续编译 DataEngine / Database replay-ingest workflow shim；它不是 Live runtime、production operations runtime、Trader runtime、Strategy runtime、ExecutionClient runtime、OMS runtime 或 broker gateway：

| Retained source | Envelope target | Real module owner | Shim role |
| --- | --- | --- | --- |
| `Sources/Database/ReplayProjection/MarketDataReplayProjectionConsistency.swift` | `Runtime` | `Database` / `DataEngine` | DataEngine / Database replay-ingest workflow shim |
| `Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift` | `Runtime` | `DataEngine` / `Database` | DataEngine / Database replay-ingest workflow shim |

## GH-635-PACKAGE-SOURCE-OVERLAP-GUARD

`GH-635-PACKAGE-SOURCE-OVERLAP-GUARD`

Package guard:

- `Database` target lists `PersistenceRuntimeEnvelopeRetirementContract.swift` as a Database-owned source.
- `Persistence` target excludes `PersistenceRuntimeEnvelopeRetirementContract.swift` and continues listing only the three projection adapter shim sources.
- `Runtime` target excludes `Database/PersistenceRuntimeEnvelopeRetirementContract.swift` and continues listing only `Database/ReplayProjection` and `DataEngine/Ingest`.
- `Sources/Persistence` and `Sources/Runtime` directories remain absent; `Persistence` / `Runtime` remain target-level compatibility envelopes only.

## GH-635-NO-PRODUCTION-AUTHORIZATION

`GH-635-NO-PRODUCTION-AUTHORIZATION`

GH-635 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- raw SQLite / DuckDB schema exposure to Dashboard;
- Runtime object exposure to Dashboard;
- broker payload or account payload persistence;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `rawSchemaExposedToDashboard == false`
- `runtimeObjectExposedToDashboard == false`
- `brokerPayloadPersistenceEnabledByDefault == false`
- `accountPayloadPersistenceEnabledByDefault == false`
- `brokerGatewayEnabledByDefault == false`
- `omsRuntimeEnabledByDefault == false`
- `realOrderCommandEnabledByDefault == false`
- `reconciliationRuntimeEnabledByDefault == false`

## GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT

`GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`

GH-636 收口 GH-631 至 GH-635 的 final envelope retirement validation matrix。收口后，`Core`、`Adapters`、`Persistence` 和 `Runtime` 都只能解释为 retained compatibility envelope 或 shim，不再代表 active business implementation owner。

## GH-636-ISSUE-PR-EVIDENCE-CHAIN

`GH-636-ISSUE-PR-EVIDENCE-CHAIN`

GH-636 的 evidence chain 以 `docs/audit/inputs/mtpro-core-compatibility-envelope-final-retirement-v1-stage-audit-input.md` 为 Stage Code Audit 输入材料，覆盖：

- GH-631 / PR #637 / merge `e3279b0c102ba47e56304d3ad98d203819ef3ecc`;
- GH-632 / PR #638 / merge `c1aa7634c658833171f2956bbc7102be3e7e5bdc`;
- GH-633 / PR #639 / merge `02c50ea24488e430664073833d076af88fbddff5`;
- GH-634 / PR #640 / merge `4041b7eb82e490ee6deb2c2bfe6781cc772bb778`;
- GH-635 / PR #641 / merge `75cb1cf157244c3e4234ad4f866ae2eab06a2634`.

## GH-636-REAL-MODULE-OWNER-MAP-COMPLETE

`GH-636-REAL-MODULE-OWNER-MAP-COMPLETE`

Final owner map 必须覆盖 `DataClient`、`DataEngine`、`MessageBus`、`Database`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Trader`、`TraderStrategies` 和 `Dashboard`。任何 active implementation ownership 都必须落在这些真实 module owner 或对应 foundation owner，不得回流到 `Core`、`Adapters`、`Persistence` 或 `Runtime` compatibility envelope。

## GH-636-RETAINED-ENVELOPE-SHIM-MATRIX

`GH-636-RETAINED-ENVELOPE-SHIM-MATRIX`

Retained envelope shim matrix:

- `Core`: compatibility envelope only; allowed reasons are legacy import surface, rich cross-module payload bridge, read-model-only historical evidence and deterministic validation bridge.
- `Adapters`: DataClient compatibility re-export only; allowed reason is re-export compatibility surface.
- `Persistence`: Database projection adapter shim only; allowed reason is projection adapter shim.
- `Runtime`: DataEngine / Database replay-ingest workflow shim only; allowed reason is ingest / replay workflow shim.

## GH-636-AUTOMATION-READINESS-CLOSEOUT

`GH-636-AUTOMATION-READINESS-CLOSEOUT`

Automation readiness must mechanically require the GH-636 stage audit input file, the GH-636 contract anchors, the final trading validation matrix row and the focused TargetGraph test `testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover`.

## GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION

`GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION`

GH-636 does not authorize production trading, production secret read, production endpoint connection, signed endpoint, account endpoint, listenKey, private WebSocket runtime, broker gateway, broker adapter, automatic broker connection, real submit / cancel / replace, production OMS, execution report runtime, broker fill runtime, reconciliation runtime, Live PRO Console command, trading button, live command, order form or production cutover.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `productionBrokerConnectionEnabledByDefault == false`
- `productionCutoverAuthorized == false`

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
- `GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT`
- `GH-632-CORE-RICH-ROUTING-COMPATIBILITY-ONLY`
- `GH-632-MESSAGEBUS-OWNED-ROUTING-CLASSIFICATION`
- `GH-632-DASHBOARD-CLI-BOUNDARY-HELD`
- `GH-632-NO-PRODUCTION-AUTHORIZATION`
- `TVM-CEFR-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY`
- `GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT`
- `GH-633-ACTIVE-DATAENGINE-SCENARIO-QUALITY-SOURCES`
- `GH-633-CORE-DETERMINISTIC-MATCHING-COMPATIBILITY-ONLY`
- `GH-633-NO-PRODUCTION-AUTHORIZATION`
- `TVM-CEFR-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP`
- `GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT`
- `GH-634-PORTFOLIO-ACTIVE-PROJECTION-SOURCES`
- `GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT`
- `GH-634-EXECUTION-ACTIVE-SIMULATED-SOURCES`
- `GH-634-CORE-PORTFOLIO-EXECUTION-PARITY-COMPATIBILITY-ONLY`
- `GH-634-CORE-PORTFOLIO-PARITY-COMPATIBILITY-ONLY`
- `GH-634-CORE-EXECUTION-PARITY-COMPATIBILITY-ONLY`
- `GH-634-NO-PRODUCTION-AUTHORIZATION`
- `TVM-CEFR-PORTFOLIO-EXECUTION-PARITY-OWNERSHIP`
- `GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT`
- `GH-635-PERSISTENCE-ADAPTER-SHIM-ONLY`
- `GH-635-RUNTIME-WORKFLOW-SHIM-ONLY`
- `GH-635-PACKAGE-SOURCE-OVERLAP-GUARD`
- `GH-635-NO-PRODUCTION-AUTHORIZATION`
- `TVM-CEFR-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT`
- `GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`
- `GH-636-ISSUE-PR-EVIDENCE-CHAIN`
- `GH-636-REAL-MODULE-OWNER-MAP-COMPLETE`
- `GH-636-RETAINED-ENVELOPE-SHIM-MATRIX`
- `GH-636-AUTOMATION-READINESS-CLOSEOUT`
- `GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION`
- `TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`

Required validation:

- `swift test --filter TargetGraphTests/testGH631FinalEnvelopeRetirementContractClassifiesEveryRetainedSource`
- `swift test --filter TargetGraphTests/testGH632MessageBusOwnsRichRoutingCompatibilityContractAndKeepsCoreCompatibilityOnly`
- `swift test --filter TargetGraphTests/testGH633DataEngineOwnsScenarioReplayAndDataQualityWhileCoreRetainsMatchingBridgeOnly`
- `swift test --filter TargetGraphTests/testGH634PortfolioAndExecutionOwnParityContractsWhileCoreRetainsBridgeOnly`
- `swift test --filter TargetGraphTests/testGH635PersistenceRuntimeEnvelopesAreAdapterAndWorkflowShimsOnly`
- `swift test --filter TargetGraphTests/testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-631-NON-AUTHORIZATION

`GH-631-NON-AUTHORIZATION`

GH-631 不授权 Linear 使用或状态修改，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不实现 runtime，不移动生产 source，不创建下一 Project / Issue，不推进 CEFR-02，不开启 production trading，不读取 production secret，不连接 production endpoint，不启用真实 broker、真实订单、production OMS、Live PRO Console production command、trading button、live command 或 order form。
