# MTPRO Post-Issue Ledger / 施工后记账

日期：2026-05-16

执行者：Codex

## 定位

Post-Issue Ledger 是 MTPRO 在 `symphony-issue` 完成一个 Linear issue 后执行的本地记账环节。

它发生在：

```text
GitHub PR Automation merge
-> Linear bot auto Done
-> symphony-issue terminal state detected
-> host-side before_remove
-> Post-Issue Ledger
```

它只记录和刷新关系事实，不授权下一步执行。

## 当前 hook

当前本机 `symphony-issue` workflow 的 `before_remove` 负责执行 Post-Issue Ledger。

当前操作为：

```bash
cd /Users/mac/code/tools/symphony/elixir
mise exec -- mix workspace.post_issue_ledger \
  --repo-path /Users/mac/Documents/MTPRO \
  --issue "${SYMPHONY_ISSUE_IDENTIFIER:-$(basename "$PWD")}" \
  --workspace "${SYMPHONY_WORKSPACE:-$PWD}" \
  --output /Users/mac/Documents/MTPRO/.codex/post-issue-ledger/latest.json || true
```

如果 `graphify` 命令、`git pull` 或持久仓库不可用，hook 将失败或跳过原因写入结构化摘要，不阻塞已经完成的 PR / Linear Done 结果。

## 做什么

Post-Issue Ledger 做五件事：

1. 同步最新 `main`。
2. 刷新本地 Graphify resource relationship graph。
3. 保留 `graphify-out/*` 作为本地 ignored output，不进入 Git PR。
4. 写入 `.codex/post-issue-ledger/latest.json` 结构化摘要。
5. 生成或承接下一步观察提示，用于 Human / Parent Codex 后续判断。

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
- `graphify`
- `next_step_hints`
- `boundaries`

其中 `operations` 至少记录：

- `git_pull_ff_only`
- `graphify_update`

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
- 不修改 `ROADMAP.md`。
- 不修改业务代码。
- 不启动 Symphony。
- 不决定下一阶段目标。

## 和 Parent Codex 的关系

Post-Issue Ledger 只提供施工后关系事实和观察提示。

是否推进下一个 issue 仍由 Human 决定。

父 Codex 可以读取 `.codex/post-issue-ledger/latest.json` 并做 queue preview、风险提示和流程迭代建议，但必须遵守：

- WIP=1。
- 只有 Human 明确授权后，才可推进 eligible next issue。
- 不从观察提示直接获得执行授权。
- 不自动创建下一个 Project。

## 边界

- Post-Issue Ledger 不替代 Linear。
- Post-Issue Ledger 不替代 PR evidence。
- Post-Issue Ledger 不替代 `verification.md`。
- Post-Issue Ledger 不替代 Human Project Planning。
- Post-Issue Ledger 不授权 Codex 执行下一 issue。
- Post-Issue Ledger 不提交 `graphify-out/*`。
- Post-Issue Ledger 不提交 `.codex/post-issue-ledger/*`。
