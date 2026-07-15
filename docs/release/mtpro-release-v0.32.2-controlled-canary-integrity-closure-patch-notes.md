# MTPRO Release v0.32.2 Controlled Canary Integrity Closure Patch Notes

日期：2026-07-15  
执行者：Codex

## Scope

v0.32.2 is an integrity closure patch for the controlled canary line. It does not add trading capability and does not authorize backend production operations closure.

Anchors: `GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX`, `GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY`, `GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS`, `GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY`, `GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE`, `GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT`, `TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH`, `V0322-001-RELEASE-CREATION-BEHIND-FULL-MATRIX`, `V0322-002-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY`, `V0322-003-COMMIT-CLOCK-APPROVAL-FRESHNESS`, `V0322-004-ATOMIC-RUN-LOCK-REPLAY-REGISTRY`, `V0322-005-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE`, `V0322-006-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT`.

## What Changed

- GitHub Release creation for `v0.32.2` is owned by the final `release-publication-checks` job after `pr-fast-checks`, `linux-checks`, and `dashboard-macos` all pass.
- Observed canary acceptance is derived from trusted GitHub Actions provenance and artifact evidence, not from a manifest self-report boolean.
- Approval expiry, source commit, trusted clock, and evidence freshness are bound to validator input.
- Run-lock evidence requires atomic persistence, replay registry recording, duplicate-run rejection, replay rejection, and stale-lock recovery audit evidence.
- Operation artifacts must semantically bind run ID, product, action, event identity, idempotency key, OMS event, reconciliation, rollback, and incident stop evidence.
- Backend production operations closure remains blocked: `backendClosureDecision=blocked`, `observedProductionCanary=false`, `acceptanceDecision=blocked-trusted-observed-canary-missing`.

## Boundary

- Production cutover remains unauthorized.
- Default or unrestricted production trading remains disabled.
- No automatic production secret read.
- No automatic broker connection.
- No OKX active runtime.
- No Dashboard trading button, order form, or live command.
- No new production submit / cancel / replace capability.
- `v0.33.0` observed canary work remains blocked until v0.32.2 closure evidence is complete.

## Validation

Required validation:

```bash
swift test --filter TargetGraphTests/testGH1528To1533ReleaseV0322ControlledCanaryIntegrityClosurePatch
bash checks/verify-v0.32.2.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
