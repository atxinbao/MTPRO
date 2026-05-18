# 最近验证摘要

日期：2026-05-18

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 当前 Linear Project：`MTPRO Runtime Research Workbench v1`。
- Project 状态：`MTP-16` 到 `MTP-23` 全部为 Linear `Done`。
- 当前 active issue：无。
- 当前工作树：已同步到 `origin/main` 的 `948cc67a6b9dff898deb4d46c7f793a2e7de6e83`。
- Stage Code Audit Report 已由 Parent Codex 固化到 `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`。
- Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界和最终通过证据。
- Stage Code Audit Report 使用 `<linear-project-slug>-stage-code-audit.md` 命名规则，覆盖完整 Linear Project，不是单个 issue evidence。
- Post-Issue Ledger 已完成，`git_pull_ff_only` 和 `graphify_update` 均为 `passed`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- `symphony-issue` active Project pointer 仍指向 `mtpro-runtime-research-workbench-v1-222cf4e1965c`。
- workflow 本体不得为每个 Project 复制一套；Project 切换只更新 active Project pointer，并先做 queue preview。
- `@002 Startup Runbook` 已固化：父 Codex 接管新 Project 时必须先执行 Project / Issue 格式 Gate、queue preview、active Project pointer 更新和 pointer 后二次 queue preview；gate 全部通过后，才可自动推进唯一 eligible `Backlog` -> `Todo`。
- Project Planning Record 已统一到 `docs/planning/projects/`。
- 当前 Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- Planning Record 状态：写入 Linear 前记录；不授权执行，不创建 Linear Project / Issues，不修改 Linear status。
- Planning Record 只保存 Project 级计划摘要和格式门槛；完整 issue execution contract 以 Linear 为准。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-23 App / tests / contract docs / evidence docs 变更无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 59 个 XCTest 通过；新增 AppTests 覆盖 Report read model、Dashboard Report 快照、projection-level parity evidence 和 missing Paper projection 禁区断言。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | pass | `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md` 已记录 Project completion、Issue / PR evidence、validation、Known CI Boundary、boundary audit 和 handoff。 |

## 当前边界

- Runtime Research Workbench v1 已完成；本摘要不授权下一阶段开发。
- Stage Code Audit Report 只作为 Next Human Project Planning 输入，不替代 Human 决策。
- `MTPRO Trading Validation and Parity Hardening` planning record 不授权执行。
- 当前 planning record 不创建 Linear Project / Issues。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- Report 是研究输出，不是交易执行授权。
- 不做完整报表系统。
- 不做完整 Paper execution 工作流。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
