# MTPRO Release v0.29.1 Shadow Acceptance Integrity / Publication Gate Repair Patch Stage Code Audit

Date: 2026-07-11  
Author: Codex

`TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR`

## Scope

v0.29.1 closes #1459-#1467 as a no-capability-change repair patch. It synchronizes v0.29.0 publication facts, reclassifies v0.29.0 acceptance evidence as deterministic fixture evidence, adds observed artifact validation, wires the CLI and Dashboard read-only acceptance surface, and adds stale wording / validation orchestration guards.

## Evidence Chain

- #1459: v0.29.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0.
- #1460: v0.29.0 fixture evidence is `evidenceOrigin=deterministic-fixture` with `acceptanceDecision=blocked`.
- #1461: `mtpro production-shadow-acceptance status|evidence|boundaries` routes to the v0.29.0 read-only acceptance surface.
- #1462: observed-run acceptance requires file existence, regular file proof, safe relative path, byte count, SHA-256 (`sha256`) digest, run ID, source commit, `operatorApprovalID`, actor, freshness, `observed-run-artifact` provenance, redaction and immutable manifest validation.
- #1463: fixture evidence and observed-run acceptance decision are separated; blocked fixture evidence is not summarized as accepted.
- #1464: publication facts record PR #1458, workflow run `29099609391`, release URL, tag target commit and closed milestone evidence.
- #1465: current docs keep Binance Spot + USD-M Futures as canonical current targets; OKX remains outside active runtime.
- #1466: `checks/run.sh` keeps one final full `swift test` lane while v0.29.0 focused verification can run in static mode under aggregate checks.
- #1467: v0.29.1 release notes and this stage audit close the patch without changing trading capability.

## Boundary

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretAutoReadEnabled=false`
- `automaticBrokerConnectionEnabled=false`
- `productionSubmitCancelReplaceEnabled=false`
- `noSubmitTransportMode=true`
- `shadowOnly=true`
- no production endpoint connection
- no broker submit / cancel / replace
- no OKX active runtime
- no v0.30.0 observed production shadow run capability

## Validation

- `swift test --filter TargetGraphTests/testGH1459To1467ReleaseV0291ShadowAcceptanceIntegrityPatch`
- `bash checks/verify-v0.29.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
