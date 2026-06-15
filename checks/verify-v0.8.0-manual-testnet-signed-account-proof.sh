#!/usr/bin/env bash
set -euo pipefail

# GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF
# TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 manual testnet signed account proof verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 manual testnet signed account proof verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetSignedAccountProof.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH813ManualBinanceTestnetSignedAccountNetworkProofIsRedactedAndNoOrder

require_file_contains "Package.swift" "Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetSignedAccountProof.swift"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact"
require_file_contains "$SOURCE" "ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofWorkflow"
require_file_contains "$SOURCE" "networkAttempted"
require_file_contains "$SOURCE" "signedAccountSnapshotRead"
require_file_contains "$SOURCE" "manualOperatorNetworkProof"
require_file_contains "$SOURCE" "deterministicCIProof"
require_file_contains "$SOURCE" "ciRequiresNetwork"
require_file_contains "$SOURCE" "ciRequiresSecrets"
require_file_contains "$SOURCE" "redactedCredentialReference"
require_file_contains "$TESTS" "testGH813ManualBinanceTestnetSignedAccountNetworkProofIsRedactedAndNoOrder"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 manual testnet signed account proof anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF"
require_file_contains "$VALIDATION_PLAN" "GH-813 Release v0.8.0 Manual Testnet Signed Account Network Proof Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF"
require_file_contains "$CONTRACT" "V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF"

for anchor in \
  "GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF" \
  "TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF" \
  "V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF" \
  "V080-007-NETWORK-ATTEMPTED-AND-SNAPSHOT-READ" \
  "V080-007-REDACTED-CREDENTIAL-REFERENCE" \
  "V080-007-CI-DETERMINISTIC-NO-NETWORK-SECRET" \
  "V080-007-NO-TESTNET-ORDER-ROUTING" \
  "V080-007-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"
reject_file_contains "$SOURCE" "productionSecretRead = true"
reject_file_contains "$SOURCE" "productionEndpointConnected = true"

echo "MTPRO release v0.8.0 manual testnet signed account proof verification passed."
