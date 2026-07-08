# MTPRO Release v0.25.0 Dual-product Production Readiness / Canary Hardening Notes

Date: 2026-07-07

Executor: Codex

## Anchors

- GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
- GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY
- GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE
- GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE
- GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE
- GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE
- GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE
- GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
- TVM-RELEASE-V0250-AGGREGATE-VALIDATION
- V0250-008-AGGREGATE-VALIDATION-SUITE
- V0250-008-STAGE-AUDIT-RELEASE-DOCS
- V0250-008-ROOT-DOCS-REFRESH
- V0250-008-RELEASE-PUBLICATION-GATE-HANDOFF
- V0250-008-NO-PRODUCTION-CUTOVER
- V0250-008-NO-TAG-OR-RELEASE-PUBLICATION

## Summary

v0.25.0 closes the Binance dual-product production readiness / canary hardening stage. It combines Binance Spot controlled canary evidence with Binance USD-M Futures read-only evidence and adds unified readiness views for risk, capital, exposure, notional, incident rollback, no-trade state, kill-switch readiness and read-only Dashboard / CLI operator status.

## What This Release Enables

- Binance Spot canary evidence can be reviewed alongside dual-product readiness evidence.
- Binance USD-M Futures evidence stays read-only and fail-closed.
- Unified risk / capital / exposure / notional gates are represented as readiness evidence.
- Incident rollback, no-trade and kill-switch readiness are visible as evidence.
- Dashboard / CLI operator surface remains read-only.

## What This Release Does Not Enable

- productionTradingEnabledByDefault remains false.
- Production secret reads remain disabled.
- Production endpoint and broker endpoint auto-connect remain disabled.
- Futures submit / cancel / replace remains disabled.
- OKX active runtime remains disabled.
- Dashboard trading button, order form, live command and Live PRO Console remain disabled.
- Production cutover remains separately gated and is not authorized by v0.25.0.

## Compatibility / Regression Note

The aggregate verifier also exercises the historical v0.20.0 `production-shadow-readiness status` CLI surface. That path now renders status from a lightweight read-only projection instead of constructing the full nested v0.20.0 evidence graph inside the executable. This prevents a CLI stack overflow while preserving the same read-only output and keeping all production trading boundaries closed.

## Validation

```bash
swift test --filter TargetGraphTests/testGH1379ReleaseV0250AggregateValidationReleaseCloseout
bash checks/verify-v0.25.0.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Publication Boundary

The #1379 PR remains historical construction closeout evidence. Current publication fact: `v0.25.0` is published as a stable GitHub Release at https://github.com/atxinbao/MTPRO/releases/tag/v0.25.0, the tag target is `1dad68196b28eca7285a5c8efb3d15ce74c`, and the release was published at `2026-07-07T14:47:50Z`. The v0.25.0 milestone #41 is closed with 0 open / 8 closed issues. Production cutover remains not authorized.

## v0.25.1 Publication Fact Sync Patch Anchors

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
