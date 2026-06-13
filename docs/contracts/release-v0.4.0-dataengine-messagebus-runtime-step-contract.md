# Release v0.4.0 DataEngine MessageBus Runtime Step Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-697 V040-04 Wire DataEngine runtime step into MessageBus`。

本文档定义 DataEngine 在 v0.4.0 unified runtime rehearsal pipeline 中的 local dry-run 输出：Binance Spot 与 USDⓈ-M Perpetual market events 必须带 product identity、共享 `RehearsalRunContext.runID`，并通过 `MessageBusAppendOnlyJournal` 进入 unified run evidence chain。

## V040-04-DATAENGINE-MESSAGEBUS-RUNTIME-STEP

`V040-04-DATAENGINE-MESSAGEBUS-RUNTIME-STEP`

`Sources/DataEngine/ReleaseV040DataEngineMessageBusRuntimeStep.swift` 定义：

- `ReleaseV040DataEngineMessageBusPayloadType`
- `ReleaseV040DataEngineMessageBusEmission`
- `ReleaseV040DataEngineMessageBusRuntimeStepEvidence`
- `ReleaseV040DataEngineMessageBusRuntimeStep`

该 step 只消费本地 product-aware `MarketEvent`，不创建 DataClient network request，不连接 Binance endpoint，不读取 secret，不提交订单。

## V040-04-RUN-SCOPED-MARKET-EVENTS

`V040-04-RUN-SCOPED-MARKET-EVENTS`

每个 DataEngine emission 必须同时持有：

- `ReleaseV040RehearsalRunContext`
- DataEngine unified evidence envelope
- MessageBus unified evidence envelope
- `MessageBusJournalEnvelope`

上述 evidence 必须共享同一个 `runID`。MessageBus envelope 必须以上一个 DataEngine envelope 为 upstream evidence，证明 market event 已从 DataEngine 进入 MessageBus，而不是停留在孤立 evidence surface。

## V040-04-BINANCE-SPOT-PERP-PRODUCT-IDENTITY

`V040-04-BINANCE-SPOT-PERP-PRODUCT-IDENTITY`

GH-697 必须覆盖：

- Binance Spot market event。
- Binance USDⓈ-M Perpetual market event。
- 每个 `MessageBusJournalEnvelope.instrumentID` 必须携带 `InstrumentIdentity`。
- `InstrumentIdentity.productType` 必须分别为 `spot` 和 `usdsPerpetual`。

非 Binance venue、非 Spot / USDⓈ-M Perpetual product、缺少 instrument identity 或 market event symbol 与 instrument symbol 不一致时必须 fail closed。

## V040-04-FORBIDDEN-NETWORK-SECRET-PRODUCTION

`V040-04-FORBIDDEN-NETWORK-SECRET-PRODUCTION`

GH-697 必须保持以下能力关闭：

- network calls performed：false
- secret reads performed：false
- production endpoint connected：false
- production broker connected：false
- production order submitted：false
- production cutover authorized：false

本文档不授权 live market data endpoint、signed endpoint、account endpoint、listenKey、private WebSocket、ExecutionClient implementation、broker gateway、OMS runtime、real order lifecycle、trading button、live command 或 order form。

## TVM-RELEASE-V040-DATAENGINE-MESSAGEBUS-RUNTIME-STEP

`TVM-RELEASE-V040-DATAENGINE-MESSAGEBUS-RUNTIME-STEP`

Required validation：

- `swift test --filter TargetGraphTests/testGH697DataEngineRuntimeStepPublishesRunScopedMarketEventsIntoMessageBus`
- `bash checks/verify-v0.3.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V040-04 Non-authorization

GH-697 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- live market data endpoint。
- testnet 默认开启。
- production endpoint / broker endpoint。
- production secret read。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- production cutover authorization。
