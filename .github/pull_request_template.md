# 摘要

-

# 关联 Linear 事项

-

# 来源

- 来源目标：
- 来源 Roadmap 阶段：
- 来源架构模块：

# 范围

-

# 非目标

-

# 边界确认

- [ ] 本 PR 只执行当前唯一 configured executable Linear 事项。
- [ ] 本 PR 不执行任何 `Backlog`、`In Review` 或 `Done` 事项。
- [ ] 本 PR 不依赖 label gate 作为执行授权。
- [ ] 本 PR 不创建新的 Linear 事项。
- [ ] 本 PR 不创建新的 Linear Project。
- [ ] 本 PR 不决定新的项目 Goal。
- [ ] 本 PR 不跳过 Roadmap 或里程碑顺序。
- [ ] 本 PR 不修改 Linear 状态。
- [ ] 本 PR 不解锁下一事项。
- [ ] 本 PR 不提交 `.codex/*`。
- [ ] 本 PR 不提交 `graphify-out/*`。

# MTPRO 交易边界

- [ ] 未实现 `LiveExecutionAdapter`。
- [ ] 未调用 Binance signed endpoint。
- [ ] 未调用 Binance account endpoint。
- [ ] 未提交、取消或替换真实订单。
- [ ] 未引入真实经纪商动作。

# Graphify 上下文和更新状态

- [ ] 执行前复用既有 Graphify read context。
- [ ] Graphify read context 不可用，并已记录原因。

Graphify 边界：

- [ ] 执行后已运行 Graphify scoped resource relationship graph update。
- [ ] 本 issue 不需要 Graphify scoped update，并已记录原因。
- [ ] Graphify scoped update 因环境不可用未运行，并已记录原因。
- [ ] 未运行 Graphify full rebuild。
- [ ] 未提交 `graphify-out/*`。
- [ ] 未提交 task-local graph。
- [ ] 未提交 generic `Community N` graph regression。

# 验证

-

# 证据链

-

# 草稿区门槛

- [ ] `.codex/*` 已排除在本 PR 之外。

# symphony-issue Handoff

- [ ] 本地 handoff marker `.codex/symphony-issue-handoff.json` 已在 ready-for-review PR 和 GitHub auto-merge handoff 后写入。
- [ ] Handoff marker 包含 `pr_url`、`ready_for_review: true` 和 `auto_merge_enabled: true`。
- [ ] Handoff marker 未进入本 PR。
- [ ] Child Codex 已在 symphony-issue automation write profile 下完成 git / PR / handoff，或已记录 host-side handoff fallback 原因。

# Parent Codex Automation Supervision

- [ ] 父 Codex 已执行或不需要执行 Project 级监督。
- [ ] Queue preview / issue state 检查只读，除非 Human 明确授权推进唯一 `Todo`。
- [ ] 如使用 host-side fallback，已记录原因、范围和证据。
- [ ] 父 Codex 未扩大当前 issue scope。
- [ ] 父 Codex 未创建 Linear Project / Issue。
- [ ] 父 Codex 未直接 merge PR 或绕过 GitHub required checks。

# Post-Issue Ledger / 施工后记账

- [ ] PR merge / Linear bot auto Done 后，预计由 symphony-issue host-side `before_remove` 执行 Post-Issue Ledger。
- [ ] Post-Issue Ledger 只同步持久本地仓库、刷新 Graphify resource relationship graph，并写入 `.codex/post-issue-ledger/latest.json` 只读摘要。
- [ ] 下一步观察提示不授权下一个 issue，不创建 Linear issue，不修改 `ROADMAP.md`。
- [ ] `.codex/post-issue-ledger/*` 和 `graphify-out/*` 仍为本地 ignored output，不进入 PR。

# GitHub PR Automation 门槛

- [ ] GitHub required checks 预计运行。
- [ ] Required check: `checks`。
- [ ] GitHub branch protection / main 保护规则预计适用。
- [ ] GitHub auto-merge 预计启用。
- [ ] Merge method: squash。
- [ ] Linear bot auto Done 预计在 merge 后触发。
- [ ] Codex Execution Agent 不直接 merge 自己生成的 PR。

# 已知限制

-

# 下一建议任务

-
