#!/usr/bin/env bash
set -euo pipefail

# GH-758-VERIFY-V060-RUNTIME-SHA256-CHECKSUM
# TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 runtime sha256 checksum verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.6.0 runtime sha256 checksum verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH758RuntimeMessageBusAndRunJournalUseSHA256AuditChecksums

require_file_contains "Package.swift" "name: \"Crypto\", package: \"swift-crypto\""
require_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "import Crypto"
require_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "SHA256.hash"
require_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "journalSHA256"
require_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "previousJournalSHA256"
require_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "latestJournalSHA256"
require_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "sha256JournalChainAvailable"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "V060-004-RUNTIME-EVENT-SHA256-CHECKSUM"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "V060-004-JOURNAL-SHA256-CHAIN"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "V060-004-FNV-COMPATIBILITY-EVIDENCE"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "V060-004-CHECKSUM-MISMATCH-FAILS-VALIDATION"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "V060-004-NO-PRODUCTION-AUTHORIZATION"
require_file_contains "docs/contracts/release-v0.6.0-runtime-sha256-checksum-contract.md" "TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-runtime-sha256-checksum.sh"
require_file_contains "checks/automation-readiness.sh" "GH-758-VERIFY-V060-RUNTIME-SHA256-CHECKSUM"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM"
require_file_contains "docs/validation/validation-plan.md" "GH-758 Release v0.6.0 Runtime sha256 Checksum Validation"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 runtime sha256 checksum anchor"

reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "URLSession"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "URLRequest"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "submitOrder"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "cancelOrder"
reject_file_contains "Sources/MessageBus/RuntimeMessageBus.swift" "replaceOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "URLSession"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "URLRequest"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "api.binance.com"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "fapi.binance.com"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "submitOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "cancelOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "replaceOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "HMAC<"

echo "MTPRO release v0.6.0 runtime sha256 checksum verification passed."
