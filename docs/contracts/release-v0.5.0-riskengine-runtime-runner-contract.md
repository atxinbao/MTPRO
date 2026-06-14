# Release v0.5.0 RiskEngine Runtime Runner Contract

日期：2026-06-14

执行者：Codex

## Scope

`V050-09-RISKENGINE-RUNTIME-RUNNER` 固定 GH-734 的 RiskEngine runtime runner 合同。该 runner 消费 GH-730 typed `StrategyIntentEvent` envelope，应用 notional / exposure policy、kill switch 和 no-trade gate，并产出 typed `RiskDecisionEvent` envelope。

该合同只授权 dry-run / rehearsal 风控决策证据。它不创建 ExecutionEngine bypass，不创建 OMS lifecycle，不连接 ExecutionClient，不接 broker gateway，不读取 production secret，不连接 production endpoint，不发送真实订单，也不授权 production cutover。

## Contract Anchors

- `V050-09-RISKENGINE-RUNTIME-RUNNER`
- `V050-09-STRATEGY-INTENT-TO-RISK-DECISION`
- `V050-09-NOTIONAL-EXPOSURE-POLICY-EVIDENCE`
- `V050-09-KILL-SWITCH-NO-TRADE-BLOCKS`
- `V050-09-RUN-JOURNAL-REPLAYABLE-RISK-DECISIONS`
- `TVM-RELEASE-V050-RISKENGINE-RUNTIME-RUNNER`

## Required Evidence

- `Sources/RiskEngine/LiveGate/ReleaseV050RiskEngineRuntimeRunner.swift`
- `ReleaseV050RiskEngineRuntimeRunnerContract`
- `ReleaseV050RiskEngineRuntimeRunner`
- `ReleaseV050RiskEngineRuntimeRunnerEvidence`
- `ReleaseV050RiskEngineRuntimePolicy`
- `ReleaseV050RiskEngineRuntimeDecisionEmission`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 中的 `testGH734RiskEngineRuntimeRunnerConsumesStrategyIntentAndEmitsReplayableDecisions`
- `checks/verify-v0.5.0-riskengine.sh`

## Validation

GH-734 required validation：

- `swift test --filter TargetGraphTests/testGH734RiskEngineRuntimeRunnerConsumesStrategyIntentAndEmitsReplayableDecisions`
- `bash checks/verify-v0.5.0-riskengine.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`V050-09-STRATEGY-INTENT-TO-RISK-DECISION` 要求 RiskEngine 只消费 typed `StrategyIntentEvent` envelope，并只产出 typed `RiskDecisionEvent` envelope。Decision payload 必须保留 `sourceIntentID`、`decision` 和 `reason`，下游只能从 `allowed` decision 继续，不能绕过 RiskEngine。

`V050-09-NOTIONAL-EXPOSURE-POLICY-EVIDENCE` 要求每个 decision 保留 policy snapshot evidence，包括 target quantity、projected notional、projected aggregate exposure 和 passed policy checks。Notional / exposure 只使用 deterministic fixed-point evidence，不读取真实账户或 broker state。

`V050-09-KILL-SWITCH-NO-TRADE-BLOCKS` 要求 kill switch 和 no-trade gate 输出 `blocked` decision，并且不能产生 order lifecycle、ExecutionClient request 或 broker command。

`V050-09-RUN-JOURNAL-REPLAYABLE-RISK-DECISIONS` 要求 StrategyIntentEvent 与 RiskDecisionEvent envelope 保留同一 runID / streamID / correlationID / causation chain，并可由 GH-731 local run journal replay。

## Non-goals

- 不实现 ExecutionEngine / OMS dry-run lifecycle。
- 不实现 ExecutionClient request、broker adapter 或 network connector。
- 不读取 signed endpoint、account endpoint、listenKey 或 private WebSocket runtime。
- 不读取 production secret。
- 不连接 production endpoint 或 broker endpoint。
- 不发送 submit / cancel / replace。
- 不实现 Portfolio projection。
- 不实现 Dashboard / CLI observer。
- 不授权 production trading 或 production cutover。
