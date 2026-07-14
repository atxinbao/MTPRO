# MTPRO Release v0.32.0 Binance Controlled Production Canary Operations Stage Code Audit

Date: 2026-07-15
Executor: Codex

## Scope

v0.32.0 closes the controlled production canary operations queue after v0.31.1. It defines human-approved Binance Spot and Binance USD-M Futures canary operations evidence for submit, status, cancel, OMS, reconciliation, rollback, incident stop, and read-only Dashboard / CLI canary status.

## Anchors

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

## Evidence

- Canary operations are Binance-only and product-limited to Spot and USD-M Futures.
- Each operation requires human approval, v0.31.1 closeout, strict size caps, risk pass, kill switch clear, no-trade clear, and redacted artifact evidence.
- Spot and Futures canary evidence includes submit, status, and cancel surfaces.
- OMS evidence is append-only and reconciliation replayable.
- Incident stop evidence proves kill switch and no-trade states block submit and cancel.
- Dashboard / CLI canary status is read-only and cannot bypass approval, risk, kill switch, or no-trade.

## Boundary

- defaultProductionTradingEnabled=false
- unrestrictedTradingEnabled=false
- automaticSecretReadEnabled=false
- automaticBrokerConnectionEnabled=false
- productionCutoverAuthorized=false
- okxRuntimeEnabled=false
- dashboardTradingButtonEnabled=false
- orderFormEnabled=false
- liveCommandEnabled=false
