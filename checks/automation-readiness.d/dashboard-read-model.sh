#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "Sources/Dashboard/DashboardTargetBoundary.swift"
require_file "Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyDashboardBoundary.swift"
require_file "Sources/Dashboard/DashboardBetaAcceptancePath.swift"
require_contains "Sources/Dashboard/DashboardTargetBoundary.swift" "GH-420-DASHBOARD-ACTIVE-SOURCE-NAMING-CLEAN"
require_contains "Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyDashboardBoundary.swift" "dashboardReadModelOnlyBoundaryHeld"
require_contains "Sources/Dashboard/DashboardBetaAcceptancePath.swift" "mtp-122-dashboard-beta-acceptance-path"
require_absent "Sources/Dashboard/DashboardBetaAcceptancePath.swift" "mtp-122-workbench-beta-acceptance-path"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH420DashboardActiveSourceUsesDashboardReadModelOnlyNaming"
require_contains "Tests/AppTests/AppTests.swift" "testGH468DashboardLivePROConsoleSplitKeepsDashboardReadModelOnly"
require_contains "Tests/AppTests/AppTests.swift" "testGH469GuardedCommandUISurfaceAllowsSandboxOnlySubmitCancelReplace"

if grep -R -n -E 'Workbench|workbench' Sources/Dashboard >/tmp/mtpro-dashboard-domain-workbench-matches 2>/dev/null; then
  cat /tmp/mtpro-dashboard-domain-workbench-matches >&2
  fail "Sources/Dashboard must not contain active Workbench naming"
fi
