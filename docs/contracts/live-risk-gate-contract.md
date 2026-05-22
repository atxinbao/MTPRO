# Live Risk Gate Contract

日期：2026-05-22

执行者：Codex

本文档定义 `MTPRO Live Risk Gate Contract v1` 的 Future Live Risk terminology、future risk decision taxonomy、paper / live risk 隔离和 validation anchor 候选入口。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不实现 API key、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、真实账户余额读取、broker position sync、margin / leverage、真实 pre-trade allow / reject runtime、live risk engine、live command、order form 或交易按钮。

## MTP-82 Live risk terminology

`MTP-82-LIVE-RISK-TERMINOLOGY`

Live risk gate 在当前 Project 中不是可执行实盘风控能力，而是一组 Future / gated terminology。MTP-82 只允许定义这些词汇、taxonomy 和 validation anchors，不允许把它们变成 account reader、broker state reader、pre-trade runtime、adapter、Runtime workflow 或 UI 操作入口。

| Term | 中文定义 | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `live pre-trade risk` | Future Live 中在真实订单提交前评估风险的边界名称。 | Future / gated terminology | 合同术语、validation anchor、deterministic forbidden test | 当前 risk engine、真实 allow / reject runtime |
| `future risk decision` | Future Live 可能输出的风险决策分类。 | Future / gated taxonomy | taxonomy label、future gate | 当前交易授权、broker reject、account state |
| `risk gate` | Future Live 风控进入实现前必须满足的门禁。 | Future / gated | gate 名称、证据要求 | 自动解锁 Linear issue、自动推进 Todo |
| `risk blocked evidence` | 后续 read-model-only 方式说明 live risk gates 为什么仍被阻断的证据。 | Future / blocked evidence | source anchor、blocked reason 候选 | command surface、真实风控执行 |
| `exposure gate` | Future Live 对真实账户 / 仓位 exposure 的风险门禁。 | Future / gated | 后续 MTP-83 contract anchor | 读取真实账户余额、broker position |
| `order notional gate` | Future Live 对真实订单 notional 的风险门禁。 | Future / gated | 后续 MTP-83 contract anchor | 真实订单金额 allow / reject runtime |
| `frequency gate` | Future Live 对下单频率的风险门禁。 | Future / gated | 后续 MTP-84 contract anchor | 生产级限频 runtime |
| `loss gate` | Future Live 对亏损 / drawdown 的风险门禁。 | Future / gated | 后续 MTP-84 contract anchor | 读取真实盈亏、账户权益或保证金 |
| `circuit breaker` | Future Live 熔断门禁，阻断后续交易动作。 | Future / gated | 后续 MTP-85 contract anchor | 当前熔断服务、自动停机命令 |
| `no-trade state` | Future Live 禁交易状态 taxonomy。 | Future / gated | 后续 MTP-85 contract anchor | 当前全局交易锁、UI 交易控制 |
| `paper risk blocker` | 当前 paper-only risk blocker evidence。 | Current / isolated paper evidence | paper / live risk isolation evidence | future live risk decision 输入 |
| `paper exposure` | 当前 paper-only portfolio exposure read model。 | Current / isolated paper evidence | paper / live risk isolation evidence | real account exposure 或 broker position |

## MTP-82 future risk decision taxonomy

`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`

MTP-82 的 future risk decision taxonomy 只固定分类，不提供可执行 risk decision surface：

| Taxonomy term | 含义 | 当前禁止 |
| --- | --- | --- |
| `allowed` | Future Live 风控可能允许某个真实订单继续进入 execution gate。 | 不授权当前真实订单，不绕过 execution-control gate。 |
| `blocked` | Future Live 风控可能阻断某个真实订单或风险状态。 | 不实现 broker reject、不提交真实拒单事件。 |
| `degraded` | Future Live 风控可能识别降级状态并限制操作。 | 不实现生产 telemetry、自动恢复或继续下单策略。 |
| `no-trade` | Future Live 风控可能进入禁交易状态。 | 不实现全局交易锁、停机控制或交易按钮状态。 |

这些 taxonomy term 只能进入 contract docs、Core deterministic fixture、validation plan、matrix 和 PR evidence。任何后续 issue 若要把 taxonomy 扩展为 read model、Dashboard / Report / Event Timeline evidence 或 runtime gate，必须等对应 Linear issue 成为唯一 configured executable issue。

## MTP-82 paper / live risk separation

`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`

MTP-82 必须保持 paper risk blocker、paper execution decision、simulated fill 和 paper exposure 与 future live risk decision 隔离：

- `RiskBlockerEvidence` 仍只是本地 paper readiness blocker evidence，不等于 live risk decision。
- `PortfolioExposureSnapshot` 仍只是 paper projection 派生的 exposure read model，不等于真实账户余额、broker position、margin 或 leverage。
- `PaperActionProposalRiskDecision` 仍只绑定 paper proposal、risk query 和 blocker evidence，不授权 real pre-trade allow / reject。
- `PaperSimulatedFillEvidence` 和 `PaperPortfolioProjectionUpdate` 不能升级为 real account state、broker position 或 future live risk input。
- `LiveRiskTerminologyBoundary` 的 paper upgrade flags 必须全部为 `false`。

Source anchors：

- `TVM-RISK-BLOCKER`
- `TVM-PORTFOLIO-EXPOSURE`
- `TVM-PAPER-EXECUTION-DECISION`
- `TVM-PAPER-SIMULATED-FILL`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`
- `MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`

## MTP-82 no live risk runtime

`MTP-82-NO-LIVE-RISK-RUNTIME`

MTP-82 的 non-implementation evidence 必须来自三层本地证据：

- Core deterministic fixture：`LiveRiskTerminologyBoundary` 只定义 terminology、future risk decision taxonomy、future gates、forbidden capabilities 和 validation anchors。
- Core deterministic tests：`testLiveRiskTerminologyDefinesMTP82FutureOnlyTaxonomy`、`testLiveRiskTerminologyRejectsMTP82RuntimeAccountAndCommandBypass` 和 `testPaperRiskBlockerAndExposureCannotUpgradeToMTP82FutureLiveRiskDecision`。
- Required validation：`bash checks/run.sh`；不得依赖真实 Binance 网络、API key、account endpoint、listenKey、broker state、真实账户或人工验收。

禁止能力 baseline：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- real account balance read。
- broker position sync。
- margin / leverage read。
- real pre-trade risk engine。
- real pre-trade allow / reject runtime。
- circuit breaker runtime。
- no-trade state runtime。
- paper risk blocker / paper exposure 升级。
- live command surface。
- risk command surface。
- position management command。
- order form。
- trading button。

## MTP-82 validation anchors

`MTP-82-LIVE-RISK-GATE-VALIDATION`

MTP-82 建立以下 validation anchors，供后续 issue 接入 forbidden capability tests：

- `TVM-LIVE-RISK-GATE`
- `MTP-82-LIVE-RISK-TERMINOLOGY`
- `MTP-82-FUTURE-RISK-DECISION-TAXONOMY`
- `MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`
- `MTP-82-NO-LIVE-RISK-RUNTIME`
- `MTP-82-LIVE-RISK-GATE-VALIDATION`

后续 issue 只能在该 Future / forbidden boundary 内继续细化：

- `MTP-83`：exposure / order notional gates 和 forbidden capability tests。
- `MTP-84`：frequency / loss / drawdown gates 和 forbidden capability tests。
- `MTP-85`：circuit breaker / no-trade state gates 和 forbidden capability tests。
- `MTP-86`：paper risk blocker / paper exposure 与 future live risk decision 隔离合同。
- `MTP-87`：read-model-only `LiveRiskGateBlockedEvidence`。
- `MTP-88`：validation matrix、automation readiness 和 stage audit input material 收口。

## MTP-83 exposure / order notional gates

`MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`

MTP-83 只定义 exposure gate 和 order notional gate 的 Future Live Risk contract，不实现真实账户读取、真实订单金额 allow / reject、真实 pre-trade runtime 或 live risk engine。

| Gate | Future 条件 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- |
| `exposure gate` | Future Live Risk 需要独立 Human decision、live trading foundation boundary、live execution control boundary、account state source contract、broker position source contract、margin / leverage source contract、exposure limit policy、paper exposure isolation 和 operations / audit handoff。 | contract anchor、Core deterministic fixture、forbidden capability test、PR boundary evidence | real account balance read、broker position sync、margin / leverage read、real account exposure calculation |
| `order notional gate` | Future Live Risk 需要 order notional limit policy、future account / position / margin / leverage source contracts、execution-control handoff 和 audit handoff；当前只记录 gate 条件。 | contract anchor、Core deterministic fixture、forbidden capability test、PR boundary evidence | real order notional allow / reject runtime、real pre-trade allow / reject、真实订单提交 / 撤销 / 替换 |

## MTP-83 forbidden account / position / margin / leverage tests

`MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`

MTP-83 的 forbidden capability tests 必须阻断：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- real account balance read。
- broker position sync。
- margin read。
- leverage read。
- real account exposure calculation。
- real order notional limit evaluation。
- real pre-trade risk engine。
- real pre-trade allow / reject runtime。
- live order submit / cancel / replace。
- risk command surface、position management command、order form 和 trading button。

Core deterministic fixture：`LiveExposureOrderNotionalGateBoundary`。

Core deterministic tests：

- `testLiveExposureOrderNotionalBoundaryDefinesMTP83FutureGatesAndForbiddenCapabilities`
- `testLiveExposureOrderNotionalBoundaryRejectsMTP83AccountPositionMarginLeverageBypass`
- `testPaperExposureCannotUpgradeToMTP83FutureLiveExposureGateDecision`

Required validation：`bash checks/run.sh`；不得依赖真实 Binance 网络、API key、account endpoint、listenKey、broker state、真实账户或人工验收。

## MTP-83 no real pre-trade allow / reject

`MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`

MTP-83 的 exposure / order notional gate 只能作为 Future / gated contract 存在：

- `LiveExposureOrderNotionalGateBoundary.providesLiveRiskEngine == false`
- `LiveExposureOrderNotionalGateBoundary.evaluatesRealOrderNotionalLimit == false`
- `LiveExposureOrderNotionalGateBoundary.evaluatesRealPreTradeAllow == false`
- `LiveExposureOrderNotionalGateBoundary.evaluatesRealPreTradeReject == false`
- `LiveExposureOrderNotionalGateBoundary.authorizesLiveTrading == false`

## MTP-83 paper exposure isolation

`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`

当前 `PortfolioExposureSnapshot` 仍只能表示 paper projection 派生的只读 exposure evidence，不等于 live exposure gate 输入、真实账户 exposure、broker position、margin 或 leverage。MTP-83 必须保持：

- `mapsPaperExposureToLiveExposureGate == false`
- `mapsPaperRiskBlockerToFutureRiskDecision == false`
- `computesLiveExposureFromAccountState == false`
- `readsRealAccountBalance == false`
- `syncsBrokerPosition == false`

Source anchors：

- `MTP-82-LIVE-RISK-TERMINOLOGY`
- `MTP-82-FUTURE-RISK-DECISION-TAXONOMY`
- `MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`
- `TVM-PORTFOLIO-EXPOSURE`
- `TVM-RISK-BLOCKER`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`

## MTP-83 validation anchors

`MTP-83-LIVE-RISK-GATE-VALIDATION`

MTP-83 建立以下 validation anchors：

- `TVM-LIVE-RISK-GATE`
- `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`
- `MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`
- `MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`
- `MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`
- `MTP-83-LIVE-RISK-GATE-VALIDATION`

## MTP-84 frequency / loss / drawdown gates

`MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`

MTP-84 只定义 frequency gate、loss gate 和 drawdown gate 的 Future Live Risk contract，不实现真实下单频率限制、真实亏损阈值执行、真实回撤控制 runtime、回撤熔断、停机命令或 live risk engine。

| Gate | Future 条件 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- |
| `frequency gate` | Future Live Risk 需要独立 Human decision、live trading foundation boundary、live execution control boundary、frequency window policy、order event source contract、paper risk / exposure isolation 和 operations / audit handoff。 | contract anchor、Core deterministic fixture、forbidden capability test、PR boundary evidence | live order frequency counter、production frequency throttling、broker-side throttling、real pre-trade allow / reject runtime |
| `loss gate` | Future Live Risk 需要 PnL / equity source contract、loss limit policy、future account / position / margin / leverage source contracts、paper evidence isolation 和 audit handoff；当前只记录 gate 条件。 | contract anchor、Core deterministic fixture、forbidden capability test、PR boundary evidence | real PnL read、real account equity read、real loss limit evaluation、real pre-trade allow / reject runtime |
| `drawdown gate` | Future Live Risk 需要 drawdown limit policy、PnL / equity source contract、operations / audit handoff 和后续 circuit breaker / no-trade state gate coordination；当前只记录 gate 条件。 | contract anchor、Core deterministic fixture、forbidden capability test、PR boundary evidence | real drawdown limit evaluation、drawdown circuit breaker runtime、circuit breaker command、stop trading command、emergency stop command |

## MTP-84 forbidden frequency / loss / drawdown runtime tests

`MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`

MTP-84 的 forbidden capability tests 必须阻断：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- real account balance read。
- broker position sync。
- margin read。
- leverage read。
- real PnL read。
- real account equity read。
- live order frequency counter。
- production frequency throttling / broker-side throttling。
- real loss limit evaluation。
- real drawdown limit evaluation。
- drawdown circuit breaker runtime。
- real pre-trade risk engine。
- real pre-trade allow / reject runtime。
- circuit breaker command / stop trading command / emergency stop command。
- live order submit / cancel / replace。
- risk command surface、position management command、order form 和 trading button。

Core deterministic fixture：`LiveFrequencyLossDrawdownGateBoundary`。

Core deterministic tests：

- `testLiveFrequencyLossDrawdownBoundaryDefinesMTP84FutureGatesAndForbiddenCapabilities`
- `testLiveFrequencyLossDrawdownBoundaryRejectsMTP84RuntimeBypass`
- `testPaperRiskAndExposureCannotUpgradeToMTP84FrequencyLossDrawdownGateDecision`

Required validation：`bash checks/run.sh`；不得依赖真实 Binance 网络、API key、account endpoint、listenKey、broker state、真实账户、真实 PnL、真实 equity、真实下单频率计数或人工验收。

## MTP-84 no real PnL / equity / drawdown enforcement

`MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`

MTP-84 的 frequency / loss / drawdown gate 只能作为 Future / gated contract 存在：

- `LiveFrequencyLossDrawdownGateBoundary.providesLiveRiskEngine == false`
- `LiveFrequencyLossDrawdownGateBoundary.countsLiveOrderFrequency == false`
- `LiveFrequencyLossDrawdownGateBoundary.enforcesFrequencyThrottle == false`
- `LiveFrequencyLossDrawdownGateBoundary.readsRealPnL == false`
- `LiveFrequencyLossDrawdownGateBoundary.readsRealAccountEquity == false`
- `LiveFrequencyLossDrawdownGateBoundary.evaluatesRealLossLimit == false`
- `LiveFrequencyLossDrawdownGateBoundary.evaluatesRealDrawdownLimit == false`
- `LiveFrequencyLossDrawdownGateBoundary.runsDrawdownCircuitBreaker == false`
- `LiveFrequencyLossDrawdownGateBoundary.runsCircuitBreakerCommand == false`
- `LiveFrequencyLossDrawdownGateBoundary.runsStopTradingCommand == false`
- `LiveFrequencyLossDrawdownGateBoundary.runsEmergencyStopCommand == false`

## MTP-84 paper risk / exposure isolation

`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`

当前 `RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 仍只能表示 paper-only read model / evidence，不等于 live frequency gate 输入、真实 loss / drawdown gate 输入、真实 PnL / equity、真实账户状态或 pre-trade risk runtime。MTP-84 必须保持：

- `mapsPaperRiskBlockerToFrequencyLossDrawdownGate == false`
- `mapsPaperExposureToLossDrawdownGate == false`
- `readsRealPnL == false`
- `readsRealAccountEquity == false`
- `countsLiveOrderFrequency == false`
- `evaluatesRealLossLimit == false`
- `evaluatesRealDrawdownLimit == false`

Source anchors：

- `MTP-82-LIVE-RISK-TERMINOLOGY`
- `MTP-82-FUTURE-RISK-DECISION-TAXONOMY`
- `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`
- `TVM-RISK-BLOCKER`
- `TVM-PORTFOLIO-EXPOSURE`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`

## MTP-84 validation anchors

`MTP-84-LIVE-RISK-GATE-VALIDATION`

MTP-84 建立以下 validation anchors：

- `TVM-LIVE-RISK-GATE`
- `MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`
- `MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`
- `MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`
- `MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`
- `MTP-84-LIVE-RISK-GATE-VALIDATION`
