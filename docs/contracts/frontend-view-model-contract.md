# Frontend ViewModel Contract

前端 ViewModel Contract 必须先于 SwiftUI 页面实现。

## ViewModel 来源

ViewModel 只能来自稳定 read model projection。

禁止：

- UI 直接消费 database table。
- UI 直接消费 ORM model。
- UI 直接消费 runtime object。
- UI 直接调用 Binance adapter。

## 第一版 ViewModel

| ViewModel | 输入来源 | 用途 |
| --- | --- | --- |
| MarketViewModel | Market read model | 行情观察 |
| StrategyViewModel | Strategy read model | 策略状态 |
| BacktestViewModel | Backtest read model | 回测结果 |
| PaperViewModel | Paper execution read model | Paper 状态 |
| RiskViewModel | Risk read model | 风险状态 |
| PortfolioViewModel | Portfolio read model | 组合投影 |
| EventLogViewModel | Event read model | 事件流水 |

## 边界

当前只定义契约，不实现 SwiftUI 页面。

## MTP-14 ViewModel 契约细化

日期：2026-05-17

执行者：Codex

`MTPROApp` 在本事项中建立 Trader Workstation Dashboard 的 ViewModel contract，覆盖：

- `MTPROMarketViewModel`
- `MTPROStrategyViewModel`
- `MTPROBacktestViewModel`
- `MTPROPaperViewModel`
- `MTPRORiskViewModel`
- `MTPROPortfolioViewModel`
- `MTPROEventLogViewModel`
- `MTPRODashboardViewModel`

输入契约：

- Market / Strategy / Backtest 来自 `MTPRODuckDBAnalyticalProjectionSnapshot` 派生的稳定 read model。
- Paper / Risk / Portfolio 来自 `MTPROSQLiteRuntimeProjectionSnapshot` 派生的稳定 read model。
- Events 来自 append-only `EventEnvelope` timeline 派生的稳定事件观察面。

边界确认：

- ViewModel 不暴露 database table。
- ViewModel 不暴露 ORM model。
- ViewModel 不暴露 runtime object。
- ViewModel 不调用 Binance adapter。
- ViewModel 不提供 live order action。
- 当前只实现 ViewModel contract，不实现 SwiftUI 页面。
