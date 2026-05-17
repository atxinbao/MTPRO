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

## MTP-12 订单簿失衡研究链路契约

日期：2026-05-17

执行者：Codex

`Core` 在本事项中建立订单簿读模型输入、失衡信号和研究事件流契约。

契约结构：

- `OrderBookReadModelInput`：由只读 `OrderBookSnapshot` 构建，并可应用同 symbol 的 `OrderBookDelta`。
- `OrderBookImbalanceStrategyConfiguration`：定义 strategyID、symbol、timeframe、depth 和 signalThreshold。
- `OrderBookImbalanceStrategyContract`：只消费本地订单簿读模型输入，计算 top depth bid / ask notional imbalance。
- `OrderBookImbalanceSignalSample`：输出 signal、sourceObservedAt、depth、bidNotional、askNotional、imbalanceRatio 和 bias。
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
