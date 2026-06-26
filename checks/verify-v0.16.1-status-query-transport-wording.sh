#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.16.1 status query wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.16.1 status query wording guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift"
CONTRACT="docs/contracts/release-v0.16.0-binance-spot-testnet-order-status-query-contract.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1137ReleaseV0161StatusQueryTransportEvidenceWording

for file in \
  "$SOURCE" \
  "$CONTRACT" \
  "$READINESS" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$NOTES" \
  "$0" \
  "checks/run.sh" \
  "$TESTS"; do
  require_file_contains "$file" "GH-1137-VERIFY-V0161-STATUS-QUERY-TRANSPORT-WORDING"
  require_file_contains "$file" "TVM-RELEASE-V0161-STATUS-QUERY-TRANSPORT-WORDING"
  require_file_contains "$file" "V0161-005-REQUEST-EVIDENCE-FLAG-CLARIFIED"
  require_file_contains "$file" "V0161-005-TRANSPORT-RESULT-EVIDENCE-CLARIFIED"
  require_file_contains "$file" "V0161-005-NO-FAKE-STATUS-QUERY-WORDING"
  require_file_contains "$file" "V0161-005-NO-PRODUCTION-READINESS-OVERSTATEMENT"
done

require_file_contains "$SOURCE" "requestEvidenceNetworkStatusQueryPerformed=false"
require_file_contains "$SOURCE" "statusTransportResultEvidence=guarded-testnet-status-result"
require_file_contains "$SOURCE" "ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult"
require_file_contains "$CONTRACT" "networkStatusQueryPerformed=false"
require_file_contains "$CONTRACT" "guarded Testnet status transport result evidence"
require_file_contains "$POLICY" "request-construction evidence does not itself assert a network side effect"
require_file_contains "$LATEST" "guarded Testnet status transport result evidence"
require_file_contains "$NOTES" "request evidence flag"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.1-status-query-transport-wording.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.1-status-query-transport-wording.sh"

for file in "$CONTRACT" "$LATEST" "$PLAN" "$MATRIX" "$POLICY" "$NOTES"; do
  reject_file_contains "$file" "fake status query"
  reject_file_contains "$file" "mock status query"
  reject_file_contains "$file" "networkStatusQueryPerformed=false means no transport result"
  reject_file_contains "$file" "production readiness authorized"
done

echo "MTPRO release v0.16.1 status query transport wording verification passed."
