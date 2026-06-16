#!/usr/bin/env bash
set -euo pipefail

# GH-810-VERIFY-V080-CLI-LOCAL-SESSION
# TVM-RELEASE-V080-CLI-LOCAL-SESSION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_output_contains() {
  local output="$1"
  local expected="$2"

  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'release v0.8.0 CLI local session verification failed: output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" <<< "$output"; then
    printf 'release v0.8.0 CLI local session verification failed: output must not contain: %s\n' "$forbidden" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 CLI local session verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 CLI local session verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

expect_failure_contains() {
  local expected="$1"
  shift

  local output
  set +e
  output="$("$@" 2>&1)"
  local status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    printf 'release v0.8.0 CLI local session verification failed: command unexpectedly succeeded: %s\n' "$*" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi

  require_output_contains "$output" "$expected"
  reject_output_contains "$output" "productionOrderSubmitted=true"
  reject_output_contains "$output" "productionCutoverAuthorized=true"
}

RUNS_ROOT="$(mktemp -d)"
trap 'rm -rf "$RUNS_ROOT"' EXIT
export MTPRO_LOCAL_RUNS_ROOT="$RUNS_ROOT"

RUN_ID="gh-810-cli-local-session"

run_output="$(swift run mtpro run --mode dry-run --run-id "$RUN_ID")"
require_output_contains "$run_output" "issue=GH-810"
require_output_contains "$run_output" "persistentValidationAnchor=TVM-RELEASE-V080-CLI-LOCAL-SESSION"
require_output_contains "$run_output" "persistentVerificationAnchor=GH-810-VERIFY-V080-CLI-LOCAL-SESSION"
require_output_contains "$run_output" "localSessionCreated=true"
require_output_contains "$run_output" "brokerSessionStarted=false"
require_output_contains "$run_output" "runID=$RUN_ID"
require_output_contains "$run_output" "registryState=running"
require_output_contains "$run_output" "eventLogInitialized=true"
require_output_contains "$run_output" "manifestCreated=true"
require_output_contains "$run_output" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_output_contains "$run_output" "canonicalStatusArtifact=status.json"
require_output_contains "$run_output" "status.json=$RUNS_ROOT/$RUN_ID/status.json"
require_output_contains "$run_output" "compatibilityRunStatusArtifact=_RUN_STATUS.json"
reject_output_contains "$run_output" "sessionStarted=false"
reject_output_contains "$run_output" "productionOrderSubmitted=true"
reject_output_contains "$run_output" "productionCutoverAuthorized=true"

test -f "$RUNS_ROOT/registry.json"
test -f "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json"
test -f "$RUNS_ROOT/$RUN_ID/status.json"
test -f "$RUNS_ROOT/$RUN_ID/events.jsonl"
test -f "$RUNS_ROOT/$RUN_ID/manifest.json"

require_file_contains "$RUNS_ROOT/registry.json" '"issueID" : "GH-809"'
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"issueID" : "GH-810"'
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"state" : "running"'
require_file_contains "$RUNS_ROOT/$RUN_ID/events.jsonl" '\"issue\":\"GH-810\"'
require_file_contains "$RUNS_ROOT/$RUN_ID/events.jsonl" '\"action\":\"run\"'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" '"issueID" : "GH-810"'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" '"manifestFileName" : "manifest.json"'

status_output="$(swift run mtpro status "$RUN_ID")"
require_output_contains "$status_output" "mtpro status no-order-runtime-session"
require_output_contains "$status_output" "localSessionFound=true"
require_output_contains "$status_output" "sessionState=running"
require_output_contains "$status_output" "registryState=running"
require_output_contains "$status_output" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_output_contains "$status_output" "canonicalStatusArtifact=status.json"
require_output_contains "$status_output" "status.json=$RUNS_ROOT/$RUN_ID/status.json"
require_output_contains "$status_output" "compatibilityRunStatusArtifact=_RUN_STATUS.json"
require_output_contains "$status_output" "_RUN_STATUS.json=$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json"

stop_output="$(swift run mtpro stop "$RUN_ID")"
require_output_contains "$stop_output" "mtpro stop local-no-order-session"
require_output_contains "$stop_output" "sessionState=stopped"
require_output_contains "$stop_output" "registryState=stopped"
require_output_contains "$stop_output" "localSessionMutated=true"

status_after_stop="$(swift run mtpro status "$RUN_ID")"
require_output_contains "$status_after_stop" "sessionState=stopped"
require_output_contains "$status_after_stop" "registryState=stopped"
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"state" : "stopped"'

recover_output="$(swift run mtpro recover "$RUN_ID" --reason operator-reviewed)"
require_output_contains "$recover_output" "mtpro recover local-no-order-session"
require_output_contains "$recover_output" "sessionState=recovered"
require_output_contains "$recover_output" "registryState=recovered"
require_output_contains "$recover_output" "recoveryReason=operator-reviewed"

status_after_recover="$(swift run mtpro status "$RUN_ID")"
require_output_contains "$status_after_recover" "sessionState=recovered"
require_output_contains "$status_after_recover" "registryState=recovered"
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"state" : "recovered"'

expect_failure_contains "mtpro.stop.arguments" swift run mtpro stop
expect_failure_contains "mtpro.recover.arguments" swift run mtpro recover
expect_failure_contains "mtpro.run.production" swift run mtpro run --mode production

require_file_contains "Sources/MTPROCLI/main.swift" "ReleaseV080CLILocalSessionBinder"
require_file_contains "Sources/MTPROCLI/main.swift" "MTPRO_LOCAL_RUNS_ROOT"
require_file_contains "Sources/MTPROCLI/main.swift" "GH-810-VERIFY-V080-CLI-LOCAL-SESSION"
require_file_contains "Sources/MTPROCLI/main.swift" "TVM-RELEASE-V080-CLI-LOCAL-SESSION"
require_file_contains "Sources/MTPROCLI/main.swift" "mtpro stop local-no-order-session"
require_file_contains "Sources/MTPROCLI/main.swift" "mtpro recover local-no-order-session"
require_file_contains "Sources/MTPROCLI/main.swift" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_file_contains "Sources/MTPROCLI/main.swift" "canonicalStatusArtifact=status.json"
require_file_contains "Sources/MTPROCLI/main.swift" "compatibilityRunStatusArtifact=_RUN_STATUS.json"
require_file_contains "Sources/MTPROCLI/main.swift" "status.json"
require_file_contains "Sources/MTPROCLI/main.swift" "_RUN_STATUS.json"
require_file_contains "Sources/MTPROCLI/main.swift" "events.jsonl"
require_file_contains "Sources/MTPROCLI/main.swift" "manifest.json"
require_file_contains "Package.swift" "\"DomainModel\", \"Database\", \"DataClient\", \"Portfolio\""
require_file_contains ".gitignore" ".local/"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-cli-local-session.sh"
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "V080-004-CLI-LOCAL-SESSION-ACTIONS"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 CLI local session action anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-810 Release v0.8.0 CLI Local Session Action Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-CLI-LOCAL-SESSION"
require_file_contains "checks/automation-readiness.sh" "GH-810-VERIFY-V080-CLI-LOCAL-SESSION"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH810TopLevelCLICreatesAndMutatesPersistentLocalSessionArtifacts"

reject_file_contains "Sources/MTPROCLI/main.swift" "api.binance.com"
reject_file_contains "Sources/MTPROCLI/main.swift" "fapi.binance.com"
reject_file_contains "Sources/MTPROCLI/main.swift" "submitOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "cancelOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "replaceOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "HMAC<"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionTradingEnabledByDefault=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionSecretRead=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionEndpointConnected=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionBrokerConnected=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionOrderSubmitted=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionCutoverAuthorized=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "testnetOrderSubmissionAllowed=true"

echo "MTPRO release v0.8.0 CLI local session action verification passed."
