# Release v0.21.0 Dashboard / CLI Canary Status Surface

日期：2026-07-02

执行者：Codex

## Anchors

- GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
- TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
- V0210-011-DASHBOARD-CLI-CANARY-STATUS
- V0210-011-CANARY-STATE-GATES
- V0210-011-RISK-ORDER-CANCEL-RECONCILIATION
- V0210-011-READ-ONLY-NO-COMMANDS
- V0210-011-NO-PRODUCTION-CUTOVER

## Goal

GH-1283 adds a Dashboard / CLI read-only status surface for the v0.21.0 Binance Spot canary evidence chain.

The surface consumes GH-1282 redacted OMS event log / reconciliation evidence and displays:

- canary state
- gate stack
- risk decision
- order lifecycle evidence
- cancel / rollback evidence
- reconciliation evidence
- redaction / no-command boundary

## Scope

- Source: `Sources/ExecutionEngine/OMSFutureGate/ReleaseV0210CanaryStatusReadOnlySurface.swift`
- Dashboard ViewModel: `Sources/Dashboard/Report/ReleaseV0210DashboardCLICanaryStatusSurface.swift`
- Dashboard shell binding: `Sources/Dashboard/DashboardShell.swift`
- CLI command: `mtpro canary-status status`
- CLI event inspect: `mtpro canary-status events`
- CLI reconciliation inspect: `mtpro canary-status reconciliation`

## Boundary

GH-1283 is read-only evidence projection only.

It does not:

- show a trading button
- show an order form
- expose a live command
- enable submit / cancel / replace
- show raw order id
- show raw broker payload
- read production secret value
- connect production endpoint
- connect broker endpoint
- create a tag or GitHub Release
- authorize production cutover

## Validation

- `swift test --filter AppTests/testGH1283DashboardCLIReadOnlyCanaryStatusSurfaceShowsCanaryEvidenceWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1283ReleaseV0210DashboardCLIReadOnlyCanaryStatusSurface`
- `bash checks/verify-v0.21.0-dashboard-cli-canary-status-surface.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
