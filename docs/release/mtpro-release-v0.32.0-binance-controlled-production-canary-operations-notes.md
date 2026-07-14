# MTPRO v0.32.0 Binance Controlled Production Canary Operations

Date: 2026-07-15
Executor: Codex

v0.32.0 adds a controlled production canary operations evidence layer for Binance Spot and Binance USD-M Futures after v0.31.1 integrity repair. It is not production cutover and does not enable default or unrestricted trading.

## Closed Scope

- GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT
- GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE
- GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE
- GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL
- GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
- GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK
- GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP
- GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS
- GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE
- GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS
- TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS
- V0320-001-CANARY-OPERATIONS-CONTRACT
- V0320-002-HUMAN-APPROVED-ENABLEMENT-BUNDLE
- V0320-003-STRICT-SIZE-CAP-FINAL-GATE
- V0320-004-SPOT-CANARY-SUBMIT-STATUS-CANCEL
- V0320-005-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
- V0320-006-OMS-RECONCILIATION-ROLLBACK
- V0320-007-KILL-NOTRADE-INCIDENT-STOP
- V0320-008-DASHBOARD-CLI-CANARY-STATUS
- V0320-009-AGGREGATE-VALIDATION-SUITE
- V0320-010-STAGE-AUDIT-RELEASE-DOCS

## Release Notes

The release records canary operations as explicit, human-approved, size-capped, risk-gated evidence. It covers Spot and USD-M Futures submit / status / cancel proof surfaces, append-only OMS evidence, reconciliation replay, rollback artifact readiness, incident stop evidence, and read-only Dashboard / CLI status.

Production trading remains disabled by default. Automatic secret read, automatic broker connection, unrestricted trading, OKX runtime, Dashboard trading controls, order forms, live commands, and production cutover remain unavailable.
