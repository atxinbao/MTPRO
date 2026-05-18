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
| ReportViewModel | Report read model | 研究报告快照 |
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

## MTP-23 Report ViewModel 契约

日期：2026-05-18

执行者：Codex

MTP-23 新增 Report read model / ViewModel，覆盖：

- `ReportReadModel`
- `ResearchBacktestReportArtifact`
- `ReportViewModel`
- `ReportArtifactViewModel`

输入契约：

- Report read model 只能由 `DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot` 和 append-only event timeline 派生。
- Report artifact 绑定 backtest run、同 symbol / timeframe 的 research run、matching Paper session、事件数量和投影级 parity evidence。
- Report ViewModel 只暴露报告快照字段，不暴露 database table、SQL statement、ORM model、runtime object 或 adapter request。

边界确认：

- Report 不调用 Runtime / Adapters。
- Report 不提供 live order action。
- Report 不替代 Core 层 `BacktestPaperParity` 完整信号时间线验证，只表达 projection-level evidence。
- Report artifact 的 `executionAuthorization` 固定为 research output only，不代表 broker action、signed endpoint 或真实订单授权。

## MTP-28 Risk / Portfolio ViewModel 契约

日期：2026-05-18

执行者：Codex

MTP-28 细化 Risk / Portfolio 只读 ViewModel：

- `RiskBlockerEvidenceViewModel`：展示 evidenceID、paperOrderID、symbol、timeframe、proposedQuantity、riskProfileID、executionMode、reason 和 sourceSequence。
- `RiskViewModel`：展示 blocker evidence、rejected paper order IDs、blocker reason 列表和 lastAppliedSequence。
- `PortfolioExposureViewModel`：展示 portfolioID、symbol、timeframe、paperQuantity、referencePrice、grossExposureNotional、source 和 sourceSequence。
- `PortfolioViewModel`：展示 portfolio IDs、updated count、exposure count、total gross exposure notional 和 lastAppliedSequence。

边界确认：

- Risk / Portfolio ViewModel 只消费 `SQLiteRuntimeProjectionSnapshot` 派生的稳定 read model。
- ViewModel 不暴露 SQLite table、column、SQL statement、payload 编码或 ORM model。
- ViewModel 不调用 Runtime / Adapters，不连接 broker / exchange。
- ViewModel 不提供 risk control command、position management command、live order action 或 signed endpoint。

## MTP-29 Report / Dashboard Trading Validation Evidence 契约

日期：2026-05-18

执行者：Codex

MTP-29 在 Report / Dashboard ViewModel 中汇总交易验证 evidence：

- `ReportExecutionCostEvidence`：从 paper-only exposure projection 和 MTP-27 deterministic fixture 派生 maker / taker cost parity evidence。
- `TradingValidationEvidenceSummary`：聚合 projection-level parity、execution cost evidence、risk blocker evidence 和 portfolio exposure evidence。
- `ReportArtifactViewModel.tradingValidationEvidence`：把单个 report artifact 的交易验证证据作为可编码只读快照暴露给 Dashboard。
- `ReportViewModel`：汇总 execution cost evidence count、assumption IDs、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols 和 gross exposure notional。
- `DashboardShellSnapshot` 的 Report 区域展示 cost evidence、risk blocker 和 exposure evidence。

边界确认：

- Report / Dashboard 仍只消费 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- fees / slippage evidence 只来自 deterministic fixture 和本地 projection，不代表 Binance 实际费率、真实成交、broker fill 或账户成本。
- Risk / Portfolio evidence 只代表 Paper readiness，不代表真实账户余额、margin、leverage、broker position 或 Live fallback。
- Report / Dashboard 不提供 live order action、risk control command、position management command、broker action 或 signed endpoint。

## MTP-34 Paper-only Portfolio Projection Update ViewModel 契约

日期：2026-05-19

执行者：Codex

MTP-34 不新增 SwiftUI 交易控制，也不让 ViewModel 直连 runtime / database。

确认的只读 ViewModel 路径：

- `PortfolioViewModel` 继续只消费 `PortfolioReadModel`。
- `PortfolioReadModel` 继续只从 `SQLiteRuntimeProjectionSnapshot` 派生。
- `PaperPortfolioProjectionUpdate` 经 replay / SQLite runtime projection 后，才以 `PortfolioExposureViewModel` 展示。

边界确认：

- ViewModel 不暴露 SQLite table、column、SQL statement、payload 编码或 ORM model。
- ViewModel 不调用 Runtime / Adapters，不连接 broker / exchange。
- ViewModel 不提供 position management command、live order action、broker action 或 signed endpoint。
- portfolio exposure 只代表 paper-only projection evidence，不代表真实账户余额、margin、leverage、broker position 或真实成交。
