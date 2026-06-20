#!/usr/bin/env bash
set -euo pipefail

# GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
# V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED
# V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN
# V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED
# V0130-001-NO-SYNTHETIC-READINESS-DATA
# V0130-001-NO-PRODUCTION-CUTOVER
# GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL
# TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL
# V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT
# V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS
# V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS
# V0130-002-MISSING-MALFORMED-FAILS-CLOSED
# V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER
# V0130-002-READ-ONLY-INTAKE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.13.0 local evidence readiness engine contract guard failed: %s\n' "$1" >&2
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

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.13.0 local evidence readiness engine contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.13.0-local-evidence-driven-readiness-engine-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0130LocalEvidenceIntakeModel.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"

swift test --filter TargetGraphTests/testGH994ReleaseV0130LocalEvidenceReadinessEngineContract
swift test --filter TargetGraphTests/testGH995ReleaseV0130LocalEvidenceIntakeModelDiscoversValidRootAndFailsClosed

for anchor in \
  "GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT" \
  "V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED" \
  "V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN" \
  "V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED" \
  "V0130-001-NO-SYNTHETIC-READINESS-DATA" \
  "V0130-001-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for anchor in \
  "GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL" \
  "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL" \
  "V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT" \
  "V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS" \
  "V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS" \
  "V0130-002-MISSING-MALFORMED-FAILS-CLOSED" \
  "V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER" \
  "V0130-002-READ-ONLY-INTAKE"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.13.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.13.0.sh"
require_file_contains "$READINESS" "Release v0.13.0 local evidence-driven readiness engine contract anchor"
require_file_contains "$READINESS" "Release v0.13.0 local evidence intake model anchor"
require_file_contains "$PLAN" "GH-994 Release v0.13.0 Local Evidence-driven Readiness Engine Contract Validation"
require_file_contains "$PLAN" "GH-995 Release v0.13.0 Local Evidence Intake Model Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL"
require_file_contains "$LATEST" "v0.13.0 local evidence-driven readiness engine contract"
require_file_contains "$LATEST" "v0.13.0 local evidence intake model"
require_file_contains "$ROADMAP" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$GOAL" "release/v0.13.0"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$README" "release/v0.13.0"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceIntakeModel"
require_file_contains "$SOURCE" "ReleaseV0130LocalEvidenceIntakeReport"
require_file_contains "$SOURCE" "run-logs/run-journal.jsonl"
require_file_contains "$SOURCE" "event-stream/events.jsonl"
require_file_contains "$SOURCE" "artifacts/artifact-index.json"
require_file_contains "$SOURCE" "registry/registry.json"
require_file_contains "$SOURCE" "prior-assessments/assessments-index.json"
require_file_contains "$CLI_SOURCE" "readiness intake <evidenceRoot>"
require_file_contains "$CLI_SOURCE" "intakeValid="
require_file_contains "$CLI_SOURCE" "failClosed="

for required_contract_string in \
  "artifact -> policy -> manifest -> bundle -> registry -> diff" \
  "local evidence root" \
  "real local evidence intake" \
  "sourceRunID" \
  "sourceCommit" \
  "generationID" \
  "compare-before-build" \
  "export-before-validate" \
  "synthetic readiness data" \
  "#995 至 #1005 必须继续被 #994 阻塞"; do
  require_file_contains "$CONTRACT" "$required_contract_string"
done

for required_intake_string in \
  "run logs / event stream / artifacts / registry / prior assessments" \
  "readiness intake <evidenceRoot>" \
  "missing local evidence root" \
  "malformed JSON / JSONL" \
  "read-only local intake diagnostics" \
  "不写 registry、不生成 bundle、不执行 diff"; do
  require_file_contains "$CONTRACT" "$required_intake_string"
done

fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT
mkdir -p \
  "$fixture_root/run-logs" \
  "$fixture_root/event-stream" \
  "$fixture_root/artifacts" \
  "$fixture_root/registry" \
  "$fixture_root/prior-assessments"

printf '%s\n' '{"sourceRunID":"run-gh995","sourceCommit":"8c3f87168d04f22d4cf21364963648f39f4aaf8e","eventType":"run.completed","createdAt":"2026-06-20T00:00:00Z"}' \
  >"$fixture_root/run-logs/run-journal.jsonl"
printf '%s\n' '{"eventID":"event-gh995","sourceRunID":"run-gh995","eventType":"risk.accepted","occurredAt":"2026-06-20T00:00:01Z"}' \
  >"$fixture_root/event-stream/events.jsonl"
printf '%s\n' '{"sourceRunID":"run-gh995","sourceCommit":"8c3f87168d04f22d4cf21364963648f39f4aaf8e","artifacts":[{"id":"artifact-gh995","path":"artifacts/readiness-summary.json"}]}' \
  >"$fixture_root/artifacts/artifact-index.json"
printf '%s\n' '{"registryVersion":"v0.13.0.local-evidence-intake","assessments":[{"assessmentID":"assessment-gh995"}]}' \
  >"$fixture_root/registry/registry.json"
printf '%s\n' '{"assessmentIDs":["baseline-gh995","followup-gh995"],"sourceRunIDs":["run-gh995"]}' \
  >"$fixture_root/prior-assessments/assessments-index.json"

cli_output="$(swift run mtpro readiness intake "$fixture_root")"
printf '%s\n' "$cli_output" | grep -Fq "issue=GH-995" || fail "CLI intake output must link GH-995"
printf '%s\n' "$cli_output" | grep -Fq "intakeValid=true" || fail "CLI intake output must validate complete local evidence root"
printf '%s\n' "$cli_output" | grep -Fq "failClosed=false" || fail "CLI intake output must not fail closed for valid fixture"
printf '%s\n' "$cli_output" | grep -Fq "localReadOnly=true" || fail "CLI intake output must remain read-only"
printf '%s\n' "$cli_output" | grep -Fq "assessmentOutputWritten=false" || fail "CLI intake output must not write assessment output"
printf '%s\n' "$cli_output" | grep -Fq "registryWritten=false" || fail "CLI intake output must not write registry"
printf '%s\n' "$cli_output" | grep -Fq "productionEndpointConnected=false" || fail "CLI intake output must not connect production endpoint"

rm "$fixture_root/registry/registry.json"
missing_output="$(swift run mtpro readiness intake "$fixture_root")"
printf '%s\n' "$missing_output" | grep -Fq "intakeValid=false" || fail "CLI intake output must fail invalid missing evidence"
printf '%s\n' "$missing_output" | grep -Fq "failClosed=true" || fail "CLI intake output must fail closed on missing evidence"
printf '%s\n' "$missing_output" | grep -Fq "missingDiagnosticCount=1" || fail "CLI intake output must expose missing evidence diagnostic"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

echo "MTPRO release v0.13.0 local evidence-driven readiness engine and intake verification passed."
