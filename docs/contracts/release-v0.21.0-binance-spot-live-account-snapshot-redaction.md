# Release v0.21.0 Binance Spot Live Account Snapshot Redaction

日期：2026-07-02  
执行者：Codex

## Scope

GH-1277 固定 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary`
的 redacted live account snapshot artifact 和 freshness evidence。该 gate 只消费
GH-1276 signed account read-only preflight evidence，并输出可审计的脱敏账号快照
artifact schema、freshness / staleness evidence 和 stale / malformed fail-closed
evidence。

验证锚点：

- `GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION`
- `TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION`
- `V0210-005-LIVE-ACCOUNT-SNAPSHOT-REDACTION`
- `V0210-005-CONSUMES-SIGNED-ACCOUNT-PREFLIGHT`
- `V0210-005-ALLOWED-READINESS-FIELDS`
- `V0210-005-FRESHNESS-STALE-FAIL-CLOSED`
- `V0210-005-NO-RAW-BALANCE-ACCOUNT-ID`
- `V0210-005-NO-PRODUCTION-CUTOVER`

## Contract

GH-1277 依赖 GH-1276 的 signed account read-only preflight。它只允许 Binance Spot
`productionLive` identity 下的 redacted live account snapshot artifact 进入证据链；
artifact 只保存 readiness-only field、redacted marker、freshness score、staleness
threshold 和 policy version，并明确 rejects stale or malformed snapshots。

| Field | Required Value |
| --- | --- |
| Issue | `GH-1277` |
| Upstream | `GH-1276` |
| Downstream | `GH-1278` |
| Queue | `GH-1273..GH-1286` |
| Venue | Binance |
| Product | Spot |
| Environment identity | `productionLive` identity only |
| Artifact path | `artifacts/release-v0.21.0/account-snapshot/binance-spot-canary/<redacted-snapshot-id>.json` |
| Artifact content | redacted live account snapshot artifact |
| Freshness evidence | freshness / staleness evidence with bounded age |
| Stale / malformed snapshot | fail closed |
| Raw balance / account id / raw payload | forbidden |
| Order endpoint | forbidden |
| Production cutover | not authorized |

## Allowed Readiness Fields

允许字段只表达账号 readiness 与 freshness，不表达真实余额或真实账户标识：

- `snapshot_id_redacted`
- `venue`
- `product_kind`
- `trading_environment`
- `account_status_redacted`
- `can_trade_readiness_only`
- `can_withdraw_readiness_only`
- `can_deposit_readiness_only`
- `permissions_redacted`
- `freshness_status`
- `freshness_age_seconds`
- `stale_after_seconds`
- `policy_version`

## Fail-closed Rules

- Missing or invalid GH-1276 signed account read-only preflight evidence fails closed.
- Stale snapshot evidence fails closed when freshness age exceeds the threshold.
- Malformed snapshot evidence fails closed and cannot be accepted into the artifact chain.
- Raw balances, exact balance fields, account id, uid, secret, signature, listenKey, raw account payload,
  endpoint response body, order payload and broker fill are forbidden.
- Artifact path must remain release-scoped and redacted.
- Submit / cancel / replace, order endpoint, private stream / listenKey runtime and Dashboard command surfaces remain disabled.

## Forbidden Capabilities

GH-1277 does not read production secret value, does not persist credential value, does not persist raw balances, does not persist account identifier, does not persist raw account payload, does not persist endpoint response body, does not touch order endpoint, does not submit / cancel / replace, does not implement private stream / listenKey runtime, does not add Dashboard trading button / order form / live command, does not include Futures or OKX active implementation, does not create tag / GitHub Release and does not authorize production cutover.

This document intentionally contains no credential value and no production cutover instruction.

## Validation

Required commands:

- `swift test --filter TargetGraphTests/testGH1277ReleaseV0210LiveAccountSnapshotRedactionArtifact`
- `bash checks/verify-v0.21.0-live-account-snapshot-redaction.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
