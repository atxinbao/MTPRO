#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

echo "GH-737-VERIFY-V050-DASHBOARD-CLI-RUN-OBSERVER"

required_files=(
  "Sources/Portfolio/ReleaseV050RunObserverSurface.swift"
  "Sources/Dashboard/Report/ReleaseV050DashboardRunObserverSurface.swift"
  "Sources/MTPROCLI/main.swift"
  "docs/contracts/release-v0.5.0-run-observer-surface-contract.md"
  "docs/validation/validation-plan.md"
  "docs/validation/trading-validation-matrix.md"
  "docs/automation/automation-readiness.md"
  "Tests/TargetGraphTests/TargetGraphTests.swift"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || {
    echo "missing required GH-737 file: $file" >&2
    exit 1
  }
done

required_anchors=(
  "V050-12-DASHBOARD-CLI-RUN-OBSERVER"
  "V050-12-RUNID-STATUS-EVENTS-PROJECTION-RISK"
  "V050-12-DASHBOARD-SECTIONS-CONSUME-RUN-JOURNAL"
  "V050-12-BLOCKED-REJECTED-BOUNDARY-EVIDENCE"
  "V050-12-NO-PRODUCTION-COMMAND-SURFACE"
  "TVM-RELEASE-V050-DASHBOARD-CLI-RUN-OBSERVER"
)

for anchor in "${required_anchors[@]}"; do
  grep -R -Fq "$anchor" \
    Sources/Portfolio/ReleaseV050RunObserverSurface.swift \
    docs/contracts/release-v0.5.0-run-observer-surface-contract.md \
    docs/validation/validation-plan.md \
    docs/validation/trading-validation-matrix.md \
    checks/automation-readiness.sh || {
      echo "missing GH-737 anchor: $anchor" >&2
      exit 1
    }
done

grep -Fq "ReleaseV050RunObserverSurface" Sources/Portfolio/ReleaseV050RunObserverSurface.swift
grep -Fq "ReleaseV050DashboardRunObserverSurfaceViewModel" Sources/Dashboard/Report/ReleaseV050DashboardRunObserverSurface.swift
grep -Fq "ReleaseV050RunObserverSurface.commandLineOutput" Sources/MTPROCLI/main.swift
grep -Fq "run-observer" Sources/MTPROCLI/main.swift
grep -Fq "testGH737DashboardCLIRunObserverReadsJournalProjectionAndBoundaryByRunID" Tests/TargetGraphTests/TargetGraphTests.swift

for subcommand in list status events projection risk; do
  swift run mtpro run-observer "$subcommand" | grep -Fq "issue=GH-737"
done

swift test --filter TargetGraphTests/testGH737DashboardCLIRunObserverReadsJournalProjectionAndBoundaryByRunID

for forbidden in "URLSession" "URLRequest" "api.binance.com" "fapi.binance.com" "submitOrder" "cancelOrder" "replaceOrder" "HMAC<"; do
  if grep -Fq "$forbidden" Sources/Portfolio/ReleaseV050RunObserverSurface.swift Sources/Dashboard/Report/ReleaseV050DashboardRunObserverSurface.swift Sources/MTPROCLI/main.swift; then
    echo "GH-737 observer must not contain forbidden runtime token: $forbidden" >&2
    exit 1
  fi
done

echo "TVM-RELEASE-V050-DASHBOARD-CLI-RUN-OBSERVER verified"
