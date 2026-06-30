# MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness Notes

日期：2026-07-01

执行者：Codex

## Summary

`MTPRO Release v0.20.0 Binance Spot Production-shadow / Read-only Live Readiness` 是 v0.19.1 之后的 read-only live readiness construction queue。它只把 Binance Spot 推进到 production-shadow readiness evidence：readiness contract、production-shadow environment profile、read-only endpoint allowlist、credential reference identity、public market read-only probe、signed account read-only intent、account snapshot redaction policy、no-order guard、Risk / kill switch / no-trade readiness、Dashboard / CLI read-only readiness surface 和 aggregate validation suite。

GH-1250 使用 `GH-1250-VERIFY-V0200-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0200-STAGE-AUDIT-RELEASE-DOCS`、`V0200-012-STAGE-CODE-AUDIT`、`V0200-012-RELEASE-NOTES`、`V0200-012-VALIDATION-MATRIX`、`V0200-012-ROOT-DOCS-REFRESH`、`V0200-012-STALE-WORDING-GUARD`、`V0200-012-RELEASE-PUBLICATION-GATE-HANDOFF`、`V0200-012-NO-PRODUCTION-CUTOVER` 和 `V0200-012-NO-TAG-OR-RELEASE-PUBLICATION` 收口 Stage Code Audit、release notes、validation matrix、root docs refresh、stale wording guard 和 release publication gate handoff。

#1250 是 construction closeout：它不创建 `v0.20.0` tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover。v0.20.0 public release publication 必须在 #1250 PR merge、required `checks` SUCCESS、clean main、open PR = 0、open active issue = 0、worktree clean 和完整 validation evidence 重新确认后，由独立 Release Publication Gate 执行。

## Issue Evidence

- #1239：v0.20.0 production-shadow / read-only live readiness contract。
- #1240：production-shadow environment profile。
- #1241：production-shadow read-only endpoint allowlist。
- #1242：credential reference readiness without secret value read。
- #1243：public market read-only probe。
- #1244：signed account read-only readiness intent。
- #1245：account snapshot redaction and artifact policy。
- #1246：no-order capability guard。
- #1247：Risk / kill switch / no-trade readiness evidence。
- #1248：Dashboard / CLI read-only live readiness surface。
- #1249：aggregate v0.20.0 validation suite。
- #1250：Stage Code Audit / release docs / validation matrix / root docs refresh / release publication handoff closeout。

## PR Evidence

- PR #1257：Define v0.20.0 production-shadow readiness contract。
- PR #1258：Define v0.20 production-shadow environment profile。
- PR #1259：Harden v0.20 production-shadow endpoint allowlist。
- PR #1260：Add v0.20.0 credential reference readiness。
- PR #1261：Add v0.20.0 public market read-only probe。
- PR #1262：Add v0.20.0 signed account read-only readiness。
- PR #1263：Add v0.20.0 account snapshot redaction policy。
- PR #1264：Add v0.20.0 no-order capability guard。
- PR #1265：Add v0.20.0 risk no-trade readiness guard。
- PR #1266：Add v0.20.0 read-only live readiness surface。
- PR #1267：Add v0.20.0 aggregate validation suite。

All listed PRs are merged and their required GitHub check `checks` is SUCCESS. The #1250 closeout PR validation is the final authority for this release docs closeout.

## Validation Anchors

- `GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`
- `GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE`
- `GH-1241-VERIFY-V0200-PRODUCTION-SHADOW-ENDPOINT-ALLOWLIST`
- `GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS`
- `GH-1243-VERIFY-V0200-PUBLIC-MARKET-READ-ONLY-PROBE`
- `GH-1244-VERIFY-V0200-SIGNED-ACCOUNT-READ-ONLY-READINESS`
- `GH-1245-VERIFY-V0200-ACCOUNT-SNAPSHOT-REDACTION-POLICY`
- `GH-1246-VERIFY-V0200-NO-ORDER-CAPABILITY-GUARD`
- `GH-1247-VERIFY-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS`
- `GH-1248-VERIFY-V0200-DASHBOARD-CLI-READ-ONLY-LIVE-READINESS-SURFACE`
- `GH-1249-VERIFY-V0200-RELEASE-VALIDATION-SUITE`
- `GH-1250-VERIFY-V0200-STAGE-AUDIT-RELEASE-DOCS`
- `TVM-RELEASE-V0200-STAGE-AUDIT-RELEASE-DOCS`
- `V0200-012-STAGE-CODE-AUDIT`
- `V0200-012-RELEASE-NOTES`
- `V0200-012-VALIDATION-MATRIX`
- `V0200-012-ROOT-DOCS-REFRESH`
- `V0200-012-STALE-WORDING-GUARD`
- `V0200-012-RELEASE-PUBLICATION-GATE-HANDOFF`
- `V0200-012-NO-PRODUCTION-CUTOVER`
- `V0200-012-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.20.0-stage-audit-release-docs.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1250ReleaseV0200StageAuditReleaseDocsCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Release Boundary

- `release/v0.20.0` construction queue `#1239..#1250` is complete / closed / done after #1250 merge.
- #1250 is construction closeout only.
- #1250 does not create the `v0.20.0` tag.
- #1250 does not create GitHub Release.
- Publication remains an independent Release Publication Gate after #1250 merge and clean-state validation.
- v0.20.0 is Binance Spot production-shadow / read-only live readiness only.
- Spot controlled production canary remains future gated to v0.21.0 and requires explicit Human approval.
- production trading remains disabled by default.
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不触达 live account endpoint 或 order endpoint。
- 不发送 testnet 或 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
