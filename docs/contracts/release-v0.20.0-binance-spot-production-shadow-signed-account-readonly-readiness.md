# Release v0.20.0 Binance Spot Production-shadow Signed Account Read-only Readiness Contract

日期：2026-06-30
执行者：Codex
Issue：#1244 / GH-1244
上游：#1242 / GH-1242、#1243 / GH-1243
下游：#1245 / GH-1245

## 验证锚点

- GH-1244-VERIFY-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS
- TVM-RELEASE-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS
- V0200-006-BINANCE-SPOT-PRODUCTION-SHADOW-SIGNED-ACCOUNT-READINESS
- V0200-006-ACCOUNT-ENDPOINT-INTENT-ONLY
- V0200-006-CREDENTIAL-REFERENCE-BOUND
- V0200-006-REDACTED-ACCOUNT-PAYLOAD-EVIDENCE
- V0200-006-NO-SECRET-VALUE-READ
- V0200-006-NO-ORDER-ENDPOINT
- V0200-006-NO-PRODUCTION-CUTOVER

## 范围

GH-1244 只固定 Binance Spot `productionShadow` signed account read-only readiness contract：

- 复用 #1242 的 credential reference readiness，要求 credential reference identity-only 且 redacted。
- 复用 #1243 的 public market read-only probe，确保当前 v0.20.0 前序 probe evidence 已闭合。
- 记录 `/api/v3/account` 的 read-only intent，但该 intent 只作为 contract evidence，不生成 signature、不读取 secret、不打开连接。
- 对 missing / invalid credential reference 保留 fail-closed evidence。
- account payload evidence 必须保持 `account-payload=<not-accessed>`，不能保存 raw account payload。

## V0201-003 Intent Evidence Clarification

GH-1271 使用 `GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE`、`V0201-003-NOT-LIVE-TRANSPORT-PROOF`、`V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL`、`V0201-003-NO-ENDPOINT-CONNECTION` 和 `V0201-003-NO-PRODUCTION-CUTOVER` 明确：GH-1244 只记录 signed account read-only intent evidence，并依赖 GH-1243 的 public-market classification evidence 已闭合。它不是 signed endpoint runtime，不是 live transport proof，不是 account access proof，不生成 signature，不读取 secret，不触达 `/api/v3/account`，也不进行 account payload retrieval。

## 非目标

GH-1244 不实现以下能力：

- 不读取 production secret value。
- 不生成 signed request material。
- 不触达 `/api/v3/account` 或任何真实 account endpoint。
- 不保存 raw account payload。
- 不创建 listenKey 或 private stream runtime。
- 不触达 order endpoint 或 trading endpoint。
- 不提交 / 取消 / 替换订单。
- 不运行 Spot canary。
- 不实现 Binance USDⓈ-M Futures runtime。
- 不实现 OKX active implementation。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。

## Read-only Account Intent Evidence

`ReleaseV0200ProductionShadowSignedAccountReadOnlyIntent` 只允许记录：

- endpoint family：`https://api.binance.com`
- path：`/api/v3/account`
- method：`GET`
- redacted summary：`signed-account-readiness=<redacted>; endpoint=/api/v3/account; mode=read-only; payload=<not-accessed>`

任何 signing material 生成、secret value 读取、endpoint 连接、account payload 访问或 order endpoint touch 都会 fail closed。

## Boundary

GH-1244 是 signed account read-only readiness contract 和 intent evidence，不是 signed endpoint runtime、live transport proof 或 account access proof。production trading 默认关闭；production cutover not authorized；不会读取 production secret；不会连接 production endpoint / broker endpoint；不会触达真实 account endpoint 或 order endpoint；不会进行 account payload retrieval；不会发送真实订单或 testnet order。
