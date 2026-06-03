# MTPRO Persistence Validation Repair v1 Planning Record

日期：2026-06-03

执行者：Codex

本文档是 `MTPRO Persistence Validation Repair v1` 的 docs-only Project Planning Record。它只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。

本文档不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不授权修复实现。后续完整 issue execution contract 以 Linear issue body 为准。

## Project name

`MTPRO Persistence Validation Repair v1`

## Target maturity

`Validation repair / architecture split prerequisite`

## Target Engines / Modules

- Database / Persistence boundary
- MessageBus event envelope boundary
- Event Log append-only invariant
- Validation / Automation readiness layer

## Project goal

修复当前 `main` 上 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 触发的 `xctest` signal 11，使 `bash checks/run.sh` 恢复通过，为后续 SwiftPM target graph architecture split 建立干净、可信的验证基线。

## Scope

- 诊断 `FileEventLogStore` out-of-order append focused test 崩溃原因。
- 修复 `testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant`。
- 保持 append-only event log invariant。
- 保持 Database / MessageBus / Persistence boundary 不变。
- 保持相邻 focused test `testFileEventLogStoreAppendsAndReplaysStableEnvelopes` 继续通过。
- 恢复 `bash checks/run.sh` 全量通过。
- 输出 crash diagnosis、repair evidence 和 validation baseline。

## Non-goals

- 不拆 SwiftPM target graph。
- 不移动 `Sources` 文件。
- 不修改 architecture module layout。
- 不实现 Trader runtime / Strategy runtime / Live runtime。
- 不实现 ExecutionClient implementation / OMS / broker gateway。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 不推进 L4。
- 不运行 Graphify。
- 不修改 Figma。
- 不把 repair project 扩展成架构迁移 project。

## Known validation blocker

当前已知 blocker：

```text
PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant
-> xctest signal 11
```

该 blocker 是本 Project 的目标修复对象。docs-only planning PR 不要求 `bash checks/run.sh` 通过；如果 GitHub required check `checks` 因同一 blocker 失败，不应解释为 planning record 内容错误。

## Suggested issue order

1. Diagnose PersistenceTests xctest signal 11
2. Repair FileEventLogStore out-of-order append validation crash
3. Close validation baseline / repair evidence

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 2

## Validation requirements

每个 issue 必须按 scope 运行必要 focused validation；收口 issue 必须运行完整验证。

Required focused validation：

- `swift test --filter PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant`
- `swift test --filter PersistenceTests/testFileEventLogStoreAppendsAndReplaysStableEnvelopes`

Required closure validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

必须验证：

- append-only invariant preserved。
- 相邻 append / replay stable envelope test 不回退。
- no architecture layout change。
- no SwiftPM target graph split。
- no runtime / live / broker capability added。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals。
- crash diagnosis 或 repair explanation。
- changed paths summary。
- focused test before / after evidence。
- validation output。
- boundary evidence：
  - append-only invariant preserved。
  - no architecture layout change。
  - no SwiftPM target graph split。
  - no runtime / live / broker capability added。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。

Issue 3 只准备 repair closure / validation baseline evidence，不输出最终 Stage Code Audit Report。

## First executable issue candidate

Issue 1：`Diagnose PersistenceTests xctest signal 11`

该 issue 只是 first executable candidate，不构成执行授权。

## WIP=1 / queue preflight rule

- Project 执行必须保持 WIP=1。
- 所有 issues 初始状态必须是 `Backlog / non-executable`。
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
- 后续 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 以 Linear issue body 为准。

## Candidate issue summaries

### Issue 1：Diagnose PersistenceTests xctest signal 11

目标：定位 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 触发 `xctest` signal 11 的真实原因，形成可复现、可修复的 crash diagnosis。

摘要范围：

- 复现 focused failing test。
- 对比 `testFileEventLogStoreAppendsAndReplaysStableEnvelopes`。
- 审查 `FileEventLogStore`、event envelope、append validation 和 PersistenceTests 的最小相关路径。
- 输出最小 repair plan。

边界：

- 只做诊断，不提交修复。
- 不修改 production code。
- 不改变 append-only invariant。
- 不扩大到 architecture migration。

### Issue 2：Repair FileEventLogStore out-of-order append validation crash

目标：修复 out-of-order append validation crash，使 `FileEventLogStore` 在拒绝乱序 append 时稳定返回预期错误或测试可捕获结果，而不是触发 `xctest` signal 11。

摘要范围：

- 基于 Issue 1 diagnosis 做最小修复。
- 保持 append-only event log invariant。
- 修复或调整 focused failing test。
- 保持相邻 append / replay stable envelope test 继续通过。
- 如触及 production code，必须补充详细中文注释，说明 append-only invariant、错误边界和禁止破坏 event log 顺序的原因。

边界：

- 不重写 `FileEventLogStore`。
- 不替换 persistence backend。
- 不拆 SwiftPM target graph。
- 不迁移 source layout。
- 不新增 runtime / live / broker capability。

### Issue 3：Close validation baseline / repair evidence

目标：在修复完成后收口验证基线，确认当前 `main` 可恢复到完整 checks 通过状态，并为后续 SwiftPM target graph split 提供干净前置证据。

摘要范围：

- 运行 focused tests。
- 运行 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`。
- 汇总 repair closure evidence。
- 确认没有 architecture layout change、SwiftPM target graph split、runtime / live / broker capability added。

边界：

- 不输出最终 Stage Code Audit Report。
- 不推进下一 Project。
- 不拆 SwiftPM target graph。
- 不移动 source layout。
- 不运行 Graphify。
- 不修改 Figma。

## Final boundary confirmation

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不修复 production code。
- 不修改 Persistence implementation。
- 不修改 `Tests/PersistenceTests` 行为。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime / Strategy runtime / Live runtime。
- 不实现 ExecutionClient implementation / OMS / broker gateway。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 不推进 L4。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
