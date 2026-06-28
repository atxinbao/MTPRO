# MTPRO Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Foundation Notes

日期：2026-06-28

执行者：Codex

## Summary

`MTPRO Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Foundation` 是 v0.17.1 后的 operator lifecycle recovery construction queue。它把本地 operator beta recovery evidence 从单一 Binance Spot path 压实为 venue/product-aware foundation：所有关键证据都必须携带 `{venue, product, environment, accountProfile, runID}`，并在 cross venue/product/environment reuse 时 fail closed。

GH-1185 使用 `GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS`、`V0180-010-STAGE-CODE-AUDIT`、`V0180-010-RELEASE-NOTES`、`V0180-010-VALIDATION-MATRIX`、`V0180-010-ROOT-DOCS-REFRESH`、`V0180-010-STALE-WORDING-GUARD`、`V0180-010-NO-PRODUCTION-CUTOVER` 和 `V0180-010-NO-TAG-OR-RELEASE-PUBLICATION` 收口 Stage Code Audit、release notes、validation matrix、root docs refresh 和 stale wording guard。#1185 不创建 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover。

## Issue Evidence

- #1176：venue/product-aware operator lifecycle recovery contract。
- #1177：run artifact lifecycle manifest namespace。
- #1178：status-query retry artifact persistence。
- #1179：resume-after-interruption command。
- #1180：cancel/status reconciliation replay command。
- #1181：operator failure classification next-action CLI。
- #1182：Dashboard artifact recovery drilldown。
- #1183：manual workflow fixture negative cases。
- #1184：beta safety profile drift detector。
- #1185：Stage Code Audit / release docs / validation matrix / root docs refresh closeout。

## Validation Anchors

- `GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`
- `GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`
- `GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`
- `GH-1179-VERIFY-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`
- `GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND`
- `GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI`
- `GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN`
- `GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES`
- `GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR`
- `GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS`
- `TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS`
- `V0180-010-STAGE-CODE-AUDIT`
- `V0180-010-RELEASE-NOTES`
- `V0180-010-VALIDATION-MATRIX`
- `V0180-010-ROOT-DOCS-REFRESH`
- `V0180-010-STALE-WORDING-GUARD`
- `V0180-010-NO-PRODUCTION-CUTOVER`
- `V0180-010-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.18.0-stage-audit-release-docs.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1185ReleaseV0180StageAuditReleaseDocsCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Release Boundary

- `v0.18.0` construction queue `#1176..#1185` is complete / closed / done after #1185 merge.
- #1185 is construction closeout only.
- #1185 does not create `v0.18.0` tag.
- #1185 does not create GitHub Release.
- Publication, if requested, must be a separate Release Publication Gate.
- production trading remains disabled by default.
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
