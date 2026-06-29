# MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation Stage Code Audit

日期：2026-06-29

执行者：Codex

## Scope

`MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation` 收口 GitHub fallback issues `#1206..#1215`。本 construction queue 基于 v0.18.1 Venue/Product Lifecycle Recovery CLI + Release Fact Patch closeout，把 venue / product / environment / accountProfile namespace 进一步提升为 registry foundation：VenueRegistry、ProductRegistry、VenueProductCapabilityMatrix、VenueEndpointFamily registry、VenueCredentialProfile registry、typed v0.18 lifecycle namespace、VenueProductRuntimeAdapter protocol、Binance Spot Testnet runtime registry、Dashboard read-only surface 和 CLI read-only inspect surface。

本 Stage Code Audit 只记录 v0.19.0 construction closeout evidence。它在 #1215 construction closeout 当时不创建 `v0.19.0` tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover。该 no-tag / no-release statement 是 historical closeout evidence，不是当前 v0.19.0 release 状态；后续独立 Release Publication Gate 已发布 v0.19.0 stable GitHub Release。

GH-1233 使用 `GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`、`TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`、`V0191-002-CURRENT-RELEASE-PUBLISHED` 和 `V0191-002-NO-PRODUCTION-CUTOVER` 约束本 audit 的 historical wording：#1215 no-tag / no-release 只描述 construction closeout time；当前 release fact 是 v0.19.0 stable GitHub Release 已发布，Release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`，tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`，publication timestamp `2026-06-29T13:42:34Z`。

GH-1234 使用 `GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD`、`V0191-003-V0190-STALE-WORDING-GUARD`、`V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`、`TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD`、`V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION` 和 `V0191-003-NO-PRODUCTION-CUTOVER` 约束本 audit 的 current-facing wording：stale v0.19.0 publication wording 必须失败；historical construction closeout evidence 只有在保留 Release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`、tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c` 和 publication timestamp `2026-06-29T13:42:34Z` 时允许；production cutover not authorized。

GH-1235 使用 `V0191-004-V0190-RELEASE-NOTES-PUBLICATION-FACTS`、`V0191-004-V0190-STAGE-AUDIT-PUBLICATION-FACTS`、`V0191-004-V0190-STABLE-RELEASE-FACT` 和 `V0191-004-NO-PRODUCTION-CUTOVER` 将本 audit 的 current release state 对齐到 GitHub live-read：`v0.19.0` GitHub Release URL 为 `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`，release title 为 `MTPRO v0.19.0 Venue/Product Registry + Runtime Adapter Foundation`，`isDraft=false`，`isPrerelease=false`，tag 是 annotated tag，peeled commit 为 `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`，publishedAt 为 `2026-06-29T13:42:34Z`。该 publication fact 不改变本 audit 的 boundary：production trading 默认关闭，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 real order，不授权 production cutover。

GH-1236 使用 `GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR`、`TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR`、`V0191-005-AGGREGATE-GUARD`、`V0191-005-FOCUSED-GUARDS-COVERED`、`V0191-005-PUBLICATION-FACTS-COVERED`、`V0191-005-RUN-AUTOMATION-WIRING`、`V0191-005-NO-PRODUCTION-CUTOVER` 和 `V0191-005-NO-TAG-OR-RELEASE-PUBLICATION` 将 v0.19.1 aggregate verifier 绑定到 #1232 release fact sync、#1233 historical closeout wording、#1234 stale wording guard 和 #1235 publication fact markers。该 aggregate anchor 不移动 `v0.19.0` tag，不覆盖 GitHub Release，不创建 v0.19.1 tag / GitHub Release；production cutover not authorized。

## Issue Completion Evidence

- #1206：`GH-1206-VERIFY-V0190-VENUE-PRODUCT-REGISTRY`，定义 `ReleaseV0190VenueRegistry`、`ReleaseV0190ProductRegistry` 和 `ReleaseV0190VenueProductTarget`，允许 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap target pairs，并保持 productionLive 默认拒绝。
- #1207：`GH-1207-VERIFY-V0190-VENUE-PRODUCT-CAPABILITY-MATRIX`，定义 submit、cancel、status、position、reconcile、reduceOnly、leverage 和 marginType capability matrix，区分 active、placeholder、forbidden 和 futureGated。
- #1208：`GH-1208-VERIFY-V0190-VENUE-ENDPOINT-FAMILY-REGISTRY`，定义 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap 的 typed endpoint family rows；registry 只保存 host family evidence，不打开 endpoint connection。
- #1209：`GH-1209-VERIFY-V0190-VENUE-CREDENTIAL-PROFILE-REGISTRY`，定义 testnet / productionShadow credential profile identity rows 和 redacted evidence reference；不读取或保存 secret value。
- #1210：`GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE`，把 v0.18 lifecycle manifest、status retry、resume、replay 和 Dashboard drilldown 迁移到 typed VenueID / ProductKind / TradingEnvironment / AccountProfileID namespace。
- #1211：`GH-1211-VERIFY-V0190-RUNTIME-ADAPTER-PROTOCOL`，定义 registry-aware `ReleaseV0190VenueProductRuntimeAdapter` protocol 和 local evidence adapter selection，所有 operation 必须通过 capability / endpoint / credential / namespace gate。
- #1212：`GH-1212-VERIFY-V0190-BINANCE-SPOT-TESTNET-RUNTIME-REGISTRY`，只注册 Binance Spot Testnet submit / cancel / queryStatus 到既有 v0.15 / v0.16 runtime anchors；Binance Futures、OKX、productionShadow 和 productionLive 均 fail closed。
- #1213：`GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE`，让 Dashboard 只读展示 Binance Spot、Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap 的 registry / capability / runtime registration 状态。
- #1214：`GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT`，增加 `mtpro venue-product list`、`capabilities` 和 `explain` 三个只读 CLI inspect command；unknown / unsupported venue product input fail closed。
- #1215：`GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`，收口 Stage Code Audit、release notes、validation matrix、root docs refresh、stale wording guard 和 no-production-cutover statement。

## PR / Checks / Merge Evidence

- PR #1222：[Define v0.19 venue/product registries](https://github.com/atxinbao/MTPRO/pull/1222)，mergedAt `2026-06-28T11:44:48Z`，merge commit `40e7c8bd6ee9ac117d28a564d58e8c75f8267195`，required check `checks` SUCCESS。
- PR #1223：[Add v0.19 venue/product capability matrix](https://github.com/atxinbao/MTPRO/pull/1223)，mergedAt `2026-06-28T12:27:21Z`，merge commit `34b68ed1cea516b4e63e2da73447fa3ac216ee38`，required check `checks` SUCCESS。
- PR #1224：[Add v0.19 venue endpoint family registry](https://github.com/atxinbao/MTPRO/pull/1224)，mergedAt `2026-06-28T14:23:31Z`，merge commit `40b10f004b627231bcec343c93c111af9c2cb047`，required check `checks` SUCCESS。
- PR #1225：[Add v0.19 venue credential profile registry](https://github.com/atxinbao/MTPRO/pull/1225)，mergedAt `2026-06-29T08:11:38Z`，merge commit `3b6a373a0d2d2e053f78c54222cbc377ca81275e`，required check `checks` SUCCESS。
- PR #1226：[Migrate v0.18 lifecycle namespace to typed registry](https://github.com/atxinbao/MTPRO/pull/1226)，mergedAt `2026-06-29T09:02:22Z`，merge commit `9735b0ed5d062778b2e5b01e4f8b276619ef7045`，required check `checks` SUCCESS。
- PR #1227：[Add v0.19 venue/product runtime adapter protocol](https://github.com/atxinbao/MTPRO/pull/1227)，mergedAt `2026-06-29T09:49:05Z`，merge commit `2b59aec25992c2503ef82d211cfb189ad1a76ea6`，required check `checks` SUCCESS。
- PR #1228：[Route Binance Spot Testnet through v0.19 runtime registry](https://github.com/atxinbao/MTPRO/pull/1228)，mergedAt `2026-06-29T10:35:52Z`，merge commit `b178abe721a5e5c52796b22b3d04c1439be1d6c8`，required check `checks` SUCCESS。
- PR #1229：[Add dashboard venue product registry surface](https://github.com/atxinbao/MTPRO/pull/1229)，mergedAt `2026-06-29T11:23:46Z`，merge commit `38c64031beec15ae996a595831d8e73e61bb3c7f`，required check `checks` SUCCESS。
- PR #1230：[Add CLI venue product registry inspect](https://github.com/atxinbao/MTPRO/pull/1230)，mergedAt `2026-06-29T12:14:14Z`，merge commit `e767e700393d98519e9f68d56d18553cefb7291f`，required check `checks` SUCCESS。

## Closeout Anchors

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
- `V0191-004-V0190-RELEASE-NOTES-PUBLICATION-FACTS`
- `V0191-004-V0190-STAGE-AUDIT-PUBLICATION-FACTS`
- `V0191-004-V0190-STABLE-RELEASE-FACT`
- `V0191-004-NO-PRODUCTION-CUTOVER`
- `GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR`
- `TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR`
- `V0191-005-AGGREGATE-GUARD`
- `V0191-005-FOCUSED-GUARDS-COVERED`
- `V0191-005-PUBLICATION-FACTS-COVERED`
- `V0191-005-RUN-AUTOMATION-WIRING`
- `V0191-005-NO-PRODUCTION-CUTOVER`
- `V0191-005-NO-TAG-OR-RELEASE-PUBLICATION`

## Validation Summary

Required local validation for this closeout:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.19.0-stage-audit-release-docs.sh
bash checks/run.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1215ReleaseV0190StageAuditReleaseDocsCloseout
```

Latest pre-closeout evidence before #1215: #1214 finished with `bash checks/run.sh` passing `759 tests / 0 failures` and required GitHub check `checks` SUCCESS on PR #1230. #1215 adds the final closeout verifier and root docs guard; the PR validation output is the final authority for this audit PR.

## Boundary Audit

- v0.19.0 是 venue/product registry + runtime adapter foundation，不是 production cutover。
- Active runtime registration remains Binance Spot Testnet only for submit / cancel / queryStatus through existing v0.15 / v0.16 anchors.
- Binance USDⓈ-M Futures、OKX Spot 和 OKX Swap 仍是 registry / capability / endpoint / credential / read-only inspection foundation，不是 active runtime implementation。
- Dashboard 和 CLI surfaces are read-only inspect surfaces only。
- Production trading 默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production submit / cancel / replace order。
- 不新增 OKX runtime、Binance Futures runtime、real broker adapter、production OMS、trading button、order form、live command 或 production cutover control。
- 本 Stage Code Audit 在 #1215 construction closeout 当时不创建 tag 或 GitHub Release；该 statement 是 historical closeout evidence，当前 v0.19.0 已由后续独立 Release Publication Gate 发布 stable GitHub Release。
- 当前 v0.19.0 GitHub Release URL 是 `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`，`isDraft=false`，`isPrerelease=false`，annotated tag peels to `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`，publishedAt `2026-06-29T13:42:34Z`。
- 不创建下一 Project / Issue，不推进下一 Todo。
- 不使用 Linear、Symphony、Graphify、code-index 或 Figma。

## Residual Risk

v0.19.0 关闭的是 registry foundation 和 local adapter boundary。它把 venue / product target、capability、endpoint family、credential profile、runtime adapter selection、Dashboard inspect 和 CLI inspect 串成 typed evidence surface，但仍不是 production readiness approval。真实 production cutover、production credential policy、production endpoint connection, broker adapter, capital / risk approval, operator quorum, incident rollback, venue-specific runtime implementation 和 production release gate 仍必须单独规划、单独授权、单独验证。

## Root Docs Delta

本 closeout 将 root docs、validation docs、automation readiness 和 release publication policy 同步到已发生事实：`release/v0.19.0` queue `#1206..#1215` construction closeout，#1215 收口 Stage Code Audit、release notes、validation matrix、root docs refresh 和 stale wording guard。#1215 本身不创建 public release publication 的语句只限定为 historical construction closeout evidence；后续独立 Release Publication Gate 已发布 v0.19.0 stable GitHub Release。production cutover not authorized。

## Next Handoff

v0.19.0 已在本 historical construction closeout 之后通过独立 Release Publication Gate 发布 stable GitHub Release。后续 patch queue 只能同步已发生事实、修正 stale wording 或追加 patch evidence；不得移动 `v0.19.0` tag、不得覆盖 GitHub Release、不得推进下一阶段、不得授权 production cutover。
