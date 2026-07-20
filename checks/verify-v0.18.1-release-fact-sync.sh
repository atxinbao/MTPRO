#!/usr/bin/env bash
set -euo pipefail

# GH-1200-VERIFY-V0181-V0180-RELEASE-FACT-SYNC
# V0181-001-V0180-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0181-V0180-RELEASE-FACT-SYNC
# V0181-001-V0180-TAG-FIXED
# V0181-001-PATCH-QUEUE-NOT-PUBLICATION
# V0181-001-V0180-STALE-WORDING-GUARD
# V0181-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.18.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.18.1 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0180_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches=""
  local line_number
  local line

  while IFS=: read -r line_number line; do
    [[ -n "${line_number:-}" ]] || continue

    if [[ "$line" == *"reject_unqualified_stale_v0180_wording"* ]] ||
      [[ "$line" == *"STALE_V0180_WORDING"* ]] ||
      [[ "$line" == *"GH-1200-VERIFY-V0181-V0180-RELEASE-FACT-SYNC"* ]] ||
      [[ "$line" == *"V0181-001-V0180-STALE-WORDING-GUARD"* ]] ||
      [[ "$line" == *"stale wording guard"* ]] ||
      [[ "$line" == *"GH-1200 rejects unqualified stale v0.18.0 publication wording"* ]]; then
      continue
    fi

    if {
      [[ "$line" == *"#1185"* ]] ||
        [[ "$line" == *"GH-1185"* ]] ||
        [[ "$line" == *"GH-1171"* ]] ||
        [[ "$line" == *"GH-1176"* ]] ||
        [[ "$line" == *"GH-1177"* ]] ||
        [[ "$line" == *"GH-1178"* ]] ||
        [[ "$line" == *"GH-1179"* ]] ||
        [[ "$line" == *"GH-1180"* ]] ||
        [[ "$line" == *"GH-1181"* ]] ||
        [[ "$line" == *"GH-1182"* ]] ||
        [[ "$line" == *"GH-1183"* ]] ||
        [[ "$line" == *"GH-1184"* ]] ||
        [[ "$line" == *"V0171-006-V0180-HANDOFF"* ]] ||
        [[ "$line" == *"V0180-"* ]] ||
        [[ "$line" == *"V0180-010-NO-TAG-OR-RELEASE-PUBLICATION"* ]] ||
        [[ "$line" == *"construction closeout evidence"* ]] ||
        [[ "$line" == *"historical construction closeout"* ]] ||
        [[ "$line" == *"本 Stage Code Audit 只记录 v0.18.0 construction closeout evidence"* ]]
    } &&
      grep -Fq "$V0180_RELEASE_URL" "$file" &&
      grep -Fq "$V0180_TARGET_COMMIT" "$file" &&
      grep -Fq "$V0180_PUBLICATION_TIMESTAMP" "$file"; then
      continue
    fi

    matches+="${line_number}:${line}"$'\n'
  done < <(grep -En "$forbidden_regex" "$file" || true)

  if [[ -n "$matches" ]]; then
    printf 'release v0.18.1 release fact sync guard failed: %s contains unqualified stale v0.18.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.18.0-venue-product-aware-operator-lifecycle-recovery-foundation-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.18.0-venue-product-aware-operator-lifecycle-recovery-foundation-notes.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

V0180_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0"
V0180_TARGET_COMMIT="cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9"
V0180_PUBLICATION_TIMESTAMP="2026-06-28T04:55:36Z"
STALE_V0180_WORDING='v0[.]18[.]0.{0,240}(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|does not create .*tag|does not create .*GitHub Release|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|GitHub Release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|does not create .*tag|does not create .*GitHub Release|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]18[.]0'

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
  require_file_contains "$file" "GH-1200-VERIFY-V0181-V0180-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0181-001-V0180-RELEASE-FACT-SYNC-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0181-V0180-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0181-001-V0180-TAG-FIXED"
  require_file_contains "$file" "V0181-001-PATCH-QUEUE-NOT-PUBLICATION"
  require_file_contains "$file" "V0181-001-V0180-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0181-001-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0180_RELEASE_URL"
  require_file_contains "$file" "$V0180_TARGET_COMMIT"
  require_file_contains "$file" "$V0180_PUBLICATION_TIMESTAMP"
  case "$file" in
  "$RUN_SCRIPT" | "$AUTOMATION_SCRIPT" | "$TESTS" | "$0")
    ;;
  *)
    reject_unqualified_stale_v0180_wording "$file" "$STALE_V0180_WORDING"
    ;;
  esac
done

require_file_contains "$READINESS" "Release v0.18.1 v0.18.0 release fact sync anchor"
require_file_contains "$PLAN" "GH-1200 Release v0.18.1 v0.18.0 Release Fact Sync Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0181-V0180-RELEASE-FACT-SYNC"
require_file_contains "$POLICY" "v0.18.1 是 v0.18.0 后的 Venue/Product Lifecycle Recovery CLI + Release Fact Patch queue"
require_file_contains "$POLICY" "GH-1200 不移动 \`v0.18.0\` tag"
require_file_contains "$POLICY" "GH-1200 rejects unqualified stale v0.18.0 publication wording"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.18.1-release-fact-sync.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.18.1-release-fact-sync.sh"
require_file_contains "$TESTS" "testGH1200ReleaseV0181V0180ReleaseFactSyncGuard"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$AUDIT" "$POLICY"; do
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.18.0 tag pending"
  require_file_absent "$file" "v0.18.0 release pending"
  require_file_absent "$file" "v0.18.0 GitHub Release not created"
  require_file_absent "$file" "productionCutoverAuthorized=true"
done

for file in "$NOTES" "$AUDIT" "$LATEST"; do
  require_file_absent "$file" "A future \`v0.18.0\` publication requires"
  require_file_absent "$file" "publication 必须由后续独立 Release Publication Gate"
done

swift test --filter TargetGraphTests/testGH1200ReleaseV0181V0180ReleaseFactSyncGuard

echo "MTPRO release v0.18.1 v0.18.0 release fact sync verification passed."
