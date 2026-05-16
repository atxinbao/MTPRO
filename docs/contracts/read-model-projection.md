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
