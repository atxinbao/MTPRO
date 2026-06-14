#!/usr/bin/env bash
set -euo pipefail

# GH-782-VERIFY-V070-DASHBOARD-MACOS-GUARDS
# TVM-RELEASE-V070-DASHBOARD-MACOS-GUARDS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 Dashboard macOS guard verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_contains ".github/workflows/checks.yml" "Verify v0.7.0 Dashboard macOS focused guards"
require_file_contains ".github/workflows/checks.yml" "bash checks/verify-v0.7.0-dashboard-macos-guards.sh"
require_file_contains ".github/workflows/checks.yml" "swift build --product Dashboard"
require_file_contains ".github/workflows/checks.yml" "DASHBOARD_SMOKE=1 swift run Dashboard"
require_file_contains "checks/automation-readiness.sh" "GH-782-VERIFY-V070-DASHBOARD-MACOS-GUARDS"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 Dashboard macOS focused guard anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-782 Release v0.7.0 Dashboard macOS Focused Guard Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-DASHBOARD-MACOS-GUARDS"

bash checks/verify-v0.6.0-run-detail-observer.sh
bash checks/verify-v0.6.0-testnet-readonly-probe.sh
bash checks/verify-v0.7.0-testnet-endpoint-policy.sh
bash checks/verify-v0.7.0-cli.sh

echo "MTPRO release v0.7.0 Dashboard macOS focused guard verification passed."
