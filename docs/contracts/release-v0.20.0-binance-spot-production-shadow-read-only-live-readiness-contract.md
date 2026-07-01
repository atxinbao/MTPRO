# Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness Contract

日期：2026-06-30

执行者：Codex

本文档服务 GitHub fallback issue `GH-1239 V0200-001 Define Binance Spot production-shadow / read-only live readiness contract`。

本文档定义 `MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness` 的第一层 release boundary、queue preflight、allowed modes、fail-closed readiness evidence、validation anchors 和 forbidden production capabilities。GH-1239 只定义合同，不实现 public market probe、signed account probe、private stream runtime、credential secret value read、endpoint connection、submit / cancel / replace、Spot canary 或 production cutover。

## V0200-001-V0191-PREFLIGHT-GATE

`V0200-001-V0191-PREFLIGHT-GATE`

GH-1239 必须在 v0.19.1 release fact / stale wording patch queue 完成后才可执行。前置事实：

- Blocking issues：`GH-1232`、`GH-1233`、`GH-1234`、`GH-1235`、`GH-1236`、`GH-1237`
- Required prior state：`GH-1232..GH-1237 closed / done`
- Required prior patch line：`release/v0.19.1 queue closed`
- Required Parent Codex state：open PR = 0，open `todo` / `in-progress` / `in-review` issue = 0
- Required root state：`main == origin/main` 且 worktree clean

## V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW

`V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW`

v0.20.0 的 active venue / product scope 固定为：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot]`
- `canonicalQueueRange == GH-1239..GH-1250`

任何 Binance Spot 之外的 product、Binance USDⓈ-M Futures execution、OKX active implementation、production broker adapter、production OMS、order command path 或 production cutover 都不属于 v0.20.0 scope。

## V0200-001-READ-ONLY-LIVE-READINESS

`V0200-001-READ-ONLY-LIVE-READINESS`

v0.20.0 只能证明 Binance Spot production-shadow / read-only live readiness。允许后续 issue 在严格 gate 下逐步推进：

- `production-shadow-environment-profile`
- `production-read-only-endpoint-allowlist`
- `credential-reference-readiness`
- `public-market-read-only-probe`
- `signed-account-readiness-probe-contract`
- `account-snapshot-redaction-artifact-policy`
- `no-order-capability-guard`
- `risk-kill-switch-no-trade-readiness-evidence`
- `dashboard-cli-read-only-live-readiness-surface`
- `release-validation-suite`
- `stage-audit-release-docs`

GH-1239 本身只定义上述 scope，不读取 secret、不连接 production endpoint、不实现 signed account endpoint runtime、不实现 private stream runtime、不产生 live account snapshot。

## V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE

`V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE`

v0.20.0 不允许任何 submit / cancel / replace order path。后续 issue 即使引用 Binance Spot production-shadow readiness，也必须保持：

- `orderSubmitCancelReplaceImplementedByThisIssue == false`
- `productionOrderSubmitCancelReplaceEnabled == false`
- `productionTradingEnabledByDefault == false`
- `productionCutoverAuthorized == false`

Dashboard / CLI 只能展示 read-only readiness evidence，不得提供 trading button、order form、live command 或 submit / cancel / replace 操作入口。

## V0200-001-SPOT-CANARY-DEFERRED-TO-V0210

`V0200-001-SPOT-CANARY-DEFERRED-TO-V0210`

Spot controlled canary 最早属于 v0.21.0，不属于 v0.20.0。v0.20.0 的任何 readiness pass、public market probe pass、credential reference pass、signed account readiness pass、Risk / Kill Switch / No-trade pass 或 Dashboard / CLI read-only evidence，都不得被解释为 Spot canary、production order authorization 或 production cutover。

GH-1271 使用 `GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE`、`V0201-003-NOT-LIVE-TRANSPORT-PROOF`、`V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL`、`V0201-003-NO-ENDPOINT-CONNECTION` 和 `V0201-003-NO-PRODUCTION-CUTOVER` 固定该解释边界：public market probe pass 只是 response classification evidence，不是 live transport proof；signed account readiness pass 只是 intent evidence，不是 account access proof 或 account payload retrieval；production cutover not authorized。

## V0200-001-QUEUE-ORDER

`V0200-001-QUEUE-ORDER`

Canonical queue order：

1. `GH-1239` Define Binance Spot production-shadow / read-only live readiness contract
2. `#1240 / GH-1240` Add Binance Spot production-shadow environment profile
3. `#1241 / GH-1241` Harden Binance Spot production endpoint read-only allowlist
4. `#1242 / GH-1242` Add credential reference readiness without secret value read
5. `#1243 / GH-1243` Add Binance Spot production public market read-only probe
6. `#1244 / GH-1244` Add Binance Spot signed account read-only readiness probe contract
7. `#1245 / GH-1245` Add production-shadow account snapshot redaction and artifact policy
8. `#1246 / GH-1246` Add production-shadow no-order capability guard
9. `#1247 / GH-1247` Add production-shadow Risk / Kill Switch / No-trade readiness evidence
10. `#1248 / GH-1248` Add Dashboard / CLI read-only live readiness surface
11. `#1249 / GH-1249` Add verify-v0.20.0 release validation suite
12. `#1250 / GH-1250` Close v0.20.0 stage audit and release docs

Each issue remains `backlog` / `non-executable` until Parent Codex queue preflight promotes it. WIP=1 remains mandatory.

## V0200-001-NO-PRODUCTION-CUTOVER

`V0200-001-NO-PRODUCTION-CUTOVER`

GH-1239 keeps these flags closed:

- `credentialSecretValueReadEnabledByThisIssue=false`
- `productionEndpointConnectionEnabledByThisIssue=false`
- `signedAccountEndpointRuntimeImplementedByThisIssue=false`
- `privateStreamRuntimeImplementedByThisIssue=false`
- `orderSubmitCancelReplaceImplementedByThisIssue=false`
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
- production secret value read
- production endpoint auto-connect
- production broker connection
- order submit / cancel / replace
- Spot canary by v0.20.0
- Futures execution
- OKX active implementation
- signed endpoint runtime by GH-1239
- account endpoint runtime by GH-1239
- private stream runtime by GH-1239
- Dashboard trading button
- Dashboard order form
- live command
- tag or GitHub Release publication
- next milestone auto-start

## TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT

`TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`

Validation anchors：

- `GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`
- `TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`
- `V0200-001-V0191-PREFLIGHT-GATE`
- `V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW`
- `V0200-001-READ-ONLY-LIVE-READINESS`
- `V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE`
- `V0200-001-SPOT-CANARY-DEFERRED-TO-V0210`
- `V0200-001-QUEUE-ORDER`
- `V0200-001-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1239ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract`
- `bash checks/verify-v0.20.0-production-shadow-readiness-contract.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1239 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- public market probe implementation。
- signed account probe implementation。
- credential secret value read。
- production endpoint connection。
- signed account endpoint runtime。
- private stream runtime。
- account snapshot runtime。
- submit / cancel / replace。
- Spot controlled canary。
- Futures execution。
- OKX active implementation。
- Dashboard trading button。
- order form。
- live command。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production order。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
