# MTPRO Release v0.27.0 Binance USD-M Futures Testnet Operator Runtime Hardening Notes

Date: 2026-07-09
Executor: Codex

## Release Scope

`MTPRO Release v0.27.0 Binance USD-M Futures testnet operator runtime hardening` strengthens the operator evidence chain after the Futures testnet controlled execution foundation.

This release records and validates:

- run registry and artifact manifest evidence
- run identity under `binance/usdsPerpetual/testnet/v0.27.0`
- signed status retry / timeout classification
- cancel / status / reconciliation recovery
- artifact bundle replay validation
- idempotency, duplicate submit rejection, and run lock evidence
- manual workflow artifact validation and redaction evidence
- read-only Dashboard / CLI failure drilldown

## Required Anchors

- GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
- TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING
- V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT
- V0270-001-FAIL-CLOSED-SEMANTICS
- GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST
- V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST
- V0270-002-RUN-IDENTITY-EVIDENCE
- GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
- V0270-003-SIGNED-STATUS-RETRY-TIMEOUT
- V0270-003-CLASSIFIED-FAILURE-EVIDENCE
- GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY
- V0270-004-CANCEL-STATUS-RECOVERY
- V0270-004-RECONCILIATION-RECOVERY
- GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
- V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
- V0270-005-CHECKSUM-FAIL-CLOSED
- GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK
- V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD
- V0270-006-RUN-LOCK-HARDENING
- GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY
- V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN
- V0270-007-NO-DASHBOARD-TRADING-CONTROLS
- GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION
- V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
- V0270-008-REDACTION-EVIDENCE
- GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION
- V0270-009-AGGREGATE-VALIDATION-SUITE
- GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS
- V0270-010-STAGE-CODE-AUDIT
- V0270-010-RELEASE-NOTES
- V0270-010-NO-PRODUCTION-CUTOVER

## Explicit Non-goals

- productionFuturesOrderExecutionEnabled=false
- productionTradingEnabledByDefault=false
- production cutover not authorized
- no production secret read
- no production endpoint or broker endpoint connection
- no production order submission
- no OKX active runtime
- no Dashboard trading controls, trading button, order form, or live command
- no unrestricted live trading authorization

## Validation

The release queue requires:

- `swift test --filter TargetGraphTests/testGH1411To1420ReleaseV0270FuturesTestnetOperatorRuntimeHardening`
- `bash checks/verify-v0.27.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Publication Facts And Patch Follow-up

These notes were first written for the v0.27.0 construction closeout. Current publication facts are now fixed:

- v0.27.0 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.27.0
- v0.27.0 tag fixed at: `4ee83ecece5c434cbc97999ae30ee680c1072020`
- v0.27.0 published at: `2026-07-09T14:06:49Z`
- v0.27.1 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.27.1
- v0.27.1 tag fixed at: `a69eed3b1a83028de14ce64ce42d1e2578eaab96`
- v0.27.1 published at: `2026-07-09T15:19:56Z`
- v0.27.1 title: `MTPRO v0.27.1 v0.27 Dashboard macOS Type-check Patch`
- v0.27.0 milestone #45: closed with 0 open / 10 closed issues
- v0.27.0 issues #1411 through #1420: closed / done
- Binance Spot + Binance USD-M Futures remain the continuation scope
- OKX out of current target path
- production cutover not authorized

v0.27.2 records the publication fact sync / milestone closure patch:

- GH-1424-VERIFY-V0272-V0271-RELEASE-FACT-SYNC
- TVM-RELEASE-V0272-V0271-RELEASE-FACT-SYNC
- V0272-001-V0271-GITHUB-RELEASE-PUBLISHED
- V0272-001-V0271-TAG-FIXED
- V0272-001-V0271-PUBLISHED-AT-2026-07-09T15-19-56Z
- GH-1425-VERIFY-V0272-V0270-MILESTONE-COMPLETION
- V0272-002-V0270-MILESTONE-CLOSED
- V0272-002-V0270-ISSUES-1411-1420-DONE
- GH-1426-VERIFY-V0272-V0271-STALE-WORDING-GUARD
- V0272-003-PUBLISHED-V0271-STALE-WORDING-GUARD
- GH-1427-VERIFY-V0272-BINANCE-ONLY-CONTINUATION-SCOPE
- V0272-004-BINANCE-SPOT-USDM-FUTURES-CONTINUATION
- V0272-004-OKX-OUT-OF-CURRENT-TARGET-PATH
- GH-1428-VERIFY-V0272-PATCH-AUDIT-RELEASE-NOTES
- V0272-005-PATCH-AUDIT
- V0272-005-V0280-BLOCKED-BY-V0272-COMPLETION
- V0272-005-NO-CAPABILITY-CHANGE
