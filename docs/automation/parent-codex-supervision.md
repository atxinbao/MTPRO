# Parent Codex Automation Supervision / 父 Codex 自动化监督

日期：2026-05-19

执行者：Codex

## 定位

Parent Codex Automation Supervision 是 MTPRO 的 Project 级自动化监督角色。

它承担：

```text
Linear Project queue preview
-> Project / Issue 格式 Gate
-> eligible issue 调度
-> child Codex 行为监督
-> PR / checks / auto-merge / Linear bot Done 证据检查
-> host-side fallback
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Current Phase Progress Bar
```

它不是业务实现 Agent，不替代 Human 阶段决策，不直接 merge PR。

当前 @002 / PAR supervision 不依赖额外调度服务。Issue execution 可以由 Parent Codex host-side 执行到 PR / check / merge / Linear Done / ledger gate；任何历史 `symphony-issue` 术语只作为过去流程证据保留，不授权启动、调用、恢复或依赖 Symphony。

## Role Alias Rule

MTPRO 支持 AEP 三位数字编号和三字母角色代号。数字编号与三字母代号等价，例如 `@000 = AIE`、`@002 = PAR`。

角色编号只用于沟通压缩，不改变职责边界，不授权执行。

`@000 / AIE` 是当前 Codex 协作入口，负责识别任务、选择正确角色或流程，并在明确任务范围内完成代码 / 文档 / 验证 / PR handoff。`@000 / AIE` 不替代 `@002 / PAR` 的 Project queue gate，不得用 AI Engineer 身份绕过 WIP=1、依赖、active conflict 或执行合同格式检查。

本文档只定义 `@002 / PAR` 的自动化监督职责。`@003 / PRD`、`@004 / DSG`、`@005 / ARC` 固定为 Linear 外 reference / root docs 角色，不属于 issue 执行调度层。Codex Execution Agent 和 GitHub PR Automation 必须按流程 actor 名称调用，不占用这些编号。

常用指令可以写成：

```text
给 @002 下 Codex 指令：检查当前 Linear Project queue，并按规则推进 eligible issue。
```

## @002 Startup Runbook

当 Human 指令要求 `@002 / PAR` 接管一个已写入 Linear 的 Project 时，父 Codex 必须合并执行：

```text
@002 启动
-> 执行前检查
-> queue preview
-> gate 通过后推进唯一 eligible issue 到 Todo
```

顺序：

1. 读取 `docs/planning/projects/<linear-project-slug>-plan.md`。
2. 读取 Linear Project / Issues、issue status、dependencies / blocker 关系和 issue body。
3. 执行 Linear Project / Issue 格式 Gate，确认 Project planning record 和 Linear issue body 都满足执行合同字段要求。
4. 执行 queue preview，确认 WIP=1、无 `Todo` / `In Progress` / `In Review` active conflict、依赖满足、first executable issue candidate 唯一。
5. 记录本次 queue context：Project name、Project ID / URL source、Project slug、issue range 和 next eligible candidate。
6. gate 通过后推进唯一 eligible issue 到 Todo，也就是自动推进唯一 eligible `Backlog` -> `Todo`。
7. gate 任一失败时停止并报告阻塞项，不推进 `Todo`。

第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都归属父 Codex。Human 确认 Project / Issue plan 并写入 Linear 后，父 Codex 在当前 Project 内按 gate 自动调度，不需要逐个 issue 再等待 Human 授权。

边界：

- `@002 Startup Runbook` 不创建 Linear Project。
- `@002 Startup Runbook` 不创建 Linear issue。
- `@002 Startup Runbook` 不修改 issue body，除非任务另行明确授权。
- `@002 Startup Runbook` 不启动或依赖额外调度服务。
- `@002 Startup Runbook` 不写代码。
- `@002 Startup Runbook` 不创建 PR。
- `@002 Startup Runbook` 不运行 Graphify。

## Project queue 职责

Project Planning Facilitator 只负责阶段规划和 Linear 写入准备，不操作 `Backlog -> Todo`，不启动 issue execution。

父 Codex 可以：

1. 读取 Linear Project 队列，执行当前 Project 的 queue preview。
2. 确认同一 Project 内 WIP=1。
3. 确认 previous issue Done 和依赖满足。
4. 确认 issue execution contract 完整。
5. 将唯一 eligible issue 推进为 `Todo`。
6. 监控 child Codex 是否只按当前 Linear issue execution contract 执行。
7. 检查 PR、checks、auto-merge 和 Linear bot Done evidence。
8. 在 child Codex 被权限、网络或工具交互阻塞时执行 host-side fallback。
9. 在当前 Linear Project 的有效 issues 全部 `Done` 后，将 Linear Project status 设置或确认为 `Completed`。

父 Codex 禁止：

- 自动创建下一个 Project。
- 自动创建新 issue。
- 绕过 WIP=1。
- 替代 child Codex 的当前 issue 执行职责。
- 修正长期停留在 `In Progress` / `In Review` 的 issue，除非有明确 evidence 和任务授权。

## Runtime service boundary

MTPRO 不再维护 Symphony active Project pointer，也不再把 Graphify resource graph 作为执行前上下文或施工后刷新服务。

Parent Codex 在 Project 切换时只做 Linear live-read 和本次 queue context 记录；这些 context 只用于当前会话判断，不写成仓库长期事实，也不授权启动额外服务。

## Linear Project / Issue 格式 Gate

Human Project Planning 写入 Linear 后，父 Codex 必须在第一个 `Todo` 前做一次只读格式核对。

核对内容：

- Project description 包含 Goal、Scope、Non-goals、Issue Order、Dependencies、Validation Requirements、Evidence Requirements、WIP=1 和 Current State。
- 每个 issue description 包含 Goal、Scope、Non-goals、Codex Instructions、Validation、Boundary、PR Requirements、Dependencies 和 Initial Linear State。
- 所有 issue 初始状态仍为 `Backlog` 或等价非可执行状态。
- Next eligible candidate 只在 Project / Issue plan 已由 Human 确认、queue preview 通过且执行合同格式完整后进入 `Todo`。

格式 Gate 只确认 Linear issue 可作为执行合同，不授权执行，不修改 Linear status，不启动额外调度服务。

## Stage Code Audit Report 落仓规则

当当前 Linear Project 的有效 issues 全部 `Done` 后，Parent Codex 必须先完成 Linear Project closure：

- 将 Linear Project status 设置或确认为 `Completed`。
- 确认 Linear 返回 `type=completed`。
- 确认 `completedAt` 非空。

仅有全部 issues `Done`、PR 全部 merge、Post-Issue Ledger passed 或会话输出，都不能替代 Linear Project status `Completed`。

closure 后，Parent Codex 必须输出 Project 级 Stage Code Audit Report：

- 报告路径：`docs/audit/<linear-project-slug>-stage-code-audit.md`
- 报告必须覆盖整个 Linear Project。
- 报告必须包含 Project scope / issue range、Linear Project `Completed` evidence、Issue / PR evidence、Validation、Boundary Audit、Known CI Boundary、Root Docs Delta、Residual Notes For Human Planning 和 Next Human Project Planning Handoff。
- Stage Code Audit Report 合并后才能进入 Root Docs Refresh Gate。

Next Human Project Planning 必须读取该文件。

## Root Docs Refresh Gate

Stage Code Audit Report 合并后，Parent Codex 必须检查：

- `GOAL.md`
- `docs/environment.md`
- `docs/architecture.md`
- `docs/roadmap.md`

Root Docs Delta 只同步已发生事实。

下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。

## Current Phase Progress Bar / 当前阶段完成进度条

Root Docs Refresh Gate closure 后，Parent Codex 必须输出当前阶段完成进度条。

进度条是 Current Foundation Progress 和 Final Product Goal Progress 摘要，不是蓝图内容，不写入 `BLUEPRINT.md`，不授权下一阶段执行。

进度条必须基于当前 `GOAL.md` 和 `docs/roadmap.md` 的两层目标切片计算，而不是直接用 Project closure 数量计算，也不是基于未授权方向计算。

- Current Foundation Progress：当前已批准、已执行、已 closure 的 foundation 目标切片。
- Final Product Goal Progress：完整专业交易工作台产品目标切片，包括仍处于 Pending / gated 的 future capability。

Project closure 数量必须单独输出为 `Project Closure Count`，只作为证据口径，不等于目标完成度。

一个 Project 只有同时满足以下条件，才能计为 completed：

- Linear Project status 已设置或确认为 `Completed`。
- Linear 返回 `type=completed`。
- `completedAt` 非空。
- Project 级 Stage Code Audit Report 已落仓并合并。
- Root Docs Refresh Gate 已 closure。

进度条输出必须包含：

- 当前 phase 名称或范围。
- Project Closure Count。
- Current Foundation Progress。
- Final Product Goal Progress。
- ASCII progress bars。
- 目标切片状态。
- 最近完成 Project。
- 下一步 handoff：交给 Human + `@001 / PLN`，或说明当前 phase 已全部完成、等待 Human 选择下一阶段。

推荐格式：

```text
Current Phase Progress
Phase: <phase name>
Project Closure Count: <closed-projects>/<approved-projects> (<closure-percent>%)
Current Foundation Progress: <done-foundation-slices>/<total-foundation-slices> (<foundation-percent>%)
Final Product Goal Progress: <done-final-product-slices>/<total-final-product-slices> (<final-product-percent>%)
Foundation Progress: [##########] <foundation-percent>%
Final Product Progress: [####------] <final-product-percent>%
Latest Completed Project: <project name>
Next Handoff: Human + @001 / PLN
```

Parent Codex 可以在最终会话输出、Stage Code Audit Report、Root Docs Refresh Gate closure 记录或 `docs/validation/latest-verification-summary.md` 中记录该进度条。若写入仓库，必须保持 docs-only，不得修改 Linear、不得推进 `Todo`、不得启动额外调度服务。

## Host-side fallback

Host-side fallback 只能处理当前 issue scope 内的自动化阻塞。

允许：

- commit 当前 issue diff。
- push 当前 issue branch。
- 创建或修正当前 issue PR。
- 启用 `gh pr merge --auto --squash`。
- 在 PR evidence 中记录 fallback 原因。

禁止：

- 扩大业务 diff。
- 修改 Linear status。
- 跳过 validation。
- 直接 merge PR。

## Post-Issue Ledger / 施工后记账

Post-Issue Ledger 只提供关系事实和下一步观察提示。

父 Codex 可以读取 `.codex/post-issue-ledger/latest.json`，用于 queue preview、风险判断和下一步 eligible issue 判断，但不得把它当作创建新 Project / Issue 或绕过 WIP=1 的授权。
