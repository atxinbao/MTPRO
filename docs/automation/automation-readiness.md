# MTPRO 自动化就绪状态

日期：2026-05-17

执行者：Codex

## 结论

MTPRO 已完成项目初始化、Bootstrap PR human merge、Linear Project setup、symphony-issue 基本链路验证和 GitHub PR Automation setup。

MTP-15 当前用于把验证矩阵、PR 证据模板、WIP=1 队列边界、symphony-issue handoff marker 和 Graphify / Post-Issue Ledger 边界固化为本地可重复检查。

后续真实 PR 使用已验证的 GitHub PR Automation 链路：

```text
Codex creates ready-for-review PR
-> GitHub checks
-> GitHub auto-merge / squash merge
-> branch cleanup
-> Linear bot auto Done
```

## 当前自动化状态

| 项目 | 状态 | 证据 |
| --- | --- | --- |
| Repository visibility | 通过 | `atxinbao/MTPRO` 已为 public |
| GitHub Actions workflow | 通过 | `.github/workflows/checks.yml`，workflow `AEP Checks` active |
| Required check | 通过 | `protect-main` ruleset 要求 `checks` |
| Merge method | 通过 | 只允许 squash merge |
| Auto-merge | 通过 | repo setting `allow_auto_merge=true` |
| Branch cleanup | 通过 | repo setting `delete_branch_on_merge=true` |
| Branch protection / ruleset | 通过 | `protect-main` active，target default branch |
| Local validation entrypoint | 通过 | `checks/run.sh` 运行 `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` |
| Automation readiness shell gate | 通过 | `checks/automation-readiness.sh` 检查 workflow、PR 模板、WIP=1、handoff marker、Graphify 边界、ignore 边界和验证文档 |
| Linear Project | 通过 | Project `MTPRO 引导` |
| Linear WIP=1 | 通过 | 当前只读查询显示 `MTP-15` 为唯一 active issue；`MTP-14` 已 Done；文档不固定未来 current issue |
| Parent Codex Automation Supervision | 通过 | 父 Codex 负责 Project 级 queue preview、child Codex 监控、代码审查、host-side fallback 和流程迭代建议；只有 Human 明确授权后才可推进 eligible `Backlog` 为唯一 `Todo` |
| Symphony workflow | 已验证 | 本机 workflow 已跑通 MTP-8 / MTP-9 / MTP-10 的 issue execution path |
| symphony-issue automation write profile | 通过 | workflow 使用 `dangerFullAccess` turn sandbox 服务 issue workspace 写入、git、PR 和 handoff marker；GitHub token / 网络 / MCP elicitation 阻塞时由 host-side handoff fallback 接管 |
| Post-Issue Ledger / 施工后记账 | 通过 | PR merge / Linear bot Done 后，由 host-side `before_remove` 在 `/Users/mac/Documents/MTPRO` 同步 main、刷新 Graphify resource relationship graph，并写入 `.codex/post-issue-ledger/latest.json` 只读摘要；`.codex/*` 和 `graphify-out/*` 不进入 PR |

## AEP v2 正式流程状态

| 阶段 | 当前状态 | 通过条件 | 阻塞 / 边界 |
| --- | --- | --- | --- |
| 1. Human Project Planning | 已完成 | Project `MTPRO 引导` 和 issue 顺序已确认 | 不自动创建下一 Project |
| 2. Parent Codex Automation Supervision | 已启用人工监督模式 | 父 Codex 可做 queue preview、监控 child Codex、审查 diff、处理受控 host-side fallback | 只有 Human 明确授权后，父 Codex 才可把 eligible `Backlog` 推进为唯一 `Todo`；当前未接入独立 Project 级 continuation 程序 |
| 3. symphony-issue | 已验证并执行 MTP-15 | MTP-8 到 MTP-14 已完成 issue execution path；MTP-15 当前为唯一 active issue | 当前 child Codex 只执行 MTP-15 scope，不修改 Linear status |
| 4. GitHub PR Automation | 已通过真实 PR 验证 | 前序事项已验证 checks / auto-merge / branch cleanup / Linear bot auto Done | 后续 PR 仍必须通过 required check `checks` |
| 5. Next Human Project Planning | 未进入 | 当前 Project 全部 issues Done | Codex / symphony-issue / 父 Codex 不决定下一阶段目标 |

## 当前 Linear 队列快照

执行时只读快照日期：2026-05-17。

| Linear 事项 | 标题 | 状态 |
| --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Done` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Done` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Done` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Done` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Done` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Done` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Done` |
| `MTP-15` | 验证加固与自动化就绪 | `In Progress` |

## MTP-15 当前允许的下一步

- 只完成 `MTP-15` 验证加固与自动化就绪 scope。
- 继续使用 GitHub PR Automation 验证 checks、auto-merge、branch cleanup 和 Linear bot auto Done。
- 在 symphony-issue `dangerFullAccess` automation profile 下完成当前 issue workspace 更新；git commit / push、PR、auto-merge handoff 和本地 handoff marker 可由 child Codex 完成，若被 GitHub token / 网络 / MCP elicitation 阻塞则由 host-side handoff fallback 接管并记录原因。
- 父 Codex 监控 `symphony-issue` 和 child Codex，审查 diff / validation / PR evidence，并将真实阻塞反馈到 automation docs。
- PR merge 后等待 Linear bot auto Done。

## 当前禁止

- 不创建新的 Linear Project / Issue。
- 不修改 Linear status。
- 不由 Codex 自动解锁 `MTP-11` 或后续 issue；只有 Human 明确授权后，父 Codex 才可推进 eligible `Backlog` 为唯一 `Todo`。
- 不启动 Symphony，除非用户明确授权。
- 不运行 Graphify full rebuild；Post-Issue Ledger / 施工后记账由 symphony-issue host-side `before_remove` 处理，只刷新 resource relationship graph 并写入只读结构化摘要。
- 不提交 `graphify-out/*`。
- 不实现 `LiveExecutionAdapter`。
- 不调用 Binance signed endpoint。
- 不自动推进 MTP-15 之后的新 issue；当前 Project 全部 Done 后进入 Human 下一步规划。

## 验证命令

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub `protect-main` ruleset 查询
- GitHub repo settings 查询
- GitHub Actions `checks` run 查询
- Linear Project / Issue 只读查询
- PR merge / Linear bot Done 后，symphony-issue host-side `before_remove` 在 `/Users/mac/Documents/MTPRO` 执行 Post-Issue Ledger，并写入 `.codex/post-issue-ledger/latest.json`
- 下一步观察提示只读，不授权下一个 issue
- Graphify source / test directory exclusion check

## MTP-15 自动化就绪检查项

日期：2026-05-17

执行者：Codex

| 检查项 | 本地证据 | 期望 |
| --- | --- | --- |
| GitHub + Linear 关联 | PR body `Linked Linear Issue` 与 Linear URL | PR 明确关联当前唯一 configured executable issue |
| GitHub required check | `.github/workflows/checks.yml` | job 名称保持 `checks`，入口为 `bash checks/run.sh` |
| PR Automation Gate | `.github/pull_request_template.md` | required check、squash auto-merge、Linear bot auto Done、Codex 不直接 merge 均有勾选项 |
| symphony-issue handoff marker | `.github/pull_request_template.md` 与本地 `.codex/symphony-issue-handoff.json` | marker 包含 `pr_url`、`ready_for_review: true`、`auto_merge_enabled: true` 且不进入 PR |
| WIP=1 | Linear 只读 queue preview 与 PR body | 同一 Project 只有一个 active configured executable issue |
| Graphify 边界 | `.graphifyignore` 与 Graphify evidence | 不运行 full rebuild；不提交 `graphify-out/*`；Post-Issue Ledger host-side 刷新 |
| 本地输出隔离 | `.gitignore`、Pre-PR review | `.codex/*` 与 `.codex/post-issue-ledger/*` 不进入 PR |
