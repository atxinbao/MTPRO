# Release v0.16.0 Failure Recovery Workflow Contract

日期：2026-06-26  
执行者：Codex

## Issue

#1109 / GH-1109: V160-009 Add failure recovery workflow

## Goal

定义 v0.16.0 Binance Spot Testnet operator beta 的 ambiguous failure recovery workflow。该合同覆盖 submit 已可能到达交易所但本地 artifact 写入失败、network timeout 但 exchange receipt 未知、cancel unknown state，以及 status query compensation workflow。

## Scope

- `GH-1109-VERIFY-V0160-FAILURE-RECOVERY-WORKFLOW`
- `TVM-RELEASE-V0160-FAILURE-RECOVERY-WORKFLOW`
- `V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED`
- `V0160-009-NETWORK-TIMEOUT-POSSIBLE-EXCHANGE-RECEIPT`
- `V0160-009-CANCEL-UNKNOWN-STATE`
- `V0160-009-STATUS-QUERY-COMPENSATION-WORKFLOW`
- `V0160-009-NO-AUTOMATIC-PRODUCTION-RETRY`
- `V0160-009-NO-PRODUCTION-CUTOVER`

## Contract

`ReleaseV0160FailureRecoveryWorkflowEngine` 只生成本地 recovery runbook evidence。恢复步骤固定为 freeze run、quarantine partial artifact、preserve redacted transport evidence、run status query compensation、reconcile observed status、require operator review 和 close failed no retry。

status query compensation 必须使用已授权的 #1105 signed GET status query flow 产生新的脱敏 status artifact，再由 #1107 OMS observed-status reconciliation 处理。#1109 本身不执行网络请求，不自动 retry submit / cancel，不连接 production endpoint，也不读取 secret。

## Non-goals

- 不启用 production trading。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 production order。
- 不授权 production cutover。
- 不新增非 Binance venue。
- 不扩展到 Binance Spot Testnet operator beta 之外。
- 不新增 Dashboard trading button、order form 或 live command。

## Boundary

所有 recovery case 都必须 `failClosed == true`、`automaticRetryBlocked == true`、`productionRetryBlocked == true`、`localRecoveryEvidenceOnly == true`。任何 production flag、credential value、raw order identity 或 raw broker payload 都必须 fail closed。

## Validation

- `swift test --filter TargetGraphTests/testGH1109ReleaseV0160FailureRecoveryWorkflowHandlesAmbiguousStatesFailClosed`
- `bash checks/verify-v0.16.0-failure-recovery-workflow.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Acceptance Criteria

- 四类 ambiguous failure scenario 全部被本地 recovery report 覆盖。
- timeout、partial artifact、cancel unknown state 和 status query compensation 都有明确 operator runbook evidence。
- no automatic retry into production 保持为真。
- production trading 默认关闭，不授权 production cutover。
