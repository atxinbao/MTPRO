# MTPRO Release v0.6.0 Run Manifest Checksum Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-757 V060-003 Add run manifest and artifact checksum`。

## V060-003-RUN-MANIFEST-ARTIFACT-CHECKSUM

`V060-003-RUN-MANIFEST-ARTIFACT-CHECKSUM`

`ReleaseV060LocalRunJournalWriter` 必须把 completed run 的 required artifacts 写入 `manifest.json`，并为每个 required artifact 记录本地审计元数据。manifest 仍是 completed run 的最终完成 marker，不授权 production trading、production endpoint、secret resolution、broker command 或真实订单。

## V060-003-REQUIRED-ARTIFACT-METADATA

`V060-003-REQUIRED-ARTIFACT-METADATA`

每个 required artifact metadata 必须包含：

- `path`
- `schemaVersion`
- `sha256`
- `bytes`
- `createdAt`
- `required == true`

当前 required artifact 顺序固定为：

```text
events.jsonl
projection.json
summary.json
_RUN_STATUS.json
```

`manifest.json` 记录这些 artifact 的 metadata，并通过 `writeOrder` 保持自己最后写入。

## V060-003-SHA256-BYTECOUNT-VALIDATION

`V060-003-SHA256-BYTECOUNT-VALIDATION`

`validateRunManifest(runID:)` 必须重新读取 manifest 中的 required artifacts，逐项校验：

- file exists
- actual byte count equals `bytes`
- actual sha256 equals `sha256`

sha256 是本地 audit hash，不是远程签名、production attestation 或 cutover authorization。

## V060-003-MISSING-CORRUPTED-ARTIFACT-REJECTION

`V060-003-MISSING-CORRUPTED-ARTIFACT-REJECTION`

missing artifact 必须 validation failure。相同 byte count 的内容损坏必须 checksum failure。byte count 漂移必须 byte-count failure。validator 不得静默降级为 completed。

## V060-003-MANIFEST-FINAL-COMPLETION-MARKER

`V060-003-MANIFEST-FINAL-COMPLETION-MARKER`

`manifest.json` 仍是 completed run final marker。它不为自己记录 self-checksum，避免自引用 checksum 不稳定；它只记录 completed marker 之前已经落盘的 required artifacts。manifest 缺失时，`inspectRun` 必须继续把 run 视为 incomplete。

## TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM

`TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM`

验证入口：

- `swift test --filter TargetGraphTests/testGH757RunManifestRecordsSha256BytesAndRejectsCorruptedArtifacts`
- `bash checks/verify-v0.6.0-run-manifest-checksum.sh`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

GH-757 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不连接 production endpoint，不读取 production secret，不调用 broker，不提交真实订单，不授权 production cutover。
