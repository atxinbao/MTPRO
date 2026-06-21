#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0 failed: $file must contain: $expected" >&2
    exit 1
  fi
}

require_file_contains "Sources/DomainModel/OrderIntent.swift" "public struct OrderIntent"
require_file_contains "Sources/DomainModel/OrderIntent.swift" "requiresRiskEngineApproval"
require_file_contains "Sources/DomainModel/OrderIntent.swift" "authorizesProductionTrading"
require_file_contains "Sources/DomainModel/OrderIntent.swift" "productionTradingEnabledByDefault"
require_file_contains "Sources/DomainModel/OrderIntent.swift" "touchesBrokerEndpoint"
require_file_contains "Package.swift" "\"OrderIntent.swift\""
require_file_contains "docs/contracts/release-v0.14.0-order-intent-contract.md" "GH-1025-ORDERINTENT-CANONICAL-CONTRACT"
require_file_contains "docs/contracts/release-v0.14.0-order-intent-contract.md" "GH-1025-ORDERINTENT-RISK-GATE-BOUNDARY"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1025ReleaseV0140OrderIntentCanonicalContractRequiresRiskGateAndBoundary"

swift test --filter TargetGraphTests/testGH1025ReleaseV0140OrderIntentCanonicalContractRequiresRiskGateAndBoundary

echo "MTPRO release v0.14.0 OrderIntent contract verification passed."
