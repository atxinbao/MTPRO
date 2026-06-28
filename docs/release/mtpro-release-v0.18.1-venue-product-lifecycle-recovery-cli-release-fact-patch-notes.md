# MTPRO Release v0.18.1 Venue/Product Lifecycle Recovery CLI + Release Fact Patch Notes

日期：2026-06-28

执行者：Codex

## Summary

v0.18.1 是 v0.18.0 之后的 patch closeout，覆盖 release fact sync、release full matrix publication gate、operator-run CLI、artifact namespace paths、typed namespace model、aggregate audit / release notes。它不新增 production runtime，不启动 v0.19.0，不授权 production cutover。

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

## v0.18.0 Publication Fact

v0.18.0 stable GitHub Release 已发布：

- Release URL: https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0
- Tag peeled commit: `cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9`
- Published at: `2026-06-28T04:55:36Z`

v0.18.1 不移动 `v0.18.0` tag，不覆盖 v0.18.0 GitHub Release。

## Patch Evidence

| Issue | PR | Evidence |
| --- | --- | --- |
| #1200 | PR #1216 | v0.18.0 release fact sync guard |
| #1201 | PR #1217 | release full matrix publication gate |
| #1202 | PR #1218 | operator-run CLI commands |
| #1203 | PR #1219 | artifact namespace paths |
| #1204 | PR #1220 | typed namespace model |
| #1205 | current closeout PR | aggregate audit / release notes / verifier |

## Release Notes Input

- `checks/verify-v0.18.1.sh` aggregates the v0.18.1 focused guards.
- release publication evidence must include the GH-1201 full matrix requirements.
- ordinary PR required `checks` remains fast lane and does not by itself authorize publication.
- #1205 construction closeout does not itself create a tag or GitHub Release.
- Human has explicitly requested v0.18.1 publication; publication still occurs only after #1205 merge through an independent Release Publication Gate.
- v0.19.0 is not started.

## Boundary

production cutover not authorized。

- production trading remains disabled by default
- no production secret read
- no production endpoint connection
- no production broker endpoint connection
- no production submit / cancel / replace
- no production order
- no VenueRegistry implementation
- no v0.19.0 implementation

## Publication Handoff

After #1205 merges, the only allowed next action for publishing is the independent `v0.18.1 Release Publication Gate`: confirm clean `main`, open PR = 0, open active issue = 0, worktree clean, validation evidence, release full matrix evidence, and then create / report the `v0.18.1` tag and GitHub Release without moving existing tags.
