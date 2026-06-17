#!/usr/bin/env bash
set -euo pipefail

# GH-781-VERIFY-V070-CLI-RUNTIME-SESSION-SURFACE
# TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

RUNS_ROOT="$(mktemp -d)"
trap 'rm -rf "$RUNS_ROOT"' EXIT
export MTPRO_LOCAL_RUNS_ROOT="$RUNS_ROOT"

require_output_contains() {
  local output="$1"
  local expected="$2"

  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'release v0.7.0 CLI verification failed: output must contain: %s\n' "$expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
}

reject_output_contains() {
  local output="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" <<< "$output"; then
    printf 'release v0.7.0 CLI verification failed: output must not contain: %s\n' "$forbidden" >&2
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
    printf 'release v0.7.0 CLI verification failed: command unexpectedly succeeded: %s\n' "$*" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi

  require_output_contains "$output" "$expected"
  reject_output_contains "$output" "productionOrderSubmitted=true"
  reject_output_contains "$output" "productionCutoverAuthorized=true"
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 CLI verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH781TopLevelCLIRunStatusVerifyUseV070RuntimeSessionSemantics

help_output="$(swift run mtpro help)"
require_output_contains "$help_output" "validationAnchor=TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE"
require_output_contains "$help_output" "runtimeSessionContract=v0.7.0"
require_output_contains "$help_output" "runtimeModes=local-dry-run,testnet-read-only-monitor,recovery-observe,production-blocked"
require_output_contains "$help_output" "legacyRuntimeModes=testnet-read-only-probe"

run_output="$(swift run mtpro run --mode dry-run)"
require_output_contains "$run_output" "mtpro run no-order-runtime-session"
require_output_contains "$run_output" "mode=local-dry-run"
require_output_contains "$run_output" "noOrder"
require_output_contains "$run_output" "orderSubmissionAllowed=false"
require_output_contains "$run_output" "submitCancelReplaceAllowed=false"
reject_output_contains "$run_output" "mtpro run blocked"

probe_output="$(swift run mtpro run --mode testnet-read-only-monitor)"
require_output_contains "$probe_output" "mode=testnet-read-only-monitor"
require_output_contains "$probe_output" "testnetConnected=false"
require_output_contains "$probe_output" "productionEndpointConnected=false"

legacy_probe_output="$(swift run mtpro run --mode testnet-read-only-probe)"
require_output_contains "$legacy_probe_output" "mode=testnet-read-only-probe"
require_output_contains "$legacy_probe_output" "productionEndpointConnected=false"

status_output="$(swift run mtpro status gh-781-local-session)"
require_output_contains "$status_output" "mtpro status no-order-runtime-session"
require_output_contains "$status_output" "runID=gh-781-local-session"
require_output_contains "$status_output" "activeTopLevelStatusSurface=v0.7.0"
require_output_contains "$status_output" "legacyV040StatusSurface=false"
require_output_contains "$status_output" "legacyV050ObserverSurface=false"
reject_output_contains "$status_output" "mtpro unified-run-status blocked"

verify_output="$(swift run mtpro verify)"
require_output_contains "$verify_output" "mtpro verify v0.9.0"
require_output_contains "$verify_output" "verificationAnchor=GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_output_contains "$verify_output" "historicalV080Checks=verify-v0.8.0-contract,verify-v0.8.0-release-publication-policy,verify-v0.8.0-cli-local-session,verify-v0.8.0-validation-lanes,verify-v0.8.0"
require_output_contains "$verify_output" "historicalV070Checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli"
require_output_contains "$verify_output" "verify-v0.7.0-contract"
require_output_contains "$verify_output" "verify-v0.7.0-testnet-endpoint-policy"
require_output_contains "$verify_output" "verify-v0.7.0-cli"
require_output_contains "$verify_output" "noOrderRuntimeSession=true"
require_output_contains "$verify_output" "orderSubmissionAllowed=false"

legacy_v040_output="$(swift run mtpro unified-run-status)"
require_output_contains "$legacy_v040_output" "mtpro unified-run-status blocked"

expect_failure_contains "mtpro.run.production" swift run mtpro run --mode production
expect_failure_contains "mtpro.strict.arguments" swift run mtpro submit
expect_failure_contains "mtpro.strict.arguments" swift run mtpro cancel
expect_failure_contains "mtpro.strict.arguments" swift run mtpro replace

require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-cli.sh"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE"
require_file_contains "docs/validation/validation-plan.md" "GH-781 Release v0.7.0 CLI Runtime Session Surface Validation"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 CLI runtime session surface anchor"

echo "MTPRO release v0.7.0 CLI runtime session surface verification passed."
