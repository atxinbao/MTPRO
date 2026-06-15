#!/usr/bin/env bash
set -euo pipefail

# GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT
# TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 Risk policy profile management verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 Risk policy profile management verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/RiskEngine/LiveGate/ReleaseV080RiskPolicyProfileManagement.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH816RiskPolicyProfilesVersionHashDiffAndRunApplicationEvidence

SHOW_OUTPUT="$(swift run mtpro risk-policy show)"
VALIDATE_OUTPUT="$(swift run mtpro risk-policy validate)"
DIFF_OUTPUT="$(swift run mtpro risk-policy diff)"

printf '%s\n' "$SHOW_OUTPUT" | grep -Fq "profilePath=.local/mtpro/risk_policy.json"
printf '%s\n' "$SHOW_OUTPUT" | grep -Fq "policyHash=risk-policy-fnv64"
printf '%s\n' "$VALIDATE_OUTPUT" | grep -Fq "profileValid=true"
printf '%s\n' "$VALIDATE_OUTPUT" | grep -Fq "forbiddenCapabilityGate=held"
printf '%s\n' "$DIFF_OUTPUT" | grep -Fq "changedFields=profileVersion,maxNotionalMinorUnits,maxExposureMinorUnits,appliedRunIDs"
printf '%s\n' "$DIFF_OUTPUT" | grep -Fq "orderCommandPathEnabled=false"

for anchor in \
  "GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT" \
  "TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT" \
  "V080-010-RISK-POLICY-PROFILE-MANAGEMENT" \
  "V080-010-RISK-POLICY-JSON-VERSION-HASH" \
  "V080-010-DETERMINISTIC-POLICY-DIFF" \
  "V080-010-OPERATOR-CHANGE-METADATA" \
  "V080-010-RUN-APPLICATION-POLICY-REFERENCE" \
  "V080-010-CLI-SHOW-VALIDATE-DIFF" \
  "V080-010-NO-BROKER-ENDPOINT-OMS-ORDER-PATH"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CLI_SOURCE" "$anchor"
  require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

require_file_contains "$SOURCE" "ReleaseV080RiskPolicyProfile"
require_file_contains "$SOURCE" "ReleaseV080RiskPolicyProfileDiff"
require_file_contains "$SOURCE" "ReleaseV080RiskPolicyProfileRunApplicationEvidence"
require_file_contains "$SOURCE" "ReleaseV080RiskPolicyProfileManagementBuilder"
require_file_contains "$SOURCE" "risk_policy.json"
require_file_contains "$SOURCE" "risk-policy-fnv64-"
require_file_contains "$SOURCE" "operatorChangeMetadata"
require_file_contains "$SOURCE" "appliedRunIDs"
require_file_contains "$CLI_SOURCE" "riskPolicyOutput(arguments: arguments)"
require_file_contains "$CLI_SOURCE" "risk-policy show"
require_file_contains "$CLI_SOURCE" "risk-policy validate"
require_file_contains "$CLI_SOURCE" "risk-policy diff"
require_file_contains "$TESTS" "testGH816RiskPolicyProfilesVersionHashDiffAndRunApplicationEvidence"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-risk-policy-profiles.sh"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 Risk policy profile management anchor"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "/api/v3/account" \
  "/api/v3/order" \
  "/api/v3/userDataStream" \
  "listenKey" \
  "submitOrder" \
  "cancelOrder" \
  "replaceOrder" \
  "HMAC<" \
  "productionCutoverAuthorized = true"; do
  reject_file_contains "$SOURCE" "$forbidden"
done

echo "MTPRO release v0.8.0 Risk policy profile management verification passed."
