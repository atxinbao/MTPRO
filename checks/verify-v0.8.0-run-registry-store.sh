#!/usr/bin/env bash
set -euo pipefail

# GH-809-VERIFY-V080-RUN-REGISTRY-STORE
# TVM-RELEASE-V080-RUN-REGISTRY-STORE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 run registry store verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 run registry store verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Database/ReleaseV080RunRegistryStore.swift"

swift test --filter TargetGraphTests/testGH809RunRegistryStorePersistsRegistryJSONChecksumAndFailClosedStates

require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryDocument"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryEntry"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryArtifactPaths"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStoreContract"
require_file_contains "$SOURCE" "GH-809-VERIFY-V080-RUN-REGISTRY-STORE"
require_file_contains "$SOURCE" "V080-003-REGISTRY-JSON-PATH"
require_file_contains "$SOURCE" "V080-003-REGISTRY-LOCK"
require_file_contains "$SOURCE" "V080-003-REGISTRY-CHECKSUM"
require_file_contains "$SOURCE" ".local/mtpro/runs/registry.json"
require_file_contains "$SOURCE" ".local/mtpro/runs/registry.lock"
require_file_contains "$SOURCE" "missingOrCorruptedRegistryFailsClosed"
require_file_contains "$SOURCE" "checksumMismatch"
require_file_contains "$SOURCE" "listRuns"
require_file_contains "$SOURCE" "inspect(runID:"
require_file_contains "$SOURCE" "archive("
require_file_contains "$SOURCE" "recover("
require_file_contains "Package.swift" "\"ReleaseV080RunRegistryStore.swift\""
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "V080-003-RUN-REGISTRY-STORE"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-run-registry-store.sh"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 persistent RunRegistryStore anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-809 Release v0.8.0 Persistent RunRegistryStore Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-RUN-REGISTRY-STORE"
require_file_contains "checks/automation-readiness.sh" "GH-809-VERIFY-V080-RUN-REGISTRY-STORE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH809RunRegistryStorePersistsRegistryJSONChecksumAndFailClosedStates"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionTradingEnabledByDefault=true"
reject_file_contains "$SOURCE" "productionSecretRead=true"
reject_file_contains "$SOURCE" "productionEndpointConnected=true"
reject_file_contains "$SOURCE" "productionBrokerConnected=true"
reject_file_contains "$SOURCE" "productionOrderSubmitted=true"
reject_file_contains "$SOURCE" "productionCutoverAuthorized=true"
reject_file_contains "$SOURCE" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed=true"

echo "MTPRO release v0.8.0 persistent RunRegistryStore verification passed."
