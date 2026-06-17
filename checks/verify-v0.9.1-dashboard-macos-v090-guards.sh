#!/usr/bin/env bash
set -euo pipefail

# V091-002-VERIFY-DASHBOARD-MACOS-V090-GUARDS
# TVM-RELEASE-V091-DASHBOARD-MACOS-V090-GUARDS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.1 Dashboard macOS v0.9 guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.9.1 Dashboard macOS v0.9 guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"

require_file_contains "$WORKFLOW" "Verify v0.9.0 Dashboard macOS focused guards"
require_file_contains "$WORKFLOW" "bash checks/verify-v0.9.1-dashboard-macos-v090-guards.sh"
require_file_contains "$WORKFLOW" "Build Dashboard"
require_file_contains "$WORKFLOW" "Run Dashboard smoke"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
guard = workflow.index("Verify v0.9.0 Dashboard macOS focused guards")
build = workflow.index("Build Dashboard")
smoke = workflow.index("Run Dashboard smoke")
if not (guard < build < smoke):
    raise SystemExit("v0.9 Dashboard focused guard must run before Dashboard build and smoke")
PY

bash checks/verify-v0.9.0-dashboard-observability-timeline.sh
bash checks/verify-v0.9.0-alert-read-model.sh
bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh

if [[ "$(uname -s)" == "Darwin" ]]; then
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard smoke inside v0.9 macOS guard: SwiftUI shell smoke is macOS-only."
fi

reject_file_contains "$WORKFLOW" "productionCutoverAuthorized=true"
reject_file_contains "$WORKFLOW" "swift run mtpro submit"
reject_file_contains "$WORKFLOW" "swift run mtpro cancel"
reject_file_contains "$WORKFLOW" "swift run mtpro replace"

echo "MTPRO release v0.9.1 Dashboard macOS v0.9 focused guard verification passed."
