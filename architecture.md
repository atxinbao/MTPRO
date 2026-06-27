# architecture.md

## 工程模块地图定位

本文档是 MTPRO 的 Engineering Module Map / 工程模块地图。它是根目录高权重承接文档，负责把 `BLUEPRINT.md` 的完整蓝图翻译成系统模块、模块边界、数据流、接口关系、依赖方向和架构不变量。本文档不能推翻 `BLUEPRINT.md`，不重新定义产品目标，不作为 Stage Code Audit、validation 或 PR evidence 流水账。

MTPRO 是 SwiftPM-first、Swift-only、local-first 的 macOS 实盘原生交易系统。架构借鉴 NautilusTrader 的 Kernel、MessageBus、Cache、DataEngine、StrategyEngine、RiskEngine、ExecutionEngine、Portfolio 和 Adapter 职责拆分，但不引入 NautilusTrader 作为运行依赖。

## Architecture Responsibility / 架构职责

`architecture.md` 只回答：当前有哪些模块、模块之间允许怎么依赖、数据和事件如何流动、哪些接口边界不能被绕过、Future Live 能力如何被隔离在当前 scope 之外。

## Current Architecture Flow / 当前架构流

```text
DataClient/<venue>
-> DataEngine
-> MessageBus
-> Cache / Database
-> Trader/Strategies/{EMA,RSI} + Trader/Coordination
-> Portfolio + RiskEngine
-> ExecutionEngine
-> ExecutionClient gated testnet / production-disabled boundary
```

| 模块 | 大白话职责 | 禁止越界 |
| --- | --- | --- |
| `DataClient/<venue>/` | 交易所 / venue 输入适配器；一个 venue 一个目录，product identity 必须进入 event / artifact namespace | 不接非授权 venue，不把 testnet / dry-run / read-only evidence 升级成 production command |
| `DataEngine/` | ingest、replay、quality、scenario、cursor、freshness | 不直接写 UI，不执行交易，不绕过 MessageBus / Cache / Database |
| `MessageBus/` | 内部 facts / events / commands / request-response spine | 不暴露 HTTP、broker payload、adapter request、DB schema 或 UI command surface |
| `Cache/`、`Database/` | 可重建 state、durable facts / projections | 不成为 UI contract，不保存 broker truth |
| `Trader/Strategies/EMA`、`Trader/Strategies/RSI` | Trader-owned concrete strategy，只产出 signal / proposal / evidence | 不直连 ExecutionClient、broker、OMS 或 live command |
| `Trader/Coordination` | account、strategy、portfolio、risk、execution context 协调 | binding / adapter 语义归这里，不作为具体 strategy code 落点 |
| `Portfolio`、`RiskEngine` | financial read model / projection context 和 pre-execution risk evidence | 不读取 broker account state，不调用 broker / ExecutionClient |
| `ExecutionEngine` | paper / simulated lifecycle、future OMS boundary | 不调用交易所，不实现 broker adapter，不处理 real order lifecycle |
| `ExecutionClient` | 把订单发出去的 gated boundary；后续按 venue / product 拆 Binance / OKX execution adapter | production default、secret auto-read、production endpoint auto-connect 和 real order 默认禁止，除非独立 production gate 授权 |
| `Dashboard` | 只读消费 ReadModel / ViewModel | 不读 Runtime object、Adapter request、DB schema，不提供 trading button / live command |

`GH-596-RELEASE-V020-ROOT-DOCS-REFRESH`

`GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH`

`MTPRO Release v0.2.0` 已完成 GitHub fallback queue closure；Stage Code Audit Report 位于 `docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md`，operator runbook 位于 `docs/operators/release-v0.2.0-operator-runbook.md`。

Current release construction scope：activeVenue == Binance；activeProductTypes == [spot, usdsPerpetual]；activeStrategies == [ema, rsi]；productionTradingEnabledByDefault == false；productionCapabilityGatedNotMissing == true；oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true。

## Target Venue / Product Architecture

长期目标架构必须按 venue / product 建模，而不是把交易所和产品写成单个全局常量：

```text
Venue/
  Binance/
    Spot
    USDⓈ-M Futures
  OKX/
    Spot
    Swap
```

Bybit Spot / Linear Perpetual 只作为 future candidate，不进入当前 canonical target architecture。若 Human 后续确认 Bybit，必须先创建独立 planning / issue queue，再引入 active source、tests 或 Package target。

工程不变量：

- 每个 run、artifact、order intent、OMS event、risk decision、credential reference、status query、reconciliation record 和 Dashboard read model 都必须能携带 `{venue, productType, environment, accountProfile, runID}`。
- `DataClient/<venue>/` 负责 venue 输入与 product identity；`ExecutionClient/<venue>/` 负责 future signed / execution adapter boundary；两者不能混用。
- Binance Spot 是当前最成熟 implementation path；Binance USDⓈ-M Futures、OKX Spot、OKX Swap 是目标能力，不是当前已实现或已授权 production 能力。
- production trading 可以成为未来版本目标，但必须按 venue / product 逐项通过 credential、signed endpoint、OMS、risk、reconciliation、audit、rollback 和 Human approval gate。
- 当前文档目标调整不移动 `Sources/`，不修改 `Package.swift`，不授权 OKX、USDⓈ-M Futures、production endpoint、production broker 或 production order。

正确心智：策略只提出建议 -> Trader 协调上下文 -> RiskEngine 做风险门 -> ExecutionEngine 处理内部 paper / simulated lifecycle -> ExecutionClient 只在 release issue 明确授权且 production 默认关闭的 gate 后才可能接外部交易所 / broker。

## Current Source Layout / 当前源码模块地形

```text
Sources/
  DomainModel/
  MessageBus/
  DataClient/Binance/
  DataEngine/
  Cache/
  Database/
  Trader/Strategies/EMA/
  Trader/Coordination/
  Portfolio/
  RiskEngine/
  ExecutionEngine/
  ExecutionClient/
  Dashboard/
```

当前 active UI surface 是 Dashboard read-model-only boundary；`Workbench` product / target 和 `Sources/Workbench/` 已退休；`TargetGraph Anchor Retirement / Real Module Source Root Migration before L4` 已完成。

Target planned roots（不代表当前已存在 source，不授权 execution）：

```text
Sources/DataClient/Binance/{Spot,USDⓈ-M Futures}/
Sources/DataClient/OKX/{Spot,Swap}/
Sources/ExecutionClient/Binance/{Spot,USDⓈ-M Futures}/
Sources/ExecutionClient/OKX/{Spot,Swap}/
```

## Package Dependency Direction / SwiftPM 依赖方向

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
Dashboard -> Core / Persistence
```

Retained compatibility envelopes：`Core`、`Adapters -> Core`、`Persistence -> Core, CSQLite, DuckDB(macOS)`、`Runtime -> Core, Adapters, Persistence`。`App` product / target 和 `Sources/AppCompatibility` 已退休。

Forbidden path taxonomy：`DataClient -> signed/account/listenKey/private runtime`；`Trader/Strategies -> ExecutionClient`；`Trader -> ExecutionClient`；`Trader -> ExecutionEngine` direct target dependency；`RiskEngine -> broker / ExecutionClient`；`Portfolio -> broker account state`；`ExecutionEngine -> current OMS / broker adapter`；`Dashboard -> Runtime object / Adapter request / Database schema`。

## Module Boundary Contracts / 模块边界合同

`GH-391 Real Target Source Ownership / Core Envelope Retirement Contract`

`GH-391-REAL-TARGET-OWNERSHIP-CONTRACT`

`GH-391-CURRENT-BLOCKERS`

`GH-391-AUTHORITATIVE-TARGET-OWNERSHIP-MODEL`

`GH-391-DEPENDENCY-DIRECTION-CORRECTION`：Trader 不直接拥有 ExecutionEngine implementation。

`GH-392-TRADER-NO-DIRECT-EXECUTIONENGINE-DEPENDENCY`

`GH-392-TRADER-PROPOSAL-MESSAGEBUS-COORDINATION-BOUNDARY`

`GH-392-VALIDATION-ANCHORS`

`GH-393 Foundation Real Target Smoke Tests`

`GH-393-FOUNDATION-REAL-TARGET-SMOKE-TESTS`

`GH-393-FOUNDATION-COMPATIBILITY-ENVELOPE-PRESERVED`

`GH-393-FOUNDATION-NO-RUNTIME-LIVE-BROKER-L4-GUARD`

`GH-394 DomainModel / MessageBus Implementation Ownership`

`GH-394-DOMAINMODEL-MESSAGEBUS-IMPLEMENTATION-OWNERSHIP`

`GH-394-MESSAGEBUS-NEUTRAL-JOURNAL-OWNERSHIP`

`GH-394-CORE-COMPATIBILITY-ENVELOPE-PRESERVED`

`GH-414 MessageBus Neutral Query / Replay Ownership`

`GH-414-MESSAGEBUS-NEUTRAL-QUERY-REPLAY-OWNERSHIP`

`GH-414-CORE-RICH-MESSAGEBUS-COMPATIBILITY-ENVELOPE`

`GH-395 Data Target Real Smoke Tests`

`GH-395-DATA-TARGET-REAL-SMOKE-TESTS`

`GH-395-DATACLIENT-REAL-TARGET-SMOKE`

`GH-395-CACHE-REAL-TARGET-SMOKE`

`GH-395-DATAENGINE-REAL-TARGET-SMOKE`

`GH-395-DATA-COMPATIBILITY-ENVELOPE-PRESERVED`

`GH-396 Data Target Implementation Ownership`

`GH-396-DATA-TARGET-IMPLEMENTATION-OWNERSHIP`

`GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP`

`GH-396-CACHE-MARKETDATA-IMPLEMENTATION-OWNERSHIP`

`GH-396-DATAENGINE-REPLAY-QUALITY-COREERROR-ENVELOPE-DOCUMENTED`

`GH-396-DATAENGINE-INGEST-RUNTIME-ENVELOPE-DOCUMENTED`

`GH-415 DataEngine ScenarioReplay / DataQuality Ownership`

`GH-415-DATAENGINE-SCENARIO-REPLAY-QUALITY-OWNERSHIP`

`GH-415-DATAENGINE-DETERMINISTIC-MATCHING-CORE-ENVELOPE-DEFERRED`

`GH-397 Trader / Portfolio / Risk / Execution Real Target Smoke Tests`

`GH-397-TRADER-PORTFOLIO-RISK-EXECUTION-REAL-SMOKE-TESTS`

`GH-397-TRADER-EMA-COORDINATION-SMOKE`

`GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE`

`GH-397-COMPATIBILITY-ENVELOPE-PRESERVED`

`GH-416 Portfolio Paper Projection Update Ownership`

`GH-416-PORTFOLIO-PAPER-PROJECTION-UPDATE-OWNERSHIP`

`GH-416-CORE-PORTFOLIO-EVENT-BRIDGE-ONLY`

`GH-416-PORTFOLIO-REPLAY-PARITY-BRIDGE-DEFERRED`

`GH-417 RiskEngine Paper Pre-trade Ownership`

`GH-417-RISKENGINE-PAPER-PRETRADE-OWNERSHIP`

`GH-417-CORE-RISKENGINE-EVENT-BRIDGE-ONLY`

`GH-417-RISKENGINE-NO-EXECUTIONCLIENT-OMS-BROKER-GUARD`

`GH-418 ExecutionEngine Paper / Simulated Boundary Ownership`

`GH-418-EXECUTIONENGINE-PAPER-RUNTIME-KERNEL-OWNERSHIP`

`GH-418-EXECUTIONENGINE-SESSION-CONTROL-OWNERSHIP`

`GH-418-EXECUTIONENGINE-SIMULATED-PARITY-BOUNDARY-OWNERSHIP`

`GH-418-CORE-EXECUTIONENGINE-ORDER-EVENT-REPLAY-BRIDGE-DEFERRED`

`GH-419 Database / Persistence / Runtime Ownership Matrix`

`GH-419-DATABASE-PERSISTENCE-RUNTIME-OWNERSHIP-MATRIX`

`GH-419-PERSISTENCE-CORE-DEPENDENCY-DEFERRED-ONLY`

`GH-419-RUNTIME-REPLAY-INGEST-COMPOSITION-ONLY`

`GH-419-NO-SCHEMA-RUNTIME-BROKER-L4-GUARD`

`GH-420 Dashboard Read-model-only Active Naming Cleanup`

`GH-420-DASHBOARD-ACTIVE-SOURCE-NAMING-CLEAN`

`GH-421 All Architecture Targets Real API Smoke Coverage`

`GH-421-ALL-ARCHITECTURE-TARGETS-REAL-API-SMOKE`

`GH-422 Core Envelope Retirement Matrix / L4 Readiness Closeout`

`GH-422-CORE-ENVELOPE-RETIREMENT-MATRIX-STAGE-CLOSEOUT`

`GH-422-RETAINED-COMPATIBILITY-ENVELOPE-SNAPSHOT`

`GH-422-L4-READINESS-BLOCKERS`

`GH-413 Core Envelope Retirement / Real Module Ownership Completion Contract`

`GH-413-REAL-MODULE-OWNERSHIP-ACCEPTANCE-CRITERIA`

`GH-413-SOURCE-ROOT-BOUNDARY-ANCHOR-FUTURE-GATE-MATRIX`

`GH-413-NO-L4-RUNTIME-BROKER-GUARD`

## Target Graph Split Ledger

`MTP-216 SwiftPM Target Graph Split Contract`

`MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT`

`MTP-216-CANONICAL-TARGET-GRAPH-BASELINE`

`MTP-216-DEPENDENCY-DIRECTION-CONTRACT`

`MTP-216-PACKAGE-SPLIT-NON-AUTHORIZATION`

`MTP-216-NO-RUNTIME-LIVE-BROKER-L4`

`MTP-217 Foundation Target Split`

`MTP-217-FOUNDATION-DEPENDENCY-DIRECTION`

`MTP-218 Data Target Split`

`MTP-218-DATACLIENT-DATAENGINE-CACHE-DEPENDENCY-DIRECTION`

`MTP-219 Trader / Portfolio / Risk Target Split`

`MTP-219-TRADER-CONTAINER-ACCOUNTS-EMA-COORDINATION`

`MTP-220 ExecutionEngine / ExecutionClient Target Split`

`MTP-220-RISKENGINE-EXECUTIONENGINE-EXECUTIONCLIENT-DIRECTION`

`MTP-221 Dashboard Read-model-only Target Split`

`MTP-221-DASHBOARD-READ-MODEL-DEPENDENCY-DIRECTION`

`MTP-222 Compatibility Anchor Retirement`

`MTP-222-CURRENT-TARGET-GRAPH-SNAPSHOT`

`MTP-224 TargetGraph Anchor Retirement / Real Module Source Root Migration Contract`

`MTP-224-TARGETGRAPH-RETIREMENT-CONTRACT`

`MTP-231 TargetGraph Active Path Reference Retirement`

`MTP-231-REAL-MODULE-ROOT-ACTIVE-SNAPSHOT`

## Capability Flow Map / 能力流地图

```text
Market event -> MessageBus fact -> Cache / Database projection
-> Trader strategy proposal -> RiskEngine decision
-> ExecutionEngine paper / dry-run lifecycle
-> Portfolio projection -> Dashboard / CLI read model
```

## Future Live Isolation / 未来实盘隔离

Future Live、signed endpoint、account endpoint、listenKey、broker gateway、ExecutionClient production implementation、OMS、real order lifecycle、Live PRO Console、trading button、live command 和 order form 必须保持 future-gated。Production capability 是 gated capability，不是缺失能力；没有 CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store、kill switch / no-trade 和 validation gates 的路径仍不得读取 production secret、连接 production endpoint、连接 broker 或提交真实订单。

## Architecture Update Gate / 架构更新门槛

修改本文档时只能同步已发生事实或 Human-approved planning input。不得把 planning record、Backlog issue、Stage Audit input、reference map 或 release note 写成 execution authorization。任何新 runtime、broker、OMS、signed endpoint、account endpoint、Live PRO Console 或 production capability 都必须先经过 Human decision、issue contract、Parent Codex queue preflight、PR evidence 和 validation gate。
