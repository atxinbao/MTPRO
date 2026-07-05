# Release v0.22.0 Failure Rollback Drill Contract

Date: 2026-07-05  
Executor: Codex

## Scope

GH-1317 adds the Binance Spot live canary failure classification and rollback drill contract.
It consumes GH-1315 OMS evidence log and GH-1316 reconciliation evidence, then proves every
operator-visible failure class has a deterministic next action.

Anchors:

- GH-1317-VERIFY-V0220-FAILURE-ROLLBACK-DRILL
- TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL
- V0220-009-BLOCKED-BY-GH1315-GH1316
- V0220-009-FAILURE-CLASSIFICATION
- V0220-009-AUTH-ENDPOINT-RISK-KILL-NOTRADE-SUBMIT-CANCEL-STATUS-RECONCILIATION-ARTIFACT
- V0220-009-DETERMINISTIC-NEXT-ACTION
- V0220-009-KILL-SWITCH-BLOCKS-SUBMIT-CANCEL
- V0220-009-NO-TRADE-BLOCKS-SUBMIT-CANCEL
- V0220-009-ROLLBACK-DRILL-EVIDENCE
- V0220-009-NO-UNINTENDED-ORDERS
- V0220-009-NO-FUTURES-OKX
- V0220-009-NO-DASHBOARD-TRADING-CONTROLS
- V0220-009-NO-PRODUCTION-CUTOVER

## Failure Classification

The required failure classes are:

- auth
- endpoint
- risk
- kill-switch
- no-trade
- submit
- cancel
- status
- reconciliation
- artifact

Each class must:

- fail closed;
- block submit and cancel;
- provide one deterministic operator next action;
- require redacted evidence;
- avoid Futures, OKX, Dashboard trading command, and production cutover enablement.

## Rollback Drill

The rollback drill covers submit and cancel command vocabulary only. It must prove:

- kill switch is active;
- no-trade is active;
- the command is blocked before transport;
- the command is blocked before broker gateway;
- rollback evidence is recorded;
- no unintended submit or cancel order is sent.

## Non-goals

- No broad production cutover.
- No Futures capability.
- No OKX capability.
- No Dashboard trading button.
- No order form.
- No raw broker payload persistence.
- No production endpoint or broker endpoint connection.

## Validation

Required local validation:

- `swift test --filter TargetGraphTests/testGH1317ReleaseV0220FailureClassificationRollbackKillSwitchNoTradeDrill`
- `bash checks/verify-v0.22.0-failure-rollback-drill.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/run.sh`
