# Release v0.18.0 Cancel / Status Reconciliation Replay Command Contract

本合同覆盖 #1180 / GH-1180：`V180-005 Add cancel/status reconciliation replay command`。

## Dependencies

- #1178 closed / done：`ReleaseV0180StatusQueryRetryArtifactPersistence` 已把 signed status-query retry / timeout / failure classification result 持久化到本地 append-only artifact store。
- #1179 closed / done：`ReleaseV0180ResumeAfterInterruptionCommand` 已基于 lifecycle manifest、status-query retry snapshot 和 reconciliation cursor 生成本地 resume evidence。

## Anchors

- `GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND`
- `TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND`
- `V0180-005-DEPENDENCIES-GH1178-GH1179-DONE`
- `V0180-005-LOCAL-ARTIFACT-REPLAY`
- `V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED`
- `V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED`
- `V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED`
- `V0180-005-READ-ONLY-OPERATOR-ACTION`
- `V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED`
- `V0180-005-NO-PRODUCTION-CUTOVER`

## Command Contract

`ReleaseV0180CancelStatusReconciliationReplayCommand` 定义本地 operator command：

`mtpro operator-run replay-cancel-status-reconciliation --run-id <runID> --venue <venue> --product <product> --environment <environment> --account-profile <accountProfile>`

该 command 只消费调用方已经从本地 artifact store replay / validate 的 evidence object：

- GH-1178 `ReleaseV0180StatusQueryRetryArtifactPersistence`。
- GH-1179 `ReleaseV0180ResumeAfterInterruptionResult`。
- GH-1107 `ReleaseV0160OMSObservedStatusReconciliationReport`。
- GH-1143 `ReleaseV0170CancelStatusReconciliationRecoveryReport`。

## Replay Rules

- `{venue, product, environment, accountProfile, runID}` 必须在 status persistence、resume result、observed reconciliation report 和 recovery report 中一致。
- `expectedLifecycleState` 必须来自 GH-1107 expected state。
- `observedLifecycleState` 必须来自 GH-1107 observed status。
- passed result 要求 GH-1107 reconciliation status 为 `passed`，GH-1143 recovery status 为 `passed`，且 recovery case count 为 `0`。
- 缺少 observed reconciliation report 或 recovery report 必须返回 failed result。
- observed / expected mismatch 或 recovery cases 非空必须返回 failed result。

## Boundary

GH-1180 是本地 artifact replay / read-only operator action，不是 runtime continuation。

禁止：

- 自动 network retry。
- broker mutation。
- endpoint connection。
- production secret read。
- production trading。
- order submit / cancel / replace。
- production cutover。
- tag / GitHub Release publication。

## Validation

- `swift test --filter TargetGraphTests/testGH1180CancelStatusReconciliationReplayCommandUsesLocalArtifacts`
- `bash checks/verify-v0.18.0-cancel-status-reconciliation-replay-command.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
