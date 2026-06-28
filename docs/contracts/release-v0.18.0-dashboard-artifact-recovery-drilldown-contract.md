# Release v0.18.0 Dashboard Artifact Recovery Drilldown Contract

日期：2026-06-28

执行者：Codex

## Scope

`GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN`

`TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN`

`V0180-007-DEPENDENCIES-GH1179-GH1180-GH1181-DONE`

`V0180-007-REAL-LOCAL-BUNDLE-EVIDENCE`

`V0180-007-LIFECYCLE-STATUS-RESUME-RECONCILIATION-DRILLDOWN`

`V0180-007-VENUE-PRODUCT-ENVIRONMENT-DRILLDOWN`

`V0180-007-FAILURE-CLASS-NEXT-ACTION-GUIDANCE`

`V0180-007-DASHBOARD-READ-ONLY-NO-COMMANDS`

`V0180-007-NO-PRODUCTION-CUTOVER`

GH-1182 在 GH-1179 resume-after-interruption command、GH-1180 cancel/status reconciliation replay command 和 GH-1181 operator failure classification next-action CLI 之后，新增 Dashboard artifact / recovery drilldown read model。

## Dependency Evidence

- #1179 closed / done。
- #1180 closed / done。
- #1181 closed / done。
- #1182 只消费本地 artifact bundle evidence，不读取 live endpoint，不重新执行 status query，不执行 broker state mutation。

## Contract

`ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel` 必须展示同一 `{venue, product, environment, accountProfile, runID}` namespace 下的本地 bundle evidence：

- lifecycle manifest。
- status-query retry artifact。
- resume-after-interruption result。
- cancel/status reconciliation replay artifact。
- failure classification next-action artifact。

每条 drilldown row 必须包含：

- stage。
- source artifact path。
- failure class。
- next action。
- explanation。
- read-only / no-command boundary flags。

Dashboard 必须展示 venue、product、environment、accountProfile 和 runID，使 operator 能从真实本地 bundle 追溯到 run lifecycle、status query、resume 和 reconciliation state。Dashboard 不允许显示 synthetic happy-path placeholder。

## Dashboard Boundary

Dashboard artifact / recovery drilldown 只能作为只读证据面：

- 不依赖 `ExecutionClient` target。
- 不绑定 command handler。
- 不显示 trading button。
- 不显示 order form。
- 不显示 live command。
- 不启用 submit / cancel / replace。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不授权 production cutover。
- production cutover not authorized。

## Validation

- `swift test --filter AppTests/testGH1182DashboardArtifactRecoveryDrilldownShowsRealBundleEvidenceWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1182DashboardArtifactRecoveryDrilldownIsAnchoredInV0180Guards`
- `bash checks/verify-v0.18.0-dashboard-artifact-recovery-drilldown.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
