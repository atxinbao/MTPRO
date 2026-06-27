# Release v0.18.0 Status Query Retry Artifact Persistence Contract

日期：2026-06-28

执行者：Codex

本文档服务 GitHub fallback issue `GH-1178 V180-003 Add status-query retry result persistence into artifact store`。

GH-1178 在 GH-1177 的 `{venue, product, environment, accountProfile, runID}` namespace 之后，把 GH-1141 signed status-query retry / timeout / classified failure result 写入 GH-1106 append-only local execution artifact store。该 persistence 只保存 redacted local evidence，不重新触发 status query，不连接 endpoint，不读取 secret，不发送订单，不授权 production cutover。

## V0180-003-DEPENDENCY-GH1177-DONE

`V0180-003-DEPENDENCY-GH1177-DONE`

GH-1178 blocked by `#1177 closed / done`。只有 GH-1177 已完成 run artifact lifecycle manifest namespace，GH-1178 才能把 status-query retry result 绑定到同一 namespace 下的 local artifact store。

## V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED

`V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED`

artifact payload 必须持久化结构化 `statusQueryRetrySnapshot`，覆盖：

- signed status-query result id。
- signed status-query request id。
- final validation status。
- attempt snapshots。
- retry attempts persisted flag。
- local artifact replay flag。

该 snapshot 写入现有 append-only artifact store payload JSON，并进入 checksum manifest / replay chain。

## V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE

`V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`

每个 persisted status-query retry result 必须记录完整 namespace：

- `venue`
- `product`
- `environment`
- `accountProfile`
- `runID`

ExecutionClient 不依赖 Database target，因此 `ReleaseV0180StatusQueryRetryArtifactNamespace` 只保留 GH-1177 同形字段和同一 namespace key 语义。它必须与 GH-1177 lifecycle namespace key 对齐，且 product / environment mismatch 必须 fail closed。

## V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION

`V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION`

失败 status-query result 必须持久化：

- every retry attempt index。
- per-attempt timeout milliseconds。
- timeout failure reason。
- retry limit exceeded reason。
- retry scheduled flag。
- failure field。
- fail-closed status。

该 evidence 只能来自既有 GH-1141 classified failure model，不允许重新连接 broker 或 production endpoint。

## V0180-003-REDACTION-STATUS-PERSISTED

`V0180-003-REDACTION-STATUS-PERSISTED`

payload 必须显式记录 `redactedEvidenceOnly` redaction status。artifact store 必须继续拒绝 credential value、raw order identity、raw broker payload、production endpoint marker 和 production command marker。

## V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE

`V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE`

失败 status-query evidence 必须 operator-visible，并给出下一步动作：

- `operatorVisibleFailureEvidence=true`
- `failedStatusQueryFailClosed=true`
- `operatorNextAction=review-redacted-status-query-failure-before-resume`

operator next-action 只允许指导人工 review / resume，不允许 submit / cancel / replace，不允许 production cutover。

## V0180-003-LOCAL-ARTIFACT-STORE-REPLAY

`V0180-003-LOCAL-ARTIFACT-STORE-REPLAY`

`appendStatusQueryRetryResult` 必须写入 `.status` artifact record。`validateStatusQueryRetryResult` 必须只从 local artifact store replay 最新 status-query retry snapshot，并校验 namespace 完全一致。

Replay 不允许：

- 重新执行 status query。
- 连接 endpoint。
- 读取 credential value。
- 查询 broker。
- 发送 submit / cancel / replace。

## V0180-003-NO-PRODUCTION-CUTOVER

`V0180-003-NO-PRODUCTION-CUTOVER`

GH-1178 keeps these flags closed：

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`

Forbidden capabilities：

- production cutover authorization
- production trading enabled by default
- production secret read
- production endpoint connection
- production broker endpoint connection
- production submit / cancel / replace
- production OMS
- Dashboard trading button
- Dashboard order form
- Live PRO Console command
- status-query endpoint execution
- new venue/product activation
- tag or GitHub Release publication
- next milestone auto-start

production cutover not authorized。

## TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE

`TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`

Validation anchors：

- `GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`
- `TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`
- `V0180-003-DEPENDENCY-GH1177-DONE`
- `V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED`
- `V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`
- `V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION`
- `V0180-003-REDACTION-STATUS-PERSISTED`
- `V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE`
- `V0180-003-LOCAL-ARTIFACT-STORE-REPLAY`
- `V0180-003-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1178StatusQueryRetryResultPersistsNamespaceAndFailureIntoArtifactStore`
- `bash checks/verify-v0.18.0-status-query-retry-artifact-persistence.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1178 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- OKX runtime implementation。
- new venue/product runtime activation。
- status query runtime endpoint implementation。
- resume / reconciliation replay endpoint implementation。
- CLI order command implementation。
- Dashboard command implementation。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production submit / cancel / replace。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
