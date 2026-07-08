# MTPRO Release v0.25.1 v0.25 Publication Fact Sync / Roadmap Correction Patch Notes

Date: 2026-07-08  
Executor: Codex

## Anchors

- GH-1389-VERIFY-V0251-V0250-RELEASE-FACT-SYNC
- TVM-RELEASE-V0251-V0250-RELEASE-FACT-SYNC
- V0251-001-V0250-GITHUB-RELEASE-PUBLISHED
- V0251-001-V0250-TAG-FIXED
- V0251-001-V0250-PUBLISHED-AT-2026-07-07T14-47-50Z
- GH-1390-VERIFY-V0251-MILESTONE-COMPLETION-FACTS
- V0251-002-V0250-MILESTONE-CLOSED
- GH-1391-VERIFY-V0251-V022-V023-MAINLINE-WORDING
- V0251-003-V0220-SPOT-LIVE-CANARY-TRANSPORT
- V0251-003-V0230-FUTURES-READONLY-FOUNDATION
- GH-1392-VERIFY-V0251-V0250-STALE-WORDING-GUARD
- V0251-004-PUBLISHED-V0250-STALE-WORDING-GUARD
- GH-1393-VERIFY-V0251-PATCH-AUDIT-RELEASE-NOTES
- V0251-005-PATCH-AUDIT
- V0251-005-V0260-BLOCKED-BY-V0251-COMPLETION
- V0251-005-NO-CAPABILITY-CHANGE

## Summary

v0.25.1 is a publication fact sync and roadmap correction patch. It records the already-published v0.25.0 GitHub Release, records the v0.25.0 milestone completion, corrects the fixed v0.22 / v0.23 mainline wording, and adds a stale wording guard for published v0.25.0 documentation.

## Publication Facts

- v0.25.0 GitHub Release: https://github.com/atxinbao/MTPRO/releases/tag/v0.25.0
- v0.25.0 tag target: `1dad68196b28eca7285a5c8efb3d15ce74c`
- v0.25.0 published at: `2026-07-07T14:47:50Z`
- v0.25.0 milestone #41: closed with 0 open / 8 closed issues.

## Roadmap Correction

- v0.22.0 is Binance Spot live canary transport completion.
- v0.23.0 is Binance USD-M Futures read-only foundation.
- v0.26.0 remains blocked until v0.25.1 completion.

## Boundary

No new trading capability is added. `productionCutoverAuthorized=false`; `futuresOrderExecutionEnabled=false`; `okxActiveRuntimeEnabled=false`; `dashboardTradingControlsEnabled=false`. This patch does not move the v0.25.0 tag, does not overwrite the v0.25.0 GitHub Release, and does not authorize production cutover.
