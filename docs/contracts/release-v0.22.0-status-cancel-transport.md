# MTPRO Release v0.22.0 Status / Cancel Transport Contract

日期：2026-07-05

执行者：Codex

## Scope

GH-1314 defines approved Binance Spot live canary status / cancel transport evidence after GH-1313 one-shot submit transport is held.

This contract covers:

- Status query by approved exchange order id and approved client order id.
- Cancel transport only for the approved canary run and approved canary order.
- Idempotency key persistence and duplicate retry classification.
- Redacted status / cancel request and response evidence only.
- Ambiguous or unknown exchange state fail-closed behavior with required reconciliation.

## Anchors

- GH-1314-VERIFY-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT
- TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT
- V0220-006-BLOCKED-BY-GH1313
- V0220-006-STATUS-QUERY-BY-EXCHANGE-AND-CLIENT-ID
- V0220-006-CANCEL-APPROVED-CANARY-ORDER-ONLY
- V0220-006-IDEMPOTENCY-KEY-RETRY-CLASSIFICATION
- V0220-006-REDACTED-STATUS-CANCEL-EVIDENCE
- V0220-006-AMBIGUOUS-STATE-REQUIRES-RECONCILIATION
- V0220-006-UNKNOWN-STATE-FAILS-CLOSED
- V0220-006-NO-FUTURES-OKX
- V0220-006-NO-DASHBOARD-TRADING-CONTROLS
- V0220-006-NO-PRODUCTION-CUTOVER

## Boundary

Duplicate retry is accepted only when the idempotency key matches the approved prior attempt. A retry with a different key is rejected and logged as unsafe duplicate retry.

Cancel cannot target any order outside the approved run, approved client order id, and approved exchange order id.

Ambiguous exchange state requires reconciliation and fails closed. It does not create a cancel transport.

The persisted evidence is limited to redacted status / cancel envelopes. Raw status payload, raw cancel payload, credential value, signature, account payload, Futures execution, OKX active implementation, Dashboard trading controls, release publication and production cutover stay closed.

## Validation

- `swift test --filter TargetGraphTests/testGH1314ReleaseV0220LiveOrderStatusCancelTransport`
- `bash checks/verify-v0.22.0-status-cancel-transport.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/run.sh`
