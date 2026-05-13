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

# Graphify 上下文状态

- [ ] 未使用 graph context。
- [ ] 复用既有 Graphify 上下文。
- [ ] Graphify 上下文不可用。

Graphify 边界：

- [ ] Graphify 仅作为只读上下文使用。
- [ ] 未运行 Graphify update。
- [ ] 未运行 Graphify scoped update。
- [ ] 未运行 Graphify full rebuild。
- [ ] 未包含 `graphify-out` 变更。
- [ ] 未提交 task-local graph。
- [ ] 未提交 generic `Community N` graph regression。

# 验证

-

# 证据链

-

# 草稿区门槛

- [ ] `.codex/*` 已排除在本 PR 之外。

# Authorized Merge 门槛

- [ ] Authorized Merge Agent 与 Codex Execution Agent 分离。
- [ ] 合并前已检查 PR head sha。
- [ ] 没有未解决的 review comments。
- [ ] 没有失败的 required checks。
- [ ] Authorized Merge Agent 未修改代码、PR diff 或证据链。

# 已知限制

-

# 下一建议任务

-
