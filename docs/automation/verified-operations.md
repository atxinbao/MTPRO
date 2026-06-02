# Verified Operations / 可审计操作

日期：2026-05-18

执行者：Codex

## 定位

本文档定义 MTPRO 中跨系统自动化操作的最小审计格式。

它不授权执行，不替代 Linear，不替代 GitHub PR Automation，不替代 `verification.md`。

## 适用范围

必须按 verified operation 记录的操作：

- 父 Codex 在 Human-approved Project 内自动推进 eligible `Backlog` -> `Todo`。
- Codex Execution Agent 创建 commit / ready-for-review PR / GitHub auto-merge handoff。
- host-side fallback。
- Post-Issue Ledger / 施工后记账。

## 记录字段

每个 verified operation 至少记录：

| 字段 | 含义 |
| --- | --- |
| Operation | 操作名称 |
| Actor | 执行者，例如 Parent Codex、Codex Execution Agent、GitHub |
| Authorization Source | 授权来源，例如 Human-approved Project plan、当前 Linear issue、PR merge evidence |
| Input | 输入对象，例如 Linear issue、PR、workspace、queue context |
| Action | 实际动作 |
| Output | 输出对象，例如 PR URL、handoff marker、ledger summary |
| Validation | 运行的验证命令或外部系统结果 |
| Evidence Location | 证据位置 |
| Stop Condition | 停止条件 |
| Boundary Confirmation | 未突破的边界 |

## 操作原则

- 先读取授权来源，再执行动作。
- 先记录输入和预期输出，再运行外部系统动作。
- 如果权限、网络、GitHub 或 Linear 阻塞，必须停止并记录原因。
- fallback 只能修复当前 issue scope 内的自动化阻塞。
- verified operation 不得创建新 Linear Project / Issue。
- verified operation 不得决定下一阶段目标。
- verified operation 不得直接 merge PR。
- verified operation 不得提交 `.codex/*`。

## PR 证据要求

如果 PR 涉及 verified operation，PR body 必须说明：

- 操作名称。
- actor。
- 授权来源。
- validation。
- evidence location。
- 是否发生 fallback。

## 与 Post-Issue Ledger 的关系

Post-Issue Ledger 是 issue 完成后的 verified operation。

它只记录施工后关系事实和下一步观察提示，不能单独授权下一个 issue；下一个 issue 仍必须由 Parent Codex queue preflight 判断是否 eligible。
