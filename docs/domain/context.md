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

`MTP-98-PAPER-PRETRADE-RISKENGINE-TERMS`

以下术语由 MTP-98 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only pre-trade risk language。它们只用于本地 sandbox proposal risk decision、blocker evidence、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 live risk engine、真实账户读取、broker position sync、margin、leverage、real pre-trade allow / reject runtime、circuit breaker、stop trading、emergency stop、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Paper Pre-trade RiskEngine` | Core 层本地 paper-only runtime path，把 paper proposal、paper account snapshot、paper exposure 和 deterministic paper risk rules 转成 accepted / rejected paper risk decision | 不等于 live risk engine、真实账户风控、broker rejection 或 future live risk decision |
| `paper account snapshot` | 本地 sandbox available paper balance 证据，只用于 MTP-98 paper risk 输入 | 不读取 account endpoint、真实账户余额、broker position、margin 或 leverage |
| `paper risk rule` | deterministic paper risk rule，例如 max paper quantity、max paper notional、max paper gross exposure 和 available paper balance | 不等于交易所风控、broker-side throttling、真实 pre-trade policy 或 production risk config |
| `accepted paper risk decision` | 当前 paper proposal 在 deterministic rules 下通过，只允许作为 paper-only decision 写入 `.risk` event evidence | 不授权真实订单、real submit、future live risk allowed 或 broker action |
| `rejected paper risk decision` | 当前 paper proposal 被 deterministic rules 阻断，并携带 paper-only `RiskBlockerEvidence` | 不等于 broker rejection、future live risk blocked、circuit breaker、no-trade state 或 stop control |
| `PaperPreTradeRiskEnginePublication` | MTP-98 rejected decision 经 MTP-97 routing 写入 `MessageBus` 后的 route evidence 与 replay evidence 对照 | 不暴露 Runtime object、Persistence schema、adapter object、broker acknowledgement 或 UI command |
| `paper risk no live account / broker upgrade` | paper risk blocker、paper exposure 和 paper account snapshot 必须保持本地 sandbox 语义 | 不得升级为真实账户 exposure、broker position、margin / leverage、real pre-trade allow / reject、future live risk decision 或交易按钮 |

`MTP-99-PAPER-LOCAL-LIFECYCLE-TERMS`

以下术语由 MTP-99 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only local lifecycle language。它们只用于本地 lifecycle coordinator、local order transition fact、simulated fill 前置状态、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、单笔 order cancel button、order-level command UI、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `paper-only lifecycle coordinator` | Core 层本地 paper lifecycle value orchestration，消费 MTP-98 accepted / rejected paper risk decision 并输出 local lifecycle transition fact | 不叫 OMS，不等于 broker router、execution engine、真实订单状态机或 Runtime actor |
| `PaperOrderLocalLifecycleState` | 本地 paper order lifecycle 状态集合：proposed、submitted local、accepted local、rejected by paper risk、cancelled local、expired local、failed local | 不等于 exchange accepted、broker submitted、broker filled、真实 cancel 或真实 rejected |
| `PaperOrderLocalLifecycleTransition` | 写入 `.paper` stream 的 append-only local lifecycle transition fact，带 order、proposal、risk decision、from / to state、trigger 和 source sequence | 不暴露 broker acknowledgement、execution report、Persistence schema 或 UI command |
| `cancelled local` | 只能来自 session close / reset、local expiry 或 deterministic local rule 的本地取消结果 | 不等于用户单笔撤单、broker cancel、exchange cancel 或 real cancel command |
| `accepted local` | 本地 deterministic rule 下满足 simulated fill 前置条件的状态 | 不等于 exchange accepted、broker accepted、真实订单可成交或执行授权 |
| `PaperOrderSimulatedFillPrecondition` | 证明 accepted local 已写入 event fact、后续 MTP-100 可以消费的 simulated fill 前置证据 | 不生成 simulated fill，不计算 fee / slippage，不表示 broker fill、execution report 或 reconciliation |

`MTP-99-NO-OMS-BROKER-REAL-CANCEL`

MTP-99 的 local lifecycle evidence 不得升级为 OMS、broker adapter、real order state machine、真实 submit / cancel / replace、execution report、broker fill、reconciliation、单笔 order cancel button、order-level command UI、live command、order form 或交易按钮。

`MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-TERMS`

以下术语由 MTP-100 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only simulated fill / fee / slippage language。它们只用于 deterministic market snapshot、fill assumption、partial / full simulated fill evidence、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、broker / signed endpoint / account endpoint 或真实账户更新。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `PaperSimulatedFillMarketSnapshot` | simulated fill model 的本地 market-side 输入，只保存 fixture / replay bid、ask、last price 和 source anchor | 不等于 Adapter payload、live market stream、signed endpoint、account endpoint、broker stream 或 execution report |
| `PaperSimulatedFillCompletion` | simulated fill 的 deterministic completion 分类：`full` 或 `partial` | 不等于真实成交状态、broker partial fill 或交易所撮合结果 |
| `PaperSimulatedFillPriceSource` | fill price assumption 的本地来源：order reference、market last price、best bid 或 best ask | 不等于真实成交价格发现、动态滑点模型或执行成本优化 |
| `PaperSimulatedFillEvidence` | paper-only simulated fill、fee、slippage 和 cost impact 的可 replay 证据 | 不等于真实 fill、broker fill、execution report、account update 或 reconciliation |
| `PaperSimulatedFillEventLogBoundary` | 复用 MTP-97 routing 将 simulated fill evidence 写入 `.paper` Event Log 的 Core 边界 | 不等于 Runtime actor、broker event bus、OMS 或外部 pub/sub |
| `PaperSimulatedFillReplayPath` | 从 append-only replay result 重建 partial / full simulated fill facts | 不等于 broker replay、account replay、incident replay 或 production recovery |

`MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION`

MTP-100 的 simulated fill evidence 不得升级为 broker fill、execution report、真实 fee statement、真实成交质量分析、live reconciliation、real account balance update、signed endpoint、account endpoint、broker action、Live PRO Console、live command、order form 或交易按钮。

`MTP-101-PAPER-ACCOUNT-PORTFOLIO-PROJECTION-TERMS`

以下术语由 MTP-101 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper account /
portfolio / position projection v2 language。它们只用于 replayed simulated fill -> projection ->
read model 的本地 sandbox 账本，不授权真实账户、broker position、margin、leverage、real PnL、
live risk runtime、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `paper account projection v2` | 从 replayed simulated fill、fee / slippage cost impact 和 starting cash 推导的本地 sandbox account snapshot | 不等于 real account balance、account endpoint payload 或 broker statement |
| `paper position projection v2` | 从 replayed simulated fills 聚合 symbol / timeframe net quantity、average entry、last fill price、market value 和 cost basis | 不等于 broker position、margin position、leverage position 或真实持仓同步 |
| `paper portfolio projection v2` | 组合 account、positions、exposures 和 PnL summary 的 MTP-101 read model source | 不等于真实 portfolio、OMS state、broker sync 或 Live fallback |
| `paper PnL summary` | 基于本地 simulated fill cost impact、position market value 和 cost basis 的 realized / unrealized / net paper PnL | 不等于 real PnL、fee statement、margin PnL 或税务 / 对账结果 |
| `replayed simulated fill projection` | projection 只能从 Event Log replay result 中的 `.paper.simulatedFillRecorded` facts 派生 | 不直接读取 risk decision、Runtime object、SQLite schema、adapter payload、broker state 或真实账户 |
| `MTP-101 read model consumption` | Persistence / App / Dashboard / Report / Risk / Portfolio 只能消费 read model / ViewModel | 不暴露 database schema、Runtime object、adapter request、position command 或交易按钮 |

`MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`

MTP-101 的 paper account / portfolio / position projection v2 不得升级为真实账户余额、broker
position sync、margin、leverage、real PnL、live risk runtime、account endpoint、signed endpoint、
broker action、Live PRO Console、live command、order form、position command 或交易按钮。

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

## Data Catalog / Scenario Replay Terms

`MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`

以下术语由 MTP-103 定义为 `MTPRO Data Catalog / Scenario Replay v1` 的 local-first、deterministic、versioned scenario replay 语言。它们只用于 Data Engine、State & Persistence Engine 和 Workbench Interface 的边界合同、source docs anchors、validation anchors 和后续 issue 的共同语言，不授权当前 scope 实现 manifest parser、fixture 数据、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `local data catalog` | 本地 scenario replay 输入身份、版本和证据锚点目录语言 | 不等于 production data platform、cloud data lake 或大型 ingestion pipeline |
| `scenario replay` | 从本地 versioned input 重建 deterministic evidence 的后续路径 | 不等于 production recovery、broker replay、account replay 或 live runtime resume |
| `scenario manifest` | 后续 issue 的输入身份合同名称 | 当前不解析 manifest，不定义最终字段 parser |
| `scenario id` | 后续 scenario replay 的稳定场景标识 | 不等于 database primary key、runtime job id、broker order id 或真实订单 id |
| `dataset version` | 后续 replay 输入数据版本 | 不等于 production dataset registry 或云端数据湖版本 |
| `fixture version` | 后续 deterministic fixture 的本地版本 | 当前不新增 fixture 数据 |
| `replay window` | 后续 replay 的本地时间 / 序列窗口 | 当前不实现 cursor 或 historical downloader |
| `replay cursor` | 后续回放位置证据 | 当前不实现 cursor runtime |
| `checksum evidence` | 后续完整性 / parity 证据 | 当前不计算新 checksum |
| `data quality gate` | 后续 scenario replay 数据质量判定分类 | 不等于 production data observability 或自动修复平台 |
| `report input versioning` | 后续 Report / Backtest / future Simulated Exchange 输入追溯合同 | 当前不实现 report input versioning runtime |
| `Workbench scenario replay evidence` | 后续 Workbench / Report / Events 只读展示面输入 | 不做 UI command、query language、schema exposure、adapter request 或 Runtime object exposure |

`MTP-103-FORBIDDEN-CAPABILITY-BASELINE`

MTP-103 的 forbidden baseline 必须覆盖 signed endpoint、account endpoint、listenKey、secret read、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、trading button、production data platform、large-scale ingestion pipeline、real network download、Graphify update 和 Figma change。

`MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`

MTP-104 把 `scenario manifest` 从术语推进为 Core value contract，但仍只表达本地输入身份，不解析 manifest 文件，不新增 fixture data，也不实现 replay cursor。最小字段为 `scenario id`、`dataset version`、`symbol`、`timeframe`、`source anchor` 和 `single-symbol / single-timeframe` scope。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioID` | 本地 scenario replay 的稳定场景标识 | 不等于 database primary key、runtime job id、broker order id 或真实订单 id |
| `DatasetVersion` | 本地 replay 输入数据版本 | 不等于 production dataset registry、cloud data lake version 或外部 catalog service version |
| `ScenarioManifest` | 绑定 scenario id、dataset version、symbol、timeframe、source anchor 和 scope 的 Core 输入身份合同 | 不等于 manifest parser、fixture data、production catalog service 或 report UI |
| `ScenarioManifestDeterministicSerialization` | 固定字段顺序的 deterministic serialization evidence | 不计算 checksum，不暴露 SQLite / DuckDB schema、adapter payload 或 Runtime object |
| `single-symbol / single-timeframe` | MTP-104 first scenario 的唯一允许 scope | 不授权 multi-symbol / multi-timeframe catalog |

`MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`

MTP-104 manifest 必须保持 database schema exposure、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、order command、live runtime、production dataset registry、real network download、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`

MTP-105 把 MTP-104 manifest 绑定到第一个本地 deterministic scenario fixture。该 fixture 只包含 BTCUSDT / 1m 的本地 public-read-only `MarketBar` records、`fixture-v1`、fixed window、fixed record order 和 deterministic summary pre-structure；不代表真实历史下载规模、production ingestion、data lake、adapter request、replay cursor、final checksum evidence、freshness evidence、data quality gate 或 report input versioning runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `FixtureVersion` | 本地 fixture record set 的稳定版本身份 | 不等于 dataset version、production dataset registry 或 cloud data lake version |
| `DeterministicScenarioFixture` | first scenario 的 Core fixture，绑定 manifest、fixture version、source anchors、records 和 validation anchors | 不等于 manifest parser、historical downloader、production data platform 或 Runtime job |
| `ScenarioFixtureRecord` | fixture 内固定 sequence 的 public market data record | 不等于 exchange sequence、broker sequence、event log sequence 或 replay cursor |
| `ScenarioFixtureDeterministicSummary` | record count、fixed window、ordered starts、record order identity、canonical summary 和 checksum preimage 的前置结构 | 不等于 MTP-106 final checksum、freshness verdict、data quality gate 或 report input versioning |
| `Binance public read-only local fixture` | first scenario 与既有 public read-only / local replay evidence 的关系锚点 | 不等于真实 Binance 网络下载、signed endpoint、account endpoint / listenKey 或 broker feed |

`MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`

MTP-105 fixture 必须保持 required validation 不依赖网络，且 real network download、production ingestion pipeline、cloud data lake、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、live command、trading button、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-106-DETERMINISTIC-REPLAY-WINDOW`

MTP-106 把 MTP-105 fixture 推进为本地 scenario replay evidence。`ScenarioReplayWindow` 继承 MTP-105 fixed window `1704067200...1704067380`、record sequence `1,2,3`、record order identity 和 MTP-104 source identity；它只表达 historical replay window，不等于 historical downloader、production retention window、Runtime job 或 broker/account replay window。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioReplayWindow` | 本地 deterministic scenario replay 的时间窗口和 record order identity | 不等于 downloader policy、production scheduler window 或 broker/account replay |
| `ScenarioReplayCursor` | 本地 fixture record progress，默认 next sequence 为 `1`，completed 为 `4` | 不等于 event log sequence、exchange sequence、broker sequence、job offset 或 live resume token |
| `ScenarioReplayCursorSummary` | cursor identity、window identity、next sequence、consumed count、total count 和 state 的稳定摘要 | 不暴露 Runtime object、adapter request、SQLite / DuckDB schema 或 UI command |
| `ScenarioReplayChecksumEvidence` | MTP-105 checksum preimage 的 final FNV-1a checksum evidence | 不等于 production data quality platform、真实下载校验或 reconciliation |
| `ScenarioReplayFreshnessEvidence` | 固定 evaluatedAt、age 和 freshness status 的本地 fixture freshness evidence | 不执行 retention cleanup、cloud archive、storage tiering 或 downloader |
| `ScenarioReplayEvidence` | replay window、cursor、checksum、freshness 和 forbidden capability flags 的聚合证据 | 只供后续 quality gate / read model 消费，不实现 MTP-107 或 MTP-108 |

`MTP-106-CHECKSUM-PARITY-EVIDENCE`

MTP-106 final checksum 固定为 `fnv1a64:3c6cd4ff13cd4062`，算法为 `fnv1a64`，输入为 MTP-105 canonical checksum preimage。checksum evidence 必须保持 source identity、record order identity、canonical preimage 和 checksum 一致；初始化和 Codable 解码不能恢复 checksum drift、record order drift 或 parity flag drift。

`MTP-106-FIXTURE-FRESHNESS-EVIDENCE`

MTP-106 fixture freshness policy 只定义本地 freshness 阈值：stale after `300` seconds、expires after `900` seconds。默认 evaluatedAt 为 `1704067500`，相对 replay window end `1704067380` 的 age 为 `120` seconds，status 为 `fresh`。该 evidence 不执行 production retention engine，不授权 cloud archive，不暴露 storage tiering，不依赖真实网络。

`MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`

MTP-106 replay evidence 必须保持 required validation network dependency、real network download、production retention engine、large-scale ingestion pipeline、production data platform、database schema exposure、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、report input versioning runtime、data quality gate runtime、live runtime、live command 和 trading button flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-107-DATA-QUALITY-GATE-TAXONOMY`

MTP-107 把 MTP-106 replay evidence 推进为本地 data quality gate 和 report input versioning contract。Data quality gates 只服务 local scenario replay 与 report reproducibility，不等于 production data observability、automatic download / repair、broker/account reconciliation 或 Simulated Exchange / Backtest Parity runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioDataQualityGateKind` | record order、window coverage、checksum match、freshness status、missing data、duplicate data 六个最小 gate | 不等于生产监控规则、自动修复规则或外部数据平台策略 |
| `ScenarioDataQualityGateEvaluation` | 基于 MTP-106 replay evidence 生成 deterministic quality verdict 的 Core 值对象 | 不启动 Runtime，不读取 schema，不自动下载 / 修复数据 |
| `ScenarioDataQualityVerdict` | `accepted`、`marked`、`rejected` 三类 report input 质量结论 | 不等于 production SLA、broker reject 或 live risk decision |
| `ScenarioReportInputVersion` | 把 scenario id、dataset version、fixture version、replay window、checksum、freshness 和 quality verdict 固定成 report input identity | 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、broker payload 或真实账户资料 |
| `ScenarioDataQualityReportInputEvidence` | 绑定 replay evidence、quality gates 和 report input version 的 MTP-107 聚合证据 | 只供后续 read-model evidence 消费，不实现 Workbench UI、不输出 stage audit input |

`MTP-107-REPORT-INPUT-VERSIONING`

MTP-107 report input versioning 必须可从 `ScenarioReplayEvidence` 追溯到同一 scenario id、dataset version、fixture version、replay window、checksum 和 freshness status；`versionIdentity` 必须包含 quality verdict。该 contract 是 stable Core value contract，不是 report runtime、database schema、adapter request 或 Runtime object。

`MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`

MTP-107 quality / report input evidence 必须保持 required validation network dependency、production data platform、production data observability、automatic download、automatic repair、broker / account reconciliation、Simulated Exchange / Backtest Parity implementation、database schema exposure、adapter request exposure、Runtime object read、secret read、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command 和 trading button flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`

MTP-108 scenario replay read-model evidence 指 App 层只读聚合：它把 MTP-106 replay window / cursor / checksum / freshness 与 MTP-107 quality verdict / report input version identity 复制到 `ScenarioReplayEvidenceReadModel` 和 `ScenarioReplayEvidenceViewModel`。该术语只表示展示面 evidence，不表示 Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Workbench scenario replay summary` | Workbench 中的 scenarios、quality gates、report inputs 和 quality verdict 只读指标 | 不等于 replay control、download console、query editor 或交易入口 |
| `Scenario replay drill-down entry` | 展示 scenario id、dataset version、fixture version、replay window、checksum、freshness、quality verdict 和 report input version identity 的只读 detail | 不等于 schema inspector、Runtime object inspector、Adapter request log 或 broker payload |
| `Quality gate timeline` | Events / Evidence Explorer 中的 record order、window coverage、checksum match、freshness status、missing data、duplicate data verdict rows | 不等于 production data observability、automatic repair、broker/account reconciliation 或 Simulated Exchange runtime |
| `Report input version surface` | Report / Dashboard ViewModel 中可编码展示的 report input version identity | 不等于 report runtime、database migration、SQL query 或 production data platform |

`MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-108 App surface 必须保持 read-model-only：Dashboard、Workbench、Report 和 Events 只能消费 `ScenarioReplayEvidenceReadModel` / `ScenarioReplayEvidenceViewModel`，不能提供 command surface、order-level command、query language、live command、trading button、broker action、live trading authorization 或 trading execution authorization。

## Simulated Exchange / Backtest Parity Terms

`MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`

以下术语由 MTP-110 定义为 `MTPRO Simulated Exchange / Backtest Parity v1` 的 L2 deterministic simulation 语言。它们只用于 Simulation / Backtest Engine、paper-only / simulated Execution Engine、Portfolio Engine、Data Engine、State & Persistence Engine 和 Workbench Interface 的边界合同、source docs anchors、validation anchors 和后续 issue 的共同语言，不授权当前 scope 实现 matching runtime、order execution runtime、portfolio projection runtime、UI、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、Live PRO Console、live command、trading button、emergency stop、shutdown 或 restore。

| 术语 | MTPRO 含义 | 避免混用 |
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

`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`

MTP-110 固定六类目标引擎职责：`Simulation / Backtest Engine`、`Execution Engine (paper-only / simulated)`、`Portfolio Engine`、`Data Engine`、`State & Persistence Engine` 和 `Workbench Interface`。这些职责只表达 L2 parity 共同语言，不实现 matching runtime、order execution runtime、portfolio projection runtime 或 UI。

`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`

MTP-110 handoff boundary 只把 L1 Paper Runtime 的 paper-only execution evidence 和 L1.5 Data Catalog / Scenario Replay 的 deterministic scenario input identity 连接到 L2 terminology。它不表示真实交易所、live readiness、production trading engine、broker / OMS、signed endpoint、account endpoint / listenKey 或 Live PRO Console 已进入当前 scope。

`MTP-110-FORBIDDEN-CAPABILITY-BASELINE`

MTP-110 的 forbidden baseline 必须覆盖 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、emergency stop / shutdown / restore、Graphify update 和 Figma change。

`MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`

MTP-111 把 `shared backtest-paper order semantics` 从 MTP-110 的术语入口推进为 Core value contract。它只定义 paper order intent 与 backtest replay order input 的共享字段：input id、order id、source paper order intent id、proposal id、session id、scenario id、dataset version、fixture version、symbol、timeframe、side、quantity、reference price、notional amount、source risk decision sequence、source replay sequence 和 recorded at。这些字段只服务 deterministic simulation / backtest replay，不等于 broker order id、exchange order id、real order command、order form、OMS state 或真实订单生命周期。

`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`

MTP-111 固定 shared simulated order state taxonomy：`intent recorded`、`submitted simulated`、`accepted simulated`、`rejected simulated`、`expired simulated`、`cancelled local only`、`failed local only`、`filled simulated` 和 `partially filled simulated`。这些状态只能表达 paper-only / simulated evidence；`accepted simulated` 不等于 exchange accepted，`rejected simulated` 不等于 broker rejection，`filled simulated` / `partially filled simulated` 不等于 broker fill、execution report 或真实成交质量，`cancelled local only` 不等于 real cancel command。

`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`

MTP-111 固定 paper lifecycle 与 backtest replay 的对齐：`PaperOrderLifecycleState.intentCreated` 映射为 `intent recorded`，`PaperOrderLifecycleState.rejectedByRisk` 映射为 `rejected simulated`，`PaperOrderLocalLifecycleState.submittedLocal` / `acceptedLocal` / `rejectedByPaperRisk` / `expiredLocal` / `cancelledLocal` / `failedLocal` 分别映射为 submitted / accepted / rejected / expired / local-cancelled / local-failed simulated evidence，`PaperSimulatedFillCompletion.full` 映射为 `filled simulated`，`partial` 映射为 `partially filled simulated`。scenario id、dataset version、fixture version、symbol 和 timeframe 必须与 L1.5 scenario replay input identity 对齐。

`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`

MTP-111 shared order semantics 不得升级为 matching runtime、order execution runtime、portfolio projection runtime、real order command、real order lifecycle、real submit / cancel / replace、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI、trading button 或 emergency stop / shutdown / restore。

`MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`

MTP-112 把 scenario replay window / cursor、dataset version、fixture version、local market state、checksum / freshness evidence 和 MTP-111 shared order input 串成 deterministic matching input。默认 fixture 固定 scenario id `mtp-104-btcusdt-1m-first-scenario`、dataset version `dataset-v1`、fixture version `fixture-v1`、window `1704067200...1704067380`、cursor / record sequence `2`、freshness `fresh` 和 checksum `fnv1a64:3c6cd4ff13cd4062`。这些输入只来自本地 deterministic fixture / scenario replay，不等于真实 order book、broker feed、live stream 或 production replay job。

`MTP-112-DETERMINISTIC-MATCHING-ORDERING`

MTP-112 matching ordering 只使用 scenario identity、dataset / fixture version、replay window、cursor sequence、fixture record order、shared order input tie-break 和 append-only simulated event output；不得使用 wall clock、randomness、真实网络、exchange priority、broker routing 或 production scheduler。

`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`

MTP-112 输出 `simulated exchange order matched` event，默认 matched record sequence 为 `2`、matched price 为 `42120.70`、matched quantity 为 `0.5`，shared order state 为 `filled simulated`，shared event kind 为 `simulated order filled`。该 event 只表达 simulated exchange matching output，不等于 broker fill、execution report、真实成交、account update、portfolio projection 或 reconciliation 输入。

`MTP-112-REPEATABLE-MATCHING-OUTPUT`

MTP-112 必须保证相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 可重复输出同一个 deterministic result identity：`mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|price=42120700000|quantity=500000`。

`MTP-112-NO-NETWORK-BROKER-LIVE`

MTP-112 deterministic matching model 不得升级为真实 matching runtime、market / limit execution runtime、partial fill / latency / fee / slippage runtime、portfolio projection runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`

MTP-113 market order simulated execution 只表示 accepted simulated shared order input 使用 MTP-112 deterministic matching output 的 matched price 立即 full fill。默认 fixture 使用 matched price `42120.70`、quantity `0.5`、shared state `filled simulated` 和 event kind `simulated order filled`。它不等于真实 market order、exchange order book execution、broker route、execution report、broker fill、account update 或 live order。

`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`

MTP-113 limit order simulated execution 只定义当前 shared order side 中 buy-side 的最小 limit rule：explicit limit price 大于等于 deterministic matched price 时 full fill，低于 matched price 时输出 `expired simulated` evidence。默认 fill fixture 的 limit price 为 `42150.00`；expire fixture 的 limit price 为 `42100.00`。它不实现 sell / short、stop、OCO、post-only、maker/taker routing、price-time priority 或真实交易所订单过期。

`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`

MTP-113 固定三种最小 simulated execution outcome：`full fill simulated` 映射到 `filled simulated` / `simulated order filled`；`rejected simulated` 映射到 `rejected simulated` / `simulated order rejected`，用于 rejected initial state 或 non-executable hold side 在 fill 前停止；`expired simulated` 映射到 `expired simulated` / `simulated order expired`，用于 buy limit 未穿越 deterministic matched price。MTP-113 不输出 partial fill，partial fill、latency、fee / slippage parity 仍归属 MTP-114。

`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`

MTP-113 必须保证相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input / order type / limit price / initial state 输出同一个 deterministic execution result identity。limit expire fixture 的 identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=limit order simulated execution|limit=42100000000|initialState=accepted simulated|outcome=expired simulated|matchedPrice=42120700000|filled=0|remaining=500000`。

`MTP-113-NO-REAL-ORDER-LIVE-COMMAND`

MTP-113 market / limit simulated execution semantics 不得升级为真实 order execution runtime、matching runtime、portfolio projection runtime、advanced order types、真实 submit / cancel / replace、OMS、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-114-PARTIAL-FULL-FILL-PARITY`

MTP-114 partial / full fill parity 只表示 deterministic simulated exchange evidence：当 `availableSimulatedLiquidity` 小于 order quantity 时输出 `partial` / `partially filled simulated` / `simulated order partially filled`，并显式保留 remaining quantity；当 available liquidity 等于 order quantity 时输出 `full` / `filled simulated` / `simulated order filled`。`availableSimulatedLiquidity` 是 fixture cap，不是真实盘口深度、真实流动性消耗、broker quote、account position、margin 或 leverage。

`MTP-114-DETERMINISTIC-LATENCY-MODEL`

MTP-114 latency model 只使用 replay record sequence 和固定 tick offset。默认 fixture 从 matched record sequence `2` 延迟 `1` 个 deterministic tick 到 output sequence `3`，并记录 `250ms` 的本地 evidence。它不等于 wall clock、真实网络延迟、exchange latency、broker SLA、production telemetry 或自动优化信号。

`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`

MTP-114 fee / slippage parity 复用 MTP-27 fixed cost assumptions：maker fee `2 bps`、taker fee `5 bps`、slippage `1.5 bps`、rounding scale `8`。Backtest 与 Paper 用同一 matched price、filled quantity、liquidity role 和 fixed assumptions 生成一致 `ExecutionCostEstimate`，再用 `ExecutionCostParity.verify` 验证一致。它不是真实费率表、VIP tier、symbol-specific fee、broker fee statement、动态滑点模型、真实成交质量或执行成本优化。

`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`

MTP-114 必须保证相同 MTP-113 execution input、available simulated liquidity、latency assumption、liquidity role 和 MTP-27 cost assumption 输出同一个 deterministic report identity。默认 partial fixture identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=market order simulated execution|limit=none|initialState=accepted simulated|availableLiquidity=250000|latencyAssumption=mtp-114-deterministic-latency-assumption|latencySource=2|latencyOutput=3|liquidityRole=taker|costAssumption=mtp-27-fixed-cost-assumptions|fill=partial|latencyMs=25000000000|latencyRecord=3|filled=250000|remaining=250000|fee=526508750|slippage=157952625|totalCost=684461375`。

`MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`

MTP-114 partial fill / latency / fee / slippage parity 不得升级为 real fee schedule、dynamic slippage model、real liquidity consumption、execution cost optimization、signed endpoint、account endpoint、listenKey、broker integration、broker fill、execution report、reconciliation、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、portfolio projection runtime、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`

MTP-115 simulated event to portfolio projection 只表示 deterministic simulated exchange parity event 到 value-object portfolio projection 的映射：输入来自 MTP-114 report evidence、MTP-107 report input version 和 replay latency output sequence `3`，输出 backtest / paper 两侧的 position、cash、PnL 和 exposure summary。它不等于 portfolio projection runtime、real account sync、broker position sync、account endpoint read 或 persistence schema read。

`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`

MTP-115 backtest / paper portfolio parity 要求两侧 projection 共享同一个 source event、report input identity、source replay sequence、filled quantity、matched price、fee、slippage 和 starting cash，并输出完全相同的 `parityComparableIdentity`。默认 partial fixture 固定 filled quantity `0.25`、matched price `42120.70`、gross exposure `10530.175`、cash `39462.98038625`、equity `49993.15538625`、net simulated PnL `-6.84461375`。

`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`

MTP-115 position / cash / PnL / exposure summary 只包含 net quantity、average entry price、last fill price、position market value、cost basis、fee、slippage、cost impact、cash、available simulated cash、equity、gross exposure、realized / unrealized / net simulated PnL 和 `PortfolioExposureSnapshot`。这些字段是 report / validation evidence，不是真实账户资产、broker statement、margin、leverage、risk limit 或 trading command state。

`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`

MTP-115 report input / replay evidence 必须绑定 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`，并在 deterministic identity 中保留 MTP-114 report identity、`startingCash=5000000000000` 和 `sourceReplaySequence=3`。该 evidence 证明 projection 从 replayed simulated fill fact 派生，而不是从 live state、database console 或 Runtime object 派生。

`MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`

MTP-115 simulated exchange portfolio projection parity 不得升级为 real account balance read / sync、broker position read、margin read、leverage read、broker reconciliation、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、交易按钮、database schema exposure、runtime object read 或 network-dependent validation。

`MTP-116-PARITY-EVIDENCE-READ-MODEL`

MTP-116 parity evidence read model 指 App 层对 MTP-112 至 MTP-115 deterministic parity facts 的只读复制：scenario id、dataset version、fixture version、replay window、matching result、fill summary、reject / expire outcome、latency、fee / slippage、portfolio projection parity、report input version identity 和 replay sequence。它不等于 matching runtime、order execution runtime、portfolio projection runtime、database console 或 command model。

`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`

MTP-116 Report / Dashboard / Events parity surface 指 Report、Dashboard Shell、Workbench 和 Evidence Explorer 对 `SimulatedExchangeParityEvidenceReadModel` 的只读展示：Report 显示 evidence count 和 deterministic fields，Dashboard / Workbench 显示 parity evidence / outcomes / timeline / portfolio parity / cost parity metrics，Events 新增 `simulated exchange parity evidence` timeline section。该 surface 不提供 order form、query language、order-level command UI、live command、trading button 或 trading execution authorization。

`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`

MTP-116 默认 snapshot 必须把同一个 scenario `mtp-104-btcusdt-1m-first-scenario`、dataset `dataset-v1`、fixture `fixture-v1`、replay window `1704067200...1704067380`、matching event `mtp-112-simulated-exchange-order-matched`、partial / full / rejected / expired simulated outcomes、latency `250ms`、fee `5.2650875`、slippage `1.57952625`、gross exposure `10530.175` 和 net simulated PnL `-6.84461375` 作为 read-model evidence 呈现，证明 projection 从 replayed simulated fill fact 派生。

`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-116 read-model-only boundary 要求所有 Report / Dashboard / Events parity evidence 只消费 App ViewModel，不读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload 或 live state；Codable decode 也不能恢复 command surface、order-level command、Live PRO Console、交易按钮或真实交易授权。

`MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`

MTP-116 parity evidence surface 必须保持 signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、database schema exposure、Runtime object exposure、adapter request exposure、live runtime 和 network-dependent validation 全部为 false。

## Workbench Beta Readiness Terms

`MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`

以下术语由 MTP-118 定义为 `MTPRO Workbench Beta Readiness v1` 的 L2+ local Workbench beta language。它们只用于 Workbench beta readiness contract、acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 / L2+ handoff boundary、forbidden capability baseline 和 validation anchors，不授权当前 scope 实现 install / run 逻辑、engine core capability、release package、production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Workbench beta readiness` | L2+ maturity slice 的本地 macOS Workbench demo / acceptance 准备度 | 不等于 production release、live readiness、notarization、App Store release 或 production operations |
| `beta acceptance path` | operator 后续按固定本地路径验收 Workbench demo 的证据链 | 当前不实现 launch / install / run 逻辑，不替代 `bash checks/run.sh` |
| `local macOS Workbench demo` | 只在本机 macOS Workbench 展示 L1 / L1.5 / L2 已完成 evidence 的 demo 目标 | 不等于 cloud service、Live PRO Console、production deployment 或真实交易工作台 |
| `demo workflow` | 后续 issue 逐步固定 demo scenario、first-run state、Report / Dashboard / Events evidence 和 checklist 的流程语言 | 当前不选择 fixture、不写启动脚本、不新增 UI 或 runtime behavior |
| `acceptance boundary` | beta readiness 验收必须保持 local-only、read-model-only、no live / broker / signed / account / OMS / trading button | 不授权下一 issue 自动执行，不授权 live / broker / production release |
| `local-only beta definition` | beta readiness 只代表本地可演示 / 可验收，不代表生产发布或 live 准入 | 不等于 production installer、auto-update、notarized build 或 real account readiness |

`MTP-118-BETA-ACCEPTANCE-BOUNDARY`

MTP-118 beta acceptance boundary 要求 Workbench beta readiness 只表示 local macOS Workbench demo / acceptance path。它必须保持 evidence-first、read-model-only 和 local-only，不得变成 production release、live readiness、cloud deployment、Runtime command surface、order form、trading button、Live PRO Console、signed endpoint、account endpoint、listenKey、broker payload、OMS 或真实交易授权。

`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`

MTP-118 只定义 local-only beta demo path 的验收语言。MTP-119 至 MTP-125 后续 issue 才能分别处理 local launch / install / environment verification、demo scenario / fixture wiring、first-run default demo state、Report / Dashboard / Events acceptance path、reproducible beta checklist / script、docs index / operator guide 和 stage audit input material；MTP-118 不提前实现这些后续 issue。

`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`

MTP-118 把 L1 Paper Runtime、L1.5 Data Catalog / Scenario Replay 和 L2 Simulated Exchange / Backtest Parity 的已完成 deterministic evidence 连接到 L2+ Workbench Beta Readiness 的 local demo / acceptance boundary。该 handoff 不表示 production trading engine、production data platform、production matching runtime、真实 exchange runtime、broker / OMS、signed endpoint、account endpoint / listenKey、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command 已进入当前 scope。

`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`

MTP-118 的 forbidden baseline 必须覆盖 engine core capability expansion、install / run implementation、release package creation、production release、notarization、App Store distribution、auto-update、production operations、API key / secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop / shutdown / restore、Graphify update 和 Figma change。

`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选。只有 Linear live-read 中经 Parent Codex queue preflight 确认为唯一 Todo / configured executable issue 的 MTP-118 才能执行；MTP-119 至 MTP-125 仍必须保持 Backlog / blocked，直到 MTP-118 独立完成 PR、required check、merge 和 Linear Done evidence 后再由 Parent Codex queue preflight 单独判断。

`MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`

MTP-119 在 MTP-118 的 local-only beta demo path 边界内定义本地 launch / install / environment verification path。这里的 install 只表示 SwiftPM 本地依赖解析和 `.build` 构建产物，不等于 production installer、notarized artifact、App Store distribution、auto-update、production deployment 或 cloud operations。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `local environment verification` | operator 在仓库根目录用 `uname -s`、`swift --version` 和 `swift package resolve` 确认 Darwin / Swift 6+ / SwiftPM dependency resolution | 不读取 API key、secret、account endpoint、listenKey、broker credential 或生产配置 |
| `local install path` | `swift build --product Dashboard` 生成本地 SwiftPM build artifact | 不等于 `.app` installer、`.pkg`、`.dmg`、notarization、App Store build、auto-update channel 或 production release |
| `local launch command` | `swift run Dashboard` 或自动 smoke 的 `DASHBOARD_SMOKE=1 swift run Dashboard` | 不等于 production deployment、cloud operations、Live PRO Console 或 live runtime |
| `Dashboard smoke expectation` | Dashboard smoke summary 必须输出 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 blocked live evidence | 不等于 UI acceptance checklist 完成，不等于 demo scenario 已选择，不等于 live readiness |
| `reproducible launch evidence` | `swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh` 的本地输出证据 | 不替代 GitHub required check，不替代后续 MTP-123 beta acceptance checklist / script |
| `launch troubleshooting boundary` | 失败排查只沿 SwiftPM dependency、Dashboard build、Dashboard smoke、`checks/run.sh` 最小失败点定位 | 不引入 signed endpoint、account endpoint、broker、OMS、real order lifecycle、Live PRO Console、live command 或 trading button |

`MTP-119-LOCAL-LAUNCH-VALIDATION`

MTP-119 required validation 是 `DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh`。该 validation 只证明 local macOS Workbench beta launch path 可复现；它不表示 production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command 已实现或获授权。

MTP-119 的英文锚点表述中，local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact，不表示发布安装或生产分发。

`MTP-120-DEMO-SCENARIO-SELECTION`

MTP-120 在 local-only beta demo path 内固定唯一 demo scenario：`mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。该选择只表示 Workbench beta demo 输入，不等于 production data catalog、production dataset registry、automatic downloader、Runtime replay job 或真实市场数据平台。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta demo scenario` | MTP-120 固定的本地 deterministic scenario id / dataset version / fixture version | 不等于 production dataset、remote catalog、真实历史数据下载任务或 live readiness |
| `demo fixture wiring` | 把 L1.5 Scenario Replay report input evidence 与 L2 Simulated Exchange / Backtest Parity evidence 绑定到同一 demo scenario | 不等于 Runtime replay job、production matching runtime、App first-run state 或 Dashboard acceptance surface |
| `demo checksum / freshness evidence` | `fnv1a64:3c6cd4ff13cd4062`、`fresh` 和 `accepted` 作为 beta demo 输入追踪证据 | 不等于 production data quality monitor、retention engine、自动修复或真实网络校验 |

`MTP-120-DATASET-FIXTURE-VERSION-LOCK`

MTP-120 固定 `dataset-v1` 和 `fixture-v1`，使后续 MTP-121 / MTP-122 / MTP-123 只能消费同一 deterministic beta fixture。该 version lock 不表示 remote sync、dataset registry、production release version 或 production operations readiness。

`MTP-120-SCENARIO-REPLAY-FIXTURE-WIRING`

MTP-120 的 wiring 由 Core 值对象 `WorkbenchBetaDemoScenarioSelection` 和 `WorkbenchBetaDemoFixtureEvidence` 表达：前者固定 selection，后者复用 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 和 `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`。该 wiring 不新增 fixture records、不触发 replay scheduler、不读取 Persistence schema、不调用 Adapter、不新增 App read model 或 Dashboard first-run state。

`MTP-120-CHECKSUM-FRESHNESS-EVIDENCE`

MTP-120 demo fixture 的 checksum / freshness / quality evidence 固定为 `fnv1a64:3c6cd4ff13cd4062`、`fresh`、`accepted`，report input version 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。

`MTP-120-L15-L2-EVIDENCE-RELATIONSHIP`

MTP-120 只记录 L1.5 Scenario Replay evidence 与 L2 Simulated Exchange / Backtest Parity evidence 的 relationship：二者共享同一 scenario / dataset / fixture / report input version，后续 L2+ Workbench Beta Readiness issue 可在 read-model-only 路径中消费。它不授权 production matching runtime、真实 exchange runtime、broker adapter、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command。

`MTP-120-NO-NETWORK-DOWNLOAD-LIVE-BROKER`

MTP-120 validation 必须证明 demo path 不依赖真实网络或自动下载，不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、live command、trading button、Graphify 或 Figma。

`MTP-121-DEFAULT-SELECTED-SCENARIO`

MTP-121 把 Workbench first-run 默认选择固定为 MTP-120 的 local deterministic beta demo scenario：`mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。该默认选择只表示本地 Workbench beta demo 启动状态，不等于 production dataset、remote catalog、Runtime replay job、live readiness 或真实交易授权。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `first-run default demo state` | Dashboard 启动后默认展示的 local beta evidence state | 不等于 UI redesign、Live PRO Console、production release 或 live readiness |
| `default selected scenario` | MTP-121 启动 snapshot 中选择的 MTP-120 deterministic scenario | 不等于用户可切换 scenario selector、remote catalog 或下载任务 |
| `first-run evidence summary` | App ViewModel 复制 scenario、dataset / fixture version、checksum、freshness、quality、report input version 和 L1.5 / L2 relationship 的只读摘要 | 不等于 Runtime replay result、Persistence schema、Core object inspector 或执行入口 |
| `first-run fallback state` | `empty` / `loading` / `error` 三个只读 fallback | 不等于 retry command、download command、repair command 或 Runtime mutation |

`MTP-121-READ-MODEL-ONLY-DASHBOARD-STATE`

MTP-121 的 first-run state 只能通过 `WorkbenchBetaFirstRunReadModel`、`WorkbenchBetaFirstRunViewModel`、`DashboardReadModel.defaultWorkbenchBetaDemo` 和 `DashboardViewModel.defaultWorkbenchBetaDemo` 进入 Dashboard。Dashboard 不直接读取 Core fixture、Persistence schema、Runtime object 或 Adapter request。

`MTP-121-FIRST-RUN-FALLBACK-STATES`

MTP-121 固定 fallback states 为 `empty`、`loading`、`error`。这些 fallback 只解释展示状态，不提供 retry / download / repair command，不读取 secret，不接 signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、Live PRO Console、live command 或 trading button。

`MTP-121-FIRST-RUN-EVIDENCE-SUMMARY`

MTP-121 first-run summary 必须保留 `checksum=fnv1a64:3c6cd4ff13cd4062`、`freshness=fresh`、`quality=accepted`、`scenarioReplayEvidence=1`、`simulatedParityEvidence=1` 和 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`。它只消费 MTP-120 fixture wiring，不新建 fixture records，不实现 MTP-122 Report / Dashboard / Events acceptance path。

`MTP-121-DEMO-FIXTURE-ALIGNMENT`

MTP-121 必须证明 first-run state 与 MTP-120 demo fixture wiring 使用同一 scenario、dataset version、fixture version、report input version 和 parity evidence identity；不得换数据源或把 demo state 写成 production data readiness。

`MTP-121-NO-LIVE-PRO-CONSOLE-TRADING-COMMAND`

MTP-121 validation 必须证明 first-run state 不新增 Live PRO Console、live command、trading button、order-level command、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、Graphify 或 Figma。

`MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY`

MTP-122 把 Report beta acceptance summary 定义为 read-model-only acceptance path summary：它从 MTP-121 first-run default demo state、MTP-108 Scenario Replay App evidence 和 MTP-116 Simulated Exchange / Backtest Parity App evidence 复制同一 demo fixture identity。执行记录：2026-05-27，Codex。该 summary 不等于 Runtime replay job、production report engine、database query surface 或 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta acceptance path` | Report / Dashboard / Events 对同一 local deterministic demo scenario 的只读验收链路 | 不等于 production release acceptance、Live readiness 或真实交易验收 |
| `Report beta acceptance summary` | Report 层展示 scenario、dataset / fixture version、report input version、quality、scenario replay 和 simulated parity evidence 的摘要 | 不等于 Runtime replay result、database schema、adapter request 或 Core object inspector |
| `Dashboard beta evidence panels` | Dashboard shell 中的 acceptance path metrics / details / smoke handles | 不等于完整 UI redesign、Live PRO Console、trading button 或 command surface |
| `Events beta acceptance trace` | Evidence Explorer 中 `workbench beta acceptance path` section 的 timeline rows | 不等于 broker event stream、execution report、account event 或 incident replay runtime |

`MTP-122-DASHBOARD-BETA-EVIDENCE-PANELS`

MTP-122 Dashboard panels 必须通过 `WorkbenchBetaAcceptancePathViewModel` 和 `DashboardShellSnapshot` 输出 `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。这些 handles 只表示 local beta evidence 可验收，不提供 scenario selector、download action、repair command、order command、live command 或交易按钮。

`MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE`

MTP-122 Events trace 必须包含 Report summary、Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、Portfolio evidence 和 boundary summary 五个 read-model-only trace rows。Trace rows 只链接已存在 evidence id，不运行 matching runtime、execution runtime、portfolio runtime、broker runtime 或 live runtime。

`MTP-122-SAME-DEMO-SCENARIO-EVIDENCE`

MTP-122 同一 demo scenario evidence 必须固定 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`、checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted` 和 report input version `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。任一 evidence source 不匹配时，acceptance path 必须为空。

`MTP-122-SCENARIO-PARITY-PORTFOLIO-TRACE`

MTP-122 scenario / parity / portfolio trace 必须同时展示 Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence 和 portfolio projection parity evidence，默认 portfolio evidence id 为 `mtp-115-simulated-exchange-portfolio-projection-parity-portfolio-parity`。它只表示 simulated evidence chain 完整，不表示真实 account balance、broker position、margin、leverage、broker fill、reconciliation 或 real account endpoint。

`MTP-122-READ-MODEL-ONLY-NO-RUNTIME-COMMAND`

MTP-122 validation 必须证明 acceptance path 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime、Persistence schema exposure、database console、Runtime object inspector、Adapter request exposure、signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、live command、trading button、order-level command UI、Graphify 或 Figma。

`MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW`

MTP-123 把 local macOS Workbench beta acceptance 固定为 operator 可复现 workflow：`checks/workbench-beta-acceptance.sh` 只运行本地环境验证、SwiftPM dependency resolution、Dashboard smoke 和 `bash checks/run.sh`。该 workflow 不等于 CI replacement、production release、notarization、App Store distribution、auto-update、production operations 或 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta acceptance checklist` | operator 按固定步骤检查 local Workbench demo、demo scenario、Report / Dashboard / Events evidence 和 boundary handles | 不等于 release checklist、production ops runbook、CI replacement 或 live readiness checklist |
| `beta acceptance script` | `checks/workbench-beta-acceptance.sh` 对既有 local commands 的薄编排和 smoke handle 校验 | 不等于 installer、deployment script、Graphify job、Figma automation 或 production operations script |
| `operator reproducibility evidence` | `.codex/beta-acceptance/<run-id>/` 下的本地 transcript | 不进入 PR，不作为 secret / account / broker evidence |
| `failure triage hints` | 只沿 SwiftPM、Dashboard smoke、automation readiness 和 `swift test` 收窄失败 | 不通过 signed endpoint、broker、LiveExecutionAdapter、OMS、Live PRO Console、trading button 或 live command 绕过失败 |

`MTP-123-BETA-ACCEPTANCE-CHECKLIST`

MTP-123 checklist 必须同时覆盖 MTP-119 launch path、MTP-120 deterministic fixture、MTP-121 first-run default demo state 和 MTP-122 Report / Dashboard / Events acceptance path。关键 handles 是 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptanceTrace=5`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`。

`MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS`

MTP-123 expected outputs 只锁定 operator acceptance 所需的稳定 smoke handles 和 `MTPRO checks passed.`；它不把 SwiftPM build noise、timing 或完整 stdout 当成领域 contract。

`MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE`

MTP-123 operator reproducibility evidence 只保存在 `.codex/beta-acceptance/<run-id>/`，用于本地 handoff 和 debug。它不得进入 PR，不得包含 secret、API key、account endpoint、listenKey、broker credential、signed request 或 production operations state。

`MTP-123-FAILURE-TRIAGE-HINTS`

MTP-123 failure triage 只能沿 `uname -s`、`swift --version`、`swift package resolve`、Dashboard smoke、`checks/automation-readiness.sh` 和 `swift test` 收窄；不得把失败升级成 Graphify refresh、Figma update、release automation、broker action、live command 或 trading button。

`MTP-123-NO-GRAPHIFY-FIGMA-PRODUCTION-OPS`

MTP-123 validation 必须证明 checklist / script 不运行 Graphify、不修改 Figma、不新增 production ops、不新增 release automation、不接 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

`MTP-124-DOCS-INDEX`

MTP-124 把 docs index 固定为 operator 的文档入口：`docs/index.md` 只帮助 Human / operator 找到 root docs、Workbench Beta Readiness docs、acceptance checklist、operator guide、demo workflow guide 和 required validation。docs index 不替代 Linear issue execution contract，不授权下一阶段 execution，不创建 production release，不表示 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `docs index` | 仓库内正式中文文档导航，指向 root docs、operator guide、demo workflow guide、acceptance checklist 和 boundary docs | 不等于 marketing landing page、release portal、production runbook 或 Linear execution contract |
| `operator guide` | local macOS Workbench beta 的本机操作手册，说明环境确认、Dashboard smoke、acceptance script、expected handles 和 failure triage | 不等于 production deployment guide、Live PRO Console docs、notarization guide 或 App Store guide |
| `demo workflow guide` | 解释 MTP-119 至 MTP-123 如何串成同一 deterministic acceptance evidence chain | 不等于 Runtime replay job、scenario selector、remote catalog、download action 或 repair command |
| `known limitations` | 明确 local Workbench beta 的限制，例如 single deterministic fixture、SwiftPM local artifact、command-line smoke summary 和 `.codex` local transcript | 不等于 roadmap promise、release blocker bypass 或 production readiness claim |
| `troubleshooting pointers` | 只沿 SwiftPM、Dashboard smoke、acceptance script、automation readiness 和 Swift tests 收窄失败 | 不通过 signed endpoint、broker、Graphify、Figma、Live PRO Console、trading button 或 live command 绕过失败 |

`MTP-124-OPERATOR-GUIDE`

MTP-124 operator guide 只服务 local Workbench beta operator。它允许 operator 运行 `bash checks/workbench-beta-acceptance.sh`、查看 stable smoke handles、阅读 `.codex/beta-acceptance/<run-id>/` 本地 transcript 和按 `bash checks/run.sh` 失败顺序排查。它不创建 release artifact，不读取 secret，不接 broker，不提供交易操作入口。

`MTP-124-DEMO-WORKFLOW-GUIDE`

MTP-124 demo workflow guide 只解释以下 evidence chain：MTP-119 local launch / install、MTP-120 deterministic fixture、MTP-121 first-run state、MTP-122 Report / Dashboard / Events acceptance path、MTP-123 reproducible checklist / script。该 workflow 不新增 Runtime job、App read model、Dashboard behavior、production data platform、Graphify update 或 Figma change。

`MTP-124-KNOWN-LIMITATIONS`

MTP-124 known limitations 必须说明 local install 只是 SwiftPM dependency resolution / `.build` artifact，Dashboard smoke 是 command-line summary，demo scenario 固定为 `mtp-104-btcusdt-1m-first-scenario`，operator transcript 只在 `.codex/beta-acceptance/<run-id>/`，stage closeout 仍归属 MTP-125。

`MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`

MTP-124 docs 必须保持 production release、notarization、App Store distribution、auto-update、production deployment、cloud operations、signed endpoint、account endpoint / listenKey、API key / secret read、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、live readiness、Live PRO Console、trading button、live command、emergency stop / shutdown / restore、Graphify update 和 Figma change 仍为 forbidden / Future Gated。

`MTP-124-TROUBLESHOOTING-POINTERS`

MTP-124 troubleshooting 只允许沿 `uname -s`、`swift --version`、`swift package resolve`、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard`、`bash checks/workbench-beta-acceptance.sh` 和 `bash checks/run.sh` 收窄失败。

`MTP-124-BETA-NOT-LIVE-READINESS`

MTP-124 必须明确 Workbench beta readiness 不等于 live readiness。它只表示 local macOS Workbench demo / acceptance path 可复现，不表示真实账户、broker readiness、Live PRO Console readiness、live runtime readiness、真实交易授权、production release 或下一阶段 execution 授权。

`MTP-124-DOCS-OPERATOR-GUIDE-VALIDATION`

MTP-124 validation 必须证明 docs index、operator guide、demo workflow guide、known limitations、forbidden capabilities、troubleshooting pointers 和 acceptance workflow references 均存在，并且 `bash checks/run.sh` 通过。

## Live Read-only Readiness Terms

`MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`

以下术语由 MTP-126 定义为 `MTPRO Live Read-only Readiness Boundary v1` 的 L3.0 boundary language。它们只用于术语、target engines / layers、future gates、forbidden capability baseline 和 validation anchors，不授权当前 scope 实现 endpoint、secret、adapter、account read model、UI 或 live runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Live read-only readiness` | 靠近真实账户只读能力前的 L3.0 准备边界，固定术语、future gates、validation anchors 和 forbidden baseline | 不等于真实账户读取、private stream、broker connection、Live Monitoring v2 或 Live Production |
| `read-only readiness boundary` | 当前 Project 只能定义 boundary / contract / forbidden baseline，不实现运行时能力 | 不等于 account endpoint runtime、adapter capability implementation、App read model 或 Dashboard surface |
| `target engine / layer boundary` | Connectivity / Adapter Engine、Data Engine / future private stream boundary、Evidence Read Model Layer、Workbench Interface / Live Readiness surface 和 Docs / Validation / Automation readiness layer 的职责地图 | 不等于新增 SwiftPM target、Runtime actor、ViewModel 或 UI 行为 |
| `read-only future gate` | 后续 account / position / balance、private stream / account snapshot simulation gate 和 Live Monitoring read-only Console v2 进入 planning 前必须满足的 gate | 不等于当前可读取真实账户、创建 listenKey 或连接 private WebSocket |

`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`

MTP-126 target engines / layers 只作为边界语言出现：Connectivity / Adapter Engine 只能定义 public market data allowed、future private read-only gate 和 forbidden write capability baseline；Data Engine 只能定义 future private stream boundary；Evidence Read Model Layer 只能定义后续 read-model-only evidence source boundary；Workbench Interface 只能定义 Live Readiness surface 的 read-model-only boundary；Docs / Validation / Automation readiness layer 只落 contract、matrix、latest summary 和 mechanical anchors。

`MTP-126-L30-L31-L32-L33-HANDOFF`

MTP-126 的 L3.0 handoff 只把 terminology、target engines、future gates、forbidden baseline 和 validation anchors 交给后续 issue。MTP-127 才能定义 credential / endpoint taxonomy，MTP-128 才能定义 adapter capability matrix，MTP-129 才能定义 account / position / balance read-model-only future gates，MTP-130 才能定义 private stream / account snapshot simulation gate input material，MTP-131 才能定义 Workbench Live readiness read-model-only boundary，MTP-132 才能做 validation / automation / stage audit input closeout。

`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`

MTP-126 的 forbidden baseline 必须覆盖 API key / secret storage、local secret read、signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage runtime、account / position / balance read model implementation、Live Monitoring Console v2 implementation、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选，不构成执行授权。只有 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 的 MTP-126 才可执行；MTP-126 完成后不得自动推进 MTP-127。

`MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

MTP-126 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 L3.0 terminology / boundary，并且 `bash checks/run.sh` 通过。

`MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`

MTP-127 credential / secret policy 只能作为 L3.0 future gate 和 forbidden baseline 出现。`LiveReadOnlyCredentialPolicyTerm` 只允许命名 credential / secret policy future gate、no local secret read、no API key / secret storage implementation、no env / keychain / config secret path 和 no credential provider runtime；它不授权当前读取 secret、创建配置路径或实现 credential provider。

`MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`

MTP-127 endpoint capability taxonomy 固定 `public read-only market data` 是唯一 current allowed capability；`signed endpoint forbidden`、`account endpoint forbidden`、`listenKey forbidden`、`private WebSocket forbidden` 和 `broker action forbidden` 只能作为 forbidden / future gate evidence。禁止把这些词写成 partially supported、preview enabled、behind flag available 或 local fallback。

`MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`

MTP-127 public read-only / private endpoint isolation 表示 public market data 不能升级为 signed request、account endpoint、listenKey、private WebSocket、broker action、`LiveExecutionAdapter` 或 private read runtime。MTP-127 不实现 MTP-128 adapter capability matrix，不实现 MTP-129 account / position / balance read model，不实现 MTP-130 private stream / account snapshot simulation gate，不实现 MTP-131 Workbench Live readiness surface。

`MTP-127-FORBIDDEN-CAPABILITY-TESTS`

MTP-127 forbidden capability tests 必须证明 `LiveReadOnlyCredentialEndpointTaxonomyBoundary` 的 secret read、API key storage、secret configuration path、signed endpoint、account endpoint、listenKey、private WebSocket、broker action、`LiveExecutionAdapter`、private read runtime、public adapter upgrade 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION`

MTP-127 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 credential / endpoint taxonomy boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为。

`MTP-128-ADAPTER-CAPABILITY-MATRIX`

MTP-128 adapter capability matrix 固定 `public market data allowed` 是唯一 current allowed adapter capability；`future private account read-only gated` 只能作为 future gated capability；`signed endpoint forbidden`、`order write forbidden`、`broker action forbidden`、`broker execution adapter forbidden`、`exchange execution adapter forbidden`、`LiveExecutionAdapter forbidden`、`account endpoint / listenKey forbidden`、`execution report / broker fill / reconciliation forbidden` 和 `real account / broker position / margin / leverage forbidden` 只能作为 forbidden evidence。

`MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`

MTP-128 public read-only adapter / future private gate isolation 表示当前 public market data adapter 不能升级为 private account read runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、order write、execution report、broker fill、reconciliation 或真实账户 / 仓位 / 保证金 / 杠杆读取。MTP-128 不实现 adapter runtime，不新增 Adapters target 类型，不实现 MTP-129 account / position / balance read model，不实现 MTP-130 private stream / account snapshot simulation gate。

`MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS`

MTP-128 forbidden adapter capability tests 必须证明 `LiveReadOnlyAdapterCapabilityMatrixBoundary` 的 broker adapter、exchange execution adapter、`LiveExecutionAdapter`、public adapter execution upgrade、signed endpoint、account endpoint、listenKey、order write、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION`

MTP-128 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 adapter capability matrix boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为。

`MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`

MTP-129 account / position / balance future gates 只能作为 L3.1 read-model-only handoff material 出现。`LiveReadOnlyAccountPositionBalanceFutureGate` 只允许命名 account read-model-only contract、position read-model-only contract、balance read-model-only contract、source identity required、snapshot freshness required、evidence identity required、Workbench / Dashboard ViewModel boundary 和 paper / simulated / fixture evidence isolation；它不授权当前读取 real account、broker position、margin、leverage 或 real PnL。

`MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`

MTP-129 source identity / freshness / evidence identity boundary 表示后续 L3.1 必须区分 future account source identity、future position source identity、future balance source identity 和 fixture source identity isolation，并在 snapshot 上记录 observedAt、source watermark 和 stale boundary。MTP-129 不实现 account snapshot runtime、不连接 private stream、不调用 signed endpoint、account endpoint 或 listenKey。

`MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS`

MTP-129 forbidden interpretation tests 必须证明 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary` 的 account / position / balance runtime、real account read、broker position sync、real account balance、margin、leverage、real PnL、signed/account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、OMS、paper evidence -> real account data、simulated fill -> broker position、fixture evidence -> real account snapshot、trading button、live command 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION`

MTP-129 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 account / position / balance read-model-only future gate boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不读取真实账户、不连接 broker、不触发真实交易行为。

`MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`

MTP-130 private stream / account snapshot simulation gate input material 只能作为 L3.2 handoff material 出现。`LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial` 只允许命名 private stream source identity、account snapshot fixture identity、snapshot observedAt、source watermark、freshness boundary、account / position / balance event shape、fixture replay cursor 和 simulation gate boundary；它不授权当前创建 listenKey、连接 private WebSocket、运行 account snapshot runtime 或读取真实账户。

`MTP-130-FUTURE-FIXTURE-REQUIREMENTS`

MTP-130 future fixture requirements 表示后续 L3.2 必须使用 deterministic account snapshot fixture、private stream event fixture、fixture source identity、fixture freshness、replay cursor、live stream implementation separation、listenKey forbidden validation 和 network independent validation。MTP-130 不实现 fixture runtime、不调用 account endpoint、不创建 private stream runtime，也不依赖真实 Binance 网络。

`MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`

MTP-130 simulation gate / live stream isolation 表示 simulation gate input material 不能被解释为 live private stream implementation，fixture account snapshot 不能被解释为真实 account snapshot。MTP-130 不新增 Adapters、Runtime、App、Dashboard behavior，不实现 L3.2，不把 public read-only adapter 或 MTP-129 account / position / balance future gate 升级为 private stream runtime。

`MTP-130-LISTENKEY-FORBIDDEN-TESTS`

MTP-130 listenKey forbidden tests 必须证明 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary` 的 listenKey create / keepalive、private WebSocket、private stream runtime、account snapshot runtime、signed/account endpoint、real account read、real account payload consumption、broker position sync、margin / leverage、broker adapter、`LiveExecutionAdapter`、OMS、real order write、simulation gate -> live stream implementation、fixture snapshot -> real account snapshot、trading button、live command 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION`

MTP-130 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 private stream / account snapshot simulation gate input boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不创建 listenKey、不连接 private WebSocket、不读取真实账户、不连接 broker、不触发真实交易行为。

`MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`

MTP-131 Workbench Live readiness read-model-only boundary 表示 Workbench、Dashboard、Report 和 Event Timeline 只能展示 Live readiness boundary evidence。`LiveReadOnlyWorkbenchReadModelBoundary`、`LiveReadOnlyWorkbenchBoundaryReadModel` 和 `LiveReadOnlyWorkbenchBoundaryViewModel` 只允许携带 surface labels、ReadModel / ViewModel input boundary、forbidden UI labels、detail / audit route、L3.1 / L3.2 / L3.3 handoff target、source anchors 和 validation anchors；它们不等于 API key 表单、broker connect、account connect、Live PRO Console、trading button、live command、order form、real account balance 或 broker position。

`MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`

MTP-131 ReadModel / ViewModel input boundary 表示 UI 输入只能来自 Core deterministic fixture、App read model projection、App ViewModel snapshot、Dashboard shell snapshot 和 Evidence Explorer timeline route。Workbench / Dashboard 不允许直接读取 secret、Persistence schema、Runtime object、adapter request、signed endpoint、account endpoint、listenKey、private WebSocket、broker state、account payload 或真实账户数据。

`MTP-131-FORBIDDEN-UI-SURFACE`

MTP-131 forbidden UI surface 必须覆盖 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command、order form、real account balance、broker position、Runtime object、database schema、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle 和 real submit / cancel / replace。这些词只能作为 forbidden evidence、validation matrix 和 PR boundary evidence 出现，不能作为可见交互、连接向导、命令入口或真实账户展示。

`MTP-131-DETAIL-AUDIT-ROUTING`

MTP-131 detail / audit routing 只允许 Dashboard summary -> Report evidence、Report evidence -> Event Timeline、Event Timeline -> contract anchor 和 detail inspector -> validation anchor。它不授权查询语言、Runtime replay command、incident replay、stop control、broker operation、live audit runtime 或任何 production operation。

`MTP-131-L31-L32-L33-HANDOFF`

MTP-131 L3.1 / L3.2 / L3.3 handoff 只说明 Workbench UI 已保留后续只读 evidence 位置：account / position / balance read-model-only、private stream / account snapshot simulation gate 和 Live Monitoring read-only console v2。该 handoff 不授权后续 issue 自动执行，也不授权 signed/account/broker capability。

`MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION`

MTP-131 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture、App ReadModel / ViewModel、Dashboard shell、Event Timeline 和 focused tests 均固定 Workbench read-model-only boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为、不创建 live command 或 trading button。

## Account / Position / Balance Read-model-only Terms

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`

以下术语由 MTP-133 定义为 `MTPRO Account / Position / Balance Read-model-only v1` 的 L3.1 boundary language。它们只用于 terminology、contract、validation anchors 和后续 issue handoff，不授权当前 scope 实现 account runtime、position runtime、balance runtime、signed endpoint、account endpoint / listenKey、private WebSocket、broker adapter、Live PRO Console、trading button、live command 或 order form。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `account read-model-only evidence` | 本地 / fixture / paper / simulated 来源的账户证据解释层 | 不等于真实 account endpoint payload、account snapshot runtime、broker account sync 或可交易账户状态 |
| `position read-model-only evidence` | 本地 / fixture / paper / simulated 来源的仓位证据解释层 | 不等于 broker position、margin position、leverage position、real portfolio sync 或 broker risk input |
| `balance read-model-only evidence` | 本地 / fixture / paper / simulated 来源的余额证据解释层 | 不等于真实账户余额、buying power、margin、leverage、real PnL 或可下单资金 |
| `read-model-only source` | 当前只允许 fixture / paper / simulated / future-gated real label 的证据来源标签 | 不等于 account endpoint、listenKey、private stream、broker adapter 或真实账户连接 |
| `future real source` | 未来可能接入真实账户只读能力前的门禁标签 | 不等于当前已实现真实账户读取、secret storage、signed request 或 private WebSocket |

`MTP-133-SOURCE-SEMANTICS-BOUNDARY`

MTP-133 source semantics 只允许表达 fixture source、paper source、simulated source 和 future-gated real source。fixture source 是 deterministic local fixture，不是真实 account payload；paper source 是 paper runtime / paper portfolio 本地证据，不是真实账户；simulated source 是 scenario replay / simulated exchange / backtest parity 本地证据，不是 broker fill、execution report 或 reconciliation；future-gated real source 只是门禁标签，不授权当前读取 real account、调用 signed endpoint、创建 listenKey 或运行 account snapshot runtime。

`MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`

MTP-133 evidence interpretation boundary 固定 account evidence 只能说明 evidence identity、source identity、freshness / stale 状态和 blocked reason；position evidence 只能说明 symbol / side / quantity / exposure 的 read-model-only interpretation；balance evidence 只能说明 paper / simulated / fixture balance interpretation。任何 evidence 都不得被解释为真实账户资产、broker position sync、buying power、margin、leverage 或 real PnL。

`MTP-133-L31-L32-HANDOFF-BOUNDARY`

MTP-133 只交付 L3.1 terminology / contract input。MTP-134 才能定义 account snapshot identity，MTP-135 才能定义 position snapshot identity，MTP-136 才能定义 balance snapshot identity，MTP-137 才能定义 deterministic fixture contract，MTP-138 才能定义 Workbench / Report / Events read-model-only evidence surface，MTP-139 才能做 validation / automation / stage audit input closeout。L3.2 Private Stream / Account Snapshot Simulation Gate 仍是 future gate；MTP-133 不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。

`MTP-133-FORBIDDEN-CAPABILITY-BASELINE`

MTP-133 的 forbidden baseline 必须覆盖 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL runtime、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable candidate 只是候选，不构成执行授权。MTP-133 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行；MTP-133 完成后不得自动推进 MTP-134。

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION`

MTP-133 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 L3.1 read-model-only terminology / boundary，并且 `bash checks/run.sh` 通过。

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`

MTP-134 account snapshot identity 只表示 account evidence 的稳定身份。`accountSnapshotId`、`accountEvidenceId`、`accountSourceIdentity`、`observedAt` 和 `sourceWatermark` 都是 Read Model / ViewModel 可引用的 evidence 字段，不是 account snapshot runtime、真实 account id、broker account object、account endpoint payload id 或可交易账户状态。Canonical identity example 为 `account-snapshot|fixture|mtp-134-local-account-evidence|1704067500|fresh`，只表达 deterministic string shape，不包含真实账户余额、margin、leverage、buying power、real PnL 或 broker account identifier。

`MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`

MTP-134 account source identity 只允许 `fixture`、`paper`、`simulated` 和 `future-gated-real`。fixture source 必须是 deterministic local fixture identity，不是真实 account payload；paper source 只能引用 paper runtime / paper portfolio 本地 evidence，不是真实账户；simulated source 只能引用 scenario replay / simulated exchange / backtest parity evidence，不是 broker fill、execution report 或 reconciliation；future-gated-real source 只是未来门禁标签，不包含 endpoint URL、API key、secret、listenKey、private stream cursor、broker account id 或 account payload。Freshness evidence 只表达 `observedAt`、`sourceWatermark`、`freshnessStatus`、`freshnessReason` 和 `sourceBoundary`。

`MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`

MTP-134 stale / missing / blocked account evidence 只描述 evidence 可用性：`stale` 不触发网络刷新，`missing` 不触发 account endpoint / listenKey / broker fallback，`blocked` 表示 forbidden capability boundary 拒绝 real account endpoint、private WebSocket、broker adapter、secret storage 或 signed request。任何状态都不得升级为 recovery action、refresh command、private stream reconnect、broker sync、Live PRO Console action、trading button 或 live command。

`MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`

MTP-134 account source identity 不能绕过 adapter capability matrix。`future-gated-real` source 不得写成 account endpoint path、signed request descriptor、listenKey lease 或 private WebSocket channel；fixture / paper / simulated source 不得写成 broker account payload、Runtime object、Adapter request 或 exchange private payload；App / UI 不得直接消费 adapter request、exchange payload、broker payload、secret config 或 Runtime object。

`MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME`

MTP-134 account snapshot identity 是 evidence identity，不是 runtime snapshot；它不授权 account snapshot runtime、account endpoint / listenKey、signed endpoint、signed request、private WebSocket runtime、secret storage、credential provider、broker / exchange execution adapter、real account balance、margin、leverage、buying power、real PnL、OMS、real order lifecycle、real submit / cancel / replace、Live PRO Console、trading button、live command 或 order form。

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION`

MTP-134 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 account snapshot identity / source freshness evidence boundary，并且 `bash checks/run.sh` 通过。MTP-134 不新增 account fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-135-POSITION-SNAPSHOT-IDENTITY`

MTP-135 position snapshot identity 只表示 position evidence 的稳定身份。`positionSnapshotId`、`positionEvidenceId`、`positionSourceIdentity`、`symbol`、`side`、`quantity` 和 `scenarioVersion` 都是 read-model-only evidence 字段，不是 broker position id、exchange position id、margin account position、leverage position、live portfolio handle 或 live risk input。Canonical identity example 为 `position-snapshot|simulated|mtp-135-local-position-evidence|BTCUSDT|long|1704067500|simulated`，只表达 deterministic string shape，不包含 broker position id、real account id、margin、leverage、real PnL、execution report、broker fill 或 reconciliation data。

`MTP-135-POSITION-EXPOSURE-EVIDENCE`

MTP-135 exposure evidence 只表示 fixture / paper / simulated position 的 read-model-only interpretation。`symbol`、`side`、`quantity`、`exposureNotional` / `exposureQuoteValue` 和 `scenarioVersion` 只能说明本地证据，不等于 broker quantity、margin exposure、leverage exposure、broker risk input、order sizing input 或 real PnL source。Exposure evidence 不能驱动 live risk engine、OMS decision、trading command、emergency stop 或 broker sync。

`MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`

MTP-135 paper exposure、simulated exposure 和 future-gated real position 必须隔离：paper exposure 可以引用 paper portfolio projection 但不得升级为 real position；simulated exposure 可以引用 simulated fill / simulated exchange / scenario replay evidence 但不得升级为 broker fill、execution report 或 broker position；future-gated real position 只是未来门禁标签，不包含 broker account id、position id、margin mode、leverage、private stream cursor 或 account endpoint payload。

`MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`

MTP-135 position evidence status 只描述 evidence 可用性：`simulated` 表示本地 simulated exchange / scenario replay / deterministic fixture evidence，`stale` 不触发 broker refresh，`blocked` 表示 forbidden broker position interpretation 拒绝 broker adapter、account endpoint、listenKey、private stream、real account position、margin、leverage 或 real PnL。任何状态都不得升级为 broker position sync、private stream reconnect、margin refresh、live risk engine input、trading button、live command 或 order form。

`MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION`

MTP-135 forbidden broker position interpretation 固定：position evidence 不是 broker position；paper portfolio projection 不是 real position；simulated fill / simulated exchange exposure 不是 broker fill、execution report 或 reconciliation；fixture position evidence 不是真实 account snapshot、broker portfolio、margin position 或 leverage position；App / UI 只能消费 Read Model / ViewModel evidence，不得展示 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

`MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION`

MTP-135 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 position snapshot identity / exposure evidence boundary，并且 `bash checks/run.sh` 通过。MTP-135 不新增 position fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-136-BALANCE-SNAPSHOT-IDENTITY`

MTP-136 balance snapshot identity 只表示 balance evidence 的稳定身份。`balanceSnapshotId`、`balanceEvidenceId`、`balanceSourceIdentity`、`balanceKind`、`observedAt` 和 `sourceWatermark` 都是 read-model-only evidence 字段，不是 real account balance id、broker cash statement id、buying power id、account endpoint payload id、ledger statement 或真实资金流水。Canonical identity example 为 `balance-snapshot|paper-cash|mtp-136-local-balance-evidence|1704067500|fresh`，只表达 deterministic string shape，不包含真实账户余额、broker cash statement、margin、leverage、buying power、real PnL、account endpoint payload 或 private stream update。

`MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`

MTP-136 balance terminology 必须保留 source label：`paper cash` 是 paper runtime / paper portfolio 的本地 sandbox cash interpretation，不是真实账户 cash；`paper equity` 不是 broker equity、margin equity 或 buying power；`simulated balance` 不是 broker cash statement；`fixture balance` 不是真实 account payload；`future-gated real balance` 只是未来门禁标签，不包含 account endpoint、listenKey、private stream、broker cash statement 或真实资金字段。

`MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`

MTP-136 paper-vs-real boundary 固定：Paper account model 输出只能解释为 paper balance evidence，不是 live account balance；simulated exchange balance 只能解释为 simulated balance evidence，不是 broker cash、broker margin 或 real PnL；fixture balance 只能解释为 deterministic local evidence，不是真实账户资金；future-gated real balance 只能作为未来门禁标签，不表示当前已读取真实账户资金。Balance evidence 不得驱动 order sizing、buying power check、live risk engine、OMS decision、trading button、live command、emergency stop 或 broker sync。

`MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`

MTP-136 forbidden baseline 必须覆盖 real PnL runtime、margin read、leverage read、buying power read、real account balance read、broker cash statement、signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 和 order form。这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成 current preview、fallback、behind flag、local beta 或 partial implementation。

`MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE`

MTP-136 balance evidence status 只描述 evidence 可用性：`stale` 表示本地 paper / simulated / fixture balance evidence 超出 freshness expectation，但不触发 account endpoint refresh；`blocked` 表示 evidence 因 forbidden real balance interpretation 被拒绝，例如 real account balance、margin、leverage、buying power、real PnL、signed endpoint、account endpoint、listenKey、private stream 或 broker cash statement。Stale / blocked state 不得升级为 balance refresh command、private stream reconnect、broker sync、buying power check、Live PRO Console action、trading button、live command 或 order form。

`MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION`

MTP-136 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 balance snapshot identity / paper-vs-real interpretation boundary，并且 `bash checks/run.sh` 通过。MTP-136 不新增 balance fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-137-DETERMINISTIC-FIXTURE-SHAPE`

MTP-137 deterministic fixture shape 固定三类本地证据：`account snapshot`、`position snapshot` 和 `balance snapshot`。每类记录只包含 snapshot identity、evidence identity、source identity、observedAt、sourceWatermark、freshnessStatus 和 read model field names；它不是真实 account endpoint payload、broker payload、private stream event、schema object、adapter request、Runtime object 或 account snapshot runtime handle。

`MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`

MTP-137 fixture identity 固定为 `fixture-v1`、`fixture:mtp-137-account-position-balance-read-model-only`、`1704067500`、`fixture-watermark:mtp-137:2024-01-01T00:05:00Z` 和 `fresh`。Checksum 只能证明本地 deterministic fixture parity，不代表真实账户 freshness、broker server timestamp、private stream cursor、listenKey keepalive 或 reconciliation watermark。

`MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`

MTP-137 forbidden real account tests 必须覆盖 signed endpoint、account endpoint、listenKey、private WebSocket、secret read、broker adapter、real account read、real account payload、broker payload import、broker position sync、real PnL runtime、margin read、leverage read、account snapshot runtime 和 payload / schema / runtime object exposure。测试必须由本地 deterministic fixture 完成，不依赖真实网络、真实 Binance private API 或真实 credential。

`MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`

MTP-137 fixture-to-read-model mapping 只能输出稳定 Read Model 字段，不能包含 `payload`、`schema`、`runtime`、`endpoint`、`listenKey`、`secret`、`broker`、`margin`、`leverage` 或 `realPnL`。任何尝试把 account endpoint payload、broker payload、schema、Runtime object 或 private stream object 放入 mapping 的行为都必须被拒绝。

`MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION`

MTP-137 real account payload isolation 规则要求 fixture 不提供 importer、parser、refresh、connect、sync、reconcile、submit、cancel、replace 或 live command。`future-gated` 只能表示后续门禁，不表示当前已连接真实账户。

`MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION`

MTP-137 validation 必须证明 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord`、`AccountPositionBalanceReadModelOnlyForbiddenCapability` 和 focused Core tests 均固定 fixture / forbidden real account boundary，并且 `bash checks/run.sh` 通过。MTP-137 不新增 App surface、不新增 Dashboard smoke handle；Workbench / Report / Events surface 仍归属 MTP-138。

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
