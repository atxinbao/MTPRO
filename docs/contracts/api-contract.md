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

MTP-25 加固补充：

- `BacktestCommand.marketData.range` 和 `PaperSessionCommand.marketData.range` 必须覆盖实际输入 bars 的完整 interval。
- range 过窄时，Backtest / Paper event flow 都必须拒绝运行，不得输出 parity 假阳性。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不把真实执行动作暴露为 API contract。

## MTP-31 Paper Session Lifecycle Command / Event 边界

日期：2026-05-19

执行者：Codex

MTP-31 不新增 HTTP API，也不新增 live / broker / signed command。

新增或细化的 Core 内部事件契约：

- `PaperSessionLifecycleState`：定义 `started`、`updated`、`closed` 三个 paper-only lifecycle 状态。
- `PaperSessionStarted`：绑定已校验的 `PaperSessionCommand`、`sessionID` 和 `startedAt`。
- `PaperSessionUpdated`：绑定已校验的 `PaperSessionCommand`、`sessionID`、`signalCount` 和 `updatedAt`。
- `PaperSessionClosed`：绑定 `PaperSessionResult`、`sessionID`、`signalCount` 和 `closedAt`。
- `PaperEvent.sessionStarted / sessionUpdated / sessionClosed`：作为 MTP-31 后默认 Paper lifecycle facts。
- `PaperSessionEventLogBoundary.append`：只接受 `PaperEvent`，并固定写入 `.paper` event stream。

边界确认：

- `PaperSessionCommand` 仍必须 `executionMode == paper`。
- lifecycle facts 只描述本地 Paper session，不代表真实订单、broker session、account state、成交、仓位或资金。
- event log 写入边界不允许调用 Binance adapter、signed endpoint、account endpoint、order submit / cancel / replace 或 Live execution。
- 历史 `sessionRequested` / `sessionCompleted` 仍可被本地 replay 消费；新事件流默认输出 `started -> signalGenerated... -> updated -> closed`。

## MTP-32 Paper Action Proposal 内部模型边界

日期：2026-05-19

执行者：Codex

MTP-32 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core value contract：

- `PaperActionProposalSizingAssumption`：保存 deterministic quantity / reference price / liquidity role 假设。
- `PaperActionProposal`：从 `StrategySignalEvent` 派生 paper-only action intent，并携带 fixed cost evidence。
- `PaperActionProposalFixture`：提供本地 deterministic long / flat proposal evidence。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 order submit / cancel / replace command。
- 不把 proposal 解释为真实订单、真实成交、broker fill、portfolio update 或执行授权。
- Codable 解码必须保持 `executionMode == paper`、signal side mapping 和 cost evidence 一致性。

## MTP-33 Paper Action Risk Link 内部模型边界

日期：2026-05-19

执行者：Codex

MTP-33 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core evidence 边界：

- `PaperActionProposalRiskPolicy`：定义本地 deterministic risk profile 与 max paper quantity。
- `PaperActionProposalRiskDecisionStatus`：表达 `allowed` 或 `blocked`。
- `PaperActionProposalRiskDecision`：保存 proposal、risk query、source sequence、状态、可选 blocker evidence 和 evaluatedAt。
- `PaperActionProposalRiskLink.evaluate`：从 proposal 生成 `RiskEvaluationQuery`，并在本地 policy 阻断时生成 `RiskBlockerEvidence`。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 order submit / cancel / replace command。
- 不新增 broker rejection fallback。
- 不把 allowed decision 解释为订单授权、真实风控通过、真实成交或 portfolio update。
- blocked decision 只代表本地 Paper blocker evidence，不代表 broker 拒单或 Live fallback。

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

## MTP-27 Execution Cost Evidence 边界

日期：2026-05-18

执行者：Codex

MTP-27 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core evidence 边界：

- `ExecutionCostAssumptions`：定义固定 maker fee bps、taker fee bps、fixed slippage bps 和统一 rounding scale。
- `ExecutionCostEstimateRequest`：只接收 symbol、timeframe、Backtest / Paper execution mode、reference price、quantity 和 maker / taker 角色。
- `ExecutionCostCalculator.estimate`：输出 gross notional、fee amount、slippage amount 和 total cost amount。
- `ExecutionCostParity.verify`：比较 Backtest / Paper 使用同一假设和同一输入时的 cost evidence 是否一致。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 exchange fee table API。
- 不新增 dynamic slippage model API。
- 不把 cost evidence 解释为真实成交、真实订单、账户余额、broker fill 或执行授权。

## MTP-28 Risk Blocker / Portfolio Exposure Evidence 边界

日期：2026-05-18

执行者：Codex

MTP-28 不新增 HTTP API，也不新增 live / broker / signed command。

新增或细化的内部 Core evidence 边界：

- `RiskEvaluationQuery`：保留 paperOrderID、symbol、timeframe、proposedQuantity、riskProfileID 和 `executionMode == paper`。
- `RiskBlockerEvidence`：输出 blocker reason、proposed Paper action context、risk profile 和 generatedAt。
- `PortfolioExposureSnapshot`：输出 portfolio ID、symbol、timeframe、paperQuantity、referencePrice、grossExposureNotional 和 `paperProjection` source。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 margin / leverage / position management command。
- 不把 risk blocker 或 exposure evidence 解释为真实订单、真实账户余额、broker fill 或执行授权。

## MTP-34 Paper-only Portfolio Projection Update 边界

日期：2026-05-19

执行者：Codex

MTP-34 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core event / value contract：

- `PaperPortfolioProjectionUpdate`：消费 MTP-33 的 allowed `PaperActionProposalRiskDecision`，生成 paper-only portfolio exposure update。
- `PortfolioEvent.paperProjectionUpdated`：把 update 写入 `.portfolio` event stream，供 replay / SQLite runtime projection 消费。

契约要求：

- 输入 risk decision 必须是 `allowed`，blocked decision 必须被拒绝。
- update 必须保持 `executionMode == paper`，并记录 proposal、session、risk profile、side、source sequence 和 `paperProjection` exposure。
- `authorizesTradingExecution`、`readsRealAccountBalance` 和 `syncsBrokerPosition` 必须固定为 `false`。
- Codable 解码不能恢复真实交易授权、真实账户余额读取或 broker position sync。

边界确认：

- 不新增 order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不读取真实账户余额。
- 不做 margin / leverage。
- 不做 broker position sync。
- 不把 portfolio projection update 解释为真实持仓、broker fill、真实订单或 Live execution。

## MTP-35 Paper Session Replay Evidence 边界

日期：2026-05-19

执行者：Codex

MTP-35 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core replay evidence contract：

- `PaperEvent.actionProposed`：把 paper action proposal 作为 `.paper` stream 中的 replay fact。
- `PaperSessionReplayEvidenceSummary`：输出 replay facts source、sequences、streams、session IDs、lifecycle states、proposal IDs、risk blocker evidence IDs、portfolio update IDs 和 paper-only boundary flags。
- `PaperSessionReplayPath.summarize`：消费 `EventReplayResult`，只做本地 deterministic summary。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不新增 database table API。
- 不把 replay summary 解释为真实订单、真实成交、broker event、账户状态或执行授权。
- 不绕过 append-only event log；summary 只从 replay result 派生。

## MTP-38 Paper-only Execution Workflow Contract 边界

日期：2026-05-19

执行者：Codex

MTP-38 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core contract：

- `PaperExecutionWorkflowStage`：定义 `proposal -> riskDecision -> paperExecutionDecision -> paperOrder -> simulatedFill -> portfolioProjection` 阶段顺序。
- `PaperExecutionWorkflowEvidenceKind`：记录每个阶段允许使用的 evidence 类型。
- `PaperExecutionWorkflowStageBoundary`：绑定阶段输入、输出、event stream、当前实现状态、future issue 占位和交易能力禁区。
- `PaperExecutionWorkflowContract.deterministicFixture`：固定 MTP-38 合同、stage order、`.paper` / `.risk` / `.portfolio` stream 和 paper-only capability flags。

契约要求：

- proposal event boundary 只能使用 `.paper` stream 和 `PaperActionProposal` evidence。
- risk decision event boundary 只能使用 `.risk` stream 和 `PaperActionProposalRiskDecision` evidence。
- paper execution decision、paper order 和 simulated fill 仅作为 future issue 合同占位，不在 MTP-38 实现 lifecycle、fill 或 OMS。
- portfolio projection event boundary 只能使用 `.portfolio` stream 和 `PaperPortfolioProjectionUpdate` evidence。
- Codable 解码不得恢复 `authorizesTradingExecution`、Live trading、signed endpoint、broker action 或 real order capability。

边界确认：

- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不实现 simulated fill。
- 不实现完整 OMS。
- 不把 paper execution decision、paper order 或 simulated fill 解释为真实订单授权、真实成交、broker fill 或 Live execution。

## MTP-39 Paper Order Intent / Lifecycle 内部模型边界

日期：2026-05-19

执行者：Codex

MTP-39 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core value contract：

- `PaperOrderLifecycleState`：表达 `intentCreated` 和 `rejectedByRisk` 的本地 paper-only lifecycle state。
- `PaperOrderIntent`：从 `PaperActionProposalRiskDecision` 派生 paper order intent，并携带 risk result、blocker evidence、proposal authorization、workflow stage、event stream 和 capability flags。
- `PaperOrderIntentFixture`：提供 deterministic allowed / risk-rejected evidence。

契约要求：

- allowed risk decision 必须映射为 `intentCreated`；blocked risk decision 必须映射为 `rejectedByRisk`。
- blocked intent 必须携带 blocker evidence ID；allowed intent 不得携带 blocker evidence ID。
- `PaperOrderIntent` 必须固定 `.paper` execution mode、`.paperOrder` workflow stage 和 `.paper` event stream。
- Codable 解码必须拒绝非 paper mode、risk result / lifecycle 不一致、trading authorization、signed endpoint、broker action、real order 或 simulated fill capability。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不实现 paper execution decision。
- 不实现 simulated fill。
- 不实现完整 OMS。
- 不实现 cancel / replace 工作流。
- 不把 paper order intent 解释为真实订单授权、真实成交、broker fill 或 Live execution。
