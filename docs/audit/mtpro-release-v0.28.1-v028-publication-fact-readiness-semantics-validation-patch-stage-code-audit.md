# MTPRO Release v0.28.1 v0.28 Publication Fact / Readiness Semantics / Validation Patch Stage Code Audit

Date: 2026-07-10  
Executor: Codex

## Anchor Inventory

- GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC
- GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE
- GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD
- GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES
- V0281-004-EVALUATION-MODE-CONTRACT-ONLY
- V0281-004-READINESS-STATUS-NOT-EVALUATED
- V0281-004-CUTOVER-DECISION-BLOCKED
- GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE
- V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES
- GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE
- GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE
- GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES

## Published v0.28.0 Evidence

v0.28.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.28.0. The fixed tag / release commit is `4411bf8536c3bae55e365d832627873b6042e4d1`, published at `2026-07-09T20:10:10Z`, from PR #1438. v0.27.2 milestone #46 closed and v0.28.0 milestone #47 closed.

## Scope

v0.28.1 is a no-capability-change patch. It syncs publication facts, corrects current Binance-only baseline wording, adds stale wording guards, makes readiness state semantics explicit, rejects incomplete / duplicate / malformed readiness gate evidence, and de-duplicates release verification.

## Readiness Semantics

- evaluationMode=contract-only
- readinessStatus=not-evaluated
- cutoverDecision=blocked
- readinessGateEvidenceComplete=true

## Validation Expectations

Linux checks and macOS Dashboard smoke are pre-publication requirements. release verifier duplication is narrowed to one focused v0.28.1 XCTest plus the final aggregate XCTest. The patch guard is `checks/verify-v0.28.1.sh`, and `checks/run.sh` must invoke it.

## Boundary

No new trading capability. No production cutover. No default production secret read. No automatic production endpoint or broker endpoint connection. No submit / cancel / replace. No Futures production order execution. No OKX active runtime. No Dashboard trading button, order form or live command. v0.29.0 remains blocked until v0.28.1 is complete.
