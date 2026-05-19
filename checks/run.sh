#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

git diff --check
bash checks/automation-readiness.sh
if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard build and smoke run: SwiftUI shell is macOS-only."
fi
swift test

echo "MTPRO checks passed."
