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
- `Sources/Core/PaperRuntimeBusRouting.swift` 必须包含：
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

## MTP-98 后仍禁止

- 不实现 paper lifecycle coordinator。
- 不实现 simulated fill / fee / slippage model。
- 不实现 paper account / portfolio projection v2。
- 不新增 App / Dashboard surface。
- 不读取 secret、API key、account endpoint、listenKey、broker state、真实账户或 production runtime。
- 不修改 Linear status，不创建下一 Project / Issue，不启动下一阶段 `symphony-issue`。
