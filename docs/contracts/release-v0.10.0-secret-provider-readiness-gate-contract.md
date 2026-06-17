# Release v0.10.0 Secret Provider Readiness Gate Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-881 V0100-004 Add SecretProviderReadinessGate`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 secret provider reference readiness / 密钥提供方引用就绪合同。它只证明 credential reference、provider type、redaction policy、operator confirmation requirement 和两个 evidence 文件名。它不读取 production secret value，不保存 secret value，不把 secret 暴露到 CI、Dashboard 或日志，不连接 production endpoint / broker endpoint，不授权 production cutover，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command。

## V0100-004-SECRET-PROVIDER-READINESS-GATE

`V0100-004-SECRET-PROVIDER-READINESS-GATE`

GH-881 的 SecretProviderReadinessGate schema 固定为：

- `credentialReferenceExists=true`
- `providerType=environmentVariableReference`
- `providerType=keychainItemReference`
- `providerType=operatorManualReference`
- `redactionPolicy=redactedIdentifierOnly`
- `ci_no_secret_proof=true`
- `manual_secret_gate_required=true`
- `cutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `productionEndpointConnectionEnabled=false`

该 gate 只能作为 readiness evidence 输入，不能被解释为 secret availability、production credential approval 或 production trading permission。

## V0100-004-CREDENTIAL-REFERENCE-EXISTS

`V0100-004-CREDENTIAL-REFERENCE-EXISTS`

Credential reference 只证明引用 identity 存在：

- `v0.10.0-env-var-secret-provider-ref`
- `v0.10.0-keychain-secret-provider-ref`
- `v0.10.0-operator-manual-secret-provider-ref`

Reference row 必须满足：

- `credentialReferenceExists=true`
- `storesSecretValue=false`
- `readsSecretValue=false`
- `printsSecretValue=false`
- `dashboardDisplaysSecretValue=false`
- `ciSecretAvailable=false`

禁止把 secret value、resolved credential、broker credential、listenKey、API key、API secret 或 signed request payload 持久化到 readiness gate。

## V0100-004-PROVIDER-TYPE-REFERENCE-ONLY

`V0100-004-PROVIDER-TYPE-REFERENCE-ONLY`

Provider type 只允许记录引用类型：

- `providerType=environmentVariableReference`
- `providerType=keychainItemReference`
- `providerType=operatorManualReference`

Provider type 不代表 provider 已解密、不代表 secret 已可读、不代表 CI 拥有 secret，也不代表 production endpoint 可以连接。

## V0100-004-REDACTION-POLICY-REQUIRED

`V0100-004-REDACTION-POLICY-REQUIRED`

Redaction policy 固定为：

- `redactionPolicy=redactedIdentifierOnly`

所有 readiness evidence 只能显示 redacted identifier、provider type 和 policy reference。禁止显示 secret body、secret prefix、secret suffix、签名 payload、header value 或 account endpoint response。

## V0100-004-SECRET-READINESS-JSON

`V0100-004-SECRET-READINESS-JSON`

GH-881 必须定义 `secret_readiness.json` evidence 文件名：

- `secret_readiness.json`
- `secret_readiness_evidence_exists=true`
- `secret_readiness_contains_secret_value=false`
- `secret_readiness_produced_by_ci=false`

该 evidence 只证明 reference layer ready，不证明 CI 或 runtime 可以读取真实 secret。

## V0100-004-REDACTION-PROOF-JSON

`V0100-004-REDACTION-PROOF-JSON`

GH-881 必须定义 `redaction_proof.json` evidence 文件名：

- `redaction_proof.json`
- `redaction_proof_evidence_exists=true`
- `redaction_proof_contains_secret_value=false`
- `redaction_proof_produced_by_ci=false`

该 evidence 只证明 redaction policy 生效，不允许携带任何 secret value 或 endpoint response。

## V0100-004-CI-NO-SECRET-PROOF

`V0100-004-CI-NO-SECRET-PROOF`

CI lane 固定为 no-secret proof：

- `ci_no_secret_proof=true`
- `ciSecretAvailable=false`

CI 可以验证 contract、redaction 和 no-secret boundary，但不得要求、读取、打印或缓存 production secret。

## V0100-004-MANUAL-SECRET-GATE-REQUIRED

`V0100-004-MANUAL-SECRET-GATE-REQUIRED`

Manual gate 固定为 required：

- `manual_secret_gate_required=true`
- `operatorConfirmationRequired=true`

Manual secret gate 只是后续人工确认输入要求，不授权 production cutover，不打开 endpoint connection，不创建 order command。

## V0100-004-PRODUCTION-CAPABILITIES-DISABLED

`V0100-004-PRODUCTION-CAPABILITIES-DISABLED`

Production capability 在 GH-881 中固定 disabled：

- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `productionSecretValueStored=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`

任何 credential reference 存在、provider type 存在、redaction proof 存在或 manual gate required 都不能转换成 production trading permission。

## V0100-004-VALIDATION-MATRIX

`V0100-004-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-881-VERIFY-V0100-SECRET-PROVIDER-READINESS-GATE`
- `TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE`
- `checks/verify-v0.10.0-secret-provider-readiness-gate.sh`
- `testGH881SecretProviderReadinessGateKeepsSecretsOutOfRuntimeCIDashboardAndEvidence`

Validation 必须证明：

- credential reference、provider type 和 redaction policy 都以 reference-only 方式保存；
- `secret_readiness.json` 和 `redaction_proof.json` evidence 文件名存在；
- `ci_no_secret_proof=true` 和 `manual_secret_gate_required=true`；
- secret value 不进入 persistence、CI、Dashboard、日志或 evidence；
- cutover、order submission、production endpoint connection 和 broker connection 全部保持 false。
