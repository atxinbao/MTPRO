# MTPRO Planning Record Index

日期：2026-07-20

执行者：Codex

状态：Canonical

## 当前状态

当前没有 active planning record。

MTPRO 当前不使用 Linear 作为执行队列；历史 Linear planning records 仅作为 `Historical evidence` 保留。新工作必须由 Human 明确目标后，通过当前仓库采用的 GitHub issue / PR 流程建立执行合同。

旧版完整 planning 索引归档在：

`docs/history/planning-pre-canonicalization-2026-07-20/linear-draft-plan.md`

该快照包含历史 Project、MTP issue range、依赖和当时的执行边界，不代表当前 queue。

## Planning record 目录

历史 Project planning records 位于：

`docs/planning/projects/`

它们默认属于 `Historical evidence`，除非当前 `docs/roadmap.md` 和 GitHub queue 明确重新激活。

## Planning record 最低内容

新 planning record 必须包含：

1. Project / milestone name。
2. Goal。
3. Scope。
4. Non-goals。
5. Issue order。
6. Dependencies。
7. Validation requirements。
8. Evidence requirements。
9. First executable candidate。
10. WIP=1 rule。
11. Repository record boundary。
12. 明确的执行授权来源。

## GitHub queue 规则

当前执行队列以 GitHub issue 为准：

- 新 issue 初始为 `backlog / non-executable`。
- 同一时间只允许一个 `todo / in-progress / in-review` issue。
- 必须先满足依赖和前置 release / patch gate。
- 每个 issue 独立 PR。
- PR required checks 通过并合并后，issue 才可关闭为 `done`。
- 不得从历史 planning record 自动恢复执行。

## WIP=1

```text
active(todo + in-progress + in-review) <= 1
```

若存在 active conflict，不得推进新的 issue。

## Repository record boundary

仓库保存：

- Project / milestone 摘要。
- issue order 和依赖。
- validation / evidence gate。
- release、audit 和 contract 证据。

仓库不应在多个 Markdown 文件复制维护同一份完整 issue body。

## 历史 Linear 边界

旧版以下术语仅描述历史流程：

- Linear Project。
- Backlog -> Todo queue preflight。
- Parent Codex / `@002 / PAR`。
- Project `Completed/type=completed`。

这些历史证据不得被解释为当前 active queue，也不得绕过当前 GitHub issue / PR gate。

## 当前入口

- 当前路线：`docs/roadmap.md`
- 当前目标：`GOAL.md`
- 当前架构：`architecture.md`
- 当前验证：`docs/validation/latest-verification-summary.md`
- 历史 planning 索引：`docs/history/planning-pre-canonicalization-2026-07-20/linear-draft-plan.md`

## 非授权声明

本文档不创建 issue，不推进 queue，不授权业务代码、production cutover、secret 读取、production endpoint 连接或生产订单。
