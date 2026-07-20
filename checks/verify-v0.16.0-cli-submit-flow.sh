#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
}

require_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "Missing required text in $file: $needle" >&2
    exit 1
  fi
}

require_absent() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    echo "Forbidden text found in $file: $needle" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH1103ReleaseV0160CLISubmitFlowUsesStableOperatorSubmitAndFailsClosed

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift"
require_file "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-submit-flow-contract.md"
require_file "checks/verify-v0.16.0-cli-submit-flow.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-submit-flow-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-cli-submit-flow.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW"
  require_contains "$file" "TVM-RELEASE-V0160-CLI-SUBMIT-FLOW"
  require_contains "$file" "V0160-003-STABLE-CLI-SUBMIT"
  require_contains "$file" "V0160-003-V0151-RUNTIME-DELEGATION"
  require_contains "$file" "V0160-003-EXPLICIT-OPERATOR-CONFIRMATION"
  require_contains "$file" "V0160-003-TESTNET-CREDENTIAL-PROFILE"
  require_contains "$file" "V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM"
  require_contains "$file" "V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED"
  require_contains "$file" "V0160-003-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "ReleaseV0160CLISubmitExecutionFlow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "cliCommand = ReleaseV0160OperatorBetaMode.spotTestnetSubmit.rawValue"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "missingGateCredentialConfirmationFailsClosed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "testnetRuntimeDelegated=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "testnetSubmitRuntimeAuthorizedByIssue=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" "productionCutoverAuthorized=false"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0160CLISubmitExecutionFlow.commandLineOutput"
require_contains "Sources/MTPROCLI/main.swift" "releaseV0160CLISubmitCommand"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1103ReleaseV0160CLISubmitFlowUsesStableOperatorSubmitAndFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-cli-submit-flow.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-cli-submit-flow.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-submit-flow-contract.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/release/release-publication-policy.md"; do
  require_absent "$file" "API Key:"
  require_absent "$file" "Secret Key:"
  require_absent "$file" "productionTradingEnabledByDefault=true"
  require_absent "$file" "productionCutoverAuthorized=true"
  require_absent "$file" "productionEndpointConnected=true"
  require_absent "$file" "brokerEndpointConnected=true"
  require_absent "$file" "productionOrderSubmitted=true"
done

echo "Release v0.16.0 CLI submit flow verification passed."
