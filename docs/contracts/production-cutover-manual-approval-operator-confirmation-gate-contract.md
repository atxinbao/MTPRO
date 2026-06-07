# Production Cutover Manual Approval / Operator Confirmation Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-506 Define manual approval and operator confirmation gate`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 manual approval and operator confirmation gate。它只表达 production cutover 前必须人工确认的 evidence、checklist 和 blocked boundary，不实现生产审批系统，不暴露 live command UI，不新增 trading button / order form，不连接 broker，不读取真实 secret，不提交 / 撤销 / 替换真实订单，也不实现 production OMS。

## GH-506-MANUAL-APPROVAL-OPERATOR-CONFIRMATION-GATE

`GH-506-MANUAL-APPROVAL-OPERATOR-CONFIRMATION-GATE`

GH-506 依赖：

- GH-503 credential / secret policy gate
- GH-504 production environment isolation gate
- GH-505 broker / venue capability matrix

当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverManualApprovalGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH506ManualApprovalGateBindsUpstreamCutoverReadinessEvidence`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH506ManualApprovalGateRejectsConfigEnvUIAndSandboxBypass`

## GH-506-OPERATOR-CONFIRMATION-CHECKLIST

`GH-506-OPERATOR-CONFIRMATION-CHECKLIST`

Operator confirmation checklist 必须覆盖：

- credential / secret policy
- environment isolation
- broker / venue capability matrix
- operator identity
- operator confirmation checklist
- production command blocked
- future dedicated cutover issue

每一项 checklist row 都必须说明 expected evidence 和 blocked reason，并且必须保持 `requiresManualApproval = true`、`approvalGranted = false`。

## GH-506-BINDS-GH503-GH504-GH505

`GH-506-BINDS-GH503-GH504-GH505`

Manual approval gate 不能单独授权 production cutover；它必须绑定：

- GH-503 no-default-secret-read / credential policy evidence
- GH-504 no-default-production-trading / environment isolation evidence
- GH-505 broker / venue capability matrix evidence

## GH-506-PRODUCTION-COMMAND-BLOCKED-UNTIL-FUTURE-CUTOVER

`GH-506-PRODUCTION-COMMAND-BLOCKED-UNTIL-FUTURE-CUTOVER`

GH-506 不授权 production command。Production command 必须保持 blocked，直到 future dedicated cutover issue 明确授权并提供新的 gate evidence。

## GH-506-NO-APPROVAL-BYPASS

`GH-506-NO-APPROVAL-BYPASS`

GH-506 必须拒绝：

- config default approval
- environment variable approval
- UI approval bypass
- script approval bypass
- sandbox command promotes production command
- production command without approval
- live command surface
- trading button
- order form
- broker connection
- secret read
- production approval system
- production OMS
- real submit / cancel / replace

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
