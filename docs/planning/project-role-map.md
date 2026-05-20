# MTPRO Project Role Map

日期：2026-05-17

执行者：Codex

本文档记录 MTPRO 当前阶段的项目能力角色、职责边界和交付物归属。

它不是执行授权，不替代 Linear Project / Issue，不替代 `GOAL.md`、`ARCHITECTURE.md`、`ROADMAP.md`，不修改 Linear status，不启动 symphony-issue，不创建 PR。

## Source

- Project：MTPRO
- Repository：`/Users/mac/Documents/MTPRO`
- Current stage：`MTPRO 引导` 已完成，下一阶段等待 Human Project Planning
- Source `GOAL.md`：`/Users/mac/Documents/MTPRO/GOAL.md`
- Source `ARCHITECTURE.md`：`/Users/mac/Documents/MTPRO/ARCHITECTURE.md`
- Source `ROADMAP.md`：`/Users/mac/Documents/MTPRO/ROADMAP.md`
- Source Linear Project：`MTPRO 引导`
- AEP reference：`/Users/mac/code/ai-engineering-protocol/templates/project-role-map-template.md`

## Role Alias Map

三位数字编号和三字母角色代号等价，例如 `@000 = AIE`、`@001 = PLN`。

角色编号只用于沟通压缩，不改变职责边界，不授权执行。

`@000 / AIE` 是 AI Engineer 角色，也是当前 Codex 协作入口。它负责理解 Human 指令、读取 root docs、选择正确仓库与流程、执行明确授权的代码 / 文档修改、维护验证与 PR handoff，并在需要时把任务路由给 `@001` 至 `@007`。

当 Human 明确要求完整蓝图设计时，`@000 / AIE` 和 Human 共同负责 MTPRO Complete Blueprint Design。该职责高于单个 Linear Project Planning，用于把 NautilusTrader reference study、Stage Code Audit Reports、root docs 和现有代码能力收敛成 MTPRO 的 Final Product Blueprint、System Architecture Blueprint、Workbench / UX Blueprint、Current Construction Scope 和 Future Construction Zones。

`@000 / AIE` 不替代 Human decision，不绕过 Linear configured executable issue，不替代 `@001 / PLN` 的下一阶段 Project Planning，不替代 `@002 / PAR` queue 调度或 Linear 外 reference 研究角色。Complete Blueprint Design 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 symphony-issue，不写业务代码。

`@003 / PRD`、`@004 / DSG`、`@005 / ARC` 是 Linear 外的 reference / root docs 角色。它们用于外部参考项目研究、产品 / 设计 / 架构差距分析，以及 `GOAL.md`、`ARCHITECTURE.md`、`ENVIRONMENT.md`、`ROADMAP.md` 的 delta proposal。它们不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 symphony-issue，不写业务代码。

| 编号 | 代号 | 角色 | MTPRO 当前使用方式 |
| --- | --- | --- | --- |
| `000` | `AIE` | AI Engineer | 当前 Codex 协作入口、Complete Blueprint Design、任务理解、仓库 / 流程选择、代码 / 文档执行、验证、PR handoff、角色路由和边界守护 |
| `001` | `PLN` | Project Planning Lead | Next Human Project Planning、阶段目标、Linear Project / Issue 草案 |
| `002` | `PAR` | Parent Codex Automation Supervision | queue preview、eligible issue 调度、child Codex 监督、Stage Code Audit、当前阶段完成进度条 |
| `003` | `PRD` | Product Reference Lead | Linear 外产品参考研究、用户路径、工作台能力、`GOAL.md` / `ROADMAP.md` / `docs/product/*` delta proposal |
| `004` | `DSG` | Design Reference Lead | Linear 外页面结构、信息架构、Dashboard / Workbench 状态与 ViewModel 映射 delta proposal |
| `005` | `ARC` | Architecture Reference Lead | Linear 外系统结构参考、模块边界、event / replay / adapter / runtime / execution 语义映射 delta proposal |
| `006` | `QAV` | QA / Trading Validation | XCTest、fixture、交易语义验证、失败归因、回归边界 |
| `007` | `OPS` | Operations | 本地环境、运行、Graphify / Symphony / GitHub 自动化可用性 |

symphony-issue、Codex Execution Agent 和 GitHub PR Automation 是流程工具 / 执行层 actor，按名称调用，不占用 `@003`、`@004`、`@005` 编号。

## AI Engineer Boundary

| 角色编号 | 当前职责 | 产物 | 禁止 |
| --- | --- | --- | --- |
| `@000 / AIE` | 作为当前 Codex 协作入口，读取 root docs 和最近验证摘要，判断任务属于完整蓝图设计、规划、自动化监督、reference 研究、issue 执行、文档修订还是环境操作；在 Human 明确要求时与 Human 共同推进 Complete Blueprint Design；在明确任务范围内直接改代码 / 文档、运行验证、提交 PR；必要时输出给 `@001` 至 `@007` 的角色化指令 | `BLUEPRINT.md`、代码 / 文档 PR、validation summary、PR handoff、角色化 Codex 指令、边界确认 | 不替代 Human decision，不绕过 Linear configured executable issue，不替代 `@001 / PLN` 的下一阶段 Project Planning，不替代 `@002 / PAR` queue 调度，不替代 reference roles 的研究结论，不直接 merge 自己的 PR |

## Reference Role Boundary

| 角色编号 | 当前职责 | 产物 | 禁止 |
| --- | --- | --- | --- |
| `@003 / PRD` | 阅读外部参考项目的产品能力、用户路径、工作台流程和 acceptance 组织方式，提炼 MTPRO 应该采用 / 不采用的产品决策 | `docs/reference/*/product-reference.md`、`GOAL.md` / `ROADMAP.md` / `docs/product/*` delta proposal | 不创建 Linear Project / Issue，不推进 `Todo`，不写业务代码，不把参考项目能力直接当成 MTPRO scope |
| `@004 / DSG` | 阅读外部参考项目的信息架构、页面组织、操作路径、状态表达和工作台结构，提炼 Dashboard / Workbench / ViewModel 设计建议 | `docs/reference/*/design-reference.md`、Product Surface / Frontend ViewModel delta proposal | 不写 UI 代码，不启动 symphony-issue，不把 wireframe / 页面建议当作执行授权 |
| `@005 / ARC` | 阅读外部参考项目源码、官方文档和 API 文档，提炼 event-driven、replay、adapter、runtime、portfolio、risk、execution 等系统结构参考 | `docs/reference/*/architecture-reference.md`、`api-reference-map.md`、`ARCHITECTURE.md` / `ENVIRONMENT.md` / `docs/contracts/*` delta proposal | 不重写架构，不引入 Live trading / signed endpoint / broker action，不把外部 API 直接映射为实现任务 |

Reference role 输出必须先形成 reference pack 和 delta proposal。完整产品 / 系统 / 设计蓝图由 Human + `@000 / AIE` 共同收敛。只有蓝图中的 Current Construction Scope 被 Human 选中，并交给 Human + `@001 / PLN` 进入下一阶段 Project Planning 后，才可能转化为 Linear Project / Issue。

## Role Coverage

| Role | Primary responsibility | Required artifacts | Covered by | Status |
| --- | --- | --- | --- | --- |
| Human Owner | 确认 MTPRO 目标、阶段取舍、Linear 写入和下一阶段验收 | GOAL / Linear Project confirmation / Stage decision | Human | covered |
| ChatGPT Planning Partner | 问答式收敛目标、拆分阶段、辅助 Linear issue 规划和阶段复盘 | Project guidance notes / Linear Draft / next planning notes | ChatGPT | covered |
| AI Engineer | 作为 Codex 协作入口执行明确任务、维护 Complete Blueprint Design、代码 / 文档 / 验证 / PR handoff，并把任务路由到对应角色规则 | Complete Blueprint / Code / docs PR / validation / role-specific instruction | Codex `@000 / AIE` | covered |
| System Architect | 维护 MTPRO 架构边界、模块关系、事件流和自动化边界 | `ARCHITECTURE.md` / module boundary / API boundary | Human + ChatGPT + Parent Codex | partial |
| Product Owner | 定义 Research -> Backtest -> Report -> Paper readiness 主路径、阶段目标和验收重点 | Product Surface Map / Linear Project acceptance / stage decision | Human + ChatGPT | partial |
| Product Designer | 定义页面骨架、用户路径、空状态、错误状态和可观察状态 | Product Surface Map / future wireframes / UI state notes | Human + ChatGPT | partial |
| Frontend / App Designer | 定义 SwiftUI shell、ViewModel 稳定输入、dashboard 信息架构和 macOS 交互边界 | Frontend ViewModel Contract / Dashboard ViewModel / macOS build-run notes | Human + ChatGPT + Codex | partial |
| Backend Engineer | 定义并实现 use case、API boundary、worker / engine boundary 和 issue scope 内代码 | Backend Use Case Contract / API Contract / implementation PR | Codex Execution Agent | partial |
| Data / Persistence Designer | 定义市场数据、事件日志、回测结果、report artifact、Read Model 和 persistence 边界 | Persistence Boundary / Read Model Projection / data object notes | Human + ChatGPT + Codex | partial |
| Finance / Trading Domain Analyst | 定义策略假设、交易语义、手续费 / 滑点假设、风险指标、Paper parity 和 Live trading 禁区 | Trading validation notes / strategy assumptions / risk metric notes | Human + ChatGPT + Parent Codex | partial |
| QA / Trading Validation Engineer | 定义验证命令、交易语义验收、回归边界、失败处理和 PR evidence | `docs/validation/validation-plan.md` / `checks/run.sh` / PR evidence / trading validation matrix | Parent Codex + Codex Execution Agent | covered |
| Automation / Runtime Operations Engineer | 维护 GitHub PR Automation、symphony-issue、Graphify、本地运行、credential 边界、runtime readiness 和环境健康 | automation readiness / workflow / Post-Issue Ledger / macOS build-run loop | Parent Codex | partial |
| Parent Codex Supervisor | 执行 Project 级 queue preview、child Codex 监控、代码审查、host-side fallback、Stage Code Audit 和当前阶段完成进度条 | Parent Codex notes / Stage Code Audit Report / Current Phase Progress Bar | Parent Codex | covered |
| Codex Execution Agent | 只执行当前唯一 Linear issue scope，完成实现、验证、PR 和 handoff | Issue PR / validation / handoff marker | Codex child session | covered |

## Team View

| Codex Team | MTPRO 角色 | 负责内容 | 当前缺口 |
| --- | --- | --- | --- |
| Product | Human Owner / Product Owner / ChatGPT Planning Partner | 阶段目标、用户主路径、acceptance、Linear Project planning | 下一个 Project 进入前需要重新确认阶段目标和验收标准 |
| Design | Product Designer / Frontend / App Designer | Research / Backtest / Report / Paper readiness 页面、ViewModel、空状态、错误状态、可观察状态 | UI 阶段前需要补 wireframe 和 macOS build / run loop |
| Engineering | System Architect / Backend Engineer / Data / Persistence Designer / Codex Execution Agent | Core、Adapters、Persistence、App、API boundary、event flow 和实现 PR | 每个 issue 必须保持 contract-first 和模块边界 |
| Finance | Finance / Trading Domain Analyst | 策略假设、market data 语义、fees / slippage、risk、portfolio、Backtest / Paper parity、Live 禁区 | 后续策略 issue 必须补交易假设和风险指标 |
| Operations | Automation / Runtime Operations Engineer / Parent Codex Supervisor | GitHub PR Automation、symphony-issue、Graphify、Post-Issue Ledger、credential、runtime readiness | UI / runtime 阶段前需要补本地运行和 telemetry evidence |
| QA | QA / Trading Validation Engineer / Parent Codex Supervisor | XCTest、fixture、trading validation、PR evidence、Codex review、regression | eval 框架暂不引入；先用 XCTest + fixtures |

## Artifact Ownership

| Artifact | Primary role | Review role | Required before |
| --- | --- | --- | --- |
| `GOAL.md` | Human Owner / ChatGPT Planning Partner | System Architect | Bootstrap PR |
| `ARCHITECTURE.md` | System Architect | Backend Engineer / Data Designer / DevOps | Bootstrap PR |
| Product Surface Map | Product Owner / Product Designer | Human Owner | Bootstrap PR |
| Frontend ViewModel Contract | Frontend / App Designer | Backend Engineer | Bootstrap PR |
| Backend Use Case Contract | Backend Engineer | System Architect | Bootstrap PR |
| Persistence Boundary | Data / Persistence Designer | Backend Engineer | Bootstrap PR |
| Read Model Projection | Data / Persistence Designer | Frontend / App Designer | Bootstrap PR |
| API Contract | Backend Engineer | Product Owner / Frontend / App Designer | Bootstrap PR |
| Trading assumptions / risk notes | Finance / Trading Domain Analyst | Product Owner / QA | Strategy issue |
| Linear Project / Issue plan | Human Owner / ChatGPT Planning Partner / Project Planning Facilitator | Parent Codex Supervisor | Human Project Planning |
| Validation plan | QA / Trading Validation Engineer | Parent Codex Supervisor | symphony-issue |
| Stage Code Audit Report | Parent Codex Supervisor | Human Owner / ChatGPT Planning Partner | Next Human Project Planning |
| Current Phase Progress Bar | Parent Codex Supervisor | Human Owner / ChatGPT Planning Partner | Root Docs Refresh Gate closure 后 |
| MTPRO Complete Blueprint Design | Human Owner / `@000 / AIE` | Product / Design / Architecture reference roles | Next Human Project Planning 前 |

## Decision Authority

- Human Owner 决定 MTPRO 的项目目标、阶段目标、Linear 写入、是否进入下一阶段。
- ChatGPT Planning Partner 辅助拆分和复盘，但不单独授权执行。
- `@000 / AIE` 与 Human 共同维护 MTPRO Complete Blueprint Design；蓝图可以描述最终产品长期能力，但不授权执行，不写 Linear，不启动 `@002 / PAR`。
- System Architect 给出架构边界建议，但不替代 Human confirmation。
- Product Owner、Product Designer、Frontend / App Designer、Backend Engineer、Data / Persistence Designer、Finance / Trading Domain Analyst、QA / Trading Validation Engineer、Automation / Runtime Operations Engineer 只定义各自专业面的合同和验收建议。
- Finance / Trading Domain Analyst 不授权 Live trading，不允许扩大到真实 broker action；它只定义策略假设、风险指标、费用 / 滑点和 Paper parity 验收。
- Project Planning Facilitator 只负责 Project / Issue 草案、顺序、依赖、validation、evidence 和 Linear 写入准备；不得操作 `Backlog` -> `Todo`，不得启动 symphony-issue。
- Parent Codex Supervisor 可以做 Project 级自动调度、child Codex 监控、代码审查、queue preview、Stage Code Audit 和当前阶段完成进度条；不得自动创建下一个 Project。
- Codex Execution Agent 只能执行当前唯一 configured executable issue。

## Automation Role Boundary

- Parent Codex 负责 Project 级监督、host-side fallback、Pre-PR Code Review、Stage Code Audit 和 Current Phase Progress Bar。
- symphony-issue 负责唯一 `Todo` issue 的调度、`Todo` -> `In Progress` 和 `In Progress` -> `In Review`。
- Codex Execution Agent 负责当前 issue scope 内实现、验证、PR、GitHub auto-merge handoff 和本地 handoff marker。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- Graphify 只提供 resource relationship graph、Graphify read context 和 Post-Issue Ledger 关系记账，不授权执行。

## Missing Role Risk

| Missing / weak role | Current risk | Required mitigation |
| --- | --- | --- |
| System Architect partial | 后续 engine / adapter / persistence 边界可能在 issue 执行中漂移 | 下一阶段 Human Project Planning 必须先确认阶段 architecture slice |
| Product Owner partial | Research -> Backtest -> Report -> Paper readiness 主路径可能在 issue 执行中漂移 | 每个阶段 Project 必须先确认用户主路径和 acceptance |
| Product Designer partial | 页面骨架、空状态、错误状态和操作路径可能缺失 | UI 相关 issue 必须先写清 surface / state / interaction |
| Frontend / App Designer partial | ViewModel 与 macOS App shell 可能脱节 | App 相关 issue 必须引用 Frontend ViewModel Contract 和 macOS build-run loop |
| Finance / Trading Domain Analyst partial | 策略实现可能缺少费用、滑点、风险和 Paper parity 验收 | 策略相关 issue 必须包含 trading assumptions、risk metrics 和 parity validation |
| Backend Engineer partial | API / worker / engine use case 可能与前端控制面错位 | 每个 Linear issue 必须包含 Backend Use Case / API boundary |
| Data / Persistence Designer partial | event log、projection、report artifact 可能被混作展示模型 | 数据相关 issue 必须引用 Persistence Boundary 和 Read Model Projection |
| Automation / Runtime Operations Engineer partial | symphony-issue、Graphify、GitHub PR Automation、runtime readiness 可能靠人工记忆 | 自动化和 runtime issue 必须保留 readiness evidence、telemetry 和 fallback notes |

## Validation Checklist

- [ ] Project Role Map 已覆盖 Product、Design、Engineering、Finance、Operations、QA。
- [ ] Project Role Map 已覆盖系统架构、前端设计、后端开发、数据 / 持久化、交易语义、质量验证、部署与运营。
- [ ] 每个角色都有至少一个 artifact 或明确的缺口记录。
- [ ] 缺口不会被解释为执行授权。
- [ ] Project Role Map 不替代 `GOAL.md`、`ARCHITECTURE.md`、`ROADMAP.md`、Linear Project 或 Linear issue。
- [ ] Project Role Map 不修改 Linear status。
- [ ] Project Role Map 不启动 symphony-issue、Graphify update 或 GitHub PR Automation。
- [ ] Project Role Map 不授权 Codex Execution Agent 扩大当前 issue scope。
