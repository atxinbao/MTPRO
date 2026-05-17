#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

git diff --check
bash checks/automation-readiness.sh
swift build --product MTPRODashboard
MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard
swift test

echo "MTPRO checks passed."
