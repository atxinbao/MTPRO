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

MTP-22 新增 `DashboardShellView` 与 `Dashboard` SwiftPM executable。

绑定契约：

- `DashboardShellView` 唯一输入是 `DashboardViewModel` 或由其派生的 `DashboardShellSnapshot`。
- `DashboardShellSnapshot` 展示 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域。
- `Dashboard` 启动时使用 `DashboardViewModel.emptyResearchWorkbench`，只表达空 read model projection，不伪造运行时事实。
- `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only summary 后退出，作为本地 smoke validation。

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

## MTP-36 Paper Session Runtime Evidence ViewModel 契约

日期：2026-05-19

执行者：Codex

MTP-36 在 Report / Dashboard ViewModel 中汇总 Paper Session runtime evidence：

- `PaperSessionRuntimeEvidenceSummary`：把 append-only replay summary 与 runtime projection evidence 汇总为可编码只读快照。
- `ReportArtifactViewModel.paperRuntimeEvidence`：展示单个 report artifact 关联的 lifecycle、proposal、risk blocker、portfolio update 和 replay evidence。
- `ReportViewModel`：汇总 runtime evidence count、runtime session IDs、lifecycle states、proposal IDs、runtime risk blocker evidence IDs、portfolio update IDs、replay sequence count、replay streams、deterministic replay flag 和 paper-only boundary flag。
- `DashboardShellSnapshot` 的 Report 区域展示 runtime evidence、replay facts、runtime sessions、proposal IDs、portfolio update IDs、replay streams 和 paper-only boundary。

边界确认：

- Report / Dashboard 仍只消费 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- runtime evidence 来自 append-only event timeline replay summary 与 SQLite runtime projection snapshot；它不触发 replay 写入、数据库迁移、broker action 或订单动作。
- `paperRuntimeAuthorizesTradingExecution`、`paperRuntimeAuthorizesLiveTrading` 和 `paperRuntimeTouchesBrokerAction` 必须保持 false。
- Report / Dashboard 不提供 live order action、risk control command、position management command、broker action 或 signed endpoint。

## MTP-44 Paper Execution Workflow Evidence ViewModel 契约

日期：2026-05-19

执行者：Codex

MTP-44 在 Report / Dashboard ViewModel 中汇总 Paper execution workflow evidence：

- `PaperExecutionWorkflowEvidenceSummary`：把 append-only replay summary 中的 paper execution decision、paper order、simulated fill 和 portfolio projection evidence 汇总为可编码只读快照。
- `ReportArtifactViewModel.paperExecutionWorkflowEvidence`：展示单个 report artifact 关联的 decision IDs、paper order IDs、simulated fill IDs、portfolio update IDs、workflow sequences 和 workflow streams。
- `ReportViewModel`：汇总 workflow evidence count、decision IDs、paper order IDs、simulated fill IDs、portfolio update IDs、workflow sequence count、workflow streams、decision / order / fill chain coverage、portfolio projection coverage、deterministic replay flag 和 paper-only boundary flag。
- `DashboardShellSnapshot` 的 Report 区域展示 workflow evidence、decision / order / fill IDs、workflow streams、execution chain coverage、portfolio projection coverage 和 paper-only boundary。

边界确认：

- Report / Dashboard 仍只消费 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- workflow evidence 来自 append-only event timeline replay summary；它不触发 replay 写入、数据库迁移、broker action 或订单动作。
- `paperExecutionWorkflowAuthorizesTradingExecution`、`paperExecutionWorkflowAuthorizesLiveTrading` 和 `paperExecutionWorkflowTouchesBrokerAction` 必须保持 false。
- Report / Dashboard 不提供 live order action、risk control command、position management command、order command、broker action 或 signed endpoint。

## MTP-47 Paper Workflow Workbench IA ViewModel 契约

日期：2026-05-20

执行者：Codex

MTP-47 新增 Workbench information architecture 合同 fixture，用于在实现 SwiftUI 控件、Command Model 或 Event Timeline 前固定 ViewModel / Read Model 观察边界：

- `PaperWorkflowSessionControl`：只允许 `start`、`pause`、`close`、`reset` 四个 session-level local controls。
- `PaperWorkflowObservabilitySection`：固定 session、proposal、risk decision、paper order、simulated fill、portfolio projection、replay freshness、report artifact status 和 event timeline 九个观察面。
- `PaperWorkflowForbiddenCapability`：固定 order-level command、Live trading、signed endpoint、account endpoint、listenKey、broker action、真实订单 submit / cancel / replace、OMS、database schema surface、runtime object surface 和 adapter request surface 禁区。
- `PaperWorkflowWorkbenchInformationArchitecture.deterministicFixture`：以可编码 fixture 证明当前 Workbench IA 仍是 read-model-only 合同，不提前实现命令、控件或 Event Timeline。

边界确认：

- 该合同只定义后续 Workbench / ViewModel / Command Model / Event Timeline 的输入边界。
- 当前 issue 不新增 SwiftUI 页面字段，不新增按钮，不新增 `Command` case，不写 event log。
- Workbench IA 仍只引用 `DashboardSection` 和 `ViewModelSourceContract`，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- order-level command 明确禁止；session-level controls 不能被解释为真实订单、真实成交、broker fill、account update 或交易授权。

## MTP-50 Paper Workflow Observability ViewModel 契约

日期：2026-05-20

执行者：Codex

MTP-50 新增 Paper workflow observability 的 App 层 read model / ViewModel：

- `PaperWorkflowObservabilityReadModel`：只从既有 `ReportReadModel`、`PaperReadModel`、`RiskReadModel`、`PortfolioReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowObservabilityViewModel`：展示 session status、proposal IDs、allowed / blocked evidence、decision -> order -> simulated fill -> portfolio projection chain coverage、replay freshness 和 report artifact status。
- `PaperWorkflowReplayFreshnessStatus`：用 append-only event timeline sequence 和 replay evidence sequence 比较 freshness，不触发 replay 或 runtime side effect。
- `DashboardReadModel.paperWorkflowObservability` 和 `DashboardViewModel.paperWorkflowObservability`：把该观察快照挂到现有 Dashboard / Workbench ViewModel 边界，供后续 shell issue 消费。

边界确认：

- ViewModel 继续使用 `ViewModelSourceContract` 证明 read-model-only。
- ViewModel 不暴露 SQLite / DuckDB schema、table、column、SQL、ORM model、Runtime object 或 adapter request。
- ViewModel 不提供 UI control、Event Timeline explorer、order-level command、broker action、signed endpoint、account endpoint、listenKey 或真实订单行为。
- `paperOnlyBoundaryHeld`、`readModelOnlyBoundaryHeld` 必须为 true；Live trading、broker action 和 trading execution authorization 必须为 false。

## MTP-51 Paper Workflow Event Timeline / Evidence Explorer ViewModel 契约

日期：2026-05-20

执行者：Codex

MTP-51 新增 Event Timeline / Evidence Explorer 的 App 层 read model / ViewModel 子集：

- `PaperWorkflowEvidenceExplorerReadModel`：只从 `MarketReadModel`、`StrategyReadModel`、`ReportReadModel`、`PaperWorkflowObservabilityReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowEvidenceExplorerViewModel`：展示 timeline items、evidence links、section snapshots、read-only filter snapshot 和 coverage flags。
- `PaperWorkflowEvidenceExplorerSection`：固定 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact 分区。
- `DashboardReadModel.paperWorkflowEvidenceExplorer` 和 `DashboardViewModel.paperWorkflowEvidenceExplorer`：把 Explorer 快照挂到现有 Dashboard / Workbench ViewModel 边界，供后续 shell issue 消费。

边界确认：

- ViewModel 继续使用 `ViewModelSourceContract` 证明 read-model-only。
- ViewModel 不暴露 SQLite / DuckDB schema、table、column、SQL、ORM model、Runtime object、Persistence adapter direct read 或 adapter request。
- ViewModel 不提供 UI control、Runtime command、query language、order-level command、risk control、position management、broker action、signed endpoint、account endpoint、listenKey 或真实订单行为。
- `readModelOnlyBoundaryHeld` 必须为 true；Live trading、broker action、command surface、query language 和 trading execution authorization 必须为 false。

## MTP-52 Dashboard / Workbench Shell ViewModel 契约

日期：2026-05-20

执行者：Codex

MTP-52 在现有 Dashboard / Workbench shell 上增量消费 MTP-47 至 MTP-51 的 App 层合同：

- `DashboardShellControlSnapshot`：把 `PaperWorkflowSessionControl` 和 `PaperSessionLocalControlAction` 映射成只读 session-level local control 展示行，固定 scope、control level、paper execution mode 和全部 false 的 capability flags。
- `DashboardShellWorkbenchSnapshot`：汇总 control shell、`PaperWorkflowObservabilityViewModel` 和 `PaperWorkflowEvidenceExplorerViewModel`，作为 Dashboard shell 的只读 Workbench 输入。
- `DashboardShellSnapshot.workbench`：在保持八个 `DashboardSection` 不变的前提下，把 Paper workflow control shell、observability sections 和 Event Timeline / Evidence Explorer preview 挂到现有 shell。
- `DashboardShellView`：只渲染 snapshot 文本、指标和 read-only preview，不提供按钮、表单、runtime command 或 adapter 访问。

边界确认：

- Shell 只能消费 ViewModel / Read Model / Command Model，不直接读取 projection schema、runtime object、adapter request 或外部系统。
- Session-level controls 只能是 `start` / `pause` / `close` / `reset`，且只作为 read-only presentation；不得解释为 order submit / cancel / replace 或真实交易授权。
- `DashboardShellWorkbenchSnapshot.readModelOnlyBoundaryHeld` 和 `paperOnlyBoundaryHeld` 必须为 true。
- `providesCommandSurface`、`providesOrderLevelCommand`、`exposesDatabaseSchema`、`exposesRuntimeObject`、`exposesAdapterRequest`、`authorizesLiveTrading`、`touchesBrokerAction` 和 `authorizesTradingExecution` 必须为 false。

## MTP-59 Market Data Replay Operations Read Model / ViewModel 契约

日期：2026-05-20

执行者：Codex

MTP-59 新增 market data replay operations 的 App 层 read model / ViewModel，并把 replay operations evidence 接入 Report、Dashboard 和 Event Timeline：

- `MarketDataReplayOperationsEvidenceItem`：复制 batch id、replay run id、symbol、timeframe、freshness status、retention status、event log / projection consistency summary 和 boundary flags。
- `MarketDataReplayOperationsEvidenceReadModel`：作为 Report / Dashboard / Event Timeline 的稳定输入，只排序和聚合已生成 evidence，不触发 replay 或 projection side effect。
- `MarketDataReplayOperationsEvidenceViewModel`：展示 batch IDs、replay run IDs、freshness / retention 状态、event log record count、replayed record count、projection consistency 和 read-model-only boundary。
- `ReportReadModel.marketDataReplayOperations` 和 `ReportViewModel.marketDataReplayOperations`：把 replay operations evidence 接入 Report 快照。
- `PaperWorkflowEvidenceExplorerSection.marketDataReplayOperation`：为 Event Timeline 新增 read-model-only replay operations 分区。
- `DashboardShellSnapshot` 的 Report section：展示 replay ops count、batch ids、replay run ids、freshness、retention、projection summary 和 boundary evidence。

边界确认：

- App 层只消费复制后的 ViewModel / Read Model 字段，不直接依赖 Runtime object、adapter request 或 persistence implementation。
- Dashboard shell 不导入 Runtime / Adapters，不暴露 SQLite / DuckDB schema、table、column、SQL、ORM model 或 adapter request。
- Event Timeline 的 `market data replay operation` item 只做 evidence navigation，不提供 query language、command surface、order-level command、retention cleanup、projection rebuild 或 production operations console。
- `readModelOnlyBoundaryHeld` 必须为 true；`authorizesLiveTrading`、`touchesBrokerAction`、`authorizesTradingExecution`、`authorizesProductionRuntimeOperations`、`providesCommandSurface` 和 `providesOrderLevelCommand` 必须为 false。

## MTP-66 Live Blocked Evidence Read Model / ViewModel 契约

日期：2026-05-21

执行者：Codex

MTP-66 新增 Live blocked evidence 的 App 层 read model / ViewModel，并把 `LiveReadiness` 接入 Report、Dashboard 和 Event Timeline：

- `LiveTradingBlockedEvidenceItem`：复制 evidence id、gate、capability、evidence kind、source anchors、blocked status 和 forbidden capability flags。
- `LiveTradingBlockedEvidenceReadModel`：作为 Report / Dashboard / Event Timeline 的稳定输入，只消费 Core `LiveReadiness` / `LiveBlockedEvidence`，不触发任何外部系统 side effect。
- `LiveTradingBlockedEvidenceViewModel`：展示 blocked capability labels、gate labels、source anchors、all-gates-blocked 和 read-model-only boundary。
- `ReportReadModel.liveTradingBlockedEvidence` 和 `ReportViewModel.liveTradingBlockedEvidence`：把 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle blocked evidence 接入 Report 快照。
- `PaperWorkflowEvidenceExplorerSection.liveTradingBlockedEvidence`：为 Event Timeline 新增 read-model-only Live blocked evidence 分区。
- `DashboardShellSnapshot` 的 Report section 和 Workbench：展示 `Live gates`、Live blocked details 和 Dashboard smoke `liveBlockedGates` evidence。

边界确认：

- App 层只消费复制后的 ViewModel / Read Model 字段，不直接依赖 adapter request、Runtime object、persistence implementation、API key、secret、account data 或 broker state。
- Dashboard shell 不新增按钮、表单、live command、order-level command、risk control command、position management command 或真实订单入口。
- Event Timeline 的 `live trading blocked evidence` item 只做 blocked evidence navigation，不提供 query language、command surface、execution control 或实盘监控台。
- `readModelOnlyBoundaryHeld` 和 `allLiveGatesBlocked` 必须为 true；`authorizesLiveTrading`、`touchesBrokerAction`、`authorizesTradingExecution`、`providesCommandSurface`、`providesOrderLevelCommand`、`readsAPIKey`、`usesSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`instantiatesBrokerAdapter` 和 `representsRealOrderLifecycle` 必须为 false。

## MTP-68 Live Monitoring Console IA / ViewModel 边界契约

日期：2026-05-21

执行者：Codex

MTP-68 只定义 Live monitoring console information architecture 和后续 ViewModel 边界，不新增 App 类型、Dashboard 字段或 SwiftUI 控件。主合同入口是 `docs/contracts/live-monitoring-console-contract.md`。

`MTP-68-LIVE-MONITORING-CONSOLE-IA`

后续 Live monitoring console 的 ViewModel 分区必须保持 read-model-only，并按以下信息架构组织：

- Overview：汇总 monitoring readiness、blocked gates 和 operations evidence。
- Runtime Health：展示 future live runtime health status，不读取 runtime actor。
- Connection：展示 connection status evidence，不创建 listenKey 或 private WebSocket。
- Market Stream：展示 public read-only market stream health / freshness / latency evidence。
- Order Stream Evidence：只展示 blocked / simulated / future order-stream evidence，不表示真实订单状态机。
- Latency：展示 read model 已计算的 latency bucket 和 stale evidence。
- Error / Degraded State：展示 error / degraded evidence，不提供 incident command 或自动恢复动作。
- Operations Evidence：展示 validation、handoff、audit input 和 readiness evidence chain。

`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`

边界确认：

- Dashboard、Report 和 Event Timeline 只能消费 App 层 Read Model / ViewModel，不读取 adapter request、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM 或 persistence implementation。
- 当前 issue 不新增 live command、交易按钮、表单、order-level command、risk control command、position management command、submit / cancel / replace 或自动恢复动作。
- `order stream evidence` 只能表达 blocked / simulated / future evidence，不得解释为 execution report、broker fill、real order lifecycle、OMS 或真实账户状态。
- `checks/automation-readiness.sh` 不在 MTP-68 中收口；后续 MTP-74 才能把 MTP-68 至 MTP-73 的 anchors 机械化。

## MTP-72 Live Monitoring Evidence Read Model / ViewModel 契约

日期：2026-05-21

执行者：Codex

MTP-72 新增 Live monitoring evidence 的 App 层 read model / ViewModel，并把 MTP-69 / MTP-70 / MTP-71 的 Core evidence 接入 Report 和 Dashboard：

- `LiveMonitoringEvidenceReadModel`：作为 Report / Dashboard 的稳定输入，只消费 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`，不触发 runtime、adapter、telemetry 或网络 side effect。
- `LiveMonitoringEvidenceViewModel`：展示 runtime health status、connection statuses、stream counts、latency buckets、error codes、degraded states、source anchors 和 forbidden capability flags。
- `ReportReadModel.liveMonitoringEvidence` 和 `ReportViewModel.liveMonitoringEvidence`：把 health、connection、stream、latency、error 和 degraded evidence 接入 Report 快照。
- `DashboardShellSnapshot` 的 Report section：新增 `Monitoring` 指标和 monitoring details。
- `DashboardShellWorkbenchSnapshot`：新增 `Live Monitoring` 只读组，展示 health、connections、streams、latency、errors、degraded counts 和 boundary details。
- Dashboard smoke 新增 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3` evidence。

边界确认：

- App 层只消费复制后的 ViewModel / Read Model 字段，不直接依赖 adapter request、Runtime object、production telemetry、external metrics service、SQLite / DuckDB schema、API key、secret、account data 或 broker state。
- Dashboard shell 不新增按钮、表单、live command、order-level command、risk command、position command、alert / paging / reconnect / stop control、incident command 或自动恢复动作。
- `readModelOnlyBoundaryHeld` 必须为 true；`providesCommandSurface`、`providesOrderLevelCommand`、`providesTradingButton`、`providesRiskCommand`、`providesPositionCommand`、`exposesDatabaseSchema`、`exposesRuntimeObject`、`exposesAdapterSurface`、`opensNetworkConnection`、`usesProductionTelemetry`、`usesExternalMetricsService`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`instantiatesBrokerAdapter`、`implementsRealOrderStateMachine`、`authorizesLiveTrading` 和 `authorizesTradingExecution` 必须为 false。

## MTP-73 Event Timeline Live Monitoring Evidence ViewModel 契约

日期：2026-05-21

执行者：Codex

MTP-73 新增 Event Timeline / Evidence Explorer 的 live monitoring evidence 只读预览，并复用 MTP-72 的 App 层 read model：

- `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence`：新增独立分区，用于展示 live monitoring runtime health、connection、stream、latency、error 和 degraded state evidence。
- `PaperWorkflowEvidenceExplorerReadModel.liveMonitoringEvidence`：默认从 `ReportReadModel.liveMonitoringEvidence` 取数，仍保持 read-model-only，不读取 adapter、Runtime、schema、telemetry、external metrics 或网络连接。
- `PaperWorkflowEvidenceExplorerViewModel.coversLiveMonitoringEvidence`：用于证明 Event Timeline 已覆盖 live monitoring evidence preview。
- Full fixture timeline item count 固定为 42，其中 live monitoring evidence 分区 18 条；空启动 Dashboard snapshot 固定为 24 条静态 Live blocked / Live monitoring evidence。

边界确认：

- Event Timeline 只生成 timeline rows、evidence links 和 section filter snapshot，不新增完整 query language、live command、交易按钮、order-level command、risk command、position command 或 broker action。
- MTP-73 不实现 live audit、incident replay、stop control、alert / paging / reconnect、incident command、auto recovery、production telemetry、runtime profiler、external metrics service 或真实 runtime monitoring。
- `readModelOnlyBoundaryHeld` 必须为 true；`providesCommandSurface`、`providesOrderLevelCommand`、`supportsQueryLanguage`、`providesLiveAudit`、`providesIncidentReplay`、`providesStopControl`、`authorizesLiveTrading`、`touchesBrokerAction` 和 `authorizesTradingExecution` 必须为 false。
