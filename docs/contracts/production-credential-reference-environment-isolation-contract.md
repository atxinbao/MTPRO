# Production Credential Reference / Environment Isolation Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-644 PCHR-02 Harden credential reference and environment isolation runtime`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的 credential reference / environment isolation 合同。它只固定 credential identity、profile reference、dry-run / testnet / production environment 分离和 fail-closed evidence，不读取 production secret，不连接 production endpoint，不提交真实订单。

## PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME

`PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME`

GH-644 依赖 GH-643 的 runtime hardening contract。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCredentialReferenceEnvironmentIsolation.swift`
- `docs/contracts/production-cutover-runtime-hardening-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH644CredentialReferenceEnvironmentIsolationFailsClosedWithoutSecretRead`

合同固定：

- upstream issue 固定为 `GH-643`
- downstream issue 固定为 `GH-645`
- queue range 固定为 `GH-643..GH-649`
- `upstreamRuntimeHardeningContractHeld == true`
- `credentialIdentityOnlyRequired == true`
- `explicitEnvironmentSelectionRequired == true`
- `missingAuthorizationFailsClosed == true`
- `noProductionFallbackRequired == true`

## PCHR-02-CREDENTIAL-IDENTITY-PROFILE-REFERENCE

`PCHR-02-CREDENTIAL-IDENTITY-PROFILE-REFERENCE`

Credential handling 只能使用 identity / profile reference：

| Environment | Profile reference | Authorization state |
| --- | --- | --- |
| dry-run | local fixture profile reference | local fixture authorized |
| testnet | Binance testnet profile reference | testnet reference authorized |
| production blocked | production profile reference blocked | production missing authorization fail-closed |
| future production | future production profile reference | future production manual gate required |

Profile reference 不能携带 secret value、API key value、signed payload、account payload 或 broker credential。

## PCHR-02-DRYRUN-TESTNET-PRODUCTION-ENVIRONMENT-ISOLATION

`PCHR-02-DRYRUN-TESTNET-PRODUCTION-ENVIRONMENT-ISOLATION`

Dry-run、testnet、production blocked 和 future production 是四个不同 environment kind：

- dry-run 只允许本地 fixture / shadow evidence。
- testnet 只允许 testnet reference identity，不允许推导 production credential。
- production blocked 表示缺少生产授权时必须 fail closed。
- future production 只能作为后续人工 gate 的 reference，不是当前 runtime。

## PCHR-02-MISSING-AUTHORIZATION-FAIL-CLOSED

`PCHR-02-MISSING-AUTHORIZATION-FAIL-CLOSED`

缺少生产授权时必须 fail closed，不能降级为 testnet、不能升级为 production，也不能通过默认 profile 自动继续。

Required evidence：

- `missingAuthorizationFailsClosed == true`
- production blocked row 使用 `productionMissingFailClosed`
- future production row 使用 `futureProductionManualGateRequired`

## PCHR-02-NO-PRODUCTION-FALLBACK

`PCHR-02-NO-PRODUCTION-FALLBACK`

任何缺失、空白或模糊 environment selection 都不得回退到 production。

Required evidence：

- `defaultProductionEnvironmentSelected == false`
- `ambiguousEnvironmentFallsBackToProduction == false`
- `allowsProductionFallback == false`

## PCHR-02-NO-PRODUCTION-SECRET-VALUE-READ

`PCHR-02-NO-PRODUCTION-SECRET-VALUE-READ`

GH-644 不读取、探测、打印、缓存、保存或传递 production secret value。

Required evidence：

- `readsProductionSecretValue == false`
- `probesEnvironmentSecret == false`
- `storesSecretValue == false`
- `productionEndpointAutoConnectEnabled == false`
- `realBrokerConnectionEnabled == false`
- `realOrderSubmissionEnabled == false`

## TVM-PCHR-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION

`TVM-PCHR-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION`

Required validation：

- `swift test --filter TargetGraphTests/testGH644CredentialReferenceEnvironmentIsolationFailsClosedWithoutSecretRead`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-02 Non-authorization

GH-644 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- environment secret probe。
- default production environment。
- production fallback。
- production endpoint auto-connect。
- broker adapter / real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- CommandGateway / RiskEngine / ExecutionEngine / OMS bypass。
- 下一阶段 Project / Issue 自动启动。
