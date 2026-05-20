# AGENTS.md

本文件定义 MTPRO 仓库内 Agent / Codex 的行为边界。

## 必读顺序

Agent 开始工作前必须读取：

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `ENVIRONMENT.md`
6. `ARCHITECTURE.md`
7. `ROADMAP.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

需要实现或验证时，再按 scope 读取：

- `docs/product/product-surface-map.md`
- `docs/automation/agent-engineering-practices.md`
- `docs/contracts/`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/automation/`
- 当前 Linear issue body

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 核心硬规则

- 所有正式文档写入必须使用中文。
- `GOAL.md` 是 Project Charter，`BLUEPRINT.md` 是 Root Blueprint，`ARCHITECTURE.md` 是 Architecture Map，`ROADMAP.md` 是 Construction Plan。
- `docs/domain/context.md` 是 MTPRO shared language；Project Planning、Linear issue、PR、Stage Audit、public type 注释和验证证据必须优先复用其中 canonical terms。
- `docs/automation/agent-engineering-practices.md` 是 skill-derived 工程实践入口；执行 issue 时必须遵守 Feedback Loop First、TDD / Tracer Bullet、Diagnose Loop、Architecture Deepening Review 和 Handoff Discipline。
- `ROADMAP.md`、Project Planning Record、Backlog issue、label、priority、assignee 都不授权执行。
- 只有 Linear live-read 中唯一 configured executable issue 才能授权正式开发；执行前必须由 Parent Codex queue preview 确认 WIP=1。
- Linear issue 的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 是 Codex Execution Agent 的执行合同。
- Project Planning Facilitator 只做规划和草案，不执行 issue，不启动 symphony-issue，不操作 `Backlog` -> `Todo`。
- Human 确认 Project / Issue plan 并写入 Linear 后，第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都只能由父 Codex 自动执行。
- 父 Codex 自动调度前必须确认 WIP=1、previous issue Done、依赖满足、执行合同格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- symphony-issue 只调度唯一 `Todo` issue，并负责 `Todo -> In Progress -> In Review` 状态推进。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- Project closure 必须确认 Linear Project status 为 `Completed`，并确认 `type=completed`、`completedAt` 非空。
- Stage Code Audit Report 必须覆盖完整 Linear Project，包含 Linear Project `Completed` evidence 和 Root Docs Delta。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步已发生事实；方向、目标、架构路线和下一阶段优先级必须交给 Human + `@001 / PLN`。
- Root Docs Refresh Gate closure 后，`@002 / PAR` 必须输出当前阶段完成进度条；进度条必须基于 `GOAL.md` 和 `ROADMAP.md` 的 Goal / Roadmap Target Progress 目标切片计算，Project closure 数量只能作为单独证据口径，不写入蓝图文档，不授权下一阶段执行。
- Complete Blueprint Design 是 Human + `@000 / AIE` 的 Linear 外蓝图活动；它可描述 Live / signed endpoint / broker / OMS 等 Future Construction Zones，但不得自动转成 Linear issue。
- Complete Blueprint Design 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Backlog` -> `Todo`，不启动 `@002 / PAR`，不启动 symphony-issue，不运行 Graphify update，不写业务代码。
- 触碰 production behavior 时，优先用 deterministic fixture / test 表达目标行为；不能只靠最终大检查判断正确性。
- Linear issue 应优先拆成可独立验证的 vertical slice / tracer bullet，不把跨层闭环机械拆成无法单独验收的横向模块切片。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- Agent 默认读取 `docs/validation/latest-verification-summary.md`。

## Role Alias Rule

MTPRO 采用 AEP 三位数字编号和三字母角色代号。数字编号与三字母代号等价，例如 `@000 = AIE`、`@001 = PLN`。角色编号只用于沟通压缩，不改变职责边界，不授权执行，不替代 Linear issue、Project planning、GitHub required checks，不替代 Human decision。

完整职责见 `docs/planning/project-role-map.md`。

| 编号 | 代号 | 角色 | MTPRO 职责摘要 |
| --- | --- | --- | --- |
| `000` | `AIE` | AI Engineer | 当前 Codex 协作入口、Complete Blueprint Design、任务理解、代码 / 文档执行、验证、PR handoff、角色路由和边界守护 |
| `001` | `PLN` | Project Planning Lead | 新阶段规划、Next Human Project Planning、Project / Issue 草案、reference synthesis |
| `002` | `PAR` | Parent Codex Automation Supervision | Project queue、eligible issue 调度、child Codex 监督、Stage Code Audit、当前阶段完成进度条 |
| `003` | `PRD` | Product Reference Lead | Linear 外产品参考、用户路径、工作台能力和 root docs delta proposal |
| `004` | `DSG` | Design Reference Lead | Linear 外信息架构、Dashboard / Workbench 页面结构、状态与 ViewModel 映射 delta proposal |
| `005` | `ARC` | Architecture Reference Lead | Linear 外系统结构参考、模块边界、event / replay / adapter / runtime / execution 语义映射 delta proposal |
| `006` | `QAV` | QA / Trading validation | 验证、失败归因、验收证据、Finance / Trading Domain 和回归边界 |
| `007` | `OPS` | Operations | 本地环境、运行、部署、Graphify / Symphony / GitHub 自动化可用性 |

Agent 收到 `给 @000 下 Codex 指令`、`给 @001 下 Codex 指令` 或 `@001：<任务>` 时，必须按对应角色职责解析。symphony-issue、Codex Execution Agent 和 GitHub PR Automation 是流程工具 / 执行层 actor，按名称调用，不占用角色编号。

## @002 Startup Runbook

当 Human 指令要求 `@002 / PAR` 接管一个已写入 Linear 的 Project 时，父 Codex 必须把启动、执行前检查、active Project pointer 更新、二次 queue preview 和首个 eligible issue 推进合并为一个连续动作。

1. 读取 Project Planning Record 和 Linear Project / Issues。
2. 执行 Project / Issue 格式 Gate。
3. 执行 queue preview，确认 WIP=1、无 active conflict、依赖满足、first executable issue candidate 唯一。
4. 更新 `symphony-issue` active Project pointer，只更新 Project name、Project ID、Project slug、issue range 和 next eligible candidate。
5. pointer 更新后再次执行 queue preview。
6. gate 全部通过后，自动推进唯一 eligible `Backlog` -> `Todo`。
7. gate 任一失败时停止并报告。

`@002 Startup Runbook` 不创建 Linear Project / Issue，不修改 issue body，不启动 `symphony-issue`，不写代码，不创建 PR，不运行 Graphify update。

## Codex Execution Agent 流程

被 symphony-issue 调度后，Codex Execution Agent 分三段执行：

1. 执行前：读取 root docs、当前 Linear issue、相关 contracts、validation 和 Graphify read context；将当前 Linear issue 已填写合同作为执行边界。
2. 执行中：只完成当前 issue scope 内的代码、文档、测试或验证任务。
3. 执行后：运行 validation，更新 evidence chain，执行 Pre-PR Codex Code Review，创建 commit，创建 ready-for-review PR，启用 GitHub auto-merge handoff，并写入本地 `.codex/symphony-issue-handoff.json`。

Codex Execution Agent 不修改 Linear status；`In Progress` -> `In Review` 由 symphony-issue 在 PR 和 handoff evidence 就绪后推进。

## 代码中文注释规则

新增或修改 production code 时，Codex 必须补充详细中文注释。

必须注释 public type / protocol / actor / service、关键函数输入输出和错误边界、领域不变量、外部系统边界，以及禁止 Live trading、signed endpoint 或真实 broker action 的原因。测试代码注释必须说明测试场景和验证目的。

禁止空泛注释或逐行复述代码。

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为架构分层、组件命名和工作流组织参考。

MTPRO 不复制参考项目整仓代码，不引入参考项目作为运行依赖，不把参考项目能力直接当作当前 Linear issue scope。
