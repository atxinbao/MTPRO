# Paper Runtime Kernel Contract

日期：2026-05-25

执行者：Codex

## MTP-96 TradingClock / Paper Runtime Kernel Boundary

本文档定义 `MTPRO Event-Driven Paper Trading Runtime v1` 的第一个执行合同落点：`TradingClock` 与 `PaperRuntimeKernelBoundary`。

该合同只属于 paper-only / local / sandbox runtime foundation。它不实现真实 live runtime，不接 signed endpoint / account endpoint / listenKey，不连接 broker，不实现 `LiveExecutionAdapter`，不实现 OMS / real order lifecycle，不实现真实 submit / cancel / replace，不提供 Live PRO Console / live command / trading button。

## MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME

`TradingClock` 是 paper runtime kernel 的确定性时间来源：

- `TradingClockTick.sequence` 必须从 1 开始单调连续。
- `TradingClockTick.instant` 必须按 deterministic fixture / replay 顺序稳定输出。
- `TradingClockSource` 只允许 `deterministicFixture` 或 `replay` 进入有效 clock。
- `wallClock` 是明确禁区，不能出现在有效 `TradingClock` 中。
- replay tick 必须带 `replaySourceSequence`，并引用本地 append-only event log sequence。

该 clock 不读取 `Date()`，不代表 exchange clock，不代表 broker session clock，不代表 production scheduler。

## MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY

`PaperRuntimeKernelBoundary` 固定 paper runtime kernel 的输入、输出、生命周期和模块边界：

- Lifecycle：`initialized`、`localPaperSessionOpened`、`paperCommandIntakeAccepted`、`paperEventEmitted`、`replaySnapshotProduced`、`localPaperSessionClosed`。
- Allowed inputs：`tradingClockTick`、`paperSessionCommand`、`paperSessionLocalControl`、`paperActionProposal`、`paperExecutionDecision`、`eventReplayCommand`。
- Allowed outputs：`paperEventEnvelope`、`replayResult`、`paperProjectionTrigger`。
- Allowed streams：`.paper` 和 `.replay`。
- Core 只定义领域边界；Runtime 后续只能做本地编排，不得把 UI state、adapter object 或 persistence schema 放进 kernel contract。

该合同为后续 MTP-97 CommandBus / EventBus / MessageBus、MTP-98 Paper RiskEngine、MTP-99 lifecycle coordinator、MTP-100 simulated fill、MTP-101 projection 和 MTP-102 evidence closeout 提供基础入口，但本 issue 不实现这些后续能力。

## MTP-96-PAPER-ONLY-KERNEL-EVENTS

kernel boundary 只处理 paper / local / replay 事件：

- paper session command 只能来自 `ExecutionMode.paper`。
- paper local control 仍只允许 session-level `start` / `pause` / `close` / `reset`。
- paper action / execution evidence 只能进入 `.paper` stream。
- replay 只能从本地 append-only event log 事实源重建 deterministic evidence。

不得把 market adapter payload、Runtime object、SQLite / DuckDB schema、UI state、broker state、account payload 或 exchange response 直接暴露为 kernel output。

## MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA

`PaperRuntimeKernelBoundary` 的 module flags 必须全部保持 false：

- `exposesUIState == false`
- `exposesPersistenceSchema == false`
- `readsAdapterObject == false`

Dashboard / Workbench 后续只能消费 Read Model / ViewModel。Persistence 仍是 facts / projection 层，不是 UI contract。

## MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME

`PaperRuntimeKernelBoundary` 的 forbidden capability flags 必须全部保持 false：

- `usesSignedEndpoint`
- `callsAccountEndpoint`
- `createsListenKey`
- `connectsBroker`
- `implementsLiveExecutionAdapter`
- `implementsOMS`
- `implementsRealOrderLifecycle`
- `submitsRealOrder`
- `cancelsRealOrder`
- `replacesRealOrder`
- `providesLiveCommand`
- `providesTradingButton`

Codable 解码不得绕过这些不变量；任何 true flag 都必须被 `CoreError.paperRuntimeKernelForbiddenCapability` 拒绝。

## MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION

Required validation：

- `bash checks/run.sh`
- `swift test --filter MTP96`
- `Tests/CoreTests/CoreTests.swift` 必须包含：
  - `testMTP96TradingClockDefinesDeterministicReplayTicks`
  - `testMTP96PaperRuntimeKernelBoundaryDefinesPaperOnlyFixture`
  - `testMTP96PaperRuntimeKernelBoundaryRejectsLiveSignedBrokerSchemaAndClockBypass`
- `Sources/Core/PaperRuntimeKernelBoundary.swift` 必须包含：
  - `TradingClock`
  - `TradingClockTick`
  - `PaperRuntimeKernelBoundary`
  - `PaperRuntimeKernelLifecycleState`
  - `PaperRuntimeKernelInputKind`
  - `PaperRuntimeKernelOutputKind`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-97 CommandBus / EventBus / MessageBus Deterministic Routing

MTP-97 在 MTP-96 kernel boundary 内新增 paper-only deterministic bus routing：

- `PaperRuntimeCommandBus` 接收 `PaperRuntimeRouteInput`，只允许 `paperSessionCommand`、`paperRiskDecision`、`paperLifecycleEvent` 和 `simulatedFillEvent`。
- `PaperRuntimeEventBus` 只把 `PaperRuntimeRoutedMessage` 发布到既有 `MessageBus`，不持有外部 runtime state。
- `PaperRuntimeMessageBusRouting` 串联 CommandBus / EventBus / MessageBus，并提供 replay evidence 重建入口。
- `PaperRuntimeBusRoutingContract` 固定 allowed buses、allowed route sources、payload kinds、`.paper` / `.risk` streams 和 forbidden capability flags。

## MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING

CommandBus / EventBus / MessageBus routing 必须复用既有 `MessageBus` 和 append-only event log：

- CommandBus 只做 paper-only input classification 和 route ordering，不执行真实命令。
- EventBus 只做本地 publish，不连接 external broker / exchange 或外部 pub/sub。
- MessageBus 仍只维护本地 append-only facts source，不成为 live command plane。
- `MessageBus.publish` 可接收 deterministic `id`，用于 fixture / replay evidence 固定 envelope identity；默认调用仍保持既有行为。

## MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER

routing 顺序必须由显式输入顺序、deterministic `TradingClock` tick 和 deterministic envelope IDs 固定：

- `routeSequence` 从 1 开始连续。
- `recordedAt` 必须来自 `TradingClock` tick，不从 wall clock 读取。
- risk decision 可确定性拆成 `paperRiskEvaluationRequested` 和 `paperRiskBlocked` payload。
- causation chain 使用上一条 deterministic envelope ID；首条 route 使用显式 `rootCausationID`。

## MTP-97-REPLAYABLE-ROUTE-EVIDENCE

route evidence 必须能从 Event Log / Replay 重建：

- `PaperRuntimeRouteEvidence` 从 `EventEnvelope` 反推 `source`、`payloadKind`、`stream`、`correlationID` 和 `causationID`。
- replay 输入必须保持 append-only sequence 升序且唯一。
- 当前 MTP-97 只把 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event 作为稳定 event fact 输入。

## MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING

`PaperRuntimeBusRoutingContract` 的 forbidden capability flags 必须全部保持 false：

- `usesLiveCommandBus`
- `routesRealOrderCommand`
- `connectsBroker`
- `routesSignedRequest`
- `callsAccountEndpoint`
- `createsListenKey`
- `routesExecutionReport`
- `routesBrokerFill`
- `routesReconciliation`

Codable 解码不得绕过这些不变量；任何 true flag 都必须被 `CoreError.paperRuntimeBusRoutingForbiddenCapability` 拒绝。

## MTP-97-PAPER-RUNTIME-BUS-VALIDATION

Required validation：

- `bash checks/run.sh`
- `swift test --filter MTP97`
- `Tests/CoreTests/CoreTests.swift` 必须包含：
  - `testMTP97PaperRuntimeBusRoutingContractDefinesPaperOnlyDeterministicBoundary`
  - `testMTP97CommandEventMessageBusRoutesDeterministicallyAndReplaysEvidence`
  - `testMTP97PaperRuntimeBusRoutingRejectsLiveSignedBrokerAndInvalidRouteBypass`
- `Sources/MessageBus/PaperRuntimeBusRouting.swift` 必须包含：
  - `PaperRuntimeCommandBus`
  - `PaperRuntimeEventBus`
  - `PaperRuntimeMessageBusRouting`
  - `PaperRuntimeRouteEvidence`
  - `PaperRuntimeBusRoutingContract`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-98 Paper Pre-trade RiskEngine Runtime Path

MTP-98 在 MTP-96 kernel boundary 和 MTP-97 bus routing 内新增 paper-only pre-trade risk runtime path：

- `PaperPreTradeRiskEngineInput` 聚合 paper proposal、paper account snapshot、paper exposure、risk profile、paper risk rules 和 source proposal sequence。
- `PaperPreTradeRiskEngineRuntimePath.evaluate` 输出 accepted / rejected `PaperPreTradeRiskEngineDecision`。
- accepted decision 只写入 `.risk` stream 的 `evaluationRequested` fact。
- rejected decision 写入 `.risk` stream 的 `evaluationRequested` 和 `blocked` facts，并可由 Event Log / Replay 重建 route evidence。
- `PaperPreTradeRiskEngineFixture` 固定 accepted / rejected deterministic tracer bullets。

## MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH

Paper Pre-trade RiskEngine runtime path 只能处理本地 paper proposal：

- proposal 必须是 `ExecutionMode.paper`，并保持 `paperIntentOnly` authorization。
- account snapshot 只表达本地 sandbox available paper balance。
- paper exposure 只能来自 `PortfolioExposureSource.paperProjection`。
- risk rules 只覆盖 max paper quantity、max paper notional、max paper gross exposure 和 available paper balance。
- source proposal sequence 必须指向本地 append-only Event Log 中的 proposal fact。

该路径不是 live risk engine，不读取真实账户、broker position、margin、leverage、PnL 或 equity。

## MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION

MTP-98 的输出只允许 accepted / rejected paper risk decision：

- accepted 等同于本地 deterministic paper risk rules 全部通过。
- rejected 等同于第一条 deterministic paper risk rule 失败，并携带 paper-only `RiskBlockerEvidence`。
- rejected blocker reason 必须来自 `RiskBlockerReason`，不能写成 broker rejection、future live risk decision 或真实 pre-trade result。
- `PaperPreTradeRiskEngineDecision.paperOnlyBoundaryHeld` 必须为 true。

## MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY

Rejected decision 必须进入 append-only Event Log 并可 replay：

- `PaperPreTradeRiskEngineRuntimePath.evaluateAndPublish` 必须复用 MTP-97 `PaperRuntimeMessageBusRouting`。
- rejected decision 必须产生 `paperRiskEvaluationRequested` 和 `paperRiskBlocked` route evidence。
- replay evidence 必须与 publish route evidence 完全一致。
- route evidence 必须保留 envelope ID、event sequence、source、payload kind、stream、recordedAt、correlationID 和 causationID。

## MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE

Paper risk blocker、paper exposure 和 paper account snapshot 不得升级为 future live risk decision、真实账户风控或 broker state：

- `providesLiveRiskEngine == false`
- `readsRealAccountBalance == false`
- `syncsBrokerPosition == false`
- `usesMargin == false`
- `usesLeverage == false`
- `runsRealPreTradeAllowReject == false`
- `runsCircuitBreakerCommand == false`
- `runsStopTradingCommand == false`
- `runsEmergencyStop == false`
- `providesLiveCommandUI == false`
- `providesTradingButton == false`
- `mapsPaperRiskToFutureLiveRiskDecision == false`

Codable 解码不得绕过这些不变量；任何 true flag 都必须被 `CoreError.paperPreTradeRiskEngineForbiddenCapability` 拒绝。

## MTP-98-PAPER-RISKENGINE-VALIDATION

Required validation：

- `bash checks/run.sh`
- `swift test --filter MTP98`
- `Tests/CoreTests/CoreTests.swift` 必须包含：
  - `testMTP98PaperPreTradeRiskEngineProducesDeterministicAcceptedRejectedDecisions`
  - `testMTP98RejectedDecisionPublishesToEventLogAndReplaysRiskEvidence`
  - `testMTP98PaperPreTradeRiskEngineRejectsLiveAccountBrokerAndDecodeBypass`
- `Sources/Core/PaperPreTradeRiskEngine.swift` 必须包含：
  - `PaperPreTradeRiskEngineInput`
  - `PaperPreTradeRiskEngineDecision`
  - `PaperPreTradeRiskEngineRuntimePath`
  - `PaperPreTradeRiskEnginePublication`
  - `PaperPreTradeRiskEngineFixture`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-99 Paper-only Lifecycle Coordinator / Local Order Lifecycle

MTP-99 在 MTP-96 kernel boundary、MTP-97 bus routing 和 MTP-98 paper risk decision 基础上新增 paper-only lifecycle coordinator：

- `PaperOrderLocalLifecycleCoordinator` 只消费 accepted / rejected paper risk decision。
- accepted path 产生 `proposed -> submittedLocal -> acceptedLocal` deterministic local lifecycle。
- rejected path 产生 `proposed -> rejectedByPaperRisk` deterministic local lifecycle。
- `cancelledLocal` 只能来自 session close / reset、local expiry 或 deterministic local rule。
- `acceptedLocal` 只是 `PaperOrderSimulatedFillPrecondition` 的前置状态，不是 exchange accepted。
- 每个 transition 都以 `PaperEvent.orderLocalLifecycleTransitionRecorded` 写入 `.paper` stream，并可由 Event Log / Replay 重建 route evidence。

该 coordinator 不是 OMS，不连接 broker，不提交 / 撤销 / 替换真实订单，不提供单笔 order cancel button 或 order-level command UI。

## MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR

`PaperOrderLocalLifecycleCoordinator` 必须保持 Core value orchestration：

- 输入只来自 `PaperPreTradeRiskEngineDecision`。
- 输出只包含 local lifecycle transition fact。
- event publication 必须复用 MTP-97 `PaperRuntimeMessageBusRouting`。
- 不启动 Runtime actor，不读取 Persistence schema，不读取 Adapter object。

## MTP-99-LOCAL-ORDER-LIFECYCLE-STATES

MTP-99 local lifecycle state 只允许：

- `proposed`
- `submittedLocal`
- `acceptedLocal`
- `rejectedByPaperRisk`
- `cancelledLocal`
- `expiredLocal`
- `failedLocal`

这些 state 都是 paper / local 语义，不是真实 exchange / broker order lifecycle。

## MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS

每个 lifecycle transition 必须有 append-only event fact：

- `PaperOrderLocalLifecycleTransition` 保存 order、proposal、risk decision、from / to state、trigger、source sequence 和 validation anchors。
- `PaperEvent.orderLocalLifecycleTransitionRecorded` 是 `.paper` stream fact。
- `PaperOrderLocalLifecyclePublication.routeEvidence` 必须与 replay 后的 `replayEvidence` 完全一致。
- route evidence 的 source 必须是 `.paperLifecycleEvent`，payload kind 必须是 `.paperOrderLocalLifecycleTransition`。

## MTP-99-SIMULATED-FILL-PRECONDITION

`PaperOrderSimulatedFillPrecondition` 只能在 local state 为 `acceptedLocal` 时生成：

- 它只说明后续 MTP-100 simulated fill 可以消费该 local lifecycle evidence。
- 它不生成 fill，不计算 fee / slippage，不读取 market snapshot。
- 它不表示 broker fill、execution report 或 reconciliation。

## MTP-99-NO-OMS-BROKER-REAL-CANCEL

MTP-99 forbidden capability flags 必须全部保持 false：

- `implementsOMS`
- `connectsBroker`
- `implementsRealOrderStateMachine`
- `submitsRealOrder`
- `cancelsRealOrder`
- `replacesRealOrder`
- `consumesExecutionReport`
- `recordsBrokerFill`
- `performsReconciliation`
- `providesRealCancelCommand`
- `providesOrderLevelCommandUI`
- `providesLiveCommand`
- `providesTradingButton`

Codable 解码不得绕过这些不变量；任何 true flag 都必须被 `CoreError.paperOrderLocalLifecycleForbiddenCapability` 拒绝。

## MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION

Required validation：

- `bash checks/run.sh`
- `swift test --filter MTP99`
- `Tests/CoreTests/CoreTests.swift` 必须包含：
  - `testMTP99PaperOrderLocalLifecycleCoordinatorProducesDeterministicAcceptedRejectedTransitions`
  - `testMTP99LifecycleTransitionsPublishEventFactsAndReplayEvidence`
  - `testMTP99LifecycleCoordinatorRejectsOMSBrokerRealOrderCancelAndInvalidTransitions`
- `Sources/Core/PaperOrderLifecycleCoordinator.swift` 必须包含：
  - `PaperOrderLocalLifecycleState`
  - `PaperOrderLocalLifecycleTransition`
  - `PaperOrderLocalLifecycleCoordinator`
  - `PaperOrderLocalLifecyclePublication`
  - `PaperOrderSimulatedFillPrecondition`
  - `PaperOrderLocalLifecycleCoordinatorFixture`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-99 issue 结束时仍禁止

- 不实现 simulated fill / fee / slippage model。
- 不实现 paper account / portfolio projection v2。
- 不新增 order-level App / Dashboard command surface；只允许 MTP-101 read model / ViewModel evidence。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增单笔 order cancel button、order-level command UI、live command、order form 或交易按钮。
- 不读取 secret、API key、account endpoint、listenKey、broker state、真实账户或 production runtime。
- 不修改 Linear status，不创建下一 Project / Issue，不启动下一阶段 `symphony-issue`。

## MTP-100 Simulated Fill / Fee / Slippage Deterministic Model

MTP-100 在 MTP-99 `acceptedLocal` 前置条件之后新增 paper-only simulated fill / fee / slippage deterministic model：

- `PaperSimulatedFillMarketSnapshot` 固定 simulated fill 的 market-side 输入，只能来自本地 fixture / replay snapshot。
- `PaperSimulatedFillAssumption` 固定 fill completion、filled quantity、fill price source、maker / taker liquidity role 和 MTP-27 fixed execution cost assumptions。
- `PaperSimulatedFillEvidence` 同时覆盖 full fill 与 partial fill，记录 remaining quantity、fee assumption、slippage assumption、fill price assumption 和 cost impact。
- `PaperSimulatedFillEventLogBoundary` 复用 MTP-97 `PaperRuntimeMessageBusRouting`，把 `simulatedFillRecorded` 写入 `.paper` stream。
- `PaperSimulatedFillReplayPath` 从 append-only replay result 重建 partial / full simulated fill facts。

该模型只表达 paper execution assumption，不代表 broker fill、execution report、real fee statement、真实成交质量分析、reconciliation 或真实账户更新。

## MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT

market snapshot 必须保持本地 paper-only 输入：

- snapshot 只记录 `symbol`、`timeframe`、bid / ask / last price、observed time 和 source anchor。
- bid price 必须小于或等于 ask price。
- snapshot symbol / timeframe 必须与 paper order intent 对齐。
- snapshot 不能包含 signed endpoint、account endpoint、broker、execution report 或 broker fill 能力。

## MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE

simulated fill evidence 必须区分 partial / full：

- `full` 要求 filled quantity 等于 order intent quantity，remaining quantity 为 0。
- `partial` 要求 filled quantity 大于 0 且小于 order intent quantity，remaining quantity 大于 0。
- 所有 fill 都必须来自 allowed `PaperOrderIntent` 和 MTP-99 `PaperOrderSimulatedFillPrecondition`。
- `localLifecycleState` 必须保持 `acceptedLocal`，只表示本地 paper fill 前置条件。

## MTP-100-FEE-SLIPPAGE-COST-IMPACT

fee / slippage 只使用 deterministic assumptions：

- fee assumption 复用 MTP-27 `ExecutionCostAssumptions.deterministicFixture`。
- slippage assumption 复用同一 fixed bps fixture。
- fill price assumption 只能是 order reference、market last price、best bid 或 best ask。
- cost impact 只等于 fixed fee amount + fixed slippage amount，不做真实交易所费率表、动态滑点、执行质量优化或 account tier 查询。

## MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY

simulated fill result 必须进入 Event Log 并可 replay：

- `PaperSimulatedFillEventLogBoundary.publish` 必须将 fill evidence 作为 `.simulatedFillEvent` route input。
- route evidence 的 source 必须是 `simulatedFillEvent`。
- payload kind 必须是 `simulatedFillRecorded`。
- event stream 必须是 `.paper`。
- replay evidence 必须与 route evidence 完全一致。
- replayed fills 必须与发布的 fills 完全一致。

## MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION

MTP-100 forbidden capability flags 必须全部保持 false：

- `usesSignedEndpoint`
- `callsAccountEndpoint`
- `connectsBroker`
- `recordsBrokerFill`
- `consumesExecutionReport`
- `performsReconciliation`
- `representsRealFill`
- `representsBrokerFill`
- `updatesRealAccountBalance`
- `authorizesLiveTrading`
- `authorizesTradingExecution`

Codable 解码不得绕过这些不变量；任何 true flag 都必须被 `CoreError.paperSimulatedFillForbiddenCapability` 拒绝。

## MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION

Required validation：

- `bash checks/run.sh`
- `swift test --filter MTP100`
- `Tests/CoreTests/CoreTests.swift` 必须包含：
  - `testMTP100SimulatedFillModelCreatesDeterministicFullAndPartialCostEvidence`
  - `testMTP100SimulatedFillEventLogPublishesPartialAndFullFillsAndReplaysEvidence`
  - `testMTP100SimulatedFillRejectsBrokerExecutionReportReconciliationAndInvalidPartialBypass`
- `Sources/Core/PaperSimulatedFillEvidence.swift` 必须包含：
  - `PaperSimulatedFillMarketSnapshot`
  - `PaperSimulatedFillCompletion`
  - `PaperSimulatedFillPriceSource`
  - `PaperSimulatedFillEventLogBoundary`
  - `PaperSimulatedFillPublication`
  - `PaperSimulatedFillReplayPath`
  - `PaperSimulatedFillFixture`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-101 Paper Account / Portfolio / Position Projection v2

MTP-101 在 MTP-100 replayed simulated fill evidence 之后新增 paper account / portfolio /
position projection v2：

- `PaperAccountPortfolioProjectionV2Path` 只能从 `EventReplayResult` 中的
  `.paper.simulatedFillRecorded` facts 派生 projection。
- `PaperAccountProjectionSnapshot` 固定 cash、available paper balance、position market value、
  equity 和 source fill sequence。
- `PaperPositionProjectionSnapshot` 固定 symbol / timeframe、net quantity、average entry、last fill
  price、market value、cost basis 和 unrealized paper PnL。
- `PaperPortfolioPnLSummary` 固定 fee、slippage、cost impact、realized / unrealized / net paper PnL。
- `PaperAccountPortfolioProjectionV2Snapshot` 是 Persistence / App / Dashboard 可消费的稳定 read model
  source；Workbench 仍只消费 Read Model / ViewModel。

## MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION

Projection v2 必须同时输出 paper account、portfolio、position、exposure 和 PnL summary。所有数值
只能来自 replayed simulated fills、fee / slippage cost impact 和本地 sandbox starting cash。

## MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION

Projection v2 的输入必须是 replay result；不得直接从 risk decision、Runtime object、SQLite schema、
adapter payload、broker state 或真实账户读取数据。source fill IDs 和 source sequences 必须进入 snapshot。

## MTP-101-PAPER-PNL-SNAPSHOT

Paper PnL 只表示本地 sandbox 账本：`netPaperPnL = realizedPaperPnL + unrealizedPaperPnL`，其中 unrealized
paper PnL 基于本地 position market value、cost basis 和 simulated fill cost impact 推导。

## MTP-101-READ-MODEL-CONSUMPTION

Persistence 只能保存 Core snapshot 派生的 SQLite runtime projection；App / Dashboard / Report / Risk /
Portfolio 只能消费 read model / ViewModel，不暴露 database schema、Runtime object、adapter request 或命令面。

## MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE

MTP-101 forbidden capability flags 必须全部保持 false：

- `readsRealAccountBalance`
- `syncsBrokerPosition`
- `usesMargin`
- `usesLeverage`
- `representsRealAccountState`
- `representsBrokerPosition`
- `representsRealPnL`
- `updatesLiveRiskRuntime`

## MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION

Validation 必须覆盖：

- replay -> projection deterministic。
- account cash / equity / available paper balance 稳定 snapshot。
- position quantity / average entry / market value / PnL summary 稳定 snapshot。
- App read model 可被 Report / Dashboard / Risk / Portfolio 消费。
- Codable decode 不能恢复真实账户、broker position、margin、leverage、real PnL 或 live risk runtime。
- `bash checks/run.sh` 仍是最终 gate。

Core anchors：

- `Sources/Core/PaperAccountPortfolioProjectionV2.swift`
  - `PaperAccountProjectionSnapshot`
  - `PaperPositionProjectionSnapshot`
  - `PaperPortfolioPnLSummary`
  - `PaperAccountPortfolioProjectionV2Snapshot`
  - `PaperAccountPortfolioProjectionV2Path`
  - `PaperAccountPortfolioProjectionV2Fixture`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-101 后仍禁止

- 不实现 Event Log / Replay / Report / Dashboard evidence stage closeout。
- 不新增 App / Dashboard surface。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不读取 secret、API key、signed endpoint、account endpoint、listenKey、broker state、真实账户或 production runtime。
- 不修改 Linear status，不创建下一 Project / Issue，不启动下一阶段 `symphony-issue`。

## MTP-102 Event Log / Replay / Report / Dashboard Evidence Stage Closeout

MTP-102 在 MTP-96 至 MTP-101 已落地的 paper runtime kernel、routing、paper risk、local lifecycle、
simulated fill、fee / slippage 和 paper account / portfolio / position projection v2 之上，只做 evidence
chain 收口：

- Event Log / Replay 必须能串联 `.risk.evaluationRequested`、`.paper.orderLocalLifecycleTransitionRecorded`、
  `.paper.simulatedFillRecorded` 和 `.portfolio.paperAccountPortfolioProjectionUpdated` facts。
- `ReportViewModel` 必须展示 paper runtime replay、local lifecycle transition、paper risk decision、
  simulated fill、fee / slippage / cost impact、paper account、position、paper PnL 和 portfolio projection evidence。
- `DashboardShellSnapshot.smokeSummary` 必须包含 paper runtime evidence、paper workflow evidence 和 paper
  portfolio impact 的稳定 smoke handles。
- `PaperWorkflowEvidenceExplorerViewModel` / Event Timeline 必须展示 local lifecycle transition、simulated fill
  和 paper account portfolio projection 的完整 sequence。
- Stage closeout 只生成 Parent Codex Stage Code Audit 输入材料，不生成最终 Stage Code Audit Report。

## MTP-102-EVENTLOG-REPLAY-PROJECTION-EVIDENCE-CLOSEOUT

Closeout evidence 必须从 append-only replay facts 派生：risk evaluation、local lifecycle transition、simulated
fill 和 account portfolio projection 均保留 source sequence / source fill ID / snapshot ID。不得从 Runtime
object、Persistence schema、adapter request、broker state、真实账户或外部系统补齐链路。

## MTP-102-REPORT-DASHBOARD-PAPER-RUNTIME-EVIDENCE

Report / Dashboard 只能消费 `DashboardReadModel`、`ReportReadModel` 和 ViewModel。允许展示的新增字段仅限
paper evidence：lifecycle transition IDs、decision IDs、paper order IDs、simulated fill IDs、account portfolio
snapshot IDs、gross notional、fee、slippage、cost impact、paper account IDs、position count 和 paper PnL。

## MTP-102-EVENT-TIMELINE-COMPLETE-SEQUENCE

Event Timeline 必须把 local lifecycle transition 作为 `Paper local lifecycle transition` 只读 item 显示，
并继续显示 `Simulated fill evidence` 和 `Paper account portfolio projection`。这些 item 只提供 evidence
link，不提供 command、order form、cancel / replace、position command、Live PRO Console 或 trading button。

## MTP-102-STAGE-AUDIT-INPUT-MATERIAL

MTP-102 必须新增 `docs/audit/inputs/mtpro-event-driven-paper-trading-runtime-v1-stage-audit-input.md`，记录：

- Linear queue evidence。
- MTP-96 至 MTP-101 已合并 PR / required checks evidence。
- `TVM-PAPER-RUNTIME-KERNEL`、`TVM-REPORT-EVIDENCE` 和 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` evidence chain。
- forbidden capability evidence。
- read-model-only boundary evidence。
- validation evidence 和 Parent Codex Stage Code Audit handoff checklist。

## MTP-102-NO-FINAL-STAGE-CODE-AUDIT

MTP-102 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，
不推进下一 issue，不启动下一阶段 `symphony-issue`，不修改 Linear status，不运行 Graphify full rebuild。

## MTP-102-PAPER-RUNTIME-STAGE-CLOSEOUT-VALIDATION

Validation 必须覆盖：

- `Tests/AppTests/AppTests.swift` 中的 `testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline`。
- Report / Dashboard / Event Timeline 的 paper runtime evidence chain。
- Dashboard smoke 中的 `paperRuntimeEvidence`、`paperWorkflowEvidence` 和 `paperPortfolioImpact`。
- `docs/validation/trading-validation-matrix.md` 的 MTP-102 issue backfill。
- `docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md` 和 automation readiness anchors。
- `bash checks/run.sh` 仍是最终 gate。

Core / App anchors：

- `Sources/App/App.swift`
  - `paperExecutionWorkflowLocalLifecycleTransitionIDs`
  - `paperExecutionWorkflowAccountPortfolioSnapshotIDs`
  - `paperExecutionWorkflowSimulatedFillCostImpactAmount`
- `Sources/App/PaperWorkflowEvidenceExplorer.swift`
  - `Paper local lifecycle transition`
- `Sources/App/DashboardShell.swift`
  - `paperRuntimeEvidence`
  - `paperWorkflowEvidence`
  - `paperPortfolioImpact`

Matrix anchor：`TVM-PAPER-RUNTIME-KERNEL`。

## MTP-102 后仍禁止

- 不实现 final Stage Code Audit Report、Project closure、Root Docs Refresh Gate 或下一阶段计划。
- 不新增 live command、order form、order-level command UI、position command、Live PRO Console、stop button 或交易按钮。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、real account update、live risk runtime 或 production runtime。
- 不读取 secret、API key、signed endpoint、account endpoint、listenKey、broker state、真实账户、broker position、margin、leverage、真实 PnL 或 equity。
- 不修改 Linear status，不创建下一 Project / Issue，不启动下一阶段 `symphony-issue`。
