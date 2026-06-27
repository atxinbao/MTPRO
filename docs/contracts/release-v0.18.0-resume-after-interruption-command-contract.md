# Release v0.18.0 Resume After Interruption Command Contract

日期：2026-06-28

执行者：Codex

本文档服务 GitHub fallback issue `GH-1179 V180-004 Add resume-after-interruption command using artifact store`。

GH-1179 在 GH-1177 lifecycle manifest namespace 和 GH-1178 status-query retry artifact persistence 之后，新增一个本地 resume-after-interruption command read model。该 command 只消费已经验证过的 local artifact evidence，不读取文件、不连接网络、不自动 retry、不发起 broker mutation，也不授权 production cutover。

## V0180-004-DEPENDENCIES-GH1177-GH1178-DONE

`V0180-004-DEPENDENCIES-GH1177-GH1178-DONE`

GH-1179 blocked by `#1177 closed / done` and `#1178 closed / done`。

只有 lifecycle manifest 已经把 local run artifact 绑定到 `{venue, product, environment, accountProfile, runID}`，并且 status-query retry / timeout / classified failure result 已经写入同一 append-only artifact store 后，resume-after-interruption command 才能生成可审计的本地 resume evidence。

## V0180-004-LOCAL-ARTIFACT-BACKED-RESUME

`V0180-004-LOCAL-ARTIFACT-BACKED-RESUME`

`ReleaseV0180ResumeAfterInterruptionCommand` 的输入必须来自本地 evidence object：

- GH-1177 lifecycle manifest namespace key。
- GH-1178 `ReleaseV0180StatusQueryRetryArtifactPersistence`。
- GH-1142 / v0.17 artifact-store resume cursor。

Command 输出 `mtpro operator-run resume` operator command string，仅表示 operator 可以从本地 append-only resume cursor 继续审计流，不表示可以连接 endpoint、重试网络请求或执行任何 broker mutation。

## V0180-004-LIFECYCLE-MANIFEST-REQUIRED

`V0180-004-LIFECYCLE-MANIFEST-REQUIRED`

Resume 前必须已有 validated lifecycle manifest。缺失、未验证或 namespace key 不一致时，结果必须 fail closed：

- `status=failed`
- `resumeCursor=nil`
- failure reason `lifecycleManifestMissingOrInvalid` 或 `namespaceMismatch`
- operator next action `inspect-local-artifact-evidence-before-resume`

## V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED

`V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED`

Resume 前必须有本地 replayable status-query retry evidence。该 evidence 可以是 passed 或 failed 状态，但必须满足：

- persisted in append-only local artifact store。
- redacted evidence only。
- local artifact store replayable。
- fail-closed status query evidence is operator-visible。
- namespace 与 lifecycle manifest 完全一致。

GH-1179 不重新执行 status query，也不把 failed status-query evidence 当作网络 retry 授权。它只证明 operator resume command 有足够本地审计上下文。

## V0180-004-RECONCILIATION-EVIDENCE-REQUIRED

`V0180-004-RECONCILIATION-EVIDENCE-REQUIRED`

Resume 前必须有 base resume result 证明 append-only artifact store 已 replay 到 reconciliation evidence，并且 resume cursor 的 last artifact kind 为 reconciliation。缺少该 evidence 时必须 fail closed，不能输出可继续 cursor。

## V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED

`V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED`

`venue`、`product`、`environment`、`accountProfile`、`runID` 必须在 lifecycle manifest、status-query persistence 和 base resume result 之间完全一致。

同一个 run artifact 不能被复用为另一个 venue、product 或 environment。Product mismatch、environment mismatch 或 runID mismatch 都必须 fail closed。

## V0180-004-NO-AUTOMATIC-NETWORK-RETRY

`V0180-004-NO-AUTOMATIC-NETWORK-RETRY`

Resume command 不包含 automatic network retry。它不执行 HTTP request，不读取 credential，不连接 broker，不发起 order lifecycle mutation。任何 resume action 都只能继续本地 evidence chain。

## V0180-004-NO-PRODUCTION-CUTOVER

`V0180-004-NO-PRODUCTION-CUTOVER`

GH-1179 keeps these defaults closed：

- production trading remains disabled by default。
- production secret read remains disabled。
- production endpoint connection remains disabled。
- production broker connection remains disabled。
- production order action remains disabled。
- production cutover remains unauthorized。

Forbidden capabilities：

- production cutover authorization
- production trading enabled by default
- production secret read
- production endpoint connection
- production broker endpoint connection
- production order action
- production OMS
- Dashboard trading button
- Dashboard order form
- Live PRO Console command
- automatic network retry
- broker mutation
- new venue/product activation
- tag or GitHub Release publication
- next milestone auto-start

production cutover not authorized。

## TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND

`TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`

Validation anchors：

- `GH-1179-VERIFY-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`
- `TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`
- `V0180-004-DEPENDENCIES-GH1177-GH1178-DONE`
- `V0180-004-LOCAL-ARTIFACT-BACKED-RESUME`
- `V0180-004-LIFECYCLE-MANIFEST-REQUIRED`
- `V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED`
- `V0180-004-RECONCILIATION-EVIDENCE-REQUIRED`
- `V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED`
- `V0180-004-NO-AUTOMATIC-NETWORK-RETRY`
- `V0180-004-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1179ResumeAfterInterruptionCommandUsesArtifactStoreEvidence`
- `bash checks/verify-v0.18.0-resume-after-interruption-command.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1179 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- OKX runtime implementation。
- new venue/product runtime activation。
- automatic network retry。
- broker mutation。
- resume endpoint execution。
- reconciliation replay endpoint implementation。
- CLI order command implementation。
- Dashboard command implementation。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production order action。
- production cutover。
- tag / GitHub Release publication。
- next milestone / next Project auto-start。
