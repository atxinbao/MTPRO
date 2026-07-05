# MTPRO Release v0.22.0 Signed Account Runtime Preflight

Date: 2026-07-05  
Executor: Codex

## Anchors

- `GH-1312-VERIFY-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT`
- `TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT`
- `V0220-004-BLOCKED-BY-GH1311`
- `V0220-004-APPROVED-CANARY-SESSION-ONLY`
- `V0220-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`
- `V0220-004-REDACTED-FRESHNESS-STATUS-EVIDENCE`
- `V0220-004-RAW-ACCOUNT-PAYLOAD-NEVER-PERSISTED`
- `V0220-004-ENDPOINT-AUTH-TIMESTAMP-PERMISSION-STALE-FAIL-CLOSED`
- `V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT`
- `V0220-004-NO-FUTURES-OKX`
- `V0220-004-NO-ORDER-CUTOVER`

## Contract

GH-1312 defines the v0.22.0 Binance Spot signed account runtime preflight after GH-1311 credential secret material read evidence is held.

The preflight is read-only and scoped to the Binance Spot production account endpoint identity:

- endpoint family: `https://api.binance.com`
- account path: `/api/v3/account`
- method: `GET`
- credential reference: redacted only
- evidence: redacted freshness/status summary only

## Fail-closed Requirements

The preflight must fail closed and block downstream submit path when any of these classes occurs:

- missing GH-1311 credential secret material read evidence
- endpoint rejection
- authentication rejection
- timestamp rejection
- permission rejection
- stale account response
- raw account payload attempt
- order capability attempt

## Redaction

Persist only redacted freshness/status evidence:

- no raw account payload persistence
- no signature persistence
- no API key or secret key persistence
- no listenKey persistence
- no balances, permissions, maker commission, taker commission or raw response body persisted

## Non-goals

- No Futures or OKX runtime.
- No submit / cancel / replace.
- No order endpoint access.
- No private stream / listenKey runtime.
- No Dashboard trading button or order form.
- No tag or GitHub Release publication in GH-1312.
- No production cutover authorization.

## Boundary

GH-1312 is the read-only signed account preflight boundary for the v0.22.0 Binance Spot live canary sequence. It proves only that the explicit canary session has redacted account preflight freshness/status evidence and that any preflight failure blocks the downstream submit gate.

`V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT` and `V0220-004-NO-ORDER-CUTOVER` remain controlling release boundaries.
