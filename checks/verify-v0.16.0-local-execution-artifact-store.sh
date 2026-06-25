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

swift test --filter TargetGraphTests/testGH1106ReleaseV0160LocalExecutionArtifactStorePersistsValidatesReplaysAndExports

require_file "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift"
require_file "docs/contracts/release-v0.16.0-local-execution-artifact-store-contract.md"
require_file "checks/verify-v0.16.0-local-execution-artifact-store.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" \
  "docs/contracts/release-v0.16.0-local-execution-artifact-store-contract.md" \
  "docs/automation/automation-readiness.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/verify-v0.16.0-local-execution-artifact-store.sh" \
  "Tests/TargetGraphTests/TargetGraphTests.swift"; do
  require_contains "$file" "GH-1106-VERIFY-V0160-LOCAL-EXECUTION-ARTIFACT-STORE"
  require_contains "$file" "TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE"
  require_contains "$file" "V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE"
  require_contains "$file" "V0160-006-CHECKSUM-MANIFEST"
  require_contains "$file" "V0160-006-CHECKSUM-MISMATCH-REJECTED"
  require_contains "$file" "V0160-006-REPLAY-VALIDATION"
  require_contains "$file" "V0160-006-REDACTED-EXPORT-BUNDLE"
  require_contains "$file" "V0160-006-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "ReleaseV0160LocalExecutionArtifactStore"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "appendOnlyArtifactPersistence=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "checksumManifestWritten=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "checksumMismatchRejected=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "replayValidationSupported=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "redactedExportBundleSupported=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" "submitCancelStatusReconciliationEvidenceSupported=true"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1106ReleaseV0160LocalExecutionArtifactStorePersistsValidatesReplaysAndExports"
require_contains "checks/run.sh" "bash checks/verify-v0.16.0-local-execution-artifact-store.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.16.0-local-execution-artifact-store.sh"

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift" \
  "docs/contracts/release-v0.16.0-local-execution-artifact-store-contract.md" \
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

echo "Release v0.16.0 local execution artifact store verification passed."
