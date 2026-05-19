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
| ReportReadModel | projection snapshots / event timeline | ReportViewModel |
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

## MTP-31 Paper Session Lifecycle 观察面

日期：2026-05-19

执行者：Codex

Paper session lifecycle 在当前事项中先以 Core event log facts 作为观察面，为后续 replay、portfolio projection 和 report / dashboard evidence 提供稳定输入。

当前可观察字段：

- sessionID。
- lifecycle state：`started`、`updated`、`closed`。
- strategyID、symbol、timeframe、riskProfileID、executionMode。
- signalCount。
- startedAt、updatedAt、closedAt。
- event log sequence、stream 和 recordedAt。

边界：

- 当前只定义 Core lifecycle facts 和 append-only event log 写入边界。
- 当前不新增 SwiftUI 页面字段，不要求 Dashboard 展示 lifecycle 状态。
- 当前不把 SQLite / DuckDB schema、ORM model 或 runtime object 暴露给前端。
- 当前不包含 action proposal、risk decision、portfolio update、真实订单、成交、账户、broker 状态、signed endpoint 或 Live execution。

## MTP-32 Paper Action Proposal 观察面

日期：2026-05-19

执行者：Codex

Paper action proposal 在当前事项中先以 Core value contract 和 deterministic fixture 作为观察面，为后续 risk blocker、paper-only portfolio projection、replay 和 report evidence 提供稳定输入。

当前可观察字段：

- proposalID、sessionID。
- strategyID、symbol、timeframe、signal direction、signal generatedAt。
- paper-only side：`buy` 或 `hold`。
- sizingAssumptionID、quantity、referencePrice、notionalAmount。
- MTP-27 fixed cost evidence：assumptionID、liquidityRole、grossNotional、feeAmount、slippageAmount、totalCostAmount。
- executionMode：固定 `paper`。
- executionAuthorization：固定 `paperIntentOnly`。
- proposedAt。
- `isExecutableAsRealOrder == false`。

边界：

- 当前只定义 Core proposal model 和 deterministic tests，不新增 SwiftUI 页面字段。
- 当前不新增 event log 写入、SQLite / DuckDB projection、Report / Dashboard 字段或 portfolio update。
- 当前不把 proposal 解释为 order、fill、account state、broker 状态、signed endpoint 或 Live execution。

## MTP-33 Paper Action Risk Link 观察面

日期：2026-05-19

执行者：Codex

Paper action risk link 在当前事项中先以 Core value contract 和 deterministic fixture 作为观察面，为后续 paper-only portfolio projection、replay 和 report evidence 提供稳定输入。

当前可观察字段：

- decisionID、proposalID、sessionID。
- strategyID、symbol、timeframe、signal direction、paper-only side。
- riskProfileID、proposedQuantity、executionMode。
- sourceSequence、evaluatedAt。
- decision status：`allowed` 或 `blocked`。
- blocker evidence：evidenceID、reason、generatedAt。
- paper-only context consistency、broker fallback availability 和 Live execution fallback availability。

边界：

- 当前只定义 Core risk link result、deterministic fixtures 和 tests，不新增 SwiftUI 页面字段。
- 当前不新增 event log 写入、SQLite / DuckDB projection、Report / Dashboard 字段或 portfolio update。
- allowed 不代表真实订单授权、真实风控通过、broker fill 或 portfolio update。
- blocked 只代表本地 Paper blocker evidence，不代表真实 broker 拒单、account state、signed endpoint 或 Live execution fallback。

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
- inputSource
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

## MTP-26 订单簿失衡 evidence 观察面

日期：2026-05-18

执行者：Codex

订单簿失衡研究链路现在把 snapshot / delta 输入来源纳入可投影 evidence。

新增或确认的可观察字段：

- `inputSource`：Core 层 signal sample 的输入来源，取值为 `snapshot` 或 `deltaApplied`。
- `coveredInputSources`：Core parity result 中覆盖的输入来源集合，用于证明 fixture 同时覆盖 snapshot 和 delta 应用边界。
- `orderBookInputSource`：DuckDB analytical signal timeline 中保存的订单簿输入来源，只作为 read model evidence，不暴露 DuckDB schema。

边界：

- `inputSource` 和 `orderBookInputSource` 只服务研究验证和报告证据，不授权交易执行。
- ask dominance 仍只作为 research bias，不能映射为 short、margin、futures leverage 或真实 broker action。
- 该观察面不新增 UI 直连数据库、Runtime object 或 adapter request。

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

## MTP-19 DuckDB Analytical Projection Adapter 观察面

日期：2026-05-18

执行者：Codex

DuckDB analytical projection adapter 在当前事项中只改变分析投影的存储方式，不改变 UI 可观察面。

当前可查询 snapshot：

- market bars、trades、best bid / ask、order book snapshots 和 order book deltas。
- backtest run projection。
- order book research run projection。
- analytical signal timeline。
- last applied sequence。

边界：

- Read Model 仍消费 `DuckDBAnalyticalProjectionSnapshot`。
- UI 不消费 DuckDB table、column、SQL statement、payload 编码或 ORM model。
- DuckDB adapter 不参与 SQLite runtime projection。
- DuckDB adapter 不触发 Binance、Live trading、signed endpoint、broker action 或真实订单行为。

## MTP-21 Runtime Ingest Projection 观察面

日期：2026-05-18

执行者：Codex

Runtime ingest 串联后的观察面由 replay 结果和 projection snapshots 组成。

当前可观察字段：

- event envelopes：sequence、stream、recordedAt 和 market event。
- market cache snapshot：market event count、bar / trade / best bid ask / order book snapshot / delta 投影。
- SQLite runtime snapshot：market-only ingest 下为空，用于确认 Paper / Risk / Portfolio 未被伪造。
- DuckDB analytical snapshot：market bars、trades、best bid / ask、order book snapshots、order book deltas 和 lastAppliedSequence。

边界：

- 当前不实现 SwiftUI 页面。
- 当前不把 SQLite / DuckDB table、column、SQL statement 或 ORM object 暴露给前端。
- 当前不把真实网络 smoke test 作为 required validation。
- 当前不包含真实订单、成交账户、broker 状态、signed endpoint 或 Live execution。

## MTP-22 macOS Dashboard Shell 观察面

日期：2026-05-18

执行者：Codex

macOS 看板壳在当前事项中消费 `DashboardViewModel` snapshot，并把每个 section 转换为
`DashboardShellSectionSnapshot`。

当前 shell 可观察字段：

- Market：symbol 数、bar / trade / best bid ask / order book 计数、latest close、last sequence。
- Strategy：strategy 数、signal 数、latest signal、last sequence。
- Backtest：run 数、completed run 数、signal 数、latest signal、last sequence。
- Report：report 数、projection-level parity、cost evidence、risk blocker evidence、exposure evidence、last sequence。
- Paper：session 数、active / completed session 数、last sequence。
- Risk：paper blocker 数、rejected paper order IDs、blocker reason、last sequence。
- Portfolio：portfolio 数、updated portfolio 数、exposure 数、gross exposure notional、last sequence。
- Events：event 数、stream 数、last sequence。

边界：

- shell 只消费 App 层 ViewModel / shell snapshot。
- shell 不直接消费 SQLite / DuckDB table、column、SQL statement、payload 编码或 ORM object。
- shell 不导入 Runtime / Adapters，不调用行情 adapter。
- shell 不包含 live order、broker action、signed endpoint、账户信息或真实交易操作。

## MTP-23 Research -> Backtest -> Report 观察面

日期：2026-05-18

执行者：Codex

最小报告路径在当前事项中以 App 层 `ReportReadModel` 作为观察面。

当前 Report 可观察字段：

- reportID。
- backtestRunID、backtestState、backtestSignalCount。
- researchIDs、researchSignalCount。
- paperSessionIDs、paperSignalCount。
- strategyIDs、symbol、timeframe。
- eventCount、lastAppliedSequence。
- projection-level parity status。
- executionAuthorization。

边界：

- Report 输入只来自 projection snapshots / read model。
- Report 不读取数据库 schema、table、column、SQL statement 或 payload 编码。
- Report 不调用 Runtime / Adapters。
- Report 不替代 Core Backtest / Paper parity 完整时间线验证。
- Report 是研究输出，不包含 signed endpoint、账户信息、真实订单、broker 状态或 Live execution。

## MTP-27 Fees / Slippage Evidence 观察面

日期：2026-05-18

执行者：Codex

MTP-27 的 fees / slippage evidence 先停留在 Core 层 deterministic estimate；MTP-29 起由 Report read model
从 paper-only portfolio exposure projection 派生只读成本证据快照。

当前可观察字段：

- assumptionID。
- symbol、timeframe、executionMode。
- liquidityRole：maker / taker。
- referencePrice、quantity。
- grossNotional。
- feeRateBps、feeAmount。
- slippageRateBps、slippageAmount。
- totalCostAmount。
- roundingDecimalPlaces。
- Backtest / Paper cost parity result。

边界：

- MTP-29 之前不新增 UI ViewModel 字段；MTP-29 只在 Report / Dashboard read model 中展示只读 evidence summary。
- 当前不写入 SQLite / DuckDB projection。
- 当前不把成本 evidence 解释为真实成交、账户余额、broker fill 或执行授权。
- 当前不包含 exchange fee table、dynamic slippage model、execution optimizer、signed endpoint、broker action 或 Live execution。

## MTP-28 Risk Blocker / Portfolio Exposure 观察面

日期：2026-05-18

执行者：Codex

MTP-28 将 risk blocker evidence 和 portfolio exposure 纳入 runtime read model / Dashboard 只读观察面。

当前 Risk 可观察字段：

- evidenceID、paperOrderID。
- symbol、timeframe、proposedQuantity。
- riskProfileID、executionMode。
- blocker reason。
- generatedAt、sourceSequence、projectedAt。

当前 Portfolio exposure 可观察字段：

- portfolioID。
- symbol、timeframe。
- paperQuantity、referencePrice。
- grossExposureNotional。
- source：`paperProjection`。
- observedAt、sourceSequence、projectedAt。

边界：

- Risk / Portfolio read model 只消费 SQLite runtime projection snapshot。
- Dashboard 只展示 blocker 数、reason、paper order ID、exposure 数和 gross exposure notional。
- Exposure 是 paper-only read model evidence，不代表真实账户余额、broker position、margin 或 leverage。
- Risk blocker 是本地 Paper 阻断证据，不代表真实 broker 拒单或 Live fallback。

## MTP-34 Paper-only Portfolio Projection Update 观察面

日期：2026-05-19

执行者：Codex

Paper-only portfolio update 在当前事项中把 MTP-33 allowed risk decision 转成可 replay 的 portfolio projection fact。

当前可观察字段：

- updateID、decisionID、proposalID、sessionID。
- riskProfileID、riskDecisionStatus、side。
- portfolioID、symbol、timeframe。
- paperQuantity、referencePrice、grossExposureNotional。
- source：固定 `paperProjection`。
- sourceSequence、updatedAt、projectedAt。
- authorizesTradingExecution、readsRealAccountBalance、syncsBrokerPosition：固定 `false`。

边界：

- 只有 allowed risk decision 可以生成 portfolio update；blocked decision 不更新 exposure。
- Runtime / Persistence 只通过 append-only event log replay 派生 SQLite runtime projection。
- ViewModel 只消费 `PortfolioReadModel`，不读取 SQLite schema、runtime object 或 adapter。
- 当前不读取真实账户余额，不做 margin / leverage，不做 broker position sync，不触发真实订单或 Live execution。

## MTP-35 Paper Session Replay Evidence 观察面

日期：2026-05-19

执行者：Codex

Paper Session replay evidence 在当前事项中以 Core 层 summary 作为观察面，为后续 Report /
Dashboard read model 汇总提供稳定输入。

当前可观察字段：

- factsSource：固定 `append-only event log replay`。
- replayedSequences、replayedStreams、firstSequence、lastSequence。
- sessionIDs、lifecycleStates、signalEventCount。
- proposalIDs。
- riskEvaluationRequestedCount、riskBlockerEvidenceIDs、rejectedPaperOrderIDs。
- portfolioUpdateIDs、portfolioIDs。
- coversSessionEvents、coversProposalEvents、coversRiskBlockerEvents、coversPortfolioProjectionEvents。
- appendOnlyFactsSourceIsReplaySource、replayResultIsDeterministic、paperOnlyBoundaryHeld。
- authorizesLiveTrading、touchesBrokerAction：固定 `false`。

边界：

- Summary 只消费 `EventReplayResult`，不读取 SQLite / DuckDB schema。
- Summary 只表达 replay evidence，不提供 UI command、risk control command、position management command 或交易执行入口。
- Proposal、risk blocker 和 portfolio evidence 都保持 paper-only，不代表 broker event、真实账户状态、真实订单或 Live execution。

## MTP-36 Paper Session Runtime Evidence Report 观察面

日期：2026-05-19

执行者：Codex

Paper Session runtime evidence 在当前事项中从 Core replay summary 与 runtime projection 汇总到
Report / Dashboard read model。

新增或细化的 Report 可观察字段：

- `PaperSessionRuntimeEvidenceSummary`：聚合 replay facts source、replayed sequences / streams、session IDs、lifecycle states、proposal IDs、risk blocker evidence IDs、portfolio update IDs 和 portfolio exposure summary。
- `ResearchBacktestReportArtifact.paperRuntimeEvidence`：把 matching symbol / timeframe 的 Paper runtime evidence 绑定到单个 report artifact。
- `ReportViewModel` 汇总 runtime evidence count、runtime session IDs、lifecycle states、proposal IDs、risk blocker evidence IDs、portfolio update IDs、replay sequence count、replay streams、deterministic replay flag 和 paper-only boundary flag。

边界：

- Runtime evidence 只来自 append-only event timeline replay summary、SQLite runtime projection snapshot 和 App 层 read model。
- Report 只按 matching symbol / timeframe 过滤 Paper / Risk / Portfolio event timeline，不读取 SQLite / DuckDB schema。
- replay deterministic 与 paper-only boundary 只是证据旗标，不授权交易执行。
- 当前不新增 UI command、risk control command、position management command、broker action、signed endpoint、account endpoint 或真实订单行为。

## MTP-38 Paper-only Execution Workflow Contract 观察面

日期：2026-05-19

执行者：Codex

Paper-only execution workflow contract 在当前事项中只作为 Core contract / validation 观察面，为后续 paper order、simulated fill、replay 和 Report evidence 提供稳定边界。

当前可观察字段：

- contractID、issueID。
- stage order：proposal、riskDecision、paperExecutionDecision、paperOrder、simulatedFill、portfolioProjection。
- consumes / produces 阶段关系。
- eventStream：`.paper`、`.risk`、`.portfolio`。
- evidenceKind。
- implementedInCurrentCode 和 futureIssueID。
- paper-only capability flags：`authorizesTradingExecution`、`authorizesLiveTrading`、`touchesSignedEndpoint`、`touchesBrokerAction`、`representsRealOrder` 固定为 `false`。

边界：

- Contract 只表达后续本地 paper-only evidence 的 stage / event boundary，不写 event log、不读 projection schema、不生成 ViewModel。
- paper execution decision、paper order 和 simulated fill 在 MTP-38 只作为 future issue 占位。
- 当前不新增 UI command、risk control command、position management command、broker action、signed endpoint、account endpoint、真实订单行为或 Live execution。

## MTP-29 Report / Dashboard Trading Validation Evidence 观察面

日期：2026-05-18

执行者：Codex

MTP-29 将 parity、fees / slippage、risk blocker 和 exposure evidence 汇总进 Report / Dashboard
read model，形成只读交易验证证据快照。

新增或细化的 Report 可观察字段：

- `TradingValidationEvidenceSummary`：聚合 projection-level parity、成本一致性、risk blocker 和 portfolio exposure。
- `ReportExecutionCostEvidence`：由 paper-only portfolio exposure projection 和 MTP-27 deterministic cost fixture 派生。
- execution cost assumption IDs、cost evidence count、Backtest / Paper cost parity consistency。
- risk blocker evidence IDs、blocker reasons。
- portfolio exposure symbols、portfolio exposure count、gross exposure notional。
- source sequences，用于回溯 runtime projection evidence。
- trading validation execution authorization 固定为 false / research-only。

Dashboard Report 区域新增可观察字段：

- Cost evidence 数。
- Risk blockers 数。
- Exposure evidence 数。
- Cost assumptions、cost parity、risk blocker evidence、exposure symbols、gross exposure。

边界：

- Report / Dashboard 仍只消费 App 层 ViewModel / Read Model。
- cost evidence 只使用本地 deterministic fixture，不读取交易所费率表、account tier 或真实成交。
- risk blocker / exposure 只来自 SQLite runtime projection snapshot 的稳定 read model，不暴露 schema。
- Report 汇总 evidence 不替代 Core 层完整 parity 测试，也不授权 Paper / Live 执行。
- 不新增 broker action、signed endpoint、account endpoint、真实订单、margin、leverage 或 Live execution。
