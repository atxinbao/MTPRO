# Production Cutover Incident Stop / Rollback / No-Trade Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-507 Define incident stop / rollback / no-trade state gate`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 incident stop / rollback / no-trade state gate。它只表达事故阻断、回滚准备、no-trade 优先级和 production no-default-trading evidence，不实现 emergency stop runtime、shutdown / restore runtime、production operations、live command、trading button、order form、broker connection、broker fill、reconciliation 或真实 submit / cancel / replace。

## GH-507-INCIDENT-STOP-ROLLBACK-NO-TRADE-GATE

`GH-507-INCIDENT-STOP-ROLLBACK-NO-TRADE-GATE`

GH-507 依赖 GH-506 manual approval / operator confirmation gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverIncidentRollbackNoTradeGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH507IncidentRollbackNoTradeGateBindsManualApprovalAndNoTradePriority`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH507IncidentRollbackNoTradeGateRejectsRuntimeCommandAndOrderBypass`

## GH-507-ROLLBACK-READINESS-CHECKLIST

`GH-507-ROLLBACK-READINESS-CHECKLIST`

Rollback readiness checklist 必须覆盖：

- incident stop
- rollback ready
- no-trade
- production blocked
- dry-run-only
- future recovery gate

每一项 checklist row 都必须包含 expected evidence 和 blocked reason，并保持 `runtimeCommandImplemented = false`。

## GH-507-NO-TRADE-STATE-PRIORITY

`GH-507-NO-TRADE-STATE-PRIORITY`

No-trade state 必须优先于任何 future production command。GH-507 不授权任何 future production command，也不允许 dry-run、script、UI 或 runtime command 绕过 no-trade state。

## GH-507-PRODUCTION-NO-DEFAULT-TRADING-EVIDENCE

`GH-507-PRODUCTION-NO-DEFAULT-TRADING-EVIDENCE`

Production default 必须保持 no-trading / blocked / dry-run。GH-507 不得打开 production trading default，不得连接 broker，不得提交、撤销或替换真实订单。

## GH-507-NO-PRODUCTION-RUNTIME-COMMAND

`GH-507-NO-PRODUCTION-RUNTIME-COMMAND`

GH-507 必须拒绝：

- emergency stop runtime
- shutdown runtime
- restore runtime
- production operations runtime
- live command surface
- trading button
- order form
- broker connection
- broker fill parser
- reconciliation runtime
- no-trade bypass
- production trading enabled by default
- real submit / cancel / replace

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
