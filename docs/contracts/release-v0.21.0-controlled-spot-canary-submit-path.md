# Release v0.21.0 Controlled Spot Canary Submit Path

日期：2026-07-02

执行者：Codex

## Scope

GH-1280 defines the controlled Binance Spot canary submit path after GH-1279 pre-trade risk / kill switch / no-trade evidence has passed.

Validation anchors:

- `GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT`
- `TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT`
- `V0210-008-CONTROLLED-SPOT-CANARY-SUBMIT`
- `V0210-008-IDEMPOTENCY-KEY`
- `V0210-008-AUDIT-EVENT`
- `V0210-008-REDACTED-REQUEST-EVIDENCE`
- `V0210-008-STRICT-SYMBOL-SIZE-SCOPE`
- `V0210-008-SINGLE-APPROVED-ORDER`
- `V0210-008-NO-REPEATED-AUTOMATION-LOOP`
- `V0210-008-NO-PRODUCTION-CUTOVER`

## Dependency

GH-1280 consumes GH-1279 accepted submit-intent evidence and outputs only the single controlled Spot canary submit request evidence required by GH-1281 cancel / rollback guard.

## Submit Path Contract

The accepted path requires:

1. GH-1279 pre-trade evidence accepted.
2. Explicit submit approval.
3. Non-empty idempotency key.
4. Audit event evidence.
5. Redacted request evidence / redacted request evidence.
6. Strict `BTCUSDT` / `LIMIT` / `10.00 USDT` / `0.00100000 BTC` scope inherited from GH-1278.
7. Single approved order only / single approved order.

Any missing condition rejects the submit path before request creation.

## Boundary

This contract does not perform network submit. It does not enable a repeated automated trading loop, Futures, OKX, Dashboard default trading button, cancel / replace path, tag / GitHub Release publication, or production cutover. It does not store raw request payload, credential value, API key, secret, signature, production endpoint response, or broker endpoint response.
