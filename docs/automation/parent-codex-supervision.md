# Parent Codex Automation Supervision / 父 Codex 自动化监督

日期：2026-05-16

执行者：Codex

## 定位

Parent Codex Automation Supervision 是 MTPRO 当前的 Project 级自动化监督角色。

它承担原计划中独立 Project 级 continuation 程序尚未接入前的监督职责：

```text
Linear Project 队列观察
-> 当前 issue 自动化监控
-> child Codex 行为监督
-> PR / checks / auto-merge / Linear bot Done 证据检查
-> host-side fallback
-> 业务流程迭代建议
```

它不是独立业务实现 Agent，也不是新的执行授权来源。

## 为什么需要父 Codex

当前 MTPRO 的 issue 级自动化已经由 `symphony-issue` 跑通：

```text
唯一 Todo
-> In Progress
-> 调度 child Codex
-> child Codex 执行当前 issue scope
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

1. 读取 Linear Project 队列，只做当前 Project 的只读 queue preview。
2. 检查 WIP=1，确认同一 Project 中最多一个 configured executable issue。
3. 在 Human 明确授权后，将 eligible `Backlog` issue 推进为唯一 `Todo`。
4. 监控 `symphony-issue` dashboard、日志、workspace 和 terminal state。
5. 监控 child Codex 是否只执行当前 issue scope。
6. 审查 child Codex 生成的 diff、validation、PR body 和 evidence chain。
7. 检查 ready-for-review PR、GitHub checks、auto-merge handoff、branch cleanup 和 Linear bot Done。
8. 在 child Codex 被权限、网络或工具交互阻塞时执行 host-side fallback。
9. 在 PR merge / Linear bot Done 后核对 Post-Issue Ledger / 施工后记账结构化摘要。
10. 基于真实失败、阻塞和重复人工步骤，提出流程改进建议。

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
| Parent Codex | Project 级监督、queue preview、Human 授权后的 `Backlog` -> `Todo`、child Codex 监控、代码审查、host-side fallback、流程迭代建议 |
| symphony-issue | 唯一 `Todo` issue 的自动执行调度、`Todo` -> `In Progress`、调度 child Codex、handoff 后 `In Progress` -> `In Review` |
| child Codex | 执行当前 issue scope、运行 validation、执行 Pre-PR Codex Code Review、创建 PR、启用 GitHub auto-merge handoff |
| GitHub PR Automation | required checks、auto-merge、squash merge、branch cleanup |
| Linear bot | PR merge 后将当前 issue 推进为 `Done` |
| Human | 决定 Project 目标、确认是否推进下一个 issue、处理跨 scope 决策 |

## 与 Post-Issue Ledger 的关系

Post-Issue Ledger / 施工后记账只提供关系事实和下一步观察提示。

父 Codex 可以读取 `.codex/post-issue-ledger/latest.json`，用于判断下一步是否需要向 Human 汇报，但不得把它当作执行授权。

下一步 issue 只能由 Human 明确授权后，父 Codex 才能把 eligible `Backlog` issue 推进为唯一 `Todo`。

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
