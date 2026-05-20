# MTPRO Complete Blueprint Design

日期：2026-05-19

执行者：Human + `@000 / AIE`

## 定位

本文档是 MTPRO 的完整蓝图设计。

它把当前 root docs、Stage Code Audit Reports、NautilusTrader reference study 和 Human 的长期产品判断，收敛成 MTPRO 自己的最终产品 / 系统 / 设计蓝图。

本文档不是 Linear Project，不是下一批 Linear issue，不授权执行，不推进 `Todo`，不启动 Symphony，不写业务代码。

本文档只记录 MTPRO 产品 / 系统 / 设计蓝图本体。角色职责、Project 调度规则、阶段完成进度条和自动化 closure 规则不在本文档重复定义，统一由 `AGENTS.md`、`docs/planning/project-role-map.md` 和 `docs/automation/parent-codex-supervision.md` 维护。

## 来源

| 来源 | 用途 |
| --- | --- |
| `GOAL.md` | 当前项目目标、第一版边界和非目标 |
| `BLUEPRINT.md` | Root Blueprint 入口、默认读取顺序、Current Construction Scope 和 Future Construction Zones 索引 |
| `ENVIRONMENT.md` | 本地环境、验证入口和外部系统禁区 |
| `ARCHITECTURE.md` | 当前模块地图、目标数据流和不变量 |
| `ROADMAP.md` | 已完成阶段、当前路线和非授权边界 |
| `docs/reference/nautilus-trader/` | NautilusTrader 产品 / 设计 / 架构参考研究 |
| `docs/audit/` | 已完成 Project 的 Stage Code Audit Reports |
| `docs/validation/trading-validation-matrix.md` | 交易语义验证证据地图 |
| `docs/planning/project-role-map.md` | MTPRO 角色编号、职责和边界 |

## Final Product Blueprint

MTPRO 最终要成为一个 macOS 原生交易研究与执行工作台。

最终产品形态不是 NautilusTrader 的 Swift 复刻，也不是 `macos-trader` 的整仓迁移。MTPRO 学习 NautilusTrader 的交易语义、event-driven runtime、adapter 分层、risk / execution / portfolio 因果链和 report / replay evidence 组织方式，但保持 SwiftPM-first、macOS-native、ViewModel-first 的产品形态。

最终产品应覆盖以下完整能力：

1. Research：研究数据、策略信号、指标假设和证据入口。
2. Backtest：基于本地事件 / fixture / replay 的确定性回测。
3. Report：把 research、backtest、paper、risk、portfolio、event log 和 validation evidence 汇总成可审计 artifact。
4. Paper：本地 paper-only session、proposal、risk blocker、paper order lifecycle、simulated fill、portfolio projection 和 replay evidence。
5. Portfolio：从事件和 projection 派生的组合观察面，当前只表达 paper-only exposure，未来可扩展到真实账户视图。
6. Risk：从 blocker evidence 发展到更完整的风险解释、限制、状态和未来 live risk gate。
7. Events：append-only facts、replay、projection freshness、audit trail 和 incident replay 观察面。
8. Operations：本地运行、验证、Graphify relationship memory、GitHub PR Automation、Linear / Symphony 自动化和阶段审计。
9. Future Live：未来可选的 signed endpoint、broker integration、real account state、real execution reconciliation、OMS 和 deployment / operations，但必须作为独立未来区处理。

## Target Users / Jobs

| 用户 | 核心任务 | MTPRO 应提供 |
| --- | --- | --- |
| 本地交易研究用户 | 用 Binance public market data 研究策略和市场状态 | Research / Backtest / Report / Paper evidence 工作台 |
| 策略验证用户 | 确认 backtest、paper、risk、cost、portfolio evidence 是否一致 | trading validation matrix、report artifact、event timeline |
| Paper readiness 用户 | 在不触碰真实交易的前提下观察 paper workflow | paper-only session、order intent、simulated fill、portfolio projection |
| 未来实盘准备用户 | 判断何时可以独立进入 Live 规划 | Live future zone、gates、禁区说明和风险条件 |

## Complete Capability Map

| Capability | Final blueprint status | Current construction status | Gate before implementation |
| --- | --- | --- | --- |
| Binance public read-only ingest | Final | 已有 baseline | 保持 public read-only，不接 API key |
| Event Log / Replay | Final | 已有 append-only / replay baseline | 后续只扩展 deterministic evidence，不破坏 facts source |
| Research / Backtest / Report | Final | 已有最小闭环 | 加强工作台、报告和 evidence explorer |
| Trading Validation | Final | 已有 matrix 和 parity / risk / cost evidence | 按 issue 继续扩展，不跳过 validation |
| Paper Session Runtime | Final | 已完成 v1 | 后续扩展可观察性和控制壳 |
| Paper Execution Workflow | Final | 已完成 v1 evidence | 后续扩展 workflow 操作和 replay consistency |
| Dashboard / Workbench | Final | 现为 read-model-only shell | UI issue 必须保持 ViewModel / Read Model 边界 |
| Portfolio | Final | 现为 paper-only exposure | Live 前不得读取真实账户或 broker position |
| Risk | Final | 现为 paper blocker / evidence | Live 前不得升级为真实 pre-trade engine |
| Live trading | Future / gated | 当前禁止 | 需要 Human 决策、独立 Project Definition、signed endpoint / broker / risk / reconciliation / operations gates |
| OMS / broker integration | Future / gated | 当前禁止 | 需要独立架构蓝图、adapter capability contract 和安全运行计划 |

## Product Workflow Blueprint

最终产品工作流：

```text
Market Data
-> Research
-> Backtest
-> Report
-> Paper Session
-> Paper Execution Evidence
-> Portfolio / Risk / Events
-> Stage Audit
-> Future gated Live decision
```

工作台不应以交易按钮为中心，而应以 evidence 和状态解释为中心。

用户应能看到：

- 当前数据来源和读取边界。
- 当前策略和 signal evidence。
- Backtest / Paper parity。
- Report artifact 的来源和状态。
- Paper session / paper order / simulated fill / portfolio projection 的因果链。
- Live 能力为什么当前被阻断，以及未来进入 Live 需要哪些 gate。

## System Architecture Blueprint

最终系统结构：

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

## Workbench / UX Blueprint

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
| Future Live | 仅展示 gated readiness，不提供当前交易入口 | future Live readiness model |

当前 UI 仍保持 read-model-only，不提供真实交易按钮，不直接读取 database schema、adapter request 或 runtime object。

## Data / Evidence / Audit Blueprint

MTPRO 的可信度来自 evidence chain，而不是单个 UI 状态。

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

未来 Live 如果被 Human 明确开启，必须新增：

- signed endpoint capability evidence。
- broker adapter capability evidence。
- real order submit / cancel / replace contract。
- execution reconciliation evidence。
- account state / position sync evidence。
- incident replay 和 audit evidence。
- operations readiness 和 rollback / stop policy。

这些 future Live evidence 不属于当前 construction scope。

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

## Current Construction Scope

当前已完成：

- Bootstrap / contract-first baseline。
- Runtime Research Workbench v1。
- Trading Validation and Parity Hardening。
- Paper Session Runtime v1。
- Paper Execution Workflow v1。
- NautilusTrader reference study。

当前可进入的下一类施工范围只能从以下方向中选择：

- Workbench information architecture / Dashboard interaction。
- Event timeline and evidence explorer。
- Paper workflow observability and local paper-only control shell。
- Market data replay operations。
- Report artifact taxonomy / export / archive。
- Trading validation v2。

当前仍不得进入：

- Live trading。
- Binance signed endpoint。
- account endpoint。
- listenKey user data stream。
- broker integration。
- real order submit / cancel / replace。
- OMS。
- real account balance / broker position sync。

## Future Construction Zones

| Zone | 内容 | 为什么未来处理 | Gate |
| --- | --- | --- | --- |
| Live Trading Foundation | signed endpoint、broker adapter、real order lifecycle | 当前 paper-only evidence 尚未形成可运营实盘系统 | Human decision、独立 Project Definition、security / risk / operations gates |
| OMS / Execution Management | order submit / cancel / replace、execution reconciliation | 完整 OMS 会改变核心风险和运行边界 | 独立架构蓝图、adapter capability contract、incident replay |
| Real Portfolio / Account | account state、position sync、real balance | 当前 Portfolio 只表达 paper projection | broker contract、account data audit、read-only / write split |
| Deployment / Operations | packaging、release、telemetry、runtime monitoring | 当前仍以本地开发验证为主 | OPS project、signing / notarization / telemetry gates |
| Advanced Research Platform | 多策略、多标的、长周期数据、参数实验 | 需要更稳定 data operations 和 report artifact taxonomy | market data operations、eval strategy、storage policy |

## Gated / Forbidden Capabilities

| Capability | Blueprint reason | Current status | Required gate |
| --- | --- | --- | --- |
| Live trading | 最终产品可能需要从研究到实盘闭环 | 当前禁止 | Human 新决策 + 独立 Live Project + signed endpoint / broker / risk / ops gate |
| signed endpoint | 实盘订单和账户能力需要 | 当前禁止 | API key / secret policy、adapter capability contract、audit evidence |
| broker action | 最终交易动作需要 | 当前禁止 | broker contract、execution reconciliation、risk gate、rollback policy |
| real order lifecycle | Live / OMS 需要 | 当前禁止 | 完整 OMS blueprint 和 validation |
| real account state | Portfolio / risk live 需要 | 当前禁止 | account endpoint boundary、read model isolation、privacy / ops policy |

## Root Docs Delta Proposal

| Root doc | 建议 delta | 当前处理 |
| --- | --- | --- |
| `GOAL.md` | 保留第一版 paper-only 禁区，同时在未来目标中承认 MTPRO 最终可能包含 gated Live 工作台能力。 | 本 PR 不直接改目标，只在蓝图中提出。 |
| `ENVIRONMENT.md` | 后续可增加 Complete Blueprint Design 作为 docs-only 规划活动，并把 future Live gates 作为未来环境能力。 | 本 PR 不新增运行依赖。 |
| `ARCHITECTURE.md` | 后续可把完整蓝图中的系统结构和 future execution boundary 写入模块地图。 | 本 PR 不改业务架构事实。 |
| `ROADMAP.md` | 后续可在 Product Roadmap 中新增 Complete Blueprint Design Gate 和 Future Construction Zones。 | 本 PR 不授权下一阶段 Project。 |
| `docs/planning/project-role-map.md` | 维护 `@000 / AIE` 与 Human 的 Complete Blueprint Design 职责。 | 已由角色文档维护，本文档不重复职责清单。 |
| `AGENTS.md` | 维护 `@000 / AIE` 的蓝图职责和非授权边界。 | 已由 Agent 手册维护，本文档不重复职责清单。 |

## Linear Planning Handoff

Complete Blueprint Design 完成后，仍不能直接执行。

后续顺序：

```text
Human confirms blueprint
-> Human + @001 / PLN selects Current Construction Scope slice
-> Project Planning Record
-> Human confirms Linear write
-> Linear Project / Issues created as Backlog
-> @002 / PAR startup gate
-> unique eligible issue -> Todo
```

当前 handoff 状态：

- Blueprint drafted: yes
- Human confirmed blueprint: pending
- Current Construction Scope selected: pending
- Next Project Planning authorized: no
- Linear write authorized: no
- `@002 / PAR` authorized: no

## Validation Checklist

- [x] NautilusTrader reference study 被总结为 MTPRO 自己的蓝图，不复制外部项目。
- [x] Final Product Blueprint 与 Current Construction Scope 分离。
- [x] Future Construction Zones 明确。
- [x] Live / signed endpoint / broker / OMS 被标记为 future / gated。
- [x] 蓝图文档只记录蓝图本体；`@000 / AIE` 职责由角色文档和 Agent 手册维护。
- [x] 本文档不创建 Linear Project / Issue。
- [x] 本文档不推进 `Todo`。
- [x] 本文档不启动 Symphony。
- [x] 本文档不写业务代码。
