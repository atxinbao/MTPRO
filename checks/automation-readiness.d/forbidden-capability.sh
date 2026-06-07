#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH436DataClientAndTraderForbiddenImplementationShapesStayOutOfActiveSource"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH496UnsafeConstructGuardRejectsRuntimeFacingCrashPaths"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH497FutureGateBuilderHelpersAreNotPublicSurface"
require_absent ".github/workflows/checks.yml" "pull_request_target"

python3 - <<'PY'
from pathlib import Path
import sys

root = Path.cwd()
forbidden_patterns = [
    'path: "/api/v3/account"',
    'path: "/api/v3/order"',
    'path: "/api/v3/userDataStream"',
    '= "/api/v3/account"',
    '= "/api/v3/order"',
    '= "/api/v3/userDataStream"',
    'URLQueryItem(name: "signature"',
    'BinanceQueryItem(name: "signature"',
    'forHTTPHeaderField: "X-MBX-APIKEY"',
    'headers: ["X-MBX-APIKEY"',
    'import CryptoKit',
    'import CryptoSwift',
    'import CommonCrypto',
    'HMAC<',
    'CCHmac',
    'CC_HMAC',
    'let apiKey',
    'var apiKey',
    'let apiSecret',
    'var apiSecret',
    'let secretKey',
    'var secretKey',
]
violations = []
for source in sorted((root / "Sources/DataClient").rglob("*.swift")):
    for index, line in enumerate(source.read_text().splitlines(), start=1):
        implementation_line = line.split("//", 1)[0]
        for forbidden in forbidden_patterns:
            if forbidden in implementation_line:
                violations.append(f"{source.relative_to(root)}:{index}: {forbidden}: {line.strip()}")
                break

if violations:
    print(
        "automation readiness domain check failed: DataClient forbidden implementation guard failed",
        file=sys.stderr,
    )
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)
PY
