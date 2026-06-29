# MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation Notes

日期：2026-06-29

执行者：Codex

## Summary

`MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation` 是 v0.18.1 后的 registry foundation construction queue。它把 v0.18 lifecycle recovery 的 `{venue, product, environment, accountProfile, runID}` evidence 提升为 typed registry / capability / endpoint / credential / runtime adapter boundary，并让 Dashboard 和 CLI 可以只读检查 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap 的 readiness state。

GH-1215 使用 `GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS`、`V0190-010-STAGE-CODE-AUDIT`、`V0190-010-RELEASE-NOTES`、`V0190-010-VALIDATION-MATRIX`、`V0190-010-ROOT-DOCS-REFRESH`、`V0190-010-STALE-WORDING-GUARD`、`V0190-010-NO-PRODUCTION-CUTOVER` 和 `V0190-010-NO-TAG-OR-RELEASE-PUBLICATION` 收口 Stage Code Audit、release notes、validation matrix、root docs refresh 和 stale wording guard。#1215 是 historical construction closeout：它在 construction closeout 当时不创建 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover。后续独立 Release Publication Gate 已发布 v0.19.0 stable GitHub Release。

GH-1233 使用 `GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`、`TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`、`V0191-002-CURRENT-RELEASE-PUBLISHED` 和 `V0191-002-NO-PRODUCTION-CUTOVER` 将本 notes 中的 no-tag / no-release 语句限定为 #1215 historical construction closeout evidence。当前 release fact 是 v0.19.0 stable GitHub Release 已发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`，tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`，publication timestamp `2026-06-29T13:42:34Z`。

## Issue Evidence

- #1206：VenueRegistry / ProductRegistry。
- #1207：VenueProductCapabilityMatrix。
- #1208：VenueEndpointFamily registry。
- #1209：VenueCredentialProfile registry。
- #1210：v0.18 lifecycle typed namespace migration。
- #1211：VenueProductRuntimeAdapter protocol。
- #1212：Binance Spot Testnet runtime registry。
- #1213：Dashboard venue/product registry surface。
- #1214：CLI venue/product registry inspect。
- #1215：Stage Code Audit / release docs / validation matrix / root docs refresh closeout。

## PR Evidence

- PR #1222：Define v0.19 venue/product registries。
- PR #1223：Add v0.19 venue/product capability matrix。
- PR #1224：Add v0.19 venue endpoint family registry。
- PR #1225：Add v0.19 venue credential profile registry。
- PR #1226：Migrate v0.18 lifecycle namespace to typed registry。
- PR #1227：Add v0.19 venue/product runtime adapter protocol。
- PR #1228：Route Binance Spot Testnet through v0.19 runtime registry。
- PR #1229：Add dashboard venue product registry surface。
- PR #1230：Add CLI venue product registry inspect。

All listed PRs are merged and their required GitHub check `checks` is SUCCESS. The #1215 closeout PR validation is the final authority for this release docs closeout.

## Validation Anchors

- `GH-1206-VERIFY-V0190-VENUE-PRODUCT-REGISTRY`
- `GH-1207-VERIFY-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX`
- `GH-1208-VERIFY-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY`
- `GH-1209-VERIFY-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY`
- `GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE`
- `GH-1211-VERIFY-V0190-RUNTIME-ADAPTER-PROTOCOL`
- `GH-1212-VERIFY-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY`
- `GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE`
- `GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT`
- `GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`
- `TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS`
- `V0190-010-STAGE-CODE-AUDIT`
- `V0190-010-RELEASE-NOTES`
- `V0190-010-VALIDATION-MATRIX`
- `V0190-010-ROOT-DOCS-REFRESH`
- `V0190-010-STALE-WORDING-GUARD`
- `V0190-010-NO-PRODUCTION-CUTOVER`
- `V0190-010-NO-TAG-OR-RELEASE-PUBLICATION`
- `GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`
- `V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`
- `TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`
- `V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`
- `V0191-002-CURRENT-RELEASE-PUBLISHED`
- `V0191-002-NO-PRODUCTION-CUTOVER`

Focused verifier:

```bash
bash checks/verify-v0.19.0-stage-audit-release-docs.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1215ReleaseV0190StageAuditReleaseDocsCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Release Boundary

- `v0.19.0` construction queue `#1206..#1215` is complete / closed / done after #1215 merge.
- #1215 is historical construction closeout only.
- #1215 did not create `v0.19.0` tag at construction closeout time.
- #1215 did not create GitHub Release at construction closeout time.
- Those no-tag / no-release statements are historical closeout evidence, not current release state.
- A later independent Release Publication Gate published v0.19.0 stable GitHub Release at `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`.
- #1215 does not create the next Project / Issue.
- #1215 does not promote the next Todo.
- production trading remains disabled by default.
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
