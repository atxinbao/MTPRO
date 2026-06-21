# Release v0.14.0 Read-only Execution Dashboard Contract

日期：2026-06-22  
执行者：Codex

## Scope

GH-1041 / `V140-017 Add read-only execution dashboard` 只为 v0.14.0 testnet trading closed loop 增加 Dashboard 只读执行状态面。

该 Dashboard surface 消费 GH-1040 已生成的 `ReleaseV0140ExecutionEventLogReport` 摘要证据，展示：

- Strategy Signal
- OrderIntent
- Risk Check
- Binance testnet Execution
- OMS Event Log
- Reconciliation
- Read-only Dashboard Status

## Source Contract

Dashboard target 不直接依赖 ExecutionEngine target，也不重新运行 adapter / OMS / reconciliation runtime。它只消费 Dashboard-safe input：

- `ReleaseV0140ReadOnlyExecutionDashboardLogInput`
- `ReleaseV0140ReadOnlyExecutionDashboardRow`
- `ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel`

输入字段只允许保存 redacted evidence ID、事件数量、状态 label、产品范围和策略范围。

## Validation Anchors

- `GH-1041-READ-ONLY-EXECUTION-DASHBOARD`
- `GH-1041-EXECUTION-STATUS-SURFACE`
- `GH-1041-NO-DASHBOARD-COMMANDS`
- `TVM-RELEASE-V0140-READ-ONLY-EXECUTION-DASHBOARD`

## Boundary

GH-1041 不授权以下能力：

- production trading
- production secret read
- production endpoint connection
- broker endpoint connection
- Dashboard command surface
- trading button
- order form
- live command
- submit / cancel / replace
- production cutover

`productionTradingEnabledByDefault` 必须保持 `false`。Dashboard 只能显示 testnet evidence 和 reconciliation 状态，不能触发任何订单命令。

## Validation

必须通过：

- `swift test --filter AppTests/testGH1041DashboardReadOnlyExecutionSurfaceShowsClosedLoopEvidenceWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1041DashboardReadOnlyExecutionSurfaceIsAnchoredInV0140Guards`
- `bash checks/verify-v0.14.0-read-only-execution-dashboard.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-goals

- 不实现生产交易。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送真实 submit / cancel / replace。
- 不扩展 Binance 以外 venue。
- 不扩展 EMA / RSI 以外 active strategy。
- 不授权 production cutover。
