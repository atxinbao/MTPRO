#!/usr/bin/env bash
set -euo pipefail

# GH-756-VERIFY-V060-LOCAL-RUN-JOURNAL-WRITER
# TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 local run journal writer verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.6.0 local run journal writer verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH756LocalRunJournalWriterPersistsArtifactsAndClassifiesIncompleteRuns

require_file_contains "Package.swift" "\"ReleaseV060LocalRunJournalWriter.swift\""
require_file_contains "Package.swift" "\"Database/ReleaseV060LocalRunJournalWriter.swift\""
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "ReleaseV060LocalRunJournalWriter"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "events.jsonl"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "projection.json"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "summary.json"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "_RUN_STATUS.json"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "manifest.json"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" ".atomic"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-LOCAL-RUN-JOURNAL-WRITER"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-RUN-DIRECTORY-SHAPE"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-APPEND-ONLY-EVENTS-JSONL"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-ATOMIC-PROJECTION-SUMMARY-STATUS-MANIFEST"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-MANIFEST-WRITTEN-LAST"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "V060-002-FAILED-INCOMPLETE-NOT-COMPLETED"
require_file_contains "docs/contracts/release-v0.6.0-local-run-journal-writer-contract.md" "TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-run-journal-writer.sh"
require_file_contains "checks/automation-readiness.sh" "GH-756-VERIFY-V060-LOCAL-RUN-JOURNAL-WRITER"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER"
require_file_contains "docs/validation/validation-plan.md" "GH-756 Release v0.6.0 Local Run Journal Writer Validation"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 local run journal writer anchor"

reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "URLSession"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "URLRequest"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "api.binance.com"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "fapi.binance.com"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "submitOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "cancelOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "replaceOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "HMAC<"

echo "MTPRO release v0.6.0 local run journal writer verification passed."
