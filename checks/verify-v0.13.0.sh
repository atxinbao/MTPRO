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
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"

swift test --filter TargetGraphTests/testGH994ReleaseV0130LocalEvidenceReadinessEngineContract

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

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.13.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.13.0.sh"
require_file_contains "$READINESS" "Release v0.13.0 local evidence-driven readiness engine contract anchor"
require_file_contains "$PLAN" "GH-994 Release v0.13.0 Local Evidence-driven Readiness Engine Contract Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT"
require_file_contains "$LATEST" "v0.13.0 local evidence-driven readiness engine contract"
require_file_contains "$ROADMAP" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$GOAL" "release/v0.13.0"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine"
require_file_contains "$README" "release/v0.13.0"

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
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$LATEST" "$forbidden"
done

echo "MTPRO release v0.13.0 local evidence-driven readiness engine contract verification passed."
