# Release v0.22.0 Live Order Submit Transport Contract

Date: 2026-07-05
Executor: Codex

## Purpose

GH-1313 defines the first Binance Spot one-shot live canary submit transport evidence path for release v0.22.0.

This contract is intentionally narrow:

- Binance Spot only.
- One approved order per run only.
- Allowlisted symbol, side, order type, time-in-force, notional and quantity only.
- CommandGateway, RiskEngine, kill switch, no-trade, ExecutionEngine and OMS gates are required before transport evidence can be accepted.
- GH-1312 signed account runtime preflight must be ready.
- Redacted request evidence and redacted exchange ack evidence must be stored.

## Anchors

- GH-1313-VERIFY-V0220-LIVE-ORDER-SUBMIT-TRANSPORT
- TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT
- V0220-005-BLOCKED-BY-GH1312
- V0220-005-BINANCE-SPOT-ONE-SHOT-SUBMIT
- V0220-005-ALLOWLISTED-SYMBOL-NOTIONAL-SIDE-TIF
- V0220-005-COMMAND-RISK-KILL-NOTRADE-EXECUTION-OMS-GATES
- V0220-005-REDACTED-EXCHANGE-ACK-EVIDENCE
- V0220-005-SINGLE-APPROVED-ORDER-PER-RUN
- V0220-005-FAIL-CLOSED-LIMIT-RISK-KILL-NOTRADE-TRANSPORT
- V0220-005-NO-FUTURES-OKX
- V0220-005-NO-DASHBOARD-TRADING-CONTROLS
- V0220-005-NO-PRODUCTION-CUTOVER

## Boundary

GH-1313 opens only the evidence path for one allowlisted Binance Spot live canary submit transport. It does not open broad production cutover, Futures, OKX, repeated automated trading loops, Dashboard trading controls, or non-allowlisted order capability.

All failures fail closed:

- Missing GH-1312 preflight.
- Risk rejection.
- Active kill switch.
- Active no-trade state.
- Symbol / notional / side / time-in-force scope violation.
- Duplicate order attempt for the same run.
- Missing redacted request evidence.
- Missing or failed exchange ack evidence.

## Verification

Required commands:

- `swift test --filter TargetGraphTests/testGH1313ReleaseV0220LiveOrderSubmitTransport`
- `bash checks/verify-v0.22.0-live-order-submit-transport.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/run.sh`
