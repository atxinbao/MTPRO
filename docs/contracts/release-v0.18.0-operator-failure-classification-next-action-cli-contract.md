# Release v0.18.0 Operator Failure Classification Next Action CLI Contract

日期：2026-06-28  
执行者：Codex

## Scope

`GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI`

`TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI`

`V0180-006-DEPENDENCIES-GH1179-GH1180-DONE`

`V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED`

`V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED`

`V0180-006-RESUME-FAILURE-CLASSIFIED`

`V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED`

`V0180-006-NEXT-ACTION-CLI`

`V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION`

`V0180-006-READ-ONLY-OPERATOR-ACTION`

`V0180-006-NO-PRODUCTION-CUTOVER`

GH-1181 在 GH-1179 resume-after-interruption command 和 GH-1180 cancel/status reconciliation replay command 之后，新增 operator-visible failure classification 与 next-action CLI read model。

## Dependency Evidence

- #1179 closed / done。
- #1180 closed / done。
- #1181 只消费前序本地 evidence object，不读取 live endpoint，不重新执行 status query，不执行 broker state mutation。

## Contract

`ReleaseV0180OperatorFailureClassificationNextActionCLI` 必须消费同一 `{venue, product, environment, accountProfile, runID}` namespace 下的本地 evidence：

- lifecycle manifest validation result / namespace key。
- GH-1178 status-query retry artifact persistence。
- GH-1179 resume result。
- GH-1180 reconciliation replay result。

分类器必须覆盖四类 failure surface：

- artifact manifest failure。
- status-query retry / timeout / retry-limit failure。
- resume evidence failure。
- reconciliation replay missing / mismatch failure。

每条 `ReleaseV0180OperatorFailureClassification` 必须包含：

- stage。
- reason。
- field。
- redacted detail。
- explanation。
- next action。
- `mtpro operator-run explain-failure` CLI string。
- `venue`、`product`、`environment`、`accountProfile`、`runID`。

## Next Action Semantics

允许输出的 next action 只有：

- `retry`：只表示 operator 可回到显式授权的 read-only status-query workflow；本分类器不自动执行。
- `resume`：当前 evidence 没有 failure classification 时，允许继续本地 resume review。
- `manualReview`：需要人工审阅 artifact / resume / replay evidence。
- `stop`：namespace mismatch、boundary drift 或 reconciliation mismatch 必须停止。

Top-level next action 按 `stop > manualReview > retry > resume` 排序。

## Boundary

本合同只新增本地 read-only operator guidance：

- 不自动 remediation。
- 不 mutation broker state。
- 不实现 OKX runtime。
- 不激活新 venue / product runtime。
- 不创建或发布 tag / GitHub Release。
- 不授权 production cutover。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送订单。
- production cutover not authorized。

## Validation

- `swift test --filter TargetGraphTests/testGH1181OperatorFailureClassificationNextActionCLIExplainsLocalEvidenceFailures`
- `bash checks/verify-v0.18.0-operator-failure-classification-next-action-cli.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
