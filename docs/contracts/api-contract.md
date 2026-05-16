# API Contract

API Contract 必须先于真实 API route 或 runtime command 实现。

MTPRO 第一版没有 HTTP API。

这里的 API 指 Swift module 内部的 stable command / query contract。

## 第一版 Command / Query

| Contract | 类型 | 说明 |
| --- | --- | --- |
| MarketDataQuery | Query | 查询 read-only market data projection |
| BacktestCommand | Command | 请求运行回测 |
| PaperSessionCommand | Command | 请求启动 paper session |
| RiskEvaluationQuery | Query | 查询风险判断 |
| PortfolioQuery | Query | 查询组合投影 |
| EventReplayCommand | Command | 请求 replay event log |

## 边界

- 不提供 live order command。
- 不提供 broker account command。
- 不提供 signed endpoint command。
- 不直接返回 runtime object 给 UI。

## MTP-11 Command / Query 细化

日期：2026-05-17

执行者：Codex

`BacktestCommand` 在 MTP-11 中绑定：

- `runID`
- `MTPROEMACrossStrategyConfiguration`
- `MarketDataQuery`

`PaperSessionCommand` 在 MTP-11 中绑定：

- `sessionID`
- `MTPROEMACrossStrategyConfiguration`
- `MarketDataQuery`
- `riskProfileID`
- `executionMode == paper`

新增事件流契约：

- Backtest stream：`requested` -> `signalGenerated...` -> `completed`
- Paper stream：`sessionRequested` -> `signalGenerated...` -> `sessionCompleted`

新增一致性契约：

- `MTPROBacktestPaperParityResult.sameStrategy`
- `MTPROBacktestPaperParityResult.sameMarketData`
- `MTPROBacktestPaperParityResult.matchingSignalTimeline`
- `MTPROBacktestPaperParityResult.isConsistent`

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不把真实执行动作暴露为 API contract。
