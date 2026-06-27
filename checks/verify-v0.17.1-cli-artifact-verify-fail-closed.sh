#!/usr/bin/env bash
set -euo pipefail

# GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED
# TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED
# V0171-001-FAILED-VALIDATION-NONZERO-EXIT
# V0171-001-VALID-BUNDLE-EXIT-ZERO
# V0171-001-LOCAL-REPORTING-PATH-REDACTED
# V0171-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.1 CLI artifact verify fail-closed guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.17.1 CLI artifact verify fail-closed guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170CLIArtifactVerifyCommand.swift"
CLI="Sources/MTPROCLI/main.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
VERIFIER="checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh"

swift test --filter TargetGraphTests/testGH1166ReleaseV0171CLIArtifactVerifyCommandFailsClosed

for file in "$SOURCE" "$CLI" "$RUN_SCRIPT" "$AUTOMATION_SCRIPT" "$TESTS" "$VERIFIER"; do
  for anchor in \
    "GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED" \
    "TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED" \
    "V0171-001-FAILED-VALIDATION-NONZERO-EXIT" \
    "V0171-001-VALID-BUNDLE-EXIT-ZERO" \
    "V0171-001-LOCAL-REPORTING-PATH-REDACTED" \
    "V0171-001-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

require_file_contains "$SOURCE" "failedValidationNonzeroExit=true"
require_file_contains "$SOURCE" "validBundleExitZero=true"
require_file_contains "$SOURCE" "ReleaseV0170CLIArtifactVerifyCommandFailedValidation"
require_file_contains "$SOURCE" "commandLineReportOutput"
require_file_contains "$CLI" "catch let error as ReleaseV0170CLIArtifactVerifyCommandFailedValidation"
require_file_contains "$CLI" "Foundation.exit(error.exitCode)"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh"
require_file_contains "$TESTS" "testGH1166ReleaseV0171CLIArtifactVerifyCommandFailsClosed"

for file in "$SOURCE" "$CLI"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.1 CLI artifact verify fail-closed verification passed.\n'
