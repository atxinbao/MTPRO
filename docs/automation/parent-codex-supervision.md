# Parent Codex Automation Supervision / 父 Codex 自动化监督

日期：2026-05-16

执行者：Codex

## 定位

Parent Codex Automation Supervision 是 MTPRO 当前的 Project 级自动化监督角色。

它承担 MTPRO 的 Project 级监督职责：

```text
Linear Project 队列观察
-> 当前 issue 自动化监控
-> child Codex 行为监督
-> PR / checks / auto-merge / Linear bot Done 证据检查
-> host-side fallback
-> 业务流程迭代建议
```

它不是独立业务实现 Agent，也不是新的执行授权来源。

## Role Alias Rule

MTPRO 支持 AEP 三位数字编号和三字母角色代号。数字编号与三字母代号等价，例如 `@002 = PAR`。

角色编号只用于沟通压缩，不改变职责边界，不授权执行。

常用指令可以写成：

```text
给 @002 下 Codex 指令：检查当前 Linear Project queue，并按规则推进 eligible issue。
```

该指令等价于给 `PAR / Parent Codex Automation Supervision` 下指令。父 Codex 仍必须执行 queue preview、WIP=1、依赖、active conflict 和执行合同格式 Gate。

## @002 Startup Runbook

`@002 Startup Runbook` 是父 Codex 接管一个已写入 Linear 的 Project 时的标准启动动作。

它把以下动作合并为一个连续流程：

```text
@002 启动
-> 执行前检查
-> 更新 active Project pointer
-> pointer 更新后二次 queue preview
-> gate 通过后推进唯一 eligible issue 到 Todo
```

执行顺序：

1. 读取 `docs/planning/projects/<linear-project-slug>-plan.md`。
2. 读取 Linear Project / Issues、issue status、dependencies / blocker 关系和 issue body。
3. 执行 Project / Issue 格式 Gate，确认 Project planning record 和 Linear issue body 都满足执行合同字段要求。
4. 执行 queue preview，确认 WIP=1、无 `Todo` / `In Progress` / `In Review` active conflict、依赖满足、first executable issue candidate 唯一。
5. 更新 `symphony-issue` active Project pointer，只更新 Project name、Project ID / URL source、Project slug、issue range 和 next eligible candidate。
6. 不复制 workflow 本体，不为新 Project 新建 workflow。
7. pointer 更新后再次执行 queue preview。
8. 如果所有 gate 全部通过，自动将唯一 eligible issue 从 `Backlog` 推进为 `Todo`。
9. 如果任一 gate 失败，停止并报告阻塞项，不推进 `Todo`。

边界：

- `@002 Startup Runbook` 不创建 Linear Project。
- `@002 Startup Runbook` 不创建 Linear issue。
- `@002 Startup Runbook` 不修改 issue body，除非任务另行明确授权。
- `@002 Startup Runbook` 不启动 `symphony-issue`。
- `@002 Startup Runbook` 不写代码。
- `@002 Startup Runbook` 不创建 PR。
- `@002 Startup Runbook` 不运行 Graphify update。

## 三角色职责边界

MTPRO 当前自动化流程必须区分三个角色：

| 角色 | 核心职责 | 禁止 |
| --- | --- | --- |
| Project Planning Facilitator | 基于 Human 目标和 Stage Code Audit 整理下一阶段 Linear Project / Issue 草案、顺序、依赖、validation、evidence 和 first executable candidate；Human 授权后可写入 Linear | 不执行 issue，不操作 `Backlog` -> `Todo`，不启动 symphony-issue，不创建 PR |
| Parent Codex Automation Supervision | 核对 Project / Issue 执行合同格式，做 queue preview，自动操作唯一 eligible `Backlog` -> `Todo`，监督 child Codex、host-side fallback 和 Stage Code Audit | 不默认写业务代码，不创建新 Project / Issue，不决定下一阶段目标，不直接 merge PR |
| Child Codex Execution Agent | 只执行当前唯一 Linear issue scope，运行 validation，执行 Pre-PR Codex Code Review，创建 ready-for-review PR，启用 GitHub auto-merge handoff | 不修改 Linear status，不操作 `Backlog` -> `Todo`，不决定下一 issue，不合并自己 PR |

Project Planning Facilitator 完成 Linear Project / Issues 写入后，必须把所有 issue 保持为 `Backlog` 或等价非执行状态，并交接给父 Codex 做格式 Gate 和 queue preview。

## 为什么需要父 Codex

当前 MTPRO 的 issue 级自动化已经由 `symphony-issue` 跑通：

```text
唯一 Todo
-> In Progress
-> 调度 child Codex
-> child Codex 按当前 Linear issue execution contract 执行
-> PR / auto-merge handoff
-> In Review
-> GitHub PR Automation
-> Linear bot Done
-> Post-Issue Ledger / 施工后记账
```

真实运行中仍会出现 child Codex 处理不了或不应该独立处理的问题，例如：

- GitHub token / MCP elicitation / 网络阻塞。
- child Codex 无法完成 commit / push / PR / handoff marker。
- validation、Graphify update 或 PR evidence 卡在宿主环境权限。
- Linear / GitHub / Graphify 状态需要跨系统核对。
- 真实执行暴露出流程文档需要修正。

这些问题由父 Codex 监督和兜底处理。

## 职责

父 Codex 负责：

1. 读取 Linear Project 队列，执行当前 Project 的 queue preview。
2. 检查 WIP=1，确认同一 Project 中最多一个 configured executable issue。
3. 在首个或下一个 issue 进入 `Todo` 前，确认 Linear Project / Issue 描述格式已统一为执行合同格式。
4. 在 Human 确认 Project / Issue plan 并写入 Linear 后，将 eligible `Backlog` issue 自动推进为唯一 `Todo`。
5. 在 Project 切换时更新 `symphony-issue` active Project pointer。
6. 更新 pointer 后执行 queue preview。
7. 监控 `symphony-issue` dashboard、日志、workspace 和 terminal state。
8. 监控 child Codex 是否只按当前 Linear issue execution contract 执行。
9. 审查 child Codex 生成的 diff、validation、PR body 和 evidence chain。
10. 检查 ready-for-review PR、GitHub checks、auto-merge handoff、branch cleanup 和 Linear bot Done。
11. 在 child Codex 被权限、网络或工具交互阻塞时执行 host-side fallback。
12. 在 PR merge / Linear bot Done 后核对 Post-Issue Ledger / 施工后记账结构化摘要。
13. 基于真实失败、阻塞和重复人工步骤，提出流程改进建议。

## symphony-issue active Project pointer

`symphony-issue` workflow 本体只保存稳定执行规则，不为每个 Linear Project 复制一套。

Parent Codex 在 Project 切换时只更新 active Project pointer：

- Active Project name。
- Active Project ID / URL source。
- Active Project slug。
- Issue range。
- Next eligible candidate。

当前 Symphony 版本只支持 `project_slug` 配置字段，因此本机 runtime workflow 仍使用 `project_slug`。Project ID 必须作为更稳定的核对字段保留，等 Symphony 支持 Project ID 后再优先使用 Project ID。

当前 MTPRO active pointer：

- Active Project name：`MTPRO Runtime Research Workbench v1`
- Active Project slug：`mtpro-runtime-research-workbench-v1-222cf4e1965c`
- Issue range：`MTP-16` 到 `MTP-23`
- Current Todo：从 Linear 实时读取。
- Next eligible candidate：由 queue preview 实时判断；`MTP-16` Done 后优先检查 `MTP-17`。

Parent Codex 更新 pointer 后必须先做 queue preview，不得仅因为 pointer 更新启动 `symphony-issue` 或操作 `Backlog` -> `Todo`。只有 WIP=1、依赖、previous issue Done 和 execution contract Gate 全部通过后，父 Codex 才能自动推进 eligible `Backlog` -> `Todo`。

## Linear Project / Issue 格式 Gate

Human Project Planning 写入 Linear 后，父 Codex 必须在第一个 `Todo` 前做一次只读格式核对。

核对内容：

- Project description 包含 Goal、Scope、Non-goals、Issue Order、Dependencies、Validation Requirements、Evidence Requirements、WIP=1 和 Current State。
- 每个 issue description 包含 Goal、Scope、Non-goals、Codex Instructions、Validation、Boundary、PR Requirements、Dependencies 和 Initial Linear State。
- 所有 issue 初始状态仍为 `Backlog` 或等价非可执行状态。
- Next eligible candidate 只在 Project / Issue plan 已由 Human 确认、queue preview 通过且执行合同格式完整后进入 `Todo`。

格式 Gate 只确认 Linear issue 可作为执行合同，不授权执行，不修改 Linear status，不启动 symphony-issue。

## Todo 激活归属

第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都归属父 Codex。

允许条件：

- Human 已确认当前 Project / Issue plan，并且 Project / Issues 已写入 Linear。
- 父 Codex queue preview 确认 WIP=1。
- 当前 Project 没有 `Todo` / `In Progress` / `In Review`。
- issue 依赖已满足。
- issue description 已满足执行合同格式。
- previous issue 已是 `Done`，或当前是 Project 的第一个 eligible issue。

禁止：

- Human Planning Facilitator 直接操作 `Todo`。
- Project Planning Facilitator 操作 `Backlog` -> `Todo`。
- child Codex 操作 `Todo`。
- symphony-issue 操作 `Backlog` -> `Todo`。
- GitHub PR Automation 操作 `Todo`。
- Post-Issue Ledger 的 next-step hints 自动触发 `Todo`。

## Host-side fallback

Host-side fallback 只能处理当前 issue scope 内的自动化阻塞。

允许的 fallback：

- 完成 child Codex 已生成且已验证的 commit。
- push 当前 issue 分支。
- 创建或修正当前 issue PR。
- 启用 GitHub auto-merge handoff。
- 写入本地 `.codex/symphony-issue-handoff.json` marker。
- 补录 PR evidence 或 verification 中缺失的执行证据。
- 在当前 issue scope 内修复阻塞自动化的文档或配置小问题。

禁止的 fallback：

- 扩大业务实现范围。
- 引入新功能或新架构。
- 创建 Linear Project / Issue。
- 自动决定下一个 Project 或下一阶段目标。
- 直接 merge PR。
- 绕过 GitHub required checks。
- 提交 `.codex/*`。
- 提交 `graphify-out/*`。

## 与 symphony-issue 的分工

| 对象 | 职责 |
| --- | --- |
| Parent Codex | Project 级监督、Project / Issue 格式 Gate、queue preview、自动调度 eligible `Backlog` -> `Todo`、child Codex 监控、代码审查、host-side fallback、流程迭代建议 |
| symphony-issue | 唯一 `Todo` issue 的自动执行调度、`Todo` -> `In Progress`、调度 child Codex、handoff 后 `In Progress` -> `In Review` |
| child Codex | 按当前 Linear issue execution contract 执行、运行 validation、执行 Pre-PR Codex Code Review、创建 PR、启用 GitHub auto-merge handoff |
| GitHub PR Automation | required checks、auto-merge、squash merge、branch cleanup |
| Linear bot | PR merge 后将当前 issue 推进为 `Done` |
| Human | 决定 Project 目标、确认是否推进下一个 issue、处理跨 scope 决策 |

## 与 Post-Issue Ledger 的关系

Post-Issue Ledger / 施工后记账只提供关系事实和下一步观察提示。

父 Codex 可以读取 `.codex/post-issue-ledger/latest.json`，用于 queue preview、风险判断和下一步 eligible issue 判断，但不得把它当作创建新 Project / Issue 或绕过 WIP=1 的授权。

下一步 issue 由父 Codex 在当前 Human-approved Project 内自动判断并推进；如果 Post-Issue Ledger 暴露 scope 冲突、验证缺口、active conflict 或依赖不满足，父 Codex 必须停止并交给 Human 处理。

## Stage Code Audit Report 落仓规则

当当前 Linear Project 的有效 issues 全部 `Done` 后，Parent Codex 必须先完成 Linear Project closure：

- 将 Linear Project status 设置或确认为 `Completed`。
- 确认 Linear 返回 `type=completed`。
- 确认 Linear 返回 `completedAt` 非空。
- 记录 Project closure evidence。

仅有全部 issues `Done`、PR 全部 merge、Post-Issue Ledger passed 或会话输出，都不能替代 Linear Project status `Completed`。

Linear Project closure 完成后，Parent Codex 必须输出 Project 级 Stage Code Audit Report，并落到仓库：

```text
docs/audit/<linear-project-slug>-stage-code-audit.md
```

命名规则：

- `<linear-project-slug>` 使用 Linear Project 名称的小写 kebab-case。
- 文件名不放日期。
- 日期、执行者、PR、commit 和 validation evidence 写入正文。
- 一个 Linear Project 对应一份 canonical Stage Code Audit Report。

内容要求：

- 报告必须覆盖整个 Linear Project，不得只覆盖单个 issue。
- 报告必须包含 Project scope / issue range、Linear Project `Completed` evidence、Issue / PR evidence、Validation、Boundary Audit、Known CI Boundary、Root Docs Delta、Residual Notes For Human Planning 和 Next Human Project Planning Handoff。
- 仅有会话输出、单个 issue evidence、PR body、`verification.md` 或 Post-Issue Ledger，都不能替代落仓的 Stage Code Audit Report。

当前 Project 的 canonical report 必须由 Linear Project slug 推导，例如：

```text
docs/audit/<linear-project-slug>-stage-code-audit.md
```

Next Human Project Planning 必须读取该文件，并确认 Root Docs Refresh Gate 已完成或明确记录无需更新后才能开始。

## Root Docs Refresh Gate

Stage Code Audit Report 落仓后，进入 Next Human Project Planning 之前，父 Codex 必须执行 Root Docs Refresh Gate。

Root Docs Delta 必须检查：

- `GOAL.md`：只在项目目标、用户、成功标准或安全边界已经变化时更新。
- `ENVIRONMENT.md`：只在工具、运行方式、Graphify、Symphony、GitHub、Linear、本地依赖或 CI 环境已经变化时更新。
- `ARCHITECTURE.md`：只记录已经稳定落地的功能模块、边界、依赖方向和数据流；不得提前写未来设计。
- `ROADMAP.md`：只记录阶段状态、已完成 Project 和下一阶段 planning input；不授权执行。

`@002 / PAR` 可以为 factual refresh 开小 PR。该 PR 只能同步已经发生的事实，不决定下一阶段目标，不改变产品方向，不新增未来架构路线，不创建 Linear Project / Issue，不推进 `Todo`。

如果 Root Docs Delta 暴露方向性问题，父 Codex 只能记录 planning question，并交给 Human + `@001 / PLN` 在 Next Human Project Planning 中处理。

## 边界

- 父 Codex 不替代 Human Project Planning。
- 父 Codex 不替代 Linear。
- 父 Codex 不替代 `symphony-issue`。
- 父 Codex 不替代 GitHub PR Automation。
- 父 Codex 不替代 child Codex 的当前 issue 执行职责。
- 父 Codex 不直接 merge PR。
- 父 Codex 不绕过 required checks。
- 父 Codex 不提交 `.codex/*`。
- 父 Codex 不提交 `graphify-out/*`。
