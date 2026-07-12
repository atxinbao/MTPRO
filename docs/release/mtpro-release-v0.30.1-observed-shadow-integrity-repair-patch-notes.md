# MTPRO v0.30.1 Observed Shadow Integrity Repair Patch

Date: 2026-07-12
Executor: Codex

## Anchor Inventory

`GH-1478-VERIFY-V0301-V0300-PUBLICATION-FACTS`, `GH-1479-VERIFY-V0301-DETERMINISTIC-FIXTURE-FAIL-CLOSED`, `GH-1480-VERIFY-V0301-ARTIFACT-INTEGRITY-ACCEPTANCE`, `GH-1481-VERIFY-V0301-CLI-EXPLICIT-ARTIFACT-INPUT`, `GH-1482-VERIFY-V0301-HUMAN-APPROVED-OBSERVED-BUNDLE`, `GH-1483-VERIFY-V0301-PREPUBLICATION-MATRIX-GATE`, `GH-1484-VERIFY-V0301-DEDUPE-VALIDATION-ORCHESTRATION`, `GH-1485-VERIFY-V0301-BINANCE-ONLY-ROOT-DOCS-MILESTONES`, `GH-1486-VERIFY-V0301-STAGE-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0301-OBSERVED-SHADOW-INTEGRITY-REPAIR`.

## Summary

v0.30.1 is an integrity repair patch for v0.30.0 publication facts and observed-run acceptance semantics. v0.30.0 is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.30.0, published at `2026-07-11T01:07:32Z`, and points to `4a9fff2add7e0a133b461afd0f4151ba1698db01`.

The deterministic fixture is now explicitly fail-closed: `evidenceOrigin=deterministic-fixture`, `acceptanceDecision=blocked`, `observedRunAccepted=false`. Acceptance requires an explicit `--artifact-root` manifest bundle with full git source commit, operator approval, freshness, provenance, redaction, immutable manifest and SHA-256 validation.

## Boundary

This patch does not add production trading, production cutover, secret auto-read, broker auto-connect, submit / cancel / replace, Futures production mutation, OKX runtime, Dashboard trading controls, order forms, or live commands.

## Validation

- `swift test --filter TargetGraphTests/testGH1468To1475ReleaseV0300ObservedProductionShadowRun`
- `bash checks/verify-v0.30.0.sh`
- `bash checks/verify-v0.30.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
