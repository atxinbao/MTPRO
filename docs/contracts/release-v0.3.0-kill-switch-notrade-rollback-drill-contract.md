# Release v0.3.0 Kill Switch / No-Trade / Rollback Drill Contract

日期：2026-06-13

执行者：Codex

本文档定义 GH-667 / V030-11 的 kill switch / no-trade / rollback drill 合同。该合同只授权本地 deterministic rehearsal evidence，用于证明 submit / cancel / replace 在 gate active 时被阻断并被审计；不授权 production trading、production secret、production endpoint、真实 broker connection、真实订单或 production cutover。

## V030-11-KILL-SWITCH-NO-TRADE-ROLLBACK-DRILL

- Issue：GH-667。
- Upstream：GH-666 / `TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE`。
- Downstream：GH-668。
- Queue range：GH-657..GH-670。
- Release：v0.3.0。

Implementation evidence：

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV030KillSwitchNoTradeRollbackDrill.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace`

## V030-11-KILL-SWITCH-BLOCKS-COMMANDS

Kill switch drill 必须覆盖：

- submit blocked。
- cancel blocked。
- replace blocked。
- 所有 blocked records 均在 ExecutionClient / broker gateway 前阻断。
- 所有 blocked records 均保留 CommandGateway audit route。

## V030-11-NO-TRADE-BLOCKS-COMMANDS

No-trade drill 必须覆盖：

- submit blocked。
- cancel blocked。
- replace blocked。
- no-trade 优先级高于任何 rehearsal command。
- 不产生真实 broker payload、signed endpoint payload 或 production account state。

## V030-11-ROLLBACK-EVIDENCE

Rollback evidence 必须覆盖：

- capture blocked rehearsal command。
- freeze no-trade state。
- record rollback reason。
- keep production trading disabled。

Rollback evidence 不执行 production rollback，不恢复 production trading，不连接 broker，不发送真实订单。

## V030-11-BLOCKED-COMMAND-AUDIT

每个 blocked command record 必须包含：

- command kind：submit / cancel / replace。
- scenario：kill-switch / no-trade / rollback。
- CommandGateway route。
- block reason。
- audited flag。
- blocked before ExecutionClient。
- blocked before broker gateway。

## TVM-RELEASE-V030-KILL-SWITCH-NOTRADE-ROLLBACK-DRILL

Validation evidence 必须同时落在：

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV030KillSwitchNoTradeRollbackDrill.swift`
- `docs/contracts/release-v0.3.0-kill-switch-notrade-rollback-drill-contract.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

Required validation：

- `swift test --filter TargetGraphTests/testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-667 不使用 Linear，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不创建下一 Project / Issue，不推进下一阶段 Todo。

GH-667 不连接 production endpoint，不读取 production secret，不发送真实订单，不读取 account endpoint，不同步 broker position，不保存或暴露 raw broker payload，不执行 broker reconciliation，不打开 production Dashboard command，不暴露 order form，不授权 production cutover。
