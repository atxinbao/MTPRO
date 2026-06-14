#!/usr/bin/env bash
set -euo pipefail

# GH-785-VERIFY-V070-RUN-REGISTRY-SUPERVISOR
# TVM-RELEASE-V070-RUN-REGISTRY-SUPERVISOR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 run registry supervisor verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 run registry supervisor verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV070OperationalRunSession.swift"
CLI_SOURCE="Sources/MTPROCLI/main.swift"

swift test --filter TargetGraphTests/testGH785RunRegistrySupervisorProvidesLocalNoOrderRunManagement

require_file_contains "$SOURCE" "ReleaseV070RunRegistry"
require_file_contains "$SOURCE" "ReleaseV070RunSupervisor"
require_file_contains "$SOURCE" "ReleaseV070RunRegistryEntry"
require_file_contains "$SOURCE" "ReleaseV070RunArtifactLocation"
require_file_contains "$SOURCE" "ReleaseV070RunRegistryListSurface"
require_file_contains "$SOURCE" "listRuns"
require_file_contains "$SOURCE" "inspect(runID:"
require_file_contains "$SOURCE" "archive(runID:"
require_file_contains "$SOURCE" "recover(runID:"
require_file_contains "$SOURCE" "local-run-registry-metadata"
require_file_contains "$SOURCE" "local-run-registry-state"
require_file_contains "$SOURCE" "runs-list-inspect-local-registry"
require_file_contains "$SOURCE" "productionTradingAuthorized == false"
require_file_contains "$CLI_SOURCE" "runRegistryState=local-run-registry-ready"
require_file_contains "$CLI_SOURCE" "runsListSource=local-run-registry-metadata"
require_file_contains "$CLI_SOURCE" "runsInspectSource=local-run-registry-metadata"
require_file_contains "$CLI_SOURCE" "sessionRegistrySource=local-run-registry-state"
require_file_contains "$CLI_SOURCE" "recoverySemantics=local-evidence-only"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-run-registry-supervisor.sh"
require_file_contains "docs/validation/validation-plan.md" "GH-785 Release v0.7.0 Run Registry / Supervisor Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-RUN-REGISTRY-SUPERVISOR"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 run registry supervisor anchor"
require_file_contains "checks/automation-readiness.sh" "GH-785-VERIFY-V070-RUN-REGISTRY-SUPERVISOR"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"

echo "MTPRO release v0.7.0 run registry supervisor verification passed."
