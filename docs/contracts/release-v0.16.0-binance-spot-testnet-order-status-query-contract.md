# Release v0.16.0 Binance Spot Testnet Order Status Query Contract

日期：2026-06-25

执行者：Codex

本文档定义 #1105 / GH-1105 的 Binance Spot Testnet signed order status query 合同。该合同只覆盖 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` 的 `spot-testnet-status-query` CLI slice，不授权 production cutover。

## Anchors

- `GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY`
- `TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY`
- `V0160-005-SIGNED-GET-ORDER-STATUS`
- `V0160-005-TESTNET-ENDPOINT-ALLOWLIST`
- `V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE`
- `V0160-005-NO-RAW-SECRET-PERSISTENCE`
- `V0160-005-PRODUCTION-HOST-REJECTED`
- `V0160-005-NO-PRODUCTION-CUTOVER`

## Scope

GH-1105 只实现 `spot-testnet-status-query` stable CLI status query flow。该 flow 必须消费 #1103 / #1104 链路已经产生的 source submit evidence JSON 与 network event log JSON，从 submit evidence 派生短生命周期 order identity，并构造 Binance Spot Testnet signed GET `/api/v3/order` status query。

允许能力：

- 使用 `ReleaseV0160CLIOrderStatusQueryFlow` 解析 `spot-testnet-status-query`。
- 使用 `ReleaseV0160BinanceSpotTestnetSignedOrderStatusQueryRequestEvidence` 记录 signed GET request 的脱敏 evidence。
- 使用 `ReleaseV0160BinanceSpotTestnetOrderStatusTransport` 注入 transport。
- 使用 `ReleaseV0151BinanceSpotTestnetURLSessionTransport.querySpotTestnetOrderStatus` 执行 allowlisted `GET https://testnet.binance.vision/api/v3/order`。
- 输出 redacted artifact path、checksum、signed request id 和 status transport result id。

## Non-goals

GH-1105 不实现 production trading、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 production order、不授权 production cutover。

GH-1105 不新增 broker adapter、不新增 OMS production runtime、不新增 Dashboard command surface、不实现 production order status、不连接 Binance production host。

## Boundary

- Endpoint host 固定为 `testnet.binance.vision`。
- Endpoint path 固定为 GET `/api/v3/order`。
- CLI 必须要求 `--testnet`、`testnet-env` credential provider 和 v0.16 operator confirmation。
- Source submit evidence 缺失、network event log 缺失、credential reference mismatch、wrong confirmation、production provider、非 status action 和 production host 必须 fail closed。
- Request evidence 不保存 raw API key、raw secret、raw originalClientOrderId 或完整 signed query string。
- Response evidence 只保存 redacted digest，不保存 raw response body。

## Validation

必跑验证：

```bash
swift test --filter TargetGraphTests/testGH1105ReleaseV0160SignedOrderStatusQueryUsesGETAllowlistAndRedaction
bash checks/verify-v0.16.0-order-status-query.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

验证必须证明：

- `spot-testnet-status-query` 已接入 `MTPROCLI`。
- signed request method 为 GET。
- URLSession transport 拒绝 production host。
- redacted request / response evidence 不泄露 raw credential、raw secret 或 raw order identity。
- production trading 默认关闭，production cutover 未授权。
