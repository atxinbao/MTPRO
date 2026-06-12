# Release v0.3.0 Trader Strategy Runtime Rehearsal Flow Contract

日期：2026-06-13

执行者：Codex

本文档是 GitHub issue `GH-660` 的执行合同证据。它只定义 `MTPRO Release v0.3.0 Runtime Rehearsal v1` 中 Trader 对 EMA / RSI strategy intent 的 rehearsal flow，不授权 production trading、production endpoint、secret 读取、Binance adapter、ExecutionClient、OMS 或真实订单。

## V030-04-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW

GH-660 在 `Sources/Trader/Runtime/ReleaseV030TraderStrategyRuntimeRehearsalFlow.swift` 中新增 `ReleaseV030TraderStrategyRuntimeRehearsalFlow`、`ReleaseV030TraderStrategyRuntimeRehearsalEvidence` 和 `ReleaseV030TraderStrategyRuntimeRehearsalRecord`。

该 flow 只调用 Trader-owned strategy emitters：

- `EMAProposalRuntime.generateTargetExposureIntent`
- `RSITargetExposureIntentEmitter.generateTargetExposureIntent`

输出只进入 `StrategyIntentMessage` 与 `MessageBusAppendOnlyJournal`，不进入 ExecutionClient、Binance adapter、ExecutionEngine、OMS、broker gateway 或 Dashboard command surface。

## V030-04-EMA-TARGET-EXPOSURE-INTENT-MESSAGEBUS

EMA rehearsal 必须满足：

- strategy name 固定为 `EMA`。
- venue 固定为 `binance`。
- product type 必须属于 `spot` 或 `usdsPerpetual`。
- output 必须是 `StrategyIntentMessage`。
- MessageBus payload type 必须包含 `trader.release-v0.3.0.binance`、`ema` 和 `targetExposureIntent`。
- 若 target exposure 需要 order intent，则只允许生成 pre-risk-gate `ProductAwareOrderIntent` evidence。

## V030-04-RSI-TARGET-EXPOSURE-INTENT-MESSAGEBUS

RSI rehearsal 必须满足：

- strategy name 固定为 `RSI`。
- venue 固定为 `binance`。
- product type 必须属于 `spot` 或 `usdsPerpetual`。
- output 必须是 `StrategyIntentMessage`。
- MessageBus payload type 必须包含 `trader.release-v0.3.0.binance`、`rsi` 和 `targetExposureIntent`。
- USDⓈ-M Perpetual short 只在 RSI emitter 的 explicit short gate 下作为 pre-risk-gate intent evidence 出现，不表示真实 short order。

## V030-04-NO-STRATEGY-EXECUTIONCLIENT-OR-BINANCE-ADAPTER-ACCESS

GH-660 必须保持以下边界：

- Trader target 依赖 `TraderStrategies` 与 `MessageBus`，不依赖 `ExecutionClient`。
- EMA / RSI source 不 import `ExecutionClient`。
- EMA / RSI source 不 import `DataClient` 或 Binance adapter。
- Strategy 不直接访问 Binance adapter、ExecutionClient、broker、OMS 或 production endpoint。
- Dashboard / CLI 不得绕过 CommandGateway。

## V030-04-TRACEABLE-TRADER-STRATEGY-REHEARSAL-EVIDENCE

GH-660 evidence 必须同时覆盖：

- issue id `GH-660`。
- upstream issue `GH-659`。
- downstream issue `GH-661`。
- canonical queue range `GH-657..GH-670`。
- release version `v0.3.0`。
- upstream DataEngine rehearsal anchor `TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW`。
- EMA 与 RSI intent messages。
- MessageBus append-only journal replay 与原始 envelope 一致。

Trader target 不依赖 DataEngine target；它只通过稳定 matrix anchor 证明已承接 GH-659 DataEngine rehearsal evidence，避免 Trader 获得 DataEngine internals、endpoint connector、secret provider、broker adapter 或 order command 能力。

## Forbidden Capability Boundary

GH-660 明确保持以下能力关闭：

- production endpoint auto-connect。
- production secret auto-read。
- production order submission。
- production cutover authorization。
- direct ExecutionClient access。
- direct Binance adapter access。
- CommandGateway bypass。
- next milestone auto-start。

任一能力被置为 true 时，Swift evidence 必须以 `CoreError.liveTradingBoundaryForbiddenCapability` fail closed。

## Validation

必跑验证：

- `swift test --filter TargetGraphTests/testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Trading Matrix Anchor

`TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW`

该矩阵锚点只覆盖 GH-660 Trader / EMA / RSI strategy intent rehearsal。它不授权真实 Binance production endpoint、signed endpoint、account endpoint、listenKey、private WebSocket、ExecutionClient implementation、OMS、broker fill、reconciliation runtime、Dashboard command 或 production cutover。
