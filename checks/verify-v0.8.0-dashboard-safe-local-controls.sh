#!/usr/bin/env bash
set -euo pipefail

# GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS
# TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 Dashboard safe local controls verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 Dashboard safe local controls verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV080DashboardSafeLocalControlsSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_REGISTRY_STORE="Sources/Database/ReleaseV080RunRegistryStore.swift"
SESSION_STORE="Sources/Database/ReleaseV080OperationalRunSessionStore.swift"
CONTRACT="docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH818DashboardSafeLocalControlsBindSessionStoresWithoutCommands
swift test --filter TargetGraphTests/testGH818DashboardSafeLocalControlsSurfaceIsAnchoredInV080Guards

require_file_contains "$SOURCE" "ReleaseV080DashboardSafeLocalControlsSurfaceViewModel"
require_file_contains "$SOURCE" "ReleaseV080DashboardSafeLocalControlResult"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore.registry-json"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore.session-json-events-status"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore.save"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore.archive"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore.recover"
require_file_contains "$SOURCE" "ReleaseV080RunRegistryStore.inspect"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore.create+apply(start,start)"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore.apply(stop,stop)"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore.apply(recover)"
require_file_contains "$SOURCE" "ReleaseV080OperationalRunSessionStore.load+status"
require_file_contains "$SOURCE" ".local/mtpro/runs/registry.json"
require_file_contains "$SOURCE" "session_events.jsonl"
require_file_contains "$SOURCE" "dashboard-readonly-snapshot.json"
require_file_contains "$RUN_REGISTRY_STORE" "public func archive"
require_file_contains "$RUN_REGISTRY_STORE" "public func recover"
require_file_contains "$SESSION_STORE" "public func create"
require_file_contains "$SESSION_STORE" "public func apply"
require_file_contains "$SESSION_STORE" "public func load"
require_file_contains "$SESSION_STORE" "public func status"
require_file_contains "$SHELL_SOURCE" "releaseV080SafeLocalControlsSurface"
require_file_contains "$SHELL_SOURCE" "releaseV080SafeLocalControls="
require_file_contains "$SHELL_SOURCE" "DashboardReleaseV080SafeLocalControlsPanel"
require_file_contains "$APP_TESTS" "testGH818DashboardSafeLocalControlsBindSessionStoresWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH818DashboardSafeLocalControlsSurfaceIsAnchoredInV080Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 Dashboard safe local controls anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS"
require_file_contains "$VALIDATION_PLAN" "GH-818 Release v0.8.0 Dashboard Safe Local Controls Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS"
require_file_contains "$CONTRACT" "V080-012-DASHBOARD-SAFE-LOCAL-CONTROLS"

for anchor in \
  "GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS" \
  "TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS" \
  "V080-012-DASHBOARD-SAFE-LOCAL-CONTROLS" \
  "V080-012-START-STOP-RECOVER-ARCHIVE-OPEN-DETAIL" \
  "V080-012-RUN-REGISTRY-SESSION-STORE-BINDING" \
  "V080-012-LOCAL-ARTIFACT-MUTATION-ONLY" \
  "V080-012-DETAIL-READONLY-SNAPSHOT" \
  "V080-012-NO-ORDER-PRODUCTION-COMMAND" \
  "V080-012-NO-TRADING-BUTTON-ORDER-FORM" \
  "V080-012-NO-TESTNET-ORDER-ROUTING" \
  "V080-012-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"
reject_file_contains "$SOURCE" "productionSecretAutoReadEnabled = true"
reject_file_contains "$SOURCE" "productionEndpointConnected = true"
reject_file_contains "$SOURCE" "brokerEndpointConnected = true"

echo "MTPRO release v0.8.0 Dashboard safe local controls verification passed."
