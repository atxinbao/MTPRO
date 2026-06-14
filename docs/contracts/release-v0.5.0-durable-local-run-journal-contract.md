# Release v0.5.0 Durable Local Run Journal Contract

日期：2026-06-14
执行者：Codex

本文档服务 GitHub fallback issue `GH-731 V050-06 Durable local run journal`。

GH-731 把 GH-730 typed runtime MessageBus envelope 固化为本地 durable run artifact 合同。该合同实现 `.local/mtpro/runs/<runID>/events.jsonl`、`projection.json` 和 `summary.json` 的 deterministic shape、append-only semantics 和 replay cursor；只写本地 rehearsal evidence，不连接 broker，不读取 secret，不连接 testnet / production endpoint，不发送真实订单，不授权 production cutover。

## Scope

`V050-06-DURABLE-LOCAL-RUN-JOURNAL`

当前 scope 只包含：

- `Sources/Database/ReleaseV050DurableLocalRunJournal.swift`
- `ReleaseV050LocalRunJournalPath`
- `ReleaseV050DurableLocalRunJournalRecord`
- `ReleaseV050RunJournalReplayCursor`
- `ReleaseV050RunJournalProjection`
- `ReleaseV050RunJournalSummary`
- `ReleaseV050DurableLocalRunJournalArtifact`
- `ReleaseV050DurableLocalRunJournal`
- `ReleaseV050DurableLocalRunJournalContract`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH731DurableLocalRunJournalPersistsTypedEnvelopeShapeAndReplaysOneRun`
- `checks/verify-v0.5.0-run-journal.sh`

## Required Evidence

- `V050-06-LOCAL-RUN-STORAGE-SHAPE`：run artifact 路径必须固定为 `.local/mtpro/runs/<runID>/events.jsonl`、`.local/mtpro/runs/<runID>/projection.json` 和 `.local/mtpro/runs/<runID>/summary.json`，并以 deterministic artifact 字符串表达同一结构。
- `V050-06-APPEND-ONLY-REPLAY-CURSOR`：journal 必须按单一 runID 追加，journal sequence 和 envelope sequence 必须连续，previous checksum 必须串联，replay cursor 必须能重建同一 run chain。
- `V050-06-TYPED-RUNTIME-ENVELOPE-PRESERVATION`：JSONL record 必须保留 GH-730 `RuntimeEventEnvelope` 的 eventID、runID、sequence、streamID、correlationID、causationID、sourceModule、payloadType、payload、recordedAt 和 checksum。
- `V050-06-NO-SECRET-ENDPOINT-LEAKAGE`：journal artifact 必须拒绝 secret、endpoint、listenKey、signature、HMAC 或 broker payload fragment。
- `TVM-RELEASE-V050-DURABLE-LOCAL-RUN-JOURNAL`：trading validation matrix anchor。

## Boundary

GH-731 的 local journal 是 rehearsal evidence，不是 production account truth，不是 broker execution source，不是 Event Store production runtime，也不是 operator cutover authorization。它不读取生产 secret，不连接生产 endpoint，不连接 broker，不提交、取消或替换真实订单，不暴露 Live PRO Console command，不推进 v0.5.0 之后的阶段。

## Validation

- `swift test --filter TargetGraphTests/testGH731DurableLocalRunJournalPersistsTypedEnvelopeShapeAndReplaysOneRun`
- `bash checks/verify-v0.5.0-run-journal.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
