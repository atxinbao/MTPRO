# MTPRO Release v0.22.0 Credential Secret Material Read Redaction Contract

Date: 2026-07-05
Executor: Codex

## Anchors

- `GH-1311-VERIFY-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION`
- `TVM-RELEASE-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION`
- `V0220-003-BLOCKED-BY-GH1310`
- `V0220-003-APPROVAL-BOUND-SECRET-READ`
- `V0220-003-EPHEMERAL-SECRET-MATERIAL-ONLY`
- `V0220-003-REDACTED-AUDIT-EVIDENCE`
- `V0220-003-RAW-SECRET-NEVER-PERSISTED`
- `V0220-003-MISSING-APPROVAL-FAILS-CLOSED`
- `V0220-003-NO-ENDPOINT-ORDER`
- `V0220-003-NO-PRODUCTION-CUTOVER`

## Goal

GH-1311 defines the approved, ephemeral credential secret material read path after GH-1310 operator approval and one-shot run lock evidence.

The path allows a scoped Binance Spot productionLive canary run to read temporary secret material only after a valid approval lock. It persists only redacted credential reference metadata and redacted audit evidence.

## Scope

- Consume GH-1310 operator approval and one-shot run lock evidence.
- Bind the read to the approved Binance / spot / productionLive / BTCUSDT / LIMIT scope.
- Require non-empty temporary API key and secret material inputs.
- Persist only redacted credential reference metadata.
- Persist only redacted audit evidence.
- Fail closed for missing approval, consumed approval, mismatched scope, or missing secret material.

## Non-goals

- No automatic secret discovery.
- No fallback secret provider.
- No raw API key persistence.
- No raw secret key persistence.
- No signature persistence.
- No listenKey persistence.
- No signed endpoint runtime.
- No account endpoint runtime.
- No private stream runtime.
- No submit / status / cancel transport.
- No OMS rollout.
- No reconciliation runtime.
- No Futures execution.
- No OKX active implementation.
- No Dashboard trading button or order form.
- No tag or GitHub Release publication in GH-1311.
- No production cutover.

## Boundary

GH-1311 is a credential material read and redaction boundary only. It does not connect to Binance, does not sign requests, does not open account endpoints, does not submit / query / cancel orders, and does not authorize production cutover.

`V0220-003-RAW-SECRET-NEVER-PERSISTED` and `V0220-003-NO-ENDPOINT-ORDER` remain controlling release boundaries.
