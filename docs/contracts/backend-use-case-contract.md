# Backend Use Case Contract

Backend Use Case Contract 必须先于 route / controller / runtime implementation。

MTPRO 当前没有服务端 API；这里的 backend 指 Core runtime use case。

## 第一版 Use Case

| Use Case | 输入 | 输出 | 状态 |
| --- | --- | --- | --- |
| LoadMarketData | symbol / timeframe / date range | market events | planned |
| RunBacktest | strategy config / market data range | backtest result events | planned |
| StartPaperSession | strategy config / risk config | paper session events | planned |
| RunOrderBookImbalanceResearch | order book imbalance config / order book read model inputs | research signal events | planned |
| EvaluateRisk | proposed paper order | risk decision event | planned |
| ProjectPortfolio | execution / fill events | portfolio projection | planned |
| ReplayEvents | event log range | read model rebuild result | planned |

## 边界

Use Case 不得直接返回内部 runtime object 给前端。

Use Case 输出必须先进入 read model projection，再供 UI 使用。

## MTP-10 内核契约

日期：2026-05-16

执行者：Codex

`Core` 在本事项中建立最小 actor 内核边界，用于把只读行情事件转入 cache 和 append-only event stream。

契约结构：

- `MessageBus`：基于 `AppendOnlyEventLog` 发布 `DomainEvent`，并按 `EventReplayCommand` 重放。
- `MarketDataCache`：只接收 `MarketEvent`，投影 bars、trades、best bid / ask、order book snapshot 和 order book delta。
- `DataEngine`：把只读 market event 同步写入 cache 和 MessageBus。
- `TradingKernel`：Swift actor 边界，串行管理 DataEngine、MessageBus 和 Cache。

契约要求：

- 所有 market event 必须来自 `Core` 已定义的只读行情事件模型。
- MessageBus 必须保持 monotonic sequence。
- Cache 必须能从 replay envelope 确定性重建。
- TradingKernel actor 必须在并发 ingest 时保持事件流和 cache 状态一致。

本契约不包含：

- 策略实现。
- Backtest engine。
- Paper execution engine。
- Live execution。
- 数据库适配器。
- SwiftUI 页面。
- Binance 网络客户端。

## MTP-11 EMA 回测与 Paper 一致性契约

日期：2026-05-17

执行者：Codex

`Core` 在本事项中建立 EMA cross 策略、回测事件流、Paper 会话事件流和一致性验证的最小本地契约。

契约结构：

- `EMACrossStrategyConfiguration`：定义 strategyID、symbol、timeframe、shortPeriod 和 longPeriod。
- `EMACrossStrategyContract`：只消费本地 `MarketBar` 序列，生成确定性 EMA signal timeline。
- `BacktestEventFlow`：生成 backtest requested、signalGenerated 和 completed 事件流。
- `PaperSessionEventFlow`：生成 paper sessionRequested、signalGenerated 和 sessionCompleted 事件流。
- `BacktestPaperParity`：比较 strategy、market data 和 signal timeline，生成一致性结果。

契约要求：

- short EMA period 必须大于 0，long EMA period 必须大于 0，且 shortPeriod 必须小于 longPeriod。
- Backtest / Paper command 的 `MarketDataQuery` 必须与 EMA 配置中的 symbol 和 timeframe 一致。
- Backtest / Paper command 的 `MarketDataQuery.range` 必须完整覆盖输入 market bars 的 interval，禁止使用查询窗口外数据生成 parity 结果。
- 输入 market bars 必须满足配置中的 symbol 和 timeframe。
- 输入 bars 数量必须至少覆盖 long EMA warm-up。
- Backtest 与 Paper 必须复用同一 EMA contract，确保同一输入下 signal timeline 一致。
- Paper 会话只生成本地模拟信号事件，不提交真实订单，不连接 broker。

本契约不包含：

- Live trading。
- 真实 broker / exchange action。
- 订单簿失衡策略。
- 完整 Dashboard 页面。
- 数据库 adapter。

## MTP-25 EMA parity 加固

日期：2026-05-18

执行者：Codex

MTP-25 在 MTP-11 契约基础上加固 `RunBacktest` 与 `StartPaperSession` 的行情查询边界：

- `MarketDataQuery.range` 必须覆盖本次 EMA 计算所用 bars 的最早 interval start 和最晚 interval end。
- 同一 deterministic fixture 下，Backtest 与 Paper 必须锁定相同 strategy config、symbol、timeframe、query range、warm-up 后首个 signal timestamp、direction timeline 和 signal sample。
- query range 过窄时，Backtest 与 Paper 都必须拒绝运行，不得生成看似一致的 parity 结果。

本加固仍不包含：

- Live trading。
- 真实 broker / exchange action。
- 真实 Binance 网络验证。
- 完整 Paper execution 工作流。

## MTP-31 Paper Session Lifecycle 和事件边界

日期：2026-05-19

执行者：Codex

`StartPaperSession` 在本事项中获得 paper-only lifecycle facts 和 event log 写入边界，但仍不进入完整 Paper execution engine。

契约结构：

- `PaperSessionLifecycleState`：定义 `started`、`updated`、`closed`。
- `PaperSessionStarted`：记录本地 Paper session 启动事实。
- `PaperSessionUpdated`：记录本地 signal timeline 刷新事实和 `signalCount`。
- `PaperSessionClosed`：记录本地 Paper session 关闭事实和最终 `PaperSessionResult`。
- `PaperSessionEventFlow.start`：默认输出 `sessionStarted -> signalGenerated... -> sessionUpdated -> sessionClosed`。
- `PaperSessionEventLogBoundary`：把 `PaperEvent` 固定写入 `.paper` stream，保持 append-only facts source。

契约要求：

- 所有 Paper lifecycle facts 必须来自 `executionMode == paper` 的 `PaperSessionCommand`。
- lifecycle fixture 必须 deterministic，固定 `startedAt`、`updatedAt`、`closedAt` 和 event log `recordedAt`。
- event log sequence 必须保持从 1 开始连续递增，并可通过 `.paper` stream replay。
- lifecycle updated 的 `signalCount` 必须非负，并只表达本地 signal samples 数量。
- Paper lifecycle events 不得被解释为 action proposal、risk decision、portfolio update、真实订单或 broker 状态。

本契约不包含：

- action proposal。
- portfolio projection update。
- 完整 Paper execution engine。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-32 Paper Action Proposal 最小模型

日期：2026-05-19

执行者：Codex

`StartPaperSession` 在本事项中获得 strategy signal -> paper-only action intent 的最小提案模型，但仍不进入订单管理、真实成交或 portfolio update。

契约结构：

- `PaperActionProposalSide`：把 `StrategySignalEvent.direction` 映射为 paper-only side，`long -> buy`，`flat -> hold`。
- `PaperActionProposalSizingAssumption`：记录 proposal fixture 使用的 quantity、reference price、liquidity role 和 MTP-27 deterministic cost assumptions。
- `PaperActionProposal`：绑定 proposalID、sessionID、strategy signal、symbol、timeframe、side、quantity、notional、cost evidence、paper execution mode 和 paper-only authorization。
- `PaperActionProposalFixture`：提供 deterministic long / flat proposal fixture，用于 XCTest 和 PR evidence。

契约要求：

- proposal 必须固定 `executionMode == paper`。
- proposal `executionAuthorization` 必须固定为 `paperIntentOnly`，`isExecutableAsRealOrder == false`。
- `long` signal 只能映射为 `buy` intent，`flat` signal 只能映射为 `hold` intent；当前不支持 sell、short、margin、leverage 或真实 order side。
- sizing assumption 的 quantity 必须为正数；`hold` proposal 会把本次 proposal quantity 映射为 0。
- notional 与 cost evidence 必须由同一 symbol、timeframe、reference price、quantity 和 MTP-27 fixed cost assumptions 生成。
- Codable 解码不得绕过 paper-only、signal mapping 或 cost evidence 一致性校验。

本契约不包含：

- 新增 order command。
- Paper action event log 写入。
- risk blocker 串联。
- portfolio projection update。
- 完整 execution engine 或 order management。
- broker / exchange side effect、真实 fill、signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-33 Paper Action Proposal -> Risk Blocker 链路

日期：2026-05-19

执行者：Codex

`EvaluateRisk` 在本事项中消费 MTP-32 的 paper-only proposal，并输出本地允许 / 阻断证据链。

契约结构：

- `PaperActionProposalRiskPolicy`：保存本地 deterministic risk profile、最大 paper quantity 和 blocker reason。
- `PaperActionProposalRiskDecision`：绑定 proposal、`RiskEvaluationQuery`、source sequence、允许 / 阻断状态、可选 `RiskBlockerEvidence` 和 evaluatedAt。
- `PaperActionProposalRiskLink.evaluate`：把 proposal 转成 risk query，并在超出本地 policy 时生成 blocker evidence。
- `PaperActionProposalRiskFixture`：提供 deterministic allowed / blocked 决策，用于 XCTest 和 PR evidence。

契约要求：

- 输入 proposal 必须保持 `executionMode == paper`、`paperIntentOnly` 和 `isExecutableAsRealOrder == false`。
- risk query 必须复用 proposal 的 symbol、timeframe、quantity 和 proposalID，并固定 `.paper` execution mode。
- blocked 决策必须携带 `RiskBlockerEvidence`；allowed 决策不得携带 blocker evidence。
- source sequence 必须为正数，用于回溯本地 event log envelope；它不是 broker order sequence 或交易所回报。
- 允许 / 阻断结果都不得提供 Live execution fallback、broker fallback、真实订单授权或真实风控语义。

本契约不包含：

- 完整风险引擎。
- broker rejection fallback。
- Paper action event log 写入。
- portfolio projection update。
- 完整 Paper execution workflow。
- signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-12 订单簿失衡研究链路契约

日期：2026-05-17

执行者：Codex

`Core` 在本事项中建立订单簿读模型输入、失衡信号和研究事件流契约。

契约结构：

- `OrderBookReadModelInput`：由只读 `OrderBookSnapshot` 构建，并可应用同 symbol 的 `OrderBookDelta`。
- `OrderBookImbalanceStrategyConfiguration`：定义 strategyID、symbol、timeframe、depth 和 signalThreshold。
- `OrderBookImbalanceStrategyContract`：只消费本地订单簿读模型输入，计算 top depth bid / ask notional imbalance。
- `OrderBookImbalanceSignalSample`：输出 signal、sourceObservedAt、depth、inputSource、bidNotional、askNotional、imbalanceRatio 和 bias。
- `OrderBookImbalanceResearchEventFlow`：生成 requested、signalGenerated 和 completed 研究事件流。

契约要求：

- depth 必须大于 0。
- signalThreshold 必须是有限值并位于 `0...1`。
- Delta 只能应用到同 symbol 的订单簿读模型输入。
- Strategy symbol / timeframe 必须与 MarketDataQuery 一致。
- 每个输入必须满足配置 depth 所需的 bid / ask level 数量。
- 失衡使用 top depth notional 计算：`(bidNotional - askNotional) / (bidNotional + askNotional)`。
- bid dominance 映射为 `.long` 研究信号；neutral 和 ask dominance 映射为 `.flat`，ask dominance 只通过 bias 字段表达，不引入 futures / margin 方向。
- 研究事件可发布到 strategy stream，但不创建订单、不连接 broker、不触发 Paper 或 Live 执行。

本契约不包含：

- signed endpoint。
- futures leverage / margin action。
- 真实订单提交、取消或替换。
- LiveExecutionAdapter。
- 持久化 adapter。
- SwiftUI 页面。

## MTP-26 订单簿失衡 parity / bias evidence 加固

日期：2026-05-18

执行者：Codex

MTP-26 在 MTP-12 契约基础上补强订单簿失衡研究链路的可审计 evidence。

新增或明确的契约结构：

- `OrderBookImbalanceSignalSample.inputSource`：记录信号来自原始 `snapshot` 还是 `deltaApplied` 后的本地读模型。
- `OrderBookImbalanceResearchParity`：比较直接策略 contract 与 research event flow 的 signal samples，生成本地 parity result。
- `OrderBookImbalanceResearchParityResult.coveredInputSources`：记录 parity evidence 覆盖的 snapshot / delta 输入来源。
- `OrderBookImbalanceResearchParityResult.askDominanceRemainsResearchOnly`：确认 ask dominance 只保留为 research bias，signal direction 仍为 `.flat`。

契约要求：

- parity evidence 必须来自本地 deterministic fixture，不依赖真实 Binance 网络。
- snapshot / delta 输入来源必须随 signal sample 进入后续分析投影 evidence。
- ask dominance 不得变成 short、margin、futures leverage 或真实订单动作。

本契约不包含：

- 高频执行引擎。
- signed endpoint / account endpoint。
- futures leverage / margin action。
- 真实订单提交、取消或替换。
- Paper 或 Live 执行推进。

## MTP-13 持久化重放与投影契约

日期：2026-05-17

执行者：Codex

`Persistence` 在本事项中建立 `ReplayEvents` 后续 use case 所需的本地投影边界。

契约结构：

- Event Log replay：按 sequence range 和 stream 过滤 envelope。
- Market cache rebuild：复用 Core market cache 投影逻辑。
- SQLite runtime projection：构建 paper session、risk rejection 和 portfolio runtime read model。
- DuckDB analytical projection：构建 market data、backtest、订单簿研究和 signal timeline 分析 read model。

契约要求：

- 输入只能是 `EventEnvelope` 与 `EventReplayCommand`。
- 输出只能是稳定 projection snapshot。
- 投影结果不得暴露 database schema。
- 投影结果不得保存或返回运行时对象。

本契约不包含：

- 真实 SQLite / DuckDB adapter。
- database migration。
- UI ViewModel。
- Live execution persistence。
- broker / exchange side effect。

## MTP-17 文件事实源 ReplayEvents 契约

日期：2026-05-18

执行者：Codex

`ReplayEvents` 在本事项中可以从文件事件日志事实源读取 `EventEnvelope`，并继续输出稳定 replay / projection 输入。

契约结构：

- `FileEventLogStore.append(_:)`：追加写入单个 `EventEnvelope`。
- `FileEventLogStore.replay(_:)`：按 `EventReplayCommand` 读取文件事实并输出 `EventReplayResult`。
- `PersistenceReplayBoundary.init(fileStore:)`：复用文件事实源重建 market cache 和 runtime / analytical projection snapshot。

契约要求：

- append-only 文件事实源必须保持 sequence 从 1 开始连续递增。
- replay 结果必须仍由 `EventEnvelope` 表达，不能暴露 JSONL 或任何文件内部格式给 UI。
- 文件事实源只服务本地研究、回放和后续投影适配器，不代表可交易命令。

本契约不包含：

- SQLite / DuckDB driver。
- database schema migration。
- Binance 网络客户端。
- UI 页面。
- Live trading、signed endpoint、broker action 或真实订单行为。

## MTP-18 SQLite 运行时投影适配器契约

日期：2026-05-18

执行者：Codex

`ReplayEvents` 在本事项中可以把 replay envelope 重建为 SQLite runtime projection adapter 的最小读写闭环。

契约结构：

- `SQLiteRuntimeProjectionAdapter.rebuild(from:)`：复用 `SQLiteRuntimeProjectionStore.project` 从 replay envelope 生成稳定 runtime snapshot，并用 SQLite3 事务替换私有投影记录。
- `SQLiteRuntimeProjectionAdapter.querySnapshot()`：从 SQLite 私有投影存储查询回 `SQLiteRuntimeProjectionSnapshot`。
- `PersistenceReplayBoundary.rebuildSQLiteRuntimeProjection(from:using:)`：把 `EventReplayCommand`、append-only replay 和 SQLite adapter 串成最小闭环。

契约要求：

- Event Log / replay envelope 仍是事实源。
- SQLite 只保存 paper session、risk rejection、portfolio projection 的最小运行时投影。
- 查询输出只能是稳定 `SQLiteRuntimeProjectionSnapshot`。
- SQLite 表名、列名和 payload 编码是 `Persistence` 私有实现细节，不能暴露给 UI、API 或 ViewModel contract。

本契约不包含：

- 完整 schema 设计。
- migration framework。
- ORM。
- DuckDB adapter。
- Binance 网络客户端。
- UI 页面。
- Live trading、signed endpoint、broker action 或真实订单行为。

## MTP-19 DuckDB 分析投影适配器契约

日期：2026-05-18

执行者：Codex

`ReplayEvents` 在本事项中可以把 replay envelope 重建为 DuckDB analytical projection adapter 的最小读写闭环。

契约结构：

- `DuckDBAnalyticalProjectionAdapter.rebuild(from:)`：复用 `DuckDBAnalyticalProjectionStore.project` 从 replay envelope 生成稳定 analytical snapshot，并用 DuckDB 事务替换私有分析投影记录。
- `DuckDBAnalyticalProjectionAdapter.querySnapshot()`：从 DuckDB 私有投影存储查询回 `DuckDBAnalyticalProjectionSnapshot`。
- `PersistenceReplayBoundary.rebuildDuckDBAnalyticalProjection(from:using:)`：把 `EventReplayCommand`、append-only replay 和 DuckDB adapter 串成最小闭环。

契约要求：

- Event Log / replay envelope 仍是事实源。
- DuckDB 只保存 market data、backtest run、order book research run 和 signal timeline 的分析投影副本。
- 查询输出只能是稳定 `DuckDBAnalyticalProjectionSnapshot`。
- DuckDB 表名、列名和 payload 编码是 `Persistence` 私有实现细节，不能暴露给 UI、API 或 ViewModel contract。

本契约不包含：

- 完整 schema 设计。
- migration framework。
- ORM。
- SQLite runtime adapter 扩展。
- Binance 网络客户端。
- UI 页面。
- Live trading、signed endpoint、broker action 或真实订单行为。

## MTP-20 Binance 公开只读行情客户端 Use Case 边界

日期：2026-05-18

执行者：Codex

`LoadMarketData` 在本事项中获得 Adapters 层 public read-only client boundary，但仍不进入
MTP-21 ingest 串联。

契约结构：

- 输入仍来自 `BinancePublicMarketDataEndpoint`、`Symbol`、`Timeframe` 和 `DateRange`。
- 网络边界由 `BinancePublicMarketDataClient` 负责生成 public request、调用 transport 并复用 decoder。
- 输出只能是 Core market data model：`BinanceExchangeInfo`、`MarketBar`、`TradeTick`、`BestBidAsk`、
  `OrderBookSnapshot` 或 `OrderBookDelta`。
- required validation 通过 mock transport 与 fixture parity 验证，不依赖真实 Binance 网络。

契约要求：

- Use Case 只能读取 Binance public market data。
- request 必须是 read-only，且 `requiresAPIKey == false`。
- client 必须拒绝 mutable、API key、signed、account、order、listenKey、SAPI、FAPI 和 DAPI 语义。
- depth stream 当前只验证 public depth delta 单条 payload 边界，不管理 WebSocket 生命周期。

本契约不包含：

- DataEngine ingest 串联。
- Event Log 写入。
- replay / projection 触发。
- SwiftUI 页面。
- 真实网络 smoke test required validation。
- signed endpoint、account endpoint、listenKey user data stream。
- 真实 broker action、真实订单行为、Live trading 或 futures leverage / margin action。

## MTP-21 行情 ingest / replay / projection 串联契约

日期：2026-05-18

执行者：Codex

`LoadMarketData` 在本事项中进入 Runtime 本地编排边界，把 Binance public read-only client
输出的 Core market data model 写入 append-only event log，并从 replay 重建投影快照。

契约结构：

- `PublicMarketDataIngestPlan`：定义 symbol、timeframe、range、public endpoint limit、观察时间和确定性 recordedAt。
- `MarketDataIngestReplayProjectionWorkflow`：串联 `BinancePublicMarketDataClient`、`TradingKernel`、`FileEventLogStore` 和 `PersistenceReplayBoundary`。
- `MarketDataIngestReplayProjectionResult`：输出 ingest events、event envelopes、replay result、market cache snapshot、SQLite runtime projection snapshot 和 DuckDB analytical projection snapshot。

契约要求：

- required validation 必须注入 mock transport 和 fixture payload，不依赖真实 Binance 网络。
- event log sequence 必须保持从 1 开始连续递增。
- replay result 必须与写入的 market event envelopes 一致。
- DuckDB analytical snapshot 必须从 replay envelope 重建 market bars、trades、best bid / ask、order book snapshot 和 delta。
- SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot，因为 Paper / Risk / Portfolio 不属于当前行情 ingest 事实。
- Runtime 不允许 App 直接调用 Binance adapter，也不允许 UI 直接读取 SQLite / DuckDB schema。

本契约不包含：

- SwiftUI 页面。
- 完整报表路径。
- 真实网络 smoke test required validation。
- 多 run 续写游标合同。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、真实订单行为、Live trading 或 futures leverage / margin action。

## MTP-23 Research -> Backtest -> Report Use Case 边界

日期：2026-05-18

执行者：Codex

`ResearchBacktestReport` 在本事项中作为 App 层最小读模型生成路径：

- 输入：`DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot`、append-only event timeline。
- 输出：`ReportReadModel` / `ResearchBacktestReportArtifact` / `ReportViewModel`。
- 数据链：Research projection -> Backtest projection -> Paper projection evidence -> Report artifact -> Dashboard shell snapshot。

契约要求：

- Report 只能汇总既有 projection snapshots，不重跑策略、不调用 Runtime / Adapters。
- Report 可以表达 projection-level Backtest / Paper evidence，但不替代 Core 层 `BacktestPaperParity` 完整时间线验证。
- Report artifact 必须标记为 research output only，不能授权真实交易执行。

本契约不包含：

- Stage Code Audit Report。
- 完整报表系统。
- 完整 Paper execution 工作流。
- signed endpoint、account endpoint、broker action、真实订单行为或 Live execution。

## MTP-27 Fixed Execution Cost Evidence Use Case 边界

日期：2026-05-18

执行者：Codex

`EstimateExecutionCostEvidence` 在本事项中作为 Core 层最小成本证据边界：

- 输入：`ExecutionCostEstimateRequest` 和 `ExecutionCostAssumptions`。
- 输出：`ExecutionCostEstimate` 和 `ExecutionCostParityResult`。
- 计算：gross notional、固定 maker / taker fee、固定 slippage 和 total cost。
- 验证：Backtest 与 Paper 在同一 deterministic fixture 下必须得到一致 cost breakdown。

契约要求：

- 假设必须是有限且非负的固定 bps。
- rounding scale 必须统一，当前限制为 `0...8` 位小数。
- deterministic fixture 只服务 XCTest、Trading Validation Matrix 和 PR evidence。
- Backtest / Paper parity evidence 只能比较本地成本估算，不触发 Paper execution 工作流。

本契约不包含：

- 完整费用模型。
- 交易所费率表。
- symbol-specific tier / account VIP tier。
- 动态滑点模型。
- 执行成本优化。
- 真实成交、broker fill、账户余额、保证金、杠杆。
- signed endpoint、account endpoint、broker action、真实订单行为或 Live execution。

## MTP-28 Risk Blocker / Portfolio Exposure Evidence Use Case 边界

日期：2026-05-18

执行者：Codex

`EvaluateRisk` 和 `ProjectPortfolio` 在本事项中补充最小 evidence / read model 边界：

- `RiskBlockerEvidence`：绑定 proposed Paper action context、risk profile、blocker reason 和 generatedAt。
- `PortfolioExposureSnapshot`：绑定 portfolio ID、symbol、timeframe、paper quantity、reference price、gross exposure notional 和 paper projection source。
- `SQLiteRiskBlockerEvidenceProjection`：把 Core risk blocker evidence 映射到 runtime projection，并保留 source sequence。
- `SQLitePortfolioExposureProjection`：把 paper-only exposure 映射到 portfolio read model，并保留 source sequence。

契约要求：

- Risk blocker evidence 只能来自本地 Paper 风险观察，`RiskEvaluationQuery.executionMode` 必须是 `paper`。
- Portfolio exposure 只能来自 Paper projection，不能读取真实账户、保证金、杠杆或 broker balance。
- App / Dashboard 只能展示 read-only evidence，不提供风险控制命令、仓位管理命令或交易执行入口。

本契约不包含：

- 完整风险引擎。
- 实时风控。
- 仓位管理、保证金、杠杆。
- 真实 broker / exchange action。
- signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-34 Paper-only Portfolio Projection Update Use Case 边界

日期：2026-05-19

执行者：Codex

`ProjectPortfolio` 在本事项中获得从 allowed paper risk decision 到 portfolio exposure projection 的本地更新路径。

契约结构：

- `PaperPortfolioProjectionUpdate`：以 MTP-33 `PaperActionProposalRiskDecision` 为输入，要求 decision status 为 `allowed`。
- `PortfolioEvent.paperProjectionUpdated`：作为 append-only portfolio stream 中的本地 projection fact。
- `SQLiteRuntimeProjectionStore.project`：从 replay envelope 应用 update，更新 `SQLitePortfolioProjection.exposures`。

契约要求：

- blocked decision 不得生成 portfolio update。
- update 的 exposure 只能来自 proposal 的 symbol、timeframe、paper quantity 和 reference price。
- update 的 source sequence 必须回溯到 allowed risk decision source sequence，不代表 broker order sequence。
- App / Dashboard 只能通过 `SQLiteRuntimeProjectionSnapshot` 派生的 `PortfolioReadModel` / `PortfolioViewModel` 展示 exposure。

本契约不包含：

- 完整 portfolio management。
- 真实账户余额读取。
- margin、leverage、broker position sync。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-35 Paper Session Replay Evidence Use Case 边界

日期：2026-05-19

执行者：Codex

`ReplayEvents` 在本事项中获得 Paper Session runtime evidence summary，用于从 append-only
event log replay 汇总 lifecycle、proposal、risk blocker 和 portfolio projection 证据。

契约结构：

- `PaperEvent.actionProposed`：把 MTP-32 proposal 作为 paper-only replay fact 写入 `.paper` stream。
- `PaperSessionReplayEvidenceSummary`：汇总 replay sequence、stream、session、lifecycle、proposal、risk blocker 和 portfolio update evidence。
- `PaperSessionReplayPath.summarize`：只消费 `EventReplayResult`，拒绝乱序 replay result。
- `PaperSessionReplayFixture`：生成 deterministic event log、replay result 和 summary，用于 XCTest / PR evidence。

契约要求：

- replay 输入必须来自 append-only event log 产生的 `EventReplayResult`。
- summary 必须覆盖 session events、proposal events、risk blocker events 和 portfolio projection events。
- summary 必须固定 replayed sequences、streams、proposal IDs、risk blocker IDs、portfolio update IDs 和 paper-only boundary flags。
- proposal、risk 和 portfolio evidence 只能表达本地 Paper runtime evidence，不得恢复真实订单授权或 broker fallback。
- SQLite runtime projection 仍只能消费 replay envelope，不暴露 table、column、SQL statement 或 ORM model。

本契约不包含：

- 生产级 event sourcing 平台。
- schema migration framework。
- 真实 broker event replay。
- 外部 execution venue。
- signed endpoint、account endpoint、broker action、真实订单行为或 Live execution。

## MTP-38 Paper-only Execution Workflow Contract Use Case 边界

日期：2026-05-19

执行者：Codex

`StartPaperSession` / `EvaluateRisk` / `ProjectPortfolio` 在本事项中获得一个共享的 paper-only execution workflow contract，用于约束后续 issue 的本地执行证据链。

契约结构：

- `PaperExecutionWorkflowContract`：汇总 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的阶段顺序。
- `PaperExecutionWorkflowStageBoundary`：为每个阶段记录 consumes、produces、event stream、evidence kind、当前实现状态和 future issue 占位。
- `PaperExecutionWorkflowContract.deterministicFixture`：为 XCTest 和 PR evidence 固定 MTP-38 合同。

契约要求：

- proposal 必须先于 risk decision，risk decision 必须先于 paper execution decision；后续 issue 不能跳过 risk decision 直接生成 order、fill 或 portfolio projection。
- paper execution decision、paper order 和 simulated fill 只是 future issue 占位；MTP-38 不实现 lifecycle、fill 生成或 OMS。
- portfolio projection 阶段只能消费本地 simulated fill 之后的 paper-only evidence，并保持 `.portfolio` stream 边界。
- 所有阶段的 `authorizesTradingExecution`、`authorizesLiveTrading`、`touchesSignedEndpoint`、`touchesBrokerAction` 和 `representsRealOrder` 必须固定为 `false`。

本契约不包含：

- simulated fill。
- 完整 OMS。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单提交 / 取消 / 替换或 Live execution。

## MTP-39 Paper Order Intent / Lifecycle Use Case 边界

日期：2026-05-19

执行者：Codex

`StartPaperSession` / `EvaluateRisk` 在本事项中获得 paper-only order intent 和 lifecycle 的最小本地模型，用于把 proposal 与 risk result 记录为可验证的 paper order 状态。

契约结构：

- `PaperOrderLifecycleState`：定义 `intentCreated` 和 `rejectedByRisk` 两个本地 lifecycle state。
- `PaperOrderIntent`：绑定 order ID、proposal ID、risk decision ID、risk result、blocker evidence、symbol、timeframe、quantity、notional、workflow stage 和 `.paper` event boundary。
- `PaperOrderIntentFixture`：提供 deterministic allowed / risk-rejected fixture，用于 XCTest 和 PR evidence。
- `PaperExecutionWorkflowContract.deterministicFixture`：将 paper order stage 标记为当前代码已实现，但仍保留 paper execution decision 和 simulated fill 的独立边界。

契约要求：

- allowed risk decision 只能映射为 `intentCreated`。
- blocked risk decision 只能映射为 `rejectedByRisk`，并必须保留 blocker evidence ID。
- paper order intent 必须固定 `executionMode == paper`、`proposalAuthorization == paperIntentOnly`、`workflowStage == paperOrder`、`eventStream == .paper` 和 `evidenceKind == paperOrder`。
- source risk decision sequence 必须为正数，用于回溯本地 append-only event log 语境，不代表 broker order sequence。
- 所有交易能力旗标必须固定为 `false`，Codable 解码不得恢复真实订单、broker action、signed endpoint、simulated fill 或 Live execution。

本契约不包含：

- paper execution decision。
- simulated fill。
- 完整 OMS。
- cancel / replace 工作流。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单提交 / 取消 / 替换或 Live execution。

## MTP-40 Simulated Fill Evidence Use Case 边界

日期：2026-05-19

执行者：Codex

`StartPaperSession` / `EvaluateRisk` 在本事项中获得本地 simulated fill evidence 的最小 value model，用于让后续 paper execution workflow 能引用模拟成交证据，但不进入 event log / replay / portfolio projection 串联。

契约结构：

- `PaperSimulatedFillAssumption`：固定 deterministic filled quantity、fill price、liquidity role 和 MTP-27 execution cost assumptions。
- `PaperSimulatedFillEvidence`：绑定 fill ID、order ID、proposal / session / risk decision trace、symbol / timeframe、filled quantity、fill price、fixed cost evidence、workflow stage 和 `.paper` event boundary。
- `PaperSimulatedFillFixture`：提供 deterministic allowed fill fixture，用于 XCTest 和 PR evidence。
- `PaperExecutionWorkflowContract.deterministicFixture`：将 simulated fill stage 标记为当前代码已实现，但不引入 event log 写入或 projection 更新。

契约要求：

- simulated fill evidence 只能消费 allowed `PaperOrderIntent`，不能由 `rejectedByRisk` intent 生成。
- source order intent sequence 和 source risk decision sequence 必须为正数，用于本地 append-only event log 语境中的追溯，不代表 broker order sequence 或交易所回报。
- filled quantity / fill price 必须与 order intent quantity / reference price 一致；当前不支持 partial fill、dynamic slippage、market matching 或执行成本优化。
- fixed cost evidence 必须由 `ExecutionCostCalculator` 和 deterministic assumptions 派生。
- 所有真实交易能力、真实 fill、broker fill、account update、signed endpoint 和 Live trading 旗标必须固定为 `false`。

本契约不包含：

- paper execution decision。
- event log 写入。
- replay 串联。
- portfolio projection update。
- 真实撮合或真实成交回报。
- 动态滑点模型、交易所费率表或执行成本优化。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单提交 / 取消 / 替换或 Live execution。

## MTP-41 Paper Execution Decision Use Case 边界

日期：2026-05-19

执行者：Codex

`StartPaperSession` / `EvaluateRisk` 在本事项中获得本地 paper execution decision 链路，用于把 proposal、risk decision、paper order intent 和 simulated fill evidence 串成可验证 evidence chain。

契约结构：

- `PaperExecutionDecisionStatus`：表达 `allowed` / `blocked`，并必须与上游 `PaperActionProposalRiskDecisionStatus` 一致。
- `PaperExecutionDecision`：保存 risk decision、可选 paper order intent、可选 simulated fill assumption / evidence、source sequence、workflow stage 和 capability flags。
- `PaperExecutionDecisionLink.decide`：无副作用地消费已校验 risk decision；allowed 路径生成本地 order / fill evidence，blocked 路径只保留 blocker evidence。
- `PaperExecutionDecisionFixture`：提供 deterministic allowed / blocked decision flow，用于 XCTest 和 PR evidence。
- `PaperExecutionWorkflowContract.deterministicFixture`：将 paper execution decision stage 标记为当前代码已实现。

契约要求：

- allowed decision 必须由 allowed risk decision 派生，并生成 `PaperOrderIntent` 与 `PaperSimulatedFillEvidence`。
- blocked decision 必须保留 `RiskBlockerEvidence`，且不得生成 paper order intent、simulated fill assumption 或 simulated fill evidence。
- status、workflow stage、event stream、evidence kind 和 source sequence 必须保持内部一致。
- 所有真实交易能力、真实订单、真实 fill、broker fill、account update、signed endpoint 和 Live trading 旗标必须固定为 `false`。
- Codable 解码不得把 blocked decision 伪造成可下单链路，也不得恢复真实交易能力。

本契约不包含：

- event log 写入。
- replay 串联。
- portfolio projection update。
- 完整 execution engine。
- 完整风险引擎。
- broker rejection fallback。
- broker / exchange side effect。
- signed endpoint、account endpoint、真实订单提交 / 取消 / 替换或 Live execution。

## MTP-42 Paper Execution Event Replay Projection Use Case 边界

日期：2026-05-19

执行者：Codex

`ReplayEvents` / `ProjectPortfolio` 在本事项中获得本地 paper execution evidence 的
event log -> replay -> portfolio projection 串联路径。

契约结构：

- `PaperEvent.executionDecisionRecorded`：把 MTP-41 decision chain 写入 `.paper` stream。
- `PaperEvent.orderIntentRecorded`：把 allowed decision 生成的 `PaperOrderIntent` 写入 `.paper` stream。
- `PaperEvent.simulatedFillRecorded`：把 allowed decision 生成的 `PaperSimulatedFillEvidence` 写入 `.paper` stream。
- `PaperExecutionEventLogBoundary`：按 decision -> order intent -> simulated fill 顺序追加本地 facts，并校验 source order sequence。
- `PaperExecutionReplayProjectionPath`：只从 replay 出来的 `simulatedFillRecorded` envelope 生成 `PaperPortfolioProjectionUpdate`。
- `PaperPortfolioProjectionUpdate`：当前只能消费 replay 后的 paper-only simulated fill evidence，并把 fill event sequence 作为 source sequence。

契约要求：

- allowed decision 必须按 decision、paper order、simulated fill 顺序写入 `.paper` stream。
- blocked decision 只能写入 decision fact，不得生成 paper order、simulated fill 或 portfolio update。
- portfolio projection 必须来自 replay 后的 `PaperSimulatedFillEvidence`，不得直接从 risk decision、真实 broker fill、account update 或外部 execution venue 派生。
- replay summary 必须覆盖 execution decision、paper order、simulated fill 和 portfolio projection evidence，并拒绝乱序 replay result。
- SQLite runtime projection 仍只消费 replay envelope，输出稳定 read model snapshot，不暴露 schema。

本契约不包含：

- 生产级 event sourcing 平台。
- schema migration framework。
- FileEventLogStore 重写。
- broker event replay。
- 真实账户、真实 position、真实 broker fill。
- signed endpoint、account endpoint、真实订单提交 / 取消 / 替换或 Live execution。
