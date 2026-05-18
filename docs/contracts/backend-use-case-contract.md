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
