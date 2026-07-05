# Release v0.22.0 OMS Evidence Log Contract

Date: 2026-07-05
Executor: Codex

## Purpose

`GH-1315` defines the v0.22.0 append-only OMS event log evidence for an approved Binance Spot live canary order lifecycle.

This contract persists only redacted and replayable evidence references for:

```text
submit ack -> status observation -> cancel request -> cancel ack -> terminal state -> ambiguous state
```

It depends on:

- `GH-1313`: one approved Binance Spot live canary submit transport evidence.
- `GH-1314`: approved Binance Spot live canary status / cancel transport evidence.

## Anchors

- `GH-1315-VERIFY-V0220-OMS-EVIDENCE-LOG`
- `TVM-RELEASE-V0220-OMS-EVIDENCE-LOG`
- `V0220-007-BLOCKED-BY-GH1313-GH1314`
- `V0220-007-APPEND-ONLY-OMS-EVENT-LOG`
- `V0220-007-SUBMIT-ACK-STATUS-CANCEL-TERMINAL-EVENTS`
- `V0220-007-CORRELATION-CAUSATION-IDS`
- `V0220-007-REDACTED-REPLAYABLE-EVIDENCE`
- `V0220-007-REJECTS-MISSING-OUT-OF-ORDER-LIFECYCLE`
- `V0220-007-NO-FUTURES-OKX`
- `V0220-007-NO-DASHBOARD-TRADING-CONTROLS`
- `V0220-007-NO-PRODUCTION-CUTOVER`

## Required Evidence

- OMS event log entries are append-only and sequence ordered.
- Submit ack, status observation, cancel request, cancel outcome, terminal state, and ambiguous-state evidence are all represented.
- Every event carries the same run ID, client order ID, exchange order ID, and correlation ID.
- Causation IDs form a deterministic chain from the root canary command to the final evidence entry.
- Evidence references are redacted and replayable.
- Missing status, missing cancel outcome, out-of-order lifecycle, correlation mismatch, or raw payload evidence fails closed.

## Boundaries

- Binance Spot only.
- No Futures / OKX active implementation.
- No Dashboard trading controls or order form.
- No production cutover.
- No raw exchange ack, raw status payload, raw cancel payload, credential value, signature, or account payload persistence.
- No tag or GitHub Release publication.

## Validation

Required commands:

```bash
swift test --filter TargetGraphTests/testGH1315ReleaseV0220OMSEventLogPersistsExchangeAckStatusCancelEvidence
bash checks/verify-v0.22.0-oms-evidence-log.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.21.0.sh
bash checks/run.sh
```
