# Simulated Exchange / Backtest Parity Contract

日期：2026-05-26

执行者：Codex

本文档定义 `MTPRO Simulated Exchange / Backtest Parity v1` 的 L2 simulated exchange / backtest parity terminology、目标引擎职责、L1 Paper Runtime 与 L1.5 Data Catalog / Scenario Replay 到 L2 的 handoff boundary、forbidden capability baseline、source docs anchors 和 validation anchors。

本文档服务 `MTP-110` 至 `MTP-111` 的术语 / 边界合同；它不实现撮合、不实现订单执行、不实现 portfolio projection、不实现 UI，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、trading button，不运行 Graphify，不修改 Figma。

## MTP-110 Simulated Exchange / Backtest Parity terminology

`MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`

MTP-110 只允许定义以下术语，不允许把术语升级为实现：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `simulated exchange` | 本地 deterministic simulation 的术语入口，用于后续模拟撮合和回测 / Paper 共享语义 | 不等于真实交易所、broker、execution venue 或 live readiness |
| `backtest parity` | backtest 与 paper runtime 共享同一模拟交易语义和证据口径 | 不等于 live parity、broker reconciliation 或生产一致性声明 |
| `matching model` | 后续 deterministic matching contract 的名称 | 当前不实现撮合 runtime、不读取真实 order book 或 broker feed |
| `fill model` | 后续 simulated fill / full fill / partial fill 语义入口 | 不等于 broker fill、execution report 或真实成交质量 |
| `latency model` | 后续 deterministic latency assumption 语义入口 | 不等于 production telemetry、exchange latency 或 broker SLA |
| `fee / slippage parity` | backtest 与 paper runtime 共享交易摩擦假设 | 不等于真实费率表、broker fee statement 或 live execution cost optimization |
| `portfolio projection parity` | 后续 simulated exchange event 到 paper / backtest portfolio projection 的一致语义 | 不等于真实账户、broker position、margin、leverage 或 reconciliation |
| `scenario replay integration` | L1.5 scenario replay 作为 L2 deterministic input 的 handoff 语言 | 不等于 production data platform、network downloader 或 Runtime replay job |
| `deterministic simulation` | 所有 L2 parity evidence 必须可由本地 fixture / scenario replay 重放 | 不等于真实交易所模拟环境或 live runtime |
| `shared backtest-paper order semantics` | 后续 MTP-111 定义的 backtest / paper 共享订单语义入口 | 当前不实现 order semantics runtime、order form 或 command model |

Core deterministic fixture：`SimulatedExchangeBacktestParityBoundary`。

Focused Core tests：

- `testMTP110SimulatedExchangeBacktestParityDefinesTerminologyAndBoundaryAnchors`
- `testMTP110SimulatedExchangeBacktestParityRejectsRuntimeAndLiveBypass`
- `testMTP110SimulatedExchangeBacktestParityKeepsL2HandoffDeterministic`

## MTP-110 target engine responsibility boundary

`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`

MTP-110 固定六类目标引擎职责：

| Target Engine | MTP-110 允许职责 | 当前禁止 |
| --- | --- | --- |
| `Simulation / Backtest Engine` | 定义 L2 simulated exchange / matching / fill / latency / cost parity 的术语入口 | 不实现 matching runtime、historical execution engine 或 production backtest engine |
| `Execution Engine (paper-only / simulated)` | 说明后续 execution 只能保持 paper-only / simulated | 不实现 OMS、broker router、real submit / cancel / replace 或 `LiveExecutionAdapter` |
| `Portfolio Engine` | 定义后续 simulated event -> portfolio parity 的边界语言 | 不读取真实账户、broker position、margin、leverage，不实现 reconciliation |
| `Data Engine` | 复用 L1.5 scenario replay deterministic input 语义 | 不实现真实网络下载、production data platform 或 broker feed |
| `State & Persistence Engine` | 说明后续 facts / replay / projection 必须可追溯 | 不暴露 SQLite / DuckDB schema，不新增 Runtime job 或 database console |
| `Workbench Interface` | 后续只消费 read model / ViewModel parity evidence | 当前不新增 UI，不提供 command surface、Live PRO Console、trading button 或 live command |

`SimulatedExchangeBacktestParityBoundary.targetEngineBoundaryHeld` 必须为 `true`，并且 `implementsMatchingRuntime`、`implementsOrderExecutionRuntime`、`implementsPortfolioProjectionRuntime` 和 `implementsUI` 必须为 `false`。

## MTP-110 L1 / L1.5 / L2 handoff boundary

`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`

MTP-110 的 handoff boundary：

- `L1 Paper Runtime handoff`：后续 L2 只能复用 paper-only runtime 的 TradingClock、paper routing、paper risk、local lifecycle、simulated fill、paper account / portfolio projection 和 Event Log / Replay evidence 语言；不得升级为真实 execution runtime。
- `L1.5 Data Catalog / Scenario Replay handoff`：后续 L2 只能消费 local scenario manifest、fixture version、replay window / cursor、checksum / freshness evidence、quality gates 和 report input versioning 的 deterministic input identity；不得升级为 production data platform。
- `L2 Backtest / Simulation Parity`：当前只定义共同语言；后续 issue 才能逐步定义 shared order semantics、deterministic matching、market / limit simulated execution、partial fill / latency / fee / slippage parity、portfolio projection parity 和 read-model evidence surface。
- `read-model-only parity evidence surface`：Report / Dashboard / Events 的 L2 evidence 只能在后续 issue 以 read model / ViewModel 进入，当前不实现 UI 或 command surface。

`SimulatedExchangeBacktestParityBoundary.deterministicSimulationBoundaryHeld` 必须为 `true`。

## MTP-110 forbidden capability baseline

`MTP-110-FORBIDDEN-CAPABILITY-BASELINE`

MTP-110 必须保持以下 forbidden capabilities：

- matching runtime
- order execution runtime
- portfolio projection runtime
- UI implementation
- secret read
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- real account / broker position / margin / leverage read
- live runtime
- Live PRO Console
- live command
- trading button
- emergency stop / shutdown / restore
- Graphify update
- Figma change

Core fixture 中对应 Boolean flags 必须全部保持 `false`，并且 Codable 解码不能绕过该边界。

## MTP-110 source docs anchors

MTP-110 的 source docs anchors：

- `GOAL.md`
- `BLUEPRINT.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `docs/domain/context.md`
- `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`
- `docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md`
- `docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md`
- `docs/planning/projects/mtpro-simulated-exchange-backtest-parity-v1-plan.md`
- `docs/validation/latest-verification-summary.md`

这些 anchors 只说明术语和边界来源，不替代 Linear issue body，不授权后续 issue scope。

## MTP-110 validation anchors

`MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION`

Required validation：

- `swift test --filter MTP110`
- `bash checks/run.sh`

Validation anchors：

- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`
- `MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`
- `MTP-110-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-110 不新增 Dashboard smoke handle，不新增 App read model，不新增 stage audit input；Project stage closeout 仍归属 `MTP-117`。

## MTP-111 shared backtest-paper order semantics contract

`MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`

MTP-111 定义 backtest 与 paper runtime 共用的 shared order input 字段。字段只服务 deterministic simulation / backtest replay，不表达真实订单命令：

| 字段组 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `input id` / `order id` / `source paper order intent id` | backtest replay order input 与既有 `PaperOrderIntent` 的稳定身份映射 | 不等于 broker order id、exchange order id、OMS id 或 UI order form id |
| `proposal id` / `session id` | 复用 paper runtime proposal / session evidence | 不授权 order-level command 或真实 session control |
| `scenario id` / `dataset version` / `fixture version` | 绑定 L1.5 scenario replay deterministic input identity | 不等于 production dataset registry、network download job 或 broker feed |
| `symbol` / `timeframe` / `side` / `quantity` / `reference price` / `notional amount` | 复用 paper-only order intent 的最小订单语义字段 | 不定义 market / limit order execution；MTP-113 才能继续定义 market / limit simulated execution semantics |
| `source risk decision sequence` / `source replay sequence` / `recorded at` | 对齐 paper risk decision 与 backtest replay 的 append-only sequence evidence | 不等于 exchange sequence、broker sequence、execution report sequence 或 production scheduler |

Core deterministic fixtures：

- `BacktestPaperSharedOrderSemanticsContract.deterministicFixture`
- `BacktestPaperSharedOrderInput.deterministicFixture`

Focused Core tests：

- `testMTP111SharedBacktestPaperOrderSemanticsDefinesFieldsStatesAndAnchors`
- `testMTP111SharedBacktestPaperOrderInputAlignsPaperIntentWithScenarioReplay`
- `testMTP111SharedBacktestPaperOrderSemanticsRejectsRealCommandBypass`

`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`

MTP-111 固定 shared simulated order state taxonomy：

| 状态 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `intent recorded` | paper order intent 已记录，可映射为 backtest replay order input | 不等于 real submit intent |
| `submitted simulated` | 本地 submitted local 可重放为 simulated submitted evidence | 不等于 broker submitted |
| `accepted simulated` | MTP-99 `acceptedLocal` 可重放为 simulated accepted evidence | 不等于 exchange accepted 或真实订单可成交 |
| `rejected simulated` | paper risk rejected / rejected local 可重放为 simulated rejected evidence | 不等于 broker rejection 或 exchange reject |
| `expired simulated` | local expiry 可重放为 simulated expired evidence | 不等于 broker expiry 或 exchange order expiry |
| `cancelled local only` | session close / reset / local rule 的本地取消证据 | 不等于用户单笔撤单、broker cancel 或 real cancel command |
| `failed local only` | 本地 deterministic failure evidence | 不等于 production incident、broker failure 或 live recovery |
| `filled simulated` | full simulated fill completion 的 shared state | 不等于 broker fill、execution report 或真实成交 |
| `partially filled simulated` | partial simulated fill completion 的 shared state | 不等于 broker partial fill 或真实成交质量 |

对应 simulated event kind 只允许进入 append-only replay facts：`order intent recorded`、`simulated order submitted`、`simulated order accepted`、`simulated order rejected`、`simulated order expired`、`simulated order cancelled local`、`simulated order failed local`、`simulated order filled` 和 `simulated order partially filled`。

`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`

MTP-111 固定 paper runtime lifecycle 与 backtest replay 的对齐规则：

- `PaperOrderLifecycleState.intentCreated` -> `intent recorded`。
- `PaperOrderLifecycleState.rejectedByRisk` -> `rejected simulated`。
- `PaperOrderLocalLifecycleState.submittedLocal` -> `submitted simulated`。
- `PaperOrderLocalLifecycleState.acceptedLocal` -> `accepted simulated`。
- `PaperOrderLocalLifecycleState.rejectedByPaperRisk` -> `rejected simulated`。
- `PaperOrderLocalLifecycleState.expiredLocal` -> `expired simulated`。
- `PaperOrderLocalLifecycleState.cancelledLocal` -> `cancelled local only`。
- `PaperOrderLocalLifecycleState.failedLocal` -> `failed local only`。
- `PaperSimulatedFillCompletion.full` -> `filled simulated`。
- `PaperSimulatedFillCompletion.partial` -> `partially filled simulated`。
- scenario identity 必须匹配 replay input：`scenario id`、`dataset version`、`fixture version`、`symbol` 和 `timeframe` 不能漂移。
- order event 只能作为 append-only replay fact，不实现 matching runtime、execution runtime、portfolio runtime 或 UI。

`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`

MTP-111 必须保持以下 forbidden capabilities 全部为 false：

- matching runtime
- order execution runtime
- portfolio projection runtime
- real order command
- real order lifecycle
- real submit / cancel / replace
- secret read
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- execution report
- broker fill
- reconciliation
- real account / broker position / margin / leverage read
- live runtime
- Live PRO Console
- live command
- order-level command UI
- trading button
- emergency stop / shutdown / restore

`BacktestPaperSharedOrderSemanticsContract` 和 `BacktestPaperSharedOrderInput` 初始化与 Codable 解码都必须拒绝 real command、signed/account/listenKey、broker、OMS、execution report、broker fill、reconciliation、live command 或 trading button 绕过。

## MTP-111 validation anchors

`MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION`

Required validation：

- `swift test --filter MTP111`
- `bash checks/run.sh`

Validation anchors：

- `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`
- `MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`
- `MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`
- `MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`
- `MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-111 不实现 matching model、market / limit execution、partial fill / latency / fee / slippage parity runtime、portfolio projection parity、Report / Dashboard / Events evidence surface 或 stage audit input；这些仍归属后续 `MTP-112` 至 `MTP-117`。
