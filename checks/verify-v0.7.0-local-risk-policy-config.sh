#!/usr/bin/env bash
set -euo pipefail

# GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG
# TVM-RELEASE-V070-LOCAL-RISK-POLICY-CONFIG

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 local Risk policy config verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 local Risk policy config verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/RiskEngine/LiveGate/ReleaseV070LocalRiskPolicyConfig.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH789LocalRiskPolicyConfigPersistsReplayablePolicyAndDecisionEvidence

require_file_contains "$SOURCE" "ReleaseV070LocalRiskPolicyConfig"
require_file_contains "$SOURCE" "ReleaseV070LocalRiskPolicyEvidenceArtifact"
require_file_contains "$SOURCE" "ReleaseV070LocalRiskPolicyDecisionRecord"
require_file_contains "$SOURCE" "maxNotionalMinorUnits"
require_file_contains "$SOURCE" "maxExposureMinorUnits"
require_file_contains "$SOURCE" "killSwitchActive"
require_file_contains "$SOURCE" "noTradeActive"
require_file_contains "$SOURCE" "allowedSymbols"
require_file_contains "$SOURCE" "allowedProductTypes"
require_file_contains "$SOURCE" "ReleaseV050RiskEngineRuntimePolicy"
require_file_contains "$SOURCE" "ReleaseV070LocalRiskPolicyRunSessionEvidence"
require_file_contains "$SOURCE" "productionAccountDataRequired"
require_file_contains "$TESTS" "testGH789LocalRiskPolicyConfigPersistsReplayablePolicyAndDecisionEvidence"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-local-risk-policy-config.sh"
require_file_contains "docs/validation/validation-plan.md" \
  "GH-789 Release v0.7.0 Local Risk Policy Config Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-LOCAL-RISK-POLICY-CONFIG"
require_file_contains "docs/automation/automation-readiness.md" \
  "Release v0.7.0 local Risk policy config anchor"
require_file_contains "checks/automation-readiness.sh" \
  "GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG"

for anchor in \
  "GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG" \
  "TVM-RELEASE-V070-LOCAL-RISK-POLICY-CONFIG" \
  "V070-011-LOCAL-RISK-POLICY-FIELDS" \
  "V070-011-RISK-POLICY-ARTIFACTS-REPLAY" \
  "V070-011-KILL-SWITCH-NO-TRADE-BLOCKS-DOWNSTREAM" \
  "V070-011-ALLOWED-SYMBOLS-PRODUCT-TYPES" \
  "V070-011-NO-PRODUCTION-ACCOUNT-DATA"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "/api/v3/account"
reject_file_contains "$SOURCE" "/api/v3/order"
reject_file_contains "$SOURCE" "/api/v3/userDataStream"
reject_file_contains "$SOURCE" "listenKey"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"

echo "MTPRO release v0.7.0 local Risk policy config verification passed."
