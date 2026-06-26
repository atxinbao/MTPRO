# Release v0.17.0 Cancel / Status Reconciliation Recovery Path Contract

日期：2026-06-27  
执行者：Codex

## #1143 / GH-1143

GH-1143 / #1143 为 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 增加 cancel/status reconciliation recovery path。

该 contract 只消费已有本地证据：

- GH-1142 operator run resume cursor。
- GH-1107 OMS observed status reconciliation report。
- GH-1141 signed status query retry / timeout failure result。

它不读取 credential value，不连接 testnet / production endpoint，不执行 status query，不提交 / 取消 / 替换订单，不授权 production cutover。

## Validation Anchors

- `GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`
- `TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`
- `V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION`
- `V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY`
- `V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED`
- `V0170-005-STATUS-COMPENSATION-REQUIRED`
- `V0170-005-NO-AUTOMATIC-ORDER-RETRY`
- `V0170-005-REDACTED-RECOVERY-EVIDENCE`
- `V0170-005-NO-PRODUCTION-CUTOVER`

## Contract

- `ReleaseV0170CancelStatusReconciliationRecoveryPath` 必须只生成本地 recovery report。
- `ReleaseV0170CancelStatusReconciliationRecoveryReport` 必须绑定 issue `GH-1143`、release `v0.17.0` 和 mode `cancelStatusReconciliationRecovery`。
- `blockedByIssueIDs` 必须为 `GH-1141` 与 `GH-1142`。
- cancel/status mismatch 必须生成 `cancelStatusMismatch` recovery case。
- interrupted status evidence 必须生成 `interruptedStatusEvidence` recovery case。
- 每个 recovery case 必须要求 `runStatusQueryCompensation`、`reconcileObservedStatus`、`requireOperatorReview` 和 `closeFailedNoRetry`。
- 每个 recovery case 必须 `failClosed=true`，并且 `automaticOrderRetryBlocked=true`、`noResubmitOnResume=true`。
- report 只能引用 redacted local evidence ID，不得保存 raw API key、secret、raw order identity、broker payload 或 production endpoint marker。

## Boundary

GH-1143 不授权 production cutover。

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`

任何 cancel/status mismatch、unknown/interrupted status 或 signed status query failure 都只能产生本地 fail-closed recovery evidence，不能自动重试订单，也不能打开 production 或 broker endpoint。

## Required Validation

- `swift test --filter TargetGraphTests/testGH1143ReleaseV0170CancelStatusReconciliationRecoveryPath`
- `bash checks/verify-v0.17.0-cancel-status-reconciliation-recovery-path.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
