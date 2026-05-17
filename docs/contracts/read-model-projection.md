# Read Model Projection

Read Model Projection 必须先于把数据库事实暴露给前端。

## 目的

Read Model 是 UI 的稳定输入，也是验证 backtest / paper 一致性的观察面。

## 第一版 Projection

| Projection | 来源 | 消费者 |
| --- | --- | --- |
| MarketReadModel | market events / DuckDB projection | MarketViewModel |
| StrategyReadModel | signal events | StrategyViewModel |
| BacktestReadModel | backtest result events | BacktestViewModel |
| PaperReadModel | paper execution events | PaperViewModel |
| RiskReadModel | risk decision events | RiskViewModel |
| PortfolioReadModel | portfolio events | PortfolioViewModel |
| EventTimelineReadModel | append-only event log | EventLogViewModel |

## 边界

Read Model 可以引用 database projection，但不能暴露 database schema 给前端。

## MTP-11 一致性观察面

日期：2026-05-17

执行者：Codex

EMA 回测与 Paper 一致性在当前事项中以本地 signal timeline 作为观察面。

当前可投影字段：

- strategyID
- symbol
- timeframe
- generatedAt
- direction
- close
- shortEMA
- longEMA
- backtestRunID
- paperSessionID
- parity result

边界：

- 当前只定义 Core 层可测试读模型输入，不实现 SwiftUI 页面。
- 当前不把 database table、ORM model 或 runtime object 暴露给前端。
- 当前不包含真实订单、成交、账户或 broker 状态。

## MTP-12 订单簿失衡观察面

日期：2026-05-17

执行者：Codex

订单簿失衡研究链路在当前事项中以本地订单簿读模型输入和 signal sample 作为观察面。

当前可投影字段：

- strategyID
- symbol
- timeframe
- sourceObservedAt
- depth
- bidNotional
- askNotional
- imbalanceRatio
- bias
- generatedAt
- direction
- researchID

边界：

- 当前只定义 Core 层可测试读模型输入，不实现 SwiftUI 页面。
- 当前不把 database table、ORM model 或 runtime object 暴露给前端。
- 当前不包含真实订单、成交、账户、futures leverage、margin 或 broker 状态。
- ask dominance 只作为研究 bias，不映射为真实 short / margin action。

## MTP-13 持久化投影观察面

日期：2026-05-17

执行者：Codex

SQLite / DuckDB 投影与重放在当前事项中以稳定 read model projection 作为观察面。

SQLite runtime projection 当前可投影字段：

- paper sessionID
- strategyID
- symbol
- timeframe
- riskProfileID
- executionMode
- session state
- signalCount
- requestedAt
- completedAt
- rejectedPaperOrderIDs
- portfolio projection state

DuckDB analytical projection 当前可投影字段：

- market bars
- trades
- best bid / ask
- order book snapshots / deltas
- backtest runID
- order book researchID
- strategyID
- symbol
- timeframe
- analytical signal timeline
- EMA close / shortEMA / longEMA
- order book bidNotional / askNotional / imbalanceRatio

边界：

- 当前只定义 `Persistence` 层可测试投影，不实现 SwiftUI 页面。
- 当前不把 database table、ORM model 或 runtime object 暴露给前端。
- 当前不引入真实 SQLite / DuckDB driver。
- 当前不包含 Live execution persistence。

## MTP-14 Dashboard ViewModel 观察面

日期：2026-05-17

执行者：Codex

Trader Workstation Dashboard 在当前事项中以 App 层 read model 聚合为唯一 ViewModel 输入。

当前 App 层 read model：

- `MarketReadModel`：由 DuckDB analytical projection 中的 market bars、trades、best bid / ask、order book snapshots 和 deltas 构建。
- `StrategyReadModel`：由 analytical signal timeline 构建。
- `BacktestReadModel`：由 backtest run projection 和 backtest signal timeline 构建。
- `PaperReadModel`：由 SQLite paper session runtime projection 构建。
- `RiskReadModel`：由 SQLite rejected paper order projection 构建。
- `PortfolioReadModel`：由 SQLite portfolio runtime projection 构建。
- `EventTimelineReadModel`：由 append-only event timeline 构建。

当前 ViewModel 可投影字段：

- Market：symbols、bar / trade / best bid ask / order book 计数、latest bar close、last applied sequence。
- Strategy：strategy IDs、signal count、latest signal direction、last applied sequence。
- Backtest：run IDs、strategy、symbol、timeframe、state、signal count、latest signal direction。
- Paper：session IDs、strategy、symbol、timeframe、risk profile、paper execution mode、state、signal count。
- Risk：rejected paper order IDs 和 rejection count。
- Portfolio：portfolio IDs 和 updated portfolio count。
- Events：event count、streams 和 last sequence。

边界：

- 当前只定义 SwiftUI 页面前的 ViewModel contract。
- App target 不再直接依赖 `Adapters`。
- 当前不把 database table、ORM model 或 runtime object 暴露给前端。
- 当前不直接读取 SQLite / DuckDB schema。
- 当前不调用 Binance adapter。
- 当前不提供 live order button 或 broker action。

## MTP-18 SQLite Runtime Projection Adapter 观察面

日期：2026-05-18

执行者：Codex

SQLite runtime projection adapter 在当前事项中只改变运行时投影的存储方式，不改变 UI 可观察面。

当前可查询 snapshot：

- paper session projection。
- rejected paper order IDs。
- portfolio projection。
- last applied sequence。

边界：

- Read Model 仍消费 `SQLiteRuntimeProjectionSnapshot`。
- UI 不消费 SQLite table、column、SQL statement、payload 编码或 ORM model。
- SQLite adapter 不参与 DuckDB analytical projection。
- SQLite adapter 不触发 Binance、Live trading、signed endpoint、broker action 或真实订单行为。
