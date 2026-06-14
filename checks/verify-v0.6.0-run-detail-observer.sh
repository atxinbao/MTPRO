#!/usr/bin/env bash
set -euo pipefail

# GH-764-VERIFY-V060-RUN-DETAIL-OBSERVER
# TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local path="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$path"; then
    printf 'release v0.6.0 run detail observer verification failed: %s must contain: %s\n' "$path" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local path="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$path"; then
    printf 'release v0.6.0 run detail observer verification failed: %s must not contain: %s\n' "$path" "$forbidden" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH764DashboardCLIRunDetailObserverReadsArtifactBackedRunJournal

require_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "ReleaseV060RunDetailObserverSurface"
require_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "validateRunManifest"
require_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "events.jsonl"
require_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "projection.json"
require_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "manifest.json"
require_file_contains "Sources/Dashboard/Report/ReleaseV060DashboardRunDetailObserverSurface.swift" "ReleaseV060DashboardRunDetailObserverViewModel"
require_file_contains "Sources/MTPROCLI/main.swift" "ReleaseV060RunDetailObserverSurface.cliCommand"
require_file_contains "Sources/MTPROCLI/main.swift" "ReleaseV060RunDetailObserverSurface.commandLineOutput"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "V060-010-DASHBOARD-CLI-RUN-DETAIL-OBSERVER"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "V060-010-ARTIFACT-BACKED-RUN-LIST-STATUS-EVENTS-PROJECTION-RISK"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "V060-010-DASHBOARD-READS-SAME-MANIFEST-AS-CLI"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "V060-010-MANIFEST-CORRUPTION-GAP-STATE"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "V060-010-NO-PRODUCTION-COMMAND-SURFACE"
require_file_contains "docs/contracts/release-v0.6.0-run-detail-observer-contract.md" "TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER"
require_file_contains "docs/validation/validation-plan.md" "GH-764 Release v0.6.0 Dashboard CLI Run Detail Observer Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 Dashboard / CLI run detail observer anchor"
require_file_contains "checks/automation-readiness.sh" "GH-764-VERIFY-V060-RUN-DETAIL-OBSERVER"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-run-detail-observer.sh"
require_file_contains "checks/verify-v0.5.0-cli.sh" "run-detail-observer"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "api.binance.com" \
  "fapi.binance.com" \
  "/api/v3/account" \
  "/api/v3/order" \
  "/api/v3/userDataStream" \
  "listenKey" \
  "submitOrder" \
  "cancelOrder" \
  "replaceOrder" \
  "HMAC<"; do
  reject_file_contains "Sources/Portfolio/ReleaseV060RunDetailObserverSurface.swift" "$forbidden"
done

echo "MTPRO release v0.6.0 Dashboard / CLI run detail observer verification passed."
