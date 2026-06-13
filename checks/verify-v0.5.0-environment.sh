#!/usr/bin/env bash
set -euo pipefail

# GH-728-VERIFY-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY
# TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 environment verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 environment verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH728EnvironmentEndpointSecretPolicyFailsClosed

require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" \
  "ReleaseV050EnvironmentEndpointSecretPolicyContract"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" \
  "ReleaseV050EndpointPolicy"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" \
  "ReleaseV050SecretProfileRef"
require_file_contains \
  "docs/contracts/release-v0.5.0-environment-endpoint-secret-policy-contract.md" \
  "V050-03-ENVIRONMENT-PROFILE-ENDPOINT-SECRET-POLICY"
require_file_contains \
  "docs/contracts/release-v0.5.0-environment-endpoint-secret-policy-contract.md" \
  "V050-03-TESTNET-HTTPS-ALLOWLIST-POLICY"
require_file_contains \
  "docs/contracts/release-v0.5.0-environment-endpoint-secret-policy-contract.md" \
  "TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-environment.sh"

reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "URLSession"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "URLRequest"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "submitOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "cancelOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "replaceOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift" "HMAC<"

echo "MTPRO release v0.5.0 environment endpoint secret policy verification passed."
