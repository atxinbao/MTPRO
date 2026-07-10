# MTPRO Release v0.29.0 Binance Production Dry-run / Shadow Run Acceptance Notes

Date: 2026-07-10
Executor: Codex

## Release Intent

v0.29.0 accepts Binance Spot and Binance USD-M Futures production dry-run / shadow run evidence. v0.29.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0; the tag points to `2b070ea979adfec5fccf90fcd823512d99ec4c3c`, was published at `2026-07-10T14:23:30Z`, and PR #1458 plus GitHub Actions run `29099609391` completed successfully. The acceptance evidence remains `evidenceOrigin=deterministic-fixture` with `acceptanceDecision=blocked`; it is not observed-run acceptance.

## v0.29.1 Publication Fact Sync

`TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR` records that v0.29.0 publication is complete while preserving v0.29.0 as contract + deterministic fixture evidence. Deterministic fixture evidence is classified as `evidenceOrigin=deterministic-fixture`, `acceptanceDecision=blocked`, `observedRunAccepted=false`. Observed-run acceptance requires a validated artifact manifest with file existence, regular file proof, safe relative path, byte count, SHA-256, run ID, source commit, operator approval, actor, freshness, provenance, redaction and immutable manifest checks.

## Anchor Inventory

`GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT`, `TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE`, `V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE`, `V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT`, `V0290-001-NO-DEFAULT-TRADING`, `V0290-001-NO-SUBMIT`, `GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL`, `V0290-002-PRODUCTION-SHADOW-CONFIGURATION`, `V0290-002-NO-SECRET-CONFIGURATION`, `V0290-002-MISMATCH-FAILS-CLOSED`, `GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION`, `V0290-003-CREDENTIAL-REFERENCE-ONLY`, `V0290-003-OPERATOR-APPROVAL-REQUIRED`, `V0290-003-SECRET-VALUE-NOT-PERSISTED`, `GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT`, `V0290-004-ENDPOINT-ALLOWLIST-READONLY`, `V0290-004-MUTATION-ENDPOINTS-BLOCKED`, `GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES`, `V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES`, `V0290-005-STALE-MISSING-INPUTS-BLOCKED`, `GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE`, `V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE`, `V0290-006-NO-BROKER-FILL-INTERPRETATION`, `GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL`, `V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL`, `V0290-007-NO-BROKER-SIDE-EFFECT`, `GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE`, `V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE`, `V0290-008-NO-TRADING-CONTROLS`, `GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION`, `V0290-009-AGGREGATE-VALIDATION`, `V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX`, `GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS`, `V0290-010-STAGE-AUDIT-RELEASE-DOCS`, `V0290-010-NO-PRODUCTION-CUTOVER`.

## Boundary

`productionTradingEnabledByDefault=false`, `productionCutoverAuthorized=false`, `productionSecretAutoReadEnabled=false`, `automaticBrokerConnectionEnabled=false`, `productionSubmitCancelReplaceEnabled=false`, `futuresProductionExecutionEnabled=false`, `leverageMarginPositionMutationEnabled=false`, `okxActiveRuntimeEnabled=false`, `dashboardTradingControlsEnabled=false`, `orderFormEnabled=false`, `liveCommandEnabled=false`, `noSubmitTransportMode=true`, `shadowOnly=true`, `evidenceComplete=true`, `boundaryHeld=true`.

## Validation

Run:

```bash
swift test --filter TargetGraphTests/testGH1447To1456ReleaseV0290ProductionDryRunShadowAcceptance
bash checks/verify-v0.29.0.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Release Notes

This release is a no-submit production dry-run / shadow acceptance release. It does not authorize production cutover, does not enable default production trading, does not read production secret values, does not automatically connect to broker endpoints, and does not send real orders.
