# Release v0.6.0 Testnet Read-only Probe Contract

日期：2026-06-15

执行者：Codex

## Scope

GH-765 增加一个 guarded Binance testnet read-only probe。该 probe 只在调用方显式提供 operator confirmation、`binance-testnet-readonly` profile、testnet endpoint 和 approved credential reference/material 后，生成 signed account read-only snapshot artifact。

Probe 的 private stream / account snapshot 部分保持 simulated read-model：它可以把 signed snapshot 和本地 fixture event 映射为 account snapshot read model，但不打开 WebSocket，不启动 listenKey lifecycle，不连接 production endpoint，不提交、取消或替换订单。

## Validation Anchors

- `V060-011-TESTNET-READ-ONLY-PROBE`
- `V060-011-OPERATOR-CONFIRMED-TESTNET-PROFILE`
- `V060-011-TESTNET-ENDPOINT-ALLOWLIST-PRODUCTION-REJECTION`
- `V060-011-SIGNED-ACCOUNT-SNAPSHOT-ARTIFACT`
- `V060-011-CREDENTIAL-REDACTION-DASHBOARD-CLI`
- `V060-011-PRIVATE-STREAM-SIMULATED-READMODEL-NO-WEBSOCKET`
- `V060-011-NO-ORDER-NO-PRODUCTION-BOUNDARY`
- `TVM-RELEASE-V060-TESTNET-READONLY-PROBE`

## Probe Contract

`ReleaseV060TestnetReadOnlyProbe` 的入口必须满足：

- `operatorConfirmedReadOnlyProbe=true`
- `profileName=binance-testnet-readonly`
- endpoint host 属于 testnet allowlist：`testnet.binance.vision` 或 `testnet.binancefuture.com`
- production endpoint host 必须 hard reject：`api.binance.com`、`fapi.binance.com`、`dapi.binance.com`
- credential value 只能通过调用方注入的短生命周期 provider 进入 request，不进入 artifact、Dashboard row 或 CLI output
- artifact 只保存 credential reference 和 redacted credential reference

## CLI / Dashboard Redaction

`mtpro testnet-readonly-probe` 只输出 deterministic read-only fixture evidence，用来证明 CLI shape 和 redaction contract。它不读取环境变量、keychain、production secret 或 production endpoint。

Dashboard 只能消费 `ReleaseV060TestnetReadOnlyProbeDashboardRow` 形态的 read-model rows。Rows 必须保持：

- `readModelOnly=true`
- `redacted=true`
- `commandSurfaceEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`

## Boundary

GH-765 不授权：

- production trading
- production secret auto-read
- production endpoint auto-connect
- broker execution
- OMS lifecycle creation
- real submit / cancel / replace
- trading button
- order form
- production cutover

Required boundary flags：

- `productionTradingEnabledByDefault=false`
- `productionSecretAutoReadEnabled=false`
- `productionEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
