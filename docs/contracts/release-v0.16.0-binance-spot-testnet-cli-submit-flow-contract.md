# MTPRO Release v0.16.0 Binance Spot Testnet CLI Submit Flow Contract

日期：2026-06-25

执行者：Codex

本文档定义 #1103 / GH-1103 的 v0.16.0 稳定 CLI submit flow。该合同承接 #1101 / GH-1101 operator beta contract 和 #1102 / GH-1102 operator run model，只授权 Binance Spot Testnet operator beta 的 `spot-testnet-submit` submit-only 入口。

## Validation Anchors

- `GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW`
- `TVM-RELEASE-V0160-CLI-SUBMIT-FLOW`
- `V0160-003-STABLE-CLI-SUBMIT`
- `V0160-003-V0151-RUNTIME-DELEGATION`
- `V0160-003-EXPLICIT-OPERATOR-CONFIRMATION`
- `V0160-003-TESTNET-CREDENTIAL-PROFILE`
- `V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM`
- `V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED`
- `V0160-003-NO-PRODUCTION-CUTOVER`

## Scope

GH-1103 只实现稳定 CLI submit flow：

- CLI command 固定为 `spot-testnet-submit`。
- 必须显式传入 `--testnet`。
- 必须显式传入 `--operator-confirm CONFIRM_BINANCE_SPOT_TESTNET_OPERATOR_BETA`。
- credential provider 固定为 `testnet-env`，只接受 testnet 命名环境变量。
- submit runtime 委托既有 v0.15.1 guarded runtime：`ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow`。
- action 固定为 `submit`；`cancel` / `cancel-replace` / status / reconciliation 仍由后续 issue 单独授权。
- 输出只包含 redacted run id、artifact path、checksum、delegated runtime evidence handle 和 boundary flags。
- artifact root 继续使用 #1102 operator run model 的 `.local/mtpro/v0.16.0/operator-runs/<runID>/redacted-execution-evidence.json`。

## Non-goals

- 不实现 cancel / cancel-replace。
- 不实现 status query。
- 不实现 local artifact store writer。
- 不实现 OMS reconciliation。
- 不新增 Dashboard trading button、order form 或 live command。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不提交 production order。
- 不授权 production cutover。

## Contract

`ReleaseV0160CLISubmitExecutionFlow` 是 v0.16.0 的 stable submit-only CLI facade。它做三件事：

1. 外层解析 `spot-testnet-submit`，检查 testnet gate、operator confirmation、testnet credential profile 和 redacted output。
2. 把外层命令转换成 v0.15.1 `testnet-execution --action submit` 参数，并委托 v0.15.1 guarded runtime。
3. 把 delegated runtime result 和 #1102 operator run model 合成为 v0.16.0 redacted submit evidence。

该 flow 必须 fail-closed：

- 缺少 `--testnet`。
- 缺少或错误 operator confirmation。
- 缺少 testnet credential 环境变量。
- credential provider 不是 `testnet-env`。
- 输出不是 `redacted`。
- action 不是 `submit`。
- 任何 production / broker / production secret 参数出现。

## Validation

Required commands:

```bash
swift test --filter TargetGraphTests/testGH1103ReleaseV0160CLISubmitFlowUsesStableOperatorSubmitAndFailsClosed
bash checks/verify-v0.16.0-cli-submit-flow.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

Evidence files:

- `Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift`
- `Sources/MTPROCLI/main.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/contracts/release-v0.16.0-binance-spot-testnet-cli-submit-flow-contract.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `checks/verify-v0.16.0-cli-submit-flow.sh`
- `checks/automation-readiness.sh`
- `checks/run.sh`

## Boundary

GH-1103 是 submit-only CLI flow slice。它允许 operator 在显式确认、testnet credential profile 和 redacted output 条件下触达 Binance Spot Testnet submit runtime。它不是 production cutover，不读取 production secret，不连接 production / broker endpoint，不发送 production order，不授权真实生产交易。
