# Release v0.17.0 Manual Workflow Artifact Validation Contract

日期：2026-06-27

执行者：Codex

## Scope

#1146 / GH-1146 adds manual workflow artifact upload/download validation for v0.17.0. The workflow validates both uploaded and downloaded local artifact bundle storage roots through the same `mtpro verify-operator-beta-artifact-bundle` CLI path and the shared GH-1140 artifact bundle replay validator.

## Required Anchors

- GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
- TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
- V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION
- V0170-008-SHARED-RUNTIME-VALIDATOR-PATH
- V0170-008-UPLOADED-BUNDLE-VALIDATED
- V0170-008-DOWNLOADED-BUNDLE-VALIDATED
- V0170-008-LOCAL-ONLY-NO-NETWORK
- V0170-008-REDACTED-EVIDENCE-RECORDED
- V0170-008-NO-PRODUCTION-CUTOVER

## Contract

- `ReleaseV0170ManualWorkflowArtifactValidationReport` records uploaded and downloaded artifact validation evidence.
- Both paths must call `ReleaseV0170CLIArtifactVerifyCommand.commandOutput`, which delegates to `ReleaseV0170OperatorBetaArtifactBundleReplayValidator`.
- The uploaded and downloaded artifact validations must share the same operator run ID.
- A mismatched, corrupted or missing downloaded bundle fails closed as local validation evidence.
- The workflow is local artifact validation only; it does not read credential values, connect endpoints or submit/cancel/replace orders.

## Validation

- `swift test --filter TargetGraphTests/testGH1146ReleaseV0170ManualWorkflowArtifactValidation`
- `bash checks/verify-v0.17.0-manual-workflow-artifact-validation.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-1146 不读取 credential value，不读取 production secret，不连接 testnet / production endpoint，不连接 broker endpoint，不发送 testnet 或 production order，不创建 tag / GitHub Release，不推进下一 milestone，不授权 production cutover。
