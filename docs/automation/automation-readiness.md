# MTPRO 自动化就绪状态

日期：2026-05-18

执行者：Codex

## 结论

MTPRO 已完成 `MTPRO 引导` Project 的自动化基线验证。

当前 active execution 不写入仓库文档。每轮执行前必须从 Linear / Parent Codex queue preview 读取唯一 active configured executable issue，并确认 WIP=1。

## 已验证能力

| 能力 | 状态 | 证据 |
| --- | --- | --- |
| GitHub Actions workflow | 通过 | `.github/workflows/checks.yml`，required job 为 `checks` |
| GitHub PR Automation | 通过 | `protect-main`、required checks、squash auto-merge、branch cleanup |
| Local validation entrypoint | 通过 | `bash checks/run.sh` |
| Automation readiness shell gate | 通过 | `bash checks/automation-readiness.sh` |
| Linear issue execution contract | 通过 | Linear issue 模板字段作为 child Codex 执行合同 |
| Parent Codex Automation Supervision | 通过 | queue preview、child Codex 监控、代码审查、host-side fallback |
| Codex use-cases alignment | 通过 | `docs/automation/codex-use-cases-alignment.md` |
| Verified operations | 通过 | `docs/automation/verified-operations.md` |
| symphony-issue path | 通过 | 唯一 `Todo` -> `In Progress` -> child Codex -> PR handoff -> `In Review` |
| Post-Issue Ledger | 通过 | PR merge / Linear bot Done 后刷新本地关系记账，输出 ignored summary |

## 当前流程边界

| 阶段 | 状态 | 边界 |
| --- | --- | --- |
| Human Project Planning | 下一 Project 前置 | Human 决定阶段目标、Project 和 issue 顺序 |
| Parent Codex Automation Supervision | 当前 Project 级监督方案 | 不替代 Human，不直接 merge PR，不自动创建下一 Project |
| symphony-issue | issue 级调度 | 只调度唯一 `Todo` issue |
| GitHub PR Automation | 已验证 | PR 合并由 GitHub required checks / auto-merge 执行 |
| Next Human Project Planning | 当前下一步 | 基于 stage audit 决定下一 Project |

## 必须保持

- `checks/run.sh` 是本地统一验证入口。
- `.github/pull_request_template.md` 必须保留 WIP=1、Graphify、handoff、Parent Codex、Post-Issue Ledger、GitHub PR Automation、Pre-PR Code Review 和 verified operations 证据项。
- `.gitignore` 必须排除 `.codex/` 和 `graphify-out/`。
- `.graphifyignore` 必须排除 `.codex/`、`graphify-out/`、`Sources/` 和 `Tests/`。
- Graphify 默认是 resource relationship graph，不是 source code graph。

## 禁止

- 不在文档中固定 current issue。
- 不自动推进下一个 issue。
- 不创建新的 Linear Project / Issue。
- 不绕过 GitHub required checks。
- 不运行 Graphify full rebuild。
- 不提交 `.codex/*` 或 `graphify-out/*`。
