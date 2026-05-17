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
- 当前 active issue：Linear 实时读取确认 `MTP-23` 为唯一 `In Progress` issue。
- 依赖状态：`MTP-21`、`MTP-22` 均为 `Done`。
- 当前工作树：MTP-23 Research -> Backtest -> Report 最小路径实现中，PR 尚未创建。
- 本轮新增 Report read model / ViewModel、Dashboard Report shell snapshot 和 `docs/validation/mtp-23-stage-evidence.md`。
- Stage Code Audit Report 不属于 MTP-23 交付物，必须在 Project 全部 Done 后由父 Codex 单独输出。
- `symphony-issue` active Project pointer 仍指向 `mtpro-runtime-research-workbench-v1-222cf4e1965c`。
- workflow 本体不得为每个 Project 复制一套；Project 切换只更新 active Project pointer，并先做 queue preview。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-23 App / tests / contract docs / evidence docs 变更无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 59 个 XCTest 通过；新增 AppTests 覆盖 Report read model、Dashboard Report 快照、projection-level parity evidence 和 missing Paper projection 禁区断言。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## 当前边界

- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- Report 是研究输出，不是交易执行授权。
- 不输出 Stage Code Audit Report。
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
