# Release v0.3.0 ExecutionEngine / OMS Rehearsal Lifecycle Contract

日期：2026-06-13  
执行者：Codex

## Scope

`GH-662 / V030-06 Add ExecutionEngine / OMS rehearsal lifecycle` 固定 Release v0.3.0 的 ExecutionEngine / OMS rehearsal lifecycle：

- `V030-06-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE`
- `V030-06-RISK-APPROVED-INTENT-TO-OMS`
- `V030-06-OMS-STATE-COVERAGE`
- `V030-06-ILLEGAL-TRANSITION-REJECTED`
- `V030-06-OMS-REPLAY-EVIDENCE`
- `TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE`

该 lifecycle 只消费 #661 RiskEngine rehearsal gate 的 allow / reject decision evidence，
并输出本地 OMS state transition 与 MessageBus replay evidence。

## State Coverage

#662 必须覆盖：

- `created`
- `accepted`
- `submitted-testnet-or-dry-run`
- `cancelled`
- `rejected`
- `filled-simulated`

`submitted-testnet-or-dry-run` 只是 rehearsal state label，不表示已经调用 ExecutionClient、testnet adapter、broker gateway 或 production endpoint。#663 才能在自己的 scope 内处理 Binance testnet / dry-run adapter rehearsal。

## Replay Contract

OMS transition 必须写入 append-only MessageBus journal，并通过 replay 恢复同一 transition sequence 与 final state evidence。Replay evidence 不保存 broker payload、account payload、production secret、signed request 或真实订单响应。

## Forbidden Capability Audit

#662 不授权：

- production trading default enabled。
- production endpoint auto-connect。
- production secret auto-read。
- production order submission。
- production cutover authorization。
- ExecutionClient call。
- broker gateway access。
- production OMS runtime。
- real submit / cancel / replace。
- reconciliation runtime。
- Dashboard command surface。
- CommandGateway bypass。
- RiskEngine bypass。
- Event Store bypass。
- non-Binance venue。
- non-Spot / non-USDⓈ-M Perpetual product。
- non-EMA / non-RSI active strategy。
- next milestone auto-start。

## Validation

必须运行：

- `swift test --filter TargetGraphTests/testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

#662 完成后，只有 PR merge、required check `checks` SUCCESS、issue closed / done、main fast-forward 和 worktree clean 同时成立，才允许 fresh queue preflight 推进 #663。
