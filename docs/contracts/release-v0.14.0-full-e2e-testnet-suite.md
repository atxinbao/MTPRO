# Release v0.14.0 Full E2E Testnet Suite Contract

日期：2026-06-21  
执行者：Codex

## Scope

`GH-1038-FULL-E2E-TESTNET-SUITE` 固定 v0.14.0 的完整本地 testnet 闭环验证套件：

Strategy Signal -> OrderIntent -> RiskEngine -> ExecutionContract -> Binance testnet adapter evidence -> OMS Event Log -> Reconciliation -> Read-only Dashboard input。

该套件只覆盖 Binance、Spot + USDⓈ-M Perpetual、EMA + RSI。它复用既有 signal-to-execution pipeline，不新增生产交易授权、不读取生产 secret、不连接 production / broker endpoint，也不发送真实订单。

## Rules

- `GH-1038-SPOT-PERP-EMA-RSI-MATRIX`：必须覆盖 Spot / USDⓈ-M Perpetual 与 EMA / RSI 的 4 个组合。
- 每个组合必须通过完整本地 pipeline，并形成 passed report。
- passed report 必须覆盖 Strategy Signal、OrderIntent、RiskEngine、ExecutionContract、Binance testnet adapter evidence、OMS local order store、Order Event Log、OMS State Sync 和 Reconciliation。
- `GH-1038-PRODUCTION-GUARDS`：production trading requested guard 必须 failed closed，并证明 adapter、OMS event log 和 reconciliation 都没有被触达。
- read-only dashboard 只能消费 report input；本 issue 不新增 Dashboard trading button、production order form 或 live command surface。

## Boundary

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionSubmitCancelReplace=false`
- Binance 是唯一 active venue。
- Spot + USDⓈ-M Perpetual 是唯一 active product set。
- EMA + RSI 是唯一 active strategy set。
- testnet behavior 只生成 redacted / local evidence；不执行真实网络 submit、cancel 或 replace。

## Validation Anchors

- `GH-1038-FULL-E2E-TESTNET-SUITE`
- `GH-1038-SPOT-PERP-EMA-RSI-MATRIX`
- `GH-1038-PRODUCTION-GUARDS`
- `TVM-RELEASE-V0140-FULL-E2E-TESTNET-SUITE`

## Verification

- `checks/verify-v0.14.0-full-e2e-testnet-suite.sh`
- `TargetGraphTests/testGH1038ReleaseV0140FullE2ETestnetSuiteCoversSpotPerpEMAAndRSIWithProductionGuard`
