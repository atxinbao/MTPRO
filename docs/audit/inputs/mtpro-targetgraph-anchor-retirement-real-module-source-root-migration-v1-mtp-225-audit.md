# MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1 MTP-225 audit

日期：2026-06-04

执行者：Codex

## 定位

`MTP-225-TARGETGRAPH-ANCHOR-AUDIT`

本文档是 `MTP-225` 的 audit / evidence output，服务 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 后续 `MTP-226` 至 `MTP-232` 的迁移输入材料。本文档只审计当前 `Sources/TargetGraph/*` transitional compile anchors、真实 module source roots、`Package.swift` active target paths / dependencies 和 `Tests/TargetGraphTests` coverage，不迁移 source，不修改 `Package.swift`，不修复 production code。

`MTP-225-NO-MIGRATION-GUARD`

本文档不授权修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list；不移动、删除或重命名 production source / tests；不退休 active `Sources/TargetGraph/*` path references；不新增 SwiftPM target / product / dependency；不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify / code-index，不修改 Figma。

## Audit commands

`MTP-225-AUDIT-COMMANDS`

| Command | Result | Interpretation |
| --- | --- | --- |
| `find Sources/TargetGraph -type f \| sort` | 12 boundary files | 当前 buildable split targets 仍全部由 `Sources/TargetGraph/<Module>/<Module>TargetBoundary.swift` 承载 active target path。 |
| `find Sources/DomainModel Sources/MessageBus Sources/Database Sources/DataClient Sources/DataEngine Sources/Cache Sources/Portfolio Sources/RiskEngine Sources/ExecutionClient Sources/ExecutionEngine Sources/Trader Sources/Workbench Sources/Dashboard -type f \| sort` | real root files enumerated | 真实 module source roots 已存在，但多数仍由 `Core` / `Adapters` / `Persistence` / `Runtime` / `Workbench` compatibility envelopes 编译。 |
| `sed -n '1,380p' Package.swift` | active target path / dependency snapshot captured | `DomainModel` 至 `Trader` 仍指向 `Sources/TargetGraph/*`；`Workbench` / `Dashboard` 已是 mixed real-root boundary；compatibility targets 仍承载 implementation source roots。 |
| `sed -n '1,260p' Tests/TargetGraphTests/TargetGraphTests.swift` | 10 target graph boundary tests | Tests 覆盖 MTP-217 foundation、MTP-218 data、MTP-219 trader / portfolio / risk、MTP-220 execution 和 MTP-221 Workbench / Dashboard dependency / forbidden drift。 |

## TargetGraph active anchor inventory

`MTP-225-TARGETGRAPH-ACTIVE-ANCHOR-INVENTORY`

Full path inventory:

- `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`
- `Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift`
- `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift`
- `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`
- `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift`
- `Sources/TargetGraph/Cache/CacheTargetBoundary.swift`
- `Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift`
- `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift`
- `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`
- `Sources/TargetGraph/Trader/TraderTargetBoundary.swift`
- `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift`
- `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift`

| Target | Active target path | Active boundary file | Current target dependencies | Later migration issue |
| --- | --- | --- | --- | --- |
| `DomainModel` | `Sources/TargetGraph/DomainModel` | `DomainModelTargetBoundary.swift` | none | `MTP-226` |
| `MessageBus` | `Sources/TargetGraph/MessageBus` | `MessageBusTargetBoundary.swift` | `DomainModel` | `MTP-226` |
| `Database` | `Sources/TargetGraph/Database` | `DatabaseTargetBoundary.swift` | `DomainModel`、`MessageBus`、`CSQLite`、`DuckDB(macOS)` | `MTP-226` |
| `DataClient` | `Sources/TargetGraph/DataClient` | `DataClientTargetBoundary.swift` | `DomainModel` | `MTP-227` |
| `Cache` | `Sources/TargetGraph/Cache` | `CacheTargetBoundary.swift` | `DomainModel`、`MessageBus` | `MTP-227` |
| `DataEngine` | `Sources/TargetGraph/DataEngine` | `DataEngineTargetBoundary.swift` | `DomainModel`、`DataClient`、`MessageBus`、`Cache` | `MTP-227` |
| `Portfolio` | `Sources/TargetGraph/Portfolio` | `PortfolioTargetBoundary.swift` | `DomainModel`、`MessageBus`、`Cache`、`Database` | `MTP-228` |
| `RiskEngine` | `Sources/TargetGraph/RiskEngine` | `RiskEngineTargetBoundary.swift` | `DomainModel`、`MessageBus`、`Cache`、`Portfolio` | `MTP-228` |
| `TraderStrategies` | `Sources/TargetGraph/TraderStrategies` | `TraderStrategiesTargetBoundary.swift` | `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` | `MTP-228` |
| `Trader` | `Sources/TargetGraph/Trader` | `TraderTargetBoundary.swift` | `DomainModel`、`MessageBus`、`Cache`、`TraderStrategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine` | `MTP-228` |
| `ExecutionClient` | `Sources/TargetGraph/ExecutionClient` | `ExecutionClientTargetBoundary.swift` | `DomainModel`、`MessageBus` | `MTP-229` |
| `ExecutionEngine` | `Sources/TargetGraph/ExecutionEngine` | `ExecutionEngineTargetBoundary.swift` | `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine`、`ExecutionClient` | `MTP-229` |

以上 12 个 files 是 active target path anchors，但只能作为 transitional compile anchor / historical evidence。它们不是最终 architecture module root，也不是 future feature landing path。`Workbench` 和 `Dashboard` 当前不位于 `Sources/TargetGraph/*` active path；它们分别使用 real-root / mixed boundary path，仍在本审计中作为 MTP-230 input 单独记录。

## Real module root inventory

`MTP-225-REAL-MODULE-ROOT-AUDIT`

| Target / boundary area | Current real source roots | Current files | Current compiler owner / gap | Later migration issue |
| --- | --- | --- | --- | --- |
| `DomainModel` | `Sources/DomainModel/` | `CoreBaseline.swift`、`MarketDataModels.swift`、`MarketPrimitives.swift` | Implementation source 已在 real root，但 active `DomainModel` target path 仍指向 `Sources/TargetGraph/DomainModel`。 | `MTP-226` |
| `MessageBus` | `Sources/MessageBus/` | `CommandsAndQueries.swift`、`DomainEvents.swift`、`EventLog.swift`、`PaperRuntimeBusRouting.swift` | Implementation source 已在 real root；需要在迁移时确认不反向依赖 Trader / Execution / Workbench / Dashboard。 | `MTP-226` |
| `Database` | `Sources/Database/` | `Projections/SQLite/Persistence.swift`、`Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift`、`ReplayProjection/MarketDataReplayProjectionConsistency.swift`、`Projections/SQLite/CSQLite/*` | `Persistence` / `Runtime` compatibility envelopes 仍编译 projection / replay roots；`Database` active target 仍只编译 TargetGraph boundary。 | `MTP-226` |
| `DataClient` | `Sources/DataClient/Binance/PublicMarketData/` | `Adapters.swift`、`BinanceMarketDataBatchReplayBoundary.swift`、`BinanceMarketDataReplayFreshness.swift`、`BinanceMarketDataReplayOperationsMetadata.swift`、`BinanceMarketDataReplayParity.swift` | `Adapters` compatibility envelope 编译 public market data implementation；`DataClient` active target 仍只编译 TargetGraph boundary。 | `MTP-227` |
| `DataEngine` | `Sources/DataEngine/` | `ScenarioReplay/*.swift`、`DataQuality/ScenarioDataQualityReportInput.swift`、`Ingest/MarketDataIngestReplayProjectionWorkflow.swift` | `Core` 编译 ScenarioReplay / DataQuality，`Runtime` 编译 Ingest；`DataEngine` active target 仍只编译 TargetGraph boundary。 | `MTP-227` |
| `Cache` | `Sources/Cache/MarketData/` | `MarketDataCache.swift`、`OrderBookReadModel.swift` | `Core` compatibility envelope 编译 cache implementation；`Cache` active target 仍只编译 TargetGraph boundary。 | `MTP-227` |
| `Portfolio` | `Sources/Portfolio/` | `PaperAccountPortfolioProjectionV2.swift`、`PaperPortfolioProjectionUpdate.swift`、`SimulatedExchangePortfolioProjectionParity.swift` | `Core` compatibility envelope 编译 portfolio projection source；`Portfolio` active target 仍只编译 TargetGraph boundary。 | `MTP-228` |
| `RiskEngine` | `Sources/RiskEngine/` | `PreTrade/PaperPreTradeRiskEngine.swift`、`LiveGate/LiveRiskGateContract.swift`、`LiveGate/LiveAuditIncidentStopContract.swift` | `Core` compatibility envelope 编译 pre-trade / live-gate contracts；`RiskEngine` active target 仍只编译 TargetGraph boundary。 | `MTP-228` |
| `TraderStrategies` | `Sources/Trader/Strategies/EMA/` | `EMACross.swift`、`PaperActionProposal.swift`、`StrategySignals.swift` | EMA is the only active concrete strategy root; `TraderStrategies` active target still compiles TargetGraph boundary, not EMA implementation. | `MTP-228` |
| `Trader` | `Sources/Trader/Accounts/`、`Sources/Trader/Coordination/RiskBinding/`、`Sources/Trader/Strategies/EMA/` | `TraderAccountContext.swift`、`PaperActionRiskLink.swift`、EMA files | `Core` compatibility envelope compiles Trader container pieces; active `Trader` target still compiles TargetGraph boundary. | `MTP-228` |
| `ExecutionClient` | `Sources/ExecutionClient/` | `FutureGate/LiveExecutionControlContract.swift`、`BrokerCapabilityMatrix/ExecutionClientBrokerCapabilityMatrix.swift` | Future gate / capability matrix source exists; active `ExecutionClient` target still compiles TargetGraph boundary and must remain no broker implementation. | `MTP-229` |
| `ExecutionEngine` | `Sources/ExecutionEngine/` | `PaperLifecycle/*.swift`、`SimulatedExchange/*.swift`、`OMSFutureGate/OMSFutureGateBoundary.swift` | `Core` compatibility envelope compiles paper / simulated / OMS future gate sources; active `ExecutionEngine` target still compiles TargetGraph boundary. | `MTP-229` |
| `Workbench` | `Sources/Workbench/` plus `Sources/Dashboard/DashboardShell.swift` | `ReadModels/App.swift`、`Report/*.swift`、`Dashboard/*.swift`、`Events/PaperWorkflowEvidenceExplorer.swift`、`FutureLiveProConsole/LiveReadOnlyWorkbenchBoundary.swift`、`TargetGraph/WorkbenchTargetBoundary.swift`、`DashboardShell.swift` | `Workbench` target already uses `path: "Sources"` with explicit sources / excludes; MTP-230 must decide final real-root simplification without exposing runtime / adapter / schema / command surfaces. | `MTP-230` |
| `Dashboard` | `Sources/Dashboard/` | `DashboardApplication.swift`、`DashboardTargetBoundary.swift`、`DashboardShell.swift` | `Dashboard` executable target already uses `Sources/Dashboard` and excludes shell; it depends only on `Workbench`. MTP-230 must keep `Dashboard -> Workbench` only. | `MTP-230` |

## Package.swift active path audit

`MTP-225-PACKAGE-TARGET-PATH-AUDIT`

`Package.swift` currently exposes buildable products for `DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench`、`Core`、`Adapters`、`Persistence`、`Runtime`、`App` and executable `Dashboard`。

The active target path snapshot is:

```text
DomainModel -> Sources/TargetGraph/DomainModel
MessageBus -> Sources/TargetGraph/MessageBus
Database -> Sources/TargetGraph/Database
DataClient -> Sources/TargetGraph/DataClient
Cache -> Sources/TargetGraph/Cache
DataEngine -> Sources/TargetGraph/DataEngine
Portfolio -> Sources/TargetGraph/Portfolio
RiskEngine -> Sources/TargetGraph/RiskEngine
ExecutionClient -> Sources/TargetGraph/ExecutionClient
ExecutionEngine -> Sources/TargetGraph/ExecutionEngine
TraderStrategies -> Sources/TargetGraph/TraderStrategies
Trader -> Sources/TargetGraph/Trader
Workbench -> path Sources with explicit Workbench and DashboardShell sources
Core -> path Sources compatibility envelope for current implementation roots
Adapters -> Sources/DataClient/Binance/PublicMarketData
Persistence -> Sources/Database/Projections
Runtime -> Sources/Database/ReplayProjection and Sources/DataEngine/Ingest
App -> Sources/AppCompatibility
Dashboard -> Sources/Dashboard
```

MTP-225 does not change this snapshot. Later migration issues may only change the active target path when their Linear issue explicitly authorizes that target family.

## TargetGraphTests coverage audit

`MTP-225-TARGETGRAPH-TEST-COVERAGE-AUDIT`

`Tests/TargetGraphTests/TargetGraphTests.swift` imports all split targets directly: `DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench` 和 `Dashboard`。

Current test coverage:

| Test area | Functions | Coverage |
| --- | --- | --- |
| MTP-217 foundation | `testMTP217FoundationTargetsExposeDependencyDirectionAndCompatibilityBoundary`、`testMTP217FoundationTargetsRejectHigherLayerRuntimeAndBrokerDrift` | Verifies foundation dependency direction, retained compatibility envelope, and no higher-layer runtime / broker / UI drift. |
| MTP-218 data | `testMTP218DataTargetsExposeReadOnlyDependencyDirectionAndCompatibilityBoundary`、`testMTP218DataTargetsRejectSignedAccountBrokerAndRuntimeDrift` | Verifies public read-only data dependency direction, cache read-model boundary, ingest / replay boundary, and no signed / account / listenKey / broker / runtime drift. |
| MTP-219 trader / portfolio / risk | `testMTP219TraderPortfolioRiskTargetsExposeDependencyDirectionAndContainerBoundary`、`testMTP219TraderPortfolioRiskTargetsRejectRuntimeBrokerAndNonEMADrift` | Verifies Trader container `Accounts + Strategies/EMA + Coordination`, EMA-only active strategy, Portfolio financial state boundary, RiskEngine pre-execution boundary, and no direct execution / broker / runtime drift. |
| MTP-220 execution | `testMTP220ExecutionTargetsExposeFutureGateDependencyDirection`、`testMTP220ExecutionTargetsRejectBrokerOMSRealOrderAndEndpointDrift` | Verifies ExecutionClient future gate, ExecutionEngine paper / simulated lifecycle boundary, Trader dependency resolution, and no broker / OMS / real order / endpoint drift. |
| MTP-221 Workbench / Dashboard | `testMTP221WorkbenchDashboardTargetsExposeReadModelOnlyDependencyDirection`、`testMTP221WorkbenchDashboardTargetsRejectRuntimeAdapterSchemaAndCommandDrift` | Verifies Workbench read-model / ViewModel consumption, Dashboard consumes Workbench only, and no runtime / adapter / schema / UI command drift. |

Gap: tests currently prove target boundary contracts, not real module root ownership. MTP-226 至 MTP-230 must add or update tests only when each target family actually migrates from `Sources/TargetGraph/<Module>` to its real source root.

## Migration risk register

`MTP-225-MIGRATION-RISK-REGISTER`

| Risk | Evidence | Required handling |
| --- | --- | --- |
| Target path and implementation root are split | Active targets still point at `Sources/TargetGraph/*`, while real roots are compiled by compatibility envelopes. | Each migration must keep dependencies directional and avoid deleting retained implementation roots. |
| Foundation root migration can accidentally expose higher-layer imports | `MessageBus` / `Database` real roots are currently compiled through `Core` / `Persistence` envelopes. | `MTP-226` must preserve no Trader / Execution / Workbench / Dashboard drift and CSQLite / DuckDB conditions. |
| Data root migration spans three envelopes | `DataClient` is in `Adapters`; `DataEngine` is split between `Core` and `Runtime`; `Cache` is in `Core`. | `MTP-227` must keep public read-only / replay / ingest boundaries and no signed / account / private stream capability. |
| Trader / Portfolio / Risk migration is behavior-sensitive | EMA, Accounts, Coordination, Portfolio and Risk are currently under `Core`. | `MTP-228` must retain EMA-only, no direct execution, no broker, no Trader runtime, no live command. |
| Execution migration can be misread as L4 enablement | ExecutionClient and OMS files are future gate / paper evidence, not live execution implementation. | `MTP-229` must keep ExecutionClient future-gated and no OMS / broker / real order lifecycle. |
| Workbench / Dashboard migration already uses mixed real roots | `Workbench` uses `path: "Sources"` with explicit sources and `DashboardShell.swift`; `Dashboard` depends on `Workbench`. | `MTP-230` must simplify only within read-model-only / display-only boundaries and keep no command surface. |
| TargetGraph retirement must wait for all family migrations | `Sources/TargetGraph` still contains 12 active boundary files. | `MTP-231` is the first issue allowed to retire active TargetGraph path references; MTP-225 does not. |

## Validation evidence

`MTP-225-AUDIT-VALIDATION`

Required local validation for this issue:

| Command | Expected result | Notes |
| --- | --- | --- |
| `git diff --check` | pass | No whitespace errors. |
| `bash checks/automation-readiness.sh` | pass | Confirms MTP-225 audit anchors are wired into readiness evidence. |
| `bash checks/run.sh` | pass | Full local validation remains the acceptance gate before PR. |

This audit also requires PR evidence that `Package.swift` has no diff, no production source / test files were moved, no Symphony / Graphify / code-index / Figma was used, and `.codex/*` / `graphify-out/*` were not submitted.
