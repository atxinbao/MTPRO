#!/usr/bin/env bash
set -euo pipefail

# GH-757-VERIFY-V060-RUN-MANIFEST-CHECKSUM
# TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 run manifest checksum verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.6.0 run manifest checksum verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH757RunManifestRecordsSha256BytesAndRejectsCorruptedArtifacts

require_file_contains "Package.swift" ".product(name: \"Crypto\", package: \"swift-crypto\")"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "import Crypto"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "ReleaseV060LocalRunJournalArtifactMetadata"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "ReleaseV060LocalRunJournalManifestValidation"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "sha256"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "bytes"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "createdAt"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "required"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "validateRunManifest"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "V060-003-RUN-MANIFEST-ARTIFACT-CHECKSUM"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "V060-003-REQUIRED-ARTIFACT-METADATA"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "V060-003-SHA256-BYTECOUNT-VALIDATION"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "V060-003-MISSING-CORRUPTED-ARTIFACT-REJECTION"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "V060-003-MANIFEST-FINAL-COMPLETION-MARKER"
require_file_contains "docs/contracts/release-v0.6.0-run-manifest-checksum-contract.md" "TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-run-manifest-checksum.sh"
require_file_contains "checks/automation-readiness.sh" "GH-757-VERIFY-V060-RUN-MANIFEST-CHECKSUM"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM"
require_file_contains "docs/validation/validation-plan.md" "GH-757 Release v0.6.0 Run Manifest Checksum Validation"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 run manifest checksum anchor"

reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "URLSession"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "URLRequest"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "api.binance.com"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "fapi.binance.com"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "submitOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "cancelOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "replaceOrder"
reject_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "HMAC<"

echo "MTPRO release v0.6.0 run manifest checksum verification passed."
