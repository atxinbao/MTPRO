# Release v0.17.0 Dashboard Artifact Validation Error Surface Contract

日期：2026-06-27

执行者：Codex

## #1144 / GH-1144

GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE

TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE

V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE

V0170-006-FAILURE-REASONS-VISIBLE

V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE

V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS

V0170-006-NO-PRODUCTION-CUTOVER

## Goal

GH-1144 在 Dashboard 中增加只读 Dashboard artifact validation error surface，用于展示 GH-1140 artifact bundle replay validator 和 GH-1143 cancel/status reconciliation recovery path 输出的 validation status、failure reasons 和 recovery case summary。

## Scope

- 展示本地 redacted artifact validation result 的 pass/fail status。
- 展示本地 recovery report 的 failure reason 和 operator review summary。
- 将 surface 接入 `DashboardShellSnapshot` 的 read-model-only smoke summary。
- 为 Dashboard read-model、TargetGraph guard、automation readiness 和 `checks/run.sh` 增加同一组 validation anchors。

## Non-goals

- 不新增 command handler。
- 不新增 trading button。
- 不新增 order form。
- 不新增 live command。
- 不实现 submit / cancel / replace。
- 不读取 credential value。
- 不连接 testnet / production endpoint。
- 不连接 broker endpoint。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。

## Dashboard artifact validation error surface

`ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel` 只接受本地 read-model artifact：

- schema 必须是 `release-v0.17.0-dashboard-artifact-validation-error-surface-read-model`。
- artifact path 必须位于 `.local/mtpro/v0.17.0/operator-runs/` 下。
- checksum 必须是 `sha256:` 引用。
- 内嵌 surface 必须 `boundaryHeld == true`。
- `artifactValidationStatusVisible == true`。
- `failureReasonsVisible == true`。
- `recoveryCaseSummaryVisible == true`。
- `dashboardCommandSurfaceEnabled == false`。
- `submitCancelReplaceEnabled == false`。
- `productionTradingEnabledByDefault == false`。
- `productionCutoverAuthorized == false`。

## Validation

- `swift test --filter AppTests/testGH1144DashboardArtifactValidationErrorSurfaceShowsFailuresWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1144DashboardArtifactValidationErrorSurfaceIsAnchoredInV0170Guards`
- `bash checks/verify-v0.17.0-dashboard-artifact-validation-error-surface.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-1144 只展示 artifact validation status、failure reasons 和 recovery case summary。Dashboard surface 不依赖 ExecutionClient target，不读取 credential value，不连接 endpoint，不发送 testnet 或 production order，不创建 tag / GitHub Release，不授权 production cutover。
