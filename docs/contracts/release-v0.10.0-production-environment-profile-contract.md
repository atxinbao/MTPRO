# Release v0.10.0 Production Environment Profile Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-880 V0100-003 Add ProductionEnvironmentProfile contract`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 production environment profile / 生产环境画像合同。它只持久化 endpoint / secret / risk policy 的引用，不保存 secret value，不连接 production endpoint 或 broker endpoint，不授权 production cutover，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command。

## V0100-003-PRODUCTION-ENVIRONMENT-PROFILE-CONTRACT

`V0100-003-PRODUCTION-ENVIRONMENT-PROFILE-CONTRACT`

GH-880 的 profile schema 固定为：

- `environment=production`
- `venue=Binance`
- `productTypes=spot,usdsPerpetual`
- `endpointPolicyRef=v0.10.0-production-endpoint-policy-ref`
- `secretPolicyRef=v0.10.0-production-secret-policy-ref`
- `riskPolicyRef=v0.10.0-production-risk-policy-ref`
- `referencesOnlyPersisted=true`
- `cutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `productionEndpointConnectionEnabled=false`

该 profile 只能作为 readiness evidence 输入，不能被解释为 production trading permission。

## V0100-003-REFERENCE-ONLY-POLICY-REFS

`V0100-003-REFERENCE-ONLY-POLICY-REFS`

Profile 只保存 policy reference identity：

- `V0100-003-ENDPOINT-POLICY-REFERENCE`
- `V0100-003-SECRET-POLICY-REFERENCE`
- `V0100-003-RISK-POLICY-REFERENCE`

Reference row 必须满足：

- `storesResolvedValue=false`
- `readsSecretValue=false`
- `connectsEndpoint=false`
- `enablesOrderSubmission=false`

禁止把 secret value、endpoint URL、broker credential、risk threshold body 或 order command payload 持久化到 profile。

## V0100-003-BINANCE-SPOT-USDSM-PERPETUAL-SCOPE

`V0100-003-BINANCE-SPOT-USDSM-PERPETUAL-SCOPE`

GH-880 只允许 Binance venue readiness profile，产品范围固定为：

- `spot`
- `usdsPerpetual`

不允许 non-Binance venue，不允许新增非 v0.10.0 scope product type，不允许用 profile 扩大到 production broker adapter。

## V0100-003-PRODUCTION-CUTOVER-DISABLED

`V0100-003-PRODUCTION-CUTOVER-DISABLED`

Production cutover 在 GH-880 中固定为 disabled：

- `cutoverAuthorized=false`
- `productionTradingEnabledByDefault=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `productionSecretValueStored=false`

任何 readiness pass、policy reference 存在或 profile 完整都不能转换成 cutover authorization。

## V0100-003-ORDER-SUBMISSION-DISABLED

`V0100-003-ORDER-SUBMISSION-DISABLED`

Order path 在 GH-880 中固定为 disabled：

- `orderSubmissionEnabled=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`

GH-880 不创建 submit / cancel / replace runtime，不创建 production OMS，不创建 Dashboard trading surface。

## V0100-003-PRODUCTION-ENDPOINT-CONNECTION-DISABLED

`V0100-003-PRODUCTION-ENDPOINT-CONNECTION-DISABLED`

Endpoint path 在 GH-880 中固定为 disabled：

- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`

Profile 可以引用 future endpoint policy，但不能解析、连接、探测或 fallback 到 production endpoint。

## V0100-003-VALIDATION-MATRIX

`V0100-003-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-880-VERIFY-V0100-PRODUCTION-ENVIRONMENT-PROFILE`
- `TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE`
- `checks/verify-v0.10.0-production-environment-profile.sh`
- `testGH880ProductionEnvironmentProfilePersistsReferencesOnlyAndKeepsProductionDisabled`

Validation 必须证明：

- ProductionEnvironmentProfile 只保存 reference identity；
- Binance / spot / usdsPerpetual scope 固定；
- cutover、order submission、production endpoint connection 全部保持 false；
- profile 完整不授权 production cutover 或 order path。
