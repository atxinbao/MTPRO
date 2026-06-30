# Release v0.20.0 Binance Spot Production-shadow Endpoint Allowlist Contract

日期：2026-06-30  
执行者：Codex

本文档是 #1241 / GH-1241 的合同证据。它在 #1240 / GH-1240 environment profile 之后，固定 Binance Spot `productionShadow` 的只读 endpoint allowlist。该合同只描述 endpoint shape、host family、read-only path 和 query shape；它不连接 production endpoint / broker endpoint，不读取 production secret value，不实现 signed account endpoint runtime、private stream runtime、listenKey runtime、submit / cancel / replace、Spot canary、Futures runtime、OKX runtime、tag / GitHub Release 或 production cutover。

## Anchors

- GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
- TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
- V0200-003-BINANCE-SPOT-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST
- V0200-003-HTTPS-API-BINANCE-COM-ONLY
- V0200-003-READ-ONLY-PATH-ALLOWLIST
- V0200-003-QUERY-SHAPE-ALLOWLIST
- V0200-003-SIGNED-TRADING-ENDPOINTS-FORBIDDEN
- V0200-003-NO-ENDPOINT-CONNECTION
- V0200-003-NO-PRODUCTION-CUTOVER

## Scope

- 上游依赖：#1240 / GH-1240 `ReleaseV0200ProductionShadowEnvironmentProfile`。
- 当前 issue：#1241 / GH-1241。
- 下游 issue：#1242 / GH-1242。
- release：`v0.20.0`。
- queue：`GH-1239..GH-1250`。
- venue：`binance`。
- product：`spot`。
- environment：`productionShadow`。
- endpoint family：`https://api.binance.com`，来源于 v0.19.0 endpoint family registry。

## Read-only Allowlist

允许表达的 read-only path 仅限：

| kind | path | allowed query |
| --- | --- | --- |
| server-time | `/api/v3/time` | none |
| exchange-info | `/api/v3/exchangeInfo` | `symbol` / `symbols` |
| ticker-price | `/api/v3/ticker/price` | `symbol` |
| depth-snapshot | `/api/v3/depth` | `symbol` / `limit` |

这些 endpoint shape 只用于 readiness evidence。它们不是 URLRequest、transport、network run、response parser 或 production probe。

## Rejection Policy

必须拒绝：

- 非 HTTPS scheme。
- 非 `api.binance.com` host。
- 未列入 allowlist 的 path。
- 未列入 allowlist 的 query item。
- signed / trading query：`signature`、`timestamp`、`recvWindow`、`listenKey`、`orderId`、`origClientOrderId`、`newClientOrderId`、`apiKey`、`secret`。
- signed / trading path：`/api/v3/account`、`/api/v3/order`、`/api/v3/order/test`、`/api/v3/openOrders`、`/api/v3/allOrders`、`/api/v3/myTrades`、`/api/v3/userDataStream`。

## Boundary

- productionEndpointConnectionEnabled=false
- productionTradingEnabledByDefault=false
- productionSecretValueRead=false
- signedAccountEndpointRuntimeEnabled=false
- privateStreamRuntimeEnabled=false
- listenKeyRuntimeEnabled=false
- productionBrokerConnectionEnabled=false
- orderSubmitCancelReplaceEnabled=false
- spotCanaryEnabled=false
- futuresRuntimeEnabled=false
- okxActiveImplementationEnabled=false
- productionCutoverAuthorized=false
- createsTagOrRelease=false

## Validation

- `swift test --filter TargetGraphTests/testGH1241ReleaseV0200ProductionShadowEndpointReadOnlyAllowlist`
- `bash checks/verify-v0.20.0-production-shadow-endpoint-allowlist.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
