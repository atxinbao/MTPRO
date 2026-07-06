# MTPRO Release v0.23.1 Publication Fact Sync / Read-only Guard Patch Notes

Date: 2026-07-07  
Executor: Codex

## Anchors

- GH-1353-VERIFY-V0231-V0230-RELEASE-FACT-SYNC
- TVM-RELEASE-V0231-V0230-RELEASE-FACT-SYNC
- V0231-001-V0230-GITHUB-RELEASE-PUBLISHED
- V0231-001-V0230-TAG-FIXED
- GH-1354-VERIFY-V0231-V0230-STALE-WORDING-GUARD
- V0231-002-PUBLISHED-V0230-STALE-WORDING-GUARD
- GH-1355-VERIFY-V0231-LATEST-VERIFICATION-MILESTONE-FACTS
- V0231-003-V0221-V0230-MILESTONES-COMPLETE
- GH-1356-VERIFY-V0231-FUTURES-READONLY-GUARD-HARDENING
- V0231-004-NO-FUTURES-MUTATION
- V0231-004-NO-LISTENKEY-PRIVATE-STREAM
- V0231-004-NO-OKX-PRODUCTION-CUTOVER
- GH-1357-VERIFY-V0231-PATCH-AUDIT-RELEASE-NOTES
- V0231-005-PATCH-AUDIT
- V0231-005-V0240-BLOCKED-BY-V0231-COMPLETION
- V0231-005-NO-CAPABILITY-CHANGE

## Summary

v0.23.1 is a docs and validation patch for the published v0.23.0 Binance USD-M Futures read-only foundation.

It synchronizes the v0.23.0 GitHub Release URL and fixed tag target, removes current-facing stale publication wording, refreshes the latest verification baseline, records v0.22.1 / v0.23.0 milestone completion facts, and hardens read-only guard wording.

## Boundary

No trading capability changes. `futuresOrderExecutionEnabled=false`, `productionCutoverAuthorized=false`, no Futures submit / cancel / replace, no leverage / margin type / position mode mutation, no listenKey / private stream runtime, no OKX active runtime, no Dashboard trading controls, no order form, and no live command.

v0.24.0 remains blocked until this v0.23.1 patch is complete.
