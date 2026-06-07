#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "Package.swift"
require_file "Sources/Trader/TargetGraph/TraderTargetBoundary.swift"
require_file "Sources/ExecutionClient/TargetGraph/ExecutionClientTargetBoundary.swift"
require_file "Sources/ExecutionEngine/TargetGraph/ExecutionEngineTargetBoundary.swift"
require_contains "Package.swift" 'name: "Trader"'
require_contains "Package.swift" 'name: "ExecutionClient"'
require_contains "Package.swift" 'name: "ExecutionEngine"'
require_contains "Sources/Trader/TargetGraph/TraderTargetBoundary.swift" "GH-392-TRADER-NO-DIRECT-EXECUTIONENGINE-DEPENDENCY"
require_contains "Sources/ExecutionClient/TargetGraph/ExecutionClientTargetBoundary.swift" "GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE"
require_contains "Sources/ExecutionEngine/TargetGraph/ExecutionEngineTargetBoundary.swift" "GH-397-EXECUTIONENGINE-REAL-TARGET-SMOKE"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH392TraderTargetPackageDoesNotDependDirectlyOnExecutionEngine"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH421AllArchitectureTargetsExposeIndependentRealAPISmokeCoverage"

python3 - <<'PY'
from pathlib import Path
import sys

root = Path.cwd()
package = (root / "Package.swift").read_text()
target_marker = '.target(\n            name: "Trader"'
start = package.find(target_marker)
if start == -1:
    print("automation readiness domain check failed: Package.swift Trader target not found", file=sys.stderr)
    sys.exit(1)

tail = package[start + len(target_marker):]
next_positions = [
    pos for marker in ("\n        .target(", "\n        .executableTarget(", "\n        .testTarget(")
    if (pos := tail.find(marker)) != -1
]
end = min(next_positions) if next_positions else len(tail)
trader_target = package[start:start + len(target_marker) + end]

for forbidden in ('"ExecutionEngine"', '"ExecutionClient"'):
    if forbidden in trader_target:
        print(
            f"automation readiness domain check failed: Trader target must not depend on {forbidden}",
            file=sys.stderr,
        )
        sys.exit(1)
PY
