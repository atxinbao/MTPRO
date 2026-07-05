# Release v0.22.0 Reconciliation Evidence Contract

Date: 2026-07-05
Executor: Codex

## Scope

GH-1316 defines the v0.22.0 Binance Spot live canary reconciliation evidence layer.

Anchors:

- `GH-1316-VERIFY-V0220-RECONCILIATION-EVIDENCE`
- `TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE`
- `V0220-008-BLOCKED-BY-GH1312-GH1315`
- `V0220-008-OMS-EXCHANGE-STATUS-ACCOUNT-RECONCILIATION`
- `V0220-008-MATCHED-PENDING-AMBIGUOUS-REJECTED-CANCELLED-FILL-LIKE`
- `V0220-008-REDACTED-RECONCILIATION-ARTIFACT`
- `V0220-008-MISSING-EXCHANGE-EVIDENCE-FAILS-CLOSED`
- `V0220-008-AMBIGUOUS-STATE-FAILS-CLOSED`
- `V0220-008-NEXT-OPERATOR-ACTION`
- `V0220-008-NO-FUTURES-OKX`
- `V0220-008-NO-DASHBOARD-TRADING-CONTROLS`
- `V0220-008-NO-PRODUCTION-CUTOVER`

## Contract

GH-1316 consumes:

- GH-1312 signed account read-only runtime preflight evidence.
- GH-1315 append-only OMS event log evidence.
- Redacted exchange order status evidence from the approved Binance Spot canary order.

It emits a redacted reconciliation artifact that classifies the canary order as matched / pending / ambiguous / rejected / cancelled / fill-like:

- matched
- pending
- ambiguous
- rejected
- cancelled
- fill-like

Each artifact must include a next operator action. Missing exchange evidence, missing OMS log evidence, ambiguous exchange state, or any local-only reconciliation assumption must fail closed.

## Boundaries

GH-1316 does not enable Futures, OKX, Dashboard trading controls, tag/release publication, production cutover, broad production OMS rollout, production secret auto-read, or unrestricted production trading.

The reconciliation artifact is evidence only. It cannot be used as an order command, cancel command, replace command, production cutover approval, or Dashboard trading action.

## Validation

Required commands:

- `swift test --filter TargetGraphTests/testGH1316ReleaseV0220ReconcilesOMSWithSignedAccountAndOrderStatusEvidence`
- `bash checks/verify-v0.22.0-reconciliation-evidence.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/run.sh`
