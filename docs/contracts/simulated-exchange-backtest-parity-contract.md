# Simulated Exchange / Backtest Parity Contract

日期：2026-05-26

执行者：Codex

本文档定义 `MTPRO Simulated Exchange / Backtest Parity v1` 的 L2 simulated exchange / backtest parity terminology、目标引擎职责、L1 Paper Runtime 与 L1.5 Data Catalog / Scenario Replay 到 L2 的 handoff boundary、shared backtest-paper order semantics、scenario replay deterministic matching model、market / limit order simulated execution semantics、partial fill / latency / fee / slippage parity、simulated exchange event 到 portfolio projection parity、forbidden capability baseline、source docs anchors 和 validation anchors。

本文档服务 `MTP-110` 至 `MTP-115` 的术语 / 边界合同；它不实现真实撮合引擎、不实现真实订单执行 runtime、不实现 portfolio projection runtime、不实现 UI，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、Live PRO Console、live command、trading button，不运行 Graphify，不修改 Figma。

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

## MTP-112 scenario replay deterministic matching model

`MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`

MTP-112 把 MTP-106 scenario replay evidence 和 MTP-111 shared order input 串成 deterministic matching input。输入必须同时包含：

| 输入字段 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `shared order input` | 复用 MTP-111 `BacktestPaperSharedOrderInput.deterministicFixture` | 不等于 real order command、broker request 或 order form |
| `replay window` | 复用 MTP-106 fixed window `1704067200...1704067380` | 不等于 production replay job、downloader window 或 live market stream |
| `cursor` | 本地 replay cursor，MTP-112 deterministic fixture 固定 `nextRecordSequence = 2` | 不等于 exchange sequence、broker sequence、scheduler offset 或 runtime resume token |
| `market state record` | MTP-105 deterministic fixture record sequence `2`，close price `42120.70` | 不等于真实 order book、broker feed 或 live market state |
| `checksum / freshness evidence` | MTP-106 checksum `fnv1a64:3c6cd4ff13cd4062` 和 freshness `fresh` | 不等于 production data quality platform 或 network validation |

Core deterministic fixtures：

- `ScenarioReplayDeterministicMatchingContract.deterministicFixture`
- `ScenarioReplayDeterministicMatchingInput.deterministicFixture`

Focused Core tests：

- `testMTP112ScenarioReplayDeterministicMatchingModelDefinesInputOutputAndAnchors`
- `testMTP112ScenarioReplayMatchingProducesStableOutputForSameScenarioInput`
- `testMTP112ScenarioReplayMatchingRejectsNetworkLiveAndIdentityBypass`

`MTP-112-DETERMINISTIC-MATCHING-ORDERING`

MTP-112 固定 deterministic matching ordering rules：

- scenario identity first。
- dataset version / fixture version must match。
- replay window locks market state。
- cursor sequence selects fixture record。
- fixture record order ascending。
- shared order input tie-break。
- no wall clock or randomness。
- append-only simulated event output。

这些规则只服务本地 deterministic fixture matching，不代表真实 matching engine、交易所 order book priority、broker routing 或 production execution scheduler。

`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`

MTP-112 输出 `ScenarioReplaySimulatedExchangeEvent`，当前只允许 `simulated exchange order matched` event kind。deterministic fixture 输出：

- shared order state：`filled simulated`。
- shared order event kind：`simulated order filled`。
- matched record sequence：`2`。
- matched price：`42120.70`。
- matched quantity：`0.5`。
- event stream：`.paper`。

该 event 只表达 simulated exchange matching output，不等于 broker fill、execution report、真实成交、account update、portfolio projection 或 reconciliation 输入。

`MTP-112-REPEATABLE-MATCHING-OUTPUT`

MTP-112 必须证明相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 可重复输出相同 `ScenarioReplayDeterministicMatchingOutput`。deterministic result identity 固定为：

```text
mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|price=42120700000|quantity=500000
```

`MTP-112-NO-NETWORK-BROKER-LIVE`

MTP-112 必须保持 signed endpoint、account endpoint、listenKey、secret、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、wall clock、randomness 和 required network validation flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

## MTP-112 validation anchors

`MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION`

Required validation：

- `swift test --filter MTP112`
- `bash checks/run.sh`

Validation anchors：

- `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`
- `MTP-112-DETERMINISTIC-MATCHING-ORDERING`
- `MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`
- `MTP-112-REPEATABLE-MATCHING-OUTPUT`
- `MTP-112-NO-NETWORK-BROKER-LIVE`
- `MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-112 不实现 market / limit order simulated execution semantics、partial fill、latency、fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface 或 stage audit input；这些仍归属后续 `MTP-113` 至 `MTP-117`。

## MTP-113 market / limit order simulated execution semantics

`MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`

MTP-113 定义 market order 的最小 simulated execution 语义：

| 语义 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `market order simulated execution` | accepted simulated shared order input 使用 MTP-112 deterministic matching output 的 matched price 立即 full fill | 不等于真实 market order、exchange order book execution、broker route 或 live order |
| `matched price source` | `ScenarioReplayDeterministicMatchingModel.match` 输出的 matched price `42120.70` | 不等于 live market price、broker quote、exchange last trade 或 wall clock price |
| `matched quantity source` | MTP-111 shared order input 的 quantity `0.5` | 不等于 partial fill、available liquidity、account position 或 margin rule |

Core deterministic fixture：

- `MarketLimitSimulatedExecutionInput.deterministicMarketFixture`
- `MarketLimitSimulatedExecutionModel.execute`

`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`

MTP-113 定义 buy-side limit order 的最小 simulated execution 语义。当前 shared order side 只允许 `buy` / `hold`，因此 limit execution 只固定 buy-side rule：

| 语义 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `limit order simulated execution` | 必须提供 explicit limit price，并与 deterministic matched price 比较 | 不等于真实交易所 price-time priority、post-only、maker/taker routing 或 stop / OCO |
| `buy limit fill` | buy limit price 大于等于 matched price 时 full fill | 不等于真实盘口可成交量、broker fill 或 execution quality |
| `buy limit expire` | buy limit price 小于 matched price 时输出 expired simulated evidence | 不等于真实交易所 order expiry、cancel command 或 broker rejection |

Core deterministic fixtures：

- `MarketLimitSimulatedExecutionInput.deterministicLimitFillFixture`，limit price `42150.00` -> full fill。
- `MarketLimitSimulatedExecutionInput.deterministicLimitExpireFixture`，limit price `42100.00` -> expired simulated。

`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`

MTP-113 固定最小 execution outcomes：

| Outcome | Shared state | Shared event kind | 当前含义 |
| --- | --- | --- | --- |
| `full fill simulated` | `filled simulated` | `simulated order filled` | market / favorable buy limit 使用 deterministic matched price 和完整 shared quantity 输出 full fill |
| `rejected simulated` | `rejected simulated` | `simulated order rejected` | rejected initial state 或 non-executable hold side 在 fill 前停止 |
| `expired simulated` | `expired simulated` | `simulated order expired` | buy limit price 未穿越 deterministic matched price 时输出 expired evidence |

MTP-113 明确不输出 partial fill。partial fill、latency、fee / slippage parity 仍归属 `MTP-114`。

`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`

相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input / order type / limit price / initial state 必须输出相同 deterministic result identity。limit expire fixture 的 identity 固定为：

```text
mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=limit order simulated execution|limit=42100000000|initialState=accepted simulated|outcome=expired simulated|matchedPrice=42120700000|filled=0|remaining=500000
```

`MTP-113-NO-REAL-ORDER-LIVE-COMMAND`

MTP-113 必须保持 order execution runtime、matching runtime、portfolio projection runtime、advanced order types、wall clock、randomness、signed endpoint、account endpoint、listenKey、secret、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI、trading button 和 required network validation flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

## MTP-113 validation anchors

`MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION`

Required validation：

- `swift test --filter MTP113`
- `bash checks/run.sh`

Validation anchors：

- `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`
- `MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`
- `MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`
- `MTP-113-DETERMINISTIC-EXECUTION-REPLAY`
- `MTP-113-NO-REAL-ORDER-LIVE-COMMAND`
- `MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-113 不实现 stop / OCO / advanced order types、partial fill、latency、fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、order form、command model、真实订单提交 / 撤销 / 替换、OMS、execution report、broker fill、reconciliation、signed endpoint、account endpoint / listenKey、Live PRO Console、live command、order-level command UI、trading button 或 stage audit input；这些仍归属后续 `MTP-114` 至 `MTP-117` 或 Future Gated scope。

## MTP-114 partial fill / latency / fee / slippage parity

`MTP-114-PARTIAL-FULL-FILL-PARITY`

MTP-114 在 MTP-113 market / limit simulated execution 输入之上定义 partial / full fill parity evidence。输入使用 deterministic simulated liquidity cap，不读取真实盘口深度、不消耗真实流动性、不访问账户 / margin / broker state。

| 语义 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `partial fill parity` | 当 deterministic available simulated liquidity 小于 order quantity 时，输出 `partial` fill、`partially filled simulated` state、`simulated order partially filled` event kind，并保留 remaining quantity | 不等于 broker partial fill、真实成交质量、真实 order book depth 或 liquidity consumption |
| `full fill parity` | 当 deterministic available simulated liquidity 等于 order quantity 时，输出 `full` fill、`filled simulated` state、`simulated order filled` event kind，remaining quantity 为 `0` | 不等于 exchange fill、broker fill、execution report 或 real account update |
| `simulated liquidity cap` | fixture 字段 `availableSimulatedLiquidity`，partial fixture 固定 `0.25`，full fixture 固定 `0.5` | 不等于真实可成交量、账户持仓、margin、leverage 或 broker quote |

Core deterministic fixtures：

- `PartialFillLatencyFeeSlippageParityInput.deterministicPartialFixture`，available liquidity `0.25` -> partial fill。
- `PartialFillLatencyFeeSlippageParityInput.deterministicFullFixture`，available liquidity `0.5` -> full fill。
- `PartialFillLatencyFeeSlippageParityModel.evaluate`。

`MTP-114-DETERMINISTIC-LATENCY-MODEL`

MTP-114 的 latency model 只使用 replay record sequence 和固定 tick offset。默认 latency assumption 固定：

| 字段 | 值 | 含义 |
| --- | --- | --- |
| `sourceRecordSequence` | `2` | 与 MTP-112 matched record sequence 对齐 |
| `fixedDelayTicks` | `1` | deterministic replay tick offset |
| `outputRecordSequence` | `3` | `sourceRecordSequence + fixedDelayTicks` |
| `fixedDelayMilliseconds` | `250` | 本地 fixture latency evidence，不代表真实网络或 broker SLA |

该模型不得使用 wall clock、randomness、production telemetry、exchange latency、broker latency 或外部网络。

`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`

MTP-114 复用 MTP-27 fixed execution cost assumptions：

- assumption id：`mtp-27-fixed-cost-assumptions`
- maker fee：`2 bps`
- taker fee：`5 bps`
- slippage：`1.5 bps`
- rounding scale：`8`

Backtest 与 Paper 两侧分别用同一 matched price、filled quantity、liquidity role 和 fixed assumptions 生成 `ExecutionCostEstimate`，再用 `ExecutionCostParity.verify` 证明 assumption、输入和 fee / slippage breakdown 完全一致。该证据不表示真实费率表、VIP tier、symbol-specific fee、broker fee statement、动态滑点、真实成交质量或执行成本优化。

`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`

相同 MTP-113 execution input、available simulated liquidity、latency assumption、liquidity role 和 MTP-27 cost assumption 必须输出相同 deterministic report identity。partial fixture 的 identity 固定为：

```text
mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=market order simulated execution|limit=none|initialState=accepted simulated|availableLiquidity=250000|latencyAssumption=mtp-114-deterministic-latency-assumption|latencySource=2|latencyOutput=3|liquidityRole=taker|costAssumption=mtp-27-fixed-cost-assumptions|fill=partial|latencyMs=25000000000|latencyRecord=3|filled=250000|remaining=250000|fee=526508750|slippage=157952625|totalCost=684461375
```

`MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`

MTP-114 必须保持 real fee schedule、dynamic slippage model、real liquidity consumption、execution cost optimization、signed endpoint、account endpoint、listenKey、broker integration、broker fill、execution report、reconciliation、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、portfolio projection runtime、live command、order-level command UI、trading button、wall clock、randomness 和 required network validation flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

## MTP-114 validation anchors

`MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION`

Required validation：

- `swift test --filter MTP114`
- `bash checks/run.sh`

Validation anchors：

- `MTP-114-PARTIAL-FULL-FILL-PARITY`
- `MTP-114-DETERMINISTIC-LATENCY-MODEL`
- `MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`
- `MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`
- `MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`
- `MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-114 不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、portfolio projection runtime、Report / Dashboard / Events evidence surface、order form、command model、真实订单提交 / 撤销 / 替换、OMS、execution report、broker fill、reconciliation、signed endpoint、account endpoint / listenKey、Live PRO Console、live command、order-level command UI、trading button 或 stage audit input；这些仍归属后续 `MTP-115` 至 `MTP-117` 或 Future Gated scope。

## MTP-115 simulated exchange event to portfolio projection parity

`MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`

MTP-115 在 MTP-114 partial fill / latency / fee / slippage report evidence 之上定义纯 Core portfolio projection parity。输入必须来自同一个 deterministic simulated exchange parity event、同一个 MTP-107 report input version 和同一个 replay evidence sequence；不得读取真实账户余额、broker position、margin、leverage、Runtime object 或 persistence schema。

| 语义 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `simulated event to portfolio projection` | 由 MTP-114 report evidence 的 filled quantity、matched price、fee、slippage 和 latency output sequence 派生 position / cash / PnL / exposure | 不等于 portfolio runtime、real account sync、broker reconciliation 或 account endpoint read |
| `backtest portfolio projection` | backtest 观察口径的单侧模拟组合快照，使用同一 source event 和 report input identity | 不等于独立回测账户、真实资产、margin 或 leverage |
| `paper portfolio projection` | paper 观察口径的单侧模拟组合快照，必须与 backtest 快照在 quantity、cash、PnL、exposure 上完全一致 | 不等于 broker position、paper broker state、listenKey stream 或 live account |

Core deterministic fixtures：

- `SimulatedExchangePortfolioProjectionParityContract.deterministicFixture`。
- `SimulatedExchangePortfolioProjectionParityInput()` 默认消费 `PartialFillLatencyFeeSlippageParityInput.deterministicPartialFixture` 的 report evidence。
- `SimulatedExchangePortfolioProjectionParityModel.project`。
- `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`。

`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`

Backtest 与 Paper projection 必须由同一个 source event 生成相同的 `parityComparableIdentity`。默认 partial fixture 固定：

| 字段 | 值 |
| --- | --- |
| source replay sequence | `3` |
| filled quantity | `0.25` |
| average / last fill price | `42120.70` |
| position market value / cost basis / gross exposure | `10530.175` |
| total fee | `5.2650875` |
| total slippage | `1.57952625` |
| total cost impact | `6.84461375` |
| starting cash | `50000` |
| cash / available simulated cash | `39462.98038625` |
| equity | `49993.15538625` |
| realized simulated PnL | `0` |
| unrealized / net simulated PnL | `-6.84461375` |

`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`

MTP-115 只输出 value-object summary：net quantity、average entry price、last fill price、position market value、cost basis、cash、available simulated cash、equity、gross exposure、realized / unrealized / net simulated PnL 和 `PortfolioExposureSnapshot`。这些值只用于 parity evidence，不落地为账户 runtime、不写 broker state、不打开 order-level command UI。

`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`

Projection evidence 必须绑定 MTP-107 report input version identity：

```text
mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted
```

Projection input identity 必须包含 MTP-114 deterministic report identity、`reportInput=mtp-104-btcusdt-1m-first-scenario...`、`startingCash=5000000000000` 和 `sourceReplaySequence=3`，保证 replay evidence 可追溯。

`MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`

MTP-115 必须保持 real account balance read / sync、broker position read、margin read、leverage read、broker reconciliation、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、trading button、database schema exposure、runtime object read 和 required network validation flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

## MTP-115 validation anchors

`MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION`

Required validation：

- `swift test --filter MTP115`
- `bash checks/run.sh`

Validation anchors：

- `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`
- `MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`
- `MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`
- `MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`
- `MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`
- `MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION`
- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`

MTP-115 不实现 portfolio projection runtime、Report / Dashboard / Events evidence surface、stage audit input、order form、command model、真实订单提交 / 撤销 / 替换、OMS、execution report、broker fill、reconciliation、signed endpoint、account endpoint / listenKey、Live PRO Console、live command、order-level command UI 或 trading button；这些仍归属后续 `MTP-116` 至 `MTP-117` 或 Future Gated scope。
