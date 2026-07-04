# MTPRO Release v0.22.0 Binance Spot Live Canary Transport Completion Contract

Date: 2026-07-05
Executor: Codex

## Anchors

- `GH-1309-VERIFY-V0220-LIVE-CANARY-TRANSPORT-CONTRACT`
- `TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT`
- `V0220-001-V0211-PREFLIGHT-GATE`
- `V0220-001-BINANCE-SPOT-LIVE-CANARY-TRANSPORT`
- `V0220-001-OPERATOR-APPROVAL-REQUIRED`
- `V0220-001-ONE-SHOT-RUN-LOCK`
- `V0220-001-RISK-KILL-NO-TRADE-OMS-RECONCILIATION`
- `V0220-001-QUEUE-ORDER`
- `V0220-001-NO-PRODUCTION-CUTOVER`

## Goal

GH-1309 defines the v0.22.0 Binance Spot live canary transport completion contract. The version may only upgrade v0.21.0 controlled canary evidence into an explicitly approved, one-shot Binance Spot live canary transport chain.

The contract keeps the full evidence chain explicit:

```text
operator approval
-> credential secret material read
-> signed account preflight
-> one-shot submit transport
-> status / cancel transport
-> OMS event log
-> reconciliation evidence
-> Dashboard / CLI read-only surface
```

## Scope

- Binance Spot only.
- One-shot run lock required.
- Explicit operator approval required before any secret read or live transport.
- Small-notional allowlist required.
- RiskEngine, kill switch, no-trade, OMS and reconciliation gates required.
- Validation must include `bash checks/verify-v0.22.0-live-canary-transport-contract.sh`.

## Non-goals

- No production cutover.
- No production trading enabled by default.
- No Futures execution.
- No OKX active implementation.
- No Dashboard trading button or order form.
- No repeated automation loop or bulk order submission.
- No tag or GitHub Release publication in GH-1309.

## Boundary

GH-1309 is a contract and validation issue only. It does not read secrets, connect to a broker endpoint, submit orders, query status, cancel orders, publish a release, or start the next milestone.

`V0220-001-NO-PRODUCTION-CUTOVER` remains the controlling release boundary.
