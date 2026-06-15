#!/usr/bin/env bash
set -euo pipefail

# GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS
# TVM-RELEASE-V070-DASHBOARD-READONLY-RUN-OPERATIONS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 Dashboard read-only run operations verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 Dashboard read-only run operations verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV070DashboardReadOnlyRunOperationsSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"

swift test --filter AppTests/testGH788DashboardReadOnlyRunOperationsSurfaceShowsRegistryJournalAndProbeStatusWithoutCommands
swift test --filter TargetGraphTests/testGH788DashboardReadOnlyRunOperationsSurfaceIsAnchoredInV070Guards

require_file_contains "$SOURCE" "ReleaseV070DashboardReadOnlyRunOperationsSurfaceViewModel"
require_file_contains "$SOURCE" "ReleaseV070DashboardRunOperationRecord"
require_file_contains "$SOURCE" "ReleaseV070DashboardReadOnlyProbeStatus"
require_file_contains "$SOURCE" "ReleaseV070RunRegistry.local-run-registry-metadata"
require_file_contains "$SOURCE" "ReleaseV070RuntimeEventLogWriter.events.jsonl"
require_file_contains "$SOURCE" "ReleaseV070OperationalRunSessionCommand.safe-local"
require_file_contains "$SOURCE" "ReleaseV070TestnetSignedAccountReadOnlyProbeArtifact"
require_file_contains "$SOURCE" "ReleaseV070TestnetPrivateStreamReadOnlyProbeArtifact"
require_file_contains "$SHELL_SOURCE" "releaseV070RunOperationsSurface"
require_file_contains "$SHELL_SOURCE" "releaseV070RunOperations="
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV070RunOperationsPanel"
require_file_contains "Tests/AppTests/AppTests.swift" \
  "testGH788DashboardReadOnlyRunOperationsSurfaceShowsRegistryJournalAndProbeStatusWithoutCommands"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "testGH788DashboardReadOnlyRunOperationsSurfaceIsAnchoredInV070Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh"
require_file_contains "checks/verify-v0.7.0-dashboard-macos-guards.sh" \
  "bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh"
require_file_contains "docs/validation/validation-plan.md" \
  "GH-788 Release v0.7.0 Dashboard Read-only Run Operations Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-DASHBOARD-READONLY-RUN-OPERATIONS"
require_file_contains "docs/automation/automation-readiness.md" \
  "Release v0.7.0 Dashboard read-only run operations anchor"
require_file_contains "checks/automation-readiness.sh" \
  "GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS"

for anchor in \
  "GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS" \
  "TVM-RELEASE-V070-DASHBOARD-READONLY-RUN-OPERATIONS" \
  "V070-010-DASHBOARD-RUN-LIST-DETAILS-STATE-EVIDENCE" \
  "V070-010-LOCAL-DRY-RUN-START-STOP-RECOVER-SAFE-COMMANDS" \
  "V070-010-TESTNET-READONLY-PROBE-STATUS-VISIBILITY" \
  "V070-010-REGISTRY-JOURNAL-READMODEL-ONLY" \
  "V070-010-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V070-010-NO-ORDER-NO-PRODUCTION-BOUNDARY"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"

echo "MTPRO release v0.7.0 Dashboard read-only run operations verification passed."
