# Release v0.4.0 RiskEngine Pre-trade Rehearsal Gate Contract

日期：2026-06-13  
执行者：Codex

## Scope

`V040-06-RISKENGINE-PRETRADE-REHEARSAL-GATE`

GH-699 在 `RiskEngine` target 内定义 v0.4.0 pre-trade rehearsal gate。该 gate 消费 #698 输出的 neutral `StrategyIntentMessage` 和 MessageBus intent envelope，产出 run-scoped RiskEngine decision evidence。

## Required Evidence

- `V040-06-ALLOW-REJECT-BLOCK-DECISIONS`：RiskEngine 必须产出 allow、reject 与 blocked 三类 deterministic decision。
- `V040-06-KILL-SWITCH-NO-TRADE-GUARDS`：kill switch 与 no-trade policy 必须能阻断 execution eligibility。
- `V040-06-EXECUTIONENGINE-RISK-APPROVED-ONLY`：只有 allow decision 的 strategy intent 可以作为后续 ExecutionEngine rehearsal 输入。
- `TVM-RELEASE-V040-RISKENGINE-PRETRADE-REHEARSAL-GATE`：trading validation matrix anchor。

## Boundary

GH-699 不实现 ExecutionEngine / OMS order lifecycle，不调用 ExecutionClient、broker、CommandGateway 或 live command surface，不连接 endpoint，不读取 secret，不提交真实 order，不授权 production cutover。后续 ExecutionEngine / OMS 只能消费 RiskEngine allow evidence。

## Validation

- `swift test --filter TargetGraphTests/testGH699RiskEnginePreTradeRehearsalGateAllowsRejectsAndBlocksRunScopedIntents`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
