#!/usr/bin/env bash
set -euo pipefail

# GH-878-VERIFY-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT
# TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.10.0-production-readiness-contract.md"

require_file_contains "$CONTRACT" "V0100-001-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT"
require_file_contains "$CONTRACT" "V0100-001-READINESS-ASSESSMENT-NOT-CUTOVER"
require_file_contains "$CONTRACT" "V0100-001-DOWNSTREAM-QUEUE-ORDER"
require_file_contains "$CONTRACT" "V0100-001-FORBIDDEN-CAPABILITIES"
require_file_contains "$CONTRACT" "V0100-001-RELEASE-VALIDATION-MATRIX"
require_file_contains "$CONTRACT" "TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT"
require_file_contains "$CONTRACT" "GH-878-VERIFY-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT"
require_file_contains "$CONTRACT" "release version 固定为 \`v0.10.0\`"
require_file_contains "$CONTRACT" "GH-878..GH-891"
require_file_contains "$CONTRACT" "productionReadinessAssessmentAllowed=true"
require_file_contains "$CONTRACT" "productionCutoverRequiresSeparateApproval=true"
require_file_contains "$CONTRACT" "readinessEvidenceOnly=true"
require_file_contains "$CONTRACT" "manualApprovalEvidenceAllowed=true"
require_file_contains "$CONTRACT" "readinessDashboardReadModelAllowed=true"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "$CONTRACT" "productionSecretRead=false"
require_file_contains "$CONTRACT" "productionEndpointConnected=false"
require_file_contains "$CONTRACT" "productionBrokerConnected=false"
require_file_contains "$CONTRACT" "productionOrderSubmitted=false"
require_file_contains "$CONTRACT" "realOrderSubmissionEnabled=false"
require_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=false"
require_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=false"
require_file_contains "$CONTRACT" "readiness assessment 允许"
require_file_contains "$CONTRACT" "不是“生产切换”"
require_file_contains "$CONTRACT" "WIP=1"
require_file_contains "$CONTRACT" "testGH878ReleaseV0100ProductionReadinessContractDoesNotAuthorizeCutover"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-contract.sh"
require_file_contains "checks/automation-readiness.sh" "GH-878-VERIFY-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.10.0 production readiness no-authorization contract anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-878 Release v0.10.0 Production Readiness No-authorization Contract Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH878ReleaseV0100ProductionReadinessContractDoesNotAuthorizeCutover"

reject_file_contains "$CONTRACT" "productionTradingEnabledByDefault=true"
reject_file_contains "$CONTRACT" "productionCutoverAuthorized=true"
reject_file_contains "$CONTRACT" "productionSecretRead=true"
reject_file_contains "$CONTRACT" "productionEndpointConnected=true"
reject_file_contains "$CONTRACT" "productionBrokerConnected=true"
reject_file_contains "$CONTRACT" "productionOrderSubmitted=true"
reject_file_contains "$CONTRACT" "realOrderSubmissionEnabled=true"
reject_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$CONTRACT" "testnetOrderRoutingAllowed=true"
reject_file_contains "$CONTRACT" "api.binance.com"
reject_file_contains "$CONTRACT" "fapi.binance.com"
reject_file_contains "$CONTRACT" "orderFormEnabled=true"
reject_file_contains "$CONTRACT" "tradingButtonEnabled=true"

echo "MTPRO release v0.10.0 production readiness no-authorization contract verification passed."
