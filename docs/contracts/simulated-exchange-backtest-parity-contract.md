# Simulated Exchange / Backtest Parity Contract

日期：2026-05-26

执行者：Codex

本文档定义 `MTPRO Simulated Exchange / Backtest Parity v1` 的 L2 simulated exchange / backtest parity terminology、目标引擎职责、L1 Paper Runtime 与 L1.5 Data Catalog / Scenario Replay 到 L2 的 handoff boundary、forbidden capability baseline、source docs anchors 和 validation anchors。

本文档服务 `MTP-110` 的术语 / 边界合同；它不实现撮合、不实现订单执行、不实现 portfolio projection、不实现 UI，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、trading button，不运行 Graphify，不修改 Figma。

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
