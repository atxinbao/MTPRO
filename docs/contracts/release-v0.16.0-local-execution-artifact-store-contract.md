# Release v0.16.0 Local Execution Artifact Store Contract

日期：2026-06-25

执行者：Codex

本文档固定 #1106 / GH-1106 的本地 execution artifact store 合同。它服务 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta`，只授权本地 redacted evidence 持久化、校验、回放和导出，不授权 production cutover。

## Scope

#1106 / GH-1106 增加 `ReleaseV0160LocalExecutionArtifactStore`。该 store 将 submit、cancel、status 和 reconciliation evidence 写入 `.local/mtpro/v0.16.0/operator-runs/<runID>/` 下的 append-only JSONL 事件链，并为每个 payload、record 和 run manifest 写入 deterministic checksum。

固定验证锚点：

- `GH-1106-VERIFY-V0160-LOCAL-EXECUTION-ARTIFACT-STORE`
- `TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE`
- `V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE`
- `V0160-006-CHECKSUM-MANIFEST`
- `V0160-006-CHECKSUM-MISMATCH-REJECTED`
- `V0160-006-REPLAY-VALIDATION`
- `V0160-006-REDACTED-EXPORT-BUNDLE`
- `V0160-006-NO-PRODUCTION-CUTOVER`

## Contract

- `V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE`：store 必须只追加 `action-events.jsonl`，payload 文件路径必须稳定且不可覆盖；重复 payload path 必须 fail closed。
- `V0160-006-CHECKSUM-MANIFEST`：每个 run 必须写入 `run-manifest.json`，记录 record count、record checksum chain、latest checksum、artifact kinds 和 manifest checksum。
- `V0160-006-CHECKSUM-MISMATCH-REJECTED`：payload、record 或 manifest 被篡改时，validate / replay / export 必须拒绝继续。
- `V0160-006-REPLAY-VALIDATION`：replay 必须先执行 checksum chain validation，再返回 submit / cancel / status / reconciliation 的 redacted record 序列。
- `V0160-006-REDACTED-EXPORT-BUNDLE`：export bundle 只能包含 redacted evidence reference、checksum、relative path 和 validation anchors，不能包含 raw credential、raw order identity 或 raw broker payload。
- `V0160-006-NO-PRODUCTION-CUTOVER`：本 issue 不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不授权 production cutover。

## Non-goals

- 不实现新的 CLI command。
- 不执行 testnet 或 production network action。
- 不读取、保存或导出 API key、secret、listenKey、signature、raw order identity 或 raw broker payload。
- 不实现 Dashboard command surface、trading button、order form、production OMS 或 production cutover。

## Validation

必须通过：

- `swift test --filter TargetGraphTests/testGH1106ReleaseV0160LocalExecutionArtifactStorePersistsValidatesReplaysAndExports`
- `bash checks/verify-v0.16.0-local-execution-artifact-store.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-1106 只提供本地 artifact persistence / validation / replay / redacted export。它可以承接 #1103 submit、#1104 cancel、#1105 status query 和后续 reconciliation evidence，但只持久化 redacted local evidence。任何 production endpoint、production credential、broker endpoint、real order submit / cancel / replace 或 production cutover authorization 都必须继续 fail closed。
