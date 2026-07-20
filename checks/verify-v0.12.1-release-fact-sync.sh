#!/usr/bin/env bash
set -euo pipefail

# GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD
# V0121-001-RELEASE-FACT-SYNC-GUARD
# V0121-001-FOUR-GATE-RELEASE-FLOW
# TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.12.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0120_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches
  matches="$(grep -En "$forbidden_regex" "$file" \
    | grep -Fv '#965' \
    | grep -Fv 'GH-965' \
    | grep -Fv 'V0120-014-NO-TAG-OR-RELEASE-MOVE' \
    | grep -Fv 'reject_unqualified_stale_v0120_wording' \
    || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.12.1 release fact sync guard failed: %s contains unqualified stale v0.12.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
AUDIT="docs/audit/mtpro-release-v0.12.0-readiness-assessment-sessions-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.12.0-readiness-assessment-sessions-notes.md"
RUNBOOK="docs/operators/release-v0.12.0-readiness-assessment-sessions-runbook.md"

V0120_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0"
V0120_TARGET_COMMIT="25e31afd351db9a372db62222226b0a3db26c93a"
V0120_PUBLICATION_TIMESTAMP="2026-06-20T01:11:22Z"
STALE_V0120_WORDING='v0[.]12[.]0.{0,240}(publication pending|release pending|tag pending|release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]12[.]0'

for file in "$POLICY" "$PLAN" "$MATRIX" "$READINESS" "$README" "$ROADMAP" "$LATEST" "$AUDIT" "$NOTES" "$RUNBOOK"; do
  require_file_contains "$file" "v0.12.0"
  require_file_contains "$file" "$V0120_RELEASE_URL"
  require_file_contains "$file" "$V0120_TARGET_COMMIT"
  require_file_contains "$file" "$V0120_PUBLICATION_TIMESTAMP"
  reject_unqualified_stale_v0120_wording "$file" "$STALE_V0120_WORDING"
done

for file in "$GOAL" "$BLUEPRINT"; do
  require_file_contains "$file" "v0.12.0"
  reject_unqualified_stale_v0120_wording "$file" "$STALE_V0120_WORDING"
done

for anchor in \
  "GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD" \
  "V0121-001-RELEASE-FACT-SYNC-GUARD" \
  "V0121-001-FOUR-GATE-RELEASE-FLOW" \
  "TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD"; do
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "$anchor"
done

require_file_contains "$POLICY" "v0.12.0 的 construction closeout、Release Publication Gate、release fact sync / stale wording guard 和 production cutover 仍是独立 gate"
require_file_contains "$POLICY" "GH-988 / v0.12.1 stale wording guard 固定该 release fact"
require_file_contains "$PLAN" "GH-988 Release v0.12.1 Release Fact Sync / Stale Wording Guard Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD"
require_file_contains "$READINESS" "Release v0.12.1 release fact sync stale wording guard anchor"
require_file_contains "$LATEST" "v0.12.1 release fact stale wording guard"
require_file_contains "checks/automation-readiness.sh" "GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD"
require_file_contains "checks/verify-v0.12.0.sh" "bash checks/verify-v0.12.1-release-fact-sync.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.12.1-release-fact-sync.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH988ReleaseFactSyncGuardRejectsV0120StalePublicationWording"

for forbidden in \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true"; do
  reject_unqualified_stale_v0120_wording "$POLICY" "$forbidden"
  reject_unqualified_stale_v0120_wording "$READINESS" "$forbidden"
done

swift test --filter TargetGraphTests/testGH988ReleaseFactSyncGuardRejectsV0120StalePublicationWording

echo "MTPRO release v0.12.1 release fact sync stale wording guard verification passed."
