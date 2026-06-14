# Release v0.6.0 Strategy Runtime Runner Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-760 V060-006 Add EMA / RSI strategy runtime runner`。

## V060-006-STRATEGY-RUNTIME-RUNNER

`V060-006-STRATEGY-RUNTIME-RUNNER`

Trader 必须提供一个本地 strategy runtime runner。该 runner 只消费 local run journal / RuntimeMessageBus 中 replay 出来的 typed `DataEngineMarketEvent` envelope，并在同一 runID、streamID、correlationID 下追加 typed `StrategyIntentEvent` envelope。

## V060-006-EMA-RSI-INTENT-EVENTS

`V060-006-EMA-RSI-INTENT-EVENTS`

Runner 的 active strategy 集合固定为 EMA + RSI。EMA 必须经由 `EMAProposalRuntime` 输出 intent-only target exposure；RSI 必须经由 `RSITargetExposureIntentEmitter` 输出 intent-only target exposure。任何非 EMA / RSI active strategy 不属于 GH-760 scope。

## V060-006-DATAENGINE-CAUSAL-LINK

`V060-006-DATAENGINE-CAUSAL-LINK`

每条 strategy emission 必须保留它消费的 DataEngine market event ID。写入 RuntimeMessageBus 时，strategy event envelope 必须继续保持 append-only causation chain：第一条 strategy event 接在最后一条 DataEngine event 之后，后一条 strategy event 接在前一条 strategy event 之后。

## V060-006-SAME-RUN-JOURNAL-SEQUENCE

`V060-006-SAME-RUN-JOURNAL-SEQUENCE`

输出必须能被 `ReleaseV050DurableLocalRunJournal` 以同一个 runID replay。完整 sequence 必须从 DataEngine market event 延续到 EMA / RSI strategy intent event，不能重启 sequence、拆分 run 或改变 correlation。

## V060-006-NO-STRATEGY-EXECUTION-PATH

`V060-006-NO-STRATEGY-EXECUTION-PATH`

GH-760 只产出 strategy intent。Strategy 不能调用 ExecutionClient、broker、OMS、CommandGateway、signed endpoint、account endpoint、private stream、submit / cancel / replace 或 production cutover。production trading 仍默认关闭。

## TVM-RELEASE-V060-STRATEGY-RUNTIME-RUNNER

`TVM-RELEASE-V060-STRATEGY-RUNTIME-RUNNER`

Validation 入口：

- `swift test --filter TargetGraphTests/testGH760StrategyRuntimeRunnerConsumesDataEngineJournalAndEmitsEMARSIIntentEvents`
- `bash checks/verify-v0.6.0-strategy-runtime-runner.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-760 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不连接 production endpoint，不读取 production secret，不调用 broker，不提交真实订单，不授权 production cutover。
