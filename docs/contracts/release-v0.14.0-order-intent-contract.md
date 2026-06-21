# MTPRO Release v0.14.0 OrderIntent Contract

日期：2026-06-21

执行者：Codex

## GH-1025-ORDERINTENT-CANONICAL-CONTRACT

`OrderIntent` 是 v0.14.0 testnet trading closed loop 的 Strategy Signal -> RiskEngine -> ExecutionEngine 中性合同。

它只表达：

- Binance venue。
- Spot + USDⓈ-M Perpetual product types。
- EMA + RSI active strategy source。
- deterministic `intentID`。
- side、quantity、time-in-force / intent policy。
- Strategy Signal / Message / Run / correlation metadata。

## GH-1025-ORDERINTENT-RISK-GATE-BOUNDARY

`OrderIntent` 必须保持 pre-RiskEngine 语义：

- `requiresRiskEngineApproval == true`
- `authorizesProductionTrading == false`
- `authorizesDirectExecution == false`
- `productionTradingEnabledByDefault == false`
- `representsProductionOrder == false`
- `bypassesRiskEngine == false`
- `touchesBrokerEndpoint == false`

该合同不提交、取消或替换订单，不连接 broker，不读取 production secret，不连接 production endpoint，也不授权 production cutover。

## GH-1025-ORDERINTENT-ACTIVE-SCOPE

v0.14.0 active scope 固定为：

- active venue: Binance
- active products: Spot、USDⓈ-M Perpetual
- active strategies: EMA、RSI

任何非 Binance venue、非 Spot / USDⓈ-M Perpetual product、非 EMA / RSI active strategy、production order、direct execution 或 RiskEngine bypass 都必须 fail closed。

## Validation

- `swift test --filter TargetGraphTests/testGH1025ReleaseV0140OrderIntentCanonicalContractRequiresRiskGateAndBoundary`
- `bash checks/verify-v0.14.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
