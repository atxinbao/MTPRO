# Live Audit Incident Stop Contract

日期：2026-05-23

执行者：Codex

本文档定义 `MTPRO Live Audit Incident Stop Boundary v1` 的 Future live audit、audit trail、incident、incident replay、stop control、emergency stop、shutdown、restore terminology、taxonomy 和 validation anchor 候选入口。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、OMS、real order state machine、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command、order form、交易按钮或 broker action。

## MTP-89 Live audit / incident / stop terminology

`MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`

Live audit / incident / stop 在当前 Project 中不是可执行实盘运维能力，而是一组 Future / gated terminology。MTP-89 只允许定义这些词汇、taxonomy 和 validation anchors，不允许把它们变成 incident replay runtime、stop command、production operations、Live PRO Console、live command surface 或 UI 操作入口。

| Term | 中文定义 | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `live audit` | Future Live 中对实盘边界、事件、命令、风险和恢复过程的审计概念。 | Future / gated terminology | 合同术语、validation anchor、blocked evidence source | 当前审计存储、production audit service |
| `audit trail` | Future Live 可能串联 signal、order、risk decision 和 fill 证据的审计轨迹。 | Future / gated taxonomy | taxonomy label、future gate | 当前 append-only production audit log |
| `incident` | Future Live 可能需要调查、回放或人工处理的事故语义。 | Future / gated terminology | incident taxonomy、blocked evidence | 当前 incident runtime 或 alerting / paging |
| `incident replay` | Future Live 可能用于事故分析的回放能力名称。 | Future / gated taxonomy | future gate、forbidden test | 当前 incident replay runtime |
| `stop control` | Future Live 可能阻断交易或运维动作的控制类别。 | Future / gated terminology | future gate、blocked evidence | 当前 stop control runtime 或 live command |
| `emergency stop` | Future Live 可能存在的紧急停止语义。 | Future / gated taxonomy | forbidden capability anchor | 当前 emergency stop command |
| `shutdown` | Future Live 可能存在的生产停机语义。 | Future / gated taxonomy | forbidden capability anchor | 当前 shutdown command / production operation |
| `restore` | Future Live 可能存在的恢复语义。 | Future / gated taxonomy | forbidden capability anchor | 当前 restore command / auto recovery |

## MTP-89 future audit / incident / stop taxonomy

`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`

MTP-89 的 future taxonomy 只固定分类，不提供可执行 audit、incident 或 stop control surface：

| Taxonomy term | 含义 | 当前禁止 |
| --- | --- | --- |
| `signal audit trail` | Future Live 可能审计策略信号来源和决策路径。 | 不实现 production audit log，不授权实盘策略命令。 |
| `order audit trail` | Future Live 可能审计真实订单 intent、submit、cancel、replace 和状态变化。 | 不实现 real order state machine、OMS、submit / cancel / replace。 |
| `risk decision audit trail` | Future Live 可能审计 risk gate decision 和阻断原因。 | 不实现真实 live risk engine 或 real pre-trade allow / reject runtime。 |
| `fill audit trail` | Future Live 可能审计 broker fill 和 execution report。 | 不消费 execution report，不记录 broker fill，不执行 reconciliation。 |
| `incident replay` | Future Live 可能回放事故相关证据链。 | 不实现 incident replay runtime。 |
| `stop control` | Future Live 可能定义 stop control gate 和 blocked evidence。 | 不实现 stop control runtime 或 live command。 |
| `emergency stop` | Future Live 可能定义紧急停止控制。 | 不实现 emergency stop command。 |
| `shutdown` | Future Live 可能定义停机流程。 | 不实现 shutdown command 或 production operations。 |
| `restore` | Future Live 可能定义恢复流程。 | 不实现 restore command 或 auto recovery。 |
| `production operations` | Future Live 可能定义生产运维 handoff。 | 不实现 production operations runtime。 |

这些 taxonomy term 只能进入 contract docs、Core deterministic fixture、validation plan、matrix 和 PR evidence。任何后续 issue 若要把 taxonomy 扩展为 read model、Dashboard / Report / Event Timeline evidence 或 runtime gate，必须等对应 Linear issue 成为唯一 configured executable issue。

## MTP-89 blocked evidence only future gates

`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`

MTP-89 只能声明 Future gates 和 blocked evidence source anchors：

- `TVM-LIVE-TRADING-FOUNDATION`
- `TVM-LIVE-EXECUTION-CONTROL`
- `TVM-LIVE-RISK-GATE`
- `MTP-65-LIVE-BLOCKED-EVIDENCE`
- `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`

这些 anchors 只说明后续 audit / incident / stop evidence 必须复用既有 Live blocked、execution-control blocked 和 risk-gate blocked evidence chain。它们不把 Workbench、Dashboard、Report 或 Event Timeline 升级为 Live PRO Console，也不新增 live command、trading button、broker action 或 production operations。

## MTP-89 no incident replay or stop command

`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`

MTP-89 的 non-implementation evidence 必须来自三层本地证据：

- Core deterministic fixture：`LiveAuditIncidentStopTerminologyBoundary` 只定义 terminology、future taxonomy、future gates、forbidden capabilities、blocked evidence source anchors 和 validation anchors。
- Core deterministic tests：`testLiveAuditIncidentStopTerminologyDefinesMTP89FutureOnlyTaxonomy`、`testLiveAuditIncidentStopTerminologyRejectsMTP89RuntimeCommandAndConsoleBypass` 和 `testLiveAuditIncidentStopTerminologyKeepsMTP89BlockedEvidenceFutureOnly`。
- Required validation：`bash checks/run.sh`；不得依赖真实 Binance 网络、API key、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

禁止能力 baseline：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker action、broker / exchange execution adapter。
- `LiveExecutionAdapter`、OMS、real order state machine。
- real order submit / cancel / replace。
- execution report runtime、broker fill runtime、reconciliation runtime。
- audit trail runtime。
- incident replay runtime。
- stop control runtime。
- emergency stop / shutdown / restore command。
- production operations runtime。
- Live PRO Console。
- live command surface、order-level command UI、trading button。
- Workbench / Dashboard 升级为 Live PRO Console。

## MTP-89 no Live PRO Console surface

`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`

Workbench 和 Dashboard 仍是当前 paper / research / validation / read-model-only evidence surface。MTP-89 不允许把任何页面、ViewModel、Report、Event Timeline 或 evidence explorer 描述为当前 Live PRO Console。Live PRO Console 仍必须经过独立 Human decision、独立 Project Definition 和后续 signed / account / broker / risk / ops gates 才能进入 IA / UI / implementation。

## MTP-89 validation anchors

`MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION`

MTP-89 建立以下 validation anchors，供后续 issue 接入 forbidden capability tests：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`
- `MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`
- `MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`
- `MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`
- `MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION`

## MTP-90 signal / order / risk decision / fill audit trail future gates

`MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`

MTP-90 只把 signal、order、risk decision 和 fill audit trail 定义为 Future gates。它们是后续 Project Definition 前必须补齐的合同和证据来源，不是当前 audit trail runtime、production audit log、execution report ingestion、broker fill fact、OMS log、broker ledger 或 broker action。

| Audit trail subject | Future gates | 当前允许 source anchor | 当前禁止输出 |
| --- | --- | --- | --- |
| `signal` | signal source contract、signal decision path contract、signal replay correlation contract | `MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`、paper strategy / signal evidence | production audit service、live strategy command、真实交易授权 |
| `order` | order intent source contract、order state transition contract、order command authorization gate | `PaperOrderIntent`、`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE` | real order state machine、OMS、submit / cancel / replace、broker action |
| `risk decision` | risk decision source contract、risk gate outcome contract、risk blocked reason contract | `PaperExecutionDecision`、`RiskBlockerEvidence`、`MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` | live risk decision runtime、real pre-trade allow / reject、circuit breaker command |
| `fill` | fill source contract、execution report source gate、broker fill source gate | `PaperSimulatedFillEvidence`、execution-control blocked evidence source anchor | execution report ingestion、broker fill fact、broker fill recorder、reconciliation runtime |

这些 gates 由 Core deterministic fixture `LiveAuditTrailFutureGateBoundary` 固定，fixture 只输出 contract / validation evidence。它不读取 secret，不接 signed endpoint / account endpoint / listenKey，不实例化 `LiveExecutionAdapter`，不连接 broker，不提供 live command、order-level command UI 或交易按钮。

## MTP-90 forbidden execution report / broker fill / OMS tests

`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`

MTP-90 的 forbidden capability tests 必须阻断：

- execution report ingestion / runtime。
- broker fill fact / broker fill recorder。
- real order state machine。
- OMS。
- broker reconciliation。
- broker action。
- `LiveExecutionAdapter`。
- signed endpoint、account endpoint 和 listenKey。

`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`

任何 signal / order / risk decision / fill audit trail gate 都不得变成 real order lifecycle、submit / cancel / replace、broker action、broker session mutation、OMS repair、execution report parser、broker fill event fact 或 reconciliation runtime。

## MTP-90 paper evidence no real audit fact upgrade

`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`

MTP-90 可以引用 paper-only / read-model-only source anchors，但不能把它们升级为真实 audit fact：

- strategy signal evidence 不等于 live signal audit fact。
- `PaperOrderIntent` 不等于 real order audit fact、real order command 或 broker order state。
- `PaperExecutionDecision` / `RiskBlockerEvidence` 不等于 future live risk decision、real pre-trade allow / reject 或 broker rejection。
- `PaperSimulatedFillEvidence` 不等于 broker fill、execution report、real account state 或 reconciliation input。
- `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` 只能作为 blocked evidence source anchors，不得升级为 incident command、stop command、restore decision、production operations 或 Live PRO Console。

## MTP-90 validation anchors

`MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

MTP-90 建立以下 validation anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`
- `MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`
- `MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`
- `MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`
- `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

后续 issue 只能在该 Future / forbidden boundary 内继续细化：

- `MTP-91`：incident replay future gates 和 forbidden capability tests。
- `MTP-92`：emergency stop / shutdown / restore future gates 和 forbidden capability tests。
- `MTP-93`：Live risk / execution blocked evidence 与 future incident / stop boundary 的隔离合同。
- `MTP-94`：read-model-only incident / stop blocked evidence 和 Dashboard / Report / Event Timeline 展示面。
- `MTP-95`：validation matrix、automation readiness 和 stage audit input material 收口。
