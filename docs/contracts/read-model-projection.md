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
