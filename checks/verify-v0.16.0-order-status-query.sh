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

swift test --filter TargetGraphTests/testGH1105ReleaseV0160SignedOrderStatusQueryUsesGETAllowlistAndRedaction

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift"
require_file "Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift"
require_file "docs/contracts/release-v0.16.0-binance-spot-testnet-order-status-query-contract.md"
require_file "checks/verify-v0.16.0-order-status-query.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" \
  "Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-order-status-query-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-order-status-query.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY"
  require_contains "$file" "TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY"
  require_contains "$file" "V0160-005-SIGNED-GET-ORDER-STATUS"
  require_contains "$file" "V0160-005-TESTNET-ENDPOINT-ALLOWLIST"
  require_contains "$file" "V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE"
  require_contains "$file" "V0160-005-NO-RAW-SECRET-PERSISTENCE"
  require_contains "$file" "V0160-005-PRODUCTION-HOST-REJECTED"
  require_contains "$file" "V0160-005-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "ReleaseV0160CLIOrderStatusQueryFlow"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "cliCommand = ReleaseV0160OperatorBetaMode.spotTestnetStatusQuery.rawValue"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "httpMethod = \"GET\""
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "sourceSubmitArtifactConsumed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "redactedOrderReferenceConsumed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "signedGETOrderStatusQueryPerformed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "redactedRequestResponseEvidence=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "productionHostRejected=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "missingPriorArtifactFailsClosed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" "productionCutoverAuthorized=false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift" "querySpotTestnetOrderStatus"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift" "method: signedRequest.httpMethod"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0160CLIOrderStatusQueryFlow.commandLineOutput"
require_contains "Sources/MTPROCLI/main.swift" "releaseV0160CLIOrderStatusQueryCommand"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1105ReleaseV0160SignedOrderStatusQueryUsesGETAllowlistAndRedaction"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-order-status-query.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-order-status-query.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift" \
  "Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-order-status-query-contract.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/release/release-publication-policy.md"; do
  require_absent "$file" "API Key:"
  require_absent "$file" "Secret Key:"
  require_absent "$file" "productionTradingEnabledByDefault=true"
  require_absent "$file" "productionCutoverAuthorized=true"
  require_absent "$file" "productionEndpointConnected=true"
  require_absent "$file" "brokerEndpointConnected=true"
  require_absent "$file" "productionOrderSubmitted=true"
done

echo "Release v0.16.0 order status query verification passed."
