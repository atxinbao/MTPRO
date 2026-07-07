# MTPRO v0.25.0 Spot Canary Operator Control Evidence

Date: 2026-07-07  
Author: Codex

## Scope

This document records `V0250-003` Spot canary hardening evidence.

The scope is evidence-only. It aligns v0.22 Spot canary transport evidence with v0.24 dual-product vocabulary, but it does not expand production trading scope and does not authorize unrestricted live trading.

## Validation Anchors

- `GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE`
- `TVM-RELEASE-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE`
- `V0250-003-SPOT-CANARY-OPERATOR-CONFIRMATION`
- `V0250-003-IDEMPOTENCY-EVIDENCE`
- `V0250-003-SIZE-CAP-EVIDENCE`
- `V0250-003-ROLLBACK-EVIDENCE`
- `V0250-003-NO-UNRESTRICTED-LIVE-TRADING`

## Required Evidence

- Operator confirmation proof before any canary submit path is considered.
- Idempotency evidence to prevent repeated operator actions from reusing stale command identity.
- Size cap evidence with a deterministic `BTCUSDT` allowlist, `10 USDT` max notional and `0.001 BTC` max base quantity.
- Rollback evidence before any controlled canary path can be interpreted as ready.
- v0.22 Spot transport evidence alignment.
- v0.24 dual-product vocabulary alignment.

## Explicit Non-goals

- No production trading enabled by default.
- No unrestricted live trading.
- No default order mutation.
- No Dashboard trading controls.
- No order form.
- No live command.
- No production cutover.
