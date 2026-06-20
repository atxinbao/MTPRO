# MTPRO Release v0.12.0 Readiness Assessment Sessions Operator Runbook

- Date: 2026-06-20
- Executor: Codex @002 / PAR
- Scope: v0.12.0 readiness assessment sessions, issues #952 至 #965
- Anchor: `GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK`

Anchor set:

- `GH-965-VERIFY-V0120-FINAL-AUDIT-DOCS-RUNBOOK`
- `GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK`
- `TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK`
- `V0120-014-STAGE-CODE-AUDIT`
- `V0120-014-RELEASE-NOTES`
- `V0120-014-OPERATOR-RUNBOOK`
- `V0120-014-ASSESSMENT-REGISTRY-SCHEMA`
- `V0120-014-MANIFEST-V2-SCHEMA`
- `V0120-014-PROVENANCE-CONTRACT`
- `V0120-014-ADVERSARIAL-VALIDATION-SUMMARY`
- `V0120-014-ROOT-DOCS-REFRESH`
- `V0120-014-AGGREGATE-VERIFY`
- `V0120-014-NO-PRODUCTION-CUTOVER`
- `V0120-014-NO-TAG-OR-RELEASE-MOVE`

## Purpose

This runbook tells an operator how to review v0.12.0 readiness assessment evidence locally. It is a review and validation guide only. It is not a production cutover guide.

## Release Publication Fact

- v0.12.0 GitHub Release 已完成发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`
- v0.12.0 peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`
- v0.12.0 publishedAt：`2026-06-20T01:11:22Z`
- This published fact does not authorize production cutover, production secret reads, production endpoint connection, broker endpoint connection or real orders.

## Preconditions

- #952 through #965 are closed / done after #965 PR merge.
- PR #973 through the #965 closure PR are merged with required checks success.
- Local `main` is fast-forwarded to `origin/main`.
- Worktree is clean.
- Production trading remains disabled by default.

## Verification Commands

Run the focused aggregate guard first:

```bash
bash checks/verify-v0.12.0.sh
```

Then run the standard local gates:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Assessment Evidence Checklist

- `V0120-014-ASSESSMENT-REGISTRY-SCHEMA`: registry evidence lives under `.local/mtpro/readiness/registry.json` and `.local/mtpro/readiness/assessments/<assessmentID>/`.
- `V0120-014-MANIFEST-V2-SCHEMA`: manifest evidence is assessment / generation scoped and uses canonical checksum fields.
- `V0120-014-PROVENANCE-CONTRACT`: every reviewable artifact is tied to issue, PR, check, merge commit, source run and checksum evidence.
- `V0120-014-ADVERSARIAL-VALIDATION-SUMMARY`: artifact redaction, immutable bundle, lock recovery, source snapshot mutation, quorum fail-closed and dashboard macOS guard coverage are all represented.
- `V0120-014-AGGREGATE-VERIFY`: `checks/verify-v0.12.0.sh` includes the #965 focused guard and is invoked by `checks/run.sh`.

## Dashboard Review

Dashboard assessment history remains read-model-only. Expected smoke evidence includes:

- `releaseV0120AssessmentHistoryRows=7`
- `releaseV0120AssessmentHistoryGenerations=3`
- `releaseV0120AssessmentHistoryAdversarialCases=7`
- `releaseV0120AssessmentHistoryBoundary=confirmed`

The Dashboard surface must not expose trading button, order form, live command, broker connection or production cutover controls.

## CLI Review

The v0.12.0 CLI lifecycle remains local-only:

```bash
mtpro readiness create <assessmentID>
mtpro readiness build <assessmentID>
mtpro readiness status <assessmentID>
mtpro readiness validate <assessmentID>
mtpro readiness export <assessmentID>
mtpro readiness archive <assessmentID>
mtpro readiness compare <baselineAssessmentID> <followUpAssessmentID>
```

Invalid assessment IDs must fail closed. Compare output is operator-review-only and must not mutate assessment registry metadata.

## Stop Rules

Stop and do not proceed if any of the following are observed:

- production trading enabled by default
- production secret read
- production endpoint or broker endpoint connection
- testnet or production order submit / cancel / replace
- production cutover authorization
- tag or GitHub Release movement in #965
- open PR or active queue conflict after closure

## Boundary

`V0120-014-NO-PRODUCTION-CUTOVER` and `V0120-014-NO-TAG-OR-RELEASE-MOVE` are mandatory. v0.12.0 readiness assessment sessions support local review only; production cutover, production broker connection and real orders remain separately gated and unauthorized.
