# 最近验证摘要

日期：2026-05-18

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近合并 PR：MTPRO #42 `MTP-20 Add Binance public read-only client boundary`
- 最近 merge commit：`b4849a4`
- 当前工作树：MTP-22 macOS Dashboard shell 实现中，PR 尚未创建。
- 当前基线：active docs 已收口，`MTPRO 引导` Project 已完成，`MTPRO Runtime Research Workbench v1` 已写入 Linear。
- 下一阶段 Linear Project：`MTPRO Runtime Research Workbench v1` 已创建，Project status 为 `Planned`。
- 下一阶段 Linear issues：`MTP-16` 到 `MTP-23` 已创建；当前状态以 Linear 实时读取为准。
- 当前 Todo / In Progress：从 Linear 实时读取。
- `MTP-16`、`MTP-17`、`MTP-18`、`MTP-19` 和 `MTP-20` 已通过 symphony-issue / GitHub PR Automation 完成并进入 `Done`。
- 当前 active issue 由 Linear 实时读取；本轮执行确认 `MTP-22` 为唯一 `In Progress` issue。
- Linear Project / Issue 正文必须在进入 `Todo` 前统一为 Codex Execution Agent 执行合同格式，并由父 Codex核对。
- Project Planning Facilitator 只负责阶段规划和 Linear 写入准备；不得操作 `Backlog` -> `Todo`。
- Parent Codex 是唯一可在当前 Human-approved Project 内自动操作 `Backlog` -> `Todo` 的角色。
- `symphony-issue` active Project pointer 已切到 `MTPRO Runtime Research Workbench v1`；当前 Symphony runtime 使用 project slug：`mtpro-runtime-research-workbench-v1-222cf4e1965c`。
- workflow 本体不得为每个 Project 复制一套；Project 切换只更新 active Project pointer，并先做 queue preview。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-22 macOS dashboard shell、验证脚本和 contract 文档变更无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=7; readModelOnly=true; sections=Market,Strategy,Backtest,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 新增 AppTests 覆盖 shell snapshot binding、空 read model 初始快照和 forbidden integration source boundary；58 个 XCTest 通过。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；58 个 XCTest 通过，输出 `MTPRO checks passed.` |
| GitHub Actions `checks` 初次运行 | fail -> fixed | Linux runner 无 SwiftUI，已改为 macOS 分支构建真实 SwiftUI shell、非 macOS fallback 验证 snapshot binding 和 executable 编译。 |

## 当前边界

- 不固定 current Linear issue。
- 不修改 Linear status。
- Project Planning Facilitator 不操作 `Backlog` -> `Todo`。
- Parent Codex 更新 active Project pointer 不授权启动 `symphony-issue`。
- 不再创建新的 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
