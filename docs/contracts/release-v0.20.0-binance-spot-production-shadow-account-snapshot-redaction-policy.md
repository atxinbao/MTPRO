# Release v0.20.0 Binance Spot Production-shadow Account Snapshot Redaction Policy

日期：2026-06-30
执行者：Codex
Issue：#1245 / GH-1245

## Scope

本合同固定 `MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness` 的 account snapshot artifact redaction policy。

GH-1245 只定义账号快照证据的安全落盘格式、字段 allowlist、字段 denylist、artifact 路径和验证入口。它继承 #1244 / GH-1244 的 signed account read-only readiness，但不读取 production secret、不生成 signature、不触达 `/api/v3/account`、不保存真实 broker response、不启用 submit / cancel / replace、不创建 tag / release，也不授权 production cutover。

## Validation Anchors

- `GH-1245-VERIFY-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY`
- `TVM-RELEASE-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY`
- `V0200-007-BINANCE-SPOT-PRODUCTION-SHADOW-ACCOUNT-SNAPSHOT-REDACTION`
- `V0200-007-ARTIFACT-LOCATION-POLICY`
- `V0200-007-ALLOWED-FIELD-SCHEMA`
- `V0200-007-FORBIDDEN-FIELD-SCHEMA`
- `V0200-007-REDACTED-SNAPSHOT-JSON`
- `V0200-007-NO-RAW-BALANCE-PERSISTENCE`
- `V0200-007-NO-ACCOUNT-ID-PERSISTENCE`
- `V0200-007-NO-SECRET-OR-RAW-PAYLOAD-PERSISTENCE`
- `V0200-007-NO-PRODUCTION-CUTOVER`

## Allowed Artifact Fields

允许落盘的字段只包含脱敏元数据：

- `snapshot_id_redacted`
- `venue`
- `product_kind`
- `trading_environment`
- `observation_state`
- `account_summary_hash`
- `balance_bucket_redacted`
- `position_count`
- `margin_mode_redacted`
- `policy_version`

这些字段不能携带真实 account identifier、真实余额、真实持仓明细、API key、secret、signature、listenKey、endpoint response body 或 order payload。

## Forbidden Artifact Fields

以下字段或语义不得进入 artifact：

- exact balance
- account id
- uid
- api key
- secret value
- signature
- listenKey
- raw broker payload
- endpoint response body
- order payload

`ReleaseV0200ProductionShadowAccountSnapshotRedactedArtifact` 会把上述字段作为 denylist 固定到 deterministic evidence；任何 raw balance、account identifier、secret material、raw broker payload、endpoint response body 或 order payload persistence flag 都必须 fail closed。

## Artifact Location Policy

唯一允许的 repository-relative 示例路径：

`artifacts/release-v0.20.0/account-snapshot/production-shadow/<redacted-snapshot-id>.json`

禁止绝对路径、`..` 逃逸、真实 account id、uid、api-key、secret 或 exchange payload 文件名进入路径。

## Safe Redacted Artifact Example

允许的示例 payload 只能是脱敏 JSON：

`{"snapshot_id":"<redacted>","venue":"binance","product_kind":"spot","trading_environment":"production-shadow","account_id":"<redacted>","balance_bucket":"<redacted-bucket>","position_count":"<count-only>","margin_mode":"<redacted>","raw_broker_payload":"<not-persisted>","policy_version":"v0.20.0-account-snapshot-redaction"}`

该样例只证明 artifact schema。它不是 `/api/v3/account` 的真实 response，不包含真实余额、真实 account id、secret、signature、listenKey、raw broker payload 或 order payload。

## Boundary

- Binance Spot only。
- Production-shadow / read-only readiness only。
- Production trading remains disabled by default。
- No production secret auto-read。
- No signed request material generation。
- No real `/api/v3/account` request。
- No endpoint connection。
- No raw account snapshot persistence。
- No submit / cancel / replace。
- No Spot canary。
- No Dashboard trading button、order form 或 live command。
- Production cutover not authorized。
