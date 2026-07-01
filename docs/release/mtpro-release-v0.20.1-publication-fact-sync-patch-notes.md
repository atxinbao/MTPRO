# MTPRO Release v0.20.1 Publication Fact Sync Patch Notes

日期：2026-07-01

执行者：Codex

## Summary

`MTPRO Release v0.20.1 Publication Fact Sync Patch` 是 `v0.20.0` stable publication 之后的 evidence / wording patch queue。它只同步 v0.20.0 publication facts、拒绝 current-facing stale publication wording、澄清 public-market probe 和 signed-account readiness 的证据语义，并收口 patch audit / release notes / validation matrix / publication guidance。

`v0.20.0` stable GitHub Release 已由独立 Release Publication Gate 发布：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.20.0`
- tag peeled commit：`7f84999e8e4071fb71fdc802f895de81303bbcfd`
- publication timestamp：`2026-06-30T16:55:24Z`
- release type：stable；非 draft；非 prerelease

#1269 将 v0.20.0 publication facts 同步到 root docs、release notes、Stage Code Audit、latest verification summary 和 release publication policy。#1270 增加 stale wording guard，拒绝把 v0.20.0 描述成 current-facing pending / no-tag / no-release 状态。#1271 澄清 GH-1243 public-market probe 只是 response classification / readiness evidence，不是 live transport proof；GH-1244 signed-account readiness 只是 intent evidence，不是 account access proof 或 account payload retrieval。#1272 收口 aggregate verifier、Stage Code Audit、release notes、validation matrix 和 no-capability-change publication guidance。

PR #1287、PR #1288 和 PR #1289 已分别合并 #1269、#1270 和 #1271 的 evidence。#1272 的 closeout PR 只把这些事实聚合到 patch audit / release notes / validation matrix；它不声明 live transport proof、不声明 account access proof、不声明 account payload retrieval，也不授权 production cutover。

## Validation Anchors

- `V0201-001`
- `GH-1270-VERIFY-V0201-V0200-STALE-WORDING-GUARD`
- `V0201-002-V0200-STALE-WORDING-GUARD`
- `V0201-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`
- `TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD`
- `V0201-002-CURRENT-FACING-STALE-WORDING-REJECTION`
- `V0201-002-NO-PRODUCTION-CUTOVER`
- `GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`
- `TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`
- `V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE`
- `V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE`
- `V0201-003-NOT-LIVE-TRANSPORT-PROOF`
- `V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL`
- `V0201-003-NO-ENDPOINT-CONNECTION`
- `V0201-003-NO-PRODUCTION-CUTOVER`
- `GH-1272-VERIFY-V0201-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0201-PATCH-AUDIT-RELEASE-NOTES`
- `V0201-004-AGGREGATE-GUARD`
- `V0201-004-PATCH-AUDIT`
- `V0201-004-RELEASE-NOTES`
- `V0201-004-VALIDATION-MATRIX`
- `V0201-004-NO-CAPABILITY-CHANGE`
- `V0201-004-V0210-DOWNSTREAM-CANARY-HANDOFF`
- `V0201-004-NO-PRODUCTION-CUTOVER`
- `V0201-004-NO-TAG-OR-RELEASE-PUBLICATION`

Focused verifier:

```bash
bash checks/verify-v0.20.1-v0200-stale-wording-guard.sh
bash checks/verify-v0.20.1-v0200-probe-classification-evidence.sh
bash checks/verify-v0.20.1.sh
```

Focused tests:

```bash
swift test --filter TargetGraphTests/testGH1270ReleaseV0201V0200StaleWordingGuardRejectsCurrentFacingDrift
swift test --filter TargetGraphTests/testGH1271ReleaseV0201PublicProbeClassificationEvidenceGuard
swift test --filter TargetGraphTests/testGH1272ReleaseV0201PatchAuditReleaseNotesCloseout
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## v0.21.0 Handoff

`V0201-004-V0210-DOWNSTREAM-CANARY-HANDOFF`

v0.21.0 Spot canary is downstream only. It must be separately planned, authorized, queued and preflighted before any canary implementation or promotion. This patch does not start v0.21.0, does not create v0.21.0 issues, and does not promote any v0.21.0 Todo.

## Patch Boundary

- `v0.20.1` 是 v0.20.0 后的 publication fact / wording / evidence classification patch closeout，不是新的 runtime release。
- `v0.20.0` tag remains fixed at `7f84999e8e4071fb71fdc802f895de81303bbcfd`。
- GH-1272 不创建、不移动、不重写任何 tag 或 GitHub Release。
- #1269..#1272 均按 GitHub fallback queue、WIP=1、dependency order 和 issue scope 单独执行；#1272 只处理 aggregate verifier、patch audit、release notes、validation matrix 和 publication guidance。
- GH-1243 public-market probe 是 classification evidence，不是 live transport proof。
- GH-1244 signed-account readiness 是 intent evidence，不是 account access proof 或 account payload retrieval。
- production trading 仍默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不进行 account payload retrieval。
- 不发送 submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
