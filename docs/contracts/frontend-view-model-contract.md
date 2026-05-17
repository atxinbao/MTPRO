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

SwiftUI 页面必须只消费 ViewModel / Read Model，不直接接入数据库、runtime 或 adapter。

## MTP-14 ViewModel 契约细化

日期：2026-05-17

执行者：Codex

`App` 在本事项中建立 Trader Workstation Dashboard 的 ViewModel contract，覆盖：

- `MarketViewModel`
- `StrategyViewModel`
- `BacktestViewModel`
- `PaperViewModel`
- `RiskViewModel`
- `PortfolioViewModel`
- `EventLogViewModel`
- `DashboardViewModel`

输入契约：

- Market / Strategy / Backtest 来自 `DuckDBAnalyticalProjectionSnapshot` 派生的稳定 read model。
- Paper / Risk / Portfolio 来自 `SQLiteRuntimeProjectionSnapshot` 派生的稳定 read model。
- Events 来自 append-only `EventEnvelope` timeline 派生的稳定事件观察面。

边界确认：

- ViewModel 不暴露 database table。
- ViewModel 不暴露 ORM model。
- ViewModel 不暴露 runtime object。
- ViewModel 不调用 Binance adapter。
- ViewModel 不提供 live order action。
- 当前只实现 ViewModel contract，不实现 SwiftUI 页面。

## MTP-22 macOS Dashboard Shell

日期：2026-05-18

执行者：Codex

MTP-22 新增 `DashboardShellView` 与 `MTPRODashboard` SwiftPM executable。

绑定契约：

- `DashboardShellView` 唯一输入是 `DashboardViewModel` 或由其派生的 `DashboardShellSnapshot`。
- `DashboardShellSnapshot` 展示 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域。
- `MTPRODashboard` 启动时使用 `DashboardViewModel.emptyResearchWorkbench`，只表达空 read model projection，不伪造运行时事实。
- `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 输出 read-model-only summary 后退出，作为本地 smoke validation。

边界确认：

- shell source 不导入 Runtime / Adapters。
- shell 不直接读取 SQLite / DuckDB schema、table、column、SQL statement 或 ORM object。
- shell 不调用 Binance adapter。
- shell 不提供 live order action、broker action、signed endpoint 或真实交易控制。
