# Release v0.20.0 Binance Spot Production-shadow Public Market Read-only Probe Contract

日期：2026-06-30
执行者：Codex
Issue：#1243 / GH-1243
上游：#1242 / GH-1242
下游：#1244 / GH-1244

## 验证锚点

- GH-1243-VERIFY-V0200-PUBLIC-MARKET-READ-ONLY-PROBE
- TVM-RELEASE-V0200-PUBLIC-MARKET-READ-ONLY-PROBE
- V0200-005-BINANCE-SPOT-PRODUCTION-SHADOW-PUBLIC-MARKET-PROBE
- V0200-005-PUBLIC-MARKET-READ-ONLY-REACHABILITY
- V0200-005-RESPONSE-CLASSIFICATION-EVIDENCE
- V0200-005-NO-CREDENTIAL-REQUIRED
- V0200-005-NO-SIGNED-ACCOUNT-ENDPOINT
- V0200-005-NO-ORDER-ENDPOINT
- V0200-005-NO-PRODUCTION-CUTOVER

## 范围

GH-1243 只固定 Binance Spot `productionShadow` public market read-only probe evidence：

- 复用 #1241 的 `https://api.binance.com` read-only endpoint allowlist。
- 复用 #1242 的 credential reference readiness，但 public market probe 不要求 credential。
- 对 `/api/v3/time`、`/api/v3/exchangeInfo`、`/api/v3/ticker/price`、`/api/v3/depth` 的 read-only probe 结果做 deterministic classification。
- response evidence 只能保存 status code、classification 和 `<not-persisted>` 摘要，不能保存 raw response payload。

## V0201-003 Classification Evidence Clarification

GH-1271 使用 `GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE`、`V0201-003-NOT-LIVE-TRANSPORT-PROOF`、`V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL`、`V0201-003-NO-ENDPOINT-CONNECTION` 和 `V0201-003-NO-PRODUCTION-CUTOVER` 明确：GH-1243 只记录 public-market response classification / readiness evidence。它不是 live transport proof，不是 account access proof，不读取 credential，不访问 signed account endpoint，不保存 raw response payload，不连接 production endpoint / broker endpoint，也不授权 production cutover。

## 非目标

GH-1243 不实现以下能力：

- 不读取 production secret value。
- 不要求 credential 或 account payload。
- 不触达 signed account endpoint。
- 不创建 listenKey 或 private stream runtime。
- 不触达 order endpoint 或 trading endpoint。
- 不提交 / 取消 / 替换订单。
- 不运行 Spot canary。
- 不实现 Binance USDⓈ-M Futures runtime。
- 不实现 OKX active implementation。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。

## Response Classification Evidence

Probe observation 的分类集合固定为：

- `reachable`
- `rate-limited`
- `service-unavailable`
- `network-unavailable`

每条 observation 必须绑定 #1241 的 endpoint shape evidence，并保留 `public-market-probe=<kind>; classification=<classification>; payload=<not-persisted>` 摘要。任何 credential required、account payload required、raw payload persisted、signed endpoint touched、account endpoint touched 或 trading endpoint touched 都是 forbidden capability。

## Boundary

GH-1243 是 read-only public market readiness evidence 和 response classification evidence，不是 live transport proof 或 account access proof。production trading 默认关闭；production cutover not authorized；不会读取 production secret；不会连接 production endpoint / broker endpoint；不会触达 signed/account/trading endpoint；不会进行 account payload retrieval；不会发送真实订单或 testnet order。
