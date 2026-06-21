#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

SOURCE="Sources/Dashboard/Report/ReleaseV0140ReadOnlyExecutionDashboardSurface.swift"
SHELL="Sources/Dashboard/DashboardShell.swift"
APP_TESTS="Tests/AppTests/AppTests.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
CONTRACT="docs/contracts/release-v0.14.0-read-only-execution-dashboard.md"
RUN_SCRIPT="checks/run.sh"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-read-only-execution-dashboard failed: $file must contain: $expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    echo "verify-v0.14.0-read-only-execution-dashboard failed: $file must not contain: $forbidden" >&2
    exit 1
  fi
}

for required in \
  "public enum ReleaseV0140ReadOnlyExecutionDashboardStage" \
  "public struct ReleaseV0140ReadOnlyExecutionDashboardLogInput" \
  "public struct ReleaseV0140ReadOnlyExecutionDashboardRow" \
  "public struct ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel" \
  "ReleaseV0140ExecutionEventLogReport" \
  "dashboardCommandSurfaceEnabled" \
  "tradingButtonVisible" \
  "orderFormVisible" \
  "submitCancelReplaceEnabled" \
  "productionSubmitCancelReplaceEnabled"; do
  require_file_contains "$SOURCE" "$required"
done

for anchor in \
  "GH-1041-READ-ONLY-EXECUTION-DASHBOARD" \
  "GH-1041-EXECUTION-STATUS-SURFACE" \
  "GH-1041-NO-DASHBOARD-COMMANDS" \
  "TVM-RELEASE-V0140-READ-ONLY-EXECUTION-DASHBOARD"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$CONTRACT" "$anchor"
done

require_file_contains "$SHELL" "releaseV0140ReadOnlyExecutionDashboardSurface"
require_file_contains "$SHELL" "releaseV0140ExecutionDashboardRows"
require_file_contains "$APP_TESTS" "testGH1041DashboardReadOnlyExecutionSurfaceShowsClosedLoopEvidenceWithoutCommands"
require_file_contains "$TARGET_TESTS" "testGH1041DashboardReadOnlyExecutionSurfaceIsAnchoredInV0140Guards"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.0-read-only-execution-dashboard.sh"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "CryptoKit" \
  "HMAC" \
  "API_KEY" \
  "SECRET" \
  "signature" \
  "api.binance.com" \
  "fapi.binance.com" \
  "dapi.binance.com"; do
  require_file_absent "$SOURCE" "$forbidden"
done

swift test --filter AppTests/testGH1041DashboardReadOnlyExecutionSurfaceShowsClosedLoopEvidenceWithoutCommands
swift test --filter TargetGraphTests/testGH1041DashboardReadOnlyExecutionSurfaceIsAnchoredInV0140Guards

echo "MTPRO release v0.14.0 read-only execution dashboard verification passed."
