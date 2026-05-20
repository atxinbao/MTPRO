# BLUEPRINT.md

日期：2026-05-20

执行者：Human + `@000 / AIE`

## 定位

本文档是 MTPRO 的 canonical Root / Complete Blueprint。

它同时承担：

- Root Blueprint：项目总览、默认读取顺序、Current / Future 边界。
- Complete Blueprint：Product Blueprint、Architecture Blueprint、Design Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Current / Future Boundary、Blueprint -> Architecture -> Roadmap Handoff。

蓝图本体只维护在根目录 `BLUEPRINT.md`。不再维护 `docs/design/` 下的兼容蓝图入口，避免双写漂移。

本文档不是 Linear Project，不是 Linear issue，不授权执行，不推进 `Todo`，不启动 Symphony，不运行 Graphify update，不写业务代码。

## 默认读取顺序

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `ENVIRONMENT.md`
6. `ARCHITECTURE.md`
7. `ROADMAP.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

执行或验证时，再按当前 Linear issue scope 读取 `docs/contracts/`、`docs/product/`、`docs/validation/`、`docs/automation/agent-engineering-practices.md`、`docs/automation/`、Stage Code Audit Report 和当前 Linear issue body。

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 图纸分层

| 层 | 文件 | 职责 |
| --- | --- | --- |
| Project Charter | `GOAL.md` | 为什么建、服务谁、硬边界、成功标准 |
| Canonical Blueprint | `BLUEPRINT.md` | Root Blueprint + Complete Blueprint，产品 / 架构 / 设计完整蓝图、Current / Future 边界 |
| Environment | `ENVIRONMENT.md` | 本地工具、验证入口、外部系统禁区 |
| Architecture Map | `ARCHITECTURE.md` | 承接 `BLUEPRINT.md`，把蓝图翻译为系统模块、边界、数据流、接口、约束和技术分层 |
| Construction Plan | `ROADMAP.md` | 当前阶段路线、Project closure、Current Foundation Progress、Final Product Goal Progress |
| Shared Language | `docs/domain/context.md` | MTPRO 领域术语、禁止混用词、paper-only / read-only / future-gated 语义 |
| Agent Engineering Practices | `docs/automation/agent-engineering-practices.md` | shared language、feedback loop、tracer bullet、diagnose、architecture deepening 和 handoff discipline |
| Evidence | `docs/audit/`、`docs/validation/`、`verification.md` | Stage Code Audit、验证摘要和 append-only 历史 |

## Root Docs Responsibility Contract

MTPRO 的 root docs 按职责分工读取和维护：

| 文件 | 只回答 | 不负责 |
| --- | --- | --- |
| `GOAL.md` | 为什么建、服务谁、硬边界、成功标准 | 不展开最终产品蓝图，不列完整系统结构，不决定下一阶段 Project |
| `BLUEPRINT.md` | 最终产品要建成什么、产品 / 架构 / 设计如何组织、Current / Future 如何分界 | 不记录完成进度条，不替代 `ROADMAP.md`，不授权 Linear execution |
| `ARCHITECTURE.md` | 承接蓝图后的工程架构地图：系统模块、边界、数据流、接口、约束和技术分层 | 不重新定义产品目标，不维护完整未来蓝图，不记录 Stage Audit 流水账 |
| `ROADMAP.md` | 当前已批准阶段、目标切片、Project closure、下一步 planning handoff | 不替代蓝图，不创建 Linear，不推进 `Todo` |

维护原则：

- 目标冲突先看 `GOAL.md`。
- 终局设计和 Future Construction Zones / 未来建设区先看 `BLUEPRINT.md`。
- 蓝图如何落成系统模块、边界、数据流、接口和技术分层先看 `ARCHITECTURE.md`。
- 当前施工进度和下一步 planning handoff 先看 `ROADMAP.md`。
- 如果蓝图被更新，必须确认它没有把 future capability 变成当前 execution scope。

## 来源

| 来源 | 用途 |
| --- | --- |
| `GOAL.md` | Project Charter、服务对象、永久硬边界和当前成功标准 |
| `ENVIRONMENT.md` | 本地环境、验证入口和外部系统禁区 |
| `ARCHITECTURE.md` | 承接蓝图后的模块地图、目标数据流和不变量 |
| `ROADMAP.md` | 已完成阶段、当前路线和非授权边界 |
| `docs/domain/context.md` | MTPRO shared language、领域术语和禁止混用词 |
| `docs/automation/agent-engineering-practices.md` | 从 `mattpocock/skills` 吸收的 Agent 工程实践 |
| `docs/reference/nautilus-trader/` | NautilusTrader 产品 / 设计 / 架构参考研究 |
| `docs/reference/nautilus-trader/root-docs-delta-proposal.md` | Root Docs Delta Proposal，进入完整蓝图前的候选 root docs delta |
| `docs/audit/` | 已完成 Project 的 Stage Code Audit Reports |
| `docs/validation/trading-validation-matrix.md` | 交易语义验证证据地图 |
| `docs/planning/project-role-map.md` | MTPRO 角色编号、职责和边界 |

## Blueprint Design Lenses / 蓝图设计视角

`BLUEPRINT.md` 必须同时从产品、架构和设计三条线考虑，不能只写功能清单。

| 视角 | 需要回答 | 落到本文档 |
| --- | --- | --- |
| Product / 产品 | 服务谁、解决什么问题、主路径是什么、为什么用户可信 | Product Blueprint、Final Product Goal Slices、Product Workflow Blueprint |
| Architecture / 架构 | 什么系统能力支撑最终产品、模块怎么分层、Paper / Live 怎么隔离 | Architecture Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint |
| Design / 工作台设计 | 用户在界面中看到什么、怎么理解状态、怎么操作、如何避免误触实盘 | Design Blueprint、Current / Future Boundary、Live Gate Blueprint |

大白话：Product 定义酒店服务谁和提供什么服务；Architecture 定义地基、水电、消防、电梯和后厨；Design 定义客人进门后怎么走、看到什么、怎么操作。

## Product Blueprint / 产品蓝图

MTPRO 最终要成为一个 local-first 的 macOS 原生专业交易工作台，先完成 Research -> Backtest -> Report -> Paper 的本地证据链，再演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

最终产品形态不是 NautilusTrader 的 Swift 复刻，也不是 `macos-trader` 的整仓迁移。MTPRO 学习 NautilusTrader 的交易语义、event-driven runtime、adapter 分层、risk / execution / portfolio 因果链和 report / replay evidence 组织方式，但保持 SwiftPM-first、macOS-native、ViewModel-first 的产品形态。

产品可信度来自 evidence chain：数据来源、策略信号、回测结果、Paper 行为、风险证据、组合变化、事件时间线和报告 artifact 都必须可追溯、可回放、可验证。Future Live 必须作为独立 Future Construction Zones / 未来建设区进入，不能从 paper-only 能力偷渡。

## Final Product Goal Slices

最终产品不是只做到 paper-only foundation。MTPRO 的完整产品目标分为 9 个目标切片：

| # | 目标切片 | 当前状态 | 中文说明 |
| --- | --- | --- | --- |
| 1 | 研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation） | Complete | 能研究策略、跑回测、生成报告，并说明数据、策略和结果来源。 |
| 2 | Paper 模拟执行基础能力（Paper execution foundation） | Complete | 能跑模拟交易，有 paper order、simulated fill、paper portfolio，但不碰真实资金和真实订单。 |
| 3 | 工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell） | Complete | 能在 Mac 工作台里观察 Research、Backtest、Report、Paper、Risk、Portfolio、Events，并做本地 Paper session 控制。 |
| 4 | 行情数据回放运营能力（Market data replay operations） | Complete | 能管理行情批次、回放数据、检查 freshness / retention / consistency，为研究和 Paper 提供稳定数据底座。 |
| 5 | 实盘交易基础边界（Live trading foundation） | Pending / gated | 开始接真实交易边界，包括 API key、signed endpoint、account endpoint、broker / exchange adapter 和真实订单生命周期。 |
| 6 | 实盘监控台（Live monitoring console） | Pending / gated | 能监控实盘节点、连接、行情流、订单流、错误、延迟和运行健康状态。 |
| 7 | 实盘执行控制（Live execution control） | Pending / gated | 能控制真实订单提交、撤销、替换、成交回报、订单状态和执行失败处理。 |
| 8 | 实盘风险控制（Live risk control） | Pending / gated | 能用真实风控阻止危险订单，例如仓位、订单金额、频率、亏损、熔断和禁交易状态。 |
| 9 | 实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls） | Pending / gated | 能审计和回放每个 signal、order、risk decision、fill，并支持紧急停止、停机、恢复和事故复盘。 |

Current Foundation Progress 已完成 4 / 4；Final Product Goal Progress 当前为 4 / 9。完整进度口径由 `ROADMAP.md` 维护，蓝图只定义目标结构。

## Target Users / Jobs

| 用户 | 核心任务 | MTPRO 应提供 |
| --- | --- | --- |
| 个人专业交易者 / 独立策略研究者 | 用 Binance public market data 研究策略和市场状态 | Research / Backtest / Report / Paper evidence 工作台 |
| 策略验证用户 | 确认 backtest、paper、risk、cost、portfolio evidence 是否一致 | trading validation matrix、report artifact、event timeline |
| Paper readiness 用户 | 在不触碰真实交易的前提下观察 paper workflow | paper-only session、order intent、simulated fill、portfolio projection |
| 未来实盘准备用户 | 判断何时可以独立进入 Live 规划 | Live future zone、实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制、禁区说明和风险条件 |

## Complete Capability Map

当前 foundation 已覆盖：

- Binance public read-only ingest、Event Log / Replay、Research / Backtest / Report、Trading Validation。
- Paper Session Runtime、Paper Execution Workflow、Dashboard / Workbench、Market Data Replay Operations。
- Portfolio 和 Risk 当前只表达 paper-only exposure / blocker evidence，Live 前不得读取真实账户、broker position 或升级为真实 pre-trade engine。

Future / gated capability 必须独立规划：

- 实盘交易基础边界 / Live trading foundation：API key、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle。
- 实盘监控台 / Live monitoring console：live runtime health、连接状态、行情流、订单流、错误和延迟。
- 实盘执行控制 / Live execution control：real order submit / cancel / replace、execution reconciliation、incident fallback。
- 实盘风险控制 / Live risk control：真实 pre-trade risk gate、熔断、禁交易状态和 operations readiness。
- 实盘审计 / 事故回放 / 停机控制：audit trail、incident replay、emergency stop、停机 / 恢复策略。
- OMS / broker integration：完整订单管理、broker reconciliation、adapter capability contract。

## Product Workflow Blueprint

最终产品工作流以 evidence 为主线，而不是以交易按钮为中心：

```text
Market Data
-> Research
-> Backtest
-> Report
-> Paper Session
-> Paper Execution Evidence
-> Portfolio / Risk / Events
-> Future gated Live trading foundation
-> Future live monitoring / execution control / risk control / audit
-> Stage Audit
-> Future gated Live decision
```

用户应能看到：

- 数据来源和读取边界、策略和 signal evidence、Backtest / Paper parity。
- Report artifact 来源和状态、Paper session / paper order / simulated fill / portfolio projection 因果链。
- Replay / freshness / event timeline 证据链。
- Live 能力为什么当前被阻断，以及未来进入实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制需要哪些 gate。

## Architecture Blueprint / 架构蓝图

本节承接 Product Blueprint，把最终产品要求翻译为系统结构原则。具体模块边界、数据流、接口、约束和技术分层由 `ARCHITECTURE.md` 继续工程化维护。

目标系统结构：

```text
Adapters
-> Runtime ingest
-> Core domain / kernel
-> MessageBus / Cache
-> Strategy
-> Risk
-> Paper / future Live execution boundary
-> Portfolio
-> Event Log
-> Replay
-> Projections
-> Read Models
-> ViewModels
-> Workbench
-> Report / Audit
```

核心原则：

- Core 保存稳定领域语义，不保存 UI 状态。
- Adapter 能力必须显式声明；read-only data adapter 和 future execution adapter 不能混用。
- Event Log 是 append-only facts source。
- Replay 是跨 Research / Backtest / Paper / future Live 的审计能力。
- SQLite / DuckDB 是 projection，不是 UI contract。
- App / Dashboard 只消费 ViewModel / Read Model。
- Future Live 必须有独立 adapter capability、risk gate、reconciliation evidence、operations readiness 和 audit trail。

## Design Blueprint / 工作台设计蓝图

MTPRO Workbench 最终应包含：

| Surface | 目的 | ViewModel / Read Model |
| --- | --- | --- |
| Overview | 展示整体状态、最新 report、paper-only / live-gated 边界 | `DashboardViewModel` / `DashboardShellSnapshot` |
| Research | 管理研究输入、策略配置、signal evidence | `StrategyViewModel`、`ReportViewModel` |
| Backtest | 展示 backtest run、parity、cost、risk evidence | `BacktestViewModel`、`ReportViewModel` |
| Report | 独立 artifact 中心，归档 research / backtest / paper evidence | `ReportViewModel` |
| Paper | 展示 session、proposal、order intent、simulated fill、paper execution evidence | `PaperViewModel`、`RiskViewModel`、`PortfolioViewModel` |
| Portfolio | 展示 paper exposure，未来可扩展真实账户视图 | `PortfolioViewModel` |
| Risk | 展示 blocker、risk status、paper-only / future live gate | `RiskViewModel` |
| Events | 展示 append-only events、replay、projection freshness、audit trail | `EventLogViewModel`、`ReportViewModel` |
| Operations | 展示 local validation、automation readiness、Graphify / Symphony / GitHub 状态 | operations read model |
| Future Live | 仅展示 gated readiness，不提供当前交易入口；未来覆盖实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制 | future Live readiness model |

当前 UI 仍保持 read-model-only，不提供真实交易按钮，不直接读取 database schema、adapter request 或 runtime object。

## Infrastructure Blueprint / 基础设施蓝图

本节定义“地基承重和市政管线”：数据、事件、回放、投影、读模型、命令模型、审计和自动化如何支撑最终专业交易工作台。它不是当前全部施工授权。MTPRO 的可信度来自 evidence chain，而不是单个 UI 状态。

长期 evidence chain：

```text
Market event
-> Strategy signal
-> Backtest / Paper parity evidence
-> Cost assumption
-> Risk decision
-> Paper order intent
-> Simulated fill evidence
-> Portfolio projection
-> Report artifact
-> Event log / replay evidence
-> Stage Code Audit
```

基础设施蓝图必须覆盖：

- Data infrastructure：market data、batch、fixture、retention、freshness、event log、replay、projection。
- Trading evidence infrastructure：strategy signal、parity、cost assumption、risk decision、paper order、simulated fill、future real order evidence。
- Read / command infrastructure：read model、ViewModel、Command Model、UI 只消费稳定边界。
- Audit infrastructure：event timeline、report artifact、Stage Code Audit、future incident replay。
- Automation infrastructure：Linear、symphony-issue、GitHub PR Automation、Graphify、Post-Issue Ledger、Root Docs Refresh。

未来 Live 若被 Human 明确开启，还必须新增 signed endpoint capability、broker adapter capability、real order submit / cancel / replace contract、execution reconciliation、account / position sync、incident replay、operations readiness 和 rollback / stop policy。上述 future Live evidence 不属于当前 construction scope。

## Trading Capability Blueprint / 交易能力蓝图

交易能力分为当前 paper-only 能力和 future-gated live 能力。当前 paper-only 能力：

```text
Strategy signal
-> Paper action proposal
-> Risk blocker evidence
-> Paper order intent
-> Simulated fill evidence
-> Paper portfolio projection
-> Report / Dashboard / Event Timeline evidence
```

当前 paper-only 能力不能被解释为真实订单、真实成交、broker fill、account update 或 Live fallback。Future live 能力：

```text
Strategy signal
-> Live risk decision
-> Real order intent
-> Broker / exchange adapter
-> Execution report / fill
-> Real portfolio / account state
-> Reconciliation
-> Audit / incident replay / stop controls
```

Future live 能力必须作为独立 Project Definition 和独立 execution contract 进入，不能从 paper-only 类型、命令或 ViewModel 偷渡。

## Live Gate Blueprint / 实盘准入蓝图

Live trading 是最终产品目标的一部分，但不是当前 execution scope。进入 Live 前必须至少满足：

- Human 独立确认进入 Live 方向。
- 独立 Project Definition，不复用 paper-only issue scope。
- API key / secret policy。
- signed endpoint / account endpoint / listenKey capability contract。
- broker / exchange adapter capability contract。
- real order submit / cancel / replace contract。
- live risk gate、熔断、禁交易状态和 stop controls。
- execution reconciliation、account / position sync 和 incident replay。
- operations readiness、monitoring、rollback / shutdown policy。

任何缺少上述 gate 的变更都只能作为 Future Construction Zone 记录在蓝图中，不能进入 Linear execution。

## Execution / Automation Blueprint

当前自动化继续保持：

- Human + `@000 / AIE`：完整蓝图设计、docs-only PR、验证和边界守护。
- Human + `@001 / PLN`：蓝图确认后的下一阶段 Project / Issue 草案。
- `@002 / PAR`：Project 写入 Linear 后，执行 queue preflight、eligible issue 调度、child Codex 监督、Stage Code Audit。
- symphony-issue：唯一 `Todo` issue 的 `Todo -> In Progress -> In Review` 状态推进和 Codex Execution Agent 调度。
- Codex Execution Agent：只执行当前 Linear issue scope。
- GitHub PR Automation：required checks、auto-merge、squash merge、Linear bot auto Done。
- Graphify：read context 和 Post-Issue Ledger relationship memory。

完整蓝图不触发上述执行层。

## Current / Future Boundary / 当前与未来边界

本节定义“当前施工区”和“未来扩建区”。当前施工区只记录已经完成或 Human 明确允许进入 planning 的范围；未来扩建区可以被蓝图描述，但不能自动变成 Linear issue。

### Current Construction Scope

当前已批准并 closure 的 construction baseline：Bootstrap / contract-first baseline、Runtime Research Workbench v1、Trading Validation and Parity Hardening、Paper Session Runtime v1、Paper Execution Workflow v1、Paper Workflow Control Shell v1、Market Data Replay Operations v1、NautilusTrader reference study、`mattpocock/skills` 方法论整合。

当前 foundation / final product 采用两层进度口径：

- Current Foundation Progress：4 / 4（100%）。
- Final Product Goal Progress：4 / 9（44%）。

Current Foundation Progress 已完成 Research / Backtest / Report / Paper readiness、Paper-only execution evidence、Paper workflow 可观察性和本地 session-level control shell、更长周期 market data replay / operations。

Final Product Goal Progress 尚未完成；实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制仍属于 Future Construction Zones / 未来建设区。

当前没有已授权的下一阶段 construction scope。

下一阶段方向仍必须由 Human + `@001 / PLN` 基于本文档、`GOAL.md`、`ROADMAP.md`、Stage Code Audit Reports 和最新验证摘要确认。

### Future Construction Zones / 未来建设区

Future Construction Zones / 未来建设区指完整产品蓝图里明确需要但当前不施工的长期能力区。它们可以被蓝图描述，但不能自动变成当前 Project、Linear issue 或执行授权。

| Zone | 内容 | 为什么未来处理 | Gate |
| --- | --- | --- | --- |
| 实盘交易基础边界 / Live Trading Foundation | API key、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle | 当前 paper-only evidence 尚未形成可运营实盘系统 | Human decision、独立 Project Definition、security / risk / operations gates |
| 实盘监控台 / Live Monitoring Console | live runtime health、连接、行情流、订单流、错误、延迟和运行健康状态 | 需要先定义 live runtime 和 operations readiness | 独立 Live monitoring Project、telemetry / health evidence |
| 实盘执行控制 / Live Execution Control | order submit / cancel / replace、execution reconciliation、执行失败处理 | 真实订单控制会改变风险边界 | 独立架构蓝图、adapter capability contract、incident replay |
| 实盘风险控制 / Live Risk Control | 真实 pre-trade risk gate、仓位、订单金额、频率、亏损、熔断、禁交易状态 | 当前 risk 仍是 paper blocker / evidence | risk policy、operations readiness、emergency stop |
| 实盘审计 / 事故回放 / 停机控制 | signal / order / risk decision / fill 审计、incident replay、紧急停止、停机和恢复 | 需要 live event chain 和 operations policy | audit trail、stop policy、restore policy |
| OMS / Execution Management | 完整订单管理、状态机、broker reconciliation | 完整 OMS 会改变核心风险和运行边界 | 独立架构蓝图、adapter capability contract、incident replay |
| Real Portfolio / Account | account state、position sync、real balance | 当前 Portfolio 只表达 paper projection | broker contract、account data audit、read-only / write split |
| Deployment / Operations | packaging、release、telemetry、runtime monitoring | 当前仍以本地开发验证为主 | OPS project、signing / notarization / telemetry gates |
| 高级研究平台 / Advanced Research Platform | 多策略、多标的、长周期数据、参数实验 | 需要更稳定 data operations 和 report artifact taxonomy | market data operations、eval strategy、storage policy |

## Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力

Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力指未来可能需要，但当前必须被门禁或禁止的能力。进入这些能力前必须先有独立 Human decision、独立 Project Definition、清晰的 signed endpoint / broker / risk / operations gates，以及可审计的验证证据。

| Capability | Blueprint reason | Current status | Required gate |
| --- | --- | --- | --- |
| Live trading | 最终产品可能需要从研究到实盘闭环 | 当前禁止 | Human 新决策 + 独立 Live Project + signed endpoint / broker / risk / ops gate |
| signed endpoint | 实盘订单和账户能力需要 | 当前禁止 | API key / secret policy、adapter capability contract、audit evidence |
| broker action | 最终交易动作需要 | 当前禁止 | broker contract、execution reconciliation、risk gate、rollback policy |
| real order lifecycle | Live / OMS 需要 | 当前禁止 | 完整 OMS blueprint 和 validation |
| real account state | Portfolio / risk live 需要 | 当前禁止 | account endpoint boundary、read model isolation、privacy / ops policy |

## Blueprint -> Architecture -> Roadmap Handoff / 蓝图到架构和路线交接

蓝图更新后的交接顺序：

```text
GOAL.md
-> BLUEPRINT.md
-> ARCHITECTURE.md
-> ROADMAP.md
-> Linear Project / Issues
```

- `BLUEPRINT.md` 定义最终产品、基础设施、交易能力、工作台设计和 Current / Future 边界。
- `ARCHITECTURE.md` 承接 `BLUEPRINT.md`，把蓝图翻译成系统模块、边界、数据流、接口、约束和技术分层。
- `ROADMAP.md` 根据 `GOAL.md` 和 `ARCHITECTURE.md` 维护施工顺序、阶段 closure 和进度条。
- Linear 只接收 Human 确认后的 Project / Issue execution contract。

蓝图不能直接执行。

后续顺序：Human confirms blueprint -> Human + `@001 / PLN` selects Current Construction Scope slice -> Project Planning Record -> Human confirms Linear write -> Linear Project / Issues created as Backlog -> `@002 / PAR` startup gate -> unique eligible issue -> `Todo`。

当前 handoff 状态：Blueprint canonical location 是 `BLUEPRINT.md`；Human confirmed next scope、Current Construction Scope selected for next Project、Next Project Planning、Linear write 和 `@002 / PAR` authorization 均为 pending / no。

## Blueprint Update Rule

修改本文档时必须保持三条线分开：

- Product / Architecture / Design Blueprint：可以描述长期终局、系统承载能力、工作台体验和 Future Construction Zones / 未来建设区。
- Current Construction Scope：只能描述已经完成或 Human 明确允许进入 planning 的当前施工范围。
- Execution Authorization：只能来自 Linear live-read 中唯一 configured executable issue。

因此，本文档可以帮助 `@001 / PLN` 形成下一阶段 Project 草案，但不能直接创建 Linear Project / Issue，不能推进 `Todo`，不能启动 `@002 / PAR` 或 symphony-issue。

## Validation Checklist

已确认：

- NautilusTrader reference study 和 `mattpocock/skills` 已收敛为 MTPRO 自己的蓝图、shared language、feedback loop、diagnosis 和 handoff 规则。
- Root Blueprint 和 Complete Blueprint 已统一到根目录 `BLUEPRINT.md`；旧 `docs/design/mtpro-complete-blueprint.md` 兼容入口已移除。
- Goal / Blueprint / Architecture / Roadmap 分工明确；Product / Architecture / Design Blueprint 三线明确。
- Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Blueprint -> Architecture -> Roadmap Handoff、Future Construction Zones / 未来建设区均已明确。
- Live / signed endpoint / broker / OMS 被标记为 future / gated；蓝图不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不写业务代码。

## 执行边界

`BLUEPRINT.md`、`ROADMAP.md`、Project Planning Record、Backlog issue、label、priority 和 assignee 都不授权执行。

只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。
