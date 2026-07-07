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

The #1379 PR is a construction closeout. It does not create or move `v0.25.0`, does not create the GitHub Release, and does not authorize production cutover. Publication must be handled by a separate release gate after the queue is closed on `main`.
