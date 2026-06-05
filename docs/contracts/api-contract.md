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
| PaperSessionLocalControlCommand | Command | 请求本地控制 paper session |
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
MTP-42 之后，当前内部 update source 已从 allowed risk decision 收窄为 replay 后的 simulated fill evidence。

新增内部 Core event / value contract：

- `PaperPortfolioProjectionUpdate`：消费 replay 后的 `PaperSimulatedFillEvidence`，生成 paper-only portfolio exposure update。
- `PortfolioEvent.paperProjectionUpdated`：把 update 写入 `.portfolio` event stream，供 replay / SQLite runtime projection 消费。

契约要求：

- 输入 simulated fill 必须来自 paper-only allowed order，且必须经 append-only event log replay 取得。
- update 必须保持 `executionMode == paper`，并记录 proposal、session、risk profile、side、fill ID、source sequence 和 `paperProjection` exposure。
- `authorizesTradingExecution`、`readsRealAccountBalance` 和 `syncsBrokerPosition` 必须固定为 `false`。
- Codable 解码不能绕过 simulated fill evidence 来源，不能恢复真实交易授权、真实账户余额读取或 broker position sync。

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

## MTP-40 Simulated Fill Evidence 内部模型边界

日期：2026-05-19

执行者：Codex

MTP-40 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core value contract：

- `PaperSimulatedFillAssumption`：保存 deterministic 模拟成交假设，固定 filled quantity、fill price、liquidity role 和 MTP-27 fixed execution cost assumptions。
- `PaperSimulatedFillEvidence`：从 `PaperOrderIntent` 派生本地 simulated fill evidence，并携带 fixed cost evidence、workflow stage、event stream 和 capability flags。
- `PaperSimulatedFillFixture`：提供 deterministic allowed fill evidence，用于 XCTest 和 PR evidence。

契约要求：

- 输入 order intent 必须是 `intentCreated`，且 risk decision status 必须是 `allowed`。
- filled quantity 和 fill price 必须与上游 order intent 完全一致，当前不表达部分成交、价格改善、动态滑点或执行优化。
- Simulated fill 必须固定 `executionMode == paper`、`proposalAuthorization == paperIntentOnly`、`workflowStage == simulatedFill`、`eventStream == .paper` 和 `evidenceKind == simulatedFill`。
- Cost evidence 必须复用 MTP-27 fixed fee / slippage assumptions，不读取交易所费率表、account tier、broker fill 或真实成交回报。
- Codable 解码必须拒绝非 paper mode、risk-rejected intent、real fill、broker fill、account update、trading authorization、signed endpoint、broker action 或 Live trading capability。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不实现真实撮合。
- 不处理真实成交回报。
- 不实现动态滑点模型、交易所费率表或执行成本优化。
- 不写 event log，不新增 projection / ViewModel，不更新真实账户。
- 不把 simulated fill evidence 解释为真实成交、broker fill、account update、真实订单授权或 Live execution。

## MTP-41 Paper Execution Decision 内部模型边界

日期：2026-05-19

执行者：Codex

MTP-41 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core value contract：

- `PaperExecutionDecisionStatus`：表达 allowed / blocked 本地执行决策状态，并锁定与 risk decision status 一致。
- `PaperExecutionDecision`：组合 `PaperActionProposalRiskDecision`、allowed 路径的 `PaperOrderIntent` 和 `PaperSimulatedFillEvidence`，或 blocked 路径的 blocker evidence。
- `PaperExecutionDecisionLink.decide`：提供本地无副作用串联函数，不访问网络、数据库或 broker。
- `PaperExecutionDecisionFixture`：提供 deterministic allowed / blocked decision flow，用于 XCTest 和 PR evidence。

契约要求：

- allowed risk decision 必须提供 order ID、fill ID、simulated fill assumption 和 source order intent sequence，才能生成 paper-only order / fill evidence。
- blocked risk decision 不得携带 order ID、fill ID、simulated fill assumption 或 source order intent sequence。
- `PaperExecutionDecision` 必须固定 `executionMode == paper`、`proposalAuthorization == paperIntentOnly`、`workflowStage == paperExecutionDecision`、`eventStream == .paper` 和 `evidenceKind == paperExecutionDecision`。
- Codable 解码必须拒绝 status mismatch、blocked order bypass、非 paper mode、trading authorization、signed endpoint、broker action、real order、real fill、broker fill 或 account update capability。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不实现完整 execution engine。
- 不实现完整风险引擎。
- 不写 event log，不新增 replay / projection / ViewModel。
- 不把 paper execution decision 解释为真实订单授权、真实成交、broker fill、account update 或 Live execution。

## MTP-42 Paper Execution Event Replay Projection 内部边界

日期：2026-05-19

执行者：Codex

MTP-42 不新增 HTTP API，也不新增 live / broker / signed command。

新增内部 Core event / replay contract：

- `PaperEvent.executionDecisionRecorded`：记录 paper execution decision fact。
- `PaperEvent.orderIntentRecorded`：记录 allowed paper order intent fact。
- `PaperEvent.simulatedFillRecorded`：记录 allowed simulated fill evidence fact。
- `PaperExecutionEventLogBoundary`：按 decision -> order -> fill 顺序写入 `.paper` stream，并校验 source order sequence。
- `PaperExecutionReplayProjectionPath`：只从 replayed simulated fill envelope 生成 `PaperPortfolioProjectionUpdate`。

契约要求：

- allowed decision 才能写入 order 和 fill；blocked decision 只能写入 decision fact。
- portfolio update 只能从 replay 后的 `simulatedFillRecorded` fact 派生，不能直接从 risk decision、broker fill、account update 或真实账户状态派生。
- replay summary 必须保留 execution decision IDs、paper order IDs、simulated fill IDs 和 paper-only boundary flags。
- 所有交易能力旗标必须继续固定为 `false`。

边界确认：

- 不新增 `Command` case。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不实现生产级 event sourcing 或 schema migration framework。
- 不重写 FileEventLogStore。
- 不接 broker event replay。
- 不读取真实账户、真实 position 或 broker fill。
- 不把 replay / projection evidence 解释为真实订单授权、真实成交、broker fill、account update 或 Live execution。

## MTP-47 Paper Workflow Workbench Control Shell API 边界

日期：2026-05-20

执行者：Codex

MTP-47 不新增 HTTP API，不新增 `Command` case，也不实现 session control Command Model。

新增 App 层合同 fixture：

- `PaperWorkflowSessionControl`：只定义未来 session-level local controls 的允许集合 `start` / `pause` / `close` / `reset`。
- `PaperWorkflowDashboardInformationArchitecture`：记录 Dashboard 信息架构、read-model-only 来源、观察面和 forbidden capability。

契约要求：

- session-level control 名称只能用于后续 paper-only local control shell。
- order-level command 必须保持禁止。
- Dashboard IA 不得调用 Runtime、Adapters、Binance signed endpoint、account endpoint、listenKey、broker 或真实订单 API。
- `PaperWorkflowDashboardInformationArchitecture` 的合同验证必须拒绝 order-level command、非 read-model-only source、提前实现 Command Model、UI controls 或 Event Timeline。

边界确认：

- 不实现 Command Model。
- 不新增 UI 控件。
- 不写 event log，不新增 replay / projection。
- 不提供 order submit / cancel / replace。
- 不实现 OMS。
- 不接 signed endpoint、account endpoint、listenKey、broker action 或 Live execution。

## MTP-48 Paper Session Local Control Command Model

日期：2026-05-20

执行者：Codex

MTP-48 新增 Swift module 内部 `Command` case 和本地 paper-only session control value model；仍不新增 HTTP API，不写 event log，不实现 UI 控件。

新增 Core command contract：

- `PaperSessionLocalControlAction`：只允许 `start` / `pause` / `close` / `reset`。
- `PaperSessionLocalControlScope`：固定为 `local paper session`。
- `PaperSessionLocalControlLevel`：固定为 `session`，拒绝 order-level command。
- `PaperSessionLocalControlRejectedReason`：记录 raw request 被拒绝原因，包括 non-session-level control、order-level command、real order command、broker-facing command、非 paper execution mode 和空 ID。
- `PaperSessionLocalControlCommand`：保存已接受的本地 Paper session control intent，所有 order / broker / signed endpoint / real order capability flags 固定为 false。
- `Command.controlPaperSession`：把已接受 command 纳入 Core 内部 command 聚合，但不代表 runtime side effect。

契约要求：

- command 只能作用于本地 Paper session。
- command 必须 `executionMode == paper`、scope 必须是 `local paper session`、level 必须是 `session`。
- `submit` / `cancel` / `replace`、broker action、signed endpoint、account endpoint、listenKey、Live trading 和 order-level command 必须被 raw validation 拒绝。
- Codable 解码必须拒绝任何试图恢复 order-level command、真实交易授权、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单 submit / cancel / replace 的 payload。

边界确认：

- 不实现 session-level control -> event boundary 串联。
- 不新增 SwiftUI 控件、按钮或表单。
- 不实现 OMS、order submit / cancel / replace、broker adapter、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-49 Paper Session Local Control Event Boundary

日期：2026-05-20

执行者：Codex

MTP-49 将 MTP-48 的 session-level local control validation 串入本地 paper-only append-only event boundary；仍不新增 HTTP API、不实现 UI 控件、不启动完整 workflow engine。

新增 Core event contract：

- `PaperSessionLocalControlApplied`：把 accepted `PaperSessionLocalControlCommand` 记录为 `.paper` stream 中的本地 session control fact。
- `PaperSessionLocalControlEventAppendResult`：记录 accepted / rejected validation 写入 event log 后的 envelope 和 evidence。
- `PaperSessionLocalControlEventLogBoundary`：只消费 `PaperSessionLocalControlValidation`，把 accepted command 映射为 `PaperEvent.sessionControlApplied`，把 rejected reason 映射为 `PaperEvent.sessionControlRejected`。
- `PaperEvent.sessionControlApplied`：表示本地 Paper session control 已被记录，不表示订单、成交或 broker side effect。
- `PaperEvent.sessionControlRejected`：表示 invalid raw request 的 rejected reason 已被记录，供后续 evidence / read model 消费。

契约要求：

- accepted command 必须保持 `paperOnlyBoundaryHeld == true`，并固定写入 `.paper` stream。
- rejected reason 必须保持可 replay 的本地 evidence，不得恢复 order-level、broker-facing 或真实订单行为。
- event sequence 只能由 `AppendOnlyEventLog` 单调分配，调用方不得覆盖 sequence。
- replay / projection / App matcher 必须显式识别新增 paper event case；当前 issue 不扩展 projection schema 或 ViewModel。

边界确认：

- 不生成 paper order command 或 real order command。
- 不实现 UI 控件、Event Timeline、Evidence Explorer 或完整 workflow engine。
- 不实现 OMS、order submit / cancel / replace、broker adapter、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-50 Paper Workflow Observability Read Model / ViewModel Boundary

日期：2026-05-20

执行者：Codex

MTP-50 不新增 HTTP API，不新增 external command endpoint，也不把 ViewModel 暴露为交易入口。

新增 App 层 contract：

- `PaperWorkflowObservabilityReadModel`：从既有 Dashboard read model 聚合 paper workflow observability evidence。
- `PaperWorkflowObservabilityViewModel`：输出 session status、blocked / allowed evidence、chain coverage、replay freshness 和 report artifact status。
- `PaperWorkflowReplayFreshnessStatus`：只描述本地 replay evidence 与 event timeline sequence 的 freshness。

契约要求：

- UI-facing shape 必须是 ViewModel / Read Model。
- 不允许 UI 或 tests 依赖 database schema、adapter request 或 runtime object。
- ViewModel 必须保持 `readModelOnlyBoundaryHeld == true`、`paperOnlyBoundaryHeld == true`。
- `authorizesTradingExecution`、`authorizesLiveTrading`、`touchesBrokerAction`、`providesOrderLevelCommand` 必须保持 false。

边界确认：

- 不实现 UI redesign、Event Timeline explorer、order-level command、OMS、broker adapter、signed endpoint、account endpoint、listenKey 或 Live execution。
- 不新增 projection schema，不写 event log，不触发 replay side effect，不提交 / 撤销 / 替换真实订单。

## MTP-51 Paper Workflow Event Timeline / Evidence Explorer Boundary

日期：2026-05-20

执行者：Codex

MTP-51 不新增 HTTP API，不新增 external command endpoint，不新增 Runtime command，也不把 Explorer 暴露为交易、风控或持仓管理入口。

新增 App 层 contract：

- `PaperWorkflowEvidenceExplorerSection`：固定 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact 七个只读分区。
- `PaperWorkflowEvidenceLinkSummary`：表达 evidence ID、分区、label 和可选 source sequence。
- `PaperWorkflowEventTimelineItem`：表达 timeline item 的 sequence、recorded time、stream、summary 和 evidence links。
- `PaperWorkflowEvidenceExplorerReadModel`：只组合既有 Dashboard read models 和 append-only event timeline。
- `PaperWorkflowEvidenceExplorerViewModel`：输出 deterministic Codable snapshot、section snapshots、read-only filter snapshot 和 no-command boundary flags。

契约要求：

- Explorer 必须只消费 stable read model projection。
- filter 只在 ViewModel snapshot 内筛选分区，不得变成查询语言或 adapter / runtime 调用。
- `readModelOnlyBoundaryHeld` 必须为 true。
- `authorizesTradingExecution`、`authorizesLiveTrading`、`touchesBrokerAction`、`providesCommandSurface`、`providesOrderLevelCommand` 和 `supportsQueryLanguage` 必须保持 false。

边界确认：

- 不实现 UI redesign、operations console、report archive/export、完整查询语言、order-level command、OMS、broker adapter、signed endpoint、account endpoint、listenKey 或 Live execution。
- 不新增 projection schema，不写 event log，不触发 replay side effect，不直接读取 Persistence adapter，不提交 / 撤销 / 替换真实订单。
