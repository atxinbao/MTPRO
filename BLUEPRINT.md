# BLUEPRINT.md

日期：2026-05-20

执行者：Human + `@000 / AIE`

## 定位

本文档是 MTPRO 的 canonical Root / Complete Blueprint：Root Blueprint 负责项目总览、默认读取顺序和 Current / Future 边界；Complete Blueprint 负责 Product Blueprint、Architecture Blueprint、Design Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint 和 Blueprint -> Architecture -> Roadmap Handoff。

蓝图本体只维护在根目录 `BLUEPRINT.md`。不再维护 `docs/design/` 下的兼容蓝图入口，避免双写漂移。

本文档不授权执行，不推进 `Todo`，不启动额外调度 / 图谱服务，不写业务代码。只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。

## 默认读取顺序

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `environment.md`
6. `architecture.md`
7. `docs/roadmap.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

执行或验证时，再按当前 issue scope 读取 `docs/contracts/`、`docs/product/`、`docs/validation/`、`docs/automation/agent-engineering-practices.md`、Stage Code Audit Report 和 issue body。完整 `verification.md` 只在审计、追溯或 debug 时读取。

## Root Docs Responsibility Contract

| 文件 | 只回答 | 不负责 |
| --- | --- | --- |
| `GOAL.md` | 为什么建、服务谁、硬边界、成功标准 | 不展开完整系统结构，不决定下一阶段 Project |
| `BLUEPRINT.md` | 最终产品要建成什么，Product / Architecture / Design Blueprint 如何组织，Current / Future 如何分界 | 不记录完成进度条，不替代 `docs/roadmap.md`，不授权 Linear execution |
| `environment.md` | 当前环境、验证入口、外部系统使用边界和禁区 | 不定义工程模块，不决定施工顺序 |
| `architecture.md` | Engineering Module Map / 工程模块地图：承接 `BLUEPRINT.md`，把蓝图翻译为工程模块、模块边界、数据流、接口、约束和技术分层 | 不重新定义产品目标，不记录 Stage Audit 流水账 |
| `docs/roadmap.md` | 根据蓝图和工程模块定义施工顺序、当前已批准阶段、目标切片、Project closure、下一步 planning handoff | 不替代蓝图，不创建 Linear，不推进 `Todo` |

`architecture.md`、`environment.md` 是根目录高权重承接文档，`docs/roadmap.md` 是施工路线文档。目标冲突先看 `GOAL.md`；终局设计和 Future Construction Zones / 未来建设区先看 `BLUEPRINT.md`；施工进度先看 `docs/roadmap.md`。

## 来源

| 来源层 | 代表文件 / 目录 | 用途 |
| --- | --- | --- |
| Root docs | `GOAL.md`、`environment.md`、`architecture.md`、`docs/roadmap.md` | Project Charter、环境边界、工程模块地图和施工路线 |
| Domain / practices | `docs/domain/context.md`、Agent Engineering Practices | shared language、执行纪律、验证约定 |
| Reference / delta | `docs/reference/nautilus-trader/`、Root Docs Delta Proposal | NautilusTrader 参考研究和 delta proposal |
| Product / design | `docs/product/`、`docs/design/` | Product surface、interaction model、Workbench dashboard、Live readiness、screen layout 和 visual rules |
| Planning / audit | `docs/planning/projects/`、`docs/audit/`、`docs/validation/trading-validation-matrix.md` | Project Planning Record、Stage Code Audit Reports 和交易语义验证证据 |

保留的机器锚点：`docs/domain/context.md`；Agent Engineering Practices；Root Docs Delta Proposal；`docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；`docs/audit/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`docs/audit/mtpro-release-v0.1.0-binance-ema-runtime-stage-code-audit.md`；`docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md`；`docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`；`docs/product/mtpro-live-readiness-roadmap-v1.md`。

## Blueprint Design Lenses / 蓝图设计视角

| 视角 | 需要回答 | 落到本文档 |
| --- | --- | --- |
| Product / 产品 | 服务谁、解决什么问题、主路径是什么、为什么用户可信 | Product Blueprint、Final Product Goal Slices、Product Workflow Blueprint |
| Architecture / 架构 | 什么系统能力支撑最终产品、模块怎么分层、Paper / Live 怎么隔离 | Architecture Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint |
| Design / 工作台设计 | 用户在界面中看到什么、怎么理解状态、怎么操作、如何避免误触实盘 | Design Blueprint、Current / Future Boundary、Live Gate Blueprint |

Product 定义服务对象和工作流；Architecture 定义系统承载能力；Design 定义用户如何看见 evidence、状态、操作和禁区。Goal / Blueprint / Engineering Module / Roadmap 分工明确；Product / Architecture / Design Blueprint 三线明确。

## Product Blueprint / 产品蓝图

MTPRO 最终要成为一个 local-first 的 macOS 原生专业交易工作台。它先完成 Research -> Backtest -> Report -> Paper 的本地证据链，再演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

产品可信度来自 evidence chain：数据来源、策略信号、回测结果、Paper 行为、风险证据、组合变化、事件时间线和报告 artifact 都必须可追溯、可回放、可验证。Future Live 必须作为独立 Future Construction Zones / 未来建设区进入，不能从 paper-only 能力偷渡。

## Final Product Goal Slices

| # | 目标切片 | 当前状态 |
| --- | --- | --- |
| 1 | Research / Backtest / Report foundation | Complete |
| 2 | Paper execution foundation | Complete |
| 3 | Workbench evidence navigation and local control shell | Complete |
| 4 | Market data replay operations | Complete |
| 5 | 实盘交易基础边界 | Complete / boundary + blocked evidence |
| 6 | 实盘监控台 | Complete / read-model-only evidence surface |
| 7 | 实盘执行控制 | Complete / contract + blocked evidence |
| 8 | 实盘风险控制 | Complete / contract + blocked evidence |
| 9 | 实盘审计 / 事故回放 / 停机控制 | Complete / contract + blocked evidence |

Current Foundation Progress 已完成 4 / 4；Final Product Goal Progress 当前为 9 / 9。完整进度口径由 `docs/roadmap.md` 维护，蓝图只定义目标结构。

## Target Users / Jobs

| 用户 | 核心任务 | MTPRO 应提供 |
| --- | --- | --- |
| 个人专业交易者 / 独立策略研究者 | 用 Binance public market data 研究策略和市场状态 | Research / Backtest / Report / Paper evidence 工作台 |
| 策略验证用户 | 确认 backtest、paper、risk、cost、portfolio evidence 是否一致 | trading validation matrix、report artifact、event timeline |
| Paper readiness 用户 | 在不触碰真实交易的前提下观察 paper workflow | paper-only session、order intent、simulated fill、portfolio projection |
| 未来实盘准备用户 | 判断何时可以独立进入 Live 规划 | Live future zone、blocked gates、禁区说明和风险条件 |

## Complete Capability Map

当前 foundation 已覆盖 Binance public read-only ingest、Event Log / Replay、Research / Backtest / Report、Trading Validation、Paper Session Runtime、Paper Execution Workflow、Dashboard / Workbench、Market Data Replay Operations、Portfolio / Risk paper-only evidence。Release line 已推进到 v0.11.0 production readiness evidence runtime + integrity hardening，但 production trading disabled by default，production cutover not authorized。

Historical release line anchor retained：Release line 已推进到 v0.10.0 production cutover readiness gate。
Historical release line anchor retained：Release line 已推进到 v0.9.0 testnet no-order observability。
Historical release line anchor retained：Release line 已推进到 v0.8.0 persistent operator runtime + testnet read-only monitoring。
Historical release line anchor retained：Release line 已推进到 v0.7.0 operator runtime session + real testnet read-only connectivity。
Historical release line anchor retained：Release line 已推进到 v0.6.0 local operational runtime + testnet read-only probe hardening。

Future / gated capability 必须独立规划：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制、OMS / broker integration、real portfolio / account、deployment / operations 和 advanced research platform。

## Product Workflow Blueprint

```text
Market Data -> Research -> Backtest -> Report -> Paper Session
-> Paper Execution Evidence -> Portfolio / Risk / Events
-> Future gated Live trading foundation
-> Completed read-model-only Live monitoring
-> Future gated live execution control / risk control / audit
-> Stage Audit -> Future gated Live decision
```

Workbench 的主导航以 evidence navigation 为中心，不以交易按钮为中心。用户看到的是工作区、状态、证据、回放和阻断原因；不能看到可执行的实盘下单入口。Figma / product / design 文档只作为产品、交互、布局、视觉和 dashboard 参考，不是 SwiftUI 实现稿、组件库、Live PRO Console、实盘操作台或 Linear execution 授权。

Strategy / Trader layout machine anchors：`Sources/Trader/Strategies/<strategy>` 是 forward-looking canonical layout；旧 `Sources/Strategies/<strategy>` 只能作为 historical / compatibility / superseded path；当前 closure 口径为 `Trader = Accounts + Strategies + Coordination`，binding / adapter 语义归入 `Trader/Coordination`。

## Architecture Blueprint / 架构蓝图

本节承接 Product Blueprint，把最终产品要求翻译为系统结构原则。具体模块边界、数据流、接口、约束和技术分层由 `architecture.md` 维护。

```text
Adapters -> Runtime ingest -> Core domain / kernel -> MessageBus / Cache
-> Strategy -> Risk -> Paper / future Live execution boundary
-> Portfolio -> Event Log -> Replay -> Projections -> Read Models
-> ViewModels -> Workbench -> Report / Audit
```

核心原则：Core 保存稳定领域语义；Adapter 能力必须显式声明；Event Log 是 append-only facts source；Replay 是跨 Research / Backtest / Paper / future Live 的审计能力；SQLite / DuckDB 是 projection，不是 UI contract；App / Dashboard 只消费 ViewModel / Read Model；Future Live 必须有独立 adapter capability、risk gate、reconciliation evidence、operations readiness 和 audit trail。

## Design Blueprint / 工作台设计蓝图

MTPRO Workbench surface：Overview、Research、Backtest、Report、Paper、Portfolio、Risk、Events、Operations、Live Readiness、Live Monitoring 和 Future Live placeholder。当前 UI 仍保持 read-model-only，不提供真实交易按钮，不直接读取 database schema、adapter request 或 runtime object。

产品层交互模型、screen layout、UI/UX rules、component layout、visual style、dashboard high-fidelity 和 reference gap map 由 `docs/product/`、`docs/design/`、`docs/reference/` 承接。它们只定义用户动线、页面角色、信息优先级、状态边界和禁止动作，不授权 SwiftUI implementation、Live PRO Console、broker adapter、OMS、real order lifecycle、live risk runtime、reconciliation runtime、incident replay runtime 或 production operations。

## Infrastructure Blueprint / 基础设施蓝图

长期 evidence chain：

```text
Market event -> Strategy signal -> Backtest / Paper parity evidence
-> Cost assumption -> Risk decision -> Paper order intent
-> Simulated fill evidence -> Portfolio projection -> Report artifact
-> Event log / replay evidence -> Stage Code Audit
```

基础设施必须覆盖 Data infrastructure、Trading evidence infrastructure、Read / command infrastructure、Audit infrastructure 和 Automation infrastructure。Linear、Parent Codex queue preflight、Codex Execution Agent、GitHub PR Automation、Post-Issue Ledger 和 Root Docs Refresh 只服务 evidence flow，不自动授权下一阶段。

## Trading Capability Blueprint / 交易能力蓝图

当前 paper-only 能力：

```text
Strategy signal -> Paper action proposal -> Risk blocker evidence
-> Paper order intent -> Simulated fill evidence -> Paper portfolio projection
-> Report / Dashboard / Event Timeline evidence
```

Future live 能力：

```text
Strategy signal -> Live risk decision -> Real order intent
-> Broker / exchange adapter -> Execution report / fill
-> Real portfolio / account state -> Reconciliation
-> Audit / incident replay / stop controls
```

Future live 能力必须作为独立 Project Definition 和独立 execution contract 进入，不能从 paper-only 类型、命令或 ViewModel 偷渡。

## Live Gate Blueprint / 实盘准入蓝图

进入 Live 前必须至少满足 Human 独立确认、独立 Project Definition、API key / secret policy、signed endpoint / account endpoint / listenKey capability contract、broker / exchange adapter capability contract、real order submit / cancel / replace contract、live risk gate、熔断、禁交易状态、stop controls、execution reconciliation、account / position sync、incident replay、operations readiness、monitoring、rollback / shutdown policy。

任何缺少上述 gate 的变更都只能作为 Future Construction Zone 记录在蓝图中，不能进入 Linear execution。

## Current / Future Boundary / 当前与未来边界

当前 foundation / final product 采用两层进度口径：

- Current Foundation Progress：4 / 4（100%）。
- Final Product Goal Progress：9 / 9（100%）。
- Engine Maturity Roadmap Progress：4 / 4（100%）。
- Engine Maturity Roadmap Progress：4 / 4（100%）

当前完成事实压缩为阶段族，详细证据以 `docs/audit/`、`docs/roadmap.md` 和 `docs/validation/latest-verification-summary.md` 为准。

| 阶段族 | 已完成事实 | 仍不授权 |
| --- | --- | --- |
| Paper / data / parity / beta | `MTPRO Event-Driven Paper Trading Runtime v1`、`MTPRO Data Catalog / Scenario Replay v1` 已由 Parent Codex 完成 Project closure、`MTPRO Simulated Exchange / Backtest Parity v1` 已由 Parent Codex 完成 Project closure、`MTPRO Workbench Beta Readiness v1` 已由 Parent Codex 完成 Project closure | signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command |
| L3 read-model readiness | `MTPRO Live Read-only Readiness Boundary v1`、`MTPRO Account / Position / Balance Read-model-only v1`、Private Stream / Snapshot simulation、Live Monitoring v2、Strategy / Trader readiness 已完成 | 真实 Live read-only runtime、private WebSocket runtime、real account read、broker position sync、real balance、real PnL、live command |
| Trader / target graph | `MTPRO Trader-Owned Strategies Layout Correction v1`、`MTPRO Trader EMA Strategy Layout Consolidation v1`、`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1`、`MTPRO SwiftPM Target Graph Module Split v1` 已完成 Project closure、TargetGraph Anchor Retirement 已完成 | Strategy runtime、Trader runtime、SwiftPM target graph 再拆、ExecutionClient implementation、OMS、broker gateway、L4 implementation |
| Core envelope / L4 / production readiness | Core Envelope Retirement / Real Module Ownership Completion before L4 complete；`MTPRO L4 Live Production / Trading Commands v1` Done / no-default-production-trading；`MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` Done / readiness-only | production cutover、production secret read、production endpoint、real broker gateway、real submit / cancel / replace、Live PRO Console production command、order form、trading button |
| Release line | `MTPRO Release v0.1.0` Done / Binance + EMA runtime validation / production disabled by default；`MTPRO Release v0.2.0`、v0.3.x、v0.4.0、v0.5.0、`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`、`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`、`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`、`MTPRO Release v0.9.0 Testnet No-order Observability`、`MTPRO Release v0.10.0 Production Cutover Readiness Gate`、`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`、`MTPRO Release v0.12.0 Readiness Assessment Sessions` 均作为后续 release evidence 记录；Current maturity statement：`MTPRO Release v0.12.0 Readiness Assessment Sessions complete with production trading disabled by default and production cutover not authorized` | 自动进入下一阶段、production cutover、production trading、non-gated broker connection、默认真实订单、testnet order routing |

Historical Core Envelope Retirement / Real Module Ownership Completion evidence 仍保留：PR #448 后完成 final residual hardening audit，确认 production executable `try!` = 0、`@unchecked Sendable` = 0、open GitHub issue / PR = 0。

## Future Construction Zones / 未来建设区

Future Construction Zones / 未来建设区指完整产品蓝图里明确需要但当前不施工的长期能力区。它们可以被蓝图描述，但不能自动变成当前 Project、Linear issue 或执行授权。主要 zones：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制、OMS / Execution Management、Real Portfolio / Account、Deployment / Operations、Advanced Research Platform。

## Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力

Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力指未来可能需要，但当前必须被门禁或禁止的能力。进入这些能力前必须先有独立 Human decision、独立 Project Definition、清晰的 signed endpoint / broker / risk / operations gates，以及可审计的验证证据。Live / signed endpoint / broker / OMS 均属此类。

## Execution / Automation Blueprint

- Human + `@000 / AIE`：完整蓝图设计、docs-only PR、验证和边界守护。
- Human + `@001 / PLN`：蓝图确认后的下一阶段 Project / Issue 草案。
- `@002 / PAR`：Project 写入 Linear 后，执行 queue preflight、eligible issue 调度、child Codex 监督、Stage Code Audit。
- Codex Execution Agent：只执行 Parent Codex queue preflight 推进后的当前唯一 issue scope。
- GitHub PR Automation：required checks、auto-merge、squash merge、Linear bot auto Done。

完整蓝图不触发上述执行层。

## Blueprint -> Architecture -> Roadmap Handoff / 蓝图到架构和路线交接

```text
GOAL.md -> BLUEPRINT.md -> architecture.md -> docs/roadmap.md -> Linear Project / Issues
```

当前 handoff 状态：`MTPRO Release v0.1.0` 已完成 GitHub fallback issue chain、Final Stage Code Audit 和 Root Docs Refresh Gate。GH-521 至 GH-541 全部 closed / done，PR #542 至 #561 全部 merged 且 required check `checks` SUCCESS。该 release 完成 Binance + EMA runtime validation、public market data -> DataEngine / Cache、signed account read-only runtime、private stream / account snapshot read-model runtime、Trader / EMA / RiskEngine / ExecutionEngine / ExecutionClient testnet evidence、Dashboard release monitoring / controlled command surfaces、kill switch / no-trade / rollback controls、dry-run / testnet validation suite、no-default-production-trading automation guard、release docs / operator runbook、validation matrix closeout 和 final audit。结论为 `MTPRO Release v0.1.0 Binance + EMA runtime validation complete with production trading disabled by default`；production trading、production secret usage、production endpoint、production broker endpoint、automatic broker connection、non-Binance venue、non-EMA active strategy、Live PRO Console production command、live command、order form、trading button 和任何 default real trading 仍关闭。

Additional retained closure anchors：`docs/audit/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；`mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；PR #448 后完成 final residual hardening audit；production executable `try!` = 0。

## Blueprint Update Rule

修改本文档时必须保持三条线分开：Product / Architecture / Design Blueprint 可以描述长期终局；Current Construction Scope 只能描述已经完成或 Human 明确允许进入 planning 的当前施工范围；Execution Authorization 只能来自 live queue source 中唯一 configured executable issue。

因此，本文档可以帮助 `@001 / PLN` 形成下一阶段 Project 草案，但不能直接创建 Linear Project / Issue，不能推进 `Todo`，不能启动 `@002 / PAR` 或任何额外 issue 调度服务。

## Validation Checklist

已确认：NautilusTrader reference study 和 `mattpocock/skills` 已收敛为 MTPRO 自己的蓝图、shared language、feedback loop、diagnosis 和 handoff 规则；Root Blueprint 和 Complete Blueprint 已统一到根目录 `BLUEPRINT.md`；Goal / Blueprint / Engineering Module / Roadmap 分工明确；Product / Architecture / Design Blueprint 三线明确；Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Blueprint -> Architecture -> Roadmap Handoff、Future Construction Zones / 未来建设区均已明确；Live / signed endpoint / broker / OMS 被标记为 future / gated。

## 执行边界

`BLUEPRINT.md`、`docs/roadmap.md`、Project Planning Record、Backlog issue、label、priority 和 assignee 都不授权执行。只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。
