# MTPRO Release v0.30.0 Observed Production Shadow Run Stage Code Audit

Date: 2026-07-11
Executor: Codex

## Anchor Inventory

`GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT`, `GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE`, `GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE`, `GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT`, `GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT`, `GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE`, `GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION`, `GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN`, `V0300-001-OBSERVED-RUN-LIFECYCLE`, `V0300-001-NO-SUBMIT-CONTRACT`, `V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE`, `V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE`, `V0300-003-IMMUTABLE-MANIFEST-PROVENANCE`, `V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT`, `V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT`, `V0300-006-DASHBOARD-CLI-READONLY-SURFACE`, `V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION`, `V0300-008-STAGE-AUDIT-RELEASE-DOCS`.

## Result

v0.30.0 adds observed production shadow run acceptance for Binance Spot and Binance USD-M Futures. The release records a no-submit, no-mutation operator-observed run lifecycle, approval scope, credential reference, endpoint allowlist, immutable artifact manifest, read-only endpoint preflight evidence, no-mutation Risk / OMS / Reconciliation / Incident drill evidence, and Dashboard / CLI read-only surface.

Required boundary facts: `observedShadowRun=true`, `observedRunAccepted=true`, `productionTradingEnabledByDefault=false`, `productionCutoverAuthorized=false`, `productionSecretAutoReadEnabled=false`, `automaticBrokerConnectionEnabled=false`, `productionSubmitCancelReplaceEnabled=false`, `noSubmitTransportMode=true`, `noMutationTransportMode=true`, `boundaryHeld=true`.

## Validation

- `swift test --filter TargetGraphTests/testGH1468To1475ReleaseV0300ObservedProductionShadowRun`
- `bash checks/verify-v0.30.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

This stage does not authorize production cutover, default production trading, automatic secret read, automatic broker connection, submit / cancel / replace, Futures production execution mutation, OKX active runtime, Dashboard trading controls, order forms, or live commands.
