# MTPRO 自动化就绪状态

日期：2026-05-16

执行者：Codex

## 结论

MTPRO 已完成项目初始化、Bootstrap PR human merge、Linear Project setup、symphony-issue 基本链路验证和 GitHub PR Automation setup。

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
| Local validation entrypoint | 通过 | `checks/run.sh` 运行 `git diff --check` 和 `swift test` |
| Linear Project | 通过 | Project `MTPRO 引导` |
| Linear WIP=1 | 通过 | `MTP-8` 和 `MTP-9` 已 Done；当前不在文档中固定下一 Todo |
| Symphony workflow | 已验证 | 本机 workflow 已跑通 MTP-8 / MTP-9 的 issue execution path |
| symphony-issue automation write profile | 通过 | workflow 使用 `workspaceWrite` turn sandbox 服务 issue workspace 写入；git / PR / handoff marker 可由 child Codex 完成，阻塞时由 host-side handoff fallback 接管 |
| Graphify | 通过 | 已按 `docs/automation/graphify-resource-graph-scope.md` 初始化本地 resource relationship graph；`graphify-out/*` 不进入 PR |

## AEP v2 正式流程状态

| 阶段 | 当前状态 | 通过条件 | 阻塞 / 边界 |
| --- | --- | --- | --- |
| 1. Human Project Planning | 已完成 | Project `MTPRO 引导` 和 issue 顺序已确认 | 不自动创建下一 Project |
| 2. symphony-project | 暂不接 continuation | 当前不自动推进下一个 Backlog issue | Codex 不修改 Linear |
| 3. symphony-issue | 已验证 | MTP-8 / MTP-9 已完成 issue execution path | Human 明确设置唯一 Todo 后再继续 |
| 4. GitHub PR Automation | 已通过真实 PR 验证 | PR #10 / PR #12 已验证 checks / auto-merge / branch cleanup / Linear bot auto Done | 后续 PR 仍必须通过 required check `checks` |
| 5. Next Human Project Planning | 未进入 | 当前 Project 全部 issues Done | Codex / symphony-issue / symphony-project 不决定下一阶段目标 |

## 当前 Linear 队列快照

| Linear 事项 | 标题 | 状态 |
| --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Done` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Done` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Backlog` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Backlog` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Backlog` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Backlog` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Backlog` |
| `MTP-15` | 验证加固与自动化就绪 | `Backlog` |

## 当前允许的下一步

- Human 明确选择是否将 `MTP-10` 推进为唯一 Todo。
- 如果 Linear 中存在唯一 configured executable issue，symphony-issue 可继续调度该 issue。
- 继续使用 GitHub PR Automation 验证 checks、auto-merge、branch cleanup 和 Linear bot auto Done。
- 在 symphony-issue automation write profile 下完成当前 issue workspace 更新；git commit / push、PR、auto-merge handoff 和本地 handoff marker 可由 child Codex 完成，若被环境阻塞则由 host-side handoff fallback 接管并记录原因。
- PR merge 后等待 Linear bot auto Done。

## 当前禁止

- 不创建新的 Linear Project / Issue。
- 不修改 Linear status。
- 不由 Codex 解锁 `MTP-10` 或后续 issue。
- 不启动 Symphony，除非用户明确授权。
- 不再次运行 Graphify update、scoped update 或 full rebuild，除非当前 issue 或用户明确要求。
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
- `graphify update .`
- Graphify source / test directory exclusion check
