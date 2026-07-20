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

swift test --filter TargetGraphTests/testGH1104ReleaseV0160CLICancelFlowConsumesSubmitArtifactAndFailsClosed

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift"
require_file "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-cancel-flow-contract.md"
require_file "checks/verify-v0.16.0-cli-cancel-flow.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-cancel-flow-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-cli-cancel-flow.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW"
  require_contains "$file" "TVM-RELEASE-V0160-CLI-CANCEL-FLOW"
  require_contains "$file" "V0160-004-STABLE-CLI-CANCEL"
  require_contains "$file" "V0160-004-SUBMIT-ARTIFACT-IDENTITY"
  require_contains "$file" "V0160-004-V0151-RUNTIME-DELEGATION"
  require_contains "$file" "V0160-004-EXPLICIT-OPERATOR-CONFIRMATION"
  require_contains "$file" "V0160-004-TESTNET-CREDENTIAL-PROFILE"
  require_contains "$file" "V0160-004-REDACTED-ORDER-REFERENCE"
  require_contains "$file" "V0160-004-APPEND-ONLY-EVENT-EVIDENCE"
  require_contains "$file" "V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED"
  require_contains "$file" "V0160-004-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "ReleaseV0160CLICancelExecutionFlow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "cliCommand = ReleaseV0160OperatorBetaMode.spotTestnetCancel.rawValue"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "sourceSubmitArtifactConsumed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "redactedOrderReferenceConsumed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "appendOnlyEventEvidence=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "missingPriorArtifactFailsClosed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "testnetCancelRuntimeAuthorizedByIssue=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" "productionCutoverAuthorized=false"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0160CLICancelExecutionFlow.commandLineOutput"
require_contains "Sources/MTPROCLI/main.swift" "releaseV0160CLICancelCommand"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1104ReleaseV0160CLICancelFlowConsumesSubmitArtifactAndFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-cli-cancel-flow.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-cli-cancel-flow.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-cli-cancel-flow-contract.md" \
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

echo "Release v0.16.0 CLI cancel flow verification passed."
