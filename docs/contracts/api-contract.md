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
| OrderBookImbalanceResearchCommand | Command | 请求运行订单簿失衡研究 |
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
- `EMACrossStrategyConfiguration`
- `MarketDataQuery`

`PaperSessionCommand` 在 MTP-11 中绑定：

- `sessionID`
- `EMACrossStrategyConfiguration`
- `MarketDataQuery`
- `riskProfileID`
- `executionMode == paper`

新增事件流契约：

- Backtest stream：`requested` -> `signalGenerated...` -> `completed`
- Paper stream：`sessionRequested` -> `signalGenerated...` -> `sessionCompleted`

新增一致性契约：

- `BacktestPaperParityResult.sameStrategy`
- `BacktestPaperParityResult.sameMarketData`
- `BacktestPaperParityResult.matchingSignalTimeline`
- `BacktestPaperParityResult.isConsistent`

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不把真实执行动作暴露为 API contract。

## MTP-12 Command / Event Flow 细化

日期：2026-05-17

执行者：Codex

新增 `OrderBookImbalanceResearchCommand`，绑定：

- `researchID`
- `OrderBookImbalanceStrategyConfiguration`
- `MarketDataQuery`

新增 `Command.runOrderBookImbalanceResearch`，只授权本地研究链路，不代表可交易命令。

新增研究事件流契约：

- Order book imbalance research stream：`requested` -> `signalGenerated...` -> `completed`

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 futures leverage / margin command。
- 不把订单簿失衡信号暴露为真实订单动作。

## MTP-13 Replay / Projection 细化

日期：2026-05-17

执行者：Codex

`EventReplayCommand` 在 MTP-13 中绑定持久化投影重建边界：

- `PersistenceReplayBoundary.replay(_:)`
- `PersistenceReplayBoundary.rebuildMarketDataCache(from:)`
- `PersistenceReplayBoundary.rebuildSQLiteRuntimeProjection(from:)`
- `PersistenceReplayBoundary.rebuildDuckDBAnalyticalProjection(from:)`

新增投影契约：

- SQLite runtime projection：paper session、risk rejection、portfolio projection。
- DuckDB analytical projection：market data、backtest run、order book research run、analytical signal timeline。

边界确认：

- 不新增 HTTP API。
- 不新增 database table API。
- 不把 ORM model 暴露为 API contract。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增真实数据库迁移 command。
