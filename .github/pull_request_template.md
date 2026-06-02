# 摘要

-

# 关联 Linear 事项

- Linked Linear Issue：
- Linear Project：`MTPRO 引导`
- WIP=1 证据：

# 来源

- 来源目标：
- 来源 Roadmap 阶段：
- 来源架构模块：

# 范围

-

# 非目标

-

# 边界确认

- [ ] 当前 Linear Project 执行前已确认 WIP=1，且当前事项是唯一 active configured executable issue。
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

# MTPRO 交易边界

- [ ] 未实现 `LiveExecutionAdapter`。
- [ ] 未调用 Binance signed endpoint。
- [ ] 未调用 Binance account endpoint。
- [ ] 未提交、取消或替换真实订单。
- [ ] 未引入真实经纪商动作。

# 验证

-

# Feedback Loop Evidence

- [ ] 已记录本 PR 使用的最快反馈环，例如 focused fixture / module test / Dashboard smoke / `bash checks/run.sh` / GitHub `checks`。
- [ ] 已说明为什么该反馈环足以覆盖本 PR scope。
- [ ] 未把真实 Binance 网络、signed endpoint、account endpoint、listenKey、broker 或真实订单作为 required validation。

# Tracer Bullet / Fixture Evidence

- [ ] 本 PR 触碰 production behavior，并已记录 deterministic fixture / vertical slice evidence。
- [ ] 本 PR 为 docs-only / evidence-only，不需要 tracer bullet；原因：
- [ ] 本 PR 未按 `Core / Persistence / App / UI` 横向扩大到无法独立验收的大块。

# Diagnose Evidence

- [ ] 本 PR 修复 bug / failing checks / replay mismatch / regression，并已记录 reproduce、minimise、hypothesis、fix 和 regression-test。
- [ ] 本 PR 不是 failure-driven change；原因：
- [ ] 如发生 host-side fallback、CI / 本地差异或临时平台边界，已记录归因和证据位置。

# Architecture Deepening Candidate

- [ ] `yes`：本 PR 发现模块深度、locality、leverage、术语漂移或边界泄漏问题，已记录为后续 planning 输入。
- [ ] `no`：本 PR 未发现需要进入后续 planning 的 architecture deepening candidate。
- [ ] 如选择 `yes`，本 PR 未顺手扩大 scope 做未授权重构。

# Pre-PR Codex Code Review

- [ ] 已执行 Pre-PR Codex Code Review。
- [ ] 已检查 diff 只覆盖当前 Linear issue scope。
- [ ] 已检查新增或修改 production code 具备详细中文注释。
- [ ] 已检查未突破 Live trading / Binance signed endpoint / broker action 边界。
- [ ] 已检查 validation 结果可信且可复现。

# Verified Operations

- [ ] 本 PR 不涉及跨系统 verified operation。
- [ ] 本 PR 涉及 verified operation，已记录 actor、授权来源、输入、输出、validation 和 evidence location。
- [ ] 如发生 host-side fallback，已记录原因、范围和证据。

# 证据链

-

# 草稿区门槛

- [ ] `.codex/*` 已排除在本 PR 之外。

# Parent Codex Automation Supervision

- [ ] 父 Codex 已执行或不需要执行 Project 级监督。
- [ ] Queue preview / issue state 检查已确认 WIP=1、依赖满足和执行合同格式；如推进 `Todo`，仅由父 Codex 在当前 Human-approved Project 内执行。
- [ ] 如使用 host-side fallback，已记录原因、范围和证据。
- [ ] 父 Codex 未扩大当前 issue scope。
- [ ] 父 Codex 未创建 Linear Project / Issue。
- [ ] 父 Codex 未直接 merge PR 或绕过 GitHub required checks。

# Post-Issue Ledger / 施工后记账

- [ ] PR merge / Linear bot auto Done 后，预计由 Parent Codex / host-side completion flow 按需执行 Post-Issue Ledger。
- [ ] Post-Issue Ledger 只写入 `.codex/post-issue-ledger/latest.json` 只读摘要，不依赖额外调度或图谱服务。
- [ ] 下一步观察提示不单独授权下一个 issue；后续推进必须由 Parent Codex queue preflight 判断，不创建 Linear issue，不修改 `ROADMAP.md`。
- [ ] `.codex/post-issue-ledger/*` 仍为本地 ignored output，不进入 PR。

# GitHub PR Automation 门槛

- [ ] GitHub required checks 预计运行。
- [ ] Required check: `checks`。
- [ ] ready_for_review: true。
- [ ] GitHub branch protection / main 保护规则预计适用。
- [ ] GitHub auto-merge 预计启用。
- [ ] auto_merge_enabled: true。
- [ ] Merge method: squash。
- [ ] Linear bot auto Done 预计在 merge 后触发。
- [ ] Codex Execution Agent 不直接 merge 自己生成的 PR。

# 已知限制

-

# 下一建议任务

-
