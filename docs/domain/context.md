# MTPRO Domain Context

日期：2026-05-20

执行者：Codex

## 定位

本文档是 MTPRO 的 shared language / 领域上下文入口。

它只定义稳定词汇和禁止混用的说法，不是 spec，不是 implementation plan，不授权创建 Linear Project / Issue，不授权推进 `Todo`，不启动 Symphony，不写业务代码。

来源：`mattpocock/skills` 的 shared language / `CONTEXT.md` 思路。参考 `https://github.com/mattpocock/skills`、`https://github.com/mattpocock/skills/blob/main/CONTEXT.md`、`https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`。

## Project / Execution Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Project Charter` | `GOAL.md`，说明为什么建、服务谁、硬边界和成功标准 | 不叫完整蓝图 |
| `Root Blueprint` | `BLUEPRINT.md`，项目总览、默认读取顺序和完整蓝图入口 | 不授权执行 |
| `Complete Blueprint` | `BLUEPRINT.md`，最终产品 / 系统 / 设计蓝图 | 不叫当前 sprint，不叫 issue plan |
| `Engineering Module Map / 工程模块地图` | `docs/architecture.md`，承接 `BLUEPRINT.md` 的工程模块、模块边界、数据流、接口关系和架构不变量 | 不等于完整未来蓝图，不推翻蓝图 |
| `Construction Plan` | `docs/roadmap.md`，根据蓝图和工程模块定义施工顺序、当前施工阶段、完成进度和非授权边界 | 不等于 Linear queue |
| `Current Construction Scope` | Human 当前允许进入规划的施工范围 | 不包含 Future Construction Zones / 未来建设区 |
| `Future Construction Zones / 未来建设区` | 完整蓝图中的长期能力区，例如 Live、signed endpoint、broker、OMS；可以设计，但当前不施工 | 不得自动变成 Linear issue |
| `Project Planning Record` | 仓库中的 Project 级计划摘要，位于 `docs/planning/projects/` | 不复制完整 Linear issue body |
| `Linear execution contract` | Linear issue body 中的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements | 不由仓库文档替代 |
| `configured executable issue` | Linear live-read 中通过 Parent Codex queue preflight 后唯一可执行 issue | 不等于 Backlog issue |
| `Parent Codex queue preflight` | `@002 / PAR` 在 Project 内确认 WIP=1、依赖、contract 和 active conflict 的检查 | 不等于 symphony-issue 执行 |
| `symphony-issue` | 调度唯一 `Todo` issue 的执行层 actor | 不创建 Project，不做 planning |
| `Stage Code Audit Report` | Project 全部 Done 后由 Parent Codex 单独输出并落仓的 Project 级审计报告 | 不由 child issue 输出 |
| `Root Docs Refresh Gate` | Project closure 后把已发生代码事实同步回 root docs 的 gate | 不决定下一阶段方向 |
| `Current Phase Progress Bar` | `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出的阶段完成进度 | 不按 Project 数量直接计算 |

## Runtime / App Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data` | Binance public read-only 行情数据 | 不包含 account、listenKey、signed endpoint |
| `Event Log` | append-only facts source | 不叫 UI model，不保存 runtime object |
| `Replay` | 从 facts source 重建 projection / evidence 的确定性路径 | 不叫生产恢复系统 |
| `Projection` | SQLite / DuckDB 或内存读模型中的派生视图 | 不作为 UI contract |
| `Read Model` | App / Dashboard 可以消费的稳定只读数据结构 | 不暴露 database schema |
| `ViewModel` | Dashboard / Workbench 绑定的 UI 输入 | 不直接读取 adapter、runtime object 或 persistence schema |
| `Command Model` | 本地 paper-only session-level 控制意图模型 | 不表示真实交易命令 |
| `Report Artifact` | 汇总 research / backtest / paper / risk / event evidence 的研究输出 | 不授权真实交易 |
| `Event Timeline` | read-model-only 的 evidence 浏览视图 | 不做完整查询语言，不暴露 persistence |

## Paper Runtime Kernel Terms

`MTP-96-PAPER-RUNTIME-KERNEL-TERMS`

以下术语由 MTP-96 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的第一层 paper-only runtime foundation language。它们只用于 TradingClock、paper runtime kernel boundary、validation anchor 和后续 issue 的基础合同，不授权当前 scope 实现 CommandBus / EventBus / Paper RiskEngine / lifecycle coordinator / simulated fill / paper account projection。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `TradingClock` | paper runtime kernel 的 deterministic tick 来源，只允许 fixture / replay tick | 不等于 exchange clock、broker session clock、production scheduler 或 `Date()` wall clock |
| `TradingClockTick` | 本地 paper runtime 可消费的 tick fact，带 monotonic sequence 和 deterministic instant | 不等于 market sequence、broker sequence 或真实调度游标 |
| `paper runtime kernel boundary` | Core 层 value contract，固定 paper kernel 输入、输出、lifecycle、event stream 和 forbidden capability flags | 不等于 Runtime actor、生产调度服务、UI state 或 persistence schema |
| `paper command intake` | 允许进入 kernel boundary 的 paper / local / replay 输入类别，例如 paper session command、session local control、paper action proposal、paper execution decision 和 replay command | 不等于 live command、order form、real submit / cancel / replace 或 broker request |
| `paper event emission` | kernel boundary 允许输出的 `.paper` event envelope、replay result 或后续 projection trigger | 不等于 adapter payload、broker acknowledgement、database schema 或 Dashboard ViewModel |
| `kernel replay invariant` | replay 只能从 append-only event log facts 重建 deterministic evidence | 不等于 production recovery、broker replay、account replay 或 incident replay runtime |

`MTP-97-PAPER-RUNTIME-BUS-ROUTING-TERMS`

以下术语由 MTP-97 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only deterministic routing language。它们只用于 CommandBus / EventBus / MessageBus route evidence、correlation / causation tracing 和 Event Log / Replay 输入，不授权当前 scope 实现 Paper RiskEngine、paper lifecycle coordinator、真实 execution runtime、signed endpoint、broker action 或 live command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `PaperRuntimeCommandBus` | Core 层 paper-only input classifier，把 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event 展开为 deterministic routed messages | 不等于 live command bus、order submit bus、broker command plane 或 production scheduler |
| `PaperRuntimeEventBus` | Core 层本地 publish 边界，只把 routed message 发布到既有 `MessageBus` / append-only facts source | 不等于 external pub/sub、broker stream、exchange adapter 或 Runtime actor |
| `PaperRuntimeMessageBusRouting` | CommandBus -> EventBus -> MessageBus 的 MTP-97 便利编排入口，用 deterministic clock、envelope ID、correlation ID 和 causation ID 固定 route evidence | 不等于 live execution message bus、OMS bus 或真实订单状态机 |
| `PaperRuntimeRouteEvidence` | 从 `EventEnvelope` 或 replay result 重建的 route source / payload / stream / correlation / causation 摘要 | 不暴露 Runtime object、SQLite / DuckDB schema、adapter payload、broker acknowledgement 或 UI state |
| `paper runtime bus routing contract` | `PaperRuntimeBusRoutingContract` 中的 allowed buses、route sources、payload kinds、`.paper` / `.risk` streams 和 forbidden capability flags | 不授权 signed request routing、account endpoint、listenKey、execution report、broker fill 或 reconciliation |

## Live Boundary Terms

以下术语只用于 Future / gated 实盘边界设计和当前 blocked evidence，不授权当前 scope 实现真实交易能力。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live capability` | 未来实盘交易基础能力的候选名称，例如 secret policy、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle | 不等于当前已有可执行能力 |
| `blocked capability` | 当前已识别但被 gate 阻断的能力；可以进入 read-model-only blocked evidence | 不等于 fallback、mock broker 或 paper order 升级 |
| `future gate` | 某项 live capability 进入后续 Project Definition 前必须满足的条件和证据 | 不自动解锁 Linear issue，不推进 Todo |
| `forbidden capability` | 当前 Project 明确禁止的能力；任何代码、测试或文档都不得把它表达成当前可用能力 | 不写成 allowed capability，不写成 partially supported |
| `credential endpoint boundary` | MTP-62 Gate 1 中 API key、secret storage、request signature、signed endpoint、account endpoint 和 listenKey 只能作为 forbidden / future gate 出现的边界 | 不读取本地 secret，不新增 env/config/keychain，不实现签名请求或 account payload |
| `adapter capability isolation` | MTP-63 Gate 2 中 current public read-only adapter 与 future live adapter / broker / exchange execution adapter 的隔离合同 | 不实现 `LiveExecutionAdapter`，不连接 execution venue，不把 public market data adapter 升级为执行 adapter |
| `real order lifecycle boundary` | MTP-64 Gate 3 中 real order intent、state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS 和 real account state 只能作为 terminology、future gate 和 forbidden tests 出现的边界 | 不实现真实订单状态机，不把 paper order intent、simulated fill 或 paper portfolio projection 升级为 real order、broker fill 或 account state |
| `Live readiness blocked read model` | MTP-65 Gate 4 中 `LiveReadiness` / `LiveBlockedEvidence` 只用 read-model-only 方式说明 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 仍被阻断 | 不提供 live command，不暴露 adapter / runtime / persistence schema，不授权真实交易或交易按钮 |
| `Live blocked evidence surface` | MTP-66 Gate 5 中 Dashboard / Report / Event Timeline 只读展示 `LiveReadiness` blocked evidence 的产品面 | 不等于实盘监控台、实盘执行控制、实盘风险控制、实盘审计或任何交易入口 |

## Live Monitoring Terms

`MTP-68-LIVE-MONITORING-TERMS`

以下术语由 MTP-68 定义为 `MTPRO Live Monitoring Console v1` 的 read-model-only language。它们只用于信息架构、合同和后续验证 anchor，不授权当前 scope 实现 live runtime、真实连接或交易执行能力。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live monitoring console` | 后续实盘监控台的信息架构和只读 evidence surface，覆盖 runtime health、connection、market stream、order stream evidence、latency、error、degraded state 和 operations evidence | 不等于当前 live runtime，不等于执行控制台，不提供交易按钮 |
| `live runtime health` | 后续 read model 可表达的 runtime health status，例如 blocked、unknown、nominal、stale、degraded、error、recovered | 不等于当前已启动 runtime actor 或生产进程 |
| `connection status` | 后续连接状态只读证据，可描述 public connection 或 future private connection gate | 不等于 account endpoint、listenKey、private WebSocket 或 broker session |
| `market stream status` | Binance public read-only market stream 的健康、freshness 和 latency evidence | 不等于 signed endpoint、account stream 或 execution venue |
| `order stream evidence` | 订单流相关的 blocked / simulated / future-only evidence，用于解释真实订单流仍未实现或后续 gate | 不等于 real order state machine、execution report、broker fill、OMS 或真实账户状态 |
| `latency evidence` | 从 read model 派生的延迟 bucket、last update、freshness 和 stale evidence | 不等于 runtime profiler、生产 telemetry agent 或自动扩缩容信号 |
| `error evidence` | 后续 Report / Dashboard / Event Timeline 可展示的错误事实摘要 | 不等于 incident command、自动恢复动作或 broker failure handler |
| `degraded state` | health / connection / stream / latency / error evidence 显示降级，但仍只作为可观察事实 | 不等于允许绕过 risk gate 或继续执行真实订单 |
| `operations evidence` | validation、handoff、Stage Audit input、known boundary 和 readiness evidence chain | 不等于 production operations command、部署或远程运维 |

## Live Execution Control Terms

`MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`

以下术语由 MTP-75 定义为 `MTPRO Live Execution Control Contract v1` 的 Future / gated language。它们只用于 execution-control contract、real order command taxonomy、paper / real command isolation 和后续 forbidden capability tests，不授权当前 scope 实现真实订单命令或 UI 操作入口。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `execution control` | Future Live 中对真实订单 submit / cancel / replace、execution report、reconciliation 和 incident fallback 的控制边界 | 不等于当前 execution runtime、Dashboard 控制台或交易授权 |
| `real order command` | Future Live 可能需要的真实订单命令族 taxonomy | 不等于 Swift `Command`、paper command、UI button 或 broker request |
| `submit` | Future 真实订单提交 taxonomy term | 不等于当前可调用 order submit |
| `cancel` | Future 真实订单撤销 taxonomy term | 不等于当前 cancel command 或 broker cancel |
| `replace` | Future 真实订单替换 taxonomy term | 不等于当前 replace command 或 order amendment |
| `execution report` | Future broker / exchange 执行回报输入 | 不等于当前 Event Log fact、simulated fill 或 read model 授权 |
| `reconciliation` | Future 本地订单状态与 broker / exchange 状态核对 | 不等于当前 account sync、broker position sync 或 OMS |
| `incident fallback` | Future 执行异常时的受控降级 / 人工接管策略 | 不等于自动恢复、继续下单、incident command、stop control 或 live audit |
| `paper / real command isolation` | Paper order intent、paper execution decision 和 simulated fill 不能升级为 real order command 的隔离合同 | 不等于 paper evidence 可复用为真实订单输入 |

`MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`

MTP-77 进一步固定 execution report、broker fill 和 reconciliation 的 future gate / blocked evidence 语义：execution report 不等于当前 parser 或 ingestion，broker fill 不等于 simulated fill 或 Event Log 真实成交 fact，reconciliation 不等于 account sync、broker position sync、real account balance read、OMS 修复或当前 runtime service。

`MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`

MTP-78 进一步固定 paper order intent、paper execution decision、simulated fill 和 paper portfolio projection 与 future real order command 的隔离语义：paper evidence 可以进入 Report / Dashboard / Event Timeline 的 read model / ViewModel，但不等于 real order command、signed command request、execution report、broker fill、broker position、real account state、order form、order-level command UI 或交易按钮。

`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`

MTP-79 进一步固定 execution-control blocked evidence 语义：`LiveExecutionControlBlockedEvidence` 只能用 read-model-only 方式说明 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 为什么仍被阻断；它不等于 command model、adapter status、Runtime control、persistence schema、真实订单状态机、execution report parser、broker fill fact、reconciliation service、incident command 或交易按钮。

## Live Risk Gate Terms

`MTP-82-LIVE-RISK-TERMINOLOGY`

以下术语由 MTP-82 定义为 `MTPRO Live Risk Gate Contract v1` 的 Future / gated language。它们只用于 live risk gate contract、future risk decision taxonomy、paper / live risk isolation 和后续 forbidden capability tests，不授权当前 scope 实现真实风控引擎、账户读取、broker position sync、pre-trade allow / reject runtime、risk command surface 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live pre-trade risk` | Future Live 中在真实订单提交前评估 exposure、order notional、frequency、loss、circuit breaker 和 no-trade state 的风险边界 | 不等于当前 risk engine、broker reject、paper blocker 或交易授权 |
| `future risk decision` | Future Live 可能输出的风险决策分类，例如 `allowed`、`blocked`、`degraded`、`no-trade` | 不等于当前 runtime decision、真实订单状态、broker response 或 Dashboard command |
| `risk gate` | Future Live 风控进入实现前必须满足的 contract / validation / operations / audit 门禁 | 不自动解锁 Linear issue，不推进 Todo |
| `risk blocked evidence` | 后续 read-model-only 方式说明 live risk gates 为什么仍被阻断的证据 | 不等于风控命令、真实拒单、熔断服务或 stop control |
| `exposure gate` | Future Live 对真实账户 / 仓位 exposure 的风险门禁 | 不读取真实账户余额、broker position、margin 或 leverage |
| `order notional gate` | Future Live 对真实订单 notional 的风险门禁 | 不实现真实订单金额 allow / reject runtime |
| `frequency gate` | Future Live 对下单频率的风险门禁 | 不实现生产限频器或 broker-side throttling |
| `loss gate` | Future Live 对亏损 / drawdown 的风险门禁 | 不读取真实 PnL、账户权益、margin 或 leverage |
| `circuit breaker` | Future Live 熔断门禁，可在后续设计中解释为什么交易必须被阻断 | 不等于当前 emergency stop、shutdown command、incident replay 或自动恢复 |
| `no-trade state` | Future Live 禁交易状态 taxonomy | 不等于当前 UI disable、真实全局交易锁或 broker session state |

`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`

MTP-82 固定 `allowed`、`blocked`、`degraded` 和 `no-trade` 只是 Future risk decision taxonomy。`allowed` 不授权当前真实订单，`blocked` 不等于 broker rejection，`degraded` 不授权绕过 gate 继续交易，`no-trade` 不实现停机 / 恢复命令。

`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`

Paper risk blocker 和 paper exposure 仍是 Current / paper-only evidence：`RiskBlockerEvidence` 不等于 future live risk decision，`PortfolioExposureSnapshot` 不等于真实账户 exposure、broker position、margin 或 leverage，paper evidence 不能升级为 real pre-trade allow / reject、circuit breaker、no-trade state 或 live risk runtime 输入。

`MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`

MTP-83 进一步固定 exposure gate 和 order notional gate 只是 Future Live Risk contract。它们可以描述后续需要的 account state source contract、broker position source contract、margin / leverage source contract、exposure limit policy、order notional limit policy 和 operations / audit handoff，但当前不得读取真实账户余额、broker position、margin 或 leverage，不得计算真实账户 exposure，不得执行真实 order notional allow / reject，不得实现 live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`

当前 `PortfolioExposureSnapshot` 仍只能是 paper projection 派生的只读 evidence。它不能升级为 live exposure gate 输入、真实账户 exposure、broker position、margin、leverage 或 future live risk decision；`LiveExposureOrderNotionalGateBoundary` 的 account / position / margin / leverage / paper-upgrade flags 必须全部保持 `false`。

`MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`

MTP-84 进一步固定 frequency gate、loss gate 和 drawdown gate 只是 Future Live Risk contract。它们可以描述后续需要的 frequency window policy、order event source contract、PnL / equity source contract、loss limit policy、drawdown limit policy、paper risk / exposure isolation 和 operations / audit handoff，但当前不得统计真实下单频率，不得执行生产限频或 broker-side throttling，不得读取真实 PnL、账户权益、账户余额、broker position、margin 或 leverage，不得执行真实 loss / drawdown allow / reject，不得运行 drawdown circuit breaker，不得实现 live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`

当前 `RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 仍只能是 paper-only evidence。它们不能升级为 live frequency gate 输入、真实 loss / drawdown gate 输入、真实 PnL / equity、pre-trade risk runtime 或 future live risk decision；`LiveFrequencyLossDrawdownGateBoundary` 的 frequency runtime、loss / drawdown runtime、PnL / equity read、drawdown circuit breaker、stop / emergency command 和 paper-upgrade flags 必须全部保持 `false`。

`MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`

MTP-85 进一步固定 circuit breaker gate 和 no-trade state gate 只是 Future Live Risk contract。它们可以描述后续需要的 circuit breaker policy、trigger source contract、no-trade state policy、no-trade state transition policy 和 operations / audit handoff，但当前不得运行真实熔断服务，不得进入真实禁交易状态，不得实现全局交易锁，不得修改 broker session state，不得实现停机 / 恢复命令、production shutdown control、live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE`

当前 `RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 仍只能是 paper-only evidence。它们不能升级为 live circuit breaker trigger、no-trade state trigger、真实 PnL / equity、真实账户状态、pre-trade risk runtime 或 future live risk decision；`LiveCircuitBreakerNoTradeGateBoundary` 的 circuit breaker runtime、no-trade runtime、global trading lock、broker session mutation、stop / emergency / recovery command、production shutdown control 和 paper-upgrade flags 必须全部保持 `false`。

`MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`

MTP-86 进一步固定 paper risk blocker、paper exposure、paper risk decision 和 read-model evidence 与 future live risk decision 的隔离合同。当前 `RiskBlockerEvidence`、`PortfolioExposureSnapshot`、paper risk decision、Report read model、Dashboard ViewModel 和 Event Timeline read model 只能作为 paper-only / read-model-only 证据，不得升级为 `allowed` / `blocked` / `degraded` / `no-trade` future live risk decision、真实账户 exposure、broker position、pre-trade allow / reject runtime、circuit breaker trigger、no-trade state trigger、risk command surface、position management command、order form 或交易按钮。

`MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`

当前 paper risk evidence 不能升级为 future live risk decision；`LivePaperRiskLiveDecisionIsolationBoundary` 的 paper risk blocker / exposure / risk decision upgrade flags、live risk engine flags、pre-trade allow / reject flags、live trading authorization flags 和 required network validation flag 必须全部保持 `false`。

`MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`

当前 paper exposure 不能升级为真实账户风险输入；`LivePaperRiskLiveDecisionIsolationBoundary` 的 real account balance、broker position sync、margin、leverage、real PnL、real account equity 和 paper exposure to account / broker position mapping flags 必须全部保持 `false`。

`MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`

MTP-86 只允许 Report / Dashboard / Event Timeline 展示既有 read model / ViewModel evidence，不新增 live risk command surface、position management command、order form、交易按钮或 `LiveRiskGateBlockedEvidence` 展示面；后者保留给 MTP-87。

`MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`

MTP-87 进一步固定 `LiveRiskGateBlockedEvidence` 的 read-model-only 语义：exposure、order notional、frequency、loss / drawdown、circuit breaker 和 no-trade state 只能以 blocked gate、blocked reason、source anchor 和 deterministic snapshot 进入 Report / Dashboard / Event Timeline；它不等于 live risk engine、real pre-trade allow / reject runtime、真实账户 / broker state reader、circuit breaker / no-trade runtime、risk command、position command、order form 或交易按钮。

## Live Audit Incident Stop Terms

`MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`

以下术语由 MTP-89 定义为 `MTPRO Live Audit Incident Stop Boundary v1` 的 Future / gated language。它们只用于 live audit / incident / stop contract、future taxonomy、blocked evidence source anchors 和后续 forbidden capability tests，不授权当前 scope 实现 incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command、broker action 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live audit` | Future Live 中对实盘边界、事件、命令、风险和恢复过程的审计概念 | 不等于当前 audit storage、production audit service 或 broker-side audit |
| `audit trail` | Future Live 可能串联 signal、order、risk decision 和 fill 证据的审计轨迹 | 不等于当前 append-only production audit log、OMS log 或 broker ledger |
| `incident` | Future Live 可能需要调查、回放或人工处理的事故语义 | 不等于当前 alerting / paging、production incident runtime 或自动恢复 |
| `incident replay` | Future Live 可能用于事故分析的回放能力名称 | 不等于当前 incident replay runtime、broker event replay 或生产回放服务 |
| `stop control` | Future Live 可能阻断交易或运维动作的控制类别 | 不等于当前 stop control runtime、risk command 或 live command |
| `emergency stop` | Future Live 可能存在的紧急停止语义 | 不等于当前 emergency stop command、交易按钮或 broker action |
| `shutdown` | Future Live 可能存在的生产停机语义 | 不等于当前 shutdown command、production operation 或 broker session mutation |
| `restore` | Future Live 可能存在的恢复语义 | 不等于当前 restore command、auto recovery 或 live runtime resume |

`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`

MTP-89 固定 `signal audit trail`、`order audit trail`、`risk decision audit trail`、`fill audit trail`、`incident replay`、`stop control`、`emergency stop`、`shutdown`、`restore` 和 `production operations` 只是 Future audit / incident / stop taxonomy。它们不授权当前 audit runtime、incident replay runtime、emergency stop command、shutdown / restore command、production operations、Live PRO Console、live command、broker action 或交易按钮。

`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`

MTP-89 只能引用 `TVM-LIVE-TRADING-FOUNDATION`、`TVM-LIVE-EXECUTION-CONTROL`、`TVM-LIVE-RISK-GATE`、`MTP-65-LIVE-BLOCKED-EVIDENCE`、`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` 作为 blocked evidence source anchors。引用这些 anchors 不会把 Workbench、Dashboard、Report 或 Event Timeline 升级为 Live PRO Console。

`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`

MTP-89 不实现 incident replay runtime、stop control runtime、emergency stop、shutdown、restore、production operations、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、live command、order-level command UI 或交易按钮；`LiveAuditIncidentStopTerminologyBoundary` 中对应 forbidden flags 必须全部保持 `false`。

`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`

Workbench 和 Dashboard 仍是当前 paper / research / validation / read-model-only evidence surface，不得被描述成当前 Live PRO Console。Live PRO Console 仍是 Future product surface，必须经过独立 Human decision、独立 Project Definition 和后续 signed / account / broker / risk / ops gates。

`MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`

MTP-90 固定 signal audit trail、order audit trail、risk decision audit trail 和 fill audit trail 只是 Future audit trail gates。signal gate 只要求未来 signal source / decision path / replay correlation contract；order gate 只要求未来 order intent source / state transition / command authorization contract；risk decision gate 只要求未来 risk decision source / gate outcome / blocked reason contract；fill gate 只要求未来 fill source / execution report source / broker fill source gate。它们不授权当前 audit trail runtime、production audit log、execution report ingestion、broker fill fact、real order state machine、OMS、broker action、live command 或交易按钮。

`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`

MTP-90 的 forbidden capability tests 必须继续阻断 execution report ingestion、broker fill fact / recorder、real order state machine、OMS、broker reconciliation、broker action、signed endpoint、account endpoint、listenKey 和 `LiveExecutionAdapter`。这些 forbidden capability 可以进入 Core deterministic fixture 和 PR evidence，但不能被实现为当前 parser、adapter、runtime、broker ledger、OMS log 或 UI command。

`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`

MTP-90 不实现 real order state machine、real order submit / cancel / replace、broker session mutation、broker reconciliation、broker action、execution report runtime 或 broker fill runtime。order audit trail 仍是 Future contract，不等于当前 real order lifecycle。

`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`

MTP-90 可以引用 paper-only / read-model-only source anchors，例如 `PaperOrderIntent`、`PaperExecutionDecision`、`RiskBlockerEvidence` 和 `PaperSimulatedFillEvidence`，但这些 evidence 不能升级为真实 audit fact、real order command、future live risk decision、execution report、broker fill、real account state 或 reconciliation input。

`MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

MTP-90 的 validation anchor 由 `LiveAuditTrailFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户或人工验收。

`MTP-91-INCIDENT-REPLAY-FUTURE-GATES`

MTP-91 固定 incident replay 只是 Future / gated incident analysis contract。它只定义 input source、replay scope、replay evidence 和 replay output gates，不授权当前 incident replay runtime、production recovery、broker replay、account replay、auto restore、auto rollback、production operations、Live PRO Console、live command 或交易按钮。

`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`

MTP-91 的 input source gates 只能引用 `MTP-89` terminology、`MTP-90` audit trail gates、`Event Log` 和 `Replay` 作为 deterministic evidence path。当前 `Event Log` 不等于 production incident log、broker ledger、OMS log 或 real account replay source；当前 `Replay` 不等于 production recovery、auto restore、broker replay、account replay 或 live runtime resume。

`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`

MTP-91 的 replay scope / evidence / output gates 只说明后续 incident replay 进入实现前必须补齐范围合同、时间窗口、证据来源和 read-model-only output gate。它们不输出 production recovery、restore decision、broker replay、account replay、live command 或生产运维动作。

`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`

MTP-91 的 forbidden capability tests 必须继续阻断 incident replay runtime、production recovery runtime、auto restore / auto rollback runtime、broker replay runtime、account replay runtime、broker state reader、real account state reader、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution report ingestion、broker fill fact、audit trail runtime、production operations runtime、Live PRO Console、live command 和 trading button。

`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`

当前 replay 仍是 Research / Backtest / Paper / validation 的 deterministic evidence path，不得被写成生产事故回放系统、恢复系统、自动恢复、自动回滚、broker replay、account replay 或 live runtime resume。

`MTP-91-INCIDENT-REPLAY-VALIDATION`

MTP-91 的 validation anchor 由 `LiveIncidentReplayFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`

MTP-92 固定 emergency stop、shutdown 和 restore 只是 Future / gated stop control contract。emergency stop gate 只要求未来 policy / trigger / authorization / read-model-only blocked evidence；shutdown gate 只要求未来 policy / scope / operations handoff；restore gate 只要求未来 policy / readiness evidence / authorization。它们不授权当前 emergency stop command、shutdown command、restore command、production shutdown control、broker session mutation、global trading lock、Live PRO Console、live command、stop button 或交易按钮。

`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`

MTP-92 的 forbidden capability tests 必须继续阻断 emergency stop command、shutdown command、restore command、stop control runtime、production shutdown control、production operations runtime、global trading lock、broker session mutation、broker action、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、OMS、real order state machine、live risk engine、restore decision runtime、live runtime resume、Live PRO Console、live command、stop button 和 trading button。

`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`

MTP-92 可以引用 `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`LiveCircuitBreakerNoTradeGateBoundary` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`，但这些 risk gate anchors 不能升级为当前 emergency stop、shutdown、restore、circuit breaker runtime、no-trade state runtime、risk command surface、global trading lock 或 broker session mutation。

`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`

MTP-92 不实现 broker session mutation、production shutdown control、production operations runtime、restore decision runtime 或 live runtime resume。shutdown / restore 仍是 Future contract，不等于当前生产停机、自动恢复或实盘运行时恢复。

`MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

MTP-92 的 validation anchor 由 `LiveStopShutdownRestoreFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`

MTP-93 固定 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence`、`RiskBlockerEvidence`、`PaperOrderIntent`、`PaperSimulatedFillEvidence` 和 `PortfolioExposureSnapshot` 只能作为 read-model-only / paper-only source anchors。它们可以解释 future audit / incident / stop boundary 为什么仍被阻断，但不能升级为 incident command、stop command、restore decision、execution runtime、live risk engine、production operations、Live PRO Console、live command 或交易按钮。

`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`

MTP-93 的 forbidden capability tests 必须继续阻断 execution-control blocked evidence -> incident command / stop command / restore decision、risk gate blocked evidence -> incident replay runtime / emergency stop / shutdown command，以及 incident replay runtime、stop command、shutdown command、restore command、execution runtime、live risk engine、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、Live PRO Console、live command 和 trading button。

`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`

MTP-93 可以引用 paper order、simulated fill、risk blocker 和 paper exposure 作为隔离证据，但这些 evidence 不能成为 production incident fact、stop decision、restore readiness、broker fill fact、real account state、future live risk decision、incident replay runtime 或 production operations handoff。

`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`

MTP-93 的 validation anchor 由 `LiveBlockedEvidenceIncidentStopIsolationBoundary` 和 focused Core tests 固定；Core tests 必须覆盖 deterministic fixture、forbidden command / runtime flags、Codable 解码拒绝绕过，以及 read-model-only / paper-only source anchors 的隔离。

`MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`

MTP-93 的 required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`

MTP-94 固定 `LiveIncidentStopBlockedEvidence` 的 read-model-only 语义：audit trail、incident replay、emergency stop、shutdown 和 restore 只能以 blocked gate、blocked reason、source anchor、validation anchor 和 deterministic snapshot 进入 Report / Dashboard / Event Timeline。它不等于 audit trail runtime、incident replay runtime、emergency stop command、shutdown command、restore command、production operations、Live PRO Console、stop button、trading button、live command、adapter / runtime / database schema exposure 或 broker action。

`MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`

MTP-94 的 blocked reasons 必须明确说明 Human live audit / incident / stop decision 尚未形成，audit trail runtime、incident replay runtime、emergency stop command、shutdown command、restore command、production operations runtime、broker session mutation、live runtime resume、Live PRO Console、live command surface、stop button、trading button 和 command surface 仍被阻断。

`MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`

MTP-94 deterministic snapshot 是本地 fixture / read model evidence，不读取 secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、adapter object、runtime object 或 persistence schema。它只保留 source anchors、blocked gates、blocked reasons、validation anchors 和 forbidden flags。

`MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-94 允许 Dashboard / Report / Event Timeline 展示 live incident / stop blocked evidence，但所有展示面必须保持只读：Dashboard metrics、Report details、Workbench detail 和 Event Timeline item 都不能带 stop action、restore action、operator workflow、order form、trading button、Live PRO Console 或 broker action。

`MTP-94-LIVE-INCIDENT-STOP-VALIDATION`

MTP-94 的 validation anchor 由 `LiveIncidentStopBlockedEvidence`、`LiveIncidentStopBlockedEvidenceReadModel`、`LiveIncidentStopBlockedEvidenceViewModel`、Dashboard / Report / Event Timeline integration 和 focused Core / App tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

## Paper-only Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Paper Session` | 本地 paper-only session lifecycle | 不等于真实账户 session |
| `Paper Action Proposal` | 策略信号转出的本地 paper-only action intent | 不等于 order |
| `Risk Blocker` | 本地 paper readiness 的 blocker / evidence | 不等于完整实盘风控引擎 |
| `Paper Order Intent` | 本地 paper-only order intent value model | 不等于真实订单请求 |
| `Paper Order Lifecycle` | 本地 paper order 状态证据 | 不等于交易所订单生命周期 |
| `Simulated Fill Evidence` | deterministic simulated fill 研究证据 | 不等于 broker fill 或 execution report |
| `Portfolio Projection` | 从 paper-only evidence 派生的组合观察面 | 不等于真实账户余额或 broker position |
| `Paper Workflow Control Shell` | session-level `start` / `pause` / `close` / `reset` 本地控制壳 | 不允许 submit / cancel / replace |

## Market Replay Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data Batch` | 本地 public read-only fixture / batch replay 输入集合 | 不绑定真实历史下载规模 |
| `Replay Run` | 一次本地 deterministic replay 的 metadata 和 evidence | 不等于生产调度任务 |
| `Retention Policy` | 本地 batch 是否保留 / 过期 / stale 的最小证据规则 | 不等于云端 archive 或 storage tiering |
| `Freshness Evidence` | Report / Dashboard / Event Timeline 可消费的 freshness read model | 不暴露 adapter 或 schema |
| `Fixture Parity` | mock transport / fixture 与 decoder / replay contract 的一致性验证 | 不依赖真实 Binance 网络 |

## Forbidden Terms / 当前禁用或必须带门禁语义的词

以下词在当前 construction scope 中必须带上 `Future`、`gated` 或 `forbidden` 语义。中文写法也必须表达“未来建设区 / 受门禁保护 / 当前禁止”，不能写成当前已具备能力：

- Live trading
- API key
- secret storage
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- execution venue connection
- real order submit / cancel / replace
- real order lifecycle
- execution report
- broker fill
- order reconciliation
- OMS
- real account balance
- broker position sync
- production deployment / runtime operations

## 维护规则

- 新 Linear Project 规划前，`@001 / PLN` 必须读取本文档，避免 issue title / body 使用漂移术语。
- `@002 / PAR` 做 Stage Code Audit 和 Root Docs Refresh Gate 时，如发现 root docs、PR 或 validation evidence 中出现术语漂移，应记录为 Root Docs Delta。
- Codex Execution Agent 新增 public type / protocol / actor / service 时，应优先复用本文档中的领域词命名，并在中文注释中保持同一语义。
- 临时 planning note、implementation detail 和代码文件清单不得写入本文档。
