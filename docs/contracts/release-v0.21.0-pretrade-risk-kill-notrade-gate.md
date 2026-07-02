# Release v0.21.0 Pre-Trade Risk / Kill Switch / No-Trade Gate

日期：2026-07-02

执行者：Codex

## Scope

GH-1279 wires the Binance Spot controlled canary submit-intent path through RiskEngine, global kill switch, no-trade, operator approval and GH-1278 hard-limit evidence before GH-1280 can create any controlled submit path.

Validation anchors:

- `GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE`
- `TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE`
- `V0210-007-RISKENGINE-PRETRADE-GATE`
- `V0210-007-GLOBAL-KILL-SWITCH-GATE`
- `V0210-007-NO-TRADE-GATE`
- `V0210-007-APPROVAL-GATE`
- `V0210-007-HARD-LIMIT-GATE`
- `V0210-007-AUDIT-EVIDENCE-NO-BYPASS`
- `V0210-007-NO-PRODUCTION-CUTOVER`

## Dependency

GH-1279 consumes GH-1278 canary hard-limit evidence and outputs only local submit-intent eligibility / rejection audit evidence for GH-1280.

## Gate Order

Every canary submit intent must pass:

1. RiskEngine pre-trade risk gate.
2. Global kill switch gate.
3. No-trade gate.
4. Operator approval gate.
5. GH-1278 hard-limit gate.

Any failed gate blocks submit-intent eligibility and emits deterministic audit evidence. The rejected path has no bypass path, no Dashboard command shortcut, and no adapter submit attempt.

## Boundary

This contract does not submit / cancel / replace orders. It does not create a broker request, touch an order endpoint, read production secrets, connect a production endpoint, enable a Dashboard command, or authorize production cutover.
