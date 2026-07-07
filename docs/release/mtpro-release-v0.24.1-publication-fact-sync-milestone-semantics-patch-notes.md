# MTPRO Release v0.24.1 Publication Fact Sync / Milestone Semantics Patch Notes

Date: 2026-07-07  
Executor: Codex

## Anchors

- GH-1367-VERIFY-V0241-V0240-RELEASE-FACT-SYNC
- TVM-RELEASE-V0241-V0240-RELEASE-FACT-SYNC
- V0241-001-V0240-GITHUB-RELEASE-PUBLISHED
- V0241-001-V0240-TAG-FIXED
- V0241-001-V0240-PUBLISHED-AT-2026-07-06T19-43-49Z
- GH-1368-VERIFY-V0241-MILESTONE-COMPLETION-FACTS
- V0241-002-V0231-V0240-MILESTONES-CLOSED
- GH-1369-VERIFY-V0241-V0240-STALE-WORDING-GUARD
- V0241-003-PUBLISHED-V0240-STALE-WORDING-GUARD
- GH-1370-VERIFY-V0241-SPOT-CANARY-FUTURES-READONLY-SEMANTICS
- V0241-004-SPOT-CANARY-EVIDENCE-NOT-FUTURES-EXECUTION
- V0241-004-FUTURES-READONLY-EVIDENCE-NOT-TRADING-AUTHORIZATION
- GH-1371-VERIFY-V0241-PATCH-AUDIT-RELEASE-NOTES
- V0241-005-PATCH-AUDIT
- V0241-005-V0250-BLOCKED-BY-V0241-COMPLETION
- V0241-005-NO-CAPABILITY-CHANGE

## Summary

v0.24.1 is a publication fact sync and semantics patch. It records the already-published v0.24.0 GitHub Release, closes the v0.23.1 / v0.24.0 milestone completion evidence, adds a stale wording guard for published v0.24.0 documentation, and clarifies that Spot canary evidence is not Futures execution while Futures read-only evidence is not trading authorization.

## Publication Facts

- v0.24.0 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.24.0
- v0.24.0 tag target: `995065ba4ae4f9c80009fc68891176e5c0a56270`
- v0.24.0 published at: `2026-07-06T19:43:49Z`
- v0.23.1 milestone #38: closed with 0 open / 5 closed issues.
- v0.24.0 milestone #39: closed with 0 open / 8 closed issues.

## Boundary

No new trading capability is added. `spotCanaryEvidenceImpliesFuturesExecution=false`; `futuresReadOnlyEvidenceImpliesTradingAuthorization=false`; `futuresOrderExecutionEnabled=false`; `productionCutoverAuthorized=false`; `dashboardTradingControlsEnabled=false`. v0.25.0 remains blocked until v0.24.1 completion.

