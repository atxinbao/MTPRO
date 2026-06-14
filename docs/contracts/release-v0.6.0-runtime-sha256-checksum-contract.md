# MTPRO Release v0.6.0 Runtime sha256 Checksum Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-758 V060-004 Migrate RuntimeMessageBus checksum to sha256`。

## V060-004-RUNTIME-EVENT-SHA256-CHECKSUM

`V060-004-RUNTIME-EVENT-SHA256-CHECKSUM`

`RuntimeEventEnvelope.checksum` 必须输出 `sha256:` audit hash。checksum input 继续覆盖 eventID、runID、sequence、streamID、correlationID、causationID、sourceModule、payloadType、payload 和 recordedAt。

sha256 只作为本地 audit evidence，不是 cryptographic signing、remote attestation、production trust 或 cutover authorization。

## V060-004-JOURNAL-SHA256-CHAIN

`V060-004-JOURNAL-SHA256-CHAIN`

`ReleaseV050DurableLocalRunJournalRecord` 必须新增 `previousJournalSHA256` 和 `journalSHA256`，并由 `ReleaseV050DurableLocalRunJournal` 在 append / validation 时按单一 runID 串联校验。`ReleaseV050RunJournalProjection.latestJournalSHA256` 和 `ReleaseV050RunJournalSummary.sha256JournalChainAvailable` 暴露后续 observer 可消费的本地 evidence。

## V060-004-FNV-COMPATIBILITY-EVIDENCE

`V060-004-FNV-COMPATIBILITY-EVIDENCE`

现有 `previousJournalChecksum` / `journalChecksum` FNV evidence 在 v0.6.0 期间保留，用于兼容 v0.5.0 projection / summary / historical tests。新的 sha256 链是并行 audit chain，不删除 legacy FNV 字段。

## V060-004-CHECKSUM-MISMATCH-FAILS-VALIDATION

`V060-004-CHECKSUM-MISMATCH-FAILS-VALIDATION`

Runtime envelope 如果传入非 matching checksum 必须 fail closed。Run journal record 如果传入错误 `journalSHA256` 必须 fail closed。Run journal validation 如果 `previousJournalSHA256` chain 不连续，必须 fail closed。

## V060-004-NO-PRODUCTION-AUTHORIZATION

`V060-004-NO-PRODUCTION-AUTHORIZATION`

sha256 checksum 不授权 production trading，不读取 production secret，不连接 production endpoint / broker，不提交真实订单，不授权 production cutover。

## TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM

`TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM`

验证入口：

- `swift test --filter TargetGraphTests/testGH758RuntimeMessageBusAndRunJournalUseSHA256AuditChecksums`
- `bash checks/verify-v0.6.0-runtime-sha256-checksum.sh`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

GH-758 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不连接 production endpoint，不读取 production secret，不调用 broker，不提交真实订单，不授权 production cutover。
