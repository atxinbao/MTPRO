# Release v0.20.0 Binance Spot Production-shadow Environment Profile Contract

日期：2026-06-30  
执行者：Codex

本文档固定 GH-1240 / V0200-002 的 production-shadow environment profile 合同。它只把 Binance Spot 的 production-shadow 身份、endpoint intent、credential profile reference、feature gates 和 operator-visible readiness state 固定为可验证 evidence；它不授权 production trading，不读取 production secret value，不连接 production endpoint / broker endpoint，不发送真实订单。

## Anchors

- GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE
- TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE
- V0200-002-BINANCE-SPOT-PRODUCTION-SHADOW-PROFILE
- V0200-002-CREDENTIAL-REFERENCE-NO-SECRET-VALUE
- V0200-002-ENDPOINT-INTENT-NO-CONNECTION
- V0200-002-OPERATOR-READINESS-STATE
- V0200-002-READ-ONLY-FAIL-CLOSED
- V0200-002-FUTURES-OKX-OUT-OF-SCOPE
- V0200-002-NO-PRODUCTION-CUTOVER

## Scope

- Issue: `#1240 / GH-1240`
- Upstream contract: `#1239 / GH-1239`
- Next dependent issue: `#1241 / GH-1241`
- Queue range: `GH-1239..GH-1250`
- Project: `MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness`
- Release version: `v0.20.0`
- Venue: `binance`
- Product: `spot`
- Environment: `productionShadow`
- Credential profile identity: `binance-spot-productionShadow-credential-profile-ref`
- Redacted evidence reference: `redacted-credential-profile:binance:spot:productionShadow`

## Contract

`ReleaseV0200ProductionShadowEnvironmentProfile` 必须保持以下事实：

- `venueID == .binance`
- `productKind == .spot`
- `tradingEnvironment == .productionShadow`
- `credentialProfileState == .productionShadow`
- `credentialIdentityOnly == true`
- `redactedEvidenceOnly == true`
- `endpointIntent == .readOnlyReferencePendingAllowlist`
- `operatorReadinessState == .profileRegisteredAwaitingReadOnlyEvidence`
- `productionTradingEnabledByDefault == false`
- `productionSecretValueRead == false`
- `productionSecretValueStored == false`
- `productionEndpointConnectionEnabled == false`
- `signedAccountEndpointRuntimeEnabled == false`
- `privateStreamRuntimeEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `orderSubmitCancelReplaceEnabled == false`
- `spotCanaryEnabled == false`
- `futuresRuntimeEnabled == false`
- `okxActiveImplementationEnabled == false`
- `dashboardTradingButtonEnabled == false`
- `orderFormEnabled == false`
- `liveCommandEnabled == false`
- `productionCutoverAuthorized == false`
- `createsTagOrRelease == false`

## Non-goals

- 不启用 production trading。
- 不读取 production secret value。
- 不保存 API key、secret、listen key、signature 或 raw credential material。
- 不连接 production endpoint / broker endpoint。
- 不实现 signed account endpoint runtime。
- 不实现 private stream runtime。
- 不实现 submit / cancel / replace。
- 不运行 Spot canary。
- 不引入 Binance USDⓈ-M Futures runtime。
- 不引入 OKX active implementation。
- 不新增 Dashboard trading button、live command 或 order form。
- 不创建 `v0.20.0` tag / GitHub Release。
- 不授权 production cutover。

## Validation

- focused test: `swift test --filter TargetGraphTests/testGH1240ReleaseV0200ProductionShadowEnvironmentProfile`
- focused verifier: `bash checks/verify-v0.20.0-production-shadow-environment-profile.sh`
- aggregate automation readiness: `bash checks/automation-readiness.sh`
- aggregate checks: `bash checks/run.sh`

## Boundary Evidence

GH-1240 只把 production-shadow profile 注册为 read-only readiness evidence。#1241 之后才能继续定义 read-only endpoint allowlist；即使 allowlist 后续存在，仍不等于 endpoint connection、signed account runtime、Spot canary 或 production cutover。任何 production secret value read、production endpoint connection、broker connection、order submit / cancel / replace、Dashboard command 或 cutover 都必须由后续独立 issue 和 Human gate 明确授权。
