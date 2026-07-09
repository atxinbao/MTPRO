# MTPRO Release v0.26.1 v0.26 Publication Fact Sync / Milestone Closure Patch Notes

Date: 2026-07-09  
Executor: Codex

## Anchors

- GH-1406-VERIFY-V0261-V0260-RELEASE-FACT-SYNC
- TVM-RELEASE-V0261-V0260-RELEASE-FACT-SYNC
- V0261-001-V0260-GITHUB-RELEASE-PUBLISHED
- V0261-001-V0260-TAG-FIXED
- V0261-001-V0260-PUBLISHED-AT-2026-07-08T13-00-01Z
- GH-1407-VERIFY-V0261-V0260-MILESTONE-COMPLETION
- V0261-002-V0260-MILESTONE-CLOSED
- V0261-002-V0260-ISSUES-1394-1403-DONE
- GH-1408-VERIFY-V0261-V0260-STALE-WORDING-GUARD
- V0261-003-PUBLISHED-V0260-STALE-WORDING-GUARD
- GH-1409-VERIFY-V0261-V0260-BASELINE-WORDING
- V0261-004-V0260-CURRENT-PUBLISHED-BASELINE
- V0261-004-FUTURES-TESTNET-CONTROLLED-EXECUTION-FOUNDATION
- GH-1410-VERIFY-V0261-PATCH-AUDIT-RELEASE-NOTES
- V0261-005-PATCH-AUDIT
- V0261-005-V0270-BLOCKED-BY-V0261-COMPLETION
- V0261-005-NO-CAPABILITY-CHANGE

## Summary

v0.26.1 is a no-capability-change publication fact sync and milestone closure patch. It records the published v0.26.0 GitHub Release facts, records the v0.26.0 milestone completion, clarifies that v0.26.0 construction no-tag wording is historical only, and keeps v0.27.0 blocked until v0.26.1 closes.

## Publication Facts

- v0.26.0 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.26.0
- v0.26.0 tag target: `e3b65f2337c5275eaa7ce5c5f224b69475a7c9bb`
- v0.26.0 published at: `2026-07-08T13:00:01Z`
- v0.26.0 milestone #43: closed with 0 open / 10 closed issues.
- v0.26.0 issues #1394 through #1403: closed / done.
- Current maturity: Binance USD-M Futures testnet controlled execution foundation.

## Boundary

No new trading capability is added. `productionFuturesOrderExecutionEnabled=false`; `productionCutoverAuthorized=false`; `okxActiveRuntimeEnabled=false`; `dashboardTradingControlsEnabled=false`. This patch does not move the v0.26.0 tag, does not overwrite the v0.26.0 GitHub Release, and does not authorize production cutover. production cutover not authorized. If v0.26.1 is published after merge, the release action must use the merged commit as an immutable target and must not authorize production cutover.
