# MTPRO Release v0.26.0 Binance USD-M Futures Testnet Controlled Execution Foundation Notes

Date: 2026-07-08  
Executor: Codex

## Anchors

- GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT
- TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION
- V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION
- V0260-001-NO-PRODUCTION-CUTOVER
- GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE
- V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE
- V0260-002-CREDENTIAL-REFERENCE-ONLY
- GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION
- V0260-003-NO-PRODUCTION-CUTOVER
- V0260-003-ORDER-INTENT-VALIDATED
- GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE
- V0260-004-MANUAL-APPROVAL-HARD-CAPS
- V0260-004-IDEMPOTENCY-REDACTION
- GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK
- V0260-005-CANCEL-STATUS-ROLLBACK
- V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY
- GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION
- V0260-006-OMS-EVENT-LOG-RECONCILIATION
- V0260-006-APPEND-ONLY-EVIDENCE
- GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS
- V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD
- V0260-007-REDUCE-ONLY-HARD-CAP
- GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
- TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
- V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS
- V0260-008-NO-DASHBOARD-TRADING-CONTROLS
- GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION
- TVM-RELEASE-V0260-AGGREGATE-VALIDATION
- V0260-009-AGGREGATE-VALIDATION-SUITE
- GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS
- V0260-010-STAGE-CODE-AUDIT
- V0260-010-NO-PRODUCTION-CUTOVER
- V0260-010-NO-TAG-OR-RELEASE-PUBLICATION

## Summary

v0.26.0 is the Binance USD-M Futures testnet controlled execution foundation. It adds controlled testnet evidence for Futures submit/cancel/status/rollback paths, OMS event log evidence, reconciliation evidence, risk/notional/leverage guard evidence and read-only Dashboard / CLI status surfaces.

## Operator Boundary

- `productionFuturesOrderExecutionEnabled=false`
- production cutover not authorized
- testnet submit/cancel/replace evidence is gated by manual approval and hard caps
- credential handling remains reference-only for this foundation evidence
- no production endpoint, production broker endpoint or production secret value is used
- no OKX active runtime is enabled
- no Dashboard trading button, order form or live command is exposed

## Validation

Run:

```bash
bash checks/verify-v0.26.0.sh
bash checks/run.sh
```

## Publication Boundary

The construction closeout does not create a tag or GitHub Release. Publication is a separate release action after the v0.26.0 queue closes.
