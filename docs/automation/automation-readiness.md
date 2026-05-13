# MTPRO 自动化就绪检查

日期：2026-05-14

执行者：Codex

## 结论

Automation Readiness 当前已通过引导阶段检查。

GitHub private 仓库已创建，`origin` 已配置，Bootstrap Draft PR 已创建，并已将 PR 作为 attachment 关联到 Linear `MTP-7`。正式开发仍未允许；后续必须先完成 Bootstrap PR 的 Human Review，并由 Authorized Merge Agent 执行合并。

## 检查范围

- GitHub 仓库和 Git remote。
- GitHub + Linear 关联前提。
- PR 模板。
- Linear 队列与 WIP=1。
- Authorized Merge Agent 分离。
- Graphify 只读边界。
- `.codex/*` 与 `graphify-out/*` 排除。
- 当前是否进入正式开发执行。

## 检查结果

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| Git remote | 通过 | `origin` 指向 `https://github.com/atxinbao/MTPRO.git` |
| GitHub 仓库上下文 | 通过 | private 仓库 `atxinbao/MTPRO` 已创建 |
| Bootstrap PR | 通过 | Draft PR：`https://github.com/atxinbao/MTPRO/pull/1` |
| GitHub + Linear 关联 | 通过 | Linear `MTP-7` 已追加 Bootstrap PR attachment |
| PR 模板 | 通过 | 已新增 `.github/pull_request_template.md` |
| Linear Project | 通过 | Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`；名称：`MTPRO 引导` |
| Linear WIP=1 | 通过 | 按 Project ID 查询，仅 `MTP-8` 为 `Todo` |
| 非执行事项锁定 | 通过 | `MTP-9` 到 `MTP-15` 保持 `Backlog`，`MTP-7` 为 `Done` |
| Authorized Merge 分离 | 通过 | PR 模板已要求 Authorized Merge Agent 与 Codex Execution Agent 分离 |
| Graphify 只读边界 | 通过 | 未运行 Graphify update、scoped update 或 full rebuild |
| `graphify-out/*` 排除 | 通过 | `.gitignore` 包含 `graphify-out/` |
| `.codex/*` 排除 | 通过 | `.gitignore` 包含 `.codex/` |
| Symphony | 通过 | 未启动 Symphony |
| 正式开发执行 | 通过 | 未执行 `MTP-8`，未实现 Core、Binance、策略、UI 或数据库适配器 |

## Linear 队列快照

| Linear 事项 | 标题 | 状态 |
| --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Todo` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Backlog` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Backlog` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Backlog` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Backlog` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Backlog` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Backlog` |
| `MTP-15` | 验证加固与自动化就绪 | `Backlog` |

## 剩余门槛

1. Human Review 审查 Bootstrap Draft PR。
2. Authorized Merge Agent 检查 PR head sha、review comments 和 required checks。
3. Authorized Merge Agent 合并 Bootstrap PR。
4. 合并后再次确认 Linear WIP=1，再决定是否进入 `MTP-8`。

## 允许的下一步

- 审查 Bootstrap Draft PR。
- 检查 PR head sha。
- 保持 `MTP-8` 为唯一 `Todo`。
- 继续维护项目定义、契约文档和验证证据。

## 仍然禁止

- 不启动 Symphony。
- 不运行 Graphify update、scoped update 或 full rebuild。
- 不执行 `MTP-8` 的正式开发。
- 不实现 Binance adapter。
- 不实现 backtest engine。
- 不实现 paper execution。
- 不实现 database adapter。
- 不实现前端页面。
- 不实现 `LiveExecutionAdapter`。
- 不调用 Binance signed endpoint。

## 验证命令

- `git remote -v`
- `git status --short --branch --ignored`
- `gh repo view atxinbao/MTPRO --json nameWithOwner,url,isPrivate,defaultBranchRef`
- GitHub compare：`main...codex/bootstrap-readiness`
- Linear Project ID 查询
- Linear `Todo` 查询
- Linear `MTP-7` attachment 查询
- `git diff --check`
- `swift test`
