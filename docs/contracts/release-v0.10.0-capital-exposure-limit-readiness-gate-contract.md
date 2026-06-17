# Release v0.10.0 Capital / Exposure Limit Readiness Gate Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-883 V0100-006 Add capital and exposure limit readiness gate`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 capital / exposure limit readiness / 资本与敞口限制就绪合同。它只证明生产切换前需要人工复核的资本、名义金额、单笔名义金额、symbol 敞口、product 敞口、日亏损、未结订单数、杠杆、allowed symbols、allowed product types 和 risk policy hash binding 已形成 deterministic evidence。它不连接 production endpoint 或 broker endpoint，不读取 production secret value，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command，也不授权 production cutover。

## V0100-006-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE

`V0100-006-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE`

GH-883 的 CapitalExposureLimitReadinessGate schema 固定为：

- `capital_exposure_limits.json`
- `capital_exposure_limits_evidence_exists=true`
- `risk_policy_hash_bound=true`
- `operator_review_required=true`
- `order_submission_enabled=false`
- `orderSubmissionEnabled=false`
- `cutoverAuthorized=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`

该 gate 只能作为 readiness evidence 输入，不能被解释为 production cutover approval、broker connection permission 或 trading permission。

## V0100-006-MAX-CAPITAL-LIMIT

`V0100-006-MAX-CAPITAL-LIMIT`

Capital limit 固定为：

- `maxCapital=100000.00`

该值只用于生产切换前人工复核和 readiness matrix，不授权资金调拨、account mutation 或 order submit。

## V0100-006-MAX-NOTIONAL-LIMIT

`V0100-006-MAX-NOTIONAL-LIMIT`

Notional limit 固定为：

- `maxNotional=25000.00`

该值只证明 policy evidence 存在，不创建 ExecutionEngine / OMS submit path。

## V0100-006-MAX-SINGLE-ORDER-NOTIONAL-LIMIT

`V0100-006-MAX-SINGLE-ORDER-NOTIONAL-LIMIT`

Single order notional limit 固定为：

- `maxSingleOrderNotional=5000.00`

该值不授权任何 testnet 或 production submit / cancel / replace。

## V0100-006-MAX-SYMBOL-EXPOSURE-LIMIT

`V0100-006-MAX-SYMBOL-EXPOSURE-LIMIT`

Symbol exposure limit 固定为：

- `maxSymbolExposure=15000.00`

该值只作为 operator review input，不连接 broker，不读取 account endpoint。

## V0100-006-MAX-PRODUCT-EXPOSURE-LIMIT

`V0100-006-MAX-PRODUCT-EXPOSURE-LIMIT`

Product exposure limit 固定为：

- `maxProductExposure=50000.00`

该值只约束 readiness evidence，不授权 Spot 或 USDⓈ-M Perpetual 交易路径。

## V0100-006-MAX-DAILY-LOSS-LIMIT

`V0100-006-MAX-DAILY-LOSS-LIMIT`

Daily loss limit 固定为：

- `maxDailyLoss=2500.00`

该值不触发 automated stop、broker command、incident command 或 trading adjustment。

## V0100-006-MAX-OPEN-ORDERS-LEVERAGE-LIMIT

`V0100-006-MAX-OPEN-ORDERS-LEVERAGE-LIMIT`

Open orders / leverage limits 固定为：

- `maxOpenOrders=10`
- `maxLeverage=3.0`

这些值只进入 `capital_exposure_limits.json` readiness evidence，不启用 production OMS 或 leverage mutation。

## V0100-006-ALLOWED-SYMBOLS-PRODUCT-TYPES

`V0100-006-ALLOWED-SYMBOLS-PRODUCT-TYPES`

Allowed universe 固定为：

- `allowedSymbols=BTCUSDT,ETHUSDT`
- `allowedProductTypes=spot,usdsPerpetual`

Allowed symbols / product types 只是 readiness allowlist，不等于交易授权，也不打开 endpoint connection。

## V0100-006-RISK-POLICY-HASH-BINDING

`V0100-006-RISK-POLICY-HASH-BINDING`

Risk policy identity 固定为：

- `riskPolicyID=v0.10.0-capital-exposure-risk-policy`
- `riskPolicyVersion=v0.10.0-production-readiness`
- `riskPolicyHashAlgorithm=sha256`
- `riskPolicyHash=sha256:v0100-capital-exposure-risk-policy-reference`
- `risk_policy_hash_bound=true`

Risk policy hash 只证明 limit evidence 绑定了固定 policy identity，不授权 production cutover，不创建 order path。

## V0100-006-CAPITAL-EXPOSURE-LIMITS-JSON

`V0100-006-CAPITAL-EXPOSURE-LIMITS-JSON`

GH-883 必须定义 `capital_exposure_limits.json` evidence 文件名：

- `capital_exposure_limits.json`
- `capital_exposure_limits_evidence_exists=true`
- `capital_exposure_limits_contains_broker_or_account_response=false`
- `capital_exposure_limits_produced_by_endpoint_connection=false`

该 evidence 不包含 broker response、account response、secret、listenKey、endpoint payload 或 order response。

## V0100-006-PRODUCTION-CAPABILITIES-DISABLED

`V0100-006-PRODUCTION-CAPABILITIES-DISABLED`

Production capability 在 GH-883 中固定 disabled：

- `testnetOrderSubmissionEnabled=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`
- `capitalExposureLimitBypassEnabled=false`
- `productionSecretValueRead=false`

任何 capital / exposure limit、allowed symbol、allowed product type 或 risk policy hash evidence 都不能转换成 production trading permission。

## V0100-006-VALIDATION-MATRIX

`V0100-006-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-883-VERIFY-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE`
- `TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE`
- `checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh`
- `testGH883CapitalExposureLimitReadinessGateBindsRiskPolicyAndDisablesOrders`

Validation 必须证明：

- maxCapital、maxNotional、maxSingleOrderNotional、maxSymbolExposure、maxProductExposure、maxDailyLoss、maxOpenOrders、maxLeverage、allowedSymbols 和 allowedProductTypes 均存在；
- `capital_exposure_limits.json` evidence 文件名存在；
- `risk_policy_hash_bound=true` 和 `operator_review_required=true`；
- `order_submission_enabled=false`；
- endpoint connection、broker connection、secret read、cutover、order submission、production OMS 和 UI command 全部保持 false。
