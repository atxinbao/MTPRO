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

swift test --filter TargetGraphTests/testGH1102ReleaseV0160OperatorRunModelDefinesRunIDLifecycleAndFailsClosed

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift"
require_file "docs/contracts/release-v0.16.0-binance-spot-testnet-operator-run-model-contract.md"
require_file "checks/verify-v0.16.0-operator-run-model.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-operator-run-model-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-operator-run-model.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL"
  require_contains "$file" "TVM-RELEASE-V0160-OPERATOR-RUN-MODEL"
  require_contains "$file" "V0160-002-RUN-ID-LIFECYCLE"
  require_contains "$file" "V0160-002-ACTION-SEQUENCE"
  require_contains "$file" "V0160-002-ARTIFACT-LINKAGE"
  require_contains "$file" "V0160-002-INVALID-TRANSITION-FAILS-CLOSED"
  require_contains "$file" "V0160-002-REDACTED-METADATA"
  require_contains "$file" "V0160-002-NO-NETWORK-BY-THIS-ISSUE"
  require_contains "$file" "V0160-002-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "ReleaseV0160OperatorRunModel"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "ReleaseV0160OperatorRunMetadata"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "ReleaseV0160OperatorRunEvent"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "ReleaseV0160OperatorRunArtifactLink"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "requiredOperatorConfirmationPhrase"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" ".local/mtpro/v0.16.0/operator-runs"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "testnetCredentialValueReadEnabledByThisIssue == false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "testnetNetworkConnectionEnabledByThisIssue == false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "testnetOrderSubmissionImplementedByThisIssue == false"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" "productionCutoverAuthorized == false"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1102ReleaseV0160OperatorRunModelDefinesRunIDLifecycleAndFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-operator-run-model.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-operator-run-model.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift" \
  "docs/contracts/release-v0.16.0-binance-spot-testnet-operator-run-model-contract.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/release/release-publication-policy.md"; do
  require_absent "$file" "API Key:"
  require_absent "$file" "Secret Key:"
  require_absent "$file" "productionTradingEnabledByDefault=true"
  require_absent "$file" "productionCutoverAuthorized=true"
  require_absent "$file" "testnetNetworkPerformedByThisIssue=true"
  require_absent "$file" "testnetCredentialValueReadEnabledByThisIssue=true"
done

echo "Release v0.16.0 operator run model verification passed."
