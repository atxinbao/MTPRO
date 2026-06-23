#!/usr/bin/env bash
set -euo pipefail

# GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW
# TVM-RELEASE-V0150-CLI-OPERATOR-FLOW
# V0150-008-EXPLICIT-TESTNET-MODE
# V0150-008-OPERATOR-CONFIRMATION-REQUIRED
# V0150-008-REDACTED-OUTPUT
# V0150-008-NO-PRODUCTION-FALLBACK
# V0150-008-APPEND-ONLY-EVIDENCE-REFERENCE
# V0150-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.15.0 CLI operator flow guard failed: %s\n' "$1" >&2
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
    printf 'release v0.15.0 CLI operator flow guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.swift"
CLI="Sources/MTPROCLI/main.swift"
CONTRACT="docs/contracts/release-v0.15.0-cli-operator-flow-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1073ReleaseV0150CLIOperatorFlowRequiresExplicitTestnetConfirmation

# v0.15.1 wires the top-level `mtpro testnet-execution` command to the guarded
# runtime.  This v0.15.0 verifier now keeps the legacy parser/source contract
# anchored through its focused unit test; the current CLI smoke is covered by
# `checks/verify-v0.15.1-cli-testnet-execution-runtime.sh`.
require_file_contains "checks/verify-v0.15.1-cli-testnet-execution-runtime.sh" \
  "GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME"

for anchor in \
  "GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW" \
  "TVM-RELEASE-V0150-CLI-OPERATOR-FLOW" \
  "V0150-008-EXPLICIT-TESTNET-MODE" \
  "V0150-008-OPERATOR-CONFIRMATION-REQUIRED" \
  "V0150-008-REDACTED-OUTPUT" \
  "V0150-008-NO-PRODUCTION-FALLBACK" \
  "V0150-008-APPEND-ONLY-EVIDENCE-REFERENCE" \
  "V0150-008-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for required_string in \
  "ReleaseV0150BinanceSpotTestnetCLIOperatorFlow" \
  "ReleaseV0150BinanceSpotTestnetCLIOperatorInput" \
  "ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence" \
  "cliCommand=testnet-execution" \
  "explicitTestnetModeRequired=true" \
  "operatorConfirmationRequired=true" \
  "redactedOutputPrinted=true" \
  "noProductionFallback=true" \
  "appendOnlyChecksummedEvidenceRequired=true" \
  "existingGuardedRuntimeRequired=true" \
  "rawSecretPrinted=false" \
  "rawCredentialPrinted=false" \
  "rawOrderIdentityPrinted=false" \
  "rawBrokerPayloadPrinted=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretAutoRead=false" \
  "productionEndpointConnected=false" \
  "brokerEndpointConnected=false" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required_string"
  require_file_contains "$CONTRACT" "$required_string"
done

require_file_contains "$CLI" "ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.15.0-cli-operator-flow.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.15.0-cli-operator-flow.sh"
require_file_contains "$READINESS" "Release v0.15.0 CLI operator flow anchor"
require_file_contains "$LATEST" "v0.15.0 CLI operator flow"
require_file_contains "$PLAN" "GH-1073 Release v0.15.0 CLI Operator Flow"
require_file_contains "$MATRIX" "TVM-RELEASE-V0150-CLI-OPERATOR-FLOW"
require_file_contains "$TESTS" "testGH1073ReleaseV0150CLIOperatorFlowRequiresExplicitTestnetConfirmation"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretAutoRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$SOURCE" "$forbidden"
  reject_file_contains "$CONTRACT" "$forbidden"
done

printf 'MTPRO release v0.15.0 CLI operator flow verification passed.\n'
