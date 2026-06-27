# MTPRO Release v0.17.1 Operator Beta Artifact Validation Fail-closed Patch Notes

日期：2026-06-28

执行者：Codex

## Summary

`MTPRO Release v0.17.1 Operator Beta Artifact Validation Fail-closed Patch` 是 `v0.17.0` 后的 fail-closed evidence patch queue；换句话说，v0.17.1 只强化 operator artifact validation、manual workflow rejection、negative regression coverage、release fact sync 和 stale wording guard。它不移动 `v0.17.0` tag，不覆盖 GitHub Release，不创建 `v0.17.1` public release，不授权 production cutover。

`v0.17.0` stable GitHub Release 已由独立 Release Publication Gate 发布：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0`
- tag peeled commit：`c83879f80a525665c3484878d7071b1f5214da20`
- publication timestamp：`2026-06-27T06:37:33Z`
- release type：stable；非 draft；非 prerelease

#1166 让 `mtpro artifact verify` 在 failed validation bundle 上返回 nonzero exit，同时保留 redacted local reporting path。#1167 强化 manual workflow：uploaded / downloaded bundle status 不是 `passed` 时必须 fail closed。#1168 增加 corrupt bundle、missing artifact、missing manifest、reconciliation missing 等 negative regression cases。#1169 将 v0.17.0 publication facts 同步回 root docs、release policy、audit notes 和 validation guard。#1170 增加 v0.17.0 stale wording guard，拒绝未限定为 historical construction closeout 且缺少 release URL / tag commit / publication timestamp 的旧话术。#1171 收口 aggregate verifier、Stage Code Audit、release notes、validation matrix 和 publication guidance。

## Validation Anchors

- `GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED`
- `TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED`
- `V0171-001-FAILED-VALIDATION-NONZERO-EXIT`
- `V0171-001-VALID-BUNDLE-EXIT-ZERO`
- `V0171-001-LOCAL-REPORTING-PATH-REDACTED`
- `V0171-001-NO-PRODUCTION-CUTOVER`
- `GH-1167-VERIFY-V0171-MANUAL-WORKFLOW-FAIL-CLOSED`
- `TVM-RELEASE-V0171-MANUAL-WORKFLOW-FAIL-CLOSED`
- `V0171-002-UPLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW`
- `V0171-002-DOWNLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW`
- `V0171-002-REQUIRE-PASSED-STATUS`
- `V0171-002-NO-PRODUCTION-CUTOVER`
- `GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS`
- `TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS`
- `V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED`
- `V0171-003-MISSING-ARTIFACT-FAILS-CLOSED`
- `V0171-003-MISSING-MANIFEST-FAILS-CLOSED`
- `V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED`
- `V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE`
- `V0171-003-NO-PRODUCTION-CUTOVER`
- `GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC`
- `V0171-004-V0170-RELEASE-FACT-SYNC-GUARD`
- `TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC`
- `V0171-004-V0170-TAG-FIXED`
- `V0171-004-PATCH-QUEUE-NOT-PUBLICATION`
- `V0171-004-NO-PRODUCTION-CUTOVER`
- `GH-1170-VERIFY-V0171-V0170-STALE-WORDING-GUARD`
- `V0171-005-V0170-STALE-WORDING-GUARD`
- `V0171-005-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`
- `TVM-RELEASE-V0171-V0170-STALE-WORDING-GUARD`
- `GH-1171-VERIFY-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES`
- `V0171-006-AGGREGATE-GUARD`
- `V0171-006-PATCH-AUDIT`
- `V0171-006-RELEASE-NOTES`
- `V0171-006-VALIDATION-MATRIX`
- `V0171-006-V0180-HANDOFF`
- `V0171-006-NO-PRODUCTION-CUTOVER`
- `V0171-006-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh
bash checks/verify-v0.17.1-manual-workflow-fail-closed.sh
bash checks/verify-v0.17.1-artifact-negative-regressions.sh
bash checks/verify-v0.17.1-release-fact-sync.sh
bash checks/verify-v0.17.1.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1166ReleaseV0171CLIArtifactVerifyCommandFailsClosed
swift test --filter TargetGraphTests/testGH1167ReleaseV0171ManualWorkflowRejectsFailedArtifactStatus
swift test --filter TargetGraphTests/testGH1168ReleaseV0171ArtifactNegativeRegressionsFailClosed
swift test --filter TargetGraphTests/testGH1169ReleaseV0171V0170ReleaseFactSyncGuard
swift test --filter TargetGraphTests/testGH1170ReleaseV0171V0170StaleWordingGuardRejectsUnqualifiedPublicationDrift
swift test --filter TargetGraphTests/testGH1171ReleaseV0171AggregatePatchAuditReleaseNotesCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## v0.18.0 Handoff

`V0171-006-V0180-HANDOFF`

Venue/Product-aware lifecycle recovery is the next feature planning context only. The target taxonomy can support:

```text
Venue
  ├── Binance
  │     ├── Spot
  │     └── USDⓈ-M Futures
  ├── OKX
  │     ├── Spot
  │     └── Swap
  └── Bybit
        ├── Spot
        └── Linear Perpetual
```

This patch does not implement multi-venue runtime, does not create additional v0.18.0 issues, and does not promote any v0.18.0 Todo. Existing future backlog remains non-executable until a fresh queue preflight confirms eligibility.

## Patch Boundary

- `v0.17.1` 是 v0.17.0 后的 patch closeout，不是新的 production cutover gate。
- `v0.17.0` tag remains fixed at `c83879f80a525665c3484878d7071b1f5214da20`。
- GH-1171 不创建、不移动、不重写任何 tag 或 GitHub Release。
- #1166..#1171 均按 GitHub fallback queue、WIP=1、dependency order 和 issue scope 单独执行；#1171 只处理 aggregate verifier、patch audit、release notes、validation matrix 和 publication guidance。
- production trading 仍默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
