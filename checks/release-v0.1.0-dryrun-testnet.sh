#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

swift test --filter TargetGraphTests/testGH537ReleaseDryRunTestnetValidationSuiteIsRepeatableAndProductionSafe

echo "MTPRO release v0.1.0 dry-run/testnet validation suite passed."
