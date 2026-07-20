#!/usr/bin/env bash
set -euo pipefail

# GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT
# TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT
# V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST
# V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT
# V0151-003-REDACTED-RESPONSE-DIGEST
# V0151-003-NO-SECRET-PERSISTENCE
# V0151-003-PRODUCTION-ENDPOINT-REJECTED
# V0151-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 URLSession Spot Testnet transport guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 URLSession Spot Testnet transport guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
POLICY="docs/release/release-publication-policy.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"

for anchor in \
  "GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT" \
  "TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT" \
  "V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST" \
  "V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT" \
  "V0151-003-REDACTED-RESPONSE-DIGEST" \
  "V0151-003-NO-SECRET-PERSISTENCE" \
  "V0151-003-PRODUCTION-ENDPOINT-REJECTED" \
  "V0151-003-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$POLICY" "$anchor"
done

for required in \
  "ReleaseV0151BinanceSpotTestnetURLSessionTransport" \
  "ReleaseV0151BinanceSpotTestnetURLSessionDataLoading" \
  "URLSession" \
  "URLRequest" \
  "testnet.binance.vision" \
  "/api/v3/order" \
  "api.binance.com" \
  "response-sha256" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required"
  require_file_contains "$0" "$required"
done

require_file_contains "$TESTS" "testGH1096ReleaseV0151URLSessionSpotTestnetTransportUsesAllowlistAndRedaction"
require_file_contains "$TESTS" "GH1096MockURLSessionDataLoader"
require_file_contains "$TESTS" "gh-1096-testnet-api-key"
require_file_contains "$TESTS" "gh-1096-testnet-secret"
require_file_contains "$TESTS" "productionHostForbidden(\"api.binance.com\")"
require_file_contains "$TESTS" "httpStatus(500)"

require_file_contains "$README" "#1096 已通过 \`GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT\`"
require_file_contains "$GOAL" "#1096 concrete URLSession Spot Testnet transport closed / done"
require_file_contains "$BLUEPRINT" "concrete URLSession Spot Testnet transport"
require_file_contains "$ROADMAP" "concrete URLSession transport"
require_file_contains "$LATEST" "v0.15.1 URLSession Spot Testnet transport"
require_file_contains "$POLICY" "V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST"
require_file_contains "$READINESS" "Release v0.15.1 URLSession Spot Testnet transport anchor"
require_file_contains "$PLAN" "GH-1096 Release v0.15.1 URLSession Spot Testnet Transport Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_absent "$file" "current issue \`#1095\`"
  require_file_absent "$file" "#1097..#1100 remain backlog / non-executable"
done

swift test --filter TargetGraphTests/testGH1096ReleaseV0151URLSessionSpotTestnetTransportUsesAllowlistAndRedaction

echo "MTPRO release v0.15.1 URLSession Spot Testnet transport verification passed."
