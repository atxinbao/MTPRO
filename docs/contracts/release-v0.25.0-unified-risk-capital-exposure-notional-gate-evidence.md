# MTPRO v0.25.0 Unified Risk / Capital / Exposure / Notional Gate Evidence

Date: 2026-07-07  
Author: Codex

## Scope

This document records `V0250-005` unified risk, capital, exposure and notional gate evidence for Binance Spot and Binance USDⓈ-M Futures production-readiness review.

The scope is readiness evidence only. It does not implement real pre-trade allow / reject runtime, does not read live account balance, broker positions, margin or leverage, and does not authorize live commands.

## Validation Anchors

- `GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE`
- `TVM-RELEASE-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE`
- `V0250-005-UNIFIED-RISK-GATE`
- `V0250-005-CAPITAL-GATE`
- `V0250-005-EXPOSURE-GATE`
- `V0250-005-NOTIONAL-GATE`
- `V0250-005-FAIL-CLOSED-READINESS-CLASSIFICATION`
- `V0250-005-NO-LIVE-COMMAND-AUTHORIZATION`

## Product Coverage

- `spot` evidence is sourced from `v0.25.0/V0250-003`.
- `usdsPerpetual` evidence is sourced from `v0.25.0/V0250-004`.

Both products must hold capital, exposure and notional gate evidence before downstream incident, rollback, Dashboard or release closeout material can claim dual-product production readiness.

## Explicit Non-goals

- No real pre-trade allow / reject runtime.
- No live account balance read.
- No broker position read.
- No margin or leverage read.
- No live command authorization from risk evidence.
- No submit / cancel / replace.
- No production cutover.
