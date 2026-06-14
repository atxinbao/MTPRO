#!/usr/bin/env bash
set -euo pipefail

# GH-730-VERIFY-V050-TYPED-RUNTIME-MESSAGEBUS
# TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 MessageBus verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 MessageBus verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH730TypedRuntimeMessageBusActorPublishesAuditableEnvelopes

require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "RuntimeEventEnvelope"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "public actor RuntimeMessageBus"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "DataEngineMarketEvent"
require_file_contains \
  "Sources/MessageBus/RuntimeMessageBus.swift" \
  "DashboardReadModelEvent"
require_file_contains \
  "Package.swift" \
  "\"RuntimeMessageBus.swift\""
require_file_contains \
  "Package.swift" \
  "\"MessageBus/RuntimeMessageBus.swift\""
require_file_contains \
  "docs/contracts/release-v0.5.0-typed-runtime-messagebus-contract.md" \
  "V050-05-TYPED-RUNTIME-MESSAGEBUS-ACTOR"
require_file_contains \
  "docs/contracts/release-v0.5.0-typed-runtime-messagebus-contract.md" \
  "V050-05-RUNTIME-EVENT-ENVELOPE"
require_file_contains \
  "docs/contracts/release-v0.5.0-typed-runtime-messagebus-contract.md" \
  "V050-05-RUN-CORRELATION-CAUSATION-CHECKSUM"
require_file_contains \
  "docs/contracts/release-v0.5.0-typed-runtime-messagebus-contract.md" \
  "TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-messagebus.sh"

reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "URLSession"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "URLRequest"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "api.binance.com"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "fapi.binance.com"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "submitOrder"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "cancelOrder"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "replaceOrder"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "HMAC<"

echo "MTPRO release v0.5.0 runtime MessageBus actor verification passed."
