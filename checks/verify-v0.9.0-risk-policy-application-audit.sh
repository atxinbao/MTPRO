#!/usr/bin/env bash
set -euo pipefail

# GH-852-VERIFY-V090-RISK-POLICY-APPLICATION-AUDIT
# TVM-RELEASE-V090-RISK-POLICY-APPLICATION-AUDIT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 risk policy application audit verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 risk policy application audit verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH852RiskPolicyApplicationAuditBindsPolicyVersionHashAndMonitorArtifacts

require_file_contains "$SOURCE" "ReleaseV090RiskPolicyApplicationAuditReadModel"
require_file_contains "$SOURCE" "ReleaseV090RiskPolicyApplicationProfileReference"
require_file_contains "$SOURCE" "ReleaseV090RiskPolicyApplicationArtifactBinding"
require_file_contains "$SOURCE" "ReleaseV090RiskPolicyApplicationAuditArtifactRole"
require_file_contains "$SOURCE" "risk_policy_version"
require_file_contains "$SOURCE" "risk_policy_hash"
require_file_contains "$SOURCE" "policy_applied_at"
require_file_contains "$SOURCE" "operator_change_reference"
require_file_contains "$SOURCE" "risk-policy-application-audit.json"
require_file_contains "$SOURCE" "recordRiskPolicyApplicationAudit"
require_file_contains "$SOURCE" "riskPolicyApplicationAudit"
require_file_contains "$TARGET_TESTS" "testGH852RiskPolicyApplicationAuditBindsPolicyVersionHashAndMonitorArtifacts"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-risk-policy-application-audit.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 Risk policy application audit anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-852-VERIFY-V090-RISK-POLICY-APPLICATION-AUDIT"
require_file_contains "$VALIDATION_PLAN" "GH-852 Release v0.9.0 Risk Policy Application Audit Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-RISK-POLICY-APPLICATION-AUDIT"
require_file_contains "$CONTRACT" "V090-010-RISK-POLICY-APPLICATION-AUDIT"

for anchor in \
  "GH-852-VERIFY-V090-RISK-POLICY-APPLICATION-AUDIT" \
  "TVM-RELEASE-V090-RISK-POLICY-APPLICATION-AUDIT" \
  "V090-010-RISK-POLICY-APPLICATION-AUDIT" \
  "V090-010-RISK-POLICY-VERSION-HASH" \
  "V090-010-POLICY-APPLIED-AT" \
  "V090-010-OPERATOR-CHANGE-REFERENCE" \
  "V090-010-MONITOR-SESSION-EVIDENCE-BINDING" \
  "V090-010-LOCAL-PROFILE-EVIDENCE" \
  "V090-010-NO-POLICY-DRIVEN-ORDER-EXECUTION" \
  "V090-010-NO-BROKER-PRODUCTION-PATH" \
  "V090-010-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "policyChangeIsOrderAuthorization=true"
reject_file_contains "$SOURCE" "automatedPolicyDrivenOrderExecution=true"
reject_file_contains "$SOURCE" "brokerOrProductionPathEnabled=true"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "brokerEndpointConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"

echo "MTPRO release v0.9.0 risk policy application audit verification passed."
