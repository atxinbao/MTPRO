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

## Role Coverage

| Role | Primary responsibility | Required artifacts | Covered by | Status |
| --- | --- | --- | --- | --- |
| Human Owner | 确认 MTPRO 目标、阶段取舍、Linear 写入和下一阶段验收 | GOAL / Linear Project confirmation / Stage decision | Human | covered |
| ChatGPT Planning Partner | 问答式收敛目标、拆分阶段、辅助 Linear issue 规划和阶段复盘 | Project guidance notes / Linear Draft / next planning notes | ChatGPT | covered |
| System Architect | 维护 MTPRO 架构边界、模块关系、事件流和自动化边界 | `ARCHITECTURE.md` / module boundary / API boundary | Human + ChatGPT + Parent Codex | partial |
| Product / Frontend Designer | 定义 Research / Backtest / Report / Paper readiness 产品面、页面骨架和 ViewModel 稳定输入 | Product Surface Map / Frontend ViewModel Contract / future wireframes | Human + ChatGPT | partial |
| Backend Engineer | 定义并实现 use case、API boundary、worker / engine boundary 和 issue scope 内代码 | Backend Use Case Contract / API Contract / implementation PR | Codex Execution Agent | partial |
| Data / Persistence Designer | 定义市场数据、事件日志、回测结果、report artifact、Read Model 和 persistence 边界 | Persistence Boundary / Read Model Projection / data object notes | Human + ChatGPT + Codex | partial |
| QA / Validation Engineer | 定义验证命令、验收证据、回归边界和失败处理 | `docs/validation/validation-plan.md` / `checks/run.sh` / PR evidence | Parent Codex + Codex Execution Agent | covered |
| DevOps / Operations Engineer | 维护 GitHub PR Automation、symphony-issue、Graphify、本地运行和环境边界 | automation readiness / workflow / Post-Issue Ledger | Parent Codex | partial |
| Parent Codex Supervisor | 执行 Project 级 queue preview、child Codex 监控、代码审查、host-side fallback 和 Stage Code Audit | Parent Codex notes / Stage Code Audit Report | Parent Codex | covered |
| Codex Execution Agent | 只执行当前唯一 Linear issue scope，完成实现、验证、PR 和 handoff | Issue PR / validation / handoff marker | Codex child session | covered |

## Artifact Ownership

| Artifact | Primary role | Review role | Required before |
| --- | --- | --- | --- |
| `GOAL.md` | Human Owner / ChatGPT Planning Partner | System Architect | Bootstrap PR |
| `ARCHITECTURE.md` | System Architect | Backend Engineer / Data Designer / DevOps | Bootstrap PR |
| Product Surface Map | Product / Frontend Designer | Human Owner | Bootstrap PR |
| Frontend ViewModel Contract | Product / Frontend Designer | Backend Engineer | Bootstrap PR |
| Backend Use Case Contract | Backend Engineer | System Architect | Bootstrap PR |
| Persistence Boundary | Data / Persistence Designer | Backend Engineer | Bootstrap PR |
| Read Model Projection | Data / Persistence Designer | Product / Frontend Designer | Bootstrap PR |
| API Contract | Backend Engineer | Product / Frontend Designer | Bootstrap PR |
| Linear Project / Issue plan | Human Owner / ChatGPT Planning Partner | Parent Codex Supervisor | Human Project Planning |
| Validation plan | QA / Validation Engineer | Parent Codex Supervisor | symphony-issue |
| Stage Code Audit Report | Parent Codex Supervisor | Human Owner / ChatGPT Planning Partner | Next Human Project Planning |

## Decision Authority

- Human Owner 决定 MTPRO 的项目目标、阶段目标、Linear 写入、是否进入下一阶段。
- ChatGPT Planning Partner 辅助拆分和复盘，但不单独授权执行。
- System Architect 给出架构边界建议，但不替代 Human confirmation。
- Product / Frontend Designer、Backend Engineer、Data / Persistence Designer、QA / Validation Engineer、DevOps / Operations Engineer 只定义各自专业面的合同和验收建议。
- Parent Codex Supervisor 可以做 Project 级审计、child Codex 监控、代码审查和只读 queue preview；不得自动创建下一个 Project。
- Codex Execution Agent 只能执行当前唯一 configured executable issue。

## Automation Role Boundary

- Parent Codex 负责 Project 级监督、host-side fallback、Pre-PR Code Review 和 Stage Code Audit。
- symphony-issue 负责唯一 `Todo` issue 的调度、`Todo` -> `In Progress` 和 `In Progress` -> `In Review`。
- Codex Execution Agent 负责当前 issue scope 内实现、验证、PR、GitHub auto-merge handoff 和本地 handoff marker。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- Graphify 只提供 resource relationship graph、Graphify read context 和 Post-Issue Ledger 关系记账，不授权执行。

## Missing Role Risk

| Missing / weak role | Current risk | Required mitigation |
| --- | --- | --- |
| System Architect partial | 后续 engine / adapter / persistence 边界可能在 issue 执行中漂移 | 下一阶段 Human Project Planning 必须先确认阶段 architecture slice |
| Product / Frontend Designer partial | Research / Backtest / Report 页面与 ViewModel 可能出现不匹配 | 下一阶段 issue 必须先写清 Product Surface / ViewModel 变更 |
| Backend Engineer partial | API / worker / engine use case 可能与前端控制面错位 | 每个 Linear issue 必须包含 Backend Use Case / API boundary |
| Data / Persistence Designer partial | event log、projection、report artifact 可能被混作展示模型 | 数据相关 issue 必须引用 Persistence Boundary 和 Read Model Projection |
| DevOps / Operations Engineer partial | symphony-issue、Graphify、GitHub PR Automation 运行边界可能靠人工记忆 | 自动化相关 issue 必须保留 readiness evidence 和 rollback / fallback notes |

## Validation Checklist

- [ ] Project Role Map 已覆盖系统架构、前端设计、后端开发、数据 / 持久化、质量验证、部署与运营。
- [ ] 每个角色都有至少一个 artifact 或明确的缺口记录。
- [ ] 缺口不会被解释为执行授权。
- [ ] Project Role Map 不替代 `GOAL.md`、`ARCHITECTURE.md`、`ROADMAP.md`、Linear Project 或 Linear issue。
- [ ] Project Role Map 不修改 Linear status。
- [ ] Project Role Map 不启动 symphony-issue、Graphify update 或 GitHub PR Automation。
- [ ] Project Role Map 不授权 Codex Execution Agent 扩大当前 issue scope。
