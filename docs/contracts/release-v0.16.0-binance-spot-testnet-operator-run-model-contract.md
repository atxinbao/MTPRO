# MTPRO Release v0.16.0 Binance Spot Testnet Operator Run Model Contract

日期：2026-06-24

执行者：Codex

本文档定义 #1102 / GH-1102 的 operator run model 合同。该合同承接 #1101 / GH-1101 的 v0.16.0 Binance Spot Testnet Operator Execution Beta 顶层合同，只建立本地 run id lifecycle、action sequence、artifact linkage、redacted metadata 和 fail-closed transition evidence。

## Validation Anchors

- `GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL`
- `TVM-RELEASE-V0160-OPERATOR-RUN-MODEL`
- `V0160-002-RUN-ID-LIFECYCLE`
- `V0160-002-ACTION-SEQUENCE`
- `V0160-002-ARTIFACT-LINKAGE`
- `V0160-002-INVALID-TRANSITION-FAILS-CLOSED`
- `V0160-002-REDACTED-METADATA`
- `V0160-002-NO-NETWORK-BY-THIS-ISSUE`
- `V0160-002-NO-PRODUCTION-CUTOVER`

## Scope

GH-1102 只定义 durable operator run model：

- run id 必须非空，并固定本地 artifact root：`.local/mtpro/v0.16.0/operator-runs/<runID>`。
- action sequence 固定为 create、request-submit、record-submit-observed、request-status、record-status-observed、request-cancel、record-cancel-observed、reconcile、close。
- metadata 只记录 issue id、release version、venue、product type、operator confirmation phrase、redacted artifact path、checksum 和 boundary flags。
- artifact link 只允许 redacted evidence handle、path 和 checksum，不允许 credential value、raw broker payload 或 raw order identity。
- transition 不符合状态机时必须 fail-closed。

## Non-goals

- 不读取 credential value。
- 不连接 testnet endpoint。
- 不提交 testnet order。
- 不实现 submit / cancel / status / reconciliation runtime。
- 不新增 Dashboard trading button、order form 或 live command。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不提交 production order。
- 不授权 production cutover。

## Contract

`ReleaseV0160OperatorRunModel` 是后续 GH-1103..GH-1112 的共享本地 run identity 和 artifact linkage contract。它提供 deterministic fixture、required validation anchors、required validation commands、状态机和 checksum chain。

该 model 的 production defaults 必须保持关闭：

- `testnetCredentialValueReadEnabledByThisIssue == false`
- `testnetNetworkConnectionEnabledByThisIssue == false`
- `testnetOrderSubmissionImplementedByThisIssue == false`
- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabled == false`
- `productionEndpointConnectionEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `productionOrderSubmitCancelReplaceEnabled == false`
- `productionCutoverAuthorized == false`

## Validation

Required commands:

```bash
swift test --filter TargetGraphTests/testGH1102ReleaseV0160OperatorRunModelDefinesRunIDLifecycleAndFailsClosed
bash checks/verify-v0.16.0-operator-run-model.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

Evidence files:

- `Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/contracts/release-v0.16.0-binance-spot-testnet-operator-run-model-contract.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `checks/verify-v0.16.0-operator-run-model.sh`
- `checks/automation-readiness.sh`
- `checks/run.sh`

## Boundary

GH-1102 是 model / lifecycle / artifact linkage slice，不是 runtime execution slice。后续 issue 只有在各自 GitHub issue scope 明确授权后，才能逐步实现 bounded Binance Spot Testnet operator submit、cancel、status、reconciliation、Dashboard / CLI evidence 或 release closeout。
