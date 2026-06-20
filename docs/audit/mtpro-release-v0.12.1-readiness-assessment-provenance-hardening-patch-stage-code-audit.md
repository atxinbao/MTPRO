# MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch Stage Code Audit

日期：2026-06-20

执行者：Codex

## Scope

`MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch` 是 v0.12.0 public GitHub Release 发布后的 provenance hardening patch。它不新增 runtime pipeline，不发布新的 production capability，只把 v0.12.0 publication fact、readiness source commit provenance、本地 source-run evidence metadata、compare fail-closed 行为、生成后 JSON inspection 和本 Stage Code Audit / release notes 固定为可验证 evidence。

v0.12.1 不创建 `v0.12.1` tag，也不创建 `v0.12.1` GitHub Release，不移动、不覆盖、不重写既有 `v0.12.0` tag 或 GitHub Release；不发布新的 runtime pipeline；不推进 v0.13.0；不授权 production cutover。

## Issue / PR Evidence

| Issue | Scope | State | PR / merge evidence | Required checks |
| --- | --- | --- | --- | --- |
| `#988` | v0.12.0 release publication fact sync / stale wording guard | `CLOSED`, `done` | PR `#1006` merged at `2026-06-20T03:22:37Z`; merge commit `69591a5e76413dc2e5f6f1acbd2692934b6c478e` | `checks`, `linux-checks`, `dashboard-macos` SUCCESS |
| `#989` | explicit readiness source commit provenance | `CLOSED`, `done` | PR `#1007` merged at `2026-06-20T04:17:33Z`; merge commit `3232b1e93d6d03d5ffb1d5e27a905bb29a4113e6` | `checks`, `linux-checks`, `dashboard-macos` SUCCESS |
| `#990` | local evidence sourceRunID / artifact metadata binding | `CLOSED`, `done` | PR `#1008` merged at `2026-06-20T05:15:55Z`; merge commit `3b88d5774bca845c8ef07ae8a8ff5189fdc6342e` | `checks`, `linux-checks`, `dashboard-macos` SUCCESS |
| `#991` | readiness compare fail-closed on missing source-run evidence | `CLOSED`, `done` | PR `#1009` merged at `2026-06-20T06:18:17Z`; merge commit `25ea9aab0222a29767a1271f8d4ed41e04baae3c` | `checks`, `linux-checks`, `dashboard-macos` SUCCESS |
| `#992` | generated manifest JSON inspection guards | `CLOSED`, `done` | PR `#1010` merged at `2026-06-20T07:24:46Z`; merge commit `7233629a7df8a90d6d4c2fd438892e2393643dfa` | `checks`, `linux-checks`, `dashboard-macos` SUCCESS |
| `#993` | v0.12.1 patch audit / release notes closeout | this PR | This PR owns final v0.12.1 Stage Code Audit, release notes, latest verification summary sync, release publication boundary notes, root-doc patch facts and focused TargetGraph coverage | This PR must pass `checks`, `linux-checks`, `dashboard-macos` before merge |

## Evidence Chain

- `docs/audit/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-stage-code-audit.md`
- `docs/release/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-notes.md`
- `checks/verify-v0.12.1-release-fact-sync.sh`
- `checks/verify-v0.12.1-sourcecommit-provenance.sh`
- `checks/verify-v0.12.1-local-evidence-metadata.sh`
- `checks/verify-v0.12.1-compare-fail-closed.sh`
- `checks/verify-v0.12.1-json-inspection-guards.sh`
- `checks/verify-v0.12.1-patch-audit-release-notes.sh`
- `docs/release/release-publication-policy.md`
- `docs/validation/latest-verification-summary.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift::testGH993ReleaseV0121PatchAuditReleaseNotesCloseout`

Validation anchors:

- `GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES`
- `V0121-006-PATCH-AUDIT`
- `V0121-006-RELEASE-NOTES`
- `V0121-006-VALIDATION-SUMMARY`
- `V0121-006-NO-PRODUCTION-CUTOVER`
- `V0121-006-NO-TAG-OR-RELEASE-MOVE`

Carry-forward anchors:

- `GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD`
- `GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE`
- `GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA`
- `GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED`
- `GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS`

## Audit Findings Closed

| Finding | Closeout |
| --- | --- |
| v0.12.0 release fact wording needed durable stale wording protection after public publication | #988 fixed the four-gate release flow wording and guards the v0.12.0 release URL, peeled commit and publication timestamp. |
| Readiness assessment Manifest V2 still allowed placeholder-like source commit provenance | #989 requires real 40-hex source commit provenance from `MTPRO_READINESS_SOURCE_COMMIT` or local `git rev-parse --verify HEAD`, and rejects known placeholders. |
| Manifest sourceRunID and artifact metadata needed to bind to actual local evidence | #990 derives sourceRunID, artifact SHA and byte count from the generated local readiness-summary artifact. |
| Readiness compare could fabricate evidence from assessment IDs when source-run artifacts were missing | #991 makes compare fail closed before emitting a report if Manifest V2 or local source-run evidence is absent. |
| Readiness guard coverage needed generated JSON inspection, not just source anchors | #992 inspects generated registry, Manifest V2, readiness summary, bundle, bundle manifest, export output and compare output, and rejects placeholder provenance / production-enabled flags. |
| v0.12.1 patch needed final audit / release notes / root-doc fact sync | #993 adds this Stage Code Audit, release notes, latest verification summary, release publication policy note, root-doc patch facts and focused TargetGraph closeout test. |

## Release Publication Boundary

GH-993 is not a release publication gate. v0.12.1 is a patch closeout document and validation guard set. It does not create a `v0.12.1` tag, does not publish a `v0.12.1` GitHub Release, and does not move the existing `v0.12.0` tag / GitHub Release.

The v0.12.0 public GitHub Release remains:

- Release URL: `https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`
- Tag peeled commit: `25e31afd351db9a372db62222226b0a3db26c93a`
- Publication timestamp: `2026-06-20T01:11:22Z`
- Release type: stable, non-draft, non-prerelease

Any future v0.12.1 public release publication, if requested by the human owner, must be a separate explicit release publication gate. This Stage Code Audit is not that publication gate.

## Runtime Boundary Audit

The patch keeps these hard boundaries:

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `realOrderSubmissionEnabled=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `productionOMSImplemented=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`
- `approvalWorkflowBypassEnabled=false`
- `readinessApprovalConvertedToTradingPermission=false`

## Validation

Required local validation:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.12.1-patch-audit-release-notes.sh
bash checks/verify-v0.12.0.sh
bash checks/run.sh
```

`checks/verify-v0.12.1-patch-audit-release-notes.sh` anchors the final patch closeout evidence. `checks/run.sh` is the canonical full local gate and includes the v0.12.1 patch audit / release notes guard.

## Known Residual Risk

- v0.12.1 does not publish a public GitHub Release in this issue. If a patch release is desired, it must be explicitly requested as a separate release publication gate.
- v0.13.0 remains blocked until #993 PR merge, required checks success, issue closed / done, local `main == origin/main`, clean worktree, and a fresh WIP=1 queue preflight.
- Production cutover remains separately gated and unauthorized.

## Next Handoff

After #993 merges, Parent Codex must verify #988 through #993 are closed / done, open PR count is zero, open active issue count is zero, `main == origin/main`, and worktree clean. Only then may any future GitHub fallback queue be considered by a fresh Human-approved preflight; this audit does not promote any v0.13.0 issue.
