# Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening Contract

日期：2026-06-27

执行者：Codex

本文档服务 GitHub fallback issue `GH-1139 V170-001 Define operator beta runtime hardening contract`。

本文档定义 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 的第一层 release boundary、queue preflight、artifact / status runtime hardening scope、validation anchors 和 forbidden production capabilities。GH-1139 只定义合同，不实现 artifact ingest、status retry、resume、reconciliation、Dashboard / CLI hardening runtime，不读取 credential value，不连接 testnet 或 production endpoint，不发送 testnet 或 production order，不授权 production cutover。

## V0170-001-V0161-PREFLIGHT-GATE

`V0170-001-V0161-PREFLIGHT-GATE`

GH-1139 必须在 v0.16.1 evidence hardening patch queue 完成后才可执行。前置事实：

- Blocking issue：`GH-1138`
- Required prior state：`GH-1138 closed / done`
- Required prior patch line：`release/v0.16.1 queue closed`
- Required Parent Codex state：open PR = 0，open `todo` / `in-progress` / `in-review` issue = 0
- Required root state：`main == origin/main` 且 worktree clean

## V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE

`V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE`

v0.17.0 的 scope 是 operator beta artifact + status runtime hardening，不是新交易能力发布。后续 issue 只能在以下范围内推进：

- artifact bundle ingest / replay validator
- signed status query retry / timeout / classified failure model
- operator run resume from artifact store
- cancel / status reconciliation recovery path
- Dashboard artifact validation error surface
- CLI artifact verify command
- manual workflow artifact upload / download validation
- beta safety policy profile evidence
- stage audit and release docs closeout

GH-1139 本身只定义上述 scope，不实现这些 runtime。

## V0170-001-BINANCE-SPOT-TESTNET-ONLY

`V0170-001-BINANCE-SPOT-TESTNET-ONLY`

v0.17.0 operator beta hardening 的 active venue 和 product scope 固定为：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot]`
- `canonicalQueueRange == GH-1139..GH-1148`

任何非 Binance venue、Spot 之外 product type、production endpoint、production broker endpoint、production OMS 或 production order path 都不属于 v0.17.0 scope。

## V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED

`V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED`

v0.17.0 的 artifact / status evidence 必须默认脱敏。API key、secret、listenKey、signature、raw request payload、raw response payload、raw broker payload、raw order identity 和 production endpoint marker 不得进入文档、test fixture、Dashboard surface、CLI output 或持久 artifact。

后续 issue 如果处理真实 operator artifact，只能记录 redacted credential reference、run id、artifact path、checksum、classification、operator confirmation metadata 和 replay validation result。

## V0170-001-QUEUE-ORDER

`V0170-001-QUEUE-ORDER`

Canonical queue order：

1. `GH-1139` Define operator beta runtime hardening contract
2. `#1140 / GH-1140` Add real artifact bundle ingest / replay validator
3. `#1141 / GH-1141` Add signed status query retry / timeout / classified failure model
4. `#1142 / GH-1142` Add operator run resume from artifact store
5. `#1143 / GH-1143` Add cancel/status reconciliation recovery path
6. `#1144 / GH-1144` Add Dashboard artifact validation error surface
7. `#1145 / GH-1145` Add CLI artifact verify command
8. `#1146 / GH-1146` Add manual workflow artifact upload/download validation
9. `#1147 / GH-1147` Add beta safety policy profile evidence
10. `#1148 / GH-1148` Close v0.17.0 stage audit and release docs

Each issue remains `backlog` / `non-executable` until Parent Codex queue preflight promotes it. WIP=1 remains mandatory.

## V0170-001-NO-PRODUCTION-CUTOVER

`V0170-001-NO-PRODUCTION-CUTOVER`

GH-1139 keeps these flags closed:

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`
- `createsTagOrRelease=false`
- `startsNextMilestone=false`

Forbidden capabilities：

- production cutover authorization
- production trading enabled by default
- production secret read
- production endpoint connection
- production broker connection
- production submit / cancel / replace
- production OMS
- Dashboard trading button
- Dashboard order form
- Live PRO Console command
- non-Binance venue
- non-spot product type
- raw secret persistence
- raw broker payload persistence
- testnet credential value read by GH-1139
- testnet network connection by GH-1139
- testnet order submission by GH-1139
- tag or GitHub Release publication
- next milestone auto-start

## TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT

`TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`

Validation anchors：

- `GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`
- `TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`
- `V0170-001-V0161-PREFLIGHT-GATE`
- `V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE`
- `V0170-001-BINANCE-SPOT-TESTNET-ONLY`
- `V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED`
- `V0170-001-QUEUE-ORDER`
- `V0170-001-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1139ReleaseV0170OperatorBetaRuntimeHardeningContract`
- `bash checks/verify-v0.17.0-operator-beta-runtime-hardening-contract.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1139 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- artifact ingest runtime implementation。
- signed status retry runtime implementation。
- resume / reconciliation runtime implementation。
- Dashboard command surface。
- CLI submit / cancel / replace command。
- testnet credential value read。
- testnet network connection。
- testnet order submission。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production submit / cancel / replace。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
