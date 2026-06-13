# Release v0.4.0 Binance Dry-run ExecutionClient Adapter Contract

日期：2026-06-13
执行者：Codex

## Scope

`V040-08-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER`

GH-701 在 `ExecutionClient` target 的 `FutureGate` 内定义 Binance dry-run ExecutionClient adapter boundary。该 boundary 消费 #700 ExecutionEngine / OMS dry-run lifecycle handoff，生成 request intent、redacted request 和 local dry-run acknowledgement evidence。

## Required Evidence

- `V040-08-REQUEST-INTENT-REDACTED-REQUEST-ACK`：每个 local lifecycle handoff 必须映射为 request intent、redacted request 和 dry-run acknowledgement。
- `V040-08-SPOT-PERP-MAPPING-ONLY`：只允许 Binance Spot 和 Binance USDⓈ-M Perpetual product mapping。
- `V040-08-NETWORK-PRODUCTION-ORDER-BLOCKED`：networkCallPerformed、production endpoint、production secret、production order、broker gateway 和 raw broker payload 必须保持 false。
- `TVM-RELEASE-V040-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER`：trading validation matrix anchor。

## Boundary

GH-701 不连接 testnet / production endpoint，不读取 secret，不签名真实请求，不调用 broker gateway，不提交真实 submit / cancel / replace，不实现 production ExecutionClient runtime，不授权 production cutover。后续 #702 才能定义 guarded Binance testnet mode boundary。

## Validation

- `swift test --filter TargetGraphTests/testGH701BinanceDryRunExecutionClientAdapterMapsLifecycleRequestsWithoutNetworkCalls`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
