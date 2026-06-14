#!/usr/bin/env bash
set -euo pipefail

# GH-733-VERIFY-V050-TESTNET-READONLY-INTEGRATION-GATE
# TVM-RELEASE-V050-TESTNET-READONLY-INTEGRATION-GATE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 testnet read-only verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 testnet read-only verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH733TestnetReadOnlyIntegrationGateRequiresExplicitProfileAndNoSubmitProof

require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "ReleaseV050TestnetReadOnlyIntegrationGate"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "ReleaseV050EnvironmentProfile"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "ReleaseV050EndpointPolicy"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "ReleaseV050SecretProfileRef"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "DataClient.BinanceSignedAccountReadSnapshot"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" \
  "DataClient.BinancePrivateStreamAccountSnapshotReadModel"
require_file_contains \
  "docs/contracts/release-v0.5.0-testnet-read-only-integration-gate-contract.md" \
  "V050-08-TESTNET-READ-ONLY-INTEGRATION-GATE"
require_file_contains \
  "docs/contracts/release-v0.5.0-testnet-read-only-integration-gate-contract.md" \
  "V050-08-EXPLICIT-TESTNET-PROFILE-REQUIRED"
require_file_contains \
  "docs/contracts/release-v0.5.0-testnet-read-only-integration-gate-contract.md" \
  "V050-08-PRODUCTION-BLOCKED-REJECTS-READMODEL-RESOLUTION"
require_file_contains \
  "docs/contracts/release-v0.5.0-testnet-read-only-integration-gate-contract.md" \
  "TVM-RELEASE-V050-TESTNET-READONLY-INTEGRATION-GATE"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-testnet-readonly.sh"

reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "URLSession"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "URLRequest"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "HMAC<"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "submitOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "cancelOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050TestnetReadOnlyIntegrationGate.swift" "replaceOrder"

echo "MTPRO release v0.5.0 testnet read-only integration gate verification passed."
