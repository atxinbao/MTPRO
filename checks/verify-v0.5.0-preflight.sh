#!/usr/bin/env bash
set -euo pipefail

# GH-726-VERIFY-V050-BOUNDARY-PREFLIGHT
# TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 preflight verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 preflight verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH726ReleaseV050BoundaryPreflightContractDefinesGuardedRuntimeFoundation

require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" \
  "ReleaseV050ReleaseBoundaryPreflightContract"
require_file_contains \
  "docs/contracts/release-v0.5.0-release-boundary-preflight-contract.md" \
  "V050-01-RELEASE-BOUNDARY-PREFLIGHT-CONTRACT"
require_file_contains \
  "docs/contracts/release-v0.5.0-release-boundary-preflight-contract.md" \
  "V050-01-PREFLIGHT-REQUIREMENTS"
require_file_contains \
  "docs/contracts/release-v0.5.0-release-boundary-preflight-contract.md" \
  "TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-preflight.sh"
require_file_contains \
  "checks/verify-v0.4.0.sh" \
  "MTPRO release v0.4.0 unified runtime rehearsal validation suite passed."

reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "URLSession"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "URLRequest"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "api.binance.com"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "fapi.binance.com"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "submitOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "cancelOrder"
reject_file_contains "Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift" "replaceOrder"

echo "MTPRO release v0.5.0 boundary preflight verification passed."
