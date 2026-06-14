# Release v0.5.0 ExecutionEngine / OMS Dry-run Lifecycle Contract

日期：2026-06-14

执行者：Codex

## Scope

`V050-10-EXECUTION-OMS-DRY-RUN-LIFECYCLE` 固定 GH-735 的 ExecutionEngine / OMS dry-run lifecycle。该 lifecycle 只消费 GH-734 的 `allowed` `RiskDecisionEvent`，并在 typed RuntimeMessageBus / local run journal 兼容 envelope 中输出 `OMSLifecycleEvent` 与 `ExecutionClientDryRunEvent`。

该合同只授权 dry-run / sandbox lifecycle evidence。它不连接 broker gateway，不打开 production OMS，不读取 production secret，不连接 production endpoint，不发送真实 submit / cancel / replace，也不授权 production cutover。

## Contract Anchors

- `V050-10-EXECUTION-OMS-DRY-RUN-LIFECYCLE`
- `V050-10-RISK-DECISION-TO-OMS-LIFECYCLE`
- `V050-10-DRY-RUN-EXECUTION-EVENTS`
- `V050-10-REJECTED-BLOCKED-RISK-NO-SUBMIT`
- `V050-10-RUN-JOURNAL-REPLAYABLE-OMS-EXECUTION`
- `TVM-RELEASE-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE`

## Required Evidence

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV050ExecutionOMSDryRunLifecycle.swift`
- `Sources/MessageBus/RuntimeMessageBus.swift` 的 v0.5 OMS state vocabulary
- `ReleaseV050ExecutionOMSDryRunLifecycleContract`
- `ReleaseV050ExecutionOMSDryRunLifecycleRunner`
- `ReleaseV050ExecutionOMSDryRunLifecycleEvidence`
- `ReleaseV050ExecutionOMSDryRunLifecyclePath`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 中的 `testGH735ExecutionOMSDryRunLifecycleConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmitPaths`
- `checks/verify-v0.5.0-oms.sh`

## Validation

GH-735 required validation：

- `swift test --filter TargetGraphTests/testGH735ExecutionOMSDryRunLifecycleConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmitPaths`
- `bash checks/verify-v0.5.0-oms.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`V050-10-RISK-DECISION-TO-OMS-LIFECYCLE` 要求 lifecycle 只从 `allowed` `RiskDecisionEvent` 创建本地 order path。Rejected / blocked decision 必须保留 suppression evidence，且 `orderPathCreated=false`、`dryRunSubmitCreated=false`、`brokerGatewayConnected=false`。

`V050-10-DRY-RUN-EXECUTION-EVENTS` 要求 typed event 覆盖：

- `created`
- `riskApproved`
- `acceptedByOMS`
- `simulatedSubmitted`
- `simulatedPartiallyFilled`
- `simulatedFilled`
- `simulatedRejected`
- `simulatedCancelled`

`V050-10-RUN-JOURNAL-REPLAYABLE-OMS-EXECUTION` 要求 GH-734 risk evidence 与 GH-735 lifecycle events 共享同一 runID / streamID / correlationID / causation chain，并可由 GH-731 local run journal replay。

## Non-goals

- 不实现真实 submit / cancel / replace。
- 不连接 broker gateway。
- 不启用 production OMS。
- 不读取 signed endpoint、account endpoint、listenKey 或 private WebSocket runtime。
- 不读取 production secret。
- 不连接 production endpoint 或 broker endpoint。
- 不实现 Portfolio projection。
- 不实现 Dashboard / CLI observer。
- 不授权 production trading 或 production cutover。
