# Release v0.21.0 Controlled Canary Cancel Rollback Guard

日期：2026-07-02

执行者：Codex

## Scope

GH-1281 defines the controlled Binance Spot canary cancel / status rollback guard after GH-1280 controlled submit request evidence has passed.

Validation anchors:

- `GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK`
- `TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK`
- `V0210-009-CONTROLLED-CANARY-CANCEL`
- `V0210-009-STATUS-ROLLBACK-GUARD`
- `V0210-009-AUDIT-EVIDENCE`
- `V0210-009-REDACTED-CANCEL-EVIDENCE`
- `V0210-009-SINGLE-CANARY-ORDER`
- `V0210-009-NO-BULK-CANCEL`
- `V0210-009-NO-FUTURES-CANCEL`
- `V0210-009-NO-PRODUCTION-CUTOVER`

## Dependency

GH-1281 consumes GH-1280 authorized controlled submit request evidence and outputs only the single controlled canary cancel request evidence plus status rollback guard required by GH-1282 status confirmation.

## Cancel / Rollback Contract

The accepted path requires:

1. GH-1280 controlled submit evidence authorized.
2. Explicit cancel approval.
3. Non-empty cancel idempotency key.
4. Redacted canary order reference / redacted canary order reference.
5. Audit event evidence.
6. Redacted cancel request evidence / redacted cancel request evidence.
7. Status rollback guard / status rollback guard evidence.
8. Strict `BTCUSDT` single canary order scope.
9. Cancel window not expired.

Any missing condition rejects the cancel / rollback path before cancel request evidence creation.

## Boundary

This contract does not perform network cancel. It does not enable bulk cancel, Futures cancel, OKX, Dashboard default trading button, tag / GitHub Release publication, or production cutover. It does not store raw order id, raw cancel payload, credential value, API key, secret, signature, production endpoint response, or broker endpoint response.
