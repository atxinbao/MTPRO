# Release v0.3.0 Runtime Rehearsal Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-657 V030-01 Define v0.3.0 runtime rehearsal contract`。

本文档定义 `MTPRO Release v0.3.0 Runtime Rehearsal v1` 的第一层 rehearsal 合同。它只固定 dry-run / testnet / shadow / production-blocked 的验证边界，不打开 production trading，不读取 production secret，不连接 production endpoint，不提交真实订单，不授权 production cutover，也不启动下一 milestone。

## V030-01-RUNTIME-REHEARSAL-CONTRACT

`V030-01-RUNTIME-REHEARSAL-CONTRACT`

GH-657 是 V030 queue `GH-657..GH-670` 的第一个 gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ReleaseV030RuntimeRehearsalContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V030-RUNTIME-REHEARSAL-CONTRACT`

合同固定：

- release version 固定为 `v0.3.0`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-657..GH-670`
- downstream issue 固定为 `GH-658`
- production capability defaults 必须关闭
- CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store gate 必须全部可审计且不可绕过。

## V030-01-REHEARSAL-MODES

`V030-01-REHEARSAL-MODES`

v0.3.0 rehearsal mode 固定为：

- `dry-run`
- `testnet`
- `shadow`
- `production-blocked`

`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V030-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY

`V030-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY`

v0.3.0 继续继承 release v0.2.x 的 active scope：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot, usdsPerpetual]`
- `allowedStrategies == [EMA, RSI]`

任何非 Binance venue、Spot / USDⓈ-M Perpetual 之外的 product type、EMA / RSI 之外的 active strategy 都不属于 GH-657 scope。

## V030-01-FORBIDDEN-PRODUCTION-CAPABILITIES

`V030-01-FORBIDDEN-PRODUCTION-CAPABILITIES`

GH-657 必须保持以下默认关闭或禁止：

- `productionTradingEnabledByDefault == false`
- `productionSecretAutoReadEnabled == false`
- `productionEndpointAutoConnectEnabled == false`
- `productionOrderSubmissionEnabled == false`
- `productionCutoverAuthorized == false`
- `dashboardCLICommandGatewayBypassAllowed == false`
- `strategyExecutionClientDirectAccessAllowed == false`
- `riskExecutionOMSEventStoreBypassAllowed == false`
- `startsNextMilestone == false`

本文档不创建 secret provider、signed request runtime、listenKey runtime、private stream runtime、broker adapter、production OMS、real submit / cancel / replace path 或 production cutover path。

## V030-01-ONE-COMMAND-REHEARSAL-SUCCESS-CRITERIA

`V030-01-ONE-COMMAND-REHEARSAL-SUCCESS-CRITERIA`

GH-657 只定义未来 one-command rehearsal 的 success criteria。命名固定为 `verify-v0.3.0`，但本 issue 不新增 runner。后续 issue 必须逐项回填 deterministic evidence：

- DataEngine -> Cache rehearsal evidence
- Trader / EMA / RSI rehearsal evidence
- RiskEngine rehearsal gate evidence
- ExecutionEngine / OMS rehearsal lifecycle evidence
- ExecutionClient dry-run / testnet evidence
- Event Store / replay rehearsal evidence
- Portfolio projection rehearsal evidence
- Dashboard / CLI CommandGateway rehearsal evidence
- kill switch / no-trade / rollback rehearsal evidence
- forbidden production capability guard evidence

## V030-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-AUDITABLE-GATES

`V030-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-AUDITABLE-GATES`

Dashboard / CLI 不得绕过 CommandGateway。Strategy 不得直接访问 ExecutionClient 或 Binance adapter。RiskEngine / ExecutionEngine / OMS / Event Store gate 必须可审计，并且后续 rehearsal evidence 只能沿这些 gate 汇总。

Required evidence：

- `commandGatewayRequired == true`
- `riskEngineRequired == true`
- `executionEngineRequired == true`
- `omsRequired == true`
- `eventStoreRequired == true`

## TVM-RELEASE-V030-RUNTIME-REHEARSAL-CONTRACT

`TVM-RELEASE-V030-RUNTIME-REHEARSAL-CONTRACT`

Required validation：

- `swift test --filter TargetGraphTests/testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V030-01 Non-authorization

GH-657 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- production order submission。
- production cutover authorization。
- broker adapter / real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- trading button / live command / order form。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- Dashboard / CLI 旁路 CommandGateway。
- Strategy 直连 ExecutionClient 或 Binance adapter。
- 下一 Project / Issue / milestone 自动启动。
