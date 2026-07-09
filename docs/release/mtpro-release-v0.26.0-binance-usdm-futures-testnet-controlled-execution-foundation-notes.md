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

## Historical Construction Boundary and Current Publication Fact

The construction closeout did not create a tag or GitHub Release. That statement is historical construction evidence only.

Current release fact: v0.26.0 is published as a stable GitHub Release at https://github.com/atxinbao/MTPRO/releases/tag/v0.26.0. The tag resolves to `e3b65f2337c5275eaa7ce5c5f224b69475a7c9bb`, and GitHub records the release publication timestamp as `2026-07-08T13:00:01Z`.

The publication does not authorize production cutover, production Futures order execution, OKX active runtime, Dashboard trading controls, unrestricted live trading, production secret read, production endpoint connection, broker endpoint connection, or production order submission.

## v0.26.1 Publication Fact Sync Anchors

- GH-1406-VERIFY-V0261-V0260-RELEASE-FACT-SYNC
- TVM-RELEASE-V0261-V0260-RELEASE-FACT-SYNC
- V0261-001-V0260-GITHUB-RELEASE-PUBLISHED
- V0261-001-V0260-TAG-FIXED
- V0261-001-V0260-PUBLISHED-AT-2026-07-08T13-00-01Z
- GH-1407-VERIFY-V0261-V0260-MILESTONE-COMPLETION
- V0261-002-V0260-MILESTONE-CLOSED
- V0261-002-V0260-ISSUES-1394-1403-DONE
- GH-1408-VERIFY-V0261-V0260-STALE-WORDING-GUARD
- V0261-003-PUBLISHED-V0260-STALE-WORDING-GUARD
- GH-1409-VERIFY-V0261-V0260-BASELINE-WORDING
- V0261-004-V0260-CURRENT-PUBLISHED-BASELINE
- V0261-004-FUTURES-TESTNET-CONTROLLED-EXECUTION-FOUNDATION
- GH-1410-VERIFY-V0261-PATCH-AUDIT-RELEASE-NOTES
- V0261-005-PATCH-AUDIT
- V0261-005-V0270-BLOCKED-BY-V0261-COMPLETION
- V0261-005-NO-CAPABILITY-CHANGE
