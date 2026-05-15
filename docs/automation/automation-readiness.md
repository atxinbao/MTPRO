# MTPRO 自动化就绪状态

日期：2026-05-16

执行者：Codex

## 结论

MTPRO 已完成项目初始化、Bootstrap PR human merge、Linear Project setup 和 GitHub PR Automation setup。

MTPRO 项目级决策：不创建单独的 test-mode onboarding Project / Issues。

后续第一个真实 PR，即当前 `MTP-8` 的 PR，将用于验证 GitHub PR Automation 链路：

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
| Local validation entrypoint | 通过 | `checks/run.sh` 运行 `git diff --check` 和 `swift test` |
| Linear Project | 通过 | Project `MTPRO 引导` |
| Linear WIP=1 | 通过 | 当前仅 `MTP-8` 为 `Todo` |
| Symphony workflow | 准备中 | 本机 workflow `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md` 已存在，未启动 |
| Graphify | 未运行 | 未运行 Graphify update、scoped update 或 full rebuild |

## 当前 Linear 队列快照

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

## 当前允许的下一步

- 执行当前唯一 configured executable issue：`MTP-8`。
- 创建 ready-for-review PR。
- 用真实 PR 验证 GitHub PR Automation。
- PR merge 后等待 Linear bot auto Done。

## 当前禁止

- 不创建单独的 test-mode onboarding Project / Issues。
- 不创建新的 Linear Project / Issue。
- 不修改 Linear status。
- 不由 Codex 解锁 `MTP-9`。
- 不启动 Symphony，除非用户明确授权。
- 不运行 Graphify update、scoped update 或 full rebuild，除非当前 issue 明确要求。
- 不提交 `graphify-out/*`。
- 不实现 `LiveExecutionAdapter`。
- 不调用 Binance signed endpoint。

## 验证命令

- `git diff --check`
- `bash checks/run.sh`
- GitHub `protect-main` ruleset 查询
- GitHub repo settings 查询
- GitHub Actions `checks` run 查询
- Linear Project / Issue 只读查询
