#!/usr/bin/env bash
set -euo pipefail

# GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD
# V0191-003-V0190-STALE-WORDING-GUARD
# V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST
# TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD
# V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION
# V0191-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.19.1 v0.19.0 stale wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

assert_regex_matches() {
  local sample="$1"

  if ! printf '%s\n' "$sample" | grep -Eiq "$STALE_V0190_WORDING"; then
    printf 'release v0.19.1 v0.19.0 stale wording guard failed: stale sample was not rejected: %s\n' "$sample" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0190_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches=""
  local line_number
  local line

  while IFS=: read -r line_number line; do
    [[ -n "${line_number:-}" ]] || continue

    if [[ "$line" == *"reject_unqualified_stale_v0190_wording"* ]] ||
      [[ "$line" == *"assert_regex_matches"* ]] ||
      [[ "$line" == *"STALE_V0190_WORDING"* ]] ||
      [[ "$line" == *"GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0191-003-V0190-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST"* ]] ||
      [[ "$line" == *"TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION"* ]] ||
      [[ "$line" == *"stale wording guard"* ]]; then
      continue
    fi

    if {
      [[ "$line" == *"#1215"* ]] ||
        [[ "$line" == *"GH-1215"* ]] ||
        [[ "$line" == *"GH-1233"* ]] ||
        [[ "$line" == *"V0190-010-NO-TAG-OR-RELEASE-PUBLICATION"* ]] ||
        [[ "$line" == *"historical construction closeout"* ]] ||
        [[ "$line" == *"historical closeout evidence"* ]] ||
        [[ "$line" == *"construction closeout evidence"* ]] ||
        [[ "$line" == *"Those no-tag / no-release statements are historical closeout evidence"* ]] ||
        [[ "$line" == *"后续独立 Release Publication Gate 已发布"* ]]
    } &&
      grep -Fq -- "$V0190_RELEASE_URL" "$file" &&
      grep -Fq -- "$V0190_TARGET_COMMIT" "$file" &&
      grep -Fq -- "$V0190_PUBLICATION_TIMESTAMP" "$file"; then
      continue
    fi

    matches+="${line_number}:${line}"$'\n'
  done < <(grep -Ein "$forbidden_regex" "$file" || true)

  if [[ -n "$matches" ]]; then
    printf 'release v0.19.1 v0.19.0 stale wording guard failed: %s contains current-facing stale v0.19.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-notes.md"
AUDIT="docs/audit/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-stage-code-audit.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0190_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0"
V0190_TARGET_COMMIT="53e9b1e81db075ef464b74f8f35c66ebd61ea03c"
V0190_PUBLICATION_TIMESTAMP="2026-06-29T13:42:34Z"
STALE_V0190_WORDING='v0[.]19[.]0.{0,240}(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|no[- ]tag */ *no[- ]release|no tag / no release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|no[- ]tag */ *no[- ]release|no tag / no release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]19[.]0'

assert_regex_matches "v0.19.0 release pending"
assert_regex_matches "v0.19.0 GitHub Release not created"
assert_regex_matches "v0.19.0 no-tag / no-release current fact"
assert_regex_matches "待发布 v0.19.0"

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
  require_file_contains "$file" "GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0191-003-V0190-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST"
  require_file_contains "$file" "TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION"
  require_file_contains "$file" "V0191-003-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0190_RELEASE_URL"
  require_file_contains "$file" "$V0190_TARGET_COMMIT"
  require_file_contains "$file" "$V0190_PUBLICATION_TIMESTAMP"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$READINESS" "$PLAN" "$MATRIX" "$POLICY" "$NOTES" "$AUDIT" "$VERIFICATION"; do
  reject_unqualified_stale_v0190_wording "$file" "$STALE_V0190_WORDING"
done

require_file_contains "$READINESS" "Release v0.19.1 v0.19.0 stale wording guard anchor"
require_file_contains "$PLAN" "GH-1234 Release v0.19.1 v0.19.0 Stale Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD"
require_file_contains "$POLICY" "GH-1234 rejects current-facing stale v0.19.0 publication wording"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.1-v0190-stale-wording-guard.sh"
require_file_contains "$TESTS" "testGH1234ReleaseV0191V0190StaleWordingGuardRejectsCurrentFacingDrift"

swift test --filter TargetGraphTests/testGH1234ReleaseV0191V0190StaleWordingGuardRejectsCurrentFacingDrift

echo "MTPRO release v0.19.1 v0.19.0 stale wording guard verification passed."
