#!/usr/bin/env bash
set -euo pipefail

# GH-727-VERIFY-V050-STRICT-CLI-COMMAND-PARSER
# TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

RUNS_ROOT="$(mktemp -d)"
trap 'rm -rf "$RUNS_ROOT"' EXIT
export MTPRO_LOCAL_RUNS_ROOT="$RUNS_ROOT"

require_output_contains() {
  local output="$1"
  local expected="$2"

  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'release v0.5.0 CLI verification failed: output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" <<< "$output"; then
    printf 'release v0.5.0 CLI verification failed: output must not contain: %s\n' "$forbidden" >&2
    printf '%s\n' "$output" >&2
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
    printf 'release v0.5.0 CLI verification failed: command unexpectedly succeeded: %s\n' "$*" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi

  require_output_contains "$output" "$expected"
  reject_output_contains "$output" "mtpro verify-fast pass"
  reject_output_contains "$output" "mtpro rehearsal-status blocked"
  reject_output_contains "$output" "mtpro unified-run-status blocked"
}

swift test --filter TargetGraphTests/testGH727StrictCLICommandParserRejectsUnknownFallback

help_output="$(swift run mtpro help)"
require_output_contains "$help_output" "mtpro help"
require_output_contains "$help_output" "commands=help,run,status,stop,recover,risk-policy,readiness,monitor,verify,testnet-execution,spot-testnet-submit,spot-testnet-cancel,rehearsal-status,unified-run-status,run-observer,run-detail-observer,testnet-readonly-probe,verify-fast,verify-release"
require_output_contains "$help_output" "productionTradingEnabledByDefault=false"

run_output="$(swift run mtpro run)"
require_output_contains "$run_output" "mtpro run no-order-runtime-session"
require_output_contains "$run_output" "runtimeSessionContract=v0.7.0"
require_output_contains "$run_output" "testnetConnected=false"
require_output_contains "$run_output" "productionOrderSubmitted=false"

status_output="$(swift run mtpro status)"
require_output_contains "$status_output" "mtpro status no-order-runtime-session"
require_output_contains "$status_output" "activeTopLevelStatusSurface=v0.7.0"
reject_output_contains "$status_output" "mtpro unified-run-status blocked"
require_output_contains "$status_output" "productionCutoverAuthorized=false"

verify_output="$(swift run mtpro verify)"
require_output_contains "$verify_output" "mtpro verify v0.10.0"
require_output_contains "$verify_output" "issue=GH-909"
require_output_contains "$verify_output" "verificationAnchor=GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "releaseModel=production-readiness-contract-reference-evidence"
require_output_contains "$verify_output" "readinessContractOnly=true"
require_output_contains "$verify_output" "referenceEvidenceModel=true"
require_output_contains "$verify_output" "operationalProductionReadiness=false"
require_output_contains "$verify_output" "historicalV090Checks=verify-v0.9.0-contract,verify-v0.9.0-dashboard-cli-operator-ux,verify-v0.9.0"
require_output_contains "$verify_output" "historicalV080Checks=verify-v0.8.0-contract,verify-v0.8.0-release-publication-policy,verify-v0.8.0-cli-local-session,verify-v0.8.0-validation-lanes,verify-v0.8.0"
require_output_contains "$verify_output" "historicalV070Checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli"
require_output_contains "$verify_output" "verify-v0.7.0-cli"
require_output_contains "$verify_output" "legacyFallbackDisabled=true"
require_output_contains "$verify_output" "unknownCommandFailure=mtpro.strict.arguments"

legacy_v040_output="$(swift run mtpro unified-run-status)"
require_output_contains "$legacy_v040_output" "mtpro unified-run-status blocked"

observer_output="$(swift run mtpro run-observer status)"
require_output_contains "$observer_output" "mtpro run-observer status blocked"
require_output_contains "$observer_output" "issue=GH-737"
require_output_contains "$observer_output" "commandSurfaceEnabled=false"

legacy_v030_output="$(swift run mtpro rehearsal-status)"
require_output_contains "$legacy_v030_output" "mtpro rehearsal-status blocked"

legacy_v020_output="$(swift run mtpro verify-fast)"
require_output_contains "$legacy_v020_output" "mtpro verify-fast pass"

expect_failure_contains "mtpro.strict.arguments" swift run mtpro unknown-command
expect_failure_contains "mtpro.strict.arguments" swift run mtpro spot
expect_failure_contains "mtpro.strict.arguments" swift run mtpro submit
expect_failure_contains "mtpro.strict.arguments" swift run mtpro cancel
expect_failure_contains "mtpro.strict.arguments" swift run mtpro replace

echo "MTPRO release v0.5.0 strict CLI command parser verification passed."
