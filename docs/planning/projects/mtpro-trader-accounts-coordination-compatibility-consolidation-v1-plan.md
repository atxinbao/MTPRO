# MTPRO Trader Accounts / Coordination Compatibility Consolidation v1 Plan

执行者：Codex

日期：2026-06-03

类型：docs-only planning record / non-executable

## 文档定位

本文件只保存 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 的 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

后续如写入 Linear，完整 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以 Linear issue body 为准。

## Project name

`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1`

## Target maturity

`Trader container compatibility consolidation before L4`

## Target Engines / Modules

- `Trader`
- `Trader/Accounts`
- `Trader/Strategies/EMA`
- `Trader/Coordination`
- `Trader/Coordination/RiskBinding`
- `Portfolio` boundary
- `RiskEngine` boundary
- `ExecutionEngine` boundary
- `ExecutionClient` future gate
- `Package.swift` compatibility envelope
- Validation / Automation readiness layer

## Project goal

固定 `Trader = Accounts + Strategies/EMA + Coordination` 的当前权威口径，新增 `Sources/Trader/Accounts` account context boundary，收口旧 `StrategyBindings` wording 和旧 `Sources/Strategies` compatibility excludes，保持 EMA-only active strategy、RiskBinding coordination boundary、no runtime / no live / no broker / no L4 implementation。

## Target layout

```text
Sources/Trader/
  Accounts/
  Strategies/
    EMA/
  Coordination/
    RiskBinding/
```

规则：

- `Trader` 是 account context、active EMA strategy definition 和 coordination 的容器。
- `Trader/Accounts` 只表达 account identity、source identity 和 future real account gate。
- `Trader/Strategies/EMA` 是当前唯一 active concrete strategy path。
- `Trader/Coordination/RiskBinding` 是 binding / coordination boundary，不是 execution gateway。
- `StrategyBindings` 不再作为 active source path 或 Trader 下一级策略目录。
- `Sources/Strategies` 不再作为 active source path；旧引用只能是 historical / compatibility / superseded evidence。
- Account context 不拥有 cash、positions、PnL、margin、leverage，不读取 broker / account payload。

## Scope

- 定义 Trader Accounts / Coordination compatibility contract。
- 新增 `Sources/Trader/Accounts` account context boundary。
- Account context 只表达 account identity / source identity / future real account gate。
- 将 account context evidence 接入 tests / validation anchors。
- 清理 root docs 中剩余 active `StrategyBindings` wording。
- 清理 `Package.swift` 中 stale `Sources/Strategies` compatibility excludes。
- 增加 Trader container completeness validation。
- 收口 validation matrix、compatibility envelope 和 stage audit input material。

## Non-goals

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不实现 Trader runtime。
- 不实现 Strategy runtime。
- 不实现 Live runtime。
- 不读取真实账户。
- 不接 signed endpoint。
- 不接 account endpoint / listenKey。
- 不实现 private WebSocket runtime。
- 不实现 `ExecutionClient` implementation。
- 不实现 OMS。
- 不实现 broker gateway。
- 不实现 real order lifecycle。
- 不实现 submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation。
- 不拥有 cash、positions、PnL、margin、leverage。
- 不读取 broker/account payload。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不拆 SwiftPM target graph。
- 不推进 L4。

## Milestones

| Milestone | 目标 |
| --- | --- |
| M1 Contract | 固定 `Trader = Accounts + Strategies/EMA + Coordination` compatibility contract 和 forbidden capability taxonomy。 |
| M2 Accounts Boundary | 新增 `Trader/Accounts` account context boundary，并接入 deterministic validation evidence。 |
| M3 Docs / Package Compatibility Cleanup | 收口 active `StrategyBindings` wording，清理 stale `Sources/Strategies` compatibility excludes。 |
| M4 Trader Container Validation | 增加 Trader container completeness validation，验证 Accounts / EMA / Coordination 三件套完整。 |
| M5 Closeout | 准备 validation matrix、compatibility envelope 和 stage audit input material。 |

## Suggested issue order

1. Define Trader Accounts / Coordination compatibility contract
2. Add `Sources/Trader/Accounts` account context boundary
3. Wire Trader account context evidence into tests / validation anchors
4. Retire remaining active `StrategyBindings` wording from root docs
5. Clean `Package.swift` stale `Strategies` compatibility excludes
6. Add validation for Trader container completeness
7. Close validation matrix / compatibility envelope / stage audit input

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 2
- Issue 4 blocked by Issue 1
- Issue 5 blocked by Issue 4
- Issue 6 blocked by Issue 2, Issue 3, Issue 4, Issue 5
- Issue 7 blocked by Issue 6

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| Issue 1 | 定义 Trader Accounts / Coordination compatibility contract，固定 account context、EMA-only strategy、RiskBinding coordination 和 forbidden path taxonomy。 | Docs / contract only；不新增 source，不修改 `Package.swift`。 |
| Issue 2 | 新增 `Sources/Trader/Accounts` account context boundary，表达 account identity、source identity 和 future real account gate。 | 不读取真实账户，不拥有 cash / positions / PnL / margin / leverage。 |
| Issue 3 | 将 Trader account context evidence 接入 tests / validation anchors。 | deterministic local evidence only；不实现 Trader runtime 或 account runtime。 |
| Issue 4 | 清理 root docs 中剩余 active `StrategyBindings` wording。 | 旧引用只能保留为 historical / compatibility / superseded evidence。 |
| Issue 5 | 清理 `Package.swift` 中 stale `Sources/Strategies` compatibility excludes。 | 不拆 SwiftPM target graph，不新增 target / product / dependency。 |
| Issue 6 | 增加 Trader container completeness validation，验证 Accounts / Strategies/EMA / Coordination/RiskBinding 的 canonical source layout。 | 不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS 或 broker gateway。 |
| Issue 7 | 收口 validation matrix、compatibility envelope 和 stage audit input material。 | 只准备 stage audit input；最终 Stage Code Audit 由 Parent Codex 单独输出。 |

## Validation requirements

- 每个 issue 必须运行 `bash checks/run.sh`。
- 必须验证 `Sources/Trader/Accounts/` exists。
- 必须验证 `Sources/Trader/Strategies/EMA/` is only active strategy。
- 必须验证 `Sources/Trader/Coordination/RiskBinding/` is binding location。
- 必须验证 no active `Sources/Trader/StrategyBindings`。
- 必须验证 no active `Sources/Strategies`。
- 必须验证 account context 不拥有 cash、positions、PnL、margin、leverage。
- 必须验证 account context 不读取 broker/account payload。
- 必须验证 no signed endpoint / account endpoint / listenKey。
- 必须验证 no `ExecutionClient` / OMS / broker gateway。
- 必须验证 no SwiftPM target graph split。
- 必须验证 no L4 implementation。

## Evidence requirements

- 每个 PR 必须包含 Linked Linear Issue。
- 每个 PR 必须包含 Scope / Non-goals。
- 每个 PR 必须包含 validation output。
- 每个 PR 必须包含 boundary evidence。
- 每个 PR 必须包含 changed paths summary。
- 每个 PR 必须说明 no Trader runtime。
- 每个 PR 必须说明 no real account read。
- 每个 PR 必须说明 no `ExecutionClient` / OMS / broker gateway。
- 每个 PR 必须说明 no SwiftPM target graph split。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- Issue 7 只准备 stage audit input material，不输出最终 Stage Code Audit Report。
- Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define Trader Accounts / Coordination compatibility contract`

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

- 当前 `Sources/Trader/Accounts/` 尚未作为 production source boundary 落地；本 planning record 只规划后续唯一 executable issue 的执行路径。
- 当前 `Sources/Trader/Strategies/EMA/` 是唯一 active concrete strategy path；非 EMA strategy 不能回流为 active source / tests / `Package.swift` path。
- 旧 `StrategyBindings` wording 如果仍存在，应在后续 issue 中改为 historical / compatibility / superseded，或收口为 `Trader/Coordination` binding / adapter 语义。
- `Package.swift` 中 stale `Sources/Strategies` compatibility excludes 是后续 Issue 5 的 cleanup 对象；本 planning record 不修改 `Package.swift`。
- SwiftPM target graph split 仍为 future gated；本 Project 只清理 compatibility envelope，不新增 target。

## Final boundary confirmation

本 planning record 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`、Symphony / symphony-issue 或 Graphify，不修改 Figma，不新增或移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
