# Release v0.4.0 Dashboard / CLI Unified Run Surface Contract

日期：2026-06-13

执行者：Codex

## 目标

GH-705 / V040-12 定义 release v0.4.0 的 Dashboard / CLI unified run surface。该 surface 只消费 GH-704 Portfolio replay projection 输出的单一 `runID` read model，用于展示 run status、gate decisions、kill switch / no-trade 状态、adapter evidence 和 Portfolio projection evidence。

该合同不授权 Dashboard command surface，不授权 CLI live command，不授权 trading button、order form、production endpoint、secret read、broker gateway、ExecutionClient command path、真实订单或 production cutover。

## Anchors

- `V040-12-DASHBOARD-CLI-UNIFIED-RUN-SURFACE`
- `V040-12-ONE-RUNID-PROJECTION-CONSUMPTION`
- `V040-12-BLOCKED-REJECTED-STATE-EXPLANATIONS`
- `V040-12-ADAPTER-PORTFOLIO-PROJECTION-VISIBLE`
- `V040-12-NO-LIVE-COMMAND-SURFACE`
- `TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE`

## Scope

- `Sources/Portfolio/ReleaseV040UnifiedRunSurface.swift` owns the shared deterministic evidence for Dashboard and CLI.
- `Sources/Dashboard/Report/ReleaseV040DashboardUnifiedRunSurface.swift` maps the evidence into a read-model-only Dashboard view model.
- `Sources/MTPROCLI/main.swift` exposes `mtpro unified-run-status [runID]` as a read-only status command.
- `Package.swift` wires `Portfolio` into `MTPROCLI` and `Dashboard` so both surfaces consume the same evidence source.
- `Tests/TargetGraphTests/TargetGraphTests.swift` must include `testGH705DashboardCLIUnifiedRunSurfaceConsumesPortfolioProjectionByRunID`.

## Acceptance

- Dashboard and CLI consume the same GH-704 Portfolio projection `runID`.
- Dashboard and CLI show blocked and rejected state explanations without authorizing execution.
- Adapter evidence and Portfolio projection evidence are visible in the status surface.
- `ReleaseV040UnifiedRunSurfaceEvidence.boundaryHeld == true`.
- `ReleaseV040DashboardUnifiedRunSurfaceViewModel.dashboardSurfaceBoundaryHeld == true`.
- `mtpro unified-run-status` emits the run ID, validation anchor, gate states, blocked / rejected explanations, and production-disabled flags.

## Boundary

- No trading button.
- No order form.
- No live command surface.
- No production command surface.
- No production trading enabled by default.
- No production secret read.
- No production endpoint connection.
- No account endpoint read.
- No broker gateway access.
- No ExecutionClient command access.
- No real order submit / cancel / replace.
- No production cutover authorization.
- No next milestone auto-start.

## Required Validation

- `swift test --filter TargetGraphTests/testGH705DashboardCLIUnifiedRunSurfaceConsumesPortfolioProjectionByRunID`
- `swift run mtpro unified-run-status`
- `bash checks/verify-v0.3.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
