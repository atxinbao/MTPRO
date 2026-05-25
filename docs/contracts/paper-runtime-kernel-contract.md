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

## 禁止

- 不实现 CommandBus / EventBus / MessageBus routing。
- 不实现 Paper Pre-trade RiskEngine runtime path。
- 不实现 paper lifecycle coordinator。
- 不实现 simulated fill / fee / slippage model。
- 不实现 paper account / portfolio projection v2。
- 不新增 App / Dashboard surface。
- 不读取 secret、API key、account endpoint、listenKey、broker state、真实账户或 production runtime。
- 不修改 Linear status，不创建下一 Project / Issue，不启动下一阶段 `symphony-issue`。
