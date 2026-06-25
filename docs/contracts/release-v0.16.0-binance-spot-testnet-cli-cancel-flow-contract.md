# MTPRO Release v0.16.0 Binance Spot Testnet CLI Cancel Flow Contract

日期：2026-06-25

执行者：Codex

本文档定义 #1104 / GH-1104 的 v0.16.0 稳定 CLI cancel flow。该合同承接 #1101 / GH-1101 operator beta contract、#1102 / GH-1102 operator run model 和 #1103 / GH-1103 CLI submit flow，只授权 Binance Spot Testnet operator beta 的 `spot-testnet-cancel` cancel-only 入口。

## Validation Anchors

- `GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW`
- `TVM-RELEASE-V0160-CLI-CANCEL-FLOW`
- `V0160-004-STABLE-CLI-CANCEL`
- `V0160-004-SUBMIT-ARTIFACT-IDENTITY`
- `V0160-004-V0151-RUNTIME-DELEGATION`
- `V0160-004-EXPLICIT-OPERATOR-CONFIRMATION`
- `V0160-004-TESTNET-CREDENTIAL-PROFILE`
- `V0160-004-REDACTED-ORDER-REFERENCE`
- `V0160-004-APPEND-ONLY-EVENT-EVIDENCE`
- `V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED`
- `V0160-004-NO-PRODUCTION-CUTOVER`

## Scope

GH-1104 只实现稳定 CLI cancel flow：

- CLI command 固定为 `spot-testnet-cancel`。
- 必须显式传入 `--testnet`。
- 必须显式传入 `--operator-confirm CONFIRM_BINANCE_SPOT_TESTNET_OPERATOR_BETA`。
- credential provider 固定为 `testnet-env`，只接受 testnet 命名环境变量。
- cancel runtime 委托既有 v0.15.1 guarded runtime：`ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow`。
- action 固定为 `cancel`；submit、cancel-replace、status、reconciliation 由各自 issue 单独授权。
- 必须消费 `source submit evidence JSON` 和 `network event log JSON`，从 prior submit artifact 派生 cancel identity。
- 输出只包含 redacted run id、artifact path、checksum、delegated runtime evidence handle、redacted order reference 和 boundary flags。
- artifact root 继续使用 #1102 operator run model 的 `.local/mtpro/v0.16.0/operator-runs/<runID>/redacted-execution-evidence.json`。

## Non-goals

- 不实现 submit。
- 不实现 cancel-replace。
- 不实现 status query。
- 不实现 local artifact store writer。
- 不实现 OMS reconciliation。
- 不新增 Dashboard trading button、order form 或 live command。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不提交 production order。
- 不授权 production cutover。

## Contract

`ReleaseV0160CLICancelExecutionFlow` 是 v0.16.0 的 stable cancel-only CLI facade。它做三件事：

1. 外层解析 `spot-testnet-cancel`，检查 testnet gate、operator confirmation、testnet credential profile、prior submit artifact 和 redacted output。
2. 把外层命令转换成 v0.15.1 `testnet-execution --action cancel` 参数，并委托 v0.15.1 guarded runtime。
3. 把 delegated runtime result、prior submit artifact identity 和 #1102 operator run model 合成为 v0.16.0 redacted cancel evidence。

该 flow 必须 fail-closed：

- 缺少 `--testnet`。
- 缺少或错误 operator confirmation。
- 缺少 testnet credential 环境变量。
- credential provider 不是 `testnet-env`。
- 输出不是 `redacted`。
- action 不是 `cancel`。
- 缺少 `--source-submit-evidence-json`。
- 缺少 `--network-event-log-json`。
- source submit evidence 与当前 cancel intent 或 credential reference 不匹配。
- 任何 production / broker / production secret 参数出现。

## Validation

Required commands:

```bash
swift test --filter TargetGraphTests/testGH1104ReleaseV0160CLICancelFlowConsumesSubmitArtifactAndFailsClosed
bash checks/verify-v0.16.0-cli-cancel-flow.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

Evidence files:

- `Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift`
- `Sources/MTPROCLI/main.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/contracts/release-v0.16.0-binance-spot-testnet-cli-cancel-flow-contract.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `checks/verify-v0.16.0-cli-cancel-flow.sh`
- `checks/automation-readiness.sh`
- `checks/run.sh`

## Boundary

GH-1104 是 cancel-only CLI flow slice。它允许 operator 在显式确认、testnet credential profile、prior submit artifact 和 redacted output 条件下触达 Binance Spot Testnet cancel runtime。它不是 production cutover，不读取 production secret，不连接 production / broker endpoint，不发送 production order，不授权真实生产交易。
