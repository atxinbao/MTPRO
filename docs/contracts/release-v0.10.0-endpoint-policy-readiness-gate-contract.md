# Release v0.10.0 Endpoint Policy Readiness Gate Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-882 V0100-005 Add EndpointPolicyReadinessGate`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 endpoint policy readiness / 端点策略就绪合同。它只证明 testnet endpoint allowlist、production endpoint allowlist、environment binding、host validation、scheme validation、forbidden fallback 和 no silent fallback policy 已可审计。它不连接 production endpoint 或 broker endpoint，不读取 production secret value，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command，也不授权 production cutover。

## V0100-005-ENDPOINT-POLICY-READINESS-GATE

`V0100-005-ENDPOINT-POLICY-READINESS-GATE`

GH-882 的 EndpointPolicyReadinessGate schema 固定为：

- `endpoint_policy_readiness.json`
- `endpoint_policy_readiness_evidence_exists=true`
- `production_endpoint_connected=false`
- `fallback_to_production=false`
- `testnet_to_production_fallback_forbidden=true`
- `no_silent_fallback_required=true`
- `cutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `productionBrokerConnectionEnabled=false`

该 gate 只能作为 readiness evidence 输入，不能被解释为 production endpoint connection permission、broker connection permission 或 trading permission。

## V0100-005-TESTNET-ENDPOINT-ALLOWLIST

`V0100-005-TESTNET-ENDPOINT-ALLOWLIST`

Testnet endpoint allowlist 固定为：

- `environment=testnet`
- `testnetEndpointHost=testnet.binance.vision`
- `testnetEndpointHost=testnet.binancefuture.com`
- `scheme=https`
- `productTypes=spot,usdsPerpetual`
- `endpointConnectionAllowed=false`

Testnet allowlist 只证明 host 和 product binding policy 存在，不授权 testnet submit / cancel / replace，也不授权从 testnet fallback 到 production。

## V0100-005-PRODUCTION-ENDPOINT-ALLOWLIST

`V0100-005-PRODUCTION-ENDPOINT-ALLOWLIST`

Production endpoint allowlist 固定为：

- `environment=production`
- `productionEndpointHost=api.binance.com`
- `productionEndpointHost=fapi.binance.com`
- `scheme=https`
- `productTypes=spot,usdsPerpetual`
- `endpointConnectionAllowed=false`

Production allowlist 只是 operator readiness policy evidence。它不打开 production endpoint connection，不打开 broker connection，不读取 production secret，也不授权 production cutover。

## V0100-005-ENVIRONMENT-BINDING

`V0100-005-ENVIRONMENT-BINDING`

每条 endpoint policy row 必须绑定明确环境：

- `environmentBound=true`
- `environment=testnet`
- `environment=production`

禁止把缺省环境、空环境或 unknown host 静默映射到 production。

## V0100-005-HOST-VALIDATION

`V0100-005-HOST-VALIDATION`

Host validation 固定为 required：

- `hostValidationRequired=true`
- `invalidEndpointHostAccepted=false`

Endpoint policy 必须拒绝非 allowlist host，且 testnet allowlist 与 production allowlist 不能互相 fallback。

## V0100-005-SCHEME-VALIDATION

`V0100-005-SCHEME-VALIDATION`

Scheme validation 固定为 required：

- `scheme=https`
- `schemeValidationRequired=true`
- `invalidEndpointSchemeAccepted=false`

HTTP、自定义 scheme、userinfo、secret-bearing URL 或非 canonical endpoint shape 不得成为 readiness evidence。

## V0100-005-NO-SILENT-FALLBACK

`V0100-005-NO-SILENT-FALLBACK`

Fallback policy 固定为：

- `fallback_to_production=false`
- `testnet_to_production_fallback_forbidden=true`
- `no_silent_fallback_required=true`

任何 testnet endpoint 缺失、host validation 失败或 scheme validation 失败都必须 fail closed，不能静默切到 production。

## V0100-005-ENDPOINT-POLICY-READINESS-JSON

`V0100-005-ENDPOINT-POLICY-READINESS-JSON`

GH-882 必须定义 `endpoint_policy_readiness.json` evidence 文件名：

- `endpoint_policy_readiness.json`
- `endpoint_policy_readiness_evidence_exists=true`
- `endpoint_policy_readiness_contains_endpoint_response=false`
- `endpoint_policy_readiness_produced_by_connection=false`

该 evidence 只证明 policy readiness，不证明 runtime 连接 endpoint，也不包含 endpoint response、secret、listenKey 或 broker session。

## V0100-005-PRODUCTION-CAPABILITIES-DISABLED

`V0100-005-PRODUCTION-CAPABILITIES-DISABLED`

Production capability 在 GH-882 中固定 disabled：

- `productionSecretValueRead=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`

任何 endpoint allowlist、host validation 或 scheme validation evidence 都不能转换成 production trading permission。

## V0100-005-VALIDATION-MATRIX

`V0100-005-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-882-VERIFY-V0100-ENDPOINT-POLICY-READINESS-GATE`
- `TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE`
- `checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh`
- `testGH882EndpointPolicyReadinessGateRejectsProductionConnectionAndSilentFallback`

Validation 必须证明：

- testnet endpoint allowlist、production endpoint allowlist、environment binding、host validation 和 scheme validation 均存在；
- `endpoint_policy_readiness.json` evidence 文件名存在；
- `production_endpoint_connected=false`、`fallback_to_production=false` 和 `testnet_to_production_fallback_forbidden=true`；
- endpoint readiness evidence 不来自 network connection，不包含 endpoint response；
- cutover、order submission、production broker connection、secret read 和 UI command 全部保持 false。
