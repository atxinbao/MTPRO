# Release v0.4.0 Binance Testnet Mode Boundary Contract

日期：2026-06-13
执行者：Codex

## Scope

`V040-09-BINANCE-TESTNET-MODE-BOUNDARY`

GH-702 在 `ExecutionClient` target 的 `FutureGate` 内定义 Binance guarded testnet mode boundary。该 boundary 消费 #701 dry-run ExecutionClient adapter evidence，生成 explicit `--mode testnet`、testnet-only endpoint reference、testnet credential profile reference 和 operator confirmation evidence。

## Required Evidence

- `V040-09-EXPLICIT-MODE-OPERATOR-CONFIRMATION`：testnet mode 必须由 operator 显式确认，dry-run 仍保持默认。
- `V040-09-TESTNET-ONLY-ENDPOINT-ENVIRONMENT`：Spot 只允许 `https://testnet.binance.vision`，USDⓈ-M Perpetual 只允许 `https://testnet.binancefuture.com`。
- `V040-09-PRODUCTION-FALLBACK-BLOCKED`：production host、production credential、production endpoint、production order 和 fallback-to-production 必须拒绝。
- `TVM-RELEASE-V040-BINANCE-TESTNET-MODE-BOUNDARY`：trading validation matrix anchor。

## Boundary

GH-702 不连接 testnet / production endpoint，不读取 secret，不签名真实请求，不调用 broker gateway，不提交真实 submit / cancel / replace，不把 testnet 设为默认模式，不授权 production cutover。后续 #707 才能把该 evidence 纳入 release validation suite。

## Validation

- `swift test --filter TargetGraphTests/testGH702BinanceTestnetModeBoundaryRequiresExplicitOperatorConfirmation`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
