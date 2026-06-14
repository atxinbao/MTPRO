#!/usr/bin/env bash
set -euo pipefail

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 DataEngine local dry-run runner verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 DataEngine local dry-run runner verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GH759="GH-759-VERIFY-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER"
TVM759="TVM-RELEASE-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER"

swift test --filter TargetGraphTests/testGH759DataEngineLocalDryRunRunnerWritesMarketEventsToLocalRunJournal

require_file_contains "Package.swift" "\"ReleaseV060DataEngineLocalDryRunRunner.swift\""
require_file_contains "Package.swift" "\"Database\""
require_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "ReleaseV060DataEngineLocalDryRunRunner"
require_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "ReleaseV060LocalRunJournalWriter"
require_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "ReleaseV050DurableLocalRunJournal"
require_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "DataEngineMarketEvent"
require_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "sha256:"
require_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "eventIDPrefix"

require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "V060-005-DATAENGINE-LOCAL-DRY-RUN-RUNNER"
require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "V060-005-LOCAL-FIXTURE-CATALOG-ONLY"
require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "V060-005-DATAENGINE-MARKET-EVENT-JOURNAL-WRITE"
require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "V060-005-BINANCE-SPOT-USDM-PERP-BOUNDARY"
require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "V060-005-NO-NETWORK-SECRET-ORDER"
require_file_contains "docs/contracts/release-v0.6.0-dataengine-local-dry-run-runner-contract.md" "$TVM759"
require_file_contains "docs/validation/trading-validation-matrix.md" "$TVM759"
require_file_contains "docs/validation/validation-plan.md" "GH-759 Release v0.6.0 DataEngine Local Dry-run Runner Validation"
require_file_contains "docs/validation/validation-plan.md" "$GH759"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 DataEngine local dry-run runner anchor"
require_file_contains "checks/automation-readiness.sh" "$GH759"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-dataengine-local-dry-run-runner.sh"

reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "URLSession"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "URLRequest"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "api.binance.com"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "fapi.binance.com"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "/api/v3/account"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "/api/v3/order"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "/api/v3/userDataStream"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "listenKey"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "submitOrder"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "cancelOrder"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "replaceOrder"
reject_file_contains "Sources/DataEngine/ReleaseV060DataEngineLocalDryRunRunner.swift" "HMAC<"

echo "MTPRO release v0.6.0 DataEngine local dry-run runner verification passed."
