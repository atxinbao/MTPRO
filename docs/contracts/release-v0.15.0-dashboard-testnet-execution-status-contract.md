# Release v0.15.0 Dashboard Testnet Execution Status Contract

日期：2026-06-23

执行者：Codex

## Scope

GH-1074 exposes v0.15.0 Binance Spot Testnet execution status in Dashboard as read-only evidence.

- `GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS`
- `TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS`
- `V0150-009-DASHBOARD-READ-MODEL-ARTIFACT`
- `V0150-009-SUBMIT-CANCEL-CANCEL-REPLACE-STATUS`
- `V0150-009-OMS-RECONCILIATION-FAILURE-REASONS`
- `V0150-009-DASHBOARD-READ-ONLY-NO-COMMANDS`
- `V0150-009-NO-PRODUCTION-CUTOVER`

## Evidence Surface

- `ReleaseV0150DashboardTestnetExecutionStatusInput`
- `ReleaseV0150DashboardTestnetExecutionStatusRow`
- `ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel`
- `ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput`
- `DashboardShellSnapshot.releaseV0150DashboardTestnetExecutionStatusSurface(fromLocalReadModelJSON:)`

The Dashboard consumes only local read-model artifacts and redacted evidence handles from #1071, #1072, and #1073.

Required static boundary:

- `dashboardConsumesReadModelArtifactsOnly=true`
- `submitCancelCancelReplaceStatusVisible=true`
- `omsStateVisible=true`
- `reconciliationStateVisible=true`
- `failureReasonsVisible=true`
- `dashboardCommandSurfaceEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandVisible=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionSubmitCancelReplaceEnabled=false`

## Non-goals

- No production trading.
- No production cutover.
- No production secret read.
- No production endpoint or broker endpoint connection.
- No production submit / cancel / replace.
- No Dashboard trading button.
- No Dashboard command surface.
- No order form.
- No new network action.
- No broker fill runtime.

## Validation

- `swift test --filter AppTests/testGH1074DashboardTestnetExecutionStatusSurfaceShowsReadOnlyStatusWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1074DashboardTestnetExecutionStatusSurfaceIsAnchoredInV0150Guards`
- `bash checks/verify-v0.15.0-dashboard-testnet-execution-status.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
