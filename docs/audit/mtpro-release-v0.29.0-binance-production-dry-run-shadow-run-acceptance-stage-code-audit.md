# MTPRO Release v0.29.0 Binance Production Dry-run / Shadow Run Acceptance Stage Code Audit

Date: 2026-07-10
Executor: Codex

## Scope

Release v0.29.0 closes #1447-#1456 as a Binance-only production dry-run / shadow run acceptance stage. It proves that Spot and USD-M Futures production acceptance evidence can be collected, validated and displayed without enabling production trading.

## Anchor Inventory

`GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT`, `TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE`, `V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE`, `V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT`, `V0290-001-NO-DEFAULT-TRADING`, `V0290-001-NO-SUBMIT`, `GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL`, `V0290-002-PRODUCTION-SHADOW-CONFIGURATION`, `V0290-002-NO-SECRET-CONFIGURATION`, `V0290-002-MISMATCH-FAILS-CLOSED`, `GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION`, `V0290-003-CREDENTIAL-REFERENCE-ONLY`, `V0290-003-OPERATOR-APPROVAL-REQUIRED`, `V0290-003-SECRET-VALUE-NOT-PERSISTED`, `GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT`, `V0290-004-ENDPOINT-ALLOWLIST-READONLY`, `V0290-004-MUTATION-ENDPOINTS-BLOCKED`, `GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES`, `V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES`, `V0290-005-STALE-MISSING-INPUTS-BLOCKED`, `GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE`, `V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE`, `V0290-006-NO-BROKER-FILL-INTERPRETATION`, `GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL`, `V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL`, `V0290-007-NO-BROKER-SIDE-EFFECT`, `GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE`, `V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE`, `V0290-008-NO-TRADING-CONTROLS`, `GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION`, `V0290-009-AGGREGATE-VALIDATION`, `V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX`, `GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS`, `V0290-010-STAGE-AUDIT-RELEASE-DOCS`, `V0290-010-NO-PRODUCTION-CUTOVER`.

## Evidence

- `ReleaseV0290ProductionDryRunShadowAcceptance` records deterministic Spot and USD-M Futures evidence for contract, configuration, credential, endpoint, risk, OMS/reconciliation, incident rollback, Dashboard/CLI and aggregate validation.
- `ReleaseV0290DashboardCLIShadowAcceptanceSurface` exposes read-only status lines only.
- `checks/verify-v0.29.0.sh` runs `TargetGraphTests/testGH1447To1456ReleaseV0290ProductionDryRunShadowAcceptance`.
- Linux checks and macOS Dashboard smoke are pre-publication requirements.

## Boundary

`productionTradingEnabledByDefault=false`, `productionCutoverAuthorized=false`, `productionSecretAutoReadEnabled=false`, `automaticBrokerConnectionEnabled=false`, `productionSubmitCancelReplaceEnabled=false`, `futuresProductionExecutionEnabled=false`, `leverageMarginPositionMutationEnabled=false`, `okxActiveRuntimeEnabled=false`, `dashboardTradingControlsEnabled=false`, `orderFormEnabled=false`, `liveCommandEnabled=false`, `noSubmitTransportMode=true`, `shadowOnly=true`, `evidenceComplete=true`, `boundaryHeld=true`.

## Conclusion

v0.29.0 is acceptable as a production dry-run / shadow acceptance release. It is not a production cutover, does not read production secrets, does not connect to broker endpoints, and does not submit, cancel or replace real orders.

## Publication Fact Addendum

`TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR` records the post-publication fact sync: v0.29.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0, published at `2026-07-10T14:23:30Z`, and points to `2b070ea979adfec5fccf90fcd823512d99ec4c3c` after PR #1458 and workflow run `29099609391` completed successfully. The v0.29.0 evidence remains `evidenceOrigin=deterministic-fixture`, `acceptanceDecision=blocked`, and `observedRunAccepted=false`; observed-run acceptance must be validated by the v0.29.1 artifact integrity gate.
