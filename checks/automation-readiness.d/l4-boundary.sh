#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "docs/contracts/l4-live-production-command-contract.md"
require_file "docs/contracts/l4-production-cutover-no-default-real-trading-policy.md"
require_file "Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift"
require_file "Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift"
require_contains "docs/contracts/l4-live-production-command-contract.md" "GH-452-NO-DEFAULT-REAL-TRADING-POLICY"
require_contains "docs/contracts/l4-production-cutover-no-default-real-trading-policy.md" "TVM-L4-PRODUCTION-CUTOVER-GATE"
require_contains "Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift" "productionTradingEnabledByDefault"
require_contains "Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift" "automaticProductionCutoverEnabled"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH471ProductionCutoverGatePolicyDefinesNoDefaultRealTradingBoundary"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH471ProductionCutoverGatePolicyRejectsAutomaticCutoverAndProductionBypass"

python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path.cwd()
violations = []
patterns = [
    re.compile(r"productionTradingEnabledByDefault\s*[:=]\s*true"),
    re.compile(r"automaticProductionCutoverEnabled\s*[:=]\s*true"),
]

for source in sorted((root / "Sources").rglob("*.swift")):
    for line_number, line in enumerate(source.read_text().splitlines(), start=1):
        implementation_line = line.split("//", 1)[0]
        if any(pattern.search(implementation_line) for pattern in patterns):
            violations.append(f"{source.relative_to(root)}:{line_number}: {line.strip()}")

if violations:
    print(
        "automation readiness domain check failed: production trading must not be enabled by default",
        file=sys.stderr,
    )
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)
PY
