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
- `TVM-RELEASE-V010-BINANCE-EMA-RUNTIME`
- `TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`
- `TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH`
- `TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

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
