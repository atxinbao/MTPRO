# MTPRO Persistence Validation Repair v1 MTP-214 修复证据

日期：2026-06-03

执行者：Codex

## 定位

`MTP-214-VERIFICATION-ONLY-REPAIR-EVIDENCE`

本文档是 `MTP-214 Repair FileEventLogStore out-of-order append validation crash` 的 issue evidence。MTP-213 已确认 planning record 中的 `xctest signal 11` 在当前 clean `origin/main` 上未复现，因此 MTP-214 不提交 production repair，不修改 test behavior，只用 verification-only closeout 证明当前 `FileEventLogStore` 错误路径稳定且 append-only invariant 仍被保留。

## Linear / repo context 上下文

`MTP-214-CURRENT-MAIN-REPAIR-CONTEXT`

- Linear Project：`MTPRO Persistence Validation Repair v1`。
- 当前 issue：`MTP-214`。
- worktree：`/Users/mac/code/mtpro-host-worktrees/MTP-214`。
- branch：`codex/mtp-214-persistence-repair-evidence`。
- base：`origin/main` `578bdac7142c05f5dc639f0fd88a7853ecf5732d`。
- 上游 evidence：`docs/audit/inputs/mtpro-persistence-validation-repair-v1-mtp-213-diagnosis.md`。
- 当前修复结论：`no active repair required`。MTP-214 没有新的 crash reproduction output，因此不应修改 `FileEventLogStore`、`PersistenceTests`、`Package.swift`、source layout 或 architecture boundaries。

## Focused validation output 输出

`MTP-214-FOCUSED-VALIDATION-EVIDENCE`

| Command | Result | Evidence |
| --- | --- | --- |
| `swift test --filter PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` | passed | 1 selected test、0 failures、未出现 signal 11。 |
| `swift test --filter PersistenceTests/testFileEventLogStoreAppendsAndReplaysStableEnvelopes` | passed | 1 selected test、0 failures。 |

## 修复结论

`MTP-214-NO-ACTIVE-REPAIR-REQUIRED`

MTP-214 issue title 使用 `Repair`，但当前可验证事实不支持对 production code 或 tests 做修复：

- MTP-213 已在 clean `origin/main` 上确认 signal 11 不可复现。
- MTP-214 在基于 PR #347 的 `origin/main` `578bdac7142c05f5dc639f0fd88a7853ecf5732d` 上重新运行两个必需 focused tests，均通过。
- 乱序 append test 仍通过 `XCTAssertThrowsError` 捕获 `CoreError.invalidSequenceRange`，没有 crash，也没有写入乱序 event。
- 相邻 append / replay stable envelope test 继续通过，说明正常 append / replay 路径未被破坏。

`MTP-214-APPEND-ONLY-INVARIANT-REPAIR-CONCLUSION`

append-only invariant 当前保持有效：

- `FileEventLogStore.append(_:)` 在写入前校验 incoming sequence 必须等于 `existingEnvelopes.count + 1`。
- 乱序 sequence 被拒绝时不会打开文件写入，既有 JSONL 内容不被污染。
- `AppendOnlyEventLog(envelopes:)` 在 replay / read path 继续校验 persisted sequence continuity。

因此，本 issue 的最小安全修复动作是记录 no-op repair evidence，而不是引入没有 reproduction 支撑的代码变更。

## Boundary evidence 边界证据

`MTP-214-NO-CODE-CHANGE-BOUNDARY`

本 issue 未执行以下行为：

- 修改 production code；
- 修改 `Tests/PersistenceTests` 行为；
- 修改 `FileEventLogStore`；
- 修改 `AppendOnlyEventLog`；
- 修改 `Package.swift`；
- 移动 source paths；
- 拆分 SwiftPM target graph；
- 修改 architecture module layout；
- 运行 Graphify、code-index、Figma、Symphony 或 symphony-issue；
- 实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## Next gate 后续 gate

`MTP-214-NEXT-GATE`

MTP-215 在 MTP-214 具备 PR / check / merge / main fast-forward / Linear Done / post-issue ledger evidence 前保持 blocked。随后 Parent Codex queue preflight 必须确认 MTP-215 是唯一 eligible next issue，且只能进入 validation baseline / repair evidence closeout，不得把当前 no-op repair evidence 扩展成 runtime、live、broker 或 architecture implementation。
