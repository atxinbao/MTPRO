# MTPRO Release v0.22.0 Operator Approval Run Lock Contract

Date: 2026-07-05
Executor: Codex

## Anchors

- `GH-1310-VERIFY-V0220-OPERATOR-APPROVAL-RUN-LOCK`
- `TVM-RELEASE-V0220-OPERATOR-APPROVAL-RUN-LOCK`
- `V0220-002-BLOCKED-BY-GH1309`
- `V0220-002-OPERATOR-APPROVAL-SESSION`
- `V0220-002-SCOPE-BOUND-APPROVAL`
- `V0220-002-APPROVAL-REUSE-FAILS-CLOSED`
- `V0220-002-MISSING-STALE-MISMATCHED-FAILS-CLOSED`
- `V0220-002-ONE-SHOT-RUN-LOCK`
- `V0220-002-NO-SECRET-ENDPOINT-ORDER`
- `V0220-002-NO-PRODUCTION-CUTOVER`

## Goal

GH-1310 defines the operator approval session and one-shot run lock required before any downstream Binance Spot live canary secret-read, signed preflight, submit, status, cancel, OMS, or reconciliation issue can proceed.

The approval cannot be reused. The approved scope is fixed to Binance / spot / productionLive / BTCUSDT / 500 minor units / LIMIT. Missing, stale, or mismatched approval fails closed.

## Scope

- Consume GH-1309 live canary transport contract evidence.
- Require explicit Human operator approval evidence.
- Bind approval to venue / product / environment / symbol / notional / order type.
- Keep approval single-use.
- Add one-shot run lock evidence.
- Block concurrent live canary submit attempts.
- Preserve v0.22.0 WIP=1 queue order.

## Non-goals

- No credential secret read.
- No signed endpoint runtime.
- No account endpoint runtime.
- No submit / status / cancel transport.
- No OMS rollout.
- No reconciliation runtime.
- No Futures execution.
- No OKX active implementation.
- No Dashboard trading button or order form.
- No tag or GitHub Release publication in GH-1310.
- No production cutover.

## Boundary

GH-1310 is approval and run-lock evidence only. It does not read secrets, connect to production endpoint / broker endpoint, submit orders, query order status, cancel orders, publish a release, or authorize production cutover.

`V0220-002-NO-SECRET-ENDPOINT-ORDER` and `V0220-002-NO-PRODUCTION-CUTOVER` remain controlling release boundaries.
