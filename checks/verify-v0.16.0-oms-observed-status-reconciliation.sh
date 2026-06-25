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

swift test --filter TargetGraphTests/testGH1107ReleaseV0160OMSObservedStatusReconciliationFromLocalArtifactsFailsClosed

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift"
require_file "docs/contracts/release-v0.16.0-oms-observed-status-reconciliation-contract.md"
require_file "checks/verify-v0.16.0-oms-observed-status-reconciliation.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" \
  "docs/contracts/release-v0.16.0-oms-observed-status-reconciliation-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-oms-observed-status-reconciliation.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1107-VERIFY-V0160-OMS-OBSERVED-STATUS-RECONCILIATION"
  require_contains "$file" "TVM-RELEASE-V0160-OMS-OBSERVED-STATUS-RECONCILIATION"
  require_contains "$file" "V0160-007-SUBMIT-OBSERVED-RECONCILIATION"
  require_contains "$file" "V0160-007-CANCEL-OBSERVED-RECONCILIATION"
  require_contains "$file" "V0160-007-UNKNOWN-STATUS-FAILS-CLOSED"
  require_contains "$file" "V0160-007-MISMATCH-FAILS-CLOSED"
  require_contains "$file" "V0160-007-LOCAL-ARTIFACTS-ONLY"
  require_contains "$file" "V0160-007-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "ReleaseV0160OMSObservedStatusReconciliationEngine"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "submitObservedReconciliation=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "cancelObservedReconciliation=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "unknownStatusFailsClosed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "mismatchFailsClosed=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" "localArtifactsOnly=true"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1107ReleaseV0160OMSObservedStatusReconciliationFromLocalArtifactsFailsClosed"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-oms-observed-status-reconciliation.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-oms-observed-status-reconciliation.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift" \
  "docs/contracts/release-v0.16.0-oms-observed-status-reconciliation-contract.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/release/release-publication-policy.md"; do
  require_absent "$file" "productionTradingEnabledByDefault=true"
  require_absent "$file" "productionCutoverAuthorized=true"
  require_absent "$file" "productionEndpointConnected=true"
  require_absent "$file" "brokerEndpointConnected=true"
  require_absent "$file" "productionOrderSubmitted=true"
done

echo "Release v0.16.0 OMS observed status reconciliation verification passed."
