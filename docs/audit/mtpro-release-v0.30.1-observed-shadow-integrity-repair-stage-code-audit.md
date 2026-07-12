# MTPRO Release v0.30.1 Observed Shadow Integrity Repair Stage Code Audit

Date: 2026-07-12
Executor: Codex

## Anchor Inventory

`GH-1478-VERIFY-V0301-V0300-PUBLICATION-FACTS`, `GH-1479-VERIFY-V0301-DETERMINISTIC-FIXTURE-FAIL-CLOSED`, `GH-1480-VERIFY-V0301-ARTIFACT-INTEGRITY-ACCEPTANCE`, `GH-1481-VERIFY-V0301-CLI-EXPLICIT-ARTIFACT-INPUT`, `GH-1482-VERIFY-V0301-HUMAN-APPROVED-OBSERVED-BUNDLE`, `GH-1483-VERIFY-V0301-PREPUBLICATION-MATRIX-GATE`, `GH-1484-VERIFY-V0301-DEDUPE-VALIDATION-ORCHESTRATION`, `GH-1485-VERIFY-V0301-BINANCE-ONLY-ROOT-DOCS-MILESTONES`, `GH-1486-VERIFY-V0301-STAGE-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0301-OBSERVED-SHADOW-INTEGRITY-REPAIR`.

## Result

v0.30.1 repairs the v0.30.0 observed production shadow run acceptance model. The v0.30.0 release facts remain immutable: GitHub Release https://github.com/atxinbao/MTPRO/releases/tag/v0.30.0 is published at `2026-07-11T01:07:32Z` and resolves to `4a9fff2add7e0a133b461afd0f4151ba1698db01`.

The deterministic fixture is blocked by default and reports `observedRunAccepted=false`. The only accepted path is an explicit artifact bundle loaded with `--artifact-root`, where `manifest.json` and all listed artifact files pass file existence, safe path, byte count, SHA-256, source commit, operator approval, freshness, provenance, redaction and immutable manifest checks.

## Boundary

No production trading capability is added. No production cutover is authorized. The patch does not read production secrets, connect broker endpoints automatically, submit / cancel / replace orders, mutate Futures production settings, activate OKX runtime, or expose Dashboard trading controls.

## Validation

- `swift test --filter TargetGraphTests/testGH1468To1475ReleaseV0300ObservedProductionShadowRun`
- `bash checks/verify-v0.30.0.sh`
- `bash checks/verify-v0.30.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
