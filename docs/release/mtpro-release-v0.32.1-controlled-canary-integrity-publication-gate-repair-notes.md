# MTPRO Release v0.32.1 Controlled Canary Integrity / Publication Gate Repair Notes

Date: 2026-07-15
Executor: Codex

## Release Purpose

v0.32.1 is a patch release for controlled canary integrity and publication gate repair. It does not add trading capability. It ensures v0.32.0 controlled canary evidence is not accepted unless it comes from an explicit, validated evidence root with artifact existence checks, SHA-256 recomputation, approval binding, run-lock replay protection, cap validation, OMS linkage and full release-matrix publication evidence.

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

## Release Notes

- Adds `controlled-canary-integrity-repair` CLI status and publication surfaces.
- Requires explicit `--artifact-root`; missing artifact roots fail closed.
- Recomputes SHA-256 for every manifest artifact and rejects mismatches.
- Rejects unsafe artifact paths that escape the evidence root.
- Validates human approval expiry, scope, source commit, policy version, product scope and action scope.
- Validates persistent run-lock and replay protection.
- Validates Spot and USD-M Futures caps and negative input rejection.
- Validates unique Spot and USD-M Futures submit / status / cancel artifact sets.
- Validates OMS reconciliation, rollback and incident evidence linkage.
- Repairs GitHub Actions release publication gating so release publication waits for PR fast checks, Linux checks, dashboard macOS and release publication checks.

## Acceptance Semantics

The deterministic fixture evidence included in local validation is intentionally blocked as an observed production canary:

```text
observedProductionCanary=false
acceptanceDecision=blocked-observed-production-canary-missing
productionCutoverAuthorized=false
boundaryHeld=true
releaseCreatedAfterFullMatrix=true
```

## Boundary

v0.32.1 keeps production cutover unauthorized. It does not enable default or unrestricted production trading, automatic secret read, automatic broker connection, OKX runtime, Dashboard trading controls, order form, live command or new production submit / cancel / replace capability.
