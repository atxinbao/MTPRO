# Release v0.17.0 Operator Beta Artifact Bundle Replay Validator Contract

日期：2026-06-27

执行者：Codex

本文档服务 GitHub fallback issue `#1140 / GH-1140 Add real artifact bundle ingest / replay validator`。

GH-1140 在 GH-1139 定义的 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 边界内执行。它只允许从本地 operator beta artifact bundle 读取 redacted evidence，执行 schema / checksum / action sequence / reconciliation 校验，并输出确定性的 pass/fail read model。GH-1140 不读取 credential value，不连接 testnet / production endpoint，不提交 testnet 或 production order，不创建 tag / GitHub Release，不授权 production cutover。

## V0170-002-REAL-ARTIFACT-BUNDLE-INGEST

`V0170-002-REAL-ARTIFACT-BUNDLE-INGEST`

Validator 必须读取调用方显式传入的本地 artifact storage root 和 run id。它复用 v0.16.0 local execution artifact store 的 manifest、record 和 replay model，不自建第二套 bundle 格式。

允许证据：

- redacted run id
- manifest path
- manifest checksum
- record checksum list
- artifact kind sequence
- deterministic validation failures

禁止证据：

- API key / secret value
- listenKey
- signature value
- raw request payload
- raw response payload
- raw broker payload
- raw order identity
- production endpoint marker

## V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION

`V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION`

Validator 必须通过 v0.16.0 artifact store 完成 schema decode、manifest replay 和 checksum chain 校验。任何 schema decode、bundle read、manifest mismatch、record checksum mismatch 或 replay chain mismatch 都必须 fail closed，并归类为确定性的 failure reason。

## V0170-002-ACTION-SEQUENCE-VALIDATION

`V0170-002-ACTION-SEQUENCE-VALIDATION`

GH-1140 的 required action sequence 固定为：

1. `submit`
2. `cancel`
3. `status`
4. `reconciliation`

任何缺失、重复、重排或额外 action 都必须 fail closed，并输出 `actionSequenceMismatch`。

## V0170-002-RECONCILIATION-ARTIFACT-REQUIRED

`V0170-002-RECONCILIATION-ARTIFACT-REQUIRED`

最后一个 replayed artifact 必须是 `reconciliation`。如果 bundle 只包含 submit / cancel / status，而没有 reconciliation artifact，validator 必须同时输出 action sequence mismatch 和 reconciliation artifact missing evidence。

## V0170-002-DETERMINISTIC-PASS-FAIL-RESULT

`V0170-002-DETERMINISTIC-PASS-FAIL-RESULT`

Validator 输出的 result id 必须由 run id、manifest checksum、status 和 failure ids 计算。相同 bundle 的 pass/fail 结果必须稳定，不依赖当前时间、网络状态、外部服务或 machine-local secret。

## V0170-002-NO-PRODUCTION-CUTOVER

`V0170-002-NO-PRODUCTION-CUTOVER`

GH-1140 keeps these flags closed：

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`

GH-1140 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不打开 Dashboard trading button、order form、Live PRO Console command 或 production OMS。

## TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR

`TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`

Validation anchors：

- `GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`
- `TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`
- `V0170-002-REAL-ARTIFACT-BUNDLE-INGEST`
- `V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION`
- `V0170-002-ACTION-SEQUENCE-VALIDATION`
- `V0170-002-RECONCILIATION-ARTIFACT-REQUIRED`
- `V0170-002-DETERMINISTIC-PASS-FAIL-RESULT`
- `V0170-002-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1140ReleaseV0170ArtifactBundleReplayValidator`
- `bash checks/verify-v0.17.0-artifact-bundle-replay-validator.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
