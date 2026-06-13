# Release v0.4.0 Shadow Replay Mode Contract

日期：2026-06-13

执行者：Codex

## 目标

GH-706 / V040-13 定义 release v0.4.0 的 shadow replay mode。该 mode 读取 historical / deterministic market-event 与 run-event 输入，在不连接 broker、不连接 testnet / production endpoint、不读取 secret、不发送订单的前提下，复用统一 `runID` rehearsal context，输出与 dry-run 相同 shape 的 evidence chain。

该合同不授权 live testnet 连接，不授权 production endpoint，不授权 signed endpoint、account endpoint、broker gateway、真实订单、production cutover 或下一 milestone 启动。Shadow replay success 只能作为 replay evidence，不能作为 production approval。

## Anchors

- `V040-13-SHADOW-REPLAY-MODE`
- `V040-13-HISTORICAL-DETERMINISTIC-INPUT`
- `V040-13-SAME-RUNID-EVIDENCE-CHAIN-SHAPE`
- `V040-13-NO-NETWORK-BROKER-CALLS`
- `V040-13-SHADOW-IS-NOT-PRODUCTION-APPROVAL`
- `TVM-RELEASE-V040-SHADOW-REPLAY-MODE`

## Scope

- `Sources/ExecutionClient/FutureGate/ReleaseV040ShadowReplayMode.swift` owns GH-706 deterministic shadow replay evidence.
- `ReleaseV040ShadowReplayInputEvent` records historical deterministic market-event / run-event inputs for Spot + USDⓈ-M Perpetual and EMA + RSI.
- `ReleaseV040ShadowReplayStepEvidence` reuses `ReleaseV040RuntimeKernelDryRunOrchestrator.requiredStepOrder` so shadow replay produces the same runID evidence chain shape as dry-run.
- `ReleaseV040ShadowReplayModeEvidence` records replay-only boundary flags and required validation anchors.
- `Tests/TargetGraphTests/TargetGraphTests.swift` must include `testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls`.

## Acceptance

- Shadow replay uses `ReleaseV040RehearsalRunContext.mode == .shadow`.
- Shadow replay input covers historical market-event and historical run-event sources.
- Shadow replay input covers Binance Spot + USDⓈ-M Perpetual and EMA + RSI release v0.4.0 boundaries.
- Shadow replay evidence step order equals the dry-run orchestrator step order.
- Shadow replay evidence uses one `runID` across all unified evidence envelopes.
- Shadow replay source and docs contain `TVM-RELEASE-V040-SHADOW-REPLAY-MODE`.
- Boundary rejection proves broker connection attempts are forbidden.

## Boundary

- No network call.
- No broker connection.
- No testnet connection.
- No production endpoint connection.
- No production secret read.
- No signed endpoint.
- No account endpoint.
- No listenKey / private WebSocket runtime.
- No order submit / cancel / replace.
- No production order submission.
- No production cutover authorization.
- Shadow success is not production approval.
- No next milestone auto-start.

## Required Validation

- `swift test --filter TargetGraphTests/testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls`
- `bash checks/verify-v0.3.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
