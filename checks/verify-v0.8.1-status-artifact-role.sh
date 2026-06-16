#!/usr/bin/env bash
set -euo pipefail

# GH-839-VERIFY-V081-STATUS-ARTIFACT-ROLE
# TVM-RELEASE-V081-STATUS-ARTIFACT-ROLE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_output_contains() {
  local output="$1"
  local expected="$2"

  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'release v0.8.1 status artifact role verification failed: output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" <<< "$output"; then
    printf 'release v0.8.1 status artifact role verification failed: output must not contain: %s\n' "$forbidden" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 status artifact role verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.1 status artifact role verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH839TopLevelCLIStatusArtifactRolesAreExplicit

RUNS_ROOT="$(mktemp -d)"
trap 'rm -rf "$RUNS_ROOT"' EXIT
export MTPRO_LOCAL_RUNS_ROOT="$RUNS_ROOT"

RUN_ID="gh-839-status-artifact-role"

run_output="$(swift run mtpro run --mode dry-run --run-id "$RUN_ID")"
require_output_contains "$run_output" "issue=GH-810"
require_output_contains "$run_output" "runID=$RUN_ID"
require_output_contains "$run_output" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_output_contains "$run_output" "canonicalStatusArtifact=status.json"
require_output_contains "$run_output" "status.json=$RUNS_ROOT/$RUN_ID/status.json"
require_output_contains "$run_output" "compatibilityRunStatusArtifact=_RUN_STATUS.json"
require_output_contains "$run_output" "_RUN_STATUS.json=$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json"
require_output_contains "$run_output" "brokerSessionStarted=false"
reject_output_contains "$run_output" "sessionStarted=false"
reject_output_contains "$run_output" "productionTradingEnabledByDefault=true"
reject_output_contains "$run_output" "productionSecretRead=true"
reject_output_contains "$run_output" "productionEndpointConnected=true"
reject_output_contains "$run_output" "productionOrderSubmitted=true"
reject_output_contains "$run_output" "productionCutoverAuthorized=true"
reject_output_contains "$run_output" "testnetOrderSubmissionAllowed=true"

test -f "$RUNS_ROOT/$RUN_ID/status.json"
test -f "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json"
test -f "$RUNS_ROOT/$RUN_ID/manifest.json"

require_file_contains "$RUNS_ROOT/$RUN_ID/status.json" '"issueID" : "GH-810"'
require_file_contains "$RUNS_ROOT/$RUN_ID/status.json" '"state" : "running"'
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"issueID" : "GH-810"'
require_file_contains "$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json" '"state" : "running"'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" '"statusJSONPath" :'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" 'status.json'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" '"runStatusJSONPath" :'
require_file_contains "$RUNS_ROOT/$RUN_ID/manifest.json" '_RUN_STATUS.json'

status_output="$(swift run mtpro status "$RUN_ID")"
require_output_contains "$status_output" "mtpro status no-order-runtime-session"
require_output_contains "$status_output" "localSessionFound=true"
require_output_contains "$status_output" "sessionState=running"
require_output_contains "$status_output" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_output_contains "$status_output" "canonicalStatusArtifact=status.json"
require_output_contains "$status_output" "status.json=$RUNS_ROOT/$RUN_ID/status.json"
require_output_contains "$status_output" "compatibilityRunStatusArtifact=_RUN_STATUS.json"
require_output_contains "$status_output" "_RUN_STATUS.json=$RUNS_ROOT/$RUN_ID/_RUN_STATUS.json"

require_file_contains "Sources/MTPROCLI/main.swift" "GH-839"
require_file_contains "Sources/MTPROCLI/main.swift" "status.json=canonical-v0.8"
require_file_contains "Sources/MTPROCLI/main.swift" "_RUN_STATUS.json=compatibility-run-status-mirror"
require_file_contains "checks/verify-v0.8.0-cli-local-session.sh" "statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror"
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "v0.8+ canonical operator status artifact"
require_file_contains "docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md" "compatibility run-status mirror"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1-status-artifact-role.sh"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.1 status artifact role anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-839 Release v0.8.1 Status Artifact Role Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V081-STATUS-ARTIFACT-ROLE"
require_file_contains "checks/automation-readiness.sh" "GH-839-VERIFY-V081-STATUS-ARTIFACT-ROLE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH839TopLevelCLIStatusArtifactRolesAreExplicit"

reject_file_contains "Sources/MTPROCLI/main.swift" "api.binance.com"
reject_file_contains "Sources/MTPROCLI/main.swift" "fapi.binance.com"
reject_file_contains "Sources/MTPROCLI/main.swift" "submitOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "cancelOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "replaceOrder"
reject_file_contains "Sources/MTPROCLI/main.swift" "HMAC<"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionTradingEnabledByDefault=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionSecretRead=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionEndpointConnected=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionOrderSubmitted=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "productionCutoverAuthorized=true"
reject_file_contains "Sources/MTPROCLI/main.swift" "testnetOrderSubmissionAllowed=true"

printf 'release v0.8.1 status artifact role verification passed\n'
