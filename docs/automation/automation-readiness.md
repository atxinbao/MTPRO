# MTPRO 自动化就绪状态

日期：2026-05-20

执行者：Codex

本文档只记录自动化能力是否可用，不记录 current issue。

每轮执行前必须从 Linear / Parent Codex queue preview 读取唯一 active configured executable issue，并确认 WIP=1。

## 已验证能力

| 能力 | 状态 | 证据入口 |
| --- | --- | --- |
| GitHub Actions required check | ready | `.github/workflows/checks.yml`，job name `checks` |
| GitHub PR Automation | ready | `protect-main`、required checks、squash auto-merge、branch cleanup |
| Local validation entrypoint | ready | `bash checks/run.sh` |
| Automation readiness shell gate | ready | `bash checks/automation-readiness.sh` |
| Linear issue execution contract | ready | Linear issue body 字段作为 child Codex 执行合同 |
| Parent Codex Automation Supervision | ready | queue preview、eligible issue 调度、child Codex 监控、host-side fallback、Stage Code Audit |
| symphony-issue path | ready | 唯一 `Todo` -> `In Progress` -> child Codex -> PR handoff -> `In Review` |
| Post-Issue Ledger | ready | PR merge / Linear bot Done 后刷新本地关系记账，输出 ignored summary |
| Graphify resource graph | ready | read context + scoped post-issue refresh；不提交 `graphify-out/*` |
| Codex use-cases alignment | ready | `docs/automation/codex-use-cases-alignment.md` |
| Verified operations | ready | `docs/automation/verified-operations.md` |
| Paper Execution Workflow stage audit input anchor | ready | `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md` |
| Paper Workflow Control Shell stage audit input anchor | ready | `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md` |
| Market Data Replay Operations stage audit input anchor | ready | `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md` |

## Project 切换规则

`symphony-issue active Project pointer` 属于本地 runtime 配置，不是仓库长期事实。

Parent Codex 切换 Project 时只更新：

- Project name
- Project ID / URL source
- Project slug
- issue range
- next eligible candidate hint

更新后必须再次 queue preview。不得因为 pointer 更新直接启动 `symphony-issue` 或推进 `Backlog -> Todo`。

## 必须保持

- WIP=1。
- `.github/pull_request_template.md` 保留 WIP=1、Graphify、handoff、Parent Codex、Post-Issue Ledger、GitHub PR Automation、Pre-PR Code Review 和 verified operations 证据项。
- Project Planning Facilitator 不操作 `Backlog -> Todo`。
- Human 确认 Project / Issue plan 并写入 Linear 后，父 Codex 在当前 Project 内按 WIP=1、依赖和执行合同 Gate 自动推进唯一 eligible issue。
- `symphony-issue` workflow 本体不得为每个 Linear Project 复制一套。
- `.gitignore` 排除 `.codex/` 和 `graphify-out/`。
- `.graphifyignore` 排除 `.codex/`、`graphify-out/`、`Sources/` 和 `Tests/`。
- Graphify 默认是 resource relationship graph，不是 source code graph。

## 禁止

- 不在文档中固定 current issue。
- 不自动创建新的 Linear Project / Issue。
- 不绕过 GitHub required checks。
- 不运行 Graphify full rebuild。
- 不提交 `.codex/*` 或 `graphify-out/*`。
