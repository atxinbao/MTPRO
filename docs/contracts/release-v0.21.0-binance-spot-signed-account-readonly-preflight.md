# Release v0.21.0 Binance Spot Signed Account Read-only Preflight

日期：2026-07-02  
执行者：Codex

## Scope

GH-1276 固定 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary`
的 signed account read-only runtime preflight。该 gate 只在 GH-1275 credential
secret-read approval path 已成立后，记录 Binance Spot account read-only preflight
的 redacted account status evidence，并为 GH-1277 live account snapshot redaction
artifact 提供上游证据。

验证锚点：

- `GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`
- `TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`
- `V0210-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`
- `V0210-004-CONSUMES-CREDENTIAL-APPROVAL`
- `V0210-004-REDACTED-ACCOUNT-STATUS-EVIDENCE`
- `V0210-004-NO-RAW-ACCOUNT-PAYLOAD`
- `V0210-004-NO-ORDER-ENDPOINT`
- `V0210-004-NO-PRODUCTION-CUTOVER`

## Contract

GH-1276 依赖 GH-1275 的 explicit Human operator approval evidence。Preflight
只允许 Binance Spot `GET /api/v3/account` read-only identity 和 redacted account
status evidence 进入本地证据链；它不保存 raw account payload，不保存 credential
value，不暴露 API key / secret key / listenKey，不触达 order endpoint，不启用 submit /
cancel / replace。

| Field | Required Value |
| --- | --- |
| Issue | `GH-1276` |
| Upstream | `GH-1275` |
| Downstream | `GH-1277` |
| Queue | `GH-1273..GH-1286` |
| Venue | Binance |
| Product | Spot |
| Environment identity | `productionLive` identity only |
| Endpoint shape | `GET /api/v3/account` read-only |
| Evidence | redacted account status evidence |
| Raw account payload | forbidden |
| Order endpoint | forbidden |
| Production cutover | not authorized |

## Fail-closed Rules

- Missing GH-1275 approval evidence keeps the preflight fail-closed.
- Redaction evidence must contain `<redacted>` markers for account and payload status.
- Raw account payload storage fails closed.
- Any order endpoint attempt fails closed.
- Submit / cancel / replace remains disabled.
- Private stream / listenKey runtime remains out of scope for GH-1276.
- Futures and OKX remain out of scope.

## Forbidden Capabilities

GH-1276 does not store credential secret value, does not log credential material, does not store raw account payload, does not touch order endpoint, does not submit / cancel / replace, does not
implement private stream / listenKey runtime, does not add Dashboard trading button / order form /
live command, does not include Futures or OKX active implementation, does not create tag / GitHub
Release and does not authorize production cutover.

This document intentionally contains no credential value and no production cutover instruction.

## Validation

Required commands:

- `swift test --filter TargetGraphTests/testGH1276ReleaseV0210SignedAccountReadOnlyRuntimePreflight`
- `bash checks/verify-v0.21.0-signed-account-readonly-preflight.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
