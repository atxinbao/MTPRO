# Release v0.3.0 RiskEngine Rehearsal Gate Contract

日期：2026-06-13  
执行者：Codex

## Scope

`GH-661 / V030-05 Add RiskEngine rehearsal gate` 固定 Release v0.3.0 的 RiskEngine rehearsal gate：

- `V030-05-RISKENGINE-REHEARSAL-GATE`
- `V030-05-MESSAGEBUS-STRATEGY-INTENT-RISK-INPUT`
- `V030-05-ALLOW-REJECT-LIMIT-EVIDENCE`
- `V030-05-KILL-SWITCH-NO-TRADE-REJECT-EVIDENCE`
- `V030-05-AUDITABLE-RISK-DECISION-EVIDENCE`
- `TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE`

该 gate 只消费 #660 Trader / EMA / RSI 通过 MessageBus 产生的 `StrategyIntentMessage`
和 `MessageBusJournalEnvelope`，并输出本地 deterministic allow / reject risk decision evidence。

## Runtime Boundary

RiskEngine target 不依赖 Trader target、ExecutionEngine、ExecutionClient、Binance adapter、OMS、broker gateway 或 Runtime target。#661 的输入是中性 MessageBus intent trace；输出是可审计 risk decision evidence，不是 broker command、OMS order、ExecutionClient request 或 Dashboard / CLI command。

## Decision Coverage

#661 必须覆盖：

- valid rehearsal intent allow decision。
- invalid rehearsal intent reject decision。
- notional / aggregate exposure limit gate。
- kill switch reject decision。
- no-trade reject decision。
- MessageBus replay trace 与 intent instrument 对齐。
- production trading disabled by default evidence。

## Forbidden Capability Audit

#661 不授权：

- production trading default enabled。
- production endpoint auto-connect。
- production secret auto-read。
- production order submission。
- production cutover authorization。
- non-Binance venue。
- non-Spot / non-USDⓈ-M Perpetual product。
- non-EMA / non-RSI active strategy。
- CommandGateway bypass。
- ExecutionEngine bypass。
- OMS bypass。
- ExecutionClient access。
- broker gateway access。
- Event Store bypass。
- kill switch bypass。
- no-trade bypass。
- next milestone auto-start。

## Validation

必须运行：

- `swift test --filter TargetGraphTests/testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

#661 完成后，只有 PR merge、required check `checks` SUCCESS、issue closed / done、main fast-forward 和 worktree clean 同时成立，才允许 fresh queue preflight 推进 #662。
