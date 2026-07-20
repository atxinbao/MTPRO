#!/usr/bin/env bash
set -euo pipefail

# GH-1270-VERIFY-V0201-V0200-STALE-WORDING-GUARD
# V0201-002-V0200-STALE-WORDING-GUARD
# V0201-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST
# TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD
# V0201-002-CURRENT-FACING-STALE-WORDING-REJECTION
# V0201-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.20.1 v0.20.0 stale wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

assert_regex_matches() {
  local sample="$1"

  if ! printf '%s\n' "$sample" | grep -Eiq "$STALE_V0200_WORDING"; then
    printf 'release v0.20.1 v0.20.0 stale wording guard failed: stale sample was not rejected: %s\n' "$sample" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0200_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches=""
  local line_number
  local line

  while IFS=: read -r line_number line; do
    [[ -n "${line_number:-}" ]] || continue

    if [[ "$line" == *"reject_unqualified_stale_v0200_wording"* ]] ||
      [[ "$line" == *"assert_regex_matches"* ]] ||
      [[ "$line" == *"STALE_V0200_WORDING"* ]] ||
      [[ "$line" == *"GH-1270-VERIFY-V0201-V0200-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0201-002-V0200-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0201-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST"* ]] ||
      [[ "$line" == *"TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0201-002-CURRENT-FACING-STALE-WORDING-REJECTION"* ]] ||
      [[ "$line" == *"stale wording guard"* ]]; then
      continue
    fi

    if {
      [[ "$line" == *"#1250"* ]] ||
        [[ "$line" == *"GH-1250"* ]] ||
        [[ "$line" == *"V0200-012-NO-TAG-OR-RELEASE-PUBLICATION"* ]] ||
        [[ "$line" == *"historical construction closeout"* ]] ||
        [[ "$line" == *"historical closeout evidence"* ]] ||
        [[ "$line" == *"construction closeout evidence"* ]] ||
        [[ "$line" == *"后续独立 Release Publication Gate 已发布"* ]] ||
        [[ "$line" == *"The later independent Release Publication Gate has published"* ]]
    } &&
      grep -Fq -- "$V0200_RELEASE_URL" "$file" &&
      grep -Fq -- "$V0200_TARGET_COMMIT" "$file" &&
      grep -Fq -- "$V0200_PUBLICATION_TIMESTAMP" "$file"; then
      continue
    fi

    matches+="${line_number}:${line}"$'\n'
  done < <(grep -Ein "$forbidden_regex" "$file" || true)

  if [[ -n "$matches" ]]; then
    printf 'release v0.20.1 v0.20.0 stale wording guard failed: %s contains current-facing stale v0.20.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-notes.md"
AUDIT="docs/audit/mtpro-release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-stage-code-audit.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0200_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.20.0"
V0200_TARGET_COMMIT="7f84999e8e4071fb71fdc802f895de81303bbcfd"
V0200_PUBLICATION_TIMESTAMP="2026-06-30T16:55:24Z"
STALE_V0200_WORDING='v0[.]20[.]0.{0,240}(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|no[- ]tag */ *no[- ]release|no tag / no release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|no[- ]tag */ *no[- ]release|no tag / no release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]20[.]0'

assert_regex_matches "v0.20.0 release pending"
assert_regex_matches "v0.20.0 GitHub Release not created"
assert_regex_matches "v0.20.0 no-tag / no-release current fact"
assert_regex_matches "待发布 v0.20.0"

for file in \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$NOTES" \
  "$AUDIT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1270-VERIFY-V0201-V0200-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0201-002-V0200-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0201-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST"
  require_file_contains "$file" "TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0201-002-CURRENT-FACING-STALE-WORDING-REJECTION"
  require_file_contains "$file" "V0201-002-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0200_RELEASE_URL"
  require_file_contains "$file" "$V0200_TARGET_COMMIT"
  require_file_contains "$file" "$V0200_PUBLICATION_TIMESTAMP"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$POLICY" "$NOTES" "$AUDIT" "$VERIFICATION"; do
  reject_unqualified_stale_v0200_wording "$file" "$STALE_V0200_WORDING"
done

require_file_contains "$READINESS" "Release v0.20.1 v0.20.0 stale wording guard anchor"
require_file_contains "$PLAN" "GH-1270 Release v0.20.1 v0.20.0 Stale Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD"
require_file_contains "$POLICY" "GH-1270 rejects current-facing stale v0.20.0 publication wording"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.1-v0200-stale-wording-guard.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.1-v0200-stale-wording-guard.sh"
require_file_contains "$TESTS" "testGH1270ReleaseV0201V0200StaleWordingGuardRejectsCurrentFacingDrift"

swift test --filter TargetGraphTests/testGH1270ReleaseV0201V0200StaleWordingGuardRejectsCurrentFacingDrift

echo "MTPRO release v0.20.1 v0.20.0 stale wording guard verification passed."
