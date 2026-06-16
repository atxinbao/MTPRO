#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.8.1 local vs broker session verification failed: %s\n' "$1" >&2
  exit 1
}

require_output_contains() {
  local output="$1"
  local expected="$2"
  grep -Fq "$expected" <<<"$output" || fail "output must contain: $expected"
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" <<<"$output"; then
    fail "output must not contain: $forbidden"
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

RUNS_ROOT="$(mktemp -d)"
trap 'rm -rf "$RUNS_ROOT"' EXIT
export MTPRO_LOCAL_RUNS_ROOT="$RUNS_ROOT"

RUN_ID="gh-838-local-vs-broker-session"
GUARD_ANCHOR="GH-838-VERIFY-V081-LOCAL-VS-BROKER-SESSION"
VALIDATION_ANCHOR="TVM-RELEASE-V081-LOCAL-VS-BROKER-SESSION"
REQUIRED_ANCHORS=(
  "V081-004-LOCAL-SESSION-CREATED"
  "V081-004-BROKER-SESSION-NOT-STARTED"
  "V081-004-NO-AMBIGUOUS-SESSION-STARTED-FIELD"
  "V081-004-NO-ENDPOINT-BROKER-ORDER-PATH"
)

for anchor in "${REQUIRED_ANCHORS[@]}"; do
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
done

swift test --filter TargetGraphTests/testGH838TopLevelCLIRunSeparatesLocalSessionCreatedFromBrokerSessionStarted

run_output="$(swift run mtpro run --mode dry-run --run-id "$RUN_ID")"
require_output_contains "$run_output" "issue=GH-810"
require_output_contains "$run_output" "localSessionCreated=true"
require_output_contains "$run_output" "brokerSessionStarted=false"
require_output_contains "$run_output" "runID=$RUN_ID"
require_output_contains "$run_output" "productionTradingEnabledByDefault=false"
require_output_contains "$run_output" "productionSecretRead=false"
require_output_contains "$run_output" "productionEndpointConnected=false"
require_output_contains "$run_output" "productionOrderSubmitted=false"
require_output_contains "$run_output" "productionCutoverAuthorized=false"
reject_output_contains "$run_output" "sessionStarted=false"
reject_output_contains "$run_output" "productionTradingEnabledByDefault=true"
reject_output_contains "$run_output" "productionSecretRead=true"
reject_output_contains "$run_output" "productionEndpointConnected=true"
reject_output_contains "$run_output" "productionOrderSubmitted=true"
reject_output_contains "$run_output" "productionCutoverAuthorized=true"

status_output="$(swift run mtpro status "$RUN_ID")"
require_output_contains "$status_output" "mtpro status no-order-runtime-session"
require_output_contains "$status_output" "localSessionFound=true"
require_output_contains "$status_output" "sessionState=running"
require_output_contains "$status_output" "registryState=running"
reject_output_contains "$status_output" "brokerSessionStarted=true"

require_file_contains "Sources/MTPROCLI/main.swift" "brokerSessionStarted=false"
reject_file_contains "Sources/MTPROCLI/main.swift" "sessionStarted=false"
require_file_contains "checks/verify-v0.8.1-local-vs-broker-session.sh" "$GUARD_ANCHOR"
require_file_contains "checks/verify-v0.8.1-local-vs-broker-session.sh" "$VALIDATION_ANCHOR"
require_file_contains "checks/verify-v0.8.0-cli-local-session.sh" "brokerSessionStarted=false"
require_file_contains "checks/verify-v0.8.0-cli-local-session.sh" "sessionStarted=false"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.1 local vs broker session wording anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-838 Release v0.8.1 Local vs Broker Session Wording Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V081-LOCAL-VS-BROKER-SESSION"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH838TopLevelCLIRunSeparatesLocalSessionCreatedFromBrokerSessionStarted"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1-local-vs-broker-session.sh"

echo "MTPRO release v0.8.1 local vs broker session wording verification passed."
