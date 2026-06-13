# Release v0.4.0 Unified Runtime Rehearsal Pipeline Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-694 V040-01 Define unified runtime rehearsal pipeline contract`。

本文档定义 `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` 的第一层合同。它只固定统一 runtime rehearsal pipeline 的 run input、run output、runID、模块顺序、evidence envelope、Dashboard / CLI projection 和后续验证矩阵期望；不实现 runtime pipeline，不连接 testnet 或 production endpoint，不读取 secret，不提交 / 取消 / 替换真实订单，不授权 production cutover。

## V040-01-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT

`V040-01-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT`

GH-694 是 V040 queue `GH-694..GH-709` 的第一个 gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ReleaseV040UnifiedRuntimeRehearsalPipelineContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH694ReleaseV040UnifiedRuntimeRehearsalPipelineContractRequiresOneRunID`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V040-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT`

合同固定：

- release version 固定为 `v0.4.0`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-694..GH-709`
- downstream issue 固定为 `GH-695`
- all module evidence 必须共享同一个 runID
- Dashboard / CLI 只能消费 unified run projection，不直连 runtime 或 broker surface
- production capability defaults 必须继续关闭。

## V040-01-ONE-RUNID-EVIDENCE-CHAIN

`V040-01-ONE-RUNID-EVIDENCE-CHAIN`

v0.4.0 统一 pipeline 的核心不变量是：一次 rehearsal run 只有一个 runID，所有模块 evidence 必须写入同一个 unified evidence envelope。

固定模块顺序：

1. DataEngine
2. MessageBus
3. Trader / EMA / RSI
4. RiskEngine
5. ExecutionEngine / OMS
6. Binance dry-run / testnet-gated ExecutionClient
7. Event Store
8. Portfolio projection
9. Dashboard / CLI

后续 V040 issues 只能逐步回填这些 step 的 deterministic evidence，不得引入第二条 runID、不完整 envelope 或绕过模块顺序的旁路。

## V040-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY

`V040-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY`

v0.4.0 继续锁定 v0.3.x 的 active scope：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot, usdsPerpetual]`
- `allowedStrategies == [EMA, RSI]`

任何非 Binance venue、Spot / USDⓈ-M Perpetual 之外的 product type、EMA / RSI 之外的 active strategy 都不属于 GH-694 scope。

## V040-01-DRYRUN-SHADOW-TESTNET-GUARDED-SEMANTICS

`V040-01-DRYRUN-SHADOW-TESTNET-GUARDED-SEMANTICS`

v0.4.0 rehearsal mode 固定为：

- `dry-run`
- `shadow`
- `testnet-guarded`
- `production-blocked`

`testnet-guarded` 只表示后续 issue 可以在显式 gate 下定义 testnet rehearsal semantics；GH-694 不连接 testnet network，不读取 testnet credential，不发送 testnet order。`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V040-01-DASHBOARD-CLI-UNIFIED-RUN-PROJECTION

`V040-01-DASHBOARD-CLI-UNIFIED-RUN-PROJECTION`

Dashboard / CLI 的唯一输入是 unified run projection。它们不得：

- 直连 DataEngine runtime。
- 直连 Trader / strategy actors。
- 绕过 CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store gate。
- 读取 signed endpoint、account endpoint、listenKey、private WebSocket 或 broker payload。
- 暴露 trading button、live command 或 order form。

后续 V040 Dashboard / CLI issue 只能消费统一 runID 下的 read-model projection。

## V040-01-FORBIDDEN-PRODUCTION-CAPABILITIES

`V040-01-FORBIDDEN-PRODUCTION-CAPABILITIES`

GH-694 必须保持以下默认关闭或禁止：

- `productionTradingEnabledByDefault == false`
- `productionSecretAutoReadEnabled == false`
- `productionEndpointAutoConnectEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `productionOrderSubmissionEnabled == false`
- `productionCutoverAuthorized == false`
- `startsNextMilestone == false`

本文档不创建 secret provider、signed request runtime、listenKey runtime、private stream runtime、broker adapter、production OMS、real submit / cancel / replace path 或 production cutover path。

## TVM-RELEASE-V040-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT

`TVM-RELEASE-V040-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT`

Required validation：

- `swift test --filter TargetGraphTests/testGH694ReleaseV040UnifiedRuntimeRehearsalPipelineContractRequiresOneRunID`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

后续 issues 必须逐项回填：

- RehearsalRunContext carries one runID
- all module evidence shares one envelope
- module order follows the canonical chain
- dry-run mode produces deterministic evidence
- shadow mode replays without order submission
- guarded testnet mode remains explicitly gated
- Dashboard / CLI consume unified run projection only
- production capability remains blocked by default
- verify-v0.4.0 covers the unified chain

## V040-01 Non-authorization

GH-694 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- runtime pipeline 实现。
- testnet endpoint 连接。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- production broker connection。
- production order submission。
- production cutover authorization。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- trading button / live command / order form。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- Dashboard / CLI 旁路 unified run projection。
- 下一 Project / Issue / milestone 自动启动。
