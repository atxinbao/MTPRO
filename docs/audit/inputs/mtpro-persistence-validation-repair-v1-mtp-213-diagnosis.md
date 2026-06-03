# MTPRO Persistence Validation Repair v1 MTP-213 崩溃诊断

日期：2026-06-03

执行者：Codex

## 定位

`MTP-213-PERSISTENCE-SIGNAL11-DIAGNOSIS`

本文档是 `MTP-213 Diagnose PersistenceTests xctest signal 11` 的诊断证据。它只记录当前 clean `origin/main` 上的 focused validation、Persistence code path 和最小 repair plan，不提交 production repair、不修改 tests、不改变 append-only invariant。

## Linear / repo context 上下文

`MTP-213-CURRENT-MAIN-NON-REPRO-CONTEXT`

- Linear Project：`MTPRO Persistence Validation Repair v1`。
- 当前 issue：`MTP-213`。
- worktree：`/Users/mac/code/mtpro-host-worktrees/MTP-213`。
- branch：`codex/mtp-213-persistence-crash-diagnosis`。
- base：`origin/main` `ed11ec60969cc2311aae39eb8aa8e576494c0918`。
- planning record：`docs/planning/projects/mtpro-persistence-validation-repair-v1-plan.md` 记录的 known blocker 是 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant -> xctest signal 11`。
- 当前复现结论：在 `ed11ec60969cc2311aae39eb8aa8e576494c0918` 上未复现 signal 11；focused failing test、相邻 focused test 和 `PersistenceTests` suite 均通过；readiness 固定证据短语为 `not reproducible on current`。

## Focused validation output 输出

`MTP-213-FOCUSED-VALIDATION-EVIDENCE`

| Command | Result | Evidence |
| --- | --- | --- |
| `swift test --filter PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` | passed | 1 selected test、0 failures、未出现 signal 11。 |
| `swift test --filter PersistenceTests/testFileEventLogStoreAppendsAndReplaysStableEnvelopes` | passed | 1 selected test、0 failures。 |
| `swift test --filter PersistenceTests` | passed | 16 selected tests、0 failures、未出现 signal 11。 |

## Code path diagnosis 代码路径诊断

`MTP-213-FILEEVENTLOGSTORE-CODE-PATH-DIAGNOSIS`

乱序 append 测试通过 `makeTemporaryFileEventLogStore()` 在 `FileManager.default.temporaryDirectory` 下创建 UUID 隔离路径的 JSONL 文件。测试先 append sequence 1，再尝试 append sequence 3：

- `Tests/PersistenceTests/PersistenceTests.swift` 先调用 `try store.append(envelopes[0])`。
- 随后测试把 `try store.append(envelopes[2])` 包在 `XCTAssertThrowsError` 中。
- `FileEventLogStore.append(_:)` 通过 `readEnvelopes()` 读取已存在 envelopes。
- `readEnvelopes()` 解码每一行 JSONL，并通过 `AppendOnlyEventLog(envelopes:)` 重新校验 sequence continuity。
- `append(_:)` 检查 `envelope.sequence == existingEnvelopes.count + 1`。
- 当现有 count 为 1、传入 sequence 为 3 时，该 guard 抛出 `CoreError.invalidSequenceRange`。
- 失败分支不会打开文件写入，因此既有 `events.jsonl` 内容仍只包含 sequence 1。
- 测试随后确认 `readEnvelopes()` 返回 `[envelopes[0]]`。

`MTP-213-APPEND-ONLY-INVARIANT-PRESERVED`

当前代码通过两层校验维护 append-only invariant：

- `FileEventLogStore.append(_:)` 在写入前拒绝 non-contiguous incoming sequence。
- `AppendOnlyEventLog(envelopes:)` 在 read / replay 时拒绝 non-contiguous persisted file contents。

该测试分支只经过 Swift / Foundation file I/O，不跨越 SQLite、DuckDB、C interop、concurrency、actor isolation、broker、live runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime 或 order execution 边界。

## Diagnosis conclusion 诊断结论

`MTP-213-DIAGNOSIS-CONCLUSION`

planning record 记录的 `xctest signal 11` 在当前 `origin/main` `ed11ec60969cc2311aae39eb8aa8e576494c0918` 上未复现。因此，当前失败假设更像是 stale 或 environment-specific 现象，而不是 `FileEventLogStore.append(_:)` 中仍然存在的 active deterministic crash。

当前最可能的状态是：

- 实际 crash 在 MTP-213 执行前已被修复或已不再可复现；或
- 早先的 signal 11 来自其他 full-suite / runner / environment interaction，并被误归因到这个 focused test；或
- 早先失败来自 clean MTP-213 worktree 外的 stale build artifacts。

`MTP-213-MINIMAL-REPAIR-PLAN`

No production repair is justified by current evidence。除非后续用新的 command output 再次复现 crash，MTP-214 不应修改 `FileEventLogStore`、`PersistenceTests`、`Package.swift`、source layout 或 architecture boundaries。

如果 MTP-214 仍为 queue hygiene 执行，最小有界动作应转为 verification-only closure evidence：

- 在 current main 上重新运行两个 focused tests；
- 重新运行 `swift test --filter PersistenceTests`；
- 如果全部通过，记录 "no active repair required"；
- 不弱化 append-only validation，不改变 production / test behavior。

## Boundary evidence 边界证据

`MTP-213-NO-REPAIR-BOUNDARY`

本 issue 未执行以下行为：

- 修改 production code；
- 修改 `Tests/PersistenceTests` 行为；
- 修改 `FileEventLogStore`；
- 修改 `AppendOnlyEventLog`；
- 修改 `Package.swift`；
- 移动 source paths；
- 拆分 SwiftPM target graph；
- 运行 Graphify、code-index、Figma、Symphony 或 symphony-issue；
- 实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## Next gate 后续 gate

`MTP-213-NEXT-GATE`

MTP-214 在 MTP-213 具备 PR / check / merge / main fast-forward / Linear Done / post-issue ledger evidence 前保持 blocked。随后 Parent Codex queue preflight 必须判断 MTP-214 是否仍是唯一 eligible next issue，并基于当前 non-repro diagnosis 判断其 repair scope 是否仍应执行。
