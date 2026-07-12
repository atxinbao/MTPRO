# MTPRO v0.31.0 Controlled Production Enablement Gate

Date: 2026-07-12
Executor: Codex

## Anchor Inventory

`GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT`, `GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE`, `GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST`, `GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES`, `GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK`, `GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES`, `GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION`, `GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE`, `GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE`, `GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE`, `V0310-001-NO-DEFAULT-TRADING-CONTRACT`, `V0310-002-CREDENTIAL-APPROVAL-GATE`, `V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST`, `V0310-004-CAPITAL-RISK-STALE-INPUT-GATES`, `V0310-005-MANUAL-APPROVAL-RUN-LOCK`, `V0310-006-KILL-NOTRADE-ROLLBACK-GATES`, `V0310-007-SIGNED-READONLY-NO-MUTATION`, `V0310-008-IMMUTABLE-AUDIT-BUNDLE`, `V0310-009-READONLY-STATUS-SURFACE`, `V0310-010-STAGE-AUDIT-RELEASE-DOCS`.

## Summary

v0.31.0 adds the controlled production enablement gate for Binance Spot and Binance USD-M Futures readiness. The gate is intentionally blocked until all credential approval, signed read-only endpoint, capital/risk, manual run lock, kill/no-trade/rollback, signed preflight and immutable audit bundle evidence is present.

Required release facts:

- `decision=blocked`
- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `automaticSecretReadEnabled=false`
- `automaticBrokerConnectionEnabled=false`
- `productionSubmitCancelReplaceEnabled=false`

## Boundary

This release does not open production cutover, does not create order mutation capability, does not auto-read secrets, does not auto-connect broker endpoints, does not submit / cancel / replace orders, and does not expose Dashboard trading buttons, order forms or live commands. The only new operator surface is read-only: `mtpro controlled-production-enablement status|gates|preflight|audit|boundaries`.

## Validation

- `swift test --filter TargetGraphTests/testGH1487To1496ReleaseV0310ControlledProductionEnablementGate`
- `bash checks/verify-v0.31.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
