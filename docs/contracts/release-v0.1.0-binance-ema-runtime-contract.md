# Release v0.1.0 Binance EMA Runtime Contract

日期：2026-06-08

执行者：Codex

本文档服务 GitHub fallback issue `GH-521 Define release v0.1.0 Binance EMA runtime contract and acceptance matrix`。

本文档定义 `MTPRO Release v0.1.0` 的顶层执行合同、模块边界、验收矩阵和 no-default-production-trading 安全门。Release v0.1.0 的唯一 active venue 是 Binance，唯一 active concrete strategy 是 EMA。本文档不实现 runtime，不读取 secret，不连接 production endpoint，不提交真实订单，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma。

## GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT

`GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT`

Release v0.1.0 contract 是 GH-521 至 GH-541 的共同上层合同。后续 issue 只能在自己的 scope 内逐项补齐 release runtime、testnet、dry-run、risk、execution、Dashboard、kill switch、docs 和 stage audit evidence，不得用一个 issue 越级打开 production trading。

合同固定：

- milestone：`MTPRO Release v0.1.0`
- queue range：`GH-521..GH-541`
- active venue：`Binance`
- active concrete strategy：`EMA`
- ownership gap retirement：`GH-522` 必须先把 `Core` / `Adapters` / `Persistence` / `Runtime` retained envelope 对 release path 的影响关闭或明确 deferred。
- release target smoke coverage：`GH-523` 必须证明 release targets 可通过真实 public API 独立 import / use，而不只验证 `Package.swift` 文本。
- production trading 默认关闭。
- dry-run-first 和 testnet-first 必须先于任何真实生产讨论。
- RiskEngine gate、ExecutionEngine lifecycle、kill switch / no-trade gate 必须先于任何 submit / cancel / replace。
- final release closure 必须在 GH-541 后单独证明 issue / PR / checks / merge / validation evidence 完整。

## GH-521-BINANCE-EMA-ACTIVE-SCOPE

`GH-521-BINANCE-EMA-ACTIVE-SCOPE`

Release v0.1.0 的 active construction scope 只包含：

- Binance public market data runtime path。
- Release ownership gap retirement for retained `Core` / `Adapters` / `Persistence` / `Runtime` envelopes。
- Real target smoke tests for all release modules：`DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Trader`、`TraderStrategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 和 `Dashboard`。
- Binance signed account read runtime。
- Binance private stream and account snapshot runtime。
- Trader runtime lifecycle for Accounts, EMA and Coordination。
- EMA strategy proposal runtime。
- RiskEngine live pre-trade gate。
- ExecutionEngine order lifecycle and OMS state machine。
- Binance ExecutionClient testnet submit / cancel / replace。
- execution report and broker fill parser。
- reconciliation and portfolio update path。
- Dashboard live monitoring surface。
- Dashboard controlled command surface with production disabled by default。
- kill switch、no-trade 和 rollback controls。
- Binance dry-run and testnet validation suite。
- no-default-production-trading automation guards。
- release docs、operator runbook、validation matrix、stage audit input、final Stage Code Audit 和 Root Docs Refresh。

非 Binance venue 不属于 release v0.1.0 active scope。非 EMA concrete strategy 不属于 release v0.1.0 active scope。

## GH-521-TESTNET-DRY-RUN-FIRST-GATE

`GH-521-TESTNET-DRY-RUN-FIRST-GATE`

Release v0.1.0 的 runtime 验证顺序必须保持：

```text
local fixture / deterministic evidence
-> dry-run evidence
-> Binance testnet evidence
-> release validation matrix closeout
-> Stage Code Audit
-> Root Docs Refresh
```

Production endpoint、production secret、production broker connection 和 production order command 不属于默认路径。任何后续 issue 如果需要 testnet credential 或 testnet environment，必须在当前 issue scope 内明确缺失时停止并报告，不能回退到 production secret 或 production endpoint。

## GH-521-ACCEPTANCE-MATRIX

`GH-521-ACCEPTANCE-MATRIX`

| Domain | Release v0.1.0 required evidence | Issue anchors | Production default |
| --- | --- | --- | --- |
| Ownership / compatibility envelopes | Core / Adapters / Persistence / Runtime ownership gap closed or explicitly deferred | GH-522 | compatibility envelope cannot be release runtime owner |
| Release target smoke coverage | DomainModel / MessageBus / Database / DataClient / DataEngine / Cache / Trader / TraderStrategies / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Dashboard real public API smoke | GH-523 | smoke evidence cannot authorize runtime implementation or production trading |
| DataClient / DataEngine / Cache | Binance public market data runtime path、market data freshness、cache update evidence | GH-524 | production trading disabled；public market data 不授权 order command |
| Account / private stream | Binance signed account read、private stream、account snapshot evidence | GH-525、GH-526 | no production secret by default；no production endpoint by default |
| Trader / EMA | Trader Accounts + EMA + Coordination lifecycle、EMA proposal runtime | GH-527、GH-528 | only EMA active；no non-EMA active strategy |
| RiskEngine | live pre-trade allow / reject gate、limit evidence | GH-529 | RiskEngine bypass forbidden |
| ExecutionEngine / OMS | order lifecycle、OMS state machine、ExecutionEngine handoff | GH-530 | production OMS disabled by default |
| ExecutionClient / Binance testnet | testnet submit / cancel / replace、execution report、broker fill parser | GH-531、GH-532 | testnet only；real production submit / cancel / replace forbidden |
| Reconciliation / Portfolio | OMS / broker report / portfolio projection reconciliation and update path | GH-533 | production reconciliation disabled by default |
| Dashboard | live monitoring surface and controlled command surface | GH-534、GH-535 | production command UI disabled by default |
| Kill switch / no-trade / rollback | submit / cancel / replace shutdown, no-trade state, rollback evidence | GH-536 | kill switch must block commands before release validation |
| Release validation | Binance dry-run / testnet validation suite, no-default-production-trading guard | GH-537、GH-538 | production remains disabled by default |
| Docs / audit | operator runbook, validation matrix, stage audit input, final Stage Code Audit and Root Docs Refresh | GH-539、GH-540、GH-541 | no next Project / Issue auto-promotion |

## GH-521-NO-DEFAULT-PRODUCTION-TRADING

`GH-521-NO-DEFAULT-PRODUCTION-TRADING`

Release v0.1.0 允许后续 issue 逐步实现 Binance testnet / dry-run runtime，但 production trading 必须默认关闭：

- `productionTradingEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `productionOrderCancelEnabledByDefault == false`
- `productionOrderReplaceEnabledByDefault == false`
- `productionOMSRuntimeEnabledByDefault == false`
- `productionDashboardCommandEnabledByDefault == false`
- `nonBinanceVenueEnabled == false`
- `nonEMAStrategyEnabled == false`

这些 false flags 是 release v0.1.0 的验收边界，不是隐藏 feature flag。任何 PR 都不得通过配置、环境变量、Dashboard UI、testnet credential、dry-run command 或 operator runbook 默认启用 production trading。

## GH-521-VALIDATION-ANCHORS

`GH-521-VALIDATION-ANCHORS`

Required anchors：

- `GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT`
- `GH-521-BINANCE-EMA-ACTIVE-SCOPE`
- `GH-521-TESTNET-DRY-RUN-FIRST-GATE`
- `GH-521-ACCEPTANCE-MATRIX`
- `GH-521-NO-DEFAULT-PRODUCTION-TRADING`
- `GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`
- `GH-523-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`
- `GH-524-BINANCE-PUBLIC-MARKET-DATA-RUNTIME-PATH`
- `GH-525-BINANCE-SIGNED-ACCOUNT-READ-RUNTIME`
- `GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME`
- `GH-527-TRADER-RUNTIME-LIFECYCLE`
- `GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME`
- `GH-529-RISKENGINE-LIVE-PRETRADE-GATE`
- `GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE`
- `TVM-RELEASE-V010-BINANCE-EMA-RUNTIME`
- `TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`
- `TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH`
- `TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ`
- `TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT`
- `TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE`
- `TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME`
- `TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE`
- `TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-527-TRADER-RUNTIME-LIFECYCLE

`GH-527-TRADER-RUNTIME-LIFECYCLE`

Trader runtime lifecycle 指 release v0.1.0 中 `Trader` target 对 Accounts、唯一 active EMA strategy instance 和 Coordination/RiskBinding handoff 的本地 lifecycle 管理。该 lifecycle 只能生成 deterministic startup / shutdown report 和 local evidence：

- account context 来自 `Sources/Trader/Accounts/TraderAccountContext.swift`。
- active concrete strategy 固定为 `EMA`，strategy configuration 来自 `TraderStrategies.EMACrossStrategyConfiguration`。
- coordination handoff 固定使用 `Sources/Trader/Coordination/RiskBinding/` 的 generic binding / adapter contract。
- lifecycle events 只允许 `configured`、`started`、`account_context_bound`、`ema_strategy_registered`、`coordination_risk_handoff_prepared` 和 `shutdown`。
- report 必须保持 `directExecutionClientEnabled == false`、`brokerCommandEnabled == false`、`omsBypassEnabled == false`、`productionTradingEnabledByDefault == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。

该 lifecycle 不读取 production secret，不连接 production endpoint，不提交 / 撤销 / 替换订单，不直连 ExecutionClient、broker 或 OMS，不暴露 Dashboard command surface，也不把 private stream read-model evidence 扩大成 command runtime。

`TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE`

## GH-527-NON-AUTHORIZATION

`GH-527-NON-AUTHORIZATION`

GH-527 不授权：

- 非 Binance venue。
- 非 EMA active strategy。
- direct Trader / Strategy -> ExecutionClient path。
- broker command、OMS bypass 或 executable order command。
- production secret、production endpoint 或 production trading。
- Dashboard command surface、trading button、live command 或 order form。

## GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME

`GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME`

EMA strategy proposal runtime 指 release v0.1.0 中唯一 active concrete strategy `EMA` 的 signal-to-proposal path。该 runtime 位于 `Sources/Trader/Strategies/EMA/EMAProposalRuntime.swift`，只把 `EMACrossSignalSample` / market bars 转成 paper-only `PaperActionProposal` 和 RiskEngine 可消费的 `RiskEvaluationQuery` evidence：

- active venue 固定为 `Binance`。
- active concrete strategy 固定为 `EMA`。
- proposal 必须保持 `executionMode == .paper`、`executionAuthorization == .paperIntentOnly` 和 `isExecutableAsRealOrder == false`。
- RiskEngine consumable evidence 必须保持 risk query 与 proposal 的 `paperOrderID`、symbol、timeframe、quantity 和 paper execution mode 一致。
- runtime report 必须保持 `directExecutionClientEnabled == false`、`brokerCommandEnabled == false`、`omsBypassEnabled == false`、`productionTradingEnabledByDefault == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。

`TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME`

## GH-528-NON-AUTHORIZATION

`GH-528-NON-AUTHORIZATION`

GH-528 不授权：

- 非 Binance venue。
- 非 EMA active strategy。
- Trader / Strategy 直连 ExecutionClient。
- broker command、OMS bypass、executable order command、submit / cancel / replace。
- production secret、production endpoint 或 production trading。
- Dashboard command surface、trading button、live command 或 order form。
- RiskEngine bypass、ExecutionEngine bypass、kill switch bypass 或 no-trade bypass。

## GH-529-RISKENGINE-LIVE-PRETRADE-GATE

`GH-529-RISKENGINE-LIVE-PRETRADE-GATE`

RiskEngine live pre-trade gate 指 release v0.1.0 中 RiskEngine 对 #528 EMA paper proposal 的交易前裁决面。该 gate 只能消费 neutral `PaperActionProposal` / `RiskEvaluationQuery`，输出 approve / reject / blocked evidence：

- 所有 proposal 必须先进入 RiskEngine gate，不能被 Trader、Strategy、ExecutionEngine 或 OMS 绕过。
- `approved` 只表示本地 RiskEngine pre-trade gate 通过，不表示 ExecutionEngine、OMS、broker 或 production trading 已获授权。
- `rejected` 必须记录 quantity / notional / available balance 等可审计拒绝原因。
- `blocked` 必须覆盖 no-trade guard，并保持 command path closed。
- decision evidence 必须保持 `authorizesExecutionCommand == false`、`productionTradingEnabledByDefault == false`、`callsExecutionClient == false`、`touchesBrokerGateway == false`、`bypassesOMS == false`、`submitsRealOrder == false`、`exposesLiveCommandSurface == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。

`TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE`

## GH-529-NON-AUTHORIZATION

`GH-529-NON-AUTHORIZATION`

GH-529 不授权：

- 非 Binance venue。
- 非 EMA active strategy。
- RiskEngine bypass、ExecutionEngine bypass、OMS bypass、kill switch bypass 或 no-trade bypass。
- ExecutionClient / broker gateway / order command / submit / cancel / replace。
- production secret、production endpoint 或 production trading。
- Dashboard command surface、trading button、live command 或 order form。

## GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE

`GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE`

ExecutionEngine OMS state machine 指 release v0.1.0 中 ExecutionEngine 对 #529 RiskEngine decision evidence 的本地订单生命周期证据。它只生成 deterministic event log / audit evidence，覆盖 `new`、`accepted`、`rejected`、`canceled`、`replaced`、`filled` 状态：

- 只有 #529 `approved` risk decision 能创建本地 order intent，并进入 accepted / canceled / replaced / filled path。
- #529 `rejected` 或 `blocked` risk decision 只能进入 rejected path，不能 fallback 到 ExecutionClient、broker retry 或 OMS bypass。
- OMS event log 必须 append-only、deterministic、audit-only，不能写 production order store。
- state machine evidence 必须保持 `productionTradingEnabledByDefault == false`、`productionOMSRuntimeEnabledByDefault == false`、`callsExecutionClient == false`、`touchesBrokerGateway == false`、`submitsRealOrder == false`、`cancelsRealOrder == false`、`replacesRealOrder == false`、`performsReconciliation == false`、`exposesLiveCommandSurface == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。

`TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE`

## GH-530-NON-AUTHORIZATION

`GH-530-NON-AUTHORIZATION`

GH-530 不授权：

- 非 Binance venue。
- 非 EMA active strategy。
- ExecutionClient testnet submit / cancel / replace runtime；该能力留给 GH-531。
- production OMS runtime、production order store 或 broker gateway。
- execution report / broker fill parser；该能力留给 GH-532。
- reconciliation / Portfolio update path；该能力留给 GH-533。
- production secret、production endpoint 或 production trading。
- Dashboard command surface、trading button、live command 或 order form。

## GH-521-NON-AUTHORIZATION

`GH-521-NON-AUTHORIZATION`

GH-521 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- runtime implementation。
- production trading。
- production secret read / print / storage。
- production endpoint connection。
- non-Binance venue。
- non-EMA active strategy。
- RiskEngine bypass。
- ExecutionEngine / OMS bypass。
- kill switch / no-trade bypass。
- real production submit / cancel / replace。
- production Dashboard command surface。
- 下一 Project / Issue 创建或 release v0.1.0 后续阶段推进。
