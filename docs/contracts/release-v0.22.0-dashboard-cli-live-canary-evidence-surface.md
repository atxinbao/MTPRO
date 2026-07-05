# Release v0.22.0 Dashboard / CLI Live Canary Evidence Surface Contract

Date: 2026-07-06  
Author: Codex

## Anchors

- GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
- TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
- V0220-010-BLOCKED-BY-GH1317
- V0220-010-LIVE-CANARY-EVIDENCE-CHAIN
- V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION
- V0220-010-FAILURE-CLASS-NEXT-ACTION
- V0220-010-READ-ONLY-DASHBOARD-CLI
- V0220-010-REDACTION-FAILURE-STATES-VISIBLE
- V0220-010-NO-TRADING-COMMANDS
- V0220-010-NO-FUTURES-OKX
- V0220-010-NO-PRODUCTION-CUTOVER

## Goal

GH-1318 exposes the Binance Spot live canary evidence chain through read-only Dashboard and CLI surfaces after GH-1317 failure taxonomy and rollback drill evidence.

The surface must show:

- operator approval and one-run lock evidence
- signed account preflight evidence
- single live canary submit transport evidence
- status / cancel transport evidence
- OMS event log evidence
- reconciliation evidence
- failure class labels and deterministic next actions
- kill switch / no-trade rollback drill state
- redaction boundary state

## Boundary

The surface is inspection-only.

It must not:

- create a trading button
- create an order form
- expose a live command
- execute submit / cancel / replace
- enable Futures
- enable OKX
- display raw order IDs
- display or persist raw broker payloads
- authorize production cutover
- create a tag or GitHub Release

## Evidence Files

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface.swift`
- `Sources/Dashboard/Report/ReleaseV0220DashboardCLILiveCanaryEvidenceSurface.swift`
- `Sources/Dashboard/DashboardShell.swift`
- `Sources/MTPROCLI/main.swift`
- `Package.swift`
- `Tests/AppTests/AppTests.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`

## Validation

Required commands:

- `swift test --filter AppTests/testGH1318DashboardCLILiveCanaryEvidenceSurfaceShowsCanaryEvidenceWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1318ReleaseV0220DashboardCLILiveCanaryEvidenceSurface`
- `bash checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/run.sh`

## Non-goals

GH-1318 does not implement Futures, OKX, production cutover, Dashboard trading controls, order forms, or new broker capabilities.
