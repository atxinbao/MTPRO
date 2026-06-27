# Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Contract

日期：2026-06-28

执行者：Codex

本文档服务 GitHub fallback issue `GH-1176 V180-001 Define venue/product-aware operator lifecycle recovery contract`。

本文档定义 `MTPRO Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Foundation` 的第一层合同：所有 operator lifecycle artifact 必须使用同一个 `{venue, product, environment, accountProfile, runID}` namespace，并且 status query persistence、resume、reconciliation replay、CLI next-action 和 Dashboard drilldown 都必须按该 namespace 查询、关联和恢复。GH-1176 只定义合同和验证护栏，不实现新 runtime，不启用 OKX，不连接 production endpoint / broker endpoint，不读取 production secret，不发送真实订单，不授权 production cutover。

## V0180-001-DEPENDENCIES-CLOSED-DONE

`V0180-001-DEPENDENCIES-CLOSED-DONE`

v0.18.0 不能启动，除非 v0.17.1 fail-closed patch 任务全部完成。GH-1176 的前置条件固定为：

- `#1168 closed / done`
- `#1169 closed / done`
- `#1170 closed / done`
- `#1171 closed / done`

Parent Codex queue preflight 仍必须确认 open PR = 0、open `todo` / `in-progress` / `in-review` issue = 0、`main == origin/main` 且 worktree clean。上述事实缺失时，v0.18.0 issue 只能保持 backlog / non-executable。

## V0180-001-NAMESPACE-CONTRACT

`V0180-001-NAMESPACE-CONTRACT`

v0.18.0 的 canonical operator lifecycle namespace 必须同时包含：

- `venue`
- `product`
- `environment`
- `accountProfile`
- `runID`

该 namespace 是 artifact lifecycle、status query persistence、resume、reconciliation replay、CLI next-action 和 Dashboard drilldown 的唯一关联键。任何 evidence surface 不得只按 `runID`、只按 venue、只按 product 或只按 local file path 关联 operator lifecycle state。

## V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE

`V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE`

v0.18.0 的 target architecture 只定义 Binance / OKX 的 venue/product-aware recovery 语义：

- Binance target product：`spot`、`usdmFutures`
- OKX target product：`spot`、`swap`
- Allowed mode：contract evidence、local artifact evidence、read-only status / resume / replay evidence、CLI next-action evidence、Dashboard read-only drilldown evidence

GH-1176 不激活新的 venue/product runtime，不实现 OKX runtime，不把 OKX 接入真实 endpoint，不把非 Binance / OKX venue 作为 v0.18.0 active target。

No new OKX runtime implementation。

## V0180-001-ARTIFACT-LIFECYCLE-SCOPE

`V0180-001-ARTIFACT-LIFECYCLE-SCOPE`

每一个 operator lifecycle artifact 都必须记录完整 namespace，并在生命周期状态中保留相同字段：

- artifact created / validated / failed / archived
- manifest path / checksum / schema version
- redacted credential reference only
- operator-readable validation result
- recovery classification

artifact lifecycle 不得持久化 raw API key、secret、listenKey、signature、raw broker payload、production endpoint marker 或 production order payload。

## V0180-001-STATUS-RESUME-RECONCILIATION

`V0180-001-STATUS-RESUME-RECONCILIATION`

status query persistence、resume 和 reconciliation replay 必须使用同一个 namespace：

- status query persistence 必须保存 `{venue, product, environment, accountProfile, runID}` 和 redacted request evidence。
- resume cursor 必须绑定同一个 namespace，并且不得在 resume 时自动 submit / cancel / replace。
- reconciliation replay 必须用同一个 namespace 读取 artifact bundle、status evidence 和 projection evidence。
- namespace 不匹配时必须 fail closed，并输出 operator-readable classification。

## V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN

`V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN`

CLI next-action 和 Dashboard drilldown 必须只读展示同一个 namespace 下的 lifecycle evidence：

- CLI next-action 必须显示 namespace、latest lifecycle state、next allowed operator step 和 fail-closed reason。
- Dashboard drilldown 必须显示 namespace、artifact lifecycle、status persistence、resume readiness 和 reconciliation replay result。
- Dashboard drilldown 仍是 read-only，不提供 trading button、order form、Live PRO command 或 production cutover control。

## V0180-001-NO-PRODUCTION-CUTOVER

`V0180-001-NO-PRODUCTION-CUTOVER`

GH-1176 keeps these flags closed：

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`
- `createsTagOrRelease=false`
- `startsNextMilestone=false`
- `newOKXRuntimeImplemented=false`

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
- new OKX runtime implementation
- new venue/product activation beyond explicit v0.18.0 evidence contract
- raw secret persistence
- raw broker payload persistence
- tag or GitHub Release publication
- next milestone auto-start

production cutover not authorized。

## TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT

`TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`

Validation anchors：

- `GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`
- `TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`
- `V0180-001-DEPENDENCIES-CLOSED-DONE`
- `V0180-001-NAMESPACE-CONTRACT`
- `V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE`
- `V0180-001-ARTIFACT-LIFECYCLE-SCOPE`
- `V0180-001-STATUS-RESUME-RECONCILIATION`
- `V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN`
- `V0180-001-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1176ReleaseV0180VenueProductAwareOperatorLifecycleRecoveryContract`
- `bash checks/verify-v0.18.0-venue-product-aware-lifecycle-recovery-contract.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1176 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- artifact lifecycle runtime implementation。
- status query runtime implementation。
- resume / reconciliation replay runtime implementation。
- CLI command implementation。
- Dashboard drilldown implementation。
- OKX runtime implementation。
- new venue/product activation。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production submit / cancel / replace。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
