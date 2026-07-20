#!/usr/bin/env bash
set -euo pipefail

# GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING
# V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD
# TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING
# V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL
# V0191-002-CURRENT-RELEASE-PUBLISHED
# V0191-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.19.1 v0.19.0 historical closeout wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.19.1 v0.19.0 historical closeout wording guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
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
  require_file_contains "$file" "GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING"
  require_file_contains "$file" "V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD"
  require_file_contains "$file" "TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING"
  require_file_contains "$file" "V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL"
  require_file_contains "$file" "V0191-002-CURRENT-RELEASE-PUBLISHED"
  require_file_contains "$file" "V0191-002-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "$V0190_RELEASE_URL"
  require_file_contains "$file" "$V0190_TARGET_COMMIT"
  require_file_contains "$file" "$V0190_PUBLICATION_TIMESTAMP"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$POLICY" "$NOTES" "$AUDIT"; do
  require_file_contains "$file" "historical construction closeout"
  require_file_contains "$file" "stable GitHub Release"
  require_file_contains "$file" "production cutover not authorized"
  require_file_absent "$file" "v0.19.0 tag pending"
  require_file_absent "$file" "v0.19.0 release pending"
  require_file_absent "$file" "v0.19.0 GitHub Release not created"
  require_file_absent "$file" "productionCutoverAuthorized=true"
done

require_file_absent "$README" "Latest completed v0.19.0 construction closeout"
require_file_absent "$BLUEPRINT" "Release v0.19.0 closeout anchor："
require_file_absent "$ROADMAP" "Completed GitHub fallback queue is \`MTPRO Release v0.19.0"
require_file_absent "$NOTES" "- #1215 is construction closeout only."
require_file_absent "$NOTES" "- #1215 does not create \`v0.19.0\` tag."
require_file_absent "$NOTES" "- #1215 does not create GitHub Release."
require_file_absent "$AUDIT" "后续若需要发布 \`v0.19.0\`"
require_file_absent "$AUDIT" "本 Stage Code Audit 不创建 tag 或 GitHub Release。"
require_file_absent "$POLICY" "If Human later requests \`v0.19.0\` publication"

require_file_contains "$README" "Latest v0.19.1 historical closeout wording guard"
require_file_contains "$GOAL" "v0.19.1 historical closeout wording guard"
require_file_contains "$BLUEPRINT" "Release v0.19.1 historical closeout wording anchor"
require_file_contains "$ROADMAP" "GH-1233 uses"
require_file_contains "$LATEST" "v0.19.1 historical closeout wording guard"
require_file_contains "$READINESS" "Release v0.19.1 v0.19.0 historical closeout wording guard anchor"
require_file_contains "$PLAN" "GH-1233 Release v0.19.1 v0.19.0 Historical Closeout Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.1-v0190-historical-closeout-wording.sh"
require_file_contains "$TESTS" "testGH1233ReleaseV0191V0190HistoricalCloseoutWordingGuard"

swift test --filter TargetGraphTests/testGH1233ReleaseV0191V0190HistoricalCloseoutWordingGuard

echo "MTPRO release v0.19.1 v0.19.0 historical closeout wording verification passed."
