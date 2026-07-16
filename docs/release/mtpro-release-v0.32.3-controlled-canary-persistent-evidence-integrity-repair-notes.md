# MTPRO Release v0.32.3 Controlled Canary Persistent Evidence Integrity Repair Notes

日期：2026-07-17  
执行者：Codex

## Scope

v0.32.3 repairs persistent controlled-canary evidence integrity before any observed production canary or backend closure work. It adds trusted GitHub provenance validation, an atomic persistent run-lock registry, independent OMS/reconciliation/rollback/incident artifacts, real-path containment, and a complete fail-closed negative matrix.

Anchors: `GH-1541-CLOSE-V0323-STAGE-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR`, `V0323-007-STAGE-AUDIT-RELEASE-NOTES`, `V0323-007-BACKEND-CLOSURE-BLOCKED`, `V0323-007-BINANCE-SPOT-USDM-FUTURES-ONLY`, `V0323-007-V0330-BLOCKED-UNTIL-V0323-PUBLISHED`, `V0323-007-NO-PRODUCTION-CUTOVER`.

## What Changed

- Trusted provenance is loaded from checksum-bound GitHub run/artifact exports; manifest self-report booleans are rejected.
- Run locking uses atomic filesystem acquisition, a checksum-protected disk registry, nonce/run replay rejection, owner validation, and audited stale recovery.
- Every Spot and USD-M Futures submit/status/cancel operation binds independent OMS, reconciliation, rollback, and incident artifacts with bidirectional identity and SHA256 linkage.
- Evidence reads resolve canonical paths and reject symlink roots/components, nested links, traversal, absolute outside paths, and replaced directories.
- `checks/verify-v0.32.3-negative-matrix.sh` preserves all P1/P2 negative scenarios.

## Boundary

- `observedProductionCanary=false`
- `backendClosureDecision=blocked`
- `productionCutoverAuthorized=false`
- `productionTradingEnabledByDefault=false`
- Active venue/product scope is Binance Spot + Binance USD-M Futures only.
- OKX is not an active runtime in this release.
- No automatic production secret read or broker connection.
- No Dashboard trading button, order form, or live command.
- v0.33.0 eligibility requires a published v0.32.3 full-matrix release and separate Human approval for any observed canary.

## Validation

```bash
swift test --filter TargetGraphTests/testGH1541ReleaseV0323StageAuditReleaseDocsCloseout
bash checks/verify-v0.32.3.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

Release publication is owned by the `v0.32.3` tag workflow after `pr-fast-checks`, `linux-checks`, `dashboard-macos`, and `release-publication-checks` succeed.
