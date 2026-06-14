#!/usr/bin/env bash
set -euo pipefail

# GH-779-VERIFY-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT
# TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 contract verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 contract verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md"

require_file_contains "$CONTRACT" "V070-001-NO-ORDER-RUNTIME-SESSION-CONTRACT"
require_file_contains "$CONTRACT" "V070-001-ALLOWED-MODES"
require_file_contains "$CONTRACT" "V070-001-CANONICAL-MODULE-SEQUENCE"
require_file_contains "$CONTRACT" "V070-001-EVIDENCE-ENVELOPE"
require_file_contains "$CONTRACT" "V070-001-DOWNSTREAM-QUEUE-ORDER"
require_file_contains "$CONTRACT" "V070-001-FORBIDDEN-CAPABILITIES"
require_file_contains "$CONTRACT" "TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT"
require_file_contains "$CONTRACT" "local-dry-run"
require_file_contains "$CONTRACT" "testnet-read-only-probe"
require_file_contains "$CONTRACT" "recovery-observe"
require_file_contains "$CONTRACT" "production-blocked"
require_file_contains "$CONTRACT" "GH-779..GH-792"
require_file_contains "$CONTRACT" "GH-780"
require_file_contains "$CONTRACT" "GH-792"
require_file_contains "$CONTRACT" "venue=Binance"
require_file_contains "$CONTRACT" "productTypes=spot,usdsPerpetual"
require_file_contains "$CONTRACT" "strategies=EMA,RSI"
require_file_contains "$CONTRACT" "noOrder=true"
require_file_contains "$CONTRACT" "productionTradingEnabledByDefault=false"
require_file_contains "$CONTRACT" "productionSecretRead=false"
require_file_contains "$CONTRACT" "productionEndpointConnected=false"
require_file_contains "$CONTRACT" "productionBrokerConnected=false"
require_file_contains "$CONTRACT" "productionOrderSubmitted=false"
require_file_contains "$CONTRACT" "productionCutoverAuthorized=false"
require_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=false"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-contract.sh"
require_file_contains "checks/automation-readiness.sh" "GH-779-VERIFY-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 no-order runtime session contract anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-779 Release v0.7.0 No-order Runtime Session Contract Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH779ReleaseV070NoOrderRuntimeSessionContractDefinesAllowedModesAndForbiddenCapabilities"

reject_file_contains "$CONTRACT" "productionTradingEnabledByDefault=true"
reject_file_contains "$CONTRACT" "productionSecretRead=true"
reject_file_contains "$CONTRACT" "productionEndpointConnected=true"
reject_file_contains "$CONTRACT" "productionBrokerConnected=true"
reject_file_contains "$CONTRACT" "productionOrderSubmitted=true"
reject_file_contains "$CONTRACT" "productionCutoverAuthorized=true"
reject_file_contains "$CONTRACT" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$CONTRACT" "api.binance.com"
reject_file_contains "$CONTRACT" "fapi.binance.com"

echo "MTPRO release v0.7.0 no-order runtime session contract verification passed."
