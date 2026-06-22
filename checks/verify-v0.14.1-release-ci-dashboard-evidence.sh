#!/usr/bin/env bash
set -euo pipefail

# GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE
# TVM-RELEASE-V0141-RELEASE-CI-DASHBOARD-EVIDENCE
# V0141-001-RELEASE-CI-DASHBOARD-EVIDENCE
# V0141-001-V0140-TAG-RELEASE-CHECKS
# V0141-001-DASHBOARD-MACOS-EVIDENCE
# V0141-001-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.14.1 release CI / Dashboard evidence guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.14.1 release CI / Dashboard evidence guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"
RUN_SCRIPT="checks/run.sh"
DASHBOARD_GUARD="checks/verify-v0.14.0-read-only-execution-dashboard.sh"
AUDIT_INPUT="docs/audit/inputs/mtpro-release-v0.14.1-release-ci-dashboard-evidence.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/validation/latest-verification-summary.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

for anchor in \
  "GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE" \
  "TVM-RELEASE-V0141-RELEASE-CI-DASHBOARD-EVIDENCE" \
  "V0141-001-RELEASE-CI-DASHBOARD-EVIDENCE" \
  "V0141-001-V0140-TAG-RELEASE-CHECKS" \
  "V0141-001-DASHBOARD-MACOS-EVIDENCE" \
  "V0141-001-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$AUDIT_INPUT" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TARGET_TESTS" "$anchor"
done

require_file_contains "$WORKFLOW" "Verify v0.14.x release CI and Dashboard evidence guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh"
require_file_contains "$WORKFLOW" "Build Dashboard"
require_file_contains "$WORKFLOW" "Run Dashboard smoke"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
v0120_guard = workflow.index("Verify v0.12.0 Dashboard macOS focused guards")
v0141_guard = workflow.index("Verify v0.14.x release CI and Dashboard evidence guards")
build = workflow.index("Build Dashboard")
smoke = workflow.index("Run Dashboard smoke")
if not (v0120_guard < v0141_guard < build < smoke):
    raise SystemExit("v0.14.x release CI / Dashboard evidence guard must run after v0.12 guard and before Dashboard build and smoke")
PY

require_file_contains "$AUDIT_INPUT" "https://github.com/atxinbao/MTPRO/releases/tag/v0.14.0"
require_file_contains "$AUDIT_INPUT" "5ec84cd02adb425fb533fdf7337673746b51c8be"
require_file_contains "$AUDIT_INPUT" "PR #1058"
require_file_contains "$AUDIT_INPUT" "27919195332"
require_file_contains "$AUDIT_INPUT" "27919993831"
require_file_contains "$AUDIT_INPUT" "linux-checks"
require_file_contains "$AUDIT_INPUT" "dashboard-macos"
require_file_contains "$AUDIT_INPUT" "checks"
require_file_contains "$AUDIT_INPUT" "bash checks/run.sh"
require_file_contains "$AUDIT_INPUT" "bash checks/verify-v0.14.0-read-only-execution-dashboard.sh"
require_file_contains "$AUDIT_INPUT" "v0.14.1 是 hardening patch，不新增 runtime pipeline"

bash "$DASHBOARD_GUARD"

if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  SMOKE_OUTPUT="$(DASHBOARD_SMOKE=1 swift run Dashboard)"
  printf '%s\n' "$SMOKE_OUTPUT"

  for expected in \
    "releaseV0140ExecutionDashboardRows=7" \
    "releaseV0140ExecutionLogEntries=7" \
    "releaseV0140ExecutionDashboardBoundary=confirmed"; do
    if ! grep -Fq "$expected" <<< "$SMOKE_OUTPUT"; then
      printf 'release v0.14.1 release CI / Dashboard evidence guard failed: smoke output must contain: %s\n' "$expected" >&2
      exit 1
    fi
  done
else
  echo "Skipping Dashboard build and smoke inside v0.14.x release CI guard: SwiftUI shell smoke is macOS-only."
fi

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "productionSubmitCancelReplace=true" \
  "productionCutoverAuthorized=true" \
  "swift run mtpro submit" \
  "swift run mtpro cancel" \
  "swift run mtpro replace"; do
  reject_file_contains "$WORKFLOW" "$forbidden"
  reject_file_contains "$AUDIT_INPUT" "$forbidden"
done

echo "MTPRO release v0.14.1 release CI / Dashboard evidence verification passed."

