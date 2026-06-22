# Release v0.15.0 Network Execution Event Log Contract

日期：2026-06-22

执行者：Codex

## Anchors

- `GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`
- `TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG`
- `V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG`
- `V0150-006-REQUEST-RESPONSE-IDENTITY`
- `V0150-006-CHECKSUM-CHAIN`
- `V0150-006-RAW-SECRET-NOT-PERSISTED`
- `V0150-006-NO-PRODUCTION-CUTOVER`

## Goal

#1071 固定 v0.15.0 Binance Spot Testnet network action 的 append-only evidence contract。它把 #1068 submit runtime 产生的 signed request identity、transport response identity、HTTP 状态、生命周期状态和 checksum chain 写入 replay-friendly artifact。

## Scope

- 新增 `ReleaseV0150BinanceSpotTestnetNetworkExecutionActionKind`。
- 新增 `ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact`。
- 新增 `ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog`。
- 当前 issue 只从 #1068 `ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence` 生成 submit event。
- `cancel` 和 `cancelReplace` 只作为后续 #1069 / #1070 的 event kind 预留，不实现 cancel transport。
- 每个 artifact 必须包含 request identity、response identity、sequence number、previous checksum、artifact checksum 和 redaction flags。

## Contract Fields

- `appendOnlyNetworkExecutionEventLog=true`
- `redactedRequestIdentity=true`
- `redactedResponseIdentity=true`
- `checksumChainVerified=true`
- `rawSecretPersisted=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## Acceptance

- `ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.fromSubmitRuntimeEvidence(...)` 只能接受 boundary-held #1068 submit runtime evidence。
- 第一个 event 的 `previousArtifactChecksum` 必须为空。
- 后续 event 的 `previousArtifactChecksum` 必须等于前一个 event 的 `artifactChecksum`。
- checksum 必须是 deterministic lowercase SHA-256。
- log 必须拒绝空 event list、错误 sequence、错误 previous checksum、错误 artifact checksum、未脱敏 artifact 和 production-enabled flags。
- `String(describing:)` 不能包含 API key、secret、raw request body 或 raw response body。

## Non-goals

- 不实现 Binance cancel runtime。
- 不实现 Binance cancel-replace runtime。
- 不实现 OMS reconciliation。
- 不实现 Dashboard command surface。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 production order。
- 不授权 production cutover。

## Validation

- `swift test --filter TargetGraphTests/testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts`
- `bash checks/verify-v0.15.0-network-execution-event-log.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

`GH-1071` 只记录 Binance Spot Testnet network execution evidence。它不扩大 #1068 submit runtime 的权限，不授权 #1069 cancel runtime、#1070 cancel-replace runtime、production endpoint、broker endpoint、production order 或 production cutover。
