# Release v0.4.0 RuntimeKernel Dry-run Orchestrator Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-696 V040-03 Add RuntimeKernel dry-run orchestrator`。

本文档定义 `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` 的第一层 local-only RuntimeKernel dry-run orchestrator。它只复用 GH-695 的 `RehearsalRunContext` 和 unified evidence envelope 生成 deterministic local evidence，不连接 network endpoint，不读取 secret，不打开 testnet 默认模式，不实现 production trading。

## V040-03-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR

`V040-03-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR`

`Sources/ExecutionClient/FutureGate/ReleaseV040RuntimeKernelDryRunOrchestrator.swift` 定义：

- `ReleaseV040RuntimeKernelDryRunStep`
- `ReleaseV040RuntimeKernelDryRunStepEvidence`
- `ReleaseV040RuntimeKernelDryRunResult`
- `ReleaseV040RuntimeKernelDryRunOrchestrator`

该 orchestrator 的默认 fixture 必须使用 `dry-run` mode 和同一个 `runID`，并且只能输出本地 deterministic evidence。它不是 network runtime、testnet connector、production session、broker session、OMS runtime 或 order lifecycle runtime，也不得重新创建 `Sources/Runtime` source root 或向 `Runtime` compatibility envelope 添加新 source。

## V040-03-ONE-RUNID-STEP-ORDER

`V040-03-ONE-RUNID-STEP-ORDER`

RuntimeKernel dry-run step order 固定为：

1. DataEngine
2. MessageBus
3. Trader / EMA / RSI
4. RiskEngine
5. ExecutionEngine / OMS
6. ExecutionClient dry-run boundary
7. Event Store
8. Portfolio projection
9. Dashboard / CLI projection

每个 step 必须产生或引用 GH-695 的 unified evidence envelope。组合 step 可以包含多个 envelope，例如 `ExecutionEngine / OMS` 必须产生 `ExecutionEngine` 和 `OMS` 两个 module envelope，`Dashboard / CLI projection` 必须产生 `Dashboard` 和 `CLI` 两个 module envelope。所有 envelope 必须复用同一个 `runID`。

## V040-03-LOCAL-ONLY-DRY-RUN

`V040-03-LOCAL-ONLY-DRY-RUN`

GH-696 只允许 local dry-run orchestration：

- `localDryRunOnly == true`
- `runContext.mode == dry-run`
- `networkCallsPerformed == false`
- `secretReadsPerformed == false`
- `testnetEnabledByDefault == false`

后续 GH-697 至 GH-705 可以逐步把各模块 evidence 接入该 step order，但不得跳过 shared run context / unified envelope。

## V040-03-FORBIDDEN-NETWORK-SECRET-PRODUCTION

`V040-03-FORBIDDEN-NETWORK-SECRET-PRODUCTION`

GH-696 必须保持以下能力关闭：

- production trading disabled by default
- production secret auto-read disabled
- production endpoint auto-connect disabled
- production broker connection disabled
- production order submission disabled
- production cutover unauthorized
- real submit / cancel / replace absent
- signed endpoint / account endpoint / listenKey absent
- private WebSocket runtime absent

任何试图把 RuntimeKernel dry-run orchestrator 解读为 testnet credential read、production broker connector、real order path 或 production cutover authorization 的行为都必须 fail closed。

## TVM-RELEASE-V040-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR

`TVM-RELEASE-V040-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR`

Required validation：

- `swift test --filter TargetGraphTests/testGH696RuntimeKernelDryRunOrchestratorDrivesLocalRunWithoutNetworkOrSecrets`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V040-03 Non-authorization

GH-696 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- DataEngine real network runtime。
- testnet 默认开启。
- network endpoint 连接。
- testnet credential 读取。
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
- trading button / live command / order form。
