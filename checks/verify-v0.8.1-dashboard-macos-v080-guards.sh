#!/usr/bin/env bash
set -euo pipefail

# GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS
# TVM-RELEASE-V081-DASHBOARD-MACOS-V080-GUARDS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 Dashboard macOS v0.8 guard verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_line_before() {
  local file="$1"
  local first="$2"
  local second="$3"
  local first_line
  local second_line

  first_line="$(grep -nF "$first" "$file" | head -n 1 | cut -d: -f1 || true)"
  second_line="$(grep -nF "$second" "$file" | head -n 1 | cut -d: -f1 || true)"

  if [[ -z "$first_line" || -z "$second_line" || "$first_line" -ge "$second_line" ]]; then
    printf 'release v0.8.1 Dashboard macOS v0.8 guard verification failed: %s must place "%s" before "%s"\n' "$file" "$first" "$second" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$WORKFLOW" "Verify v0.8.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.8.1-dashboard-macos-v080-guards.sh"
require_file_contains "$WORKFLOW" "swift build --product Dashboard"
require_file_contains "$WORKFLOW" "DASHBOARD_SMOKE=1 swift run Dashboard"
require_line_before "$WORKFLOW" "Verify v0.8.0 Dashboard macOS focused guards" "Build Dashboard"
require_line_before "$WORKFLOW" "Verify v0.8.0 Dashboard macOS focused guards" "Run Dashboard smoke"

require_file_contains "$AUTOMATION_DOC" "Release v0.8.1 Dashboard macOS v0.8 focused guard anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS"
require_file_contains "$VALIDATION_PLAN" "GH-836 Release v0.8.1 Dashboard macOS v0.8 Focused Guard Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V081-DASHBOARD-MACOS-V080-GUARDS"
require_file_contains "$TARGET_TESTS" "testGH836DashboardMacOSChecksRunV080FocusedGuards"

for command in \
  "bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh" \
  "bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh"; do
  require_file_contains "$0" "$command"
  require_file_contains "$AUTOMATION_SCRIPT" "$command"
done

for anchor in \
  "GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS" \
  "TVM-RELEASE-V081-DASHBOARD-MACOS-V080-GUARDS" \
  "V081-002-DASHBOARD-MACOS-V080-GUARDS" \
  "V081-002-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND" \
  "V081-002-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
done

bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh
bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh

echo "MTPRO release v0.8.1 Dashboard macOS v0.8 focused guard verification passed."
