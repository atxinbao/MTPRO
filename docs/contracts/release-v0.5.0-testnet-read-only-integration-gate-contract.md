# Release v0.5.0 Testnet Read-only Integration Gate Contract

日期：2026-06-14

执行者：Codex

## Scope

`V050-08-TESTNET-READ-ONLY-INTEGRATION-GATE` 固定 GH-733 的 testnet read-only integration gate。该 gate 只把 GH-728 `EnvironmentProfile` / `EndpointPolicy` / `SecretProfileRef` evidence 和 GH-525 / GH-526 DataClient read-model identity 组合成本地可验证证据。

该合同不创建真实 network connector，不读取 secret value，不打开 production endpoint，不创建 broker gateway，不创建 OMS lifecycle，不提交、取消或替换真实订单。

## Contract Anchors

- `V050-08-TESTNET-READ-ONLY-INTEGRATION-GATE`
- `V050-08-EXPLICIT-TESTNET-PROFILE-REQUIRED`
- `V050-08-PRODUCTION-BLOCKED-REJECTS-READMODEL-RESOLUTION`
- `V050-08-REDACTED-EVIDENCE-NO-SUBMIT-PROOF`
- `TVM-RELEASE-V050-TESTNET-READONLY-INTEGRATION-GATE`

## Required Evidence

- `Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift`
- `ReleaseV050TestnetReadOnlyIntegrationGateContract`
- `ReleaseV050TestnetReadOnlyIntegrationGate`
- `ReleaseV050TestnetReadOnlyIntegrationEvidence`
- `ReleaseV050TestnetReadOnlyNoSubmitProof`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 中的 `testGH733TestnetReadOnlyIntegrationGateRequiresExplicitProfileAndNoSubmitProof`
- `checks/verify-v0.5.0-testnet-readonly.sh`

## Validation

GH-733 required validation：

- `swift test --filter TargetGraphTests/testGH733TestnetReadOnlyIntegrationGateRequiresExplicitProfileAndNoSubmitProof`
- `bash checks/verify-v0.5.0-testnet-readonly.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`V050-08-EXPLICIT-TESTNET-PROFILE-REQUIRED` 要求 gate 默认 fail-closed。只有显式 `testnet-guarded` profile 可以解析 signed account read-only 和 private stream account snapshot read-model route。

`V050-08-PRODUCTION-BLOCKED-REJECTS-READMODEL-RESOLUTION` 要求 `production-blocked` profile 和 production host 都被拒绝，不能 fallback 到 production endpoint、production secret 或 production broker。

`V050-08-REDACTED-EVIDENCE-NO-SUBMIT-PROOF` 要求 output 只包含 redacted secret profile reference 和 no-submit proof。No-submit proof 必须保持：

- `orderLifecycleCreated=false`
- `submitCommandEnabled=false`
- `cancelCommandEnabled=false`
- `replaceCommandEnabled=false`
- `brokerGatewayConnected=false`
- `omsStateCreated=false`
- `productionTradingEnabledByDefault=false`

## Non-goals

- 不读取 production secret。
- 不连接 production endpoint。
- 不连接真实 testnet 或 production broker endpoint。
- 不发送真实 order。
- 不实现 RiskEngine runtime runner。
- 不实现 ExecutionEngine / OMS lifecycle。
- 不实现 Portfolio projection。
- 不实现 Dashboard / CLI observer。
- 不授权 production cutover。
