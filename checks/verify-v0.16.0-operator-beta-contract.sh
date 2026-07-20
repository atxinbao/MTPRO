#!/usr/bin/env bash
set -euo pipefail

# GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT
# TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT
# V0160-001-V0151-PREFLIGHT-GATE
# V0160-001-BINANCE-SPOT-TESTNET-ONLY
# V0160-001-OPERATOR-CONFIRMATION-REQUIRED
# V0160-001-REDACTED-EVIDENCE-REQUIRED
# V0160-001-QUEUE-ORDER
# V0160-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.16.0 operator beta contract guard failed: %s\n' "$1" >&2
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
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.16.0 operator beta contract guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorBetaContract.swift"
CONTRACT="docs/contracts/release-v0.16.0-binance-spot-testnet-operator-beta-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1101ReleaseV0160OperatorBetaContractBlocksProductionCutover

for file in "$SOURCE" "$CONTRACT" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT" \
    "TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT" \
    "V0160-001-V0151-PREFLIGHT-GATE" \
    "V0160-001-BINANCE-SPOT-TESTNET-ONLY" \
    "V0160-001-OPERATOR-CONFIRMATION-REQUIRED" \
    "V0160-001-REDACTED-EVIDENCE-REQUIRED" \
    "V0160-001-QUEUE-ORDER" \
    "V0160-001-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "ReleaseV0160OperatorBetaContract" \
  "ReleaseV0160OperatorBetaMode" \
  "ReleaseV0160OperatorBetaPreflightRequirement" \
  "ReleaseV0160OperatorBetaForbiddenCapability" \
  "GH-1101..GH-1112" \
  "GH-1100" \
  "Binance Spot Testnet" \
  'requiredAllowedProductTypes = ["spot"]' \
  "explicitOperatorConfirmationRequired" \
  "redactedEvidenceRequired" \
  "testnetCredentialValueReadEnabledByThisIssue == false" \
  "testnetNetworkConnectionEnabledByThisIssue == false" \
  "testnetOrderSubmissionImplementedByThisIssue == false" \
  "productionTradingEnabledByDefault == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

for child_issue in "#1102" "#1103" "#1104" "#1105" "#1106" "#1107" "#1108" "#1109" "#1110" "#1111" "#1112"; do
  require_file_contains "$CONTRACT" "$child_issue"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.16.0-operator-beta-contract.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.16.0-operator-beta-contract.sh"
require_file_contains "$TESTS" "testGH1101ReleaseV0160OperatorBetaContractBlocksProductionCutover"
require_file_contains "$README" "MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta"
require_file_contains "$GOAL" "MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta"
require_file_contains "$BLUEPRINT" "MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta"
require_file_contains "$ROADMAP" "GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT"
require_file_contains "$READINESS" "Release v0.16.0 operator beta contract anchor"
require_file_contains "$LATEST" "v0.16.0 operator beta contract"

for file in "$SOURCE" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "testnetCredentialValueReadEnabledByThisIssue=true"
  reject_file_contains "$file" "testnetNetworkConnectionEnabledByThisIssue=true"
  reject_file_contains "$file" "testnetOrderSubmissionImplementedByThisIssue=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

printf 'MTPRO release v0.16.0 operator beta contract verification passed.\n'
