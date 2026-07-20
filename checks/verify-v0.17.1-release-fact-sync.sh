#!/usr/bin/env bash
set -euo pipefail

# GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC
# GH-1170-VERIFY-V0171-V0170-STALE-WORDING-GUARD
# V0171-004-V0170-RELEASE-FACT-SYNC-GUARD
# V0171-005-V0170-STALE-WORDING-GUARD
# V0171-005-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST
# TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC
# TVM-RELEASE-V0171-V0170-STALE-WORDING-GUARD
# V0171-004-V0170-TAG-FIXED
# V0171-004-PATCH-QUEUE-NOT-PUBLICATION
# V0171-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.17.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.17.1 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0170_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches=""
  local line_number
  local line

  while IFS=: read -r line_number line; do
    [[ -n "${line_number:-}" ]] || continue

    if [[ "$line" == *"reject_unqualified_stale_v0170_wording"* ]] ||
      [[ "$line" == *"STALE_V0170_WORDING"* ]] ||
      [[ "$line" == *"GH-1170-VERIFY-V0171-V0170-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0171-005-V0170-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"stale wording guard: reject"* ]] ||
      [[ "$line" == *"verifier rejects stale v0.17.0 publication wording"* ]] ||
      [[ "$line" == *"GH-1170 rejects unqualified stale v0.17.0 publication wording"* ]]; then
      continue
    fi

    if {
      [[ "$line" == *"#1148"* ]] ||
        [[ "$line" == *"GH-1148"* ]] ||
        [[ "$line" == *"V0170-010-NO-TAG-OR-RELEASE-PUBLICATION"* ]] ||
        [[ "$line" == *"construction closeout evidence"* ]] ||
        [[ "$line" == *"本 Stage Code Audit 只记录 v0.17.0 construction closeout evidence"* ]] ||
        [[ "$line" == *"本 Stage Code Audit 不创建 tag"* ]] ||
        [[ "$line" == *"后续独立 Release Publication Gate 已显式发布"* ]]
    } &&
      grep -Fq "$V0170_RELEASE_URL" "$file" &&
      grep -Fq "$V0170_TARGET_COMMIT" "$file" &&
      grep -Fq "$V0170_PUBLICATION_TIMESTAMP" "$file"; then
      continue
    fi

    matches+="${line_number}:${line}"$'\n'
  done < <(grep -En "$forbidden_regex" "$file" || true)

  if [[ -n "$matches" ]]; then
    printf 'release v0.17.1 release fact sync guard failed: %s contains unqualified stale v0.17.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-notes.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0170_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0"
V0170_TARGET_COMMIT="c83879f80a525665c3484878d7071b1f5214da20"
V0170_PUBLICATION_TIMESTAMP="2026-06-27T06:37:33Z"
STALE_V0170_WORDING='v0[.]17[.]0.{0,240}(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]17[.]0'

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0171-004-V0170-RELEASE-FACT-SYNC-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0171-004-V0170-TAG-FIXED"
  require_file_contains "$file" "V0171-004-PATCH-QUEUE-NOT-PUBLICATION"
  require_file_contains "$file" "V0171-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0170_RELEASE_URL"
  require_file_contains "$file" "$V0170_TARGET_COMMIT"
  require_file_contains "$file" "$V0170_PUBLICATION_TIMESTAMP"
  case "$file" in
  "$RUN_SCRIPT" | "$AUTOMATION_SCRIPT" | "$TESTS" | "$0")
    ;;
  *)
    reject_unqualified_stale_v0170_wording "$file" "$STALE_V0170_WORDING"
    ;;
  esac
done

for file in "$READINESS" "$PLAN" "$MATRIX" "$POLICY" "$TESTS" "$AUTOMATION_SCRIPT" "$0"; do
  require_file_contains "$file" "GH-1170-VERIFY-V0171-V0170-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0171-005-V0170-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0171-005-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST"
  require_file_contains "$file" "TVM-RELEASE-V0171-V0170-STALE-WORDING-GUARD"
done

require_file_contains "$READINESS" "Release v0.17.1 v0.17.0 release fact sync anchor"
require_file_contains "$READINESS" "Release v0.17.1 v0.17.0 stale wording guard anchor"
require_file_contains "$PLAN" "GH-1169 Release v0.17.1 v0.17.0 Release Fact Sync Guard"
require_file_contains "$PLAN" "GH-1170 Release v0.17.1 v0.17.0 Stale Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC"
require_file_contains "$MATRIX" "TVM-RELEASE-V0171-V0170-STALE-WORDING-GUARD"
require_file_contains "$POLICY" "v0.17.1 是 v0.17.0 后的 artifact validation fail-closed patch queue"
require_file_contains "$POLICY" "GH-1169 不移动 \`v0.17.0\` tag"
require_file_contains "$POLICY" "GH-1170 rejects unqualified stale v0.17.0 publication wording"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1-release-fact-sync.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1-release-fact-sync.sh"
require_file_contains "$TESTS" "testGH1169ReleaseV0171V0170ReleaseFactSyncGuard"
require_file_contains "$TESTS" "testGH1170ReleaseV0171V0170StaleWordingGuardRejectsUnqualifiedPublicationDrift"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$AUDIT" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.17.0 tag pending"
  require_file_absent "$file" "v0.17.0 release pending"
  require_file_absent "$file" "v0.17.0 GitHub Release not created"
done

for file in "$NOTES" "$AUDIT" "$LATEST"; do
  require_file_absent "$file" "A future \`v0.17.0\` publication requires"
  require_file_absent "$file" "publication 必须由后续独立 Release Publication Gate"
done

swift test --filter TargetGraphTests/testGH1169ReleaseV0171V0170ReleaseFactSyncGuard
swift test --filter TargetGraphTests/testGH1170ReleaseV0171V0170StaleWordingGuardRejectsUnqualifiedPublicationDrift

echo "MTPRO release v0.17.1 v0.17.0 release fact sync verification passed."
