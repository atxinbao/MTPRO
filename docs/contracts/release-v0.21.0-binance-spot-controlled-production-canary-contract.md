# Release v0.21.0 Binance Spot Controlled Production Canary Contract

日期：2026-07-01

执行者：Codex

本文档服务 GitHub fallback issue `GH-1273 V0210-001 Define Binance Spot controlled production canary contract`。

本文档定义 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary` 的第一层 release boundary、queue preflight、allowed modes、Human approval、symbol allowlist、notional / exposure size caps、RiskEngine / kill switch / no-trade gates、validation anchors 和 forbidden production cutover capabilities。GH-1273 只定义合同，不读取 production secret、不连接 production endpoint / broker endpoint、不实现 signed account endpoint runtime、不提交 / 取消订单、不创建 tag / GitHub Release，也不授权 production cutover。

## V0210-001-V0201-PREFLIGHT-GATE

`V0210-001-V0201-PREFLIGHT-GATE`

GH-1273 必须在 v0.20.1 publication fact sync patch queue 完成并发布后才可执行。前置事实：

- Blocking issue：`GH-1272`
- Required prior state：`GH-1272 closed / done`
- Required prior patch line：`release/v0.20.1 queue closed`
- Required Parent Codex state：open PR = 0，open `todo` / `in-progress` / `in-review` issue = 0
- Required root state：`main == origin/main` 且 worktree clean
- Required publication state：`v0.20.1` stable GitHub Release 已发布，且不授权 production cutover

## V0210-001-BINANCE-SPOT-CONTROLLED-CANARY

`V0210-001-BINANCE-SPOT-CONTROLLED-CANARY`

v0.21.0 的 active venue / product scope 固定为：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot]`
- `canonicalQueueRange == GH-1273..GH-1286`

v0.21.0 只允许 Binance Spot controlled production canary。Binance USDⓈ-M Futures、OKX Spot、OKX Swap、unbounded production runtime、production broker adapter、production OMS、default-on trading 或 production cutover 都不属于本 release scope。

## V0210-001-HUMAN-APPROVAL-REQUIRED

`V0210-001-HUMAN-APPROVAL-REQUIRED`

controlled production canary 只能在显式 Human operator approval 之后进入后续 gate。该 approval 必须是可审计 evidence，且不能被环境变量默认值、自动 secret discovery、Dashboard default button、CLI shortcut 或测试 fixture 替代。

GH-1273 本身只固定 `explicitHumanApprovalRequired == true`，不实现 approval workflow runtime；后续 issue 必须继续 fail closed。

## V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS

`V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS`

controlled production canary 必须同时满足：

- symbol allowlist required
- notional size cap required
- exposure cap required
- single-product Binance Spot only
- canary evidence must be auditable

任何无 symbol allowlist、无 notional cap、无 exposure cap、跨 product 复用或绕过 audit evidence 的订单路径都必须 fail closed。

## V0210-001-RISK-KILL-NO-TRADE-GATES

`V0210-001-RISK-KILL-NO-TRADE-GATES`

所有后续 canary submit / cancel / status / reconciliation issue 必须经过：

- RiskEngine pre-trade gate
- global kill switch
- no-trade state gate
- rollback / incident stop gate
- append-only audit evidence

RiskEngine bypass、kill switch bypass、no-trade bypass、unbounded notional、unredacted payload persistence 或不可重放 evidence 都不允许进入 v0.21.0。

## V0210-001-QUEUE-ORDER

`V0210-001-QUEUE-ORDER`

Canonical queue order：

1. `GH-1273` Define Binance Spot controlled production canary contract
2. `GH-1274` Add Spot canary environment profile with default-off fail-closed policy
3. `GH-1275` Add explicit credential secret-read approval path with redaction audit
4. `GH-1276` Add Binance Spot signed account read-only runtime preflight
5. `GH-1277` Add production public market reachability / account-readiness preflight evidence
6. `GH-1278` Add hard limit / pre-trade gate for Spot canary
7. `GH-1279` Add guarded Binance Spot small canary submit path
8. `GH-1280` Add guarded Binance Spot canary cancel / emergency stop path
9. `GH-1281` Add canary status query and fill / reject classification evidence
10. `GH-1282` Add OMS event log and reconciliation evidence
11. `GH-1283` Add Dashboard / CLI read-only canary status surface
12. `GH-1284` Add incident / rollback / operator runbook
13. `GH-1285` Add verify-v0.21.0 validation suite
14. `GH-1286` Close v0.21.0 stage audit and release docs

Each issue remains `backlog` / `non-executable` until Parent Codex queue preflight promotes it. WIP=1 remains mandatory.

## V0210-001-NO-PRODUCTION-CUTOVER

`V0210-001-NO-PRODUCTION-CUTOVER`

GH-1273 keeps these flags closed:

- `credentialSecretReadImplementedByThisIssue=false`
- `productionEndpointConnectionImplementedByThisIssue=false`
- `signedAccountEndpointRuntimeImplementedByThisIssue=false`
- `canarySubmitCancelImplementedByThisIssue=false`
- `dashboardCommandSurfaceImplementedByThisIssue=false`
- `productionTradingEnabledByDefault=false`
- `automaticProductionSecretReadEnabled=false`
- `productionEndpointAutoConnectEnabled=false`
- `productionBrokerConnectionEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `futuresInScope=false`
- `okxInScope=false`
- `createsTagOrRelease=false`
- `startsNextMilestone=false`

Forbidden capabilities：

- production cutover authorization
- production trading enabled by default
- automatic secret read
- secret value logging
- production endpoint auto-connect
- production broker connection outside canary gate
- Futures execution
- OKX active implementation
- unbounded notional or exposure
- RiskEngine bypass
- kill switch bypass
- no-trade bypass
- Dashboard default trading button
- Dashboard order form by default
- order command without canary gate
- tag or GitHub Release publication
- next milestone auto-start

## TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT

`TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT`

Validation anchors：

- `GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT`
- `TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT`
- `V0210-001-V0201-PREFLIGHT-GATE`
- `V0210-001-BINANCE-SPOT-CONTROLLED-CANARY`
- `V0210-001-HUMAN-APPROVAL-REQUIRED`
- `V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS`
- `V0210-001-RISK-KILL-NO-TRADE-GATES`
- `V0210-001-QUEUE-ORDER`
- `V0210-001-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1273ReleaseV0210SpotControlledProductionCanaryContract`
- `bash checks/verify-v0.21.0-controlled-canary-contract.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1273 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production secret read。
- production endpoint / broker endpoint connection。
- signed account endpoint runtime。
- private stream runtime。
- submit / cancel / replace。
- Dashboard trading button。
- order form。
- default-on production trading。
- Futures execution。
- OKX active implementation。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
