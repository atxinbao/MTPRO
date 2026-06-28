# MTPRO Release v0.18.1 Venue/Product Lifecycle Recovery CLI + Release Fact Patch Stage Code Audit

日期：2026-06-28

执行者：Codex

## Project Scope

`MTPRO Release v0.18.1 Venue/Product Lifecycle Recovery CLI + Release Fact Patch` 是 v0.18.0 之后的 patch closeout。它只收口 v0.18.0 release fact sync、release full matrix publication evidence gate、operator-run CLI、artifact namespace paths、typed namespace model、aggregate verifier、release notes 和 audit evidence。

- GH-1205-VERIFY-V0181-AGGREGATE-AUDIT-RELEASE-NOTES
- TVM-RELEASE-V0181-AGGREGATE-AUDIT-RELEASE-NOTES
- V0181-006-AGGREGATE-GUARD
- V0181-006-PATCH-AUDIT
- V0181-006-RELEASE-NOTES
- V0181-006-VALIDATION-MATRIX
- V0181-006-PUBLICATION-GUIDANCE
- V0181-006-RELEASE-PUBLICATION-GATE-HANDOFF
- V0181-006-NO-PRODUCTION-CUTOVER
- V0181-006-NO-TAG-OR-RELEASE-PUBLICATION

## Issue Completion Evidence

| Issue | Scope | PR evidence | Merge evidence | Checks |
| --- | --- | --- | --- | --- |
| #1200 | v0.18.0 release fact sync | PR #1216 | `d83d6924e07962b4091d1287b85afd5e200688bc` | required `checks` SUCCESS |
| #1201 | release full matrix publication gate | PR #1217 | `2477bed0a762440b7da7ec1b00fb2665af9976cc` | required `checks` SUCCESS |
| #1202 | operator-run CLI commands | PR #1218 | `9cb8793ea70d79c0a74d9228642862c4b7aaf5cb` | required `checks` SUCCESS |
| #1203 | artifact namespace paths | PR #1219 | `5a5da2977307139fb4a943b17de1c029fbac56b2` | required `checks` SUCCESS |
| #1204 | typed namespace model | PR #1220 | `15c78c06c977a7e6f8b9ccf1dc475f0d1640ce13` | required `checks` SUCCESS |
| #1205 | aggregate audit / release notes | current closeout PR | pending until this PR merges | required `checks` must be SUCCESS before close |

## Validation Summary

本 Stage Code Audit 以 `checks/verify-v0.18.1.sh` 作为 v0.18.1 聚合 verifier。它串联以下 focused guard：

- `bash checks/verify-v0.18.1-release-fact-sync.sh`
- `bash checks/verify-v0.18.1-release-full-matrix-publication-gate.sh`
- `bash checks/verify-v0.18.1-operator-run-cli-commands.sh`
- `bash checks/verify-v0.18.1-artifact-namespace-paths.sh`
- `bash checks/verify-v0.18.1-typed-namespace-model.sh`
- `swift test --filter TargetGraphTests/testGH1205ReleaseV0181AggregateAuditReleaseNotesCloseout`

完整 PR 验证入口保持：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary Audit

v0.18.1 patch 不授权任何 production cutover。production cutover not authorized。

- production trading disabled by default
- no production secret read
- no production endpoint connection
- no production broker endpoint connection
- no production submit / cancel / replace
- no production order
- no VenueRegistry implementation
- no v0.19.0 implementation
- v0.19.0 is not started

## Publication Guidance

#1205 construction closeout itself does not create a tag or GitHub Release. Human 已明确提出 `v0.18.1` 发布诉求，但 publication 仍必须在 #1205 PR merged、required `checks` SUCCESS、`main == origin/main`、open PR = 0、open active issue = 0、worktree clean、validation evidence 和 release full matrix publication evidence 重新确认后，通过独立 Release Publication Gate 执行。

该 gate 不得移动 `v0.18.0` tag，不得覆盖已有 GitHub Release，不得跳过 linux checks / dashboard macOS / release publication checks evidence。

## Residual Risk

- tag / GitHub Release 仍是独立 publication gate，不由 #1205 PR 自动完成。
- release full matrix evidence 必须在 publication 前重新确认；普通 PR fast lane 不能替代 publication evidence。
- 若 tag / Release 已存在，后续 gate 不得移动、覆盖或重写，只能只读报告。

## Next Handoff

下一步只允许是独立 `v0.18.1 Release Publication Gate`，前提是 #1205 merged 且全部 gate 通过。不得推进 v0.19.0，不得创建下一 Project / Issue，不得授权 production cutover。
