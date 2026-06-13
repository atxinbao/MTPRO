# Release v0.4.0 Portfolio Replay Projection Contract

日期：2026-06-13
执行者：Codex

## Scope

`V040-11-PORTFOLIO-REPLAY-PROJECTION`

GH-704 在 `Portfolio` target 内定义 replay-derived Portfolio projection。该 projection 只消费 GH-703 Event Store run journal evidence，按同一个 runID 派生 fill-like evidence、Spot / USDⓈ-M Perpetual position projection、exposure、PnL-like rehearsal metrics 和 margin-like rehearsal fields。

## Required Evidence

- `V040-11-REPLAY-DERIVED-POSITIONS-EXPOSURE`：positions、net quantity 和 gross exposure 必须从 Event Store run journal replay 派生。
- `V040-11-SPOT-PERP-PNL-MARGIN-LIKE-METRICS`：Spot 与 USDⓈ-M Perpetual identity 必须显式，PnL-like 与 margin-like metrics 必须为 rehearsal read model。
- `V040-11-READMODEL-ONLY-NO-ACCOUNT-SYNC`：projection 不能读取真实 account、broker position、margin、leverage、real PnL 或 raw broker payload。
- `V040-11-DASHBOARD-CLI-RUNID-CONSUMABLE`：projection state 必须可由后续 Dashboard / CLI 按 runID 消费。
- `TVM-RELEASE-V040-PORTFOLIO-REPLAY-PROJECTION`：trading validation matrix anchor。

## Boundary

GH-704 不同步真实 account state，不读取 broker position / margin / leverage / real PnL，不连接 account endpoint，不运行 reconciliation runtime，不触碰 broker gateway 或 ExecutionClient，不暴露 Dashboard command surface，不授权 production cutover，不启动后续 milestone。

## Validation

- `swift test --filter TargetGraphTests/testGH704PortfolioReplayProjectionDerivesReadModelFromEventStoreRunJournal`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
