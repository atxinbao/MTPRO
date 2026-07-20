#!/usr/bin/env bash
set -euo pipefail

# GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED
# V0121-004-READINESS-COMPARE-FAIL-CLOSED
# V0121-004-MISSING-SOURCE-RUN-EVIDENCE
# V0121-004-NO-FABRICATED-COMPARE-EVIDENCE
# TVM-RELEASE-V0121-COMPARE-FAIL-CLOSED

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.12.1 compare fail-closed guard failed: %s\n' "$1" >&2
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
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
VALID_COMMIT="22fb2aff1fe706b9bfc32f3ecb2a1aa11228aa24"

for anchor in \
  "GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED" \
  "V0121-004-READINESS-COMPARE-FAIL-CLOSED" \
  "V0121-004-MISSING-SOURCE-RUN-EVIDENCE" \
  "V0121-004-NO-FABRICATED-COMPARE-EVIDENCE" \
  "TVM-RELEASE-V0121-COMPARE-FAIL-CLOSED"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$CLI" "requiredManifest(for:"
require_file_contains "$CLI" "readinessCompare:missingManifest"
require_file_contains "$CLI" "readinessCompare:missingSourceRunEvidence"
require_file_contains "$CLI" "localSourceRunEvidence(from:"
require_file_contains "$CLI" "sourceRunManifestChecksum"
require_file_contains "$CLI" "eventIDs"
require_file_contains "$CLI" "riskDecisionIDs"
require_file_contains "$CLI" "omsDryRunLifecycleIDs"
reject_file_contains "$CLI" 'Identifier.constant("\(entry.assessmentID.rawValue)-source-run")'
reject_file_contains "$CLI" 'source-run-manifest-\(entry.assessmentID.rawValue)"'
require_file_contains "checks/verify-v0.12.0.sh" "bash checks/verify-v0.12.1-compare-fail-closed.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.12.1-compare-fail-closed.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.12.1-compare-fail-closed.sh"
require_file_contains "$READINESS" "Release v0.12.1 compare fail-closed guard anchor"
require_file_contains "$LATEST" "v0.12.1 compare fail-closed guard"

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-gh991-compare.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

baseline_id="gh-991-baseline"
followup_id="gh-991-followup"

MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$followup_id" >/dev/null

set +e
missing_manifest_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness compare "$baseline_id" "$followup_id" 2>&1
)"
missing_manifest_status=$?
set -e
if [[ "$missing_manifest_status" -eq 0 ]]; then
  printf '%s\n' "$missing_manifest_output" >&2
  fail "compare-before-build must fail closed when manifest/source evidence is missing"
fi
require_text_contains "$missing_manifest_output" "nextRequiredAction=readiness export $baseline_id"
require_text_contains "$missing_manifest_output" "reason=exportMarkerMissing"

MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness build "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness build "$followup_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness validate "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness export "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness validate "$followup_id" >/dev/null

compare_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness compare "$baseline_id" "$followup_id"
)"
require_text_contains "$compare_output" "baselineAssessmentID=$baseline_id"
require_text_contains "$compare_output" "followUpAssessmentID=$followup_id"
require_text_contains "$compare_output" "comparedSections=policy,artifacts,risk-limits,kill-switch-state,approval-state,source-run-evidence"
require_text_contains "$compare_output" "compareDoesNotMutateAssessments=true"
require_text_contains "$compare_output" "operatorReviewOnly=true"
require_text_contains "$compare_output" "boundaryHeld=true"

rm "$tmp_root/assessments/$followup_id/artifacts/readiness-summary.json"
set +e
missing_artifact_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness compare "$baseline_id" "$followup_id" 2>&1
)"
missing_artifact_status=$?
set -e
if [[ "$missing_artifact_status" -eq 0 ]]; then
  printf '%s\n' "$missing_artifact_output" >&2
  fail "compare must fail closed when source-run artifact evidence is missing"
fi
require_text_contains "$missing_artifact_output" "localEvidenceArtifact:missing"

swift test --filter TargetGraphTests/testGH991ReadinessCompareFailsClosedWithoutSourceRunEvidence

echo "MTPRO release v0.12.1 compare fail-closed guard verification passed."
