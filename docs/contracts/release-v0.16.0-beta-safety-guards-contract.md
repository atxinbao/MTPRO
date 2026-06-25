# Release v0.16.0 Beta Safety Guards Contract

日期：2026-06-25  
执行者：Codex

## #1110 / GH-1110

`GH-1110-VERIFY-V0160-BETA-SAFETY-GUARDS`

## Scope

GH-1110 只为 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` 增加 transport 前置安全 guard。该 guard 在 `spot-testnet-submit`、`spot-testnet-cancel` 和 `spot-testnet-status-query` 的任何 transport call 之前执行，覆盖：

- `TVM-RELEASE-V0160-BETA-SAFETY-GUARDS`
- `V0160-010-MAX-QUANTITY-GUARD`
- `V0160-010-MAX-ORDERS-PER-RUN-GUARD`
- `V0160-010-COOLDOWN-GUARD`
- `V0160-010-SYMBOL-ALLOWLIST-GUARD`
- `V0160-010-TESTNET-ONLY-CREDENTIAL-PROFILE`
- `V0160-010-TRANSPORT-PRECHECK-FAILS-CLOSED`
- `V0160-010-REDACTED-SAFETY-EVIDENCE`
- `V0160-010-NO-PRODUCTION-CUTOVER`

## Contract

`ReleaseV0160BetaSafetyGuard` 是唯一的 v0.16.0 beta safety guard 入口。它先通过 `evaluate` 生成 `ReleaseV0160BetaSafetyGuardEvidence`，再由 `validate` 在任一 guard 未满足时 fail closed。

默认限制：

- `maxQuantity = 0.05`
- `maxOrdersPerRun = 1`
- `cooldownMilliseconds = 60000`
- `allowedSymbols = BTCUSDT, ETHUSDT`
- `credentialProvider = testnet-env`
- API key / secret environment name 必须包含 `TESTNET`

## Evidence

`ReleaseV0160BetaSafetyGuardEvidence` 只记录 run id、action、symbol、quantity、限制值、布尔 guard 结果、失败原因和脱敏 credential reference。它不得记录 API key、secret、raw order identity、raw broker payload、signed query、raw response 或 production endpoint。

## Flow Integration

以下 flow 必须在 credential resolution、signed request build、delegated runtime 或 transport call 之前调用：

- `ReleaseV0160CLISubmitExecutionFlow.result`
- `ReleaseV0160CLICancelExecutionFlow.result`
- `ReleaseV0160CLIOrderStatusQueryFlow.result`

## Validation

Focused verifier：

```bash
bash checks/verify-v0.16.0-beta-safety-guards.sh
```

Focused test：

```bash
swift test --filter TargetGraphTests/testGH1110ReleaseV0160BetaSafetyGuardsFailClosedBeforeTransport
```

Full validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Boundary

GH-1110 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不新增 Dashboard trading button、order form 或 live command，不扩大到非 Binance venue，不扩大到 Binance Futures / USDⓈ-M execution。
