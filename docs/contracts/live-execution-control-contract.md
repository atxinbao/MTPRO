# Live Execution Control Contract

日期：2026-05-22

执行者：Codex

本文档定义 `MTPRO Live Execution Control Contract v1` 的 Future Live Execution terminology、real order command taxonomy、paper / real command isolation 和 validation anchor 候选入口。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不实现 API key、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback automation、live command 或交易按钮。

## MTP-75 Live execution control terminology

`MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`

Live execution control 在当前 Project 中不是可执行实盘交易能力，而是一组 Future / gated terminology。MTP-75 只允许定义这些词汇、taxonomy 和 validation anchors，不允许把它们变成 command API、adapter、Runtime workflow 或 UI 操作入口。

| Term | 中文定义 | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `execution control` | Future Live 中对真实订单提交、撤销、替换、执行回报、对账和失败处理的控制边界。 | Future / gated terminology | 合同术语、validation anchor、deterministic forbidden test | 当前 command API、UI 控制台、真实交易授权 |
| `real order command` | Future Live 可能需要的真实订单命令族名称。 | Future / gated taxonomy | taxonomy label、future gate | Swift command、order form、broker request |
| `submit` | Future 真实订单提交命令。 | Forbidden now | future submit contract anchor | HTTP / SDK submit、真实订单创建 |
| `cancel` | Future 真实订单撤销命令。 | Forbidden now | future cancel contract anchor | cancel command、broker cancel request |
| `replace` | Future 真实订单替换命令。 | Forbidden now | future replace contract anchor | replace command、order amendment |
| `execution report` | Future broker / exchange execution report 输入。 | Future / gated | future execution report contract | 当前 ingestion、event、read model 授权 |
| `broker fill` | Future broker / exchange fill 事实。 | Future / gated | future broker fill contract | simulated fill 升级、真实账户更新 |
| `reconciliation` | Future 本地订单状态与 broker / exchange 状态核对。 | Future / gated | future reconciliation contract | 当前 reconciliation service |
| `incident fallback` | Future 执行失败、连接失败或 broker 异常时的受控降级 / 人工接管策略。 | Future / gated | future incident fallback contract | 自动恢复、继续下单、停机控制 |
| `paper order intent` | 既有 paper-only order intent value model。 | Current / isolated paper evidence | paper / real isolation evidence | real order command 输入 |
| `paper execution decision` | 既有 paper-only execution decision chain。 | Current / isolated paper evidence | paper / real isolation evidence | execution-control command 输入 |
| `simulated fill evidence` | 既有 deterministic simulated fill evidence。 | Current / isolated paper evidence | paper / real isolation evidence | broker fill 或 execution report |

## MTP-75 real order command taxonomy

`MTP-75-REAL-ORDER-COMMAND-TAXONOMY`

MTP-75 的 real order command taxonomy 只固定分类，不提供可执行 command surface：

| Taxonomy term | 含义 | 当前禁止 |
| --- | --- | --- |
| `submit` | Future 真实订单提交。 | 不实现 submit command、order submit transport 或 broker SDK submit。 |
| `cancel` | Future 真实订单撤销。 | 不实现 cancel command、cancel request 或 broker cancel。 |
| `replace` | Future 真实订单替换。 | 不实现 replace command、order amendment 或参数替换。 |
| `execution report` | Future 执行回报输入。 | 不消费 execution report，不把 read model 写成真实订单状态。 |
| `reconciliation` | Future 对账链路。 | 不实现 reconciliation service、account sync 或 broker position sync。 |
| `incident fallback` | Future 执行事故处理边界。 | 不实现自动恢复、继续执行、停机 / 恢复命令或 incident command。 |

## MTP-75 paper / real command isolation

`MTP-75-PAPER-REAL-COMMAND-ISOLATION`

MTP-75 必须保持 paper-only execution evidence 和 future real order command 隔离：

- `PaperOrderIntent` 仍只是 paper-only order intent；不得作为 real order command 输入。
- `PaperExecutionDecision` 仍只是 paper-only decision chain；不得授权 submit / cancel / replace。
- `PaperSimulatedFillEvidence` 仍只是 deterministic simulated fill evidence；不得升级为 broker fill、execution report 或 account update。
- `LiveExecutionControlTerminologyBoundary` 的 paper upgrade flags 必须全部为 `false`。

Source anchors：

- `TVM-PAPER-ORDER-LIFECYCLE`
- `TVM-PAPER-EXECUTION-DECISION`
- `TVM-PAPER-SIMULATED-FILL`
- `MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION`
- `MTP-75-PAPER-REAL-COMMAND-ISOLATION`

## MTP-75 no executable command surface

`MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`

MTP-75 的 non-implementation evidence 必须来自三层本地证据：

- Core deterministic fixture：`LiveExecutionControlTerminologyBoundary` 只定义 terminology、taxonomy、future gates、forbidden capabilities 和 validation anchors。
- Core deterministic tests：`testLiveExecutionControlTerminologyDefinesMTP75FutureOnlyTaxonomy`、`testLiveExecutionControlTerminologyRejectsMTP75ExecutableCommandBypass` 和 `testLiveExecutionControlTerminologyKeepsMTP75PaperEvidenceIsolatedFromRealCommands`。
- Required validation：`bash checks/run.sh`；不得依赖真实 Binance 网络、API key、account endpoint、listenKey、broker state 或真实账户。

禁止能力 baseline：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- real order state machine / OMS。
- real order submit / cancel / replace。
- execution report implementation。
- broker fill implementation。
- reconciliation implementation。
- incident fallback automation。
- paper order intent / paper execution decision / simulated fill 升级。
- live command surface。
- order-level command UI。
- trading button / order form。

## MTP-75 validation anchors

`MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION`

MTP-75 建立以下 validation anchors，供后续 issue 接入 forbidden capability tests：

- `TVM-LIVE-EXECUTION-CONTROL`
- `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`
- `MTP-75-REAL-ORDER-COMMAND-TAXONOMY`
- `MTP-75-PAPER-REAL-COMMAND-ISOLATION`
- `MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-76 submit / cancel / replace future gates

`MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`

MTP-76 把 `submit`、`cancel` 和 `replace` 从 MTP-75 taxonomy 进一步收窄为 future gate contract。当前系统仍不得提供真实订单提交、撤销或替换能力；这些词只允许作为 future gate、blocked evidence 和 deterministic forbidden tests 出现。

| Command | Future gate 条件 | 当前状态 | 当前禁止输出 |
| --- | --- | --- | --- |
| `submit` | Human 独立 Live decision、credential endpoint boundary、adapter capability isolation、real order lifecycle boundary、future submit command contract、future live risk gate、execution report / reconciliation gate、operations / audit handoff。 | Forbidden now | submit command API、signed submit request、broker submit action、order form、trading button |
| `cancel` | Human 独立 Live decision、credential endpoint boundary、adapter capability isolation、real order lifecycle boundary、future cancel command contract、future live risk gate、execution report / reconciliation gate、operations / audit handoff。 | Forbidden now | cancel command API、signed cancel request、broker cancel action、order-level command UI |
| `replace` | Human 独立 Live decision、credential endpoint boundary、adapter capability isolation、real order lifecycle boundary、future replace command contract、future live risk gate、execution report / reconciliation gate、operations / audit handoff。 | Forbidden now | replace command API、signed replace request、broker replace action、order amendment UI |

Core fixture：`LiveSubmitCancelReplaceCommandBoundary` 固定以下 gates：

- Human independent Live execution decision。
- credential endpoint boundary satisfied。
- adapter capability isolation satisfied。
- real order lifecycle boundary satisfied。
- future submit command contract defined。
- future cancel command contract defined。
- future replace command contract defined。
- future live risk gate defined。
- future execution report / reconciliation gate defined。
- future operations / audit handoff defined。

## MTP-76 forbidden submit / cancel / replace capability tests

`MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`

MTP-76 的 forbidden capability tests 必须覆盖：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter 和 `LiveExecutionAdapter`。
- real order state machine / OMS。
- submit / cancel / replace command API。
- signed submit / cancel / replace request。
- broker submit / cancel / replace action。
- order form、order-level command UI、live command surface 和 trading button。
- paper order intent / paper execution decision / simulated fill 升级为真实 submit / cancel / replace。
- required validation 依赖真实网络。

Core tests：

- `testLiveSubmitCancelReplaceBoundaryDefinesMTP76FutureGatesAndForbiddenCommands`
- `testLiveSubmitCancelReplaceBoundaryRejectsMTP76RealCommandBypass`
- `testPaperOrderIntentCannotUpgradeToMTP76SubmitCancelReplaceCommands`

## MTP-76 no real submit / cancel / replace

`MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`

`LiveSubmitCancelReplaceCommandBoundary` 的以下 flags 必须全部保持 `false`：

- `submitsRealOrder`
- `cancelsRealOrder`
- `replacesRealOrder`
- `sendsSignedSubmitRequest`
- `sendsSignedCancelRequest`
- `sendsSignedReplaceRequest`
- `providesExecutableCommandSurface`
- `exposesOrderForm`
- `exposesOrderLevelCommandUI`
- `providesTradingButton`

这些 flags 只用于证明当前系统没有真实 submit / cancel / replace，不代表存在 mock broker、sandbox broker、paper-to-live fallback 或隐藏命令入口。

## MTP-76 paper intent no real command upgrade

`MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE`

MTP-76 必须保持 paper-only intent 与 future real order command 隔离：

- `PaperOrderIntent` 不得映射为 real submit。
- `PaperOrderIntent` 不得映射为 real cancel。
- `PaperOrderIntent` 不得映射为 real replace。
- `PaperExecutionDecision` 不得升级为 real order command。
- `PaperSimulatedFillEvidence` 不得升级为 broker fill、execution report 或 account update。

Source anchors：

- `MTP-75-REAL-ORDER-COMMAND-TAXONOMY`
- `MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`
- `MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION`
- `TVM-PAPER-ORDER-LIFECYCLE`
- `TVM-PAPER-EXECUTION-DECISION`
- `TVM-PAPER-SIMULATED-FILL`

## MTP-76 validation anchors

`MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION`

MTP-76 建立以下 validation anchors：

- `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`
- `MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`
- `MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`
- `MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE`
- `MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-77 execution report / broker fill / reconciliation future gates

`MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`

MTP-77 把 `execution report`、`broker fill` 和 `reconciliation` 从 MTP-75 terminology 进一步收窄为 future gate contract。当前系统仍不得消费执行回报、记录 broker fill 或执行账户 / broker position 对账；这些词只允许作为 future gate、blocked evidence 和 deterministic forbidden tests 出现。

| Capability | Future gate 条件 | 当前状态 | 当前禁止输出 |
| --- | --- | --- | --- |
| `execution report` | Human 独立 Live decision、credential endpoint boundary、adapter capability isolation、real order lifecycle boundary、submit / cancel / replace boundary、future execution report schema contract、future live risk / operations / audit handoff。 | Forbidden now | execution report parser、execution report ingestion、真实订单状态更新、当前 read model 授权。 |
| `broker fill` | Human 独立 Live decision、broker / exchange adapter capability、future broker fill fact contract、real account state read boundary、future reconciliation contract、future audit trail。 | Forbidden now | broker fill recorder、broker fill event fact、simulated fill 升级、真实账户更新。 |
| `reconciliation` | Human 独立 Live decision、future account state read boundary、future broker position boundary、future local order state contract、future audit / incident handoff。 | Blocked evidence only | reconciliation service、account sync、broker position sync、real account balance read、OMS 状态修复。 |

Core fixture：`LiveExecutionReportBrokerFillReconciliationBoundary` 固定以下 gates：

- Human independent Live execution decision。
- credential endpoint boundary satisfied。
- adapter capability isolation satisfied。
- real order lifecycle boundary satisfied。
- submit / cancel / replace boundary satisfied。
- future execution report schema contract defined。
- future broker fill fact contract defined。
- future reconciliation contract defined。
- future account state read boundary defined。
- future live risk / operations / audit handoff defined。

## MTP-77 forbidden report / fill / reconciliation capability tests

`MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`

MTP-77 的 forbidden capability tests 必须覆盖：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter 和 `LiveExecutionAdapter`。
- real order state machine / OMS。
- submit / cancel / replace 仍保持 false。
- execution report parser / ingestion / current read model authorization。
- broker fill recorder / broker fill event fact。
- reconciliation service / reconciliation runtime。
- account sync、real account balance read 和 broker position sync。
- simulated fill 升级为 broker fill 或 execution report。
- paper portfolio projection 升级为 broker position。
- required validation 依赖真实网络。

Core tests：

- `testExecutionReportBrokerFillReconciliationBoundaryDefinesMTP77FutureGates`
- `testExecutionReportBrokerFillReconciliationBoundaryRejectsMTP77ImplementationBypass`
- `testSimulatedFillAndPaperPortfolioCannotUpgradeToMTP77BrokerFillOrReconciliation`

## MTP-77 simulated fill no broker fill or execution report

`MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`

MTP-77 必须保持 paper-only simulated fill 与 future broker fill / execution report 隔离：

- `PaperSimulatedFillEvidence` 仍只是 deterministic simulated fill evidence。
- simulated fill 不得映射为 broker fill。
- simulated fill 不得映射为 execution report。
- simulated fill 不得更新真实账户余额。
- `PaperPortfolioProjectionUpdate` 仍只能来自 simulated fill evidence，不得映射为 broker position 或 real account state。

Source anchors：

- `MTP-75-REAL-ORDER-COMMAND-TAXONOMY`
- `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`
- `MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`
- `MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION`
- `TVM-PAPER-ORDER-LIFECYCLE`
- `TVM-PAPER-SIMULATED-FILL`
- `TVM-PAPER-EXECUTION-WORKFLOW`

## MTP-77 reconciliation blocked evidence only

`MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY`

MTP-77 中 reconciliation 只能作为 future gate 和 blocked evidence 出现。当前系统不得读取真实账户、不读取 broker position、不做 account sync、不做 OMS 状态修复，也不得把 paper portfolio projection 当作 broker position。

`LiveExecutionReportBrokerFillReconciliationBoundary` 的以下 flags 必须全部保持 `false`：

- `consumesExecutionReport`
- `parsesExecutionReport`
- `ingestsExecutionReport`
- `recordsBrokerFill`
- `storesBrokerFillFact`
- `performsReconciliation`
- `implementsReconciliationRuntime`
- `readsRealAccountBalance`
- `syncsBrokerPosition`
- `mapsSimulatedFillToBrokerFill`
- `mapsSimulatedFillToExecutionReport`
- `mapsPaperPortfolioToBrokerPosition`
- `updatesRealAccountFromSimulatedFill`
- `exposesBrokerFillAsCurrentReadModel`

## MTP-77 validation anchors

`MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION`

MTP-77 建立以下 validation anchors：

- `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`
- `MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`
- `MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`
- `MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY`
- `MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-78 paper / real command isolation contract

`MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`

MTP-78 把既有 paper-only evidence 与 future real order command 明确隔离。当前系统可以继续展示 paper order intent、paper execution decision、simulated fill evidence 和 paper portfolio projection，但这些 evidence 只能作为 research / paper / report / timeline 的只读证据，不能成为 submit / cancel / replace、execution report、broker fill 或 reconciliation 的输入。

Core fixture：`LivePaperRealCommandIsolationBoundary` 固定以下 evidence sources：

- `paper order intent`
- `paper execution decision`
- `simulated fill evidence`
- `paper portfolio projection`
- `report read model`
- `dashboard ViewModel`
- `event timeline read model`

该 fixture 只引用 MTP-75 / MTP-76 / MTP-77 已建立的 future-gate anchors，不新增真实执行能力。

## MTP-78 paper evidence no real command upgrade

`MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`

MTP-78 必须证明 paper-only evidence 不能升级为 future real order command：

- `PaperOrderIntent` 不得映射为 real order command、real submit、real cancel 或 real replace。
- `PaperExecutionDecision` 不得授权 real order command。
- `PaperSimulatedFillEvidence` 不得映射为 real order command、execution report 或 broker fill。
- `PaperPortfolioProjectionUpdate` 不得映射为 broker position、real account state 或 reconciliation input。
- `LivePaperRealCommandIsolationBoundary.paperEvidenceCannotUpgradeToRealCommand` 必须为 `true`。

禁止能力 baseline：

- real order command / real submit / real cancel / real replace。
- signed command request。
- execution report ingestion。
- broker fill event fact。
- reconciliation runtime。
- real account state / broker position sync。
- `LiveExecutionAdapter`、real order state machine 和 OMS。
- paper-to-real upgrade。
- report / dashboard / event timeline command surface。
- order form、order-level command UI 和 trading button。

## MTP-78 paper projection read-model-only

`MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`

Paper portfolio projection 仍然只能从 replay 后的 `PaperSimulatedFillEvidence` 派生：

- `PaperPortfolioProjectionUpdate.usesSimulatedFillEvidence` 必须为 `true`。
- `PaperPortfolioProjectionUpdate.exposure.source` 必须保持 `paperProjection`。
- `PaperPortfolioProjectionUpdate.authorizesTradingExecution` 必须为 `false`。
- `PaperPortfolioProjectionUpdate.readsRealAccountBalance` 必须为 `false`。
- `PaperPortfolioProjectionUpdate.syncsBrokerPosition` 必须为 `false`。

该 projection 只进入 Report / Dashboard / Event Timeline 的 read model / ViewModel，不代表真实账户余额、broker position、account sync 或 reconciliation。

## MTP-78 report / dashboard / timeline read-model-only

`MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`

MTP-78 必须验证展示面仍然只消费 read model / ViewModel：

- `ReportViewModel` 只能汇总 paper workflow evidence、paper portfolio projection、Live blocked evidence 和 Live monitoring evidence；不得提供 command surface、order form、交易按钮或真实交易授权。
- `DashboardShellSnapshot` 只能从 `DashboardViewModel` 生成只读 snapshot；Workbench session controls 仍限于 local paper session-level `start` / `pause` / `close` / `reset` 展示。
- `PaperWorkflowEvidenceExplorerViewModel` / Event Timeline 只能展示 evidence links 和 timeline rows；不得提供 query language、Runtime command、order-level command、live audit、incident replay 或 stop control。

Core / App tests：

- `testPaperRealCommandIsolationBoundaryDefinesMTP78Contract`
- `testPaperRealCommandIsolationBoundaryRejectsMTP78RealCommandUpgradeBypass`
- `testPaperEvidenceCannotUpgradeToMTP78FutureRealOrderCommand`
- `testReportDashboardAndTimelineRemainMTP78ReadModelOnly`

## MTP-78 validation anchors

`MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION`

MTP-78 建立以下 validation anchors：

- `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`
- `MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`
- `MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`
- `MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-79 live execution-control blocked evidence

`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`

MTP-79 新增 `LiveExecutionControlBlockedEvidence` read model，用只读方式汇总 execution-control gates 为什么仍被阻断。该模型只作为后续 Dashboard / Report / Event Timeline 的 deterministic snapshot 输入，不实现任何 execution runtime、adapter、schema、command 或 UI control。

Core fixture：`LiveExecutionControlBlockedEvidence` 固定以下 blocked gates：

- `submit`
- `cancel`
- `replace`
- `execution report`
- `broker fill`
- `reconciliation`
- `incident fallback`

## MTP-79 execution-control gates blocked reasons

`MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`

`LiveExecutionControlBlockedEvidence.blockedItems` 必须逐项说明 blocked reason：

- `submit` / `cancel` / `replace`：Human live decision、credential endpoint boundary、signed command request、broker execution adapter、live risk / operations / audit evidence 仍未满足。
- `execution report`：account endpoint、listenKey user data stream、execution report implementation 和 read-model-only boundary 仍阻断。
- `broker fill`：broker execution adapter、broker fill implementation、real order state machine 和 paper / real command isolation 仍阻断。
- `reconciliation`：account endpoint、reconciliation runtime、broker position sync 和 read-model-only boundary 仍阻断。
- `incident fallback`：incident fallback automation、live risk / operations / audit evidence 和 read-model-only boundary 仍阻断。

## MTP-79 deterministic blocked evidence snapshot

`MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`

`LiveExecutionControlBlockedEvidence.deterministicSnapshot` 必须保持稳定顺序和稳定文本，供后续展示面消费：

```text
submit|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing
cancel|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing
replace|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing
execution report|blocked|account endpoint forbidden;listenKey user data stream forbidden;execution report implementation forbidden;read model only boundary required
broker fill|blocked|broker execution adapter forbidden;broker fill implementation forbidden;real order state machine forbidden;paper / real command isolation required
reconciliation|blocked|account endpoint forbidden;reconciliation runtime forbidden;broker position sync forbidden;read model only boundary required
incident fallback|blocked|incident fallback automation forbidden;live risk operations audit missing;read model only boundary required
```

## MTP-79 read-model-only no command surface

`MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-79 必须验证 `LiveExecutionControlBlockedEvidence` 保持只读边界：

- `isReadModelOnly`、`reportConsumesReadModelOnly`、`dashboardConsumesViewModelOnly` 和 `eventTimelineConsumesReadModelOnly` 必须为 `true`。
- `exposesPersistenceSchema`、`readsAdapter`、`invokesRuntimeControl` 和 `providesCommandSurface` 必须为 `false`。
- `readsAPIKey`、`storesSecret`、`usesSignedEndpoint`、`callsAccountEndpoint` 和 `createsListenKey` 必须为 `false`。
- `instantiatesBrokerExecutionAdapter`、`instantiatesExchangeExecutionAdapter`、`implementsLiveExecutionAdapter`、`implementsRealOrderStateMachine` 和 `implementsOMS` 必须为 `false`。
- `submitsRealOrder`、`cancelsRealOrder`、`replacesRealOrder`、`consumesExecutionReport`、`recordsBrokerFill`、`performsReconciliation` 和 `executesIncidentFallback` 必须为 `false`。
- `exposesOrderForm`、`exposesOrderLevelCommandUI`、`providesTradingButton` 和 `requiredValidationDependsOnNetwork` 必须为 `false`。

Core tests：

- `testLiveExecutionControlBlockedEvidenceDefinesMTP79ReadModelOnlySnapshot`
- `testLiveExecutionControlBlockedEvidenceRejectsMTP79CommandOrRuntimeBypass`
- `testLiveExecutionControlBlockedEvidenceSummarizesMTP79GateReasonsWithoutExecution`

## MTP-79 validation anchors

`MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION`

MTP-79 建立以下 validation anchors：

- `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`
- `MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-80 Dashboard / Report / Event Timeline execution-control blocked evidence

`MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`

MTP-80 把 MTP-79 `LiveExecutionControlBlockedEvidence` 接入 App 层 Dashboard / Report / Event Timeline 只读展示面。该接入只复制 Core blocked evidence 到 `LiveExecutionControlBlockedEvidenceReadModel`、`LiveExecutionControlBlockedEvidenceViewModel`、`ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel`；不得把 blocked evidence 转换成 command surface、order form、交易按钮、adapter request、Runtime control 或 persistence schema。

展示面必须覆盖以下 execution-control gates：

- `submit`
- `cancel`
- `replace`
- `execution report`
- `broker fill`
- `reconciliation`
- `incident fallback`

## MTP-80 execution-control read-model-only surface

`MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`

MTP-80 的 App 层读模型必须保持以下边界：

- Report 展示 blocked gate count、blocked gate labels、blocked reason labels、source anchors、deterministic snapshot 和 read-model-only boundary。
- Dashboard Shell Report section 展示 `Execution control` 指标和 execution-control boundary details。
- Dashboard Workbench 展示 `Live Execution Control` detail group，包含 gate count、reason count、blocked confirmation 和 no command / no order form / no trading button / no schema / no runtime / no adapter evidence。
- Event Timeline / Evidence Explorer 新增 `live execution control blocked evidence` section，为七个 gate 生成只读 timeline item 和 evidence link。
- Dashboard smoke summary 新增 `liveExecutionControlGates=7` evidence。

## MTP-80 no live command or order form

`MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM`

MTP-80 必须证明展示层没有越界：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不消费 execution report，不记录 broker fill，不执行 reconciliation 或 incident fallback automation。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter request 或 Runtime object。
- 不新增交易按钮、order form、live command 或 order-level command UI。

App tests：

- `testLiveExecutionControlBlockedEvidenceViewModelAggregatesMTP80ReadOnlySurface`
- `testLiveExecutionControlEvidenceExplorerPreviewDefinesMTP80ReadOnlyTimelineItems`
- `testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`
- `testDashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly`
- `testDashboardViewModelStateSnapshotIsCodableAndDeterministic`
- `testReportDashboardAndTimelineRemainMTP78ReadModelOnly`

## MTP-80 validation anchors

`MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION`

MTP-80 建立以下 validation anchors：

- `MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`
- `MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM`
- `MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION`

本 issue 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 automation readiness 收口保留给 Issue 7。

## MTP-81 Live Execution Control stage closeout

`MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`

MTP-81 只收口 `MTPRO Live Execution Control Contract v1` 的 validation matrix、automation readiness、Dashboard smoke、forbidden capability evidence、read-model-only boundary evidence 和 Stage Audit input material。它不输出最终 Stage Code Audit Report；最终报告必须由 Parent Codex 在 Project 全部有效 issues `Done` 且 Linear Project status `Completed`、`type=completed`、`completedAt` 非空后单独输出。

MTP-81 收口范围：

- MTP-75 至 MTP-80 的 contract / source / test / validation evidence chain。
- `TVM-LIVE-EXECUTION-CONTROL` matrix entry。
- Dashboard smoke `liveExecutionControlGates=7` evidence。
- forbidden capability evidence：API key、secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report parser / ingestion、broker fill recorder / event fact、reconciliation runtime、incident fallback automation、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 和交易按钮均仍被禁止。
- Stage Audit input material：`docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md`。

## MTP-81 Stage Audit input material

`MTP-81-STAGE-AUDIT-INPUT-MATERIAL`

MTP-81 的 Stage Audit input material 必须服务 Parent Codex 后续审计，而不是替代审计报告本身。该材料必须包含：

- Issue / PR evidence input。
- Live execution control validation evidence chain。
- Dashboard smoke evidence。
- Forbidden capability evidence。
- Read-model-only boundary evidence。
- Automation readiness evidence。
- Root Docs Delta input。
- Stage Code Audit handoff checklist。

## MTP-81 no final Stage Code Audit

`MTP-81-NO-FINAL-STAGE-CODE-AUDIT`

MTP-81 明确不输出最终 Stage Code Audit Report，不创建或推进下一 Project / Issue，不启动下一阶段 `symphony-issue`，不把 planning notes 当执行授权，不实现任何 real order command、signed command request、broker action、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、live command、order form、order-level command UI 或交易按钮。

## MTP-81 validation anchors

`MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`

MTP-81 建立以下 validation anchors：

- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`
- `MTP-81-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-81-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-AUDIT-INPUT`
- `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`
- `MTP-81-AUTOMATION-READINESS-STAGE-CLOSEOUT`
