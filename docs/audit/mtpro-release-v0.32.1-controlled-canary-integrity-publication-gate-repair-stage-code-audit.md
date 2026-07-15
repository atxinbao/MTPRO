# MTPRO Release v0.32.1 Controlled Canary Integrity / Publication Gate Repair Stage Code Audit

Date: 2026-07-15
Executor: Codex

## Anchors

- GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
- GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256
- GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK
- GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX
- GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
- GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
- GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE
- GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS
- TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR
- V0321-001-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
- V0321-002-EVIDENCE-ROOT-MANIFEST-SHA256
- V0321-003-APPROVAL-SCOPE-RUN-LOCK
- V0321-004-CAP-VALIDATION-NEGATIVE-MATRIX
- V0321-005-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
- V0321-006-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
- V0321-007-FULL-MATRIX-BEFORE-RELEASE
- V0321-008-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS

## Audit Scope

v0.32.1 repairs the v0.32.0 controlled canary evidence interpretation and release publication gate. The release adds explicit evidence-root manifest validation, SHA-256 recomputation, approval scope / expiry / source commit binding, persistent run-lock evidence, production canary cap validation, exact Spot and USD-M Futures submit / status / cancel artifact validation, OMS / rollback / incident linkage validation, and a full-matrix-before-release workflow gate.

This audit intentionally treats deterministic fixture evidence as integrity-test evidence only. A deterministic fixture can prove that the validator works, but it must not be accepted as an observed production canary. The expected local fixture result is `observedProductionCanary=false` and `acceptanceDecision=blocked-observed-production-canary-missing`.

## Evidence Chain

- `ReleaseV0321ControlledCanaryIntegrityRepair` validates `manifest.json` from an explicit `--artifact-root`.
- Every artifact listed in the manifest must exist under the evidence root, stay inside that root, match byte count, and match recomputed `sha256:<hex>` digest.
- Approval evidence must bind scope, expiry, source commit, policy version, product scope and action scope.
- Run-lock evidence must reject duplicate and replay attempts and bind to the same run ID and source commit.
- Cap evidence must reject negative, stale, over-notional, over-exposure, over-leverage or over-action inputs.
- Spot and USD-M Futures must each provide exactly one submit, one status and one cancel artifact with monotonic sequence numbers.
- OMS evidence must link append-only event log, sequence-gap rejection, reconciliation replay, rollback, incident stop, kill switch and no-trade evidence.
- Publication evidence must require `pr_fast_checks`, `linux_checks`, `dashboard_macos` and `release_publication_checks` before release creation.

## Boundary

- No default or unrestricted production trading.
- No production cutover authorization.
- No automatic secret read.
- No automatic broker connection.
- No new production submit / cancel / replace capability.
- No OKX active runtime.
- No Dashboard trading button, order form or live command.

## Validation

Required validation commands:

```bash
swift test --filter TargetGraphTests/testGH1519To1526ReleaseV0321ControlledCanaryIntegrityRepair
bash checks/verify-v0.32.1.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
