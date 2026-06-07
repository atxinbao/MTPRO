# Production Cutover Credential / Secret Policy Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-503 Define credential / secret policy cutover gate`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 credential / secret policy gate。它只提供 production cutover 前的 readiness evidence，不读取真实 secret，不保存 API key，不连接 signed endpoint / account endpoint / listenKey，不连接 broker，不实现 ExecutionClient adapter、OMS、LiveExecutionAdapter 或真实 submit / cancel / replace。

## GH-503-PRODUCTION-CUTOVER-CREDENTIAL-SECRET-POLICY-GATE

`GH-503-PRODUCTION-CUTOVER-CREDENTIAL-SECRET-POLICY-GATE`

GH-503 是该 Project 的第一个 gate，固定 queue range `GH-503..GH-510`。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverCredentialSecretPolicyGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH503ProductionCredentialSecretPolicyGateDefinesNoDefaultSecretReadContract`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH503ProductionCredentialSecretPolicyGateRejectsSecretReadAndProductionPromotion`

合同固定：

- `noDefaultSecretReadRequired == true`
- `localFixtureDryRunProductionIsolationRequired == true`
- `secretStorageFutureGateOnly == true`
- `secretInjectionRotationFutureGateOnly == true`
- `productionBlockedByDefault == true`
- 所有 forbidden runtime flags 必须为 false。

## GH-503-NO-DEFAULT-SECRET-READ

`GH-503-NO-DEFAULT-SECRET-READ`

默认环境不得读取、探测、打印或保存 production secret。以下行为全部保持 forbidden：

- default secret read
- environment secret probe
- plaintext credential in repository
- API key / API secret storage
- API-key header construction
- request signature generation

## GH-503-LOCAL-FIXTURE-DRY-RUN-PRODUCTION-ISOLATION

`GH-503-LOCAL-FIXTURE-DRY-RUN-PRODUCTION-ISOLATION`

Local fixture、dry-run、production-blocked 和 future production credential 是四个不同 scope：

| Scope | 当前含义 | 禁止事项 |
| --- | --- | --- |
| local fixture | 本地 deterministic evidence | 不读取 secret value |
| dry-run | 不联网、不下单的演练证据 | 不推导 production credential path |
| production blocked | production 默认 blocked | 不加载 production credential |
| future production credential | 后续 cutover gate 输入 | 当前不实现 secret storage / injection / rotation |

Sandbox command 不能升级为 production command，也不能通过 dry-run 推导 production credential path。

## GH-503-FUTURE-SECRET-STORAGE-INJECTION-ROTATION-GATE

`GH-503-FUTURE-SECRET-STORAGE-INJECTION-ROTATION-GATE`

Secret storage、secret injection 和 rotation 只能作为 future gate 记录。GH-503 不实现：

- secret store
- credential provider
- key rotation service
- signed request builder
- account endpoint client
- listenKey lifecycle
- broker credential runtime

## GH-503-PRODUCTION-BLOCKED-EVIDENCE

`GH-503-PRODUCTION-BLOCKED-EVIDENCE`

Production cutover 前必须保留 blocked evidence：

- `productionTradingEnabledByDefault == false`
- `connectsBroker == false`
- `callsSignedEndpoint == false`
- `callsAccountEndpoint == false`
- `createsListenKey == false`
- `submitsRealOrder == false`
- `cancelsRealOrder == false`
- `replacesRealOrder == false`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
