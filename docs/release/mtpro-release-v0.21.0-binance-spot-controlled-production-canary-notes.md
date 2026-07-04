# MTPRO Release v0.21.0 Binance Spot Controlled Production Canary Notes

日期：2026-07-04

执行者：Codex

## Summary

`MTPRO Release v0.21.0 Binance Spot Controlled Production Canary` 是 v0.20.1 之后的 Binance Spot controlled canary construction queue。它将 v0.20.0 production-shadow / read-only readiness 的 evidence chain 推进到 Human-approved 小额度 Binance Spot canary：credential approval、signed account read-only preflight、redacted account snapshot、hard limits、RiskEngine / kill switch / no-trade gate、single submit evidence、cancel / rollback evidence、OMS event log / reconciliation、Dashboard / CLI read-only canary status surface 和 operator runbook。

GH-1286 使用 `GH-1286-VERIFY-V0210-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0210-STAGE-AUDIT-RELEASE-DOCS`、`V0210-014-STAGE-CODE-AUDIT`、`V0210-014-RELEASE-NOTES`、`V0210-014-VALIDATION-MATRIX`、`V0210-014-ROOT-DOCS-REFRESH`、`V0210-014-STALE-WORDING-GUARD`、`V0210-014-RELEASE-PUBLICATION-GATE-HANDOFF`、`V0210-014-NO-PRODUCTION-CUTOVER` 和 `V0210-014-NO-TAG-OR-RELEASE-PUBLICATION` 收口 Stage Code Audit、release notes、validation matrix、root docs refresh、stale wording guard 和 release publication gate handoff。

#1286 是 historical construction closeout：在 #1286 merge 时，它只收口 construction evidence，没有创建 `v0.21.0` tag / GitHub Release、下一 Project / Issue 或下一 Todo，也没有授权 production cutover。

## Publication Fact

`v0.21.0` 已在独立 Release Publication Gate 中发布为 stable GitHub Release：

- Release URL: https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0
- Tag / target commit: `bca492ed48324a8057c5dc7223d740426a54c3b1`
- Published at: `2026-07-04T10:08:42Z`
- Release type: stable, `isDraft=false`, `isPrerelease=false`

该发布事实不移动 tag、不重写 GitHub Release、不授权 production cutover、不自动读取 production secret、不自动连接 production endpoint / broker endpoint，也不放开 unrestricted submit / cancel / replace。

## Issue Evidence

- #1273：v0.21.0 controlled canary contract。
- #1274：Spot canary environment profile。
- #1275：credential secret-read approval path。
- #1276：signed account read-only preflight。
- #1277：live account snapshot redaction artifact。
- #1278：canary hard limits。
- #1279：pre-trade RiskEngine / kill switch / no-trade gate。
- #1280：controlled Spot canary submit evidence。
- #1281：controlled canary cancel / rollback guard。
- #1282：OMS event log and reconciliation evidence。
- #1283：Dashboard / CLI read-only canary status surface。
- #1284：canary operator runbook。
- #1285：aggregate v0.21.0 validation suite。
- #1286：Stage Code Audit / release docs / validation matrix / root docs refresh / release publication handoff closeout。

## PR Evidence

- PR #1291：Define v0.21.0 controlled canary contract。
- PR #1292：Add v0.21.0 spot canary environment profile。
- PR #1293：Add v0.21.0 credential secret-read approval path。
- PR #1294：Add v0.21.0 signed account read-only preflight。
- PR #1295：Add v0.21.0 live account snapshot redaction evidence。
- PR #1296：Add v0.21.0 canary hard limit gate。
- PR #1297：Add v0.21.0 pre-trade risk kill no-trade gate。
- PR #1298：Add controlled Spot canary submit path。
- PR #1299：Add controlled canary cancel rollback guard。
- PR #1300：Add canary OMS event log reconciliation evidence。
- PR #1301：Add v0.21 canary status read-only surface。
- PR #1302：Add v0.21 canary operator runbook。
- PR #1303：Add v0.21 aggregate validation suite。

All listed PRs are merged and their required GitHub check `checks` is SUCCESS. The #1286 closeout PR validation is the final authority for this release docs closeout.

## Validation Anchors

- `GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT`
- `GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE`
- `GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL`
- `GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`
- `GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION`
- `GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS`
- `GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE`
- `GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT`
- `GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK`
- `GH-1282-VERIFY-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION`
- `GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE`
- `GH-1284-VERIFY-V0210-CANARY-OPERATOR-RUNBOOK`
- `GH-1285-VERIFY-V0210-AGGREGATE-VALIDATION`
- `GH-1286-VERIFY-V0210-STAGE-AUDIT-RELEASE-DOCS`
- `TVM-RELEASE-V0210-STAGE-AUDIT-RELEASE-DOCS`
- `V0210-014-STAGE-CODE-AUDIT`
- `V0210-014-RELEASE-NOTES`
- `V0210-014-VALIDATION-MATRIX`
- `V0210-014-ROOT-DOCS-REFRESH`
- `V0210-014-STALE-WORDING-GUARD`
- `V0210-014-RELEASE-PUBLICATION-GATE-HANDOFF`
- `V0210-014-NO-PRODUCTION-CUTOVER`
- `V0210-014-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.21.0-stage-audit-release-docs.sh
```

Full validation remains:

```bash
git diff --check
bash checks/verify-v0.21.0.sh
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Release Boundary

- `release/v0.21.0` construction queue `#1273..#1286` is complete / closed / done after #1286 merge.
- #1286 is historical construction closeout only.
- `v0.21.0` stable GitHub Release is now published at https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0.
- `v0.21.0` tag / target commit is `bca492ed48324a8057c5dc7223d740426a54c3b1`.
- `v0.21.0` publication timestamp is `2026-07-04T10:08:42Z`.
- v0.21.0 is Binance Spot controlled production canary only.
- Binance USDⓈ-M Futures and OKX are out of scope for v0.21.0.
- production trading remains disabled by default.
- 不自动读取 production secret。
- 不自动连接 production endpoint / broker endpoint。
- 不授权 production cutover。
- production cutover not authorized。
