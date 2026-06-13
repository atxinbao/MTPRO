# Release v0.4.0 ExecutionEngine / OMS Dry-run Lifecycle Contract

日期：2026-06-13  
执行者：Codex

## Scope

`V040-07-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE`

GH-700 在 `ExecutionEngine` target 的 `OMSFutureGate` 内定义 v0.4.0 ExecutionEngine / OMS dry-run lifecycle evidence。该 lifecycle 只消费 #699 的 RiskEngine allow / reject decision evidence，并产出 run-scoped local order lifecycle、OMS replay 和 unified envelope evidence。

## Required Evidence

- `V040-07-RISK-APPROVED-INTENT-TO-LOCAL-ORDER`：只有 RiskEngine allow decision 可以生成本地 order intent。
- `V040-07-RUN-SCOPED-OMS-STATE-REPLAY`：created、accepted、submitted-dry-run、filled-simulated、cancelled 和 rejected 状态必须带同一 runID，并可由 append-only MessageBus journal replay。
- `V040-07-NO-PRODUCTION-BROKER-CALL`：ExecutionEngine / OMS dry-run lifecycle 不调用 ExecutionClient、不触碰 broker gateway、不提交真实订单。
- `TVM-RELEASE-V040-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE`：trading validation matrix anchor。

## Boundary

GH-700 不实现 Binance ExecutionClient adapter、不连接 testnet / production endpoint、不读取 secret、不提交真实 submit / cancel / replace、不实现 production OMS cutover、不做 reconciliation、不创建 Dashboard / CLI command surface。后续 #701 只能消费本地 dry-run lifecycle evidence 定义 dry-run ExecutionClient adapter boundary，不得绕过 RiskEngine / ExecutionEngine / OMS gate。

## Validation

- `swift test --filter TargetGraphTests/testGH700ExecutionOMSDryRunLifecycleConsumesRiskApprovedDecisionAndReplaysRunScopedEvents`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
