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

## MTP-17 File Event Log Replay 细化

日期：2026-05-18

执行者：Codex

`EventReplayCommand` 在 MTP-17 中可作用于文件事件日志事实源：

- `FileEventLogStore.replay(_:)`
- `PersistenceReplayBoundary.init(fileStore:)`

新增文件事实源契约：

- 写入对象只能是 `EventEnvelope`。
- replay 输出只能是 `EventReplayResult`。
- sequence 必须保持 append-only 连续递增。
- 文件格式不作为 Command / Query API 暴露。

边界确认：

- 不新增 HTTP API。
- 不新增 database table API。
- 不新增 SQLite / DuckDB adapter command。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。

## MTP-18 SQLite Runtime Projection Adapter 细化

日期：2026-05-18

执行者：Codex

`EventReplayCommand` 在 MTP-18 中可以通过 SQLite runtime projection adapter 重建并查询运行时投影：

- `PersistenceReplayBoundary.rebuildSQLiteRuntimeProjection(from:using:)`
- `SQLiteRuntimeProjectionAdapter.rebuild(from: [EventEnvelope])`
- `SQLiteRuntimeProjectionAdapter.rebuild(from: EventReplayResult)`
- `SQLiteRuntimeProjectionAdapter.querySnapshot()`

新增 adapter 契约：

- 输入只能是 append-only event log replay 后的 `EventEnvelope` 集合。
- 输出只能是 `SQLiteRuntimeProjectionSnapshot`。
- SQLite 只作为 Paper / Risk / Portfolio runtime projection 的私有 adapter。
- UI / API / ViewModel 不得依赖 SQLite schema、SQL statement 或 ORM model。

边界确认：

- 不新增 HTTP API。
- 不新增 database table API。
- 不新增 migration command。
- 不新增 ORM contract。
- 不新增 DuckDB adapter command。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。

## MTP-19 DuckDB Analytical Projection Adapter 细化

日期：2026-05-18

执行者：Codex

`EventReplayCommand` 在 MTP-19 中可以通过 DuckDB analytical projection adapter 重建并查询分析投影：

- `PersistenceReplayBoundary.rebuildDuckDBAnalyticalProjection(from:using:)`
- `DuckDBAnalyticalProjectionAdapter.rebuild(from: [EventEnvelope])`
- `DuckDBAnalyticalProjectionAdapter.rebuild(from: EventReplayResult)`
- `DuckDBAnalyticalProjectionAdapter.querySnapshot()`

新增 adapter 契约：

- 输入只能是 append-only event log replay 后的 `EventEnvelope` 集合。
- 输出只能是 `DuckDBAnalyticalProjectionSnapshot`。
- DuckDB 只作为 market data、backtest run、order book research run 和 signal timeline 的私有分析投影 adapter。
- UI / API / ViewModel 不得依赖 DuckDB schema、SQL statement、table、column 或 payload 编码。

边界确认：

- 不新增 HTTP API。
- 不新增 database table API。
- 不新增 migration command。
- 不新增 ORM contract。
- 不新增 SQLite runtime adapter command。
- 不新增 Binance adapter command。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。

## MTP-20 Binance Client Command / Query 边界

日期：2026-05-18

执行者：Codex

MTP-20 不新增 HTTP API，也不新增 live / broker / signed command。

`MarketDataQuery` 的后续实现可以通过 `BinancePublicMarketDataClient` 获取 public payload，
但 client 仍是 Adapters 模块内部边界，不把 raw network response、URL、headers 或 transport
对象暴露为 API contract。

新增内部边界：

- `BinancePublicMarketDataClient.payload(for:)`：只接受 public read-only request contract。
- `BinancePublicMarketDataClient.exchangeInfo / klines / recentTrades / bestBidAsk / depthSnapshot / depthDelta`：
  只返回稳定 Core market data model。

边界确认：

- 不新增 HTTP API。
- 不新增 database table API。
- 不新增 Binance signed/account/order command。
- 不新增 listenKey user data stream command。
- 不新增 live order command。
- 不新增 broker account command。
- 不把 API key、signature、headers 或 transport object 暴露给 UI / App / Persistence。

## MTP-21 Runtime Ingest Command / Query 边界

日期：2026-05-18

执行者：Codex

MTP-21 不新增 HTTP API，也不新增 database table API、live / broker / signed command。

新增内部运行时边界：

- `PublicMarketDataIngestPlan`：作为本地行情 ingest 输入 contract。
- `MarketDataIngestReplayProjectionWorkflow.run(_:)`：执行 public market data ingest -> event log -> replay -> projection snapshots。
- `MarketDataIngestReplayProjectionResult`：只返回 Core / Persistence 稳定模型和 replay evidence，不返回 transport、URL、headers、SQL row、table 或 ORM object。

边界确认：

- Runtime 可以依赖 `Adapters`、`Core` 和 `Persistence` 做跨模块编排。
- `App` / ViewModel 仍不得直接调用 Binance adapter。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不把 SQLite / DuckDB schema 暴露为 API contract。

## MTP-23 Report Artifact / Read Model 边界

日期：2026-05-18

执行者：Codex

MTP-23 不新增 HTTP API，也不新增 live / broker / signed command。

Report artifact 由 App 层 read model 派生，不作为新的交易 command：

- `ReportReadModel`：从 projection snapshots / event timeline 生成最小 Research -> Backtest -> Report 观察面。
- `ResearchBacktestReportArtifact`：绑定 backtest、research、Paper projection evidence 和 execution authorization。
- `ReportViewModel`：给 Dashboard shell 提供只读报告快照。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 database table API。
- 不把 report artifact 解释为订单、账户或执行授权。
