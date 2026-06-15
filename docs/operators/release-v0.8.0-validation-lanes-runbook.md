# MTPRO Release v0.8.0 Validation Lanes Runbook

日期：2026-06-15

执行者：Codex

## GH-819-RELEASE-V080-VALIDATION-LANES-RUNBOOK

本文档服务 GitHub fallback issue `GH-819 V080-013 Split deterministic CI proof from manual operator network proof`。它把 v0.8.0 的验证分成两个不可混淆的 lane：deterministic CI proof lane 和 manual operator network proof lane。

验证锚点：

- `GH-819-VERIFY-V080-VALIDATION-LANES`
- `TVM-RELEASE-V080-VALIDATION-LANES`

本文档不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不读取 production secret，不连接 production endpoint / broker endpoint，不提交、取消或替换 testnet 或 production order，不授权 production cutover。

## V080-013-VALIDATION-LANES

`V080-013-VALIDATION-LANES`

v0.8.0 validation lanes 固定为：

- `V080-013-DETERMINISTIC-CI-PROOF-LANE`
- `V080-013-MANUAL-OPERATOR-NETWORK-PROOF-LANE`

两个 lane 可以引用同一组 redacted proof artifact 语义，但不能互相替代。CI lane 证明 no-secret / no-network deterministic fixture 和边界守卫；manual lane 只证明 operator 明确确认过的 Binance Spot testnet read-only network observation 已被压缩成 redacted artifact reference。

## V080-013-DETERMINISTIC-CI-PROOF-LANE

`V080-013-DETERMINISTIC-CI-PROOF-LANE`

CI lane 由 GitHub required check `checks`、本地 `checks/run.sh` 和 focused v0.8 verifiers 组成。该 lane 必须满足：

- `V080-013-CI-NO-SECRET-NO-NETWORK`
- 不读取 credential value。
- 不访问 Binance testnet 或 production network。
- 不依赖 operator 本机 secret。
- 不把 manual proof 标记为 deterministic CI proof。
- 只验证 deterministic mock source artifact、redaction、文档锚点、TargetGraphTests 和 no-order boundary。

CI lane 的固定命令：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh
bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh
bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh
bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh
bash checks/verify-v0.8.0-validation-lanes.sh
bash checks/run.sh
```

`.github/workflows/checks.yml` 的 `workflow_dispatch:` 只允许 operator 手动触发同一组 deterministic CI guard。该 dispatch 不允许注入 secret，不允许打开 network proof，不允许变成 production cutover。

## V080-013-MANUAL-OPERATOR-NETWORK-PROOF-LANE

`V080-013-MANUAL-OPERATOR-NETWORK-PROOF-LANE`

Manual lane 只在 operator 明确确认后记录 testnet read-only network proof 摘要。该 lane 必须满足：

- `V080-013-WORKFLOW-DISPATCH-OPERATOR-CONFIRMATION`
- operator 明确提供 credential reference，而不是 credential value。
- operator 明确提供 manual proof reference。
- proof artifact 必须 redacted，并保留 `redactedCredentialReference` / `redactedListenKeyReference`。
- signed account proof 只允许记录 `networkAttempted=true` 和 `signedAccountSnapshotRead=true`。
- private stream proof 只允许记录 listenKey open / observe / close lifecycle、account / balance / position read-model 摘要和 freshness status。
- manual lane 不能进入 required CI lane，不能被 CI 自动重放，不能被 Dashboard 或 CLI 升级为 order command。

Manual lane 的 operator checklist：

- [ ] 当前 proof 来自 Binance Spot testnet read-only observation。
- [ ] operator confirmation id 非空。
- [ ] credential reference 非空，且没有 credential value。
- [ ] manual proof reference 非空，指向 redacted artifact 或审计记录。
- [ ] signed account proof 没有 raw account payload。
- [ ] private stream proof 没有 raw listenKey、raw stream URL 或 raw private payload。
- [ ] `V080-013-REDACTED-PROOF-ARTIFACTS` 已满足。
- [ ] `V080-013-MANUAL-NO-ORDER-SUBMISSION` 已满足。
- [ ] `V080-013-NO-PRODUCTION-CUTOVER` 已满足。

## V080-013-REDACTED-PROOF-ARTIFACTS

`V080-013-REDACTED-PROOF-ARTIFACTS`

Manual proof artifact 只能保存 redacted references 和摘要字段：

- `manualProofReference`
- `operatorConfirmationID`
- `credentialReference`
- `redactedCredentialReference`
- `redactedListenKeyReference`
- `networkAttempted`
- `signedAccountSnapshotRead`
- `privateStreamObserved`
- `accountBalancePositionReadModelObserved`
- `deterministicCIProof=false`
- `ciRequiresNetwork=false`
- `ciRequiresSecrets=false`

Artifact 不得保存 API key、secret、raw account payload、raw listenKey、raw private stream payload、broker state、order request、production endpoint 或 production cutover authorization。

## V080-013-MANUAL-NO-ORDER-SUBMISSION

`V080-013-MANUAL-NO-ORDER-SUBMISSION`

Manual lane 必须持续固定：

- `ordersSubmitted=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `testnetCancelReplaceAllowed=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## V080-013-NO-PRODUCTION-CUTOVER

`V080-013-NO-PRODUCTION-CUTOVER`

GH-819 只定义 validation lanes split。它不授权 production trading，不读取 production secret，不连接 production endpoint / broker，不发送真实 order，不打开 production cutover，不创建下一 Project / Issue，不推进 release v0.8.0 之后的阶段。
