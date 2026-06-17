#!/usr/bin/env bash
set -euo pipefail

# GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE
# TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 Dashboard observability timeline verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 Dashboard observability timeline verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Dashboard/Report/ReleaseV090DashboardObservabilityTimelineSurface.swift"
SHELL_SOURCE="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter AppTests/testGH849DashboardObservabilityTimelineShowsMonitorArtifactsWithoutCommands
swift test --filter TargetGraphTests/testGH849DashboardObservabilityTimelineIsAnchoredInV090Guards

require_file_contains "$SOURCE" "ReleaseV090DashboardObservabilityTimelineSurfaceViewModel"
require_file_contains "$SOURCE" "ReleaseV090DashboardObservabilityTimelineEvent"
require_file_contains "$SOURCE" "monitor_session.json"
require_file_contains "$SOURCE" "monitor_events.jsonl"
require_file_contains "$SOURCE" "monitor_status.json"
require_file_contains "$SOURCE" "account-snapshot-freshness.json"
require_file_contains "$SOURCE" "private-stream-heartbeat.json"
require_file_contains "$SOURCE" "monitor-recovery.json"
require_file_contains "$SOURCE" "snapshotTimeline"
require_file_contains "$SOURCE" "privateStreamTimeline"
require_file_contains "$SOURCE" "freshnessTimeline"
require_file_contains "$SOURCE" "staleEventsVisible"
require_file_contains "$SOURCE" "disconnectedEventsVisible"
require_file_contains "$SOURCE" "recoveredEventsVisible"
require_file_contains "$SOURCE" "lastObservedEventKind"
require_file_contains "$SHELL_SOURCE" "releaseV090ObservabilityTimelineSurface"
require_file_contains "$SHELL_SOURCE" "releaseV090ObservabilityTimelineEvents"
require_file_contains "$APP_TESTS" "testGH849DashboardObservabilityTimelineShowsMonitorArtifactsWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH849DashboardObservabilityTimelineIsAnchoredInV090Guards"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-dashboard-observability-timeline.sh"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 Dashboard observability timeline anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE"
require_file_contains "$VALIDATION_PLAN" "GH-849 Release v0.9.0 Dashboard Observability Timeline Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE"
require_file_contains "$CONTRACT" "V090-007-DASHBOARD-OBSERVABILITY-TIMELINE"

for anchor in \
  "GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE" \
  "TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE" \
  "V090-007-DASHBOARD-OBSERVABILITY-TIMELINE" \
  "V090-007-MONITOR-SESSION-ARTIFACTS-ONLY" \
  "V090-007-SNAPSHOT-PRIVATE-STREAM-FRESHNESS-TIMELINES" \
  "V090-007-STALE-DISCONNECTED-RECOVERED-EVENTS" \
  "V090-007-LAST-OBSERVED-EVENT-KIND" \
  "V090-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V090-007-NO-TESTNET-ORDER-ROUTING" \
  "V090-007-NO-PRODUCTION-CUTOVER"; do
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
reject_file_contains "$SOURCE" "testnetOrderRoutingAllowed = true"

echo "MTPRO release v0.9.0 Dashboard observability timeline verification passed."
