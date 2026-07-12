# MTPRO v0.30.0 Observed Production Shadow Run Acceptance

Date: 2026-07-11
Executor: Codex

## Anchor Inventory

`GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT`, `GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE`, `GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE`, `GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT`, `GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT`, `GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE`, `GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION`, `GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN`, `V0300-001-OBSERVED-RUN-LIFECYCLE`, `V0300-001-NO-SUBMIT-CONTRACT`, `V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE`, `V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE`, `V0300-003-IMMUTABLE-MANIFEST-PROVENANCE`, `V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT`, `V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT`, `V0300-006-DASHBOARD-CLI-READONLY-SURFACE`, `V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION`, `V0300-008-STAGE-AUDIT-RELEASE-DOCS`.

## Summary

v0.30.0 moves the production-shadow track from deterministic acceptance evidence to an observed, immutable, no-submit production shadow run evidence surface; deterministic fixture evidence remains fail-closed until an explicit artifact-root manifest validates. The release remains Binance-only for Spot and USD-M Futures.

## Release Facts

- `observedShadowRun=true`
- `observedRunAccepted=false`
- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretAutoReadEnabled=false`
- `automaticBrokerConnectionEnabled=false`
- `productionSubmitCancelReplaceEnabled=false`
- `noSubmitTransportMode=true`
- `noMutationTransportMode=true`

## What Changed

- Added `ReleaseV0300ObservedProductionShadowRun`.
- Added `ReleaseV0300DashboardCLIObservedShadowRunSurface`.
- Added `mtpro observed-production-shadow status|validate|evidence|export|boundaries`.
- Added `checks/verify-v0.30.0.sh`.
- Added stage audit and root validation documentation.

## Boundary

This release does not open production cutover. It does not read production secret values automatically, connect production broker endpoints automatically, send production submit / cancel / replace, mutate Futures production leverage / margin / position mode, activate OKX runtime, or expose Dashboard trading controls.
