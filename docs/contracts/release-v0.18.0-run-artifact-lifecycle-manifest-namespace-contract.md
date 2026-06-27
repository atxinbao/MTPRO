# Release v0.18.0 Run Artifact Lifecycle Manifest Namespace Contract

日期：2026-06-28

执行者：Codex

本文档服务 GitHub fallback issue `GH-1177 V180-002 Add end-to-end run artifact lifecycle manifest with venue/product/environment namespace`。

GH-1177 在 GH-1176 的 namespace 合同之后，把本地 `.local/mtpro/runs/<runID>/` run artifact bundle 绑定到 v0.18.0 lifecycle manifest。该 manifest 必须记录 `venue`、`product`、`environment`、`accountProfile` 和 `runID`，并且 status query persistence、resume、reconciliation replay、CLI next-action 和 Dashboard drilldown 只能消费同一个 namespace 下的本地 evidence。GH-1177 不实现 OKX runtime，不连接 production endpoint / broker endpoint，不读取 production secret，不提交真实订单，不授权 production cutover。

## V0180-002-DEPENDENCY-GH1176-DONE

`V0180-002-DEPENDENCY-GH1176-DONE`

GH-1177 blocked by `#1176 closed / done`。只有 GH-1176 已完成 venue/product-aware operator lifecycle recovery contract，GH-1177 才能把 run artifact lifecycle manifest 落到本地 evidence 层。

## V0180-002-LIFECYCLE-MANIFEST-SCHEMA

`V0180-002-LIFECYCLE-MANIFEST-SCHEMA`

v0.18.0 lifecycle manifest 固定文件名为：

- `lifecycle-manifest-v0.18.0.json`

该 manifest 只作为 `.local/mtpro/runs/<runID>/manifest.json` 的 namespace-aware companion evidence。旧 `manifest.json` 的 v0.6 schema 不被破坏；v0.18.0 companion manifest 必须引用旧 manifest path、旧 required artifact checksums、required artifact file names 和 `completed-local-run-artifacts-validated` lifecycle state。

## V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE

`V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`

每个 lifecycle manifest 必须记录完整 namespace：

- `venue`
- `product`
- `environment`
- `accountProfile`
- `runID`

当前 v0.18.0 recovery taxonomy 允许的 venue/product pair 为：

- `binance` / `spot`
- `binance` / `usdmFutures`
- `okx` / `spot`
- `okx` / `swap`

该 taxonomy 不等于 OKX runtime implementation，也不激活新的 venue/product execution。

## V0180-002-ACCOUNT-RUNID-BINDING

`V0180-002-ACCOUNT-RUNID-BINDING`

`accountProfile` 和 `runID` 必须和同一个 local run artifact bundle 绑定。Validation 必须同时检查：

- expected namespace 与 manifest observed namespace 完全一致。
- source `manifest.json` artifact checksum / bytes validation 继续通过。
- status query persistence namespace、resume namespace、reconciliation replay namespace、CLI next-action namespace 和 Dashboard drilldown namespace 全部等于同一个 namespace key。

## V0180-002-BOUNDARY-REUSE-REJECTION

`V0180-002-BOUNDARY-REUSE-REJECTION`

同一个 local run artifact bundle 不能跨 venue/product/environment/accountProfile/runID 复用。任何 expected namespace 与 observed manifest namespace 不一致时，validation 必须 fail closed，并输出 namespace mismatch classification。

必须拒绝：

- missing `venue`
- missing `product`
- missing `environment`
- missing `accountProfile`
- missing `runID`
- unsupported venue/product pair
- same runID reused as a different venue
- same runID reused as a different product
- same runID reused as a different environment
- same runID reused as a different accountProfile

## V0180-002-LOCAL-EVIDENCE-ONLY

`V0180-002-LOCAL-EVIDENCE-ONLY`

GH-1177 只写入和校验本地 evidence：

- source run manifest path
- required artifact file names
- required artifact checksums
- lifecycle checksum
- namespace equality evidence

GH-1177 不读取 credential value，不保存 raw secret，不保存 raw endpoint payload，不保存 raw broker payload，不保存 order payload。

## V0180-002-NO-PRODUCTION-CUTOVER

`V0180-002-NO-PRODUCTION-CUTOVER`

GH-1177 keeps these flags closed：

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
- OKX runtime implementation
- new venue/product activation beyond explicit v0.18.0 local evidence contract
- tag or GitHub Release publication
- next milestone auto-start

production cutover not authorized。

## TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE

`TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`

Validation anchors：

- `GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`
- `TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`
- `V0180-002-DEPENDENCY-GH1176-DONE`
- `V0180-002-LIFECYCLE-MANIFEST-SCHEMA`
- `V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`
- `V0180-002-ACCOUNT-RUNID-BINDING`
- `V0180-002-BOUNDARY-REUSE-REJECTION`
- `V0180-002-LOCAL-EVIDENCE-ONLY`
- `V0180-002-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1177RunArtifactLifecycleManifestRecordsNamespaceAndRejectsReuse`
- `bash checks/verify-v0.18.0-run-artifact-lifecycle-manifest-namespace.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1177 不授权：

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
