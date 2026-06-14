# Release v0.5.0 Typed RuntimeMessageBus Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-730 V050-05 Typed RuntimeMessageBus actor`。

GH-730 把 v0.4.0 metadata journal 方向升级为 typed runtime MessageBus actor 和 `RuntimeEventEnvelope<Payload>` 合同。它只定义 MessageBus target 内部的 typed envelope、event family、actor isolation 和 checksum evidence；不连接 broker、不读取 secret、不连接 testnet / production endpoint、不发送真实订单、不授权 production cutover。

## V050-05-TYPED-RUNTIME-MESSAGEBUS-ACTOR

`V050-05-TYPED-RUNTIME-MESSAGEBUS-ACTOR`

权威 source anchor：

- `Sources/MessageBus/RuntimeMessageBus.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH730TypedRuntimeMessageBusActorPublishesAuditableEnvelopes`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS`
- `checks/verify-v0.5.0-messagebus.sh`

`RuntimeMessageBus` 必须是 actor boundary。它只维护本地 append-only envelope 数组和 replay 视图，不启动外部 pub/sub，不调用 DataEngine / Trader / RiskEngine / ExecutionEngine / ExecutionClient / Portfolio / Dashboard implementation。

## V050-05-RUNTIME-EVENT-ENVELOPE

`V050-05-RUNTIME-EVENT-ENVELOPE`

`RuntimeEventEnvelope<Payload>` 必须包含：

- `eventID`
- `runID`
- `sequence`
- `streamID`
- `correlationID`
- `causationID`
- `sourceModule`
- `payloadType`
- `payload`
- `recordedAt`
- `checksum`

`sequence` 必须单调递增。`payloadType` 必须来自 typed payload，`sourceModule` 必须和 payload family 匹配。`checksum` 是本地 deterministic identity evidence，不是安全签名，不代表外部信任。

## V050-05-TYPED-EVENT-FAMILIES

`V050-05-TYPED-EVENT-FAMILIES`

GH-730 固定以下 typed event families：

- `DataEngineMarketEvent`
- `StrategyIntentEvent`
- `RiskDecisionEvent`
- `OMSLifecycleEvent`
- `ExecutionClientDryRunEvent`
- `PortfolioProjectionEvent`
- `DashboardReadModelEvent`

这些 payload 只表达本地 evidence identity。它们不携带 signed endpoint payload、account endpoint payload、broker payload、raw private stream payload、production command 或 real order authorization。

## V050-05-RUN-CORRELATION-CAUSATION-CHECKSUM

`V050-05-RUN-CORRELATION-CAUSATION-CHECKSUM`

每个 envelope 必须保留同一个 `runID` 和 `correlationID`。后续 envelope 的 `causationID` 可指向前一 envelope 的 `eventID`，用于证明 local runtime chain 的因果顺序。

`RuntimeEventEnvelope.makeChecksum(...)` 必须把 run / stream / sequence / source / payload identity 纳入 checksum input。checksum mismatch 必须 fail closed。

## TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS

`TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS`

Required validation：

- `swift test --filter TargetGraphTests/testGH730TypedRuntimeMessageBusActorPublishesAuditableEnvelopes`
- `bash checks/verify-v0.5.0-messagebus.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-730 不授权：

- Linear / Symphony / Graphify / code-index / Figma。
- production secret read。
- testnet / production endpoint connection。
- broker gateway。
- signed endpoint runtime。
- account endpoint / listenKey / private WebSocket runtime。
- ExecutionClient command path。
- RiskEngine / OMS / ExecutionEngine bypass。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- production cutover。
- non-Binance venue。
- non-Spot / non-USDⓈ-M product。
- non-EMA / non-RSI active strategy。
- 下一 Project / Issue / milestone 自动启动。
