# Release v0.3.0 Dashboard / CLI Rehearsal Surface Contract

日期：2026-06-13

执行者：Codex

本文档定义 GH-666 / V030-10 的 Dashboard / CLI rehearsal surface 合同。该合同只授权 Dashboard 和 CLI 展示本地 rehearsal run status、gate evidence、failure reasons、kill switch status 和 no-trade status；不授权 production trading、production secret、production endpoint、真实 broker connection、真实订单或 production cutover。

## V030-10-DASHBOARD-CLI-REHEARSAL-SURFACE

- Issue：GH-666。
- Upstream：GH-665 / `TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL`。
- Downstream：GH-667。
- Queue range：GH-657..GH-670。
- Release：v0.3.0。
- Project：MTPRO Release v0.3.0 Runtime Rehearsal v1。

GH-666 输出两个 surface：

- `Sources/Portfolio/ReleaseV030RehearsalSurface.swift`：共享 Dashboard read-model surface evidence。
- `Sources/Database/ReleaseV030CLIRehearsalSurface.swift`：CLI-only `rehearsal-status` adapter evidence；`MTPROCLI` 继续只依赖 `Database`。
- `Sources/Dashboard/Report/ReleaseV030DashboardRehearsalSurface.swift`：Dashboard read-model-only ViewModel。

## V030-10-RUN-STATUS-SURFACE

Dashboard 和 CLI 必须展示 rehearsal run status。当前 deterministic surface 使用 `blocked` 状态，因为 kill switch 与 no-trade 必须保持 active，production command 默认不可执行。

## V030-10-GATE-FAILURE-REASONS

Surface 必须展示以下 gate 的状态和 failure reason：

- CommandGateway。
- RiskEngine。
- ExecutionEngine。
- OMS。
- Event Store。
- Portfolio projection。
- Kill switch。
- No-trade。

Failure reason 只用于解释本地 rehearsal gate，不包含 broker payload、secret、signed endpoint payload 或 production account state。

## V030-10-KILL-SWITCH-NO-TRADE-STATUS

Kill switch 和 no-trade status 必须可见，并且必须阻断任何 unsafe command：

- `killSwitchStatus=blocked`。
- `noTradeStatus=blocked`。
- production command remains disabled。

## V030-10-COMMANDGATEWAY-ROUTING

Dashboard / CLI surface 只能展示 CommandGateway route evidence：

- route 必须以 `command-gateway/release-v0.3.0/rehearsal/` 开头。
- Dashboard 不提供 trading button。
- Dashboard 不暴露 order form。
- CLI `rehearsal-status` 只输出状态文本，不发送 command payload。
- Dashboard / CLI 不得直连 ExecutionClient、broker、OMS 或 production endpoint。

## TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE

Validation evidence 必须同时落在：

- `Sources/Portfolio/ReleaseV030RehearsalSurface.swift`
- `Sources/Database/ReleaseV030CLIRehearsalSurface.swift`
- `Sources/Dashboard/Report/ReleaseV030DashboardRehearsalSurface.swift`
- `Sources/MTPROCLI/main.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`

Required validation：

- `swift test --filter TargetGraphTests/testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-666 不使用 Linear，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不创建下一 Project / Issue，不推进下一阶段 Todo。

GH-666 不连接 production endpoint，不读取 production secret，不发送真实订单，不读取 account endpoint，不同步 broker position，不保存或暴露 raw broker payload，不执行 broker reconciliation，不打开 production Dashboard command，不暴露 order form，不授权 production cutover。
