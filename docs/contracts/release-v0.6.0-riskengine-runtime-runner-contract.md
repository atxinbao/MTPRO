# Release v0.6.0 RiskEngine Runtime Runner Contract

日期：2026-06-14

执行者：Codex

## Scope

`V060-007-RISKENGINE-RUNTIME-RUNNER` 固定 GH-761 的 RiskEngine runtime runner 合同。该 runner 只消费 GH-760 在同一 local run journal 中追加的 typed `StrategyIntentEvent` envelope，并在同一 runID、streamID、correlationID 和 causation chain 下追加 typed `RiskDecisionEvent` envelope。

该合同只授权本地 dry-run RiskEngine 决策证据。它不创建 OMS lifecycle，不连接 ExecutionClient，不接 broker gateway，不读取 production secret，不连接 production endpoint，不发送真实订单，也不授权 production cutover。

## Contract Anchors

- `V060-007-RISKENGINE-RUNTIME-RUNNER`
- `V060-007-STRATEGY-INTENT-TO-RISK-DECISION`
- `V060-007-ALLOW-REJECT-BLOCKED-POLICY-EVIDENCE`
- `V060-007-KILL-SWITCH-NO-TRADE-BLOCKS-OMS`
- `V060-007-SAME-RUN-JOURNAL-RISK-SEQUENCE`
- `V060-007-NO-RISK-EXECUTION-PATH`
- `TVM-RELEASE-V060-RISKENGINE-RUNTIME-RUNNER`

## Required Evidence

- `Sources/RiskEngine/LiveGate/ReleaseV060RiskEngineRuntimeRunner.swift`
- `ReleaseV060RiskEngineRuntimeRunnerContract`
- `ReleaseV060RiskEngineRuntimeRunner`
- `ReleaseV060RiskEngineRuntimeRunnerResult`
- `ReleaseV060RiskEngineRuntimeDecisionEmission`
- `ReleaseV050RiskEngineRuntimePolicy`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 中的 `testGH761RiskEngineRuntimeRunnerConsumesStrategyIntentsAndEmitsAllowRejectBlockedDecisions`
- `checks/verify-v0.6.0-riskengine-runtime-runner.sh`

## Validation

GH-761 required validation：

- `swift test --filter TargetGraphTests/testGH761RiskEngineRuntimeRunnerConsumesStrategyIntentsAndEmitsAllowRejectBlockedDecisions`
- `bash checks/verify-v0.6.0-riskengine-runtime-runner.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`V060-007-STRATEGY-INTENT-TO-RISK-DECISION` 要求 RiskEngine 从同一 run journal 中筛选 typed `StrategyIntentEvent` envelope，并只产出 typed `RiskDecisionEvent` envelope。Risk decision 必须保留 `sourceIntentID`、`decision` 和 `reason`，下游只能从 `allowed` decision 继续，不能绕过 RiskEngine。

`V060-007-ALLOW-REJECT-BLOCKED-POLICY-EVIDENCE` 要求 deterministic policy coverage 明确覆盖 allow、reject 和 blocked。Reject 使用 notional policy evidence；blocked 使用 kill switch 和 no-trade gate evidence。

`V060-007-KILL-SWITCH-NO-TRADE-BLOCKS-OMS` 要求 kill switch 与 no-trade 输出 `blocked` decision，并证明没有 downstream OMS lifecycle、ExecutionClient request、submit path 或 broker command。

`V060-007-SAME-RUN-JOURNAL-RISK-SEQUENCE` 要求 DataEngineMarketEvent、StrategyIntentEvent 和 RiskDecisionEvent 在同一个 append-only run journal 中保持连续 sequence、correlationID 和 causation chain。

`V060-007-NO-RISK-EXECUTION-PATH` 要求本 runner 不 import ExecutionEngine / ExecutionClient，不创建 OMS path，不连接 endpoint，不读取 secret，不发送真实订单，不授权 production cutover。

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
