#!/usr/bin/env bash
set -euo pipefail

# GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE
# V0121-002-SOURCE-COMMIT-PROVENANCE
# V0121-002-PLACEHOLDER-SOURCE-COMMIT-REJECTION
# TVM-RELEASE-V0121-SOURCE-COMMIT-PROVENANCE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.12.1 source commit provenance guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

require_text_contains() {
  local text="$1"
  local expected="$2"

  grep -Fq "$expected" <<<"$text" || fail "output must contain: $expected"
}

CLI="Sources/MTPROCLI/main.swift"
STORE="Sources/ExecutionClient/FutureGate/ReleaseV0120ReadinessAssessmentRegistryStore.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLACEHOLDER_COMMIT="0123456789abcdef0123456789abcdef01234567"
ZERO_COMMIT="0000000000000000000000000000000000000000"
VALID_COMMIT="0354aeefc0b9f4c74ae8fa9cc80a60787b28860d"

for anchor in \
  "GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE" \
  "V0121-002-SOURCE-COMMIT-PROVENANCE" \
  "V0121-002-PLACEHOLDER-SOURCE-COMMIT-REJECTION" \
  "TVM-RELEASE-V0121-SOURCE-COMMIT-PROVENANCE"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$CLI" "MTPRO_READINESS_SOURCE_COMMIT"
require_file_contains "$CLI" "git\", \"rev-parse\", \"--verify\", \"HEAD"
require_file_contains "$CLI" "sourceCommitResolver"
reject_file_contains "$CLI" "$PLACEHOLDER_COMMIT"
require_file_contains "$STORE" "forbiddenSourceCommitPlaceholders"
require_file_contains "$STORE" "$PLACEHOLDER_COMMIT"
require_file_contains "$STORE" "$ZERO_COMMIT"
require_file_contains "$TESTS" "testGH989ReadinessSourceCommitProvenanceRejectsPlaceholdersAndAcceptsRealCommits"
require_file_contains "checks/verify-v0.12.0.sh" "bash checks/verify-v0.12.1-sourcecommit-provenance.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.12.1-sourcecommit-provenance.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.12.1-sourcecommit-provenance.sh"
require_file_contains "$READINESS" "Release v0.12.1 source commit provenance guard anchor"
require_file_contains "$LATEST" "v0.12.1 source commit provenance guard"

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-gh989-sourcecommit.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

assessment_id="gh-989-source-commit-provenance"

MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$assessment_id" >/dev/null

set +e
placeholder_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$PLACEHOLDER_COMMIT" \
  swift run mtpro readiness build "$assessment_id" 2>&1
)"
placeholder_status=$?
set -e

if [[ "$placeholder_status" -eq 0 ]]; then
  printf '%s\n' "$placeholder_output" >&2
  fail "placeholder source commit must fail readiness build"
fi
require_text_contains "$placeholder_output" "mtpro.readiness.sourceCommit"
require_text_contains "$placeholder_output" "$PLACEHOLDER_COMMIT"

build_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness build "$assessment_id"
)"
require_text_contains "$build_output" "sourceCommit=$VALID_COMMIT"
require_text_contains "$build_output" "readinessBundleWritten=true"
require_text_contains "$build_output" "boundaryHeld=true"

validate_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness validate "$assessment_id"
)"
require_text_contains "$validate_output" "manifestHeld=true"
require_text_contains "$validate_output" "validationState=valid"
require_text_contains "$validate_output" "boundaryHeld=true"

grep -R -Fq "$VALID_COMMIT" "$tmp_root" || fail "local readiness artifacts must contain the accepted source commit"
if grep -R -Fq "$PLACEHOLDER_COMMIT" "$tmp_root"; then
  fail "local readiness artifacts must not contain placeholder source commit"
fi

swift test --filter TargetGraphTests/testGH989ReadinessSourceCommitProvenanceRejectsPlaceholdersAndAcceptsRealCommits

echo "MTPRO release v0.12.1 source commit provenance guard verification passed."
