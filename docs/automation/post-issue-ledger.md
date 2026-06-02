# MTPRO Post-Issue Ledger / 施工后记账

日期：2026-05-16

执行者：Codex

## 定位

Post-Issue Ledger 是 MTPRO 在一个 Linear issue 完成 PR / check / merge / Linear Done gate 后执行的本地 read-only 记账环节。

它发生在：

```text
GitHub PR Automation merge
-> Linear bot auto Done
-> Parent Codex host-side gate confirmed
-> Post-Issue Ledger
```

它只记录和刷新关系事实，不授权下一步执行。

## 当前 hook

当前 Post-Issue Ledger 不依赖额外调度或图谱服务，不使用 `before_remove` hook。Parent Codex 在 host-side gate 里读取 PR/check/merge/root fast-forward/Linear Done evidence 后，可以写入 `.codex/post-issue-ledger/latest.json` 或对应 issue ledger 摘要；该摘要保持 read-only advisory，不进入 PR。

如果网络、GitHub、Linear 或持久仓库不可用，ledger 将失败或跳过原因写入结构化摘要，不阻塞已经完成的 PR / Linear Done 结果。

## 做什么

Post-Issue Ledger 做四件事：

1. 只读确认最新 `main` 或 root fast-forward evidence。
2. 只读确认 PR / required check / merge / Linear Done evidence。
3. 写入 `.codex/post-issue-ledger/latest.json` 结构化摘要。
4. 生成或承接下一步观察提示，用于 Human / Parent Codex 后续判断。

## 结构化摘要

摘要路径：

```text
.codex/post-issue-ledger/latest.json
```

摘要必须保持本地 ignored，不进入 PR。

摘要字段包括：

- `schema_version`
- `generated_at`
- `issue`
- `workspace`
- `repo_path`
- `operations`
- `next_step_hints`
- `boundaries`

其中 `operations` 至少记录：

- `root_fast_forward`
- `pr_check_merge_evidence`
- `linear_done_evidence`

每个 operation 可以是：

- `passed`
- `failed`
- `timeout`
- `skipped`

`next_step_hints.authorization` 必须是 `read_only`。

## 下一步观察提示

下一步观察提示是只读 advisory note。

它可以记录：

- 本轮完成的 Linear issue 和 PR。
- 本轮新增或改变的资源。
- 本轮 validation 和 evidence 的位置。
- 后续 issue 可能依赖的资源关系。
- 是否发现需要 Human 关注的阻塞或缺口。

它不得执行：

- 不把下一个 issue 改成 `Todo`。
- 不创建 Linear issue。
- 不修改 `docs/roadmap.md`。
- 不修改业务代码。
- 不启动或依赖额外调度服务。
- 不运行图谱更新服务。
- 不决定下一阶段目标。

## 和 Parent Codex 的关系

Post-Issue Ledger 只提供施工后关系事实和观察提示。

是否推进下一个 issue 仍由 Human 决定。

父 Codex 可以读取 `.codex/post-issue-ledger/latest.json` 并做 queue preview、风险提示和流程迭代建议，但必须遵守：

- WIP=1。
- 只有 Parent Codex 在当前 Human-approved Project 内完成 queue preflight 后，才可推进 eligible next issue。
- 不从观察提示直接获得执行授权。
- 不自动创建下一个 Project。

## 边界

- Post-Issue Ledger 不替代 Linear。
- Post-Issue Ledger 不替代 PR evidence。
- Post-Issue Ledger 不替代 `verification.md`。
- Post-Issue Ledger 不替代 Human Project Planning。
- Post-Issue Ledger 不授权 Codex 执行下一 issue。
- Post-Issue Ledger 不提交 `.codex/post-issue-ledger/*`。
