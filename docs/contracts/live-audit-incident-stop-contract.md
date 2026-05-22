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

## MTP-91 incident replay future gates

`MTP-91-INCIDENT-REPLAY-FUTURE-GATES`

MTP-91 只定义 incident replay 的 Future gates。`incident replay` 在当前 Project 中仍是受门禁保护的事故分析能力名称，不是当前 runtime、生产恢复系统、broker replay、account replay、auto restore 或 Live PRO Console。

| Gate group | Future gates | 当前允许 source anchor | 当前禁止输出 |
| --- | --- | --- | --- |
| input source | incident input source contract、audit trail input source gate、Event Log evidence input boundary | `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`、`MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`、`Event Log` | broker state reader、real account state reader、signed/account/listenKey |
| replay scope | replay scope contract、replay time window scope | `Replay` deterministic evidence path | production incident replay runtime、broker replay runtime、account replay runtime |
| replay evidence | replay evidence source contract、deterministic replay evidence path | `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`、`TVM-LIVE-AUDIT-INCIDENT-STOP` | execution report ingestion、broker fill fact、audit trail runtime |
| replay output | replay output contract、read-model-only replay output gate、production recovery output forbidden | contract docs、validation plan、deterministic Core tests | production recovery、auto restore、auto rollback、production runtime mutation、live command |

这些 gates 由 Core deterministic fixture `LiveIncidentReplayFutureGateBoundary` 固定。该 fixture 只输出 contract / validation evidence，不读取 secret，不接 signed endpoint / account endpoint / listenKey，不读取真实 account / broker state，不实例化 `LiveExecutionAdapter`，不连接 broker，不提供 Live PRO Console、live command、order-level command UI 或交易按钮。

## MTP-91 incident replay input source gates

`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`

MTP-91 的 input source gates 必须把当前 Event Log / Replay 限定为 deterministic evidence path：

- `Event Log` 只能作为 append-only facts source 的当前证据路径，不等于 production incident log、broker ledger、OMS log 或真实账户回放输入。
- `Replay` 只能作为本地 deterministic replay / projection evidence，不等于 production recovery、auto restore、broker replay、account replay 或 live runtime resume。
- `MTP-90` 的 signal / order / risk decision / fill audit trail gates 只是 future audit trail contract，不提供 execution report ingestion、broker fill source、real account state 或 reconciliation runtime。

## MTP-91 replay scope / evidence / output gates

`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`

MTP-91 固定 replay scope、replay evidence 和 replay output 的 Future / forbidden 边界：

- replay scope 只描述后续 incident replay 必须有范围合同、时间窗口合同和证据边界，不实现生产事故回放 runtime。
- replay evidence 只能引用 deterministic evidence path、contract docs、validation matrix 和 focused tests，不读取 broker state、account state、signed endpoint、account endpoint 或 listenKey。
- replay output 只能是后续 read-model-only evidence gate，不得输出 production recovery、auto restore、auto rollback、production operations command、Live PRO Console、live command 或交易按钮。

## MTP-91 forbidden recovery / broker / account replay tests

`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`

MTP-91 的 forbidden capability tests 必须阻断：

- incident replay runtime。
- production recovery runtime。
- auto restore runtime / auto rollback runtime。
- broker replay runtime / account replay runtime。
- broker state reader / real account state reader。
- signed endpoint、account endpoint、listenKey。
- broker action、`LiveExecutionAdapter`、OMS、real order state machine。
- execution report ingestion、broker fill fact、audit trail runtime。
- production operations runtime、Live PRO Console、live command、trading button。
- 当前 Event Log / Replay 升级为 production recovery 或 broker replay。

`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`

当前 replay 仍是 deterministic evidence path。它可以帮助 Research / Backtest / Paper / validation evidence 追溯事实和 projection，但不表示 production recovery、restore decision、broker replay、account replay、auto rollback、live runtime resume 或生产运维能力。

## MTP-91 validation anchors

`MTP-91-INCIDENT-REPLAY-VALIDATION`

MTP-91 建立以下 validation anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-91-INCIDENT-REPLAY-FUTURE-GATES`
- `MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`
- `MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`
- `MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`
- `MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`
- `MTP-91-INCIDENT-REPLAY-VALIDATION`

## MTP-92 emergency stop / shutdown / restore future gates

`MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`

MTP-92 只定义 emergency stop、shutdown 和 restore 的 Future gates。它们是后续 Project Definition 前必须补齐的合同、授权、scope 和 evidence 条件，不是当前停机命令、恢复命令、生产运维控制、Live PRO Console 或交易入口。

| Gate group | Future gates | 当前允许 source anchor | 当前禁止输出 |
| --- | --- | --- | --- |
| `emergency stop` | emergency stop policy contract、trigger source gate、authorization gate、read-model-only blocked evidence gate | `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`、`MTP-91-INCIDENT-REPLAY-VALIDATION` | emergency stop command、stop button、broker action、live command |
| `shutdown` | shutdown policy contract、shutdown scope contract、production operations handoff gate | contract docs、validation plan、deterministic Core tests | shutdown command、global trading lock、broker session mutation、production shutdown control |
| `restore` | restore policy contract、restore readiness evidence gate、restore authorization gate | incident replay future gates、blocked evidence source anchors | restore command、auto recovery、restore decision runtime、live runtime resume |
| `risk gate separation` | circuit breaker / no-trade separation、live risk gate no stop runtime separation | `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` | circuit breaker runtime、no-trade state runtime、risk command surface |

这些 gates 由 Core deterministic fixture `LiveStopShutdownRestoreFutureGateBoundary` 固定。该 fixture 只输出 contract / validation evidence，不读取 secret，不接 signed endpoint / account endpoint / listenKey，不读取真实 account / broker state，不实例化 `LiveExecutionAdapter`，不连接 broker，不提供 Live PRO Console、stop button、live command、order-level command UI 或交易按钮。

## MTP-92 forbidden stop / shutdown / restore capability tests

`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`

MTP-92 的 forbidden capability tests 必须阻断：

- emergency stop command。
- shutdown command。
- restore command。
- stop control runtime。
- production shutdown control。
- production operations runtime。
- global trading lock。
- broker session mutation。
- broker action。
- signed endpoint、account endpoint、listenKey。
- `LiveExecutionAdapter`、OMS、real order state machine。
- live risk engine、circuit breaker runtime、no-trade state runtime。
- restore decision runtime、live runtime resume。
- risk command surface、live command surface、Live PRO Console。
- stop button 和 trading button。

`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`

MTP-92 可以引用 `LiveCircuitBreakerNoTradeGateBoundary`、`MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` 作为 source anchors，但这些 anchors 不能被升级为当前 emergency stop、shutdown、restore、global trading lock、broker session mutation 或 production shutdown control。

`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`

shutdown future gates 只描述后续必须定义的 policy、scope 和 operations handoff。它们不修改 broker session state，不创建全局交易锁，不执行 production shutdown，不产生 restore decision，也不恢复 live runtime。

## MTP-92 validation anchors

`MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

MTP-92 建立以下 validation anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`
- `MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`
- `MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`
- `MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`
- `MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

## MTP-93 live risk / execution blocked evidence isolation

`MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`

MTP-93 只定义 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence` 和 paper-only evidence 与 future incident / stop boundary 的隔离合同。Execution-control blocked evidence 只能说明 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 为什么仍被阻断；risk gate blocked evidence 只能说明 exposure、notional、frequency、loss / drawdown、circuit breaker 和 no-trade state 为什么仍被阻断。两者都不能升级为 incident command、stop command、restore decision、execution runtime、live risk engine 或 production operations。

| Source evidence | 当前允许用途 | 当前禁止升级 |
| --- | --- | --- |
| `LiveExecutionControlBlockedEvidence` | read-model-only blocked reason、deterministic snapshot、PR boundary evidence | incident command、stop command、restore decision、execution runtime、live command |
| `LiveRiskGateBlockedEvidence` | read-model-only risk gate blocked reason、deterministic snapshot、PR boundary evidence | incident replay runtime、emergency stop、shutdown command、live risk engine、risk command |
| `PaperOrderIntent` / `PaperSimulatedFillEvidence` / `PortfolioExposureSnapshot` | paper-only evidence source anchor、validation matrix evidence | production incident fact、stop decision、restore readiness、broker fill fact、real account state |

这些 gates 由 Core deterministic fixture `LiveBlockedEvidenceIncidentStopIsolationBoundary` 固定。该 fixture 只输出 isolation contract、source anchors、validation anchors 和 forbidden capability flags，不读取 secret，不接 signed endpoint / account endpoint / listenKey，不读取真实 account / broker state，不实例化 `LiveExecutionAdapter`，不连接 broker，不提供 Live PRO Console、live command、stop button、order-level command UI 或交易按钮。

## MTP-93 no blocked evidence to incident / stop command upgrade

`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`

MTP-93 的 forbidden capability tests 必须阻断：

- execution-control blocked evidence -> incident command。
- execution-control blocked evidence -> stop command。
- execution-control blocked evidence -> restore decision。
- risk gate blocked evidence -> incident replay runtime。
- risk gate blocked evidence -> emergency stop。
- risk gate blocked evidence -> shutdown command。
- incident replay runtime、stop command、shutdown command、restore command。
- execution runtime、live risk engine、production operations runtime。
- signed endpoint、account endpoint、listenKey、broker action。
- `LiveExecutionAdapter`、OMS、real order state machine。
- Live PRO Console、live command surface、trading button。

## MTP-93 paper evidence no incident / stop upgrade

`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`

MTP-93 可以引用 `PaperOrderIntent`、`PaperSimulatedFillEvidence`、`RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 作为 source anchors，但这些 paper-only evidence 不能变成 future incident command input、production incident fact、stop decision、restore readiness evidence、broker fill fact、real account state 或 production operations handoff。MTP-93 只允许把它们列为隔离证据，不允许写成当前事故回放、停机、恢复或实盘运维能力。

## MTP-93 forbidden command / runtime upgrade tests

`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`

Core focused tests 必须覆盖 `LiveBlockedEvidenceIncidentStopIsolationBoundary` 的 deterministic fixture、command/runtime forbidden flags、Codable 解码拒绝绕过，以及 paper-only evidence / read-model-only evidence 的 source anchor 隔离。

## MTP-93 validation anchors

`MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`

MTP-93 建立以下 validation anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`
- `MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`
- `MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`
- `MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`
- `MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`
