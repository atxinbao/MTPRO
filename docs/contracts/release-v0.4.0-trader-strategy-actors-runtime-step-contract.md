# Release v0.4.0 Trader Strategy Actors Runtime Step Contract

日期：2026-06-13  
执行者：Codex

## Scope

`V040-05-TRADER-STRATEGY-ACTORS-RUNTIME-STEP`

GH-698 在 `Trader` target 内定义 Trader-owned EMA / RSI strategy actor runtime step。该 step 只消费来自 MessageBus journal 的 run-scoped market event evidence，并输出 `StrategyIntentMessage` 和 intent MessageBus journal evidence。

## Required Evidence

- `V040-05-EMA-RSI-RUN-SCOPED-INTENTS`：EMA 与 RSI 均必须产生带同一 `ReleaseV040RehearsalRunContext.runID` 的 intent evidence。
- `V040-05-MESSAGEBUS-MARKET-CONSUMPTION`：Trader input 只能依赖 MessageBus journal envelope、`MarketBar` 和 upstream evidence id；不得 import DataEngine implementation。
- `V040-05-NO-STRATEGY-EXECUTIONCLIENT-PATH`：strategy actor 输出只能是 intent/proposal evidence；不得直连 ExecutionClient、broker、OMS、CommandGateway bypass 或 live command。
- `TVM-RELEASE-V040-TRADER-STRATEGY-ACTORS-RUNTIME-STEP`：trading validation matrix anchor。

## Boundary

GH-698 不新增非 EMA / RSI strategy，不连接 live market data endpoint，不读取 secret，不连接 production endpoint / broker endpoint，不提交真实 order，不授权 production cutover。后续 RiskEngine / ExecutionEngine / OMS gate 只能由后续 issue 接入。

## Validation

- `swift test --filter TargetGraphTests/testGH698TraderStrategyActorsConsumeMessageBusMarketEventsAndEmitRunScopedIntents`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
