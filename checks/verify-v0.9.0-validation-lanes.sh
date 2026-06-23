#!/usr/bin/env bash
set -euo pipefail

# GH-854-VERIFY-V090-VALIDATION-LANES
# TVM-RELEASE-V090-VALIDATION-LANES

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 validation lanes verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 validation lanes verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

markdown_section() {
  local file="$1"
  local heading="$2"

  awk -v heading="$heading" '
    $0 == heading {
      in_section = 1
      print
      next
    }
    in_section && /^## / {
      exit
    }
    in_section {
      print
    }
  ' "$file"
}

reject_section_contains() {
  local file="$1"
  local heading="$2"
  local forbidden="$3"

  local matches
  matches="$(markdown_section "$file" "$heading" | grep -F "$forbidden" || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 validation lanes verification failed: %s section %s must not contain: %s\n' "$file" "$heading" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV090TestnetReadOnlyMonitorSessionStore.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
RUNBOOK="docs/operators/release-v0.9.0-validation-lanes-runbook.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
WORKFLOW=".github/workflows/checks.yml"

swift test --filter TargetGraphTests/testGH854ValidationLanesKeepManualProofOutOfCIReplay

require_file_contains "$SOURCE" "ReleaseV090ValidationLaneSplitReadModel"
require_file_contains "$SOURCE" "ReleaseV090ValidationLanePolicy"
require_file_contains "$SOURCE" "manualProofCannotEnterCIReplay"
require_file_contains "$SOURCE" "manualProofCannotSatisfyRequiredChecks"
require_file_contains "$SOURCE" "workflowDispatchUsesDeterministicGuardsOnly"
require_file_contains "$SOURCE" "manualProofReplayableByCI"
require_file_contains "$SOURCE" "workflowDispatchCanInjectSecret"
require_file_contains "$RUNBOOK" "GH-854-RELEASE-V090-VALIDATION-LANES-RUNBOOK"
require_file_contains "$RUNBOOK" "manual proof cannot be replayed by CI"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 validation lanes hardening anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-854-VERIFY-V090-VALIDATION-LANES"
require_file_contains "$VALIDATION_PLAN" "GH-854 Release v0.9.0 Validation Lanes Hardening Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-VALIDATION-LANES"
require_file_contains "$WORKFLOW" "bash checks/run.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-validation-lanes.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH854ValidationLanesKeepManualProofOutOfCIReplay"

for anchor in \
  "GH-854-VERIFY-V090-VALIDATION-LANES" \
  "TVM-RELEASE-V090-VALIDATION-LANES" \
  "V090-012-VALIDATION-LANES" \
  "V090-012-DETERMINISTIC-CI-LANE" \
  "V090-012-MANUAL-OPERATOR-TESTNET-LANE" \
  "V090-012-MANUAL-PROOF-NOT-CI-REPLAYABLE" \
  "V090-012-CI-NO-NETWORK-SECRET-ORDER" \
  "V090-012-MANUAL-NO-ORDER-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$RUNBOOK" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "testnetOrderSubmissionAllowed=true" \
  "productionCutoverAuthorized=true" \
  "manualProofReplayableByCI=true" \
  "workflowDispatchCanInjectSecret=true" \
  "ciNetworkRequired=true" \
  "ciSecretRead=true" \
  "ciOrderSubmissionAllowed=true" \
  "api.binance.com" \
  "fapi.binance.com" \
  "/api/v3/order" \
  "/fapi/v1/order"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$RUNBOOK" "$forbidden"
  reject_section_contains "$VALIDATION_PLAN" "## GH-854 Release v0.9.0 Validation Lanes Hardening Validation" "$forbidden"
  reject_section_contains "$TRADING_MATRIX" "## TVM-RELEASE-V090-VALIDATION-LANES" "$forbidden"
done

for forbidden_ci_input in \
  "MTPRO_TESTNET_SIGNED_ACCOUNT_SECRET" \
  "MTPRO_TESTNET_LISTEN_KEY" \
  "manual-proof-reference"; do
  reject_file_contains "$WORKFLOW" "$forbidden_ci_input"
done

echo "MTPRO release v0.9.0 validation lanes verification passed."
