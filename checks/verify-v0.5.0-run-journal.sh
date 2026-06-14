#!/usr/bin/env bash
set -euo pipefail

# GH-731-VERIFY-V050-DURABLE-LOCAL-RUN-JOURNAL
# TVM-RELEASE-V050-DURABLE-LOCAL-RUN-JOURNAL

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 run journal verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 run journal verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH731DurableLocalRunJournalPersistsTypedEnvelopeShapeAndReplaysOneRun

require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  "ReleaseV050DurableLocalRunJournal"
require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  "ReleaseV050RunJournalReplayCursor"
require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  ".local/mtpro/runs"
require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  "events.jsonl"
require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  "projection.json"
require_file_contains \
  "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" \
  "summary.json"
require_file_contains \
  "Package.swift" \
  "\"ReleaseV050DurableLocalRunJournal.swift\""
require_file_contains \
  "Package.swift" \
  "\"Database/ReleaseV050DurableLocalRunJournal.swift\""
require_file_contains \
  "docs/contracts/release-v0.5.0-durable-local-run-journal-contract.md" \
  "V050-06-DURABLE-LOCAL-RUN-JOURNAL"
require_file_contains \
  "docs/contracts/release-v0.5.0-durable-local-run-journal-contract.md" \
  "V050-06-LOCAL-RUN-STORAGE-SHAPE"
require_file_contains \
  "docs/contracts/release-v0.5.0-durable-local-run-journal-contract.md" \
  "V050-06-APPEND-ONLY-REPLAY-CURSOR"
require_file_contains \
  "docs/contracts/release-v0.5.0-durable-local-run-journal-contract.md" \
  "V050-06-NO-SECRET-ENDPOINT-LEAKAGE"
require_file_contains \
  "docs/contracts/release-v0.5.0-durable-local-run-journal-contract.md" \
  "TVM-RELEASE-V050-DURABLE-LOCAL-RUN-JOURNAL"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-run-journal.sh"

reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "URLSession"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "URLRequest"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "api.binance.com"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "fapi.binance.com"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "submitOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "cancelOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "replaceOrder"
reject_file_contains "Sources/Database/ReleaseV050DurableLocalRunJournal.swift" "HMAC<"

echo "MTPRO release v0.5.0 durable local run journal verification passed."
