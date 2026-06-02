# MTPRO Trader EMA Strategy Layout Consolidation v1 Plan

执行者：Codex  
日期：2026-06-02  
类型：docs-only planning record / non-executable

## 文档定位

本文件只保存 `MTPRO Trader EMA Strategy Layout Consolidation v1` 的 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

后续如写入 Linear，完整 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以 Linear issue body 为准。

## Project name

`MTPRO Trader EMA Strategy Layout Consolidation v1`

## Target maturity

`Trader-owned EMA-only strategy layout before L4`

## Target Engines / Modules

- `Trader`
- `Trader/Accounts`
- `Trader/Strategies/EMA`
- `Trader/Coordination`
- `Trader/Coordination/RiskBinding`
- `Portfolio`
- `RiskEngine`
- `ExecutionEngine`
- `ExecutionClient` future gate
- Workbench / Dashboard read-model-only evidence boundary

## Project goal

在 `MTPRO Trader-Owned Strategies Layout Correction v1` 完成后，进一步收紧 Trader-owned strategy layout：当前 active concrete strategy 只保留 `EMA`，canonical active strategy path 只保留 `Sources/Trader/Strategies/EMA`。

本阶段把 `RSI`、`OrderBookImbalance`、`Momentum`、`MeanReversion` 等非 EMA 策略收口为 future candidates，不进入当前 active source / tests / `Package.swift` path；同时把 `StrategyBindings` 从 Trader 下一级策略目录语义中移出，如仍需要 binding / adapter 语义，应归入 `Trader/Coordination`。

## Target layout

```text
Sources/Trader/
  Accounts/
  Strategies/
    EMA/
      Lifecycle/
      Signals/
      Proposals/
      Quoter/
      Hedger/
  Coordination/
    RiskBinding/
```

规则：

- 当前 active concrete strategy only：`EMA`。
- 当前 canonical active strategy path only：`Sources/Trader/Strategies/EMA`。
- `RSI` / `OrderBookImbalance` / `Momentum` / `MeanReversion` 只能作为 future candidates，不进入当前 active source / tests / `Package.swift` path。
- `StrategyBindings` 不再作为 Trader 下一级策略目录；如仍需要 binding / adapter 语义，应归入 `Trader/Coordination`，例如 `Trader/Coordination/RiskBinding`。
- Strategy 不得直连 `ExecutionClient`、broker、OMS、live command 或 real order lifecycle。

## Scope

- 定义 EMA-only Trader strategy layout contract。
- 按需更新有 strategy anchor 的 root docs，不强制无意义更新 `GOAL.md` / `BLUEPRINT.md`。
- 审计当前 source、`Package.swift` 和 tests 中的非 EMA strategy anchors。
- 移除或迁出非 EMA active strategy source，使 active source layout 只剩 EMA。
- 重新归类 `StrategyBindings`：只允许作为 `Trader/Coordination` 下的 binding protocol / adapter contract。
- 增加 EMA-only strategy path validation。
- 收口 validation matrix、compatibility envelope 和 stage audit input material。

## Non-goals

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不移动 production source，除非后续唯一 executable Linear issue 授权。
- 不修改 `Package.swift`，除非后续唯一 executable Linear issue 授权。
- 不拆 SwiftPM target graph。
- 不实现 Strategy runtime / Trader runtime / Live runtime。
- 不实现 `ExecutionClient` implementation / OMS / broker gateway。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不把 `RSI` / `OrderBookImbalance` / `Momentum` / `MeanReversion` 写成当前 active strategy。

## Milestones

| Milestone | 目标 |
| --- | --- |
| M1 Contract | 固定 EMA-only Trader strategy layout、future candidate 口径和 forbidden path taxonomy。 |
| M2 Docs Anchors | 按需更新有 strategy anchor 的 root docs，避免继续把非 EMA strategy 写成 active layout。 |
| M3 Source Audit / Retirement | 审计并收口非 EMA active strategy source，使当前 active source 只剩 EMA。 |
| M4 Coordination Binding | 把 `StrategyBindings` 重新归类到 `Trader/Coordination` binding / adapter contract。 |
| M5 Validation / Closeout | 增加 EMA-only path validation，准备 compatibility envelope 和 stage audit input。 |

## Corrected issue order

1. Define EMA-only Trader strategy layout contract
2. Update root docs to remove non-EMA active strategy anchors
3. Audit current source, Package.swift and tests for non-EMA strategy anchors
4. Retire non-EMA active strategy source from current layout
5. Move StrategyBindings into Trader Coordination boundary
6. Add EMA-only strategy path validation
7. Close validation matrix / compatibility envelope / stage audit input

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 2
- Issue 4 blocked by Issue 3
- Issue 5 blocked by Issue 3
- Issue 6 blocked by Issue 4, Issue 5
- Issue 7 blocked by Issue 6

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| Issue 1 | 定义 EMA-only Trader strategy layout contract、canonical active path 和 future candidate 语义。 | Docs / contract only；不移动 source，不修改 `Package.swift`。 |
| Issue 2 | 按需更新有 strategy anchor 的 root docs，去掉非 EMA active strategy anchors。 | 不强制无意义更新 `GOAL.md` / `BLUEPRINT.md`；不授权执行。 |
| Issue 3 | 审计 `Sources/`、`Tests/`、`Package.swift` 中非 EMA active strategy anchors。 | 只输出可验证 audit evidence，不迁移 source。 |
| Issue 4 | 移除或迁出非 EMA active strategy source，使 active source layout 只剩 `Sources/Trader/Strategies/EMA`。 | 不实现新 strategy runtime；非 EMA 只保留 future candidate 语义。 |
| Issue 5 | 将 `StrategyBindings` 从 Trader 下一级策略目录语义迁入 `Trader/Coordination` boundary。 | Binding / adapter contract only；不得形成 execution gateway。 |
| Issue 6 | 增加 EMA-only strategy path validation 和 forbidden strategy path checks。 | 不拆 SwiftPM target graph，不接 broker / OMS / live command。 |
| Issue 7 | 收口 validation matrix、compatibility envelope 和 stage audit input material。 | 只准备 stage audit input；最终 Stage Code Audit 由 Parent Codex 单独输出。 |

## Validation requirements

- 每个 issue 必须运行 `bash checks/run.sh`。
- 必须验证 active concrete strategy only：`EMA`。
- 必须验证 canonical active strategy path only：`Sources/Trader/Strategies/EMA`。
- 必须验证 `RSI` / `OrderBookImbalance` / `Momentum` / `MeanReversion` 只作为 future candidates，不进入当前 active source / tests / `Package.swift` path。
- 必须验证 `StrategyBindings` 不再作为 Trader 下一级策略目录；binding / adapter 语义只能归入 `Trader/Coordination`。
- 必须验证 strategy 不得直连 `ExecutionClient`、broker、OMS、live command 或 real order lifecycle。
- 必须验证 no Strategy runtime / Trader runtime / Live runtime。
- 必须验证 no `ExecutionClient` implementation / OMS / broker gateway。
- 必须验证 no signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 必须验证 no real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 必须验证 no Live PRO Console、trading button、live command 或 order form。
- PR 必须包含 MTPRO-native PR evidence fields。

## Evidence requirements

- 每个 PR 必须包含 Linked Linear Issue、Scope / Non-goals、validation output、boundary evidence 和 changed paths summary。
- 每个 PR 必须明确 active concrete strategy remains EMA-only。
- 每个 PR 必须明确 non-EMA strategies are future candidates only。
- 每个 PR 前必须执行 Pre-PR Codex Code Review。
- 每个 PR 必须使用 GitHub PR Automation。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- 如由 `symphony-issue` 执行，必须提供 handoff marker evidence。
- Issue 7 只准备 stage audit input material，不输出最终 Stage Code Audit Report。
- Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define EMA-only Trader strategy layout contract`

该 issue 只是 first executable candidate，不构成执行授权。

## WIP=1 / queue preflight rule

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、无 active conflict、execution contract 格式完整，才可推进唯一 eligible issue 到 Todo。

## Linear write boundary

- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- 本 planning record 不推进 Todo。
- 后续完整 execution contract 以 Linear issue body 为准。
- Linear 写入后，所有 issue 初始必须保持 `Backlog / non-executable`。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 Linear issue body。
- Planning record 不授权执行。
- 后续 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以 Linear issue body 为准。

## Compatibility / risk notes

- `StrategyBindings` 可能仍作为 historical / compatibility source path 存在；本 Project 的目标是把 forward-looking canonical binding 语义收口到 `Trader/Coordination`。
- `OrderBookImbalance` 可能仍出现在历史 audit、migration source 或 superseded docs 中；本 Project 后续执行应区分 historical evidence 与 active canonical path。
- `Package.swift` 当前仍可能通过 compatibility envelope 编译旧 source roots；本 Project 不授权 target graph split。
- 如果后续执行发现非 EMA source 被 tests 或 docs 依赖，应优先建立 compatibility evidence，再由唯一 executable issue 做小步迁移。

## Final boundary confirmation

本 planning record 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`、Symphony / symphony-issue 或 Graphify，不修改 Figma，不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
