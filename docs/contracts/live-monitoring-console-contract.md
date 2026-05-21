# Live Monitoring Console Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Monitoring Console v1` 的 information architecture、术语、状态分类和 read-model-only 边界。它只为后续 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 提供统一合同，不实现 live runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、真实订单状态机或任何 live command。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不执行真实交易动作。

## MTP-68 Live monitoring console information architecture

`MTP-68-LIVE-MONITORING-CONSOLE-IA`

Live monitoring console 在本 Project 中首先是 read-model-only information architecture。它描述后续界面和报告应如何组织监控 evidence，而不是当前可运行的实盘监控 runtime。

| Console area | 中文目的 | 允许输入 | 允许输出 | 当前禁止 |
| --- | --- | --- | --- | --- |
| Overview / 总览 | 汇总 live monitoring readiness、blocked gates 和最近 operations evidence | App 层 Read Model / ViewModel | 状态摘要、source anchor、只读边界说明 | live command、交易按钮、adapter call |
| Runtime Health / 运行健康 | 展示 future live runtime 是否 nominal / degraded / error / stale | 后续 MTP-69 read model | health status、updatedAt、evidence id | 启动 runtime、读取 runtime actor |
| Connection / 连接 | 展示 public / future private connection 的只读状态 | 后续 connection status read model | disconnected / connected / stale / error evidence | account endpoint、listenKey、private WebSocket |
| Market Stream / 行情流 | 展示 public market stream 的只读健康和延迟 evidence | public read-only market stream evidence | stream status、last event、latency bucket | signed endpoint、生产订阅控制 |
| Order Stream Evidence / 订单流证据 | 展示 blocked / simulated / future order-stream evidence | `LiveReadiness`、paper evidence、future order stream gate | blocked / simulated / future-only evidence | real order state machine、execution report、broker fill |
| Latency / 延迟 | 展示 read model 中已计算的延迟 bucket 和 freshness | 后续 latency evidence read model | nominal / stale / degraded / error bucket | runtime profiler、生产 telemetry agent |
| Error / Degraded State / 错误和降级 | 展示已记录 error / degraded evidence 的只读摘要 | 后续 error evidence read model | error code、scope、source anchor、recoveredAt | incident command、自动恢复动作 |
| Operations Evidence / 运营证据 | 展示 validation、handoff、audit input 和 readiness 证据 | validation docs、Stage Audit input、event timeline links | evidence chain、known boundaries、handoff status | production operations、deployment action |

## MTP-68 live monitoring terminology

`MTP-68-LIVE-MONITORING-TERMS`

以下术语只定义后续 read model 的语言，不代表当前已有实盘连接或可执行能力：

| Term | 中文定义 | 当前状态 | 避免混用 |
| --- | --- | --- | --- |
| `live runtime health` | 后续实盘 runtime 的健康状态读模型，例如 nominal、degraded、error、stale。 | Future / read-model-only | 不等于当前已启动 live runtime 或 actor。 |
| `connection status` | 后续连接状态的只读证据，可覆盖 public market connection 和 future private connection gate。 | Future / read-model-only | 不等于 account endpoint、listenKey 或 broker session。 |
| `market stream status` | Binance public read-only market stream 的可观察状态、freshness 和 latency evidence。 | Future / public-read-only evidence | 不等于 signed endpoint 或交易执行通道。 |
| `order stream evidence` | 订单流相关的 blocked / simulated / future evidence，用于说明真实订单流为什么尚未可用或未来需要哪些 gate。 | Blocked / simulated / future-only | 不等于 real order state machine、execution report、broker fill 或 OMS。 |
| `latency evidence` | 从 read model 派生的延迟 bucket、last update 和 freshness evidence。 | Future / read-model-only | 不等于生产 telemetry agent 或 runtime profiler。 |
| `error evidence` | 后续 Event Timeline / Report 可展示的错误事实摘要。 | Future / read-model-only | 不等于自动恢复命令或 incident handler。 |
| `degraded state` | 系统仍可观察但健康、连接、stream 或 latency evidence 显示降级的状态。 | Future / read-model-only | 不等于允许交易、risk bypass 或执行降级策略。 |
| `operations evidence` | validation、handoff、audit input、known boundary 和 readiness 证据链。 | Current docs evidence / future read model input | 不等于 production operations command、部署或远程运维。 |

## MTP-68 status taxonomy

`MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`

MTP-68 只命名状态分类，后续 issue 才能把这些分类落成具体 Read Model / ViewModel 字段。

| Status | 中文含义 | 允许展示 | 禁止解释 |
| --- | --- | --- | --- |
| `blocked` | 必要 gate 未满足，能力当前被阻断。 | blocked gate、source anchor、reason | partial live readiness、可执行 fallback |
| `simulated` | 仅来自 paper-only / deterministic fixture 的模拟证据。 | simulated source、paper evidence id | broker fill、真实订单状态 |
| `futureOnly` | 术语已定义，但当前 Project 不实现。 | future gate、required evidence | 当前可调用能力 |
| `unknown` | 没有足够 read model evidence 判断状态。 | unknown summary、missing evidence | silent success、默认 nominal |
| `nominal` | 后续 read model 可表示观察值在预期范围内。 | status label、updatedAt、source anchor | 交易授权、live command |
| `stale` | read model evidence 过期或 freshness 不足。 | stale duration、last update | 自动重连、真实状态修复 |
| `degraded` | health / connection / stream / latency / error evidence 显示降级。 | degraded scope、reason、source anchor | risk bypass、继续执行真实订单 |
| `error` | read model 中存在错误事实或失败证据。 | error code、message、scope | incident command、自动恢复动作 |
| `recovered` | 后续 evidence 显示从 error / degraded 恢复。 | recoveredAt、source anchor | 清除审计证据、跳过 incident review |

## MTP-68 read-model-only boundary

`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`

Dashboard、Report 和 Event Timeline 在 MTP-68 之后只能展示 read model / ViewModel：

- Dashboard 只能展示 status summary、section counts、source anchors 和 known boundaries。
- Report 只能汇总 read model evidence、validation anchor 和 audit input evidence。
- Event Timeline 只能展示 evidence item、source sequence、source anchor 和 read-only link summary。
- App / Dashboard 不得读取 adapter request、adapter instance、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence implementation。
- App / Dashboard 不得读取 API key、secret、account payload、listenKey、broker state、execution venue connection 或 real account state。
- App / Dashboard 不得提供 live command、order-level command、risk control command、position management command、submit / cancel / replace、交易按钮、表单或自动恢复动作。

## MTP-68 order stream evidence boundary

`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`

订单流 / 订单事件流在 MTP-68 中只能表达三类 evidence：

| Evidence type | 允许含义 | 禁止含义 |
| --- | --- | --- |
| `blocked order stream evidence` | 真实订单流仍被 credential、adapter、real order lifecycle 和 risk / operations gate 阻断。 | 当前存在 private order stream、listenKey 或 broker stream。 |
| `simulated order stream evidence` | paper order / simulated fill / paper portfolio 等本地模拟证据可被只读展示。 | broker fill、execution report、真实账户更新。 |
| `future order stream evidence` | 后续 Project Definition 需要定义 order stream contract、reconciliation 和 incident/audit evidence。 | 当前实现 real order state machine、OMS 或 submit / cancel / replace。 |

## MTP-69 live runtime health / connection status read model

`MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL`

MTP-69 在 Core 层新增最小 `LiveRuntimeHealthReadModel`。该 read model 只表达 future live runtime health 的状态证据、source anchors、deterministic fixture 和 connection status evidence；它不启动 runtime、不轮询生产 health、不读取 runtime actor、不建立网络连接、不读取 secret / account payload、不连接 broker，也不授权真实交易。

`LiveRuntimeHealthReadModel` 必须满足：

- `healthID = mtp-69-live-runtime-health`。
- `issueID = MTP-69`。
- `status = blocked` 作为当前 deterministic fixture 默认状态。
- `allowedStatuses = healthy / blocked / disconnected / degraded / unavailable`，这些状态只是 read-model label，不代表当前 runtime 已启动或 connection 已建立。
- `sourceAnchors` 固定包含 `MTP-68-LIVE-MONITORING-CONSOLE-IA`、`MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`、`MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL` 和 `MTP-69-CONNECTION-STATUS-READ-MODEL`。
- `connections` 必须等于 `LiveRuntimeHealthReadModel.requiredConnectionStatuses`，并通过每个 connection 的 read-model-only boundary。

`MTP-69-CONNECTION-STATUS-READ-MODEL`

MTP-69 同时新增 `LiveConnectionStatusReadModel`，只覆盖三类最小 connection evidence：

| Connection kind | Fixture status | 含义 | 禁止解释 |
| --- | --- | --- | --- |
| `public market data connection` | `disconnected` | public read-only market data connection 当前没有真实 live connection evidence。 | 不等于生产 WebSocket 已连接或订阅控制。 |
| `future private user data connection` | `blocked` | private account / listenKey 连接仍被 credential endpoint boundary 阻断。 | 不等于 account endpoint、listenKey 或 private WebSocket。 |
| `future broker session` | `unavailable` | broker session 属于 future gated 能力，当前不可用。 | 不等于 broker adapter、execution venue connection 或真实订单通道。 |

`MTP-69-NO-LIVE-CONNECTION-OR-COMMAND`

MTP-69 的 Core read model 和 tests 必须拒绝以下能力：

- command surface、reconnect command、start / stop live command。
- 启动或停止 live runtime。
- health polling production runtime。
- active network connection、WebSocket、private WebSocket。
- API key、secret、signed endpoint、account endpoint、listenKey、account payload。
- broker adapter、execution venue connection、`LiveExecutionAdapter`。
- Runtime object、adapter surface、SQLite / DuckDB schema。
- live trading authorization 或 trading execution authorization。
- required validation 依赖真实网络。

## MTP-70 market stream / order stream blocked evidence read model

`MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL`

MTP-70 在 Core 层新增 `LiveStreamMonitoringEvidenceReadModel` 和
`LiveStreamMonitoringEvidenceItem`，只表达 market stream / order stream 的 read-model-only
evidence。该 read model 以上一层 `LiveRuntimeHealthReadModel.deterministicFixture` 为输入证据，
不会启动 market streaming runtime、private user data stream、account/order stream runtime、
broker adapter 或任何真实交易通道。

`LiveStreamMonitoringEvidenceReadModel` 必须满足：

- `readModelID = mtp-70-live-stream-monitoring-evidence`。
- `issueID = MTP-70`。
- `runtimeHealth = LiveRuntimeHealthReadModel.deterministicFixture`。
- `sourceAnchors` 固定包含 `MTP-68-LIVE-MONITORING-CONSOLE-IA`、
  `MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`、
  `MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL` 和
  `MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL`。
- `streamEvidence` 必须等于 `LiveStreamMonitoringEvidenceReadModel.requiredStreamEvidence`，
  并覆盖 public market stream、blocked order stream、simulated order stream 和 future order
  stream 四个稳定分区。

`MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE`

Market stream evidence 只能表达 Binance public read-only / fixture evidence：

| Stream kind | Fixture status | Evidence kind | Source anchors | 禁止解释 |
| --- | --- | --- | --- | --- |
| `public market stream` | `disconnected` | `public read-only market stream evidence` | `MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`、`MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE`、`BinanceReadOnlyAdapterBoundary` | 不等于生产 WebSocket 已连接、订阅控制、signed endpoint 或 execution venue。 |

`MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE`

Order stream / order flow evidence 只能表达 blocked、simulated、future-only 三类：

| Stream kind | Fixture status | Evidence kind | 允许含义 | 禁止解释 |
| --- | --- | --- | --- | --- |
| `blocked order stream` | `blocked` | `blocked order stream evidence` | credential、adapter、real order lifecycle gates 仍阻断真实订单流。 | private user data stream、listenKey、account endpoint、broker stream。 |
| `simulated order stream` | `blocked` | `simulated paper order evidence` | 只读引用 paper order / simulated fill evidence。 | execution report、broker fill、真实账户更新。 |
| `future order stream` | `unavailable` | `future order stream gate evidence` | 后续 Project 需要独立定义 order stream contract、reconciliation 和 audit evidence。 | 当前实现 real order state machine、OMS、submit / cancel / replace。 |

`MTP-70-NO-LISTENKEY-ACCOUNT-ENDPOINT-REAL-ORDER-STATE`

MTP-70 的 Core read model 和 tests 必须拒绝以下能力：

- active market stream / active order stream。
- public market WebSocket、private user data stream、listenKey。
- signed endpoint、account endpoint、API key、secret、account payload。
- execution report、broker fill、real order state machine、OMS。
- order command、submit / cancel / replace。
- broker adapter、`LiveExecutionAdapter`、adapter surface、Runtime object、SQLite / DuckDB schema。
- live trading authorization、trading execution authorization。
- required validation 依赖真实网络。

`MTP-70-LIVE-STREAM-MONITORING-VALIDATION`

MTP-70 的验证入口：

- `Sources/Core/LiveMonitoringConsole.swift` 必须包含 `LiveStreamMonitoringEvidenceKind`、
  `LiveStreamMonitoringKind`、`LiveStreamMonitoringEvidenceItem` 和
  `LiveStreamMonitoringEvidenceReadModel`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖
  `testLiveStreamMonitoringEvidenceDefinesMTP70MarketAndOrderStreamFixture`、
  `testLiveStreamMonitoringEvidenceRejectsMTP70ListenKeyAccountBrokerAndRealOrderBypass` 和
  `testLiveOrderStreamEvidenceKeepsMTP70BlockedSimulatedFutureOnly`。
- Focused validation：`swift test --filter MTP70`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 仍不在 MTP-70 中收口 `TVM-LIVE-MONITORING-CONSOLE`；
  MTP-74 才允许统一机械化 MTP-68 至 MTP-73 anchors。

## MTP-71 latency / error / degraded state monitoring evidence

`MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL`

MTP-71 在 Core 层新增 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`、
`LiveMonitoringLatencyEvidenceItem`、`LiveMonitoringErrorEvidenceItem` 和
`LiveMonitoringDegradedStateEvidenceItem`。该 read model 以上一层
`LiveStreamMonitoringEvidenceReadModel.deterministicFixture` 为输入证据，只输出
Report / Dashboard 后续可消费的 latency、error 和 degraded / unavailable state evidence。

`LiveLatencyErrorDegradedMonitoringEvidenceReadModel` 必须满足：

- `readModelID = mtp-71-live-latency-error-degraded-evidence`。
- `issueID = MTP-71`。
- `streamEvidence = LiveStreamMonitoringEvidenceReadModel.deterministicFixture`。
- `sourceAnchors` 固定包含 `MTP-68-LIVE-MONITORING-CONSOLE-IA`、
  `MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL`、
  `MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL` 和
  `MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL`。
- `latencyEvidence` 必须等于
  `LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredLatencyEvidence`。
- `errorEvidence` 必须等于
  `LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredErrorEvidence`。
- `degradedStateEvidence` 必须等于
  `LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredDegradedStateEvidence`。

`MTP-71-LATENCY-EVIDENCE-READ-MODEL`

Latency evidence 只能表达本地 deterministic bucket / freshness evidence：

| Scope | Fixture bucket | Fixture value | Source anchors | 禁止解释 |
| --- | --- | --- | --- | --- |
| `runtime health` | `stale` | latency `6000ms` / freshness `30000ms` | `MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL`、`MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL` | 不等于生产 runtime profiler 或 live runtime 已启动。 |
| `public market stream` | `degraded` | latency `1250ms` / freshness `45000ms` | `MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE`、`MTP-71-LATENCY-EVIDENCE-READ-MODEL` | 不等于生产 telemetry、WebSocket 订阅或自动扩缩容信号。 |
| `simulated order stream` | `nominal` | latency `25ms` / freshness `500ms` | `TVM-PAPER-EXECUTION-WORKFLOW`、`MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE`、`MTP-71-LATENCY-EVIDENCE-READ-MODEL` | 不等于 broker order stream 或真实成交回报。 |
| `future private user data` | `unavailable` | 无可观测 latency | `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`MTP-71-LATENCY-EVIDENCE-READ-MODEL` | 不等于 listenKey、account endpoint 或 private WebSocket。 |
| `future broker session` | `unavailable` | 无可观测 latency | `MTP-63-ADAPTER-CAPABILITY-ISOLATION`、`MTP-71-LATENCY-EVIDENCE-READ-MODEL` | 不等于 broker session、execution venue 或 `LiveExecutionAdapter`。 |

`MTP-71-ERROR-EVIDENCE-READ-MODEL`

Error evidence 只能表达 deterministic error summary，不触发 incident command、自动恢复、
alerting、paging、reconnect 或 stop control：

| Error kind | Scope | Fixture status | Error code | 禁止解释 |
| --- | --- | --- | --- | --- |
| public market stream disconnected | public market stream | `disconnected` | `MTP71_PUBLIC_MARKET_STREAM_DISCONNECTED` | 不等于生产故障处理或自动重连。 |
| private user data blocked | future private user data | `blocked` | `MTP71_PRIVATE_USER_DATA_BLOCKED` | 不等于 account endpoint / listenKey 已实现。 |
| broker session unavailable | future broker session | `unavailable` | `MTP71_BROKER_SESSION_UNAVAILABLE` | 不等于 broker adapter 或 execution venue 已存在。 |

`MTP-71-DEGRADED-STATE-READ-MODEL`

Degraded / unavailable state evidence 只把 latency 和 error evidence 串成只读状态摘要：

| State scope | Fixture status | Contributing evidence | 禁止解释 |
| --- | --- | --- | --- |
| public market stream | `degraded` | public market stream latency degraded + public market stream disconnected error | 不允许 risk bypass、继续真实订单或自动恢复。 |
| future broker session | `unavailable` | broker session latency unavailable + broker session unavailable error | 不允许 broker fallback、真实订单执行或 live risk control。 |

`MTP-71-NO-PRODUCTION-TELEMETRY-OR-COMMAND`

MTP-71 的 Core read model 和 tests 必须拒绝以下能力：

- production telemetry、runtime profiler、external metrics service。
- production runtime monitor、runtime polling、active network connection。
- alerting command、paging command、incident command、auto recovery。
- reconnect command、stop control、live risk control。
- signed endpoint、account endpoint、listenKey、API key、secret、account payload。
- broker adapter、`LiveExecutionAdapter`、adapter surface、Runtime object、SQLite / DuckDB schema。
- live trading authorization、trading execution authorization。
- required validation 依赖真实网络。

`MTP-71-LIVE-MONITORING-LATENCY-ERROR-DEGRADED-VALIDATION`

MTP-71 的验证入口：

- `Sources/Core/LiveMonitoringConsole.swift` 必须包含 `LiveMonitoringEvidenceScope`、
  `LiveMonitoringLatencyBucket`、`LiveMonitoringLatencyEvidenceItem`、
  `LiveMonitoringErrorEvidenceKind`、`LiveMonitoringErrorEvidenceItem`、
  `LiveMonitoringDegradedStateEvidenceItem` 和
  `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖
  `testLiveLatencyErrorDegradedEvidenceDefinesMTP71DeterministicFixture`、
  `testLiveLatencyErrorDegradedEvidenceRejectsMTP71ProductionTelemetryAndCommands` 和
  `testLiveMonitoringDegradedStateKeepsMTP71ReadModelOnlyNoRecoveryCommands`。
- Focused validation：`swift test --filter MTP71`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 仍不在 MTP-71 中收口 `TVM-LIVE-MONITORING-CONSOLE`；
  MTP-74 才允许统一机械化 MTP-68 至 MTP-73 anchors。

## MTP-72 Dashboard / Report live monitoring evidence

`MTP-72-DASHBOARD-REPORT-LIVE-MONITORING-EVIDENCE`

MTP-72 把 MTP-69 / MTP-70 / MTP-71 已验证的 Core read model 接入 App 层 Dashboard / Report 展示面。该接入只复制 deterministic monitoring evidence，不新增 live runtime、生产 telemetry、外部 metrics、真实网络连接、adapter / Runtime / schema 读取、live command、交易按钮或真实交易授权。

`MTP-72-LIVE-MONITORING-READ-MODEL-VIEWMODEL`

App 层新增 `LiveMonitoringEvidenceReadModel` 和 `LiveMonitoringEvidenceViewModel`：

- `LiveMonitoringEvidenceReadModel` 只接受 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel.deterministicFixture` 或同形稳定 read model，默认 `source = ViewModelSourceContract()`。
- `LiveMonitoringEvidenceViewModel` 汇总 runtime health status、connection status、market stream / order stream evidence、latency bucket、error code、degraded / unavailable state、source anchors 和 forbidden capability flags。
- `ReportReadModel.liveMonitoringEvidence` 和 `ReportViewModel.liveMonitoringEvidence` 把 monitoring evidence 纳入 Report 快照。
- `DashboardShellSnapshot` 的 Report section 新增 `Monitoring` 指标，Workbench 新增 `Live Monitoring` 只读组，Dashboard smoke 新增 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3` evidence。

`MTP-72-NO-LIVE-COMMAND-OR-BUTTON`

MTP-72 必须保持以下 flags 为 false：

- `providesCommandSurface`
- `providesOrderLevelCommand`
- `providesTradingButton`
- `providesRiskCommand`
- `providesPositionCommand`
- `providesAlertingCommand`
- `providesPagingCommand`
- `providesReconnectCommand`
- `providesStopControl`
- `providesLiveRiskControl`
- `triggersIncidentCommand`
- `triggersAutoRecovery`
- `authorizesLiveTrading`
- `authorizesTradingExecution`

`MTP-72-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE`

MTP-72 Dashboard / Report surface 不得暴露：

- adapter surface、adapter request、Binance signed/account endpoint、listenKey、broker adapter 或 `LiveExecutionAdapter`。
- Runtime object、actor、workflow object、production telemetry、external metrics service 或真实网络连接。
- SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence implementation。
- API key、secret、account payload、broker state、execution report、broker fill、real order state machine、OMS 或真实账户状态。

`MTP-72-LIVE-MONITORING-DASHBOARD-REPORT-VALIDATION`

MTP-72 的验证入口：

- `Sources/App/LiveMonitoringEvidence.swift` 必须包含 `LiveMonitoringEvidenceReadModel` 和 `LiveMonitoringEvidenceViewModel`。
- `Sources/App/App.swift` 必须包含 `ReportReadModel.liveMonitoringEvidence`、`ReportViewModel.liveMonitoringEvidence` 和 Report 层 monitoring summary fields。
- `Sources/App/DashboardShell.swift` 必须包含 Report `Monitoring` 指标、Workbench `Live Monitoring` 组、`liveMonitoringHealth` / `liveMonitoringErrors` smoke evidence 和 no command / no schema / no adapter / no runtime boundary 聚合。
- `Tests/AppTests/AppTests.swift` 必须覆盖 `testLiveMonitoringEvidenceViewModelAggregatesMTP72ReadModelOnlyEvidence`、Dashboard / Report deterministic assertions、Dashboard smoke 和 no command / no button / no schema / no adapter / no runtime assertions。
- Focused validation：`swift test --filter AppTests`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 的完整 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-72 只回填 Dashboard / Report evidence anchors 和本地验证证据。

## MTP-73 Event Timeline live monitoring evidence preview

`MTP-73-EVENT-TIMELINE-LIVE-MONITORING-EVIDENCE-PREVIEW`

MTP-73 把 MTP-69 / MTP-70 / MTP-71 的 live monitoring evidence 接入 App 层 Event Timeline / Evidence Explorer 只读预览。该接入只消费 `LiveMonitoringEvidenceReadModel`，把 runtime health、connection、market / order stream、latency、error 和 degraded state evidence 转成 timeline item / evidence link，不读取 adapter、Runtime、schema、production telemetry、external metrics、真实网络连接或 broker 状态。

`MTP-73-LIVE-MONITORING-TIMELINE-ITEMS`

Event Timeline 新增 `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence` 分区：

- `PaperWorkflowEvidenceExplorerReadModel.liveMonitoringEvidence` 只从 `ReportReadModel.liveMonitoringEvidence` 或显式注入的同形 read model 取数。
- `PaperWorkflowEvidenceExplorerViewModel.coversLiveMonitoringEvidence` 在 deterministic fixture 中必须为 true。
- `makeLiveMonitoringEvidenceItems` 必须生成 18 条 read-only timeline item：1 条 runtime health、3 条 connection、4 条 stream、5 条 latency、3 条 error 和 2 条 degraded state。
- 每条 timeline item 必须保留 `stream = live monitoring`、source sequence、evidence ID 和 evidence label；不产生 query language、command surface、live audit、incident replay 或 stop control。
- 全量 Dashboard fixture 的 Event Timeline item count 必须从 24 增至 42；空启动 snapshot 仍包含静态 Live blocked / Live monitoring evidence，`timelineItems=24`。

`MTP-73-NO-LIVE-AUDIT-INCIDENT-REPLAY-STOP-CONTROL`

MTP-73 必须保持以下 flags 为 false：

- `providesCommandSurface`
- `providesOrderLevelCommand`
- `supportsQueryLanguage`
- `providesLiveAudit`
- `providesIncidentReplay`
- `providesStopControl`
- `authorizesLiveTrading`
- `touchesBrokerAction`
- `authorizesTradingExecution`

`MTP-73-LIVE-MONITORING-EVENT-TIMELINE-VALIDATION`

MTP-73 的验证入口：

- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须包含 `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence`、`PaperWorkflowEvidenceExplorerReadModel.liveMonitoringEvidence`、`coversLiveMonitoringEvidence` 和 live monitoring timeline item 生成逻辑。
- `Sources/App/App.swift` 必须把 `ReportReadModel.liveMonitoringEvidence` 传入 `PaperWorkflowEvidenceExplorerReadModel`。
- `Tests/AppTests/AppTests.swift` 必须覆盖 `testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems`、全量 timeline item count、分区 item count、evidence IDs 和 no command / no live audit / no incident replay / no stop control assertions。
- Focused validation：`swift test --filter AppTests/testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems`。
- Required validation：`swift test --filter AppTests` 和 `bash checks/run.sh`。
- `checks/automation-readiness.sh` 的完整 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-73 只回填 Event Timeline preview evidence 和本地验证证据。

## MTP-68 validation anchors

`MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS`

MTP-68 只定义 validation anchor 名称和入口，不实际修改 `checks/automation-readiness.sh`。automation readiness 的机械收口保留给 MTP-74。

候选 Matrix ID：

- `TVM-LIVE-MONITORING-CONSOLE`

候选 contract anchors：

- `MTP-68-LIVE-MONITORING-CONSOLE-IA`
- `MTP-68-LIVE-MONITORING-TERMS`
- `MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`
- `MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`
- `MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`
- `MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS`
- `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`

MTP-68 验证入口：

- `docs/contracts/live-monitoring-console-contract.md` 必须包含以上 anchors。
- `docs/product/product-surface-map.md` 必须能定位 Live monitoring console information architecture。
- `docs/contracts/frontend-view-model-contract.md` 必须说明 Dashboard / Report / Event Timeline 的 read-model-only 边界。
- `docs/domain/context.md` 必须说明 live monitoring 术语和 order stream evidence 语义。
- `docs/validation/validation-plan.md` 和 `docs/validation/trading-validation-matrix.md` 必须列出 MTP-68 候选 validation anchor。
- `checks/automation-readiness.sh` 在本 issue 中保持不改；不得提前机械收口 MTP-68 anchors。
- `bash checks/run.sh` 必须通过。

`MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`

本 issue 只提供候选 anchor 和文档入口，不把这些 anchor 加入 `checks/automation-readiness.sh`。后续 MTP-74 收口 validation matrix、automation readiness 和 stage audit input material 时，才允许把 MTP-68 至 MTP-73 的 anchors 统一机械化。

## MTP-69 validation anchors

`MTP-69-LIVE-RUNTIME-HEALTH-VALIDATION`

MTP-69 的验证入口：

- `Sources/Core/LiveMonitoringConsole.swift` 必须包含 `LiveMonitoringStatus`、`LiveConnectionKind`、`LiveConnectionStatusReadModel` 和 `LiveRuntimeHealthReadModel`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 `testLiveRuntimeHealthDefinesMTP69ReadModelOnlyFixture`、`testLiveRuntimeHealthRejectsMTP69CommandNetworkSecretAndSchemaBypass` 和 `testLiveConnectionStatusKeepsMTP69ConnectionEvidenceNonExecutable`。
- Focused validation：`swift test --filter MTP69`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 仍不在 MTP-69 中收口 `TVM-LIVE-MONITORING-CONSOLE`；MTP-74 才允许统一机械化 MTP-68 至 MTP-73 anchors。
