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
8. `docs/validation/latest-verification-summary.md`

需要实现或验证时，再按 scope 读取：

- `docs/product/product-surface-map.md`
- `docs/contracts/`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/automation/`
- 当前 Linear issue body

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 核心硬规则

- 所有正式文档写入必须使用中文。
- `GOAL.md` 是 Project Charter，`BLUEPRINT.md` 是 Root Blueprint，`ARCHITECTURE.md` 是 Architecture Map，`ROADMAP.md` 是 Construction Plan。
- `ROADMAP.md`、Project Planning Record、Backlog issue、label、priority、assignee 都不授权执行。
- Complete Blueprint Design 是 Human + `@000 / AIE` 的 Linear 外蓝图活动。它读取 reference study、root docs、Stage Code Audit Reports 和现有代码能力，输出 `docs/design/mtpro-complete-blueprint.md`。
- Complete Blueprint Design 可以描述 Live / signed endpoint / broker / OMS 等最终产品长期能力，但这些能力必须标记为 Future Construction Zones 或 gated capabilities；除非 Human 后续明确选入 Current Construction Scope 并进入 `@001 / PLN` Project Planning，否则不得转成 Linear issue。
- Complete Blueprint Design 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Backlog` -> `Todo`，不启动 `@002 / PAR`，不启动 symphony-issue，不运行 Graphify update，不写业务代码。
- 只有 Linear 中唯一 configured executable issue 才能授权正式开发执行。
- 当前唯一 configured executable issue 不写死在仓库文档中；执行前必须从 Linear / Parent Codex queue preview 读取，并确认 WIP=1。
- Linear issue 中已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 是 Codex Execution Agent 的执行合同；子 Codex 按模板字段执行，不二次确认 issue scope，不重新定义边界。
- Project Planning Facilitator 只负责阶段规划、Linear Project / Issue 草案、Human review 后的 Linear 写入准备；不得执行 issue，不得启动 symphony-issue，不得操作 `Backlog` -> `Todo`。
- Parent Codex Automation Supervision 负责 Project 级 queue preview、eligible issue 自动调度、child Codex 监控、代码审查、host-side fallback、流程迭代建议、Project closure 和 Stage Code Audit。
- Human 确认 Project / Issue plan 并写入 Linear 后，第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都只能由父 Codex 自动执行。
- 父 Codex 自动调度前必须确认 WIP=1、previous issue Done、依赖满足、执行合同格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- 父 Codex 负责 Project 切换时更新 `symphony-issue` active Project pointer；workflow 本体不得为每个 Project 复制一套。
- 父 Codex 更新 active Project pointer 后必须先做 queue preview，不得直接启动 `symphony-issue`，不得直接操作 `Backlog` -> `Todo`。
- symphony-issue 负责唯一 `Todo` issue 的执行调度、`Todo` -> `In Progress` 和 `In Progress` -> `In Review` 状态推进。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- Project 全部有效 issues `Done` 只是 Project closure 前置条件；Parent Codex 必须将 Linear Project status 设置或确认为 `Completed`，并确认 `type=completed`、`completedAt` 非空。
- Stage Code Audit Report 必须覆盖完整 Linear Project，必须包含 Linear Project `Completed` evidence 和 Root Docs Delta。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步已发生事实；方向、目标、架构路线和下一阶段优先级必须交给 Human + `@001 / PLN`。
- Root Docs Refresh Gate closure 后，`@002 / PAR` 必须输出当前阶段完成进度条；进度条必须基于 `GOAL.md` 和 `ROADMAP.md` 的目标切片计算，Project closure 数量只能作为单独证据口径，不写入蓝图文档，不授权下一阶段执行。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- Agent 默认读取 `docs/validation/latest-verification-summary.md`。

## Role Alias Rule

MTPRO 采用 AEP 三位数字编号和三字母角色代号。数字编号与三字母代号等价，例如 `@000 = AIE`、`@001 = PLN`。

角色编号只用于沟通压缩，不改变职责边界，不授权执行，不替代 Linear issue、Project planning、GitHub required checks 或 Human decision。

`@000 / AIE` 是 AI Engineer 角色，也是当前 Codex 协作入口。它负责理解 Human 指令、读取 root docs、选择正确仓库与流程、执行明确授权的代码 / 文档修改、维护验证与 PR handoff，并在需要时把任务路由给 `@001` 至 `@007`。

当 Human 明确要求推进 MTPRO Complete Blueprint Design 时，`@000 / AIE` 和 Human 共同处理完整蓝图设计。`@000 / AIE` 负责读取 NautilusTrader reference study、Stage Code Audit Reports、root docs 和现有代码能力，协助 Human 把 Final Product Blueprint、System Architecture Blueprint、Workbench / UX Blueprint、Current Construction Scope 和 Future Construction Zones 收敛成 `docs/design/mtpro-complete-blueprint.md`。

`@000 / AIE` 不替代 Human decision，不绕过 Linear configured executable issue，不替代 `@001 / PLN` 的下一阶段 Project Planning，不替代 `@002 / PAR` 的 Project queue 调度职责，也不替代 `@003` / `@004` / `@005` 的 Linear 外 reference 研究职责。Complete Blueprint Design 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Backlog` -> `Todo`，不启动 `@002 / PAR` 或 symphony-issue，不写业务代码。

`@003 / PRD`、`@004 / DSG`、`@005 / ARC` 是 Linear 外的 reference / root docs 角色。它们服务 `GOAL.md`、`ARCHITECTURE.md`、`ENVIRONMENT.md`、`ROADMAP.md` 和 `docs/reference/*` 的研究、差距分析与 delta proposal，不创建 Linear Project / Issue，不推进 `Todo`，不启动 symphony-issue。

| 编号 | 代号 | 角色 | MTPRO 职责摘要 |
| --- | --- | --- | --- |
| `000` | `AIE` | AI Engineer | 当前 Codex 协作入口、Complete Blueprint Design、任务理解、仓库 / 流程选择、代码 / 文档执行、验证、PR handoff、角色路由和边界守护 |
| `001` | `PLN` | Project Planning Lead | 新阶段规划、Next Human Project Planning、Project / Issue 草案、reference synthesis |
| `002` | `PAR` | Parent Codex Automation Supervision | Project queue、eligible issue 调度、child Codex 监督、Stage Code Audit、当前阶段完成进度条 |
| `003` | `PRD` | Product Reference Lead | Linear 外产品参考、用户路径、工作台能力、`GOAL.md` / `ROADMAP.md` / `docs/product/*` delta proposal |
| `004` | `DSG` | Design Reference Lead | Linear 外信息架构、Dashboard / Workbench 页面结构、状态与 ViewModel 映射 delta proposal |
| `005` | `ARC` | Architecture Reference Lead | Linear 外系统结构参考、模块边界、event / replay / adapter / runtime / execution 语义映射 delta proposal |
| `006` | `QAV` | QA / Trading validation | 验证、失败归因、验收证据、Finance / Trading Domain 和回归边界 |
| `007` | `OPS` | Operations | 本地环境、运行、部署、Graphify / Symphony / GitHub 自动化可用性 |

Agent 收到 `给 @000 下 Codex 指令`、`给 @001 下 Codex 指令` 或 `@001：<任务>` 时，必须按对应角色职责解析。`@000 / AIE` 可以执行当前明确任务或路由到其他角色，但不能用自己的编号绕过对应角色的授权边界。

symphony-issue、Codex Execution Agent 和 GitHub PR Automation 是流程工具 / 执行层 actor，按名称调用，不再占用 `@003`、`@004`、`@005` 编号。

## @002 Startup Runbook

当 Human 指令要求 `@002 / PAR` 接管一个已写入 Linear 的 Project 时，父 Codex 必须把启动、执行前检查、active Project pointer 更新、二次 queue preview 和首个 eligible issue 推进合并为一个连续动作。

标准顺序：

1. 读取 Project Planning Record 和 Linear Project / Issues。
2. 执行 Project / Issue 格式 Gate。
3. 执行 queue preview，确认 WIP=1、无 active conflict、依赖满足、first executable issue candidate 唯一。
4. 更新 `symphony-issue` active Project pointer，只更新 Project name、Project ID、Project slug、issue range 和 next eligible candidate。
5. pointer 更新后再次执行 queue preview。
6. gate 全部通过后，自动推进唯一 eligible `Backlog` -> `Todo`。
7. gate 任一失败时停止并报告。

`@002 Startup Runbook` 不创建 Linear Project / Issue，不修改 issue body，不启动 `symphony-issue`，不写代码，不创建 PR，不运行 Graphify update。

Project closure 后，`@002 / PAR` 还必须输出当前阶段完成进度条。该进度条使用 Goal / Roadmap Target Progress 口径；Project Closure Count 只说明已关闭 Project 数量，不等于目标完成度，不统计完整蓝图中的 future capability，不写入 `docs/design/mtpro-complete-blueprint.md`。

## Codex Execution Agent 流程

被 symphony-issue 调度后，Codex Execution Agent 分三段执行：

1. 执行前：读取 root docs、当前 Linear issue、相关 contracts、validation 和 Graphify read context；将当前 Linear issue 已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 作为执行合同。
2. 执行中：只完成当前 issue scope 内的代码、文档、测试或验证任务。
3. 执行后：运行 validation，更新 evidence chain，执行 Pre-PR Codex Code Review，创建 commit，创建 ready-for-review PR，启用 GitHub auto-merge handoff，并写入本地 `.codex/symphony-issue-handoff.json`。

Codex Execution Agent 不修改 Linear status；`In Progress` -> `In Review` 由 symphony-issue 在 PR 和 handoff evidence 就绪后推进。

## 代码中文注释规则

新增或修改 production code 时，Codex 必须补充详细中文注释。

必须注释：

- public type / protocol / actor / service 的职责。
- 关键函数的输入、输出和错误边界。
- 领域不变量，例如 paper-only、read-only market data、append-only event log。
- 外部系统边界，例如 Binance、SQLite、DuckDB、Graphify、Linear、GitHub。
- 任何禁止 Live trading、signed endpoint 或真实 broker action 的原因。

测试代码中的注释必须说明测试场景和验证目的。

禁止空泛注释或逐行复述代码。

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为架构分层、组件命名和工作流组织参考。

MTPRO 不复制参考项目整仓代码，不引入参考项目作为运行依赖，不把参考项目能力直接当作当前 Linear issue scope。
