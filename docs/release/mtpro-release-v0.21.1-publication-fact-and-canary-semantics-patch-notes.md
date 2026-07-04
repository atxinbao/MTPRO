# MTPRO Release v0.21.1 Publication Fact and Canary Semantics Patch Notes

日期：2026-07-05

执行者：Codex

## Summary

`MTPRO Release v0.21.1 Publication Fact and Canary Semantics Patch` 是 `v0.21.0` stable publication 之后的 evidence / wording patch queue。它只同步 v0.21.0 publication facts、拒绝 current-facing stale publication wording、澄清 v0.21.0 controlled canary evidence 与 live network execution 的语义边界，并收口 patch audit / release notes / validation matrix / publication guidance。

`v0.21.0` stable GitHub Release 已由独立 Release Publication Gate 发布：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0`
- tag peeled commit：`bca492ed48324a8057c5dc7223d740426a54c3b1`
- publication timestamp：`2026-07-04T10:08:42Z`
- release type：stable；非 draft；非 prerelease

#1305 将 v0.21.0 publication facts 同步到 root docs、release notes、Stage Code Audit、latest verification summary 和 release publication policy。#1306 增加 stale wording guard，拒绝把 v0.21.0 描述成 current-facing pending / no-tag / no-release 状态。#1307 澄清 v0.21.0 是 controlled canary evidence, not live network execution；`networkSubmitAttempted=false` / `networkCancelAttempted=false` 仍是当前事实；live Spot canary transport is future work。#1308 收口 aggregate verifier、Stage Code Audit、release notes、validation matrix 和 no-capability-change publication guidance。

PR #1321、PR #1322 和 PR #1323 已分别合并 #1305、#1306 和 #1307 的 evidence。#1308 的 closeout PR 只把这些事实聚合到 patch audit / release notes / validation matrix；它不声明 live network execution，不声明 signed account runtime transport，不声明 Spot order submit transport，也不授权 production cutover。

## Validation Anchors

- `GH-1306-VERIFY-V0211-V0210-STALE-WORDING-GUARD`
- `TVM-RELEASE-V0211-V0210-STALE-WORDING-GUARD`
- `V0211-002-V0210-STALE-WORDING-GUARD`
- `V0211-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`
- `V0211-002-CURRENT-FACING-STALE-WORDING-REJECTION`
- `V0211-002-NO-PRODUCTION-CUTOVER`
- `GH-1307-VERIFY-V0211-CANARY-EVIDENCE-WORDING`
- `TVM-RELEASE-V0211-CANARY-EVIDENCE-WORDING`
- `V0211-003-CONTROLLED-CANARY-EVIDENCE-WORDING`
- `V0211-003-NOT-LIVE-NETWORK-EXECUTION`
- `V0211-003-LIVE-SPOT-CANARY-TRANSPORT-FUTURE`
- `V0211-003-NO-PRODUCTION-CUTOVER`
- `GH-1308-VERIFY-V0211-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0211-PATCH-AUDIT-RELEASE-NOTES`
- `V0211-004-AGGREGATE-GUARD`
- `V0211-004-PATCH-AUDIT`
- `V0211-004-RELEASE-NOTES`
- `V0211-004-VALIDATION-MATRIX`
- `V0211-004-NO-CAPABILITY-CHANGE`
- `V0211-004-V0220-DOWNSTREAM-LIVE-TRANSPORT-HANDOFF`
- `V0211-004-NO-PRODUCTION-CUTOVER`
- `V0211-004-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.21.1-v0210-stale-wording-guard.sh
bash checks/verify-v0.21.1-v0210-canary-evidence-wording.sh
bash checks/verify-v0.21.1.sh
```

Focused tests:

```bash
swift test --filter TargetGraphTests/testGH1306ReleaseV0211V0210StaleWordingGuardRejectsCurrentFacingDrift
swift test --filter TargetGraphTests/testGH1307ReleaseV0211CanaryEvidenceWordingGuard
swift test --filter TargetGraphTests/testGH1308ReleaseV0211PatchAuditReleaseNotesCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## v0.22.0 Handoff

`V0211-004-V0220-DOWNSTREAM-LIVE-TRANSPORT-HANDOFF`

v0.22.0 Spot live canary transport is downstream only. It must be separately authorized, queued and preflighted before any live transport implementation or promotion. This patch does not start v0.22.0, does not promote any v0.22.0 Todo, and does not grant production cutover.

## Patch Boundary

- `v0.21.1` 是 v0.21.0 后的 publication fact / wording / canary semantics patch closeout，不是新的 runtime release。
- `v0.21.0` tag remains fixed at `bca492ed48324a8057c5dc7223d740426a54c3b1`。
- GH-1308 不创建、不移动、不重写任何 tag 或 GitHub Release。
- #1305..#1308 均按 GitHub fallback queue、WIP=1、dependency order 和 issue scope 单独执行；#1308 只处理 aggregate verifier、patch audit、release notes、validation matrix 和 publication guidance。
- v0.21.0 is controlled canary evidence, not live network execution.
- `networkSubmitAttempted=false` / `networkCancelAttempted=false` remain current facts.
- live Spot canary transport is future work for `v0.22.0`.
- production trading 仍默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
