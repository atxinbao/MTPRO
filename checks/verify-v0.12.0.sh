#!/usr/bin/env bash
set -euo pipefail

# GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
# TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
# V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT
# V0120-001-EVIDENCE-PROVENANCE-MODEL
# V0120-001-MULTI-ASSESSMENT-HISTORY
# V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES
# V0120-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.12.0 assessment-session contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.12.0 assessment-session contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.12.0-readiness-assessment-session-contract.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract

for anchor in \
  "GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT" \
  "V0120-001-EVIDENCE-PROVENANCE-MODEL" \
  "V0120-001-MULTI-ASSESSMENT-HISTORY" \
  "V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES" \
  "V0120-001-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "$CONTRACT" "assessmentSessionAllowed=true"
require_file_contains "$CONTRACT" "assessmentSessionLocalOnly=true"
require_file_contains "$CONTRACT" "assessmentSessionRequiresExplicitInput=true"
require_file_contains "$CONTRACT" "assessmentSessionMayReadLocalReadinessArtifacts=true"
require_file_contains "$CONTRACT" "assessmentSessionMayBuildDerivedReadModels=true"
require_file_contains "$CONTRACT" "assessmentSessionMayRecordHistory=true"
require_file_contains "$CONTRACT" "assessmentSessionMayComparePreviousAssessments=true"
require_file_contains "$CONTRACT" "assessmentSessionMayExportRedactedEvidence=true"
require_file_contains "$CONTRACT" "source issue / PR / check evidence reference"
require_file_contains "$CONTRACT" "canonical checksum / content hash reference"
require_file_contains "$CONTRACT" "baseline assessment"
require_file_contains "$CONTRACT" "follow-up assessment"
require_file_contains "$CONTRACT" "superseded assessment"
require_file_contains "$CONTRACT" "blocked assessment"
require_file_contains "$CONTRACT" "invalid assessment"
require_file_contains "$CONTRACT" "Production cutover 仍是独立 human-approved gate"
require_file_contains "$CONTRACT" "GH-952 V0120-001 Define v0.12.0 readiness assessment session no-authorization contract"
require_file_contains "$CONTRACT" "GH-965 V0120-014 Close v0.12.0 final audit docs and runbook"
require_file_contains "$READINESS" "Release v0.12.0 readiness assessment session no-authorization contract anchor"
require_file_contains "$PLAN" "GH-952 Release v0.12.0 Readiness Assessment Session No-authorization Contract Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT"
require_file_contains "$LATEST" "Release v0.12.0 Readiness Assessment Session Contract Snapshot"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.12.0.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.12.0.sh"
require_file_contains "$TESTS" "testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "realOrderSubmissionEnabled=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "productionOMSImplemented=true" \
  "tradingButtonEnabled=true" \
  "orderFormEnabled=true" \
  "liveCommandEnabled=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$READINESS" "$forbidden"
  reject_file_contains "$PLAN" "$forbidden"
  reject_file_contains "$MATRIX" "$forbidden"
done

echo "MTPRO release v0.12.0 readiness assessment session contract verification passed."
