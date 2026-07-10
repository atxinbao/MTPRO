# MTPRO Release v0.28.0 Binance Production Cutover Readiness Gate Stage Code Audit

Date: 2026-07-10
Executor: Codex

## Anchor Inventory

- GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT
- TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE
- V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS
- V0280-001-NOT-PRODUCTION-CUTOVER
- V0280-001-SPOT-USDM-FUTURES-ONLY
- V0280-001-OKX-NOT-ACTIVE
- GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY
- V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL
- V0280-002-NO-DEFAULT-SECRET-READ
- V0280-002-REDACTION-REQUIRED
- GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST
- V0280-003-ENDPOINT-ALLOWLIST
- V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION
- V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS
- GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION
- V0280-004-MANUAL-APPROVAL-REQUIRED
- V0280-004-OPERATOR-CONFIRMATION-REQUIRED
- V0280-004-NO-AUTO-CUTOVER
- GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE
- V0280-005-CAPITAL-RISK-GATE
- V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS
- V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED
- GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP
- V0280-006-KILL-SWITCH-REQUIRED
- V0280-006-NO-TRADE-STATE-REQUIRED
- V0280-006-ROLLBACK-INCIDENT-STOP-READY
- GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE
- V0280-007-DASHBOARD-CLI-READINESS
- V0280-007-NO-TRADING-BUTTON
- V0280-007-NO-ORDER-FORM
- V0280-007-NO-LIVE-COMMAND
- GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
- V0280-008-AGGREGATE-VALIDATION
- V0280-008-STAGE-AUDIT-RELEASE-DOCS
- V0280-008-NO-PRODUCTION-CUTOVER

## Scope

v0.28.0 closes the Binance-only production cutover readiness gate for Spot and USD-M Futures. It records readiness conditions for production credential policy, production endpoint isolation, manual approval, operator confirmation, capital risk, notional exposure, Futures leverage, kill switch, no-trade, rollback, incident stop and read-only Dashboard / CLI status.

## Boundary

This is not production cutover. `productionTradingEnabledByDefault=false`, `productionCutoverAuthorized=false`, `productionSecretReadEnabledByDefault=false`, `productionEndpointConnectionEnabledByDefault=false`, `brokerEndpointConnectionEnabledByDefault=false`, `productionOrderSubmitCancelReplaceEnabled=false`, `futuresProductionOrderExecutionEnabled=false`, `okxActiveRuntimeEnabled=false`, `dashboardTradingControlsEnabled=false`, `orderFormEnabled=false`, and `liveCommandEnabled=false`.

## Evidence Chain

- Source contract: `Sources/ExecutionClient/FutureGate/ReleaseV0280ProductionCutoverReadinessGate.swift`
- Read-only surface: `Sources/Dashboard/Report/ReleaseV0280DashboardCLIProductionReadinessSurface.swift`
- CLI entry: `mtpro production-cutover-readiness-gate status|gates|boundaries`
- Focused test: `TargetGraphTests/testGH1429To1436ReleaseV0280ProductionCutoverReadinessGate`
- Aggregate guard: `checks/verify-v0.28.0.sh`

## Validation

- `swift test --filter TargetGraphTests/testGH1429To1436ReleaseV0280ProductionCutoverReadinessGate`
- `bash checks/verify-v0.28.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Release Gate

v0.28.0 is now published at https://github.com/atxinbao/MTPRO/releases/tag/v0.28.0. The fixed tag / release commit is `4411bf8536c3bae55e365d832627873b6042e4d1`, published at `2026-07-09T20:10:10Z`, from PR #1438. v0.27.2 milestone #46 closed and v0.28.0 milestone #47 closed.

## v0.28.1 Publication Fact / Readiness Semantics Patch Addendum

Date: 2026-07-10
Executor: Codex

Anchors: `GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC`, `GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE`, `GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD`, `GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES`, `V0281-004-EVALUATION-MODE-CONTRACT-ONLY`, `V0281-004-READINESS-STATUS-NOT-EVALUATED`, `V0281-004-CUTOVER-DECISION-BLOCKED`, `GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE`, `V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES`, `GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE`, `GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE`, `GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES`.

- evaluationMode=contract-only
- readinessStatus=not-evaluated
- cutoverDecision=blocked
- readinessGateEvidenceComplete=true

v0.28.1 hardens published release facts, Binance-only current baseline wording, explicit readiness semantics, complete/unique readiness gate evidence, Linux + macOS pre-publication evidence, and verifier de-duplication. It adds no trading capability.
