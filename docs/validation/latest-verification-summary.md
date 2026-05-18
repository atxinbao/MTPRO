# 最近验证摘要

日期：2026-05-18

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- 最近验证对象：`MTP-24`，目标是定义 Trading Validation Matrix 和验收证据边界。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- 该 Project 已写入 Linear；执行事实源是 Linear issue body，planning record 仍不单独授权执行。
- 本轮变更新增 `docs/validation/trading-validation-matrix.md`，并在 `checks/automation-readiness.sh` 中检查矩阵文件和 required anchors。
- 上一完成 Linear Project：`MTPRO Runtime Research Workbench v1`，`MTP-16` 到 `MTP-23` 全部为 Linear `Done`。
- 上一阶段 Stage Code Audit Report 已由 Parent Codex 固化到 `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`。
- Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界和最终通过证据。
- Stage Code Audit Report 使用 `<linear-project-slug>-stage-code-audit.md` 命名规则，覆盖完整 Linear Project，不是单个 issue evidence。
- Post-Issue Ledger 已完成，`git_pull_ff_only` 和 `graphify_update` 均为 `passed`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。
- workflow 本体不得为每个 Project 复制一套；Project 切换只更新 active Project pointer，并先做 queue preview。
- `@002 Startup Runbook` 已固化：父 Codex 接管新 Project 时必须先执行 Project / Issue 格式 Gate、queue preview、active Project pointer 更新和 pointer 后二次 queue preview；gate 全部通过后，才可自动推进唯一 eligible `Backlog` -> `Todo`。
- Project Planning Record 已统一到 `docs/planning/projects/`。
- Planning Record 只保存 Project 级计划摘要和格式门槛；完整 issue execution contract 以 Linear 为准。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-24 validation matrix、validation plan、latest summary、readiness gate 和 verification 变更无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；已检查 `docs/validation/trading-validation-matrix.md` 和 required `TVM-*` anchors。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 59 个 XCTest 通过；现有 coverage 入口用于支撑 Trading Validation Matrix 的 EMA parity、order book imbalance、risk / portfolio projection 和 report evidence 行。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | n/a | 当前 Project 尚未全部 Done；本轮只准备 MTP-24 issue evidence，Project 级 Stage Code Audit Report 仍须在 MTP-24 至 MTP-30 全部 Done 后由 Parent Codex 输出。 |

## 当前边界

- MTP-24 只定义 Trading Validation Matrix 和验收证据边界，不授权 MTP-25 或其他后续 issue。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- 当前 planning record 不创建 Linear Project / Issues，不替代 Linear issue body。
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
