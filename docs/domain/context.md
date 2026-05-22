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
