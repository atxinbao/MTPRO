# Release v0.6.0 ExecutionEngine / OMS Dry-run Runner Contract

日期：2026-06-14

执行者：Codex

## Scope

`V060-008-EXECUTION-OMS-DRY-RUN-RUNNER` 固定 GH-762 的 ExecutionEngine / OMS dry-run runner 合同。该 runner 只消费 GH-761 同一 local run journal 中的 `allowed` typed `RiskDecisionEvent`，并继续追加 typed `OMSLifecycleEvent` 与本地 `ExecutionClientDryRunEvent` evidence。

该合同只授权本地 dry-run lifecycle evidence。它不连接 broker gateway，不打开 production OMS，不读取 production secret，不连接 production endpoint，不发送真实 submit / cancel / replace，也不授权 production cutover。

## Contract Anchors

- `V060-008-EXECUTION-OMS-DRY-RUN-RUNNER`
- `V060-008-ALLOWED-RISK-TO-OMS-LIFECYCLE`
- `V060-008-REJECTED-BLOCKED-NO-SUBMIT`
- `V060-008-SIMULATED-SUBMIT-NOT-REAL`
- `V060-008-SAME-RUN-JOURNAL-OMS-SEQUENCE`
- `V060-008-NO-PRODUCTION-OMS-BROKER-PATH`
- `TVM-RELEASE-V060-EXECUTION-OMS-DRY-RUN-RUNNER`

## Required Evidence

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV060ExecutionOMSDryRunRunner.swift`
- `ReleaseV060ExecutionOMSDryRunRunnerContract`
- `ReleaseV060ExecutionOMSDryRunRunner`
- `ReleaseV060ExecutionOMSDryRunRunnerResult`
- `ReleaseV060ExecutionOMSDryRunLifecyclePath`
- `ReleaseV060ExecutionOMSDryRunSuppression`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 中的 `testGH762ExecutionOMSDryRunRunnerConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmit`
- `checks/verify-v0.6.0-execution-oms-dry-run-runner.sh`

## Validation

GH-762 required validation：

- `swift test --filter TargetGraphTests/testGH762ExecutionOMSDryRunRunnerConsumesAllowedRiskDecisionAndBlocksRejectedOrBlockedSubmit`
- `bash checks/verify-v0.6.0-execution-oms-dry-run-runner.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`V060-008-ALLOWED-RISK-TO-OMS-LIFECYCLE` 要求 runner 只能从 `allowed` `RiskDecisionEvent` 创建 dry-run OMS lifecycle。Rejected / blocked risk decision 必须停在 suppression evidence。

`V060-008-REJECTED-BLOCKED-NO-SUBMIT` 要求 rejected / blocked decision 的 `omsLifecycleCreated=false`、`executionDryRunEventCreated=false`、`submitPathCreated=false`、`brokerCommandCreated=false`。

`V060-008-SIMULATED-SUBMIT-NOT-REAL` 要求 `simulatedSubmitted` 只由 local dry-run event 表达，不连接真实 broker，不发送真实 submit。Cancel 也只能作为 local simulated cancel evidence，replace 不启用。

`V060-008-SAME-RUN-JOURNAL-OMS-SEQUENCE` 要求 DataEngineMarketEvent、StrategyIntentEvent、RiskDecisionEvent、OMSLifecycleEvent 和 ExecutionClientDryRunEvent 保留同一 runID / streamID / correlationID / causation chain 和 append-only sequence。

`V060-008-NO-PRODUCTION-OMS-BROKER-PATH` 要求本 runner 不授权 production OMS、不连接 ExecutionClient implementation、不接 broker gateway、不读取 secret、不连接 endpoint、不发送真实订单、不授权 production cutover。

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
