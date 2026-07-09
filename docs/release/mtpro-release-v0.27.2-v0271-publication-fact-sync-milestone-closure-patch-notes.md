# MTPRO Release v0.27.2 v0.27.1 Publication Fact Sync / Milestone Closure Patch Notes

Date: 2026-07-10
Executor: Codex

## Scope

`MTPRO Release v0.27.2 v0.27.1 publication fact sync / milestone closure patch` is a no-capability-change release hygiene patch.

It records the published `v0.27.1` Dashboard macOS type-check patch facts, closes the stale `v0.27.0` milestone completion record, and keeps the continuation scope explicit:

- Binance Spot + Binance USD-M Futures remain the current target path.
- OKX out of current target path.
- v0.28.0 remains blocked until v0.27.2 completion.
- production cutover not authorized.

## Required Anchors

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

## Publication Facts

- v0.27.1 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.27.1
- v0.27.1 tag fixed at: `a69eed3b1a83028de14ce64ce42d1e2578eaab96`
- v0.27.1 published at: `2026-07-09T15:19:56Z`
- v0.27.1 title: `MTPRO v0.27.1 v0.27 Dashboard macOS Type-check Patch`
- v0.27.0 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.27.0
- v0.27.0 tag fixed at: `4ee83ecece5c434cbc97999ae30ee680c1072020`
- v0.27.0 published at: `2026-07-09T14:06:49Z`
- v0.27.0 milestone #45: closed with 0 open / 10 closed issues
- v0.27.0 issues #1411 through #1420: closed / done

## Explicit Non-goals

- No new trading capability.
- No production cutover.
- No production secret read.
- No production endpoint or broker endpoint connection.
- No production order submission.
- No OKX active runtime.
- No Dashboard trading controls, trading button, order form, or live command.
- No unrestricted live trading authorization.

## Validation

Required validation:

- `swift test --filter TargetGraphTests/testGH1424To1428ReleaseV0272PublicationFactSyncMilestoneClosurePatch`
- `bash checks/verify-v0.27.2.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Downstream Boundary

v0.28.0 remains blocked until v0.27.2 completion. v0.28.0 is Binance-only production cutover readiness planning / evidence work; it does not inherit OKX runtime, production trading authorization, Dashboard trading controls, or unrestricted live trading.
