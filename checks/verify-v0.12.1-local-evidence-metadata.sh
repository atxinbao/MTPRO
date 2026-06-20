#!/usr/bin/env bash
set -euo pipefail

# GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA
# V0121-003-LOCAL-EVIDENCE-SOURCERUNID
# V0121-003-ARTIFACT-BYTES-CHECKSUM
# V0121-003-MISSING-LOCAL-EVIDENCE-FAIL-CLOSED
# TVM-RELEASE-V0121-LOCAL-EVIDENCE-METADATA

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.12.1 local evidence metadata guard failed: %s\n' "$1" >&2
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
LATEST="docs/validation/latest-verification-summary.md"
VALID_COMMIT="22fb2aff1fe706b9bfc32f3ecb2a1aa11228aa24"

for anchor in \
  "GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA" \
  "V0121-003-LOCAL-EVIDENCE-SOURCERUNID" \
  "V0121-003-ARTIFACT-BYTES-CHECKSUM" \
  "V0121-003-MISSING-LOCAL-EVIDENCE-FAIL-CLOSED" \
  "TVM-RELEASE-V0121-LOCAL-EVIDENCE-METADATA"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$STORE" "forbiddenSourceRunIDPlaceholders"
require_file_contains "$STORE" "gh-963-source-run"
require_file_contains "$CLI" "writeLocalEvidenceArtifact"
require_file_contains "$CLI" "localEvidenceArtifactMetadata"
require_file_contains "$CLI" "ReleaseV060LocalRunJournalWriter.sha256Hex(data)"
require_file_contains "$CLI" "artifactEvidenceMatchesManifest"
reject_file_contains "$CLI" 'Identifier.constant("gh-963-source-run")'
reject_file_contains "$CLI" "artifactBytes: 512"
require_file_contains "checks/verify-v0.12.0.sh" "bash checks/verify-v0.12.1-local-evidence-metadata.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.12.1-local-evidence-metadata.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.12.1-local-evidence-metadata.sh"
require_file_contains "$READINESS" "Release v0.12.1 local evidence metadata guard anchor"
require_file_contains "$LATEST" "v0.12.1 local evidence metadata guard"

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-gh990-local-evidence.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

assessment_id="gh-990-local-evidence-metadata"
MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$assessment_id" >/dev/null

build_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness build "$assessment_id"
)"
require_text_contains "$build_output" "readinessBundleWritten=true"
require_text_contains "$build_output" "localEvidenceArtifactPath=.local/mtpro/readiness/assessments/$assessment_id/artifacts/readiness-summary.json"
require_text_contains "$build_output" "artifactSHA256=sha256:"
require_text_contains "$build_output" "artifactBytes="
require_text_contains "$build_output" "sourceRunIDs=source-run-"
require_text_contains "$build_output" "boundaryHeld=true"

artifact_path="$tmp_root/assessments/$assessment_id/artifacts/readiness-summary.json"
manifest_path="$tmp_root/assessments/$assessment_id/manifest-v2.json"
[[ -s "$artifact_path" ]] || fail "local evidence artifact must exist and be non-empty"
[[ -s "$manifest_path" ]] || fail "manifest-v2.json must exist"

python3 - "$artifact_path" "$manifest_path" <<'PY'
import hashlib
import json
import sys

artifact_path, manifest_path = sys.argv[1], sys.argv[2]
with open(artifact_path, "rb") as handle:
    artifact = handle.read()
with open(manifest_path, "r", encoding="utf-8") as handle:
    manifest = json.load(handle)

actual_sha = "sha256:" + hashlib.sha256(artifact).hexdigest()
actual_bytes = len(artifact)
expected_run_id = "source-run-" + actual_sha.removeprefix("sha256:")[:16]

if manifest["artifactSHA256"] != actual_sha:
    raise SystemExit(f"manifest artifactSHA256 mismatch: {manifest['artifactSHA256']} != {actual_sha}")
if manifest["artifactBytes"] != actual_bytes:
    raise SystemExit(f"manifest artifactBytes mismatch: {manifest['artifactBytes']} != {actual_bytes}")
if manifest["sourceRunIDs"] != [expected_run_id]:
    raise SystemExit(f"manifest sourceRunIDs mismatch: {manifest['sourceRunIDs']} != {[expected_run_id]}")
PY

validate_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness validate "$assessment_id"
)"
require_text_contains "$validate_output" "artifactEvidencePresent=true"
require_text_contains "$validate_output" "artifactEvidenceMatchesManifest=true"
require_text_contains "$validate_output" "validationState=valid"

rm "$artifact_path"
missing_output="$(
  MTPRO_READINESS_ROOT="$tmp_root" \
  MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" \
  swift run mtpro readiness validate "$assessment_id"
)"
require_text_contains "$missing_output" "artifactEvidencePresent=false"
require_text_contains "$missing_output" "artifactEvidenceMatchesManifest=false"
require_text_contains "$missing_output" "validationState=blocked"

swift test --filter TargetGraphTests/testGH990ReadinessLocalEvidenceMetadataBindsArtifactsAndSourceRunIDs

echo "MTPRO release v0.12.1 local evidence metadata guard verification passed."
