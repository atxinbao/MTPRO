# MTPRO v0.25.0 Futures Read-only Freshness / Fail-closed Evidence

Date: 2026-07-07  
Author: Codex

## Scope

This document records `V0250-004` Binance USDⓈ-M Futures read-only freshness and fail-closed evidence.

The scope is read-only readiness evidence only. It does not enable Futures submit / cancel / replace, leverage mutation, margin mode mutation, position mode mutation, listenKey runtime, or a Futures broker adapter.

## Validation Anchors

- `GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE`
- `TVM-RELEASE-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE`
- `V0250-004-FUTURES-READONLY-FRESHNESS`
- `V0250-004-STALE-FAILS-CLOSED`
- `V0250-004-MISSING-FAILS-CLOSED`
- `V0250-004-ENDPOINT-BLOCKED`
- `V0250-004-CAPABILITY-MISMATCH-BLOCKED`
- `V0250-004-NO-FUTURES-ORDER-MUTATION`

## Required Failure Classes

- `stale-readonly-evidence`
- `missing-readonly-evidence`
- `endpoint-blocked`
- `capability-mismatch`

Every failure class must produce blocked evidence, fail closed, keep order mutation disabled and keep listenKey runtime disabled.

## Explicit Non-goals

- No Futures submit / cancel / replace.
- No leverage mutation.
- No margin mode mutation.
- No position mode mutation.
- No listenKey runtime.
- No Futures broker adapter.
- No production cutover.
