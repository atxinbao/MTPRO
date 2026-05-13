# MTPRO 自动化就绪检查

日期：2026-05-14

执行者：Codex

## 结论

Automation Readiness 当前为部分通过，尚未完全就绪。

阻塞项是 GitHub 仓库前提未满足：本地仓库没有配置 Git remote，因此无法创建 Bootstrap PR，也无法验证 GitHub + Linear 关联。除 GitHub 关联外，PR 模板、Linear WIP=1、Authorized Merge 分离约束、Graphify 只读边界和本地忽略规则已完成或已确认。

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
| Git remote | 阻塞 | `git remote -v` 无输出 |
| GitHub 仓库上下文 | 阻塞 | 无 remote，`gh repo view` 无可用仓库上下文 |
| GitHub + Linear 关联 | 待验证 | 需要先配置 GitHub remote，并创建或关联 PR |
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

## 阻塞项

1. 配置 GitHub remote。
2. 推送 baseline 分支或 main 基线。
3. 创建 Bootstrap PR。
4. 验证 GitHub PR 与 Linear 事项关联。
5. 由 Human Review 确认 Bootstrap PR 和自动化就绪证据。

## 允许的下一步

- 配置 GitHub remote。
- 准备 Bootstrap PR。
- 验证 GitHub + Linear 关联。
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
- Linear Project ID 查询
- Linear `Todo` 查询
- `git diff --check`
- `swift test`
