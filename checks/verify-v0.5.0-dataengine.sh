#!/usr/bin/env bash
set -euo pipefail

# GH-732-VERIFY-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH
# TVM-RELEASE-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 DataEngine verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 DataEngine verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH732DataEngineOperationalDryRunPathPublishesTypedMarketEventsIntoMessageBusAndCache

require_file_contains \
  "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" \
  "ReleaseV050DataEngineOperationalDryRunPath"
require_file_contains \
  "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" \
  "RuntimeMessageBus"
require_file_contains \
  "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" \
  "DataEngineMarketEvent"
require_file_contains \
  "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" \
  "ProductAwareCache"
require_file_contains \
  "Package.swift" \
  "\"ReleaseV050DataEngineOperationalDryRunPath.swift\""
require_file_contains \
  "docs/contracts/release-v0.5.0-dataengine-operational-dry-run-path-contract.md" \
  "V050-07-DATAENGINE-OPERATIONAL-DRY-RUN-PATH"
require_file_contains \
  "docs/contracts/release-v0.5.0-dataengine-operational-dry-run-path-contract.md" \
  "V050-07-PUBLIC-MARKET-INPUT-DATACLIENT-DATAENGINE"
require_file_contains \
  "docs/contracts/release-v0.5.0-dataengine-operational-dry-run-path-contract.md" \
  "V050-07-TYPED-DATAENGINE-MARKET-EVENTS"
require_file_contains \
  "docs/contracts/release-v0.5.0-dataengine-operational-dry-run-path-contract.md" \
  "TVM-RELEASE-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-dataengine.sh"

reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "URLSession"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "URLRequest"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "api.binance.com"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "fapi.binance.com"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "submitOrder"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "cancelOrder"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "replaceOrder"
reject_file_contains "Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift" "HMAC<"

echo "MTPRO release v0.5.0 DataEngine operational dry-run path verification passed."
