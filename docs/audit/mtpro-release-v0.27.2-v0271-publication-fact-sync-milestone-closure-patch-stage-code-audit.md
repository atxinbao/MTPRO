# MTPRO Release v0.27.2 v0.27.1 Publication Fact Sync / Milestone Closure Patch Stage Code Audit

Date: 2026-07-10
Executor: Codex

## Summary

`MTPRO Release v0.27.2 v0.27.1 publication fact sync / milestone closure patch` closes GH-1424 through GH-1428 as a no-capability-change patch.

The patch records the published v0.27.1 release facts, records v0.27.0 milestone completion, adds stale wording guards, clarifies the Binance Spot + Binance USD-M Futures continuation scope, and keeps OKX out of the current target path.

## Anchors

- GH-1424-VERIFY-V0272-V0271-RELEASE-FACT-SYNC
- TVM-RELEASE-V0272-V0271-RELEASE-FACT-SYNC
- V0272-001-V0271-GITHUB-RELEASE-PUBLISHED
- V0272-001-V0271-TAG-FIXED
- V0272-001-V0271-PUBLISHED-AT-2026-07-09T15-19-56Z
- GH-1425-VERIFY-V0272-V0270-MILESTONE-COMPLETION
- V0272-002-V0270-MILESTONE-CLOSED
- V0272-002-V0270-ISSUES-1411-1420-DONE
- GH-1426-VERIFY-V0272-V0271-STALE-WORDING-GUARD
- V0272-003-PUBLISHED-V0271-STALE-WORDING-GUARD
- GH-1427-VERIFY-V0272-BINANCE-ONLY-CONTINUATION-SCOPE
- V0272-004-BINANCE-SPOT-USDM-FUTURES-CONTINUATION
- V0272-004-OKX-OUT-OF-CURRENT-TARGET-PATH
- GH-1428-VERIFY-V0272-PATCH-AUDIT-RELEASE-NOTES
- V0272-005-PATCH-AUDIT
- V0272-005-V0280-BLOCKED-BY-V0272-COMPLETION
- V0272-005-NO-CAPABILITY-CHANGE

## Evidence Chain

- `checks/verify-v0.27.2.sh` runs focused tests, anchor coverage checks, release fact checks, milestone completion checks, and stale wording guards.
- `Tests/TargetGraphTests/TargetGraphTests.swift` includes `testGH1424To1428ReleaseV0272PublicationFactSyncMilestoneClosurePatch`.
- v0.27.1 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.27.1.
- v0.27.1 tag is fixed at `a69eed3b1a83028de14ce64ce42d1e2578eaab96`.
- v0.27.1 was published at `2026-07-09T15:19:56Z`.
- v0.27.1 release title is `MTPRO v0.27.1 v0.27 Dashboard macOS Type-check Patch`.
- v0.27.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.27.0.
- v0.27.0 tag is fixed at `4ee83ecece5c434cbc97999ae30ee680c1072020`.
- v0.27.0 was published at `2026-07-09T14:06:49Z`.
- v0.27.0 milestone #45 is closed with 0 open / 10 closed issues.
- v0.27.0 issues #1411 through #1420 are closed / done.

## Boundary

- Binance Spot + Binance USD-M Futures remain the continuation scope.
- OKX out of current target path.
- v0.28.0 remains blocked until v0.27.2 completion.
- no capability change.
- productionFuturesOrderExecutionEnabled=false.
- productionTradingEnabledByDefault=false.
- production cutover not authorized.
- productionSecretRead=false.
- productionEndpointConnected=false.
- brokerEndpointConnected=false.
- productionOrderSubmitted=false.
- okxActiveRuntimeEnabled=false.
- dashboardTradingControlsEnabled=false.
- unrestrictedLiveTradingAuthorized=false.

## Validation

Required validation:

- `swift test --filter TargetGraphTests/testGH1424To1428ReleaseV0272PublicationFactSyncMilestoneClosurePatch`
- `bash checks/verify-v0.27.2.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
