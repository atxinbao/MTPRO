#!/usr/bin/env bash
set -euo pipefail

# GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME
# TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME
# V0151-004-CLI-GUARDED-RUNTIME-INVOKED
# V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER
# V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME
# V0151-004-EXPLICIT-OPERATOR-CONFIRMATION
# V0151-004-REDACTED-OUTPUT
# V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED
# V0151-004-RUN-ID-ARTIFACT-CHECKSUM
# V0151-004-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 CLI testnet execution runtime guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 CLI testnet execution runtime guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift"
CLI="Sources/MTPROCLI/main.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"

for anchor in \
  "GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME" \
  "TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME" \
  "V0151-004-CLI-GUARDED-RUNTIME-INVOKED" \
  "V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER" \
  "V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME" \
  "V0151-004-EXPLICIT-OPERATOR-CONFIRMATION" \
  "V0151-004-REDACTED-OUTPUT" \
  "V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED" \
  "V0151-004-RUN-ID-ARTIFACT-CHECKSUM" \
  "V0151-004-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$POLICY" "$anchor"
done

for required in \
  "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow" \
  "ReleaseV0151BinanceSpotTestnetCLICredentialProvider" \
  "ReleaseV0151BinanceSpotTestnetCLIRuntimeResult" \
  "credentialProvider=testnet-env" \
  "guardedRuntimeInvoked=true" \
  "missingCredentialFailsClosed=true" \
  "artifactPathReturned=true" \
  "runIDReturned=true" \
  "checksumReturned=true" \
  "productionOrderSubmitted=false"; do
  require_file_contains "$SOURCE" "$required"
  require_file_contains "$0" "$required"
done

require_file_contains "$CLI" "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.commandLineOutput"
require_file_contains "$TESTS" "testGH1097ReleaseV0151CLITestnetExecutionInvokesGuardedRuntime"
require_file_contains "$TESTS" "GH1097RecordingSpotTestnetTransport"
require_file_contains "$TESTS" "missing testnet credential must fail closed"
require_file_contains "$TESTS" "production credential provider must fail closed"
require_file_contains "$README" "current issue \`#1097\`"
require_file_contains "$GOAL" "#1097 CLI guarded runtime wiring is current WIP=1"
require_file_contains "$BLUEPRINT" "CLI guarded runtime wiring"
require_file_contains "$ROADMAP" "CLI guarded runtime"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-cli-testnet-execution-runtime.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-cli-testnet-execution-runtime.sh"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_absent "$file" "current issue \`#1096\`"
  require_file_absent "$file" "#1097..#1100 remain backlog / non-executable"
done

swift test --filter TargetGraphTests/testGH1097ReleaseV0151CLITestnetExecutionInvokesGuardedRuntime

echo "MTPRO release v0.15.1 CLI testnet execution runtime verification passed."
