#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

require_file_not_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if grep -Fq "$needle" "$path"; then
    echo "forbidden '$needle' in $path" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170BetaSafetyPolicyProfileEvidence.swift"
CONTRACT="docs/contracts/release-v0.17.0-beta-safety-policy-profile-evidence-contract.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1147-VERIFY-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE"
  "TVM-RELEASE-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE"
  "V0170-009-ACTIVE-SAFETY-POLICY-PROFILE"
  "V0170-009-VENUE-PRODUCT-SYMBOL-LIMITS"
  "V0170-009-NOTIONAL-LIMIT-EVIDENCE"
  "V0170-009-ORDER-COUNT-LIMIT-EVIDENCE"
  "V0170-009-PRODUCTION-GUARD-STATE"
  "V0170-009-REDACTED-POLICY-EVIDENCE"
  "V0170-009-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$CONTRACT" \
  "README.md" \
  "GOAL.md" \
  "BLUEPRINT.md" \
  "docs/roadmap.md" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "checks/automation-readiness.sh" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "$SOURCE" "betaSafetyPolicyProfileEvidence=ReleaseV0170BetaSafetyPolicyProfileEvidence"
require_file_contains "$SOURCE" "activeSafetyPolicyProfileRecorded=true"
require_file_contains "$SOURCE" "venueLimitEvidenceRecorded=true"
require_file_contains "$SOURCE" "productLimitEvidenceRecorded=true"
require_file_contains "$SOURCE" "symbolLimitEvidenceRecorded=true"
require_file_contains "$SOURCE" "notionalLimitEvidenceRecorded=true"
require_file_contains "$SOURCE" "orderCountLimitEvidenceRecorded=true"
require_file_contains "$SOURCE" "productionGuardStateRecorded=true"
require_file_contains "$SOURCE" "ReleaseV0160BetaSafetyGuardEvidence"
require_file_contains "$CONTRACT" "#1147 / GH-1147"
require_file_contains "$CONTRACT" "active safety policy profile"
require_file_contains "checks/run.sh" "bash checks/verify-v0.17.0-beta-safety-policy-profile-evidence.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.17.0-beta-safety-policy-profile-evidence.sh"
require_file_contains "$TARGET_TESTS" "testGH1147ReleaseV0170BetaSafetyPolicyProfileEvidence"

for path in "$SOURCE" "$CONTRACT"; do
  require_file_not_contains "$path" "API Key:"
  require_file_not_contains "$path" "Secret Key:"
  require_file_not_contains "$path" "productionTradingEnabledByDefault=true"
  require_file_not_contains "$path" "productionCutoverAuthorized=true"
  require_file_not_contains "$path" "productionEndpointConnectionEnabled=true"
  require_file_not_contains "$path" "productionBrokerConnectionEnabled=true"
  require_file_not_contains "$path" "productionOrderSubmitCancelReplaceEnabled=true"
done

swift test --filter TargetGraphTests/testGH1147ReleaseV0170BetaSafetyPolicyProfileEvidence

echo "MTPRO release v0.17.0 beta safety policy profile evidence verification passed."
