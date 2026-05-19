# MTPRO symphony-issue Workflow Template

日期：2026-05-19

执行者：Codex

## 定位

本文档定义 MTPRO 本地 `symphony-issue` workflow 的稳定形态。

workflow 本体只保存稳定执行规则，不随每个 Linear Project 复制一套。

当前 active Project pointer 存在本地 runtime workflow 中，仓库文档不固定 current Project、current issue 或 current Todo。

本地 workflow 路径：

- `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
- `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`

## stable workflow body

以下内容属于稳定 workflow 本体：

- tracker kind：`linear`
- active states：`Todo`、`In Progress`
- terminal states：`Done`、`Closed`、`Cancelled`、`Canceled`、`Duplicate`
- polling interval
- workspace root：`/Users/mac/code/symphony-workspaces/mtpro-aep-v2`
- `after_create` hook
- `before_remove` Post-Issue Ledger hook
- Codex command / model / reasoning effort
- sandbox / approval policy
- max concurrent agents
- max turns
- handoff marker 规则
- Graphify / Post-Issue Ledger 边界

## runtime config shape

```yaml
tracker:
  kind: linear
  api_key: "$LINEAR_API_KEY"
  project_slug: "<active-linear-project-slug>"
  active_states:
    - Todo
    - In Progress
  terminal_states:
    - Done
    - Closed
    - Cancelled
    - Canceled
    - Duplicate
```

当前 Symphony 版本只支持 `project_slug` 配置字段。Project ID 是更稳定的核对字段；Parent Codex 必须在 queue preview 中保留 Project ID / URL source，等 Symphony 支持 Project ID 后再优先使用 Project ID。

## Parent Codex 更新规则

进入新 Linear Project 时，Parent Codex 必须按顺序执行：

1. 确认 Human Project Planning 已完成。
2. 确认 Linear Project / Issues 已写入并保持 `Backlog`。
3. 更新 active Project pointer。
4. 确认 workflow 本体没有被复制成新的 Project-specific workflow。
5. pointer 更新后再次执行 queue preview。
6. 核对 WIP=1、依赖、previous issue Done 和 execution contract Gate。
7. gate 通过后，自动推进唯一 eligible `Backlog` -> `Todo`。
8. 再允许 `symphony-issue` 调度唯一 `Todo`。

## @002 Startup Runbook

当 Human 指令要求 `@002 / PAR` 接管一个已写入 Linear 的 Project 时，Parent Codex 必须执行：

1. 读取 Project Planning Record 和 Linear Project / Issues。
2. 执行 Project / Issue 格式 Gate。
3. 执行 queue preview，确认 WIP=1、无 active conflict、依赖满足、first executable issue candidate 唯一。
4. 更新 active Project pointer。
5. pointer 更新后再次执行 queue preview。
6. gate 全部通过后，自动推进唯一 eligible `Backlog` -> `Todo`。
7. gate 任一失败时停止并报告，不推进 `Todo`。

`@002 Startup Runbook` 不启动 `symphony-issue`，不复制 workflow 本体，不新建 workflow，不创建 Linear Project / Issue，不创建 PR，不运行 Graphify update。

## 禁止事项

- 不为每个新 Project 复制一套 workflow。
- 不把旧 Project slug 留在 active runtime config。
- 不因为更新 active Project pointer 启动 `symphony-issue`。
- 不因为更新 active Project pointer 操作 `Backlog` -> `Todo`。
- 不由 Project Planning Facilitator 更新 runtime pointer 后直接执行。
- 不由 child Codex 修改 workflow 或 active Project pointer。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
