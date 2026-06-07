#!/usr/bin/env bash
set -euo pipefail

# GH-538-NO-DEFAULT-PRODUCTION-TRADING-AUTOMATION-GUARD
# GH-538-FORBIDDEN-PRODUCTION-CONFIG-DEFAULTS
# GH-538-SECRET-ENDPOINT-GUARD-EVIDENCE
# GH-538-DRYRUN-TESTNET-KILLSWITCH-BYPASS-GUARD
# TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT"

python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path.cwd()

source_paths = sorted((root / "Sources").rglob("*.swift"))
source_paths.extend(
    [
        root / "Package.swift",
        root / ".github/workflows/checks.yml",
        root / "checks/run.sh",
        root / "checks/release-v0.1.0-dryrun-testnet.sh",
    ]
)

forbidden_default_patterns = [
    (
        "production trading default",
        re.compile(r"\bproductionTradingEnabledByDefault\s*[:=]\s*true\b"),
    ),
    (
        "production endpoint default",
        re.compile(r"\bproductionEndpoint(?:Connection)?EnabledByDefault\s*[:=]\s*true\b"),
    ),
    (
        "production secret read default",
        re.compile(r"\bproductionSecret(?:Read)?EnabledByDefault\s*[:=]\s*true\b"),
    ),
    (
        "production submit default",
        re.compile(r"\b(?:productionOrderSubmitEnabledByDefault|productionSubmitEnabledByDefault)\s*[:=]\s*true\b"),
    ),
    (
        "production cancel default",
        re.compile(r"\b(?:productionOrderCancelEnabledByDefault|productionCancelEnabledByDefault)\s*[:=]\s*true\b"),
    ),
    (
        "production replace default",
        re.compile(r"\b(?:productionOrderReplaceEnabledByDefault|productionReplaceEnabledByDefault)\s*[:=]\s*true\b"),
    ),
    (
        "production OMS default",
        re.compile(r"\bproductionOMSRuntimeEnabledByDefault\s*[:=]\s*true\b"),
    ),
    (
        "production Dashboard command default",
        re.compile(r"\bproductionDashboardCommandEnabledByDefault\s*[:=]\s*true\b"),
    ),
    (
        "production command enabled",
        re.compile(r"\bproductionCommandEnabled\s*[:=]\s*true\b"),
    ),
    (
        "automatic production cutover",
        re.compile(r"\bautomaticProductionCutoverEnabled\s*[:=]\s*true\b"),
    ),
    (
        "production endpoint connection",
        re.compile(r"\bconnectsProductionEndpoint\s*[:=]\s*true\b"),
    ),
    (
        "production order on failure",
        re.compile(r"\bfailureTriggersProductionOrder\s*[:=]\s*true\b"),
    ),
    (
        "sandbox command promotes production command",
        re.compile(r"\bsandboxCommandPromotesProductionCommand\s*[:=]\s*true\b"),
    ),
    (
        "trading authorization",
        re.compile(r"\bauthorizesTradingExecution\s*[:=]\s*true\b"),
    ),
    (
        "real order action",
        re.compile(r"\b(?:submitsRealOrder|cancelsRealOrder|replacesRealOrder)\s*[:=]\s*true\b"),
    ),
    (
        "risk / OMS / kill switch / no-trade bypass",
        re.compile(
            r"\b(?:bypassesRiskEngine|bypassesExecutionEngine|bypassesOMS|bypassesKillSwitch|bypassesNoTradeState)\s*[:=]\s*true\b"
        ),
    ),
]

forbidden_config_patterns = [
    (
        "environment/config production default",
        re.compile(
            r"\b[A-Z0-9_]*(?:PRODUCTION|BROKER|REAL)[A-Z0-9_]*(?:TRADING|ORDER|SUBMIT|CANCEL|REPLACE|ENDPOINT|SECRET|BROKER)[A-Z0-9_]*\s*[:=]\s*[\"']?(?:1|true|enabled|on|yes)[\"']?\b",
            re.IGNORECASE,
        ),
    ),
]

violations = []

for path in source_paths:
    if not path.exists():
        continue
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        implementation_line = line.split("//", 1)[0]
        patterns = forbidden_default_patterns
        if path.suffix in {".yml", ".yaml", ".sh"}:
            patterns = forbidden_default_patterns + forbidden_config_patterns
        for description, pattern in patterns:
            if pattern.search(implementation_line):
                violations.append(
                    f"{path.relative_to(root)}:{line_number}: {description}: {line.strip()}"
                )

if violations:
    print(
        "automation readiness release v0.1.0 guard failed: production trading, secret, endpoint, order, or bypass default is enabled",
        file=sys.stderr,
    )
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)

required_false_contracts = {
    "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md": [
        "GH-538-NO-DEFAULT-PRODUCTION-TRADING-AUTOMATION-GUARD",
        "GH-538-FORBIDDEN-PRODUCTION-CONFIG-DEFAULTS",
        "GH-538-SECRET-ENDPOINT-GUARD-EVIDENCE",
        "GH-538-DRYRUN-TESTNET-KILLSWITCH-BYPASS-GUARD",
        "TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD",
        "productionTradingEnabledByDefault == false",
        "productionEndpointConnectionEnabledByDefault == false",
        "productionSecretReadEnabledByDefault == false",
        "productionOrderSubmitEnabledByDefault == false",
        "productionOrderCancelEnabledByDefault == false",
        "productionOrderReplaceEnabledByDefault == false",
        "productionOMSRuntimeEnabledByDefault == false",
        "productionDashboardCommandEnabledByDefault == false",
    ],
    "docs/validation/trading-validation-matrix.md": [
        "TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD",
    ],
    "docs/validation/validation-plan.md": [
        "GH-538 No-default Production Trading Automation Guard Validation",
    ],
    "docs/domain/context.md": [
        "GH-538 No-default Production Trading Automation Guard Terms",
    ],
    "docs/automation/automation-readiness.md": [
        "Release v0.1.0 no-default-production-trading automation guard anchor",
    ],
}

missing = []
for relative_path, expected_values in required_false_contracts.items():
    path = root / relative_path
    if not path.exists():
        missing.append(f"{relative_path}: missing file")
        continue
    text = path.read_text(encoding="utf-8")
    for expected in expected_values:
        if expected not in text:
            missing.append(f"{relative_path}: missing {expected}")

if missing:
    print(
        "automation readiness release v0.1.0 guard failed: no-default-production-trading evidence chain is incomplete",
        file=sys.stderr,
    )
    print("\n".join(missing), file=sys.stderr)
    sys.exit(1)

print("MTPRO release v0.1.0 no-default-production-trading guard passed.")
PY
