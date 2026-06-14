# Release v0.6.0 Local Run Journal Writer Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-756 V060-002 Add LocalRunJournalWriter`。

本文档定义 v0.6.0 的真实本地 durable writer。它把 GH-731 / v0.5.0 deterministic `ReleaseV050DurableLocalRunJournal` artifact 写入 `.local/mtpro/runs/<runID>/`，但仍只允许本地 filesystem；不连接 Binance、production endpoint、broker，不读取 secret，不发送真实订单，不授权 production cutover。

## V060-002-LOCAL-RUN-JOURNAL-WRITER

`V060-002-LOCAL-RUN-JOURNAL-WRITER`

权威实现入口：

- `Sources/Database/ReleaseV060LocalRunJournalWriter.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH756LocalRunJournalWriterPersistsArtifactsAndClassifiesIncompleteRuns`
- `checks/verify-v0.6.0-run-journal-writer.sh`

## V060-002-RUN-DIRECTORY-SHAPE

`V060-002-RUN-DIRECTORY-SHAPE`

Writer 必须为唯一 runID 创建：

```text
.local/mtpro/runs/<runID>/
  events.jsonl
  projection.json
  summary.json
  _RUN_STATUS.json
  manifest.json
```

测试可以注入临时 storage root；默认 storage root 仍是 `.local/mtpro/runs`。

## V060-002-APPEND-ONLY-EVENTS-JSONL

`V060-002-APPEND-ONLY-EVENTS-JSONL`

`events.jsonl` 只能 append line-delimited records。completed run 已存在 `manifest.json` 时必须拒绝 rewrite；`events.jsonl` 已包含记录时，completed writer 也必须拒绝覆盖或重写。

## V060-002-ATOMIC-PROJECTION-SUMMARY-STATUS-MANIFEST

`V060-002-ATOMIC-PROJECTION-SUMMARY-STATUS-MANIFEST`

`projection.json`、`summary.json`、`_RUN_STATUS.json` 和 `manifest.json` 必须使用 atomic write。Writer 不把 raw broker payload、secret、production endpoint、signed request 或 real order 信息写入 artifact。

## V060-002-MANIFEST-WRITTEN-LAST

`V060-002-MANIFEST-WRITTEN-LAST`

completed run 的 write order 固定为：

```text
events.jsonl -> projection.json -> summary.json -> _RUN_STATUS.json -> manifest.json
```

`manifest.json` 是 completed run 的最终完成证据。inspect 时如果 manifest 缺失，即使 status 文件存在，也必须把 run 归类为 `incomplete`。

## V060-002-FAILED-INCOMPLETE-NOT-COMPLETED

`V060-002-FAILED-INCOMPLETE-NOT-COMPLETED`

失败或不完整 run 必须写入 / 返回 `_RUN_STATUS.json` shape：

- `state == failed` 或 `state == incomplete`
- `completed == false`
- `manifestPresent == false`
- `productionTradingEnabledByDefault == false`
- `productionSecretResolutionEnabled == false`
- `productionEndpointConnectionEnabled == false`
- `realOrderAuthorizationEnabled == false`
- `productionCutoverAuthorized == false`

## TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER

`TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER`

Required validation：

- `swift test --filter TargetGraphTests/testGH756LocalRunJournalWriterPersistsArtifactsAndClassifiesIncompleteRuns`
- `bash checks/verify-v0.6.0-run-journal-writer.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V060-002 Non-authorization

GH-756 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不读取 secret，不连接 endpoint，不调用 broker，不实现 ExecutionClient production adapter，不实现 production OMS，不提交 / 取消 / 替换真实订单，不授权 production cutover。
