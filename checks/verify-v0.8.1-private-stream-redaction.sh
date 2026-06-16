#!/usr/bin/env bash
set -euo pipefail

# GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION
# TVM-RELEASE-V081-PRIVATE-STREAM-REDACTION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 private stream redaction verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.1 private stream redaction verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/DataClient/Binance/TestnetReadOnlyProbe/ReleaseV080ManualTestnetPrivateStreamMonitoringProof.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
V080_PRIVATE_STREAM_SCRIPT="checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh"

swift test --filter TargetGraphTests/testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder

require_file_contains "$SOURCE" "import Crypto"
require_file_contains "$SOURCE" "listenKeyReferenceHash"
require_file_contains "$SOURCE" "listenKeyReferenceHash(_ reference: String)"
require_file_contains "$SOURCE" "redactedListenKeyStreamURL"
require_file_contains "$SOURCE" "redactedListenKeyPlaceholder"
require_file_contains "$SOURCE" "redactedStreamURL.contains(listenKeyReference) == false"
require_file_contains "$SOURCE" "redactedStreamURL.contains(redactedListenKeyReference) == false"
require_file_contains "$SOURCE" "redactedStreamURL.contains(\"listen-key:\") == false"
require_file_contains "$SOURCE" "SHA256.hash"
require_file_contains "$TESTS" "XCTAssertFalse(proof.redactedStreamURL.contains(sourceArtifact.listenKeyReference))"
require_file_contains "$TESTS" "XCTAssertFalse(proof.redactedStreamURL.contains(proof.redactedListenKeyReference))"
require_file_contains "$TESTS" "XCTAssertFalse(proof.redactedStreamURL.contains(\"listen-key:\"))"
require_file_contains "$TESTS" "XCTAssertTrue(proof.redactedStreamURL.contains(expectedListenKeyReferenceHash))"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1-private-stream-redaction.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.1 private stream redaction anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION"
require_file_contains "$VALIDATION_PLAN" "GH-840 Release v0.8.1 Private Stream Redaction Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V081-PRIVATE-STREAM-REDACTION"
require_file_contains "$CONTRACT" "V081-006-PRIVATE-STREAM-REDACTED-URL-HASH"
require_file_contains "$V080_PRIVATE_STREAM_SCRIPT" "GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION"

for anchor in \
  "GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION" \
  "TVM-RELEASE-V081-PRIVATE-STREAM-REDACTION" \
  "V081-006-PRIVATE-STREAM-REDACTED-URL-HASH" \
  "V081-006-NO-LISTENKEY-REFERENCE-IN-STREAM-URL" \
  "V081-006-NO-NETWORK-SECRET-ORDER-PATH"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "redactedStreamURL: sourceArtifact.redactedStreamURL"
reject_file_contains "$TESTS" "XCTAssertTrue(proof.redactedStreamURL.contains(sourceArtifact.listenKeyReference))"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"
reject_file_contains "$SOURCE" "productionSecretRead = true"
reject_file_contains "$SOURCE" "productionEndpointConnected = true"

echo "MTPRO release v0.8.1 private stream redaction verification passed."
