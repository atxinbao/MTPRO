#!/usr/bin/env bash
set -euo pipefail

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 Portfolio journal projection verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 Portfolio journal projection verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

GH763="GH-763-VERIFY-V060-PORTFOLIO-JOURNAL-PROJECTION"
TVM763="TVM-RELEASE-V060-PORTFOLIO-JOURNAL-PROJECTION"
SOURCE="Sources/Portfolio/ReleaseV060PortfolioJournalProjectionRunner.swift"

swift test --filter TargetGraphTests/testGH763PortfolioJournalProjectionRebuildsProjectionJSONFromRealRunJournal

require_file_contains "$SOURCE" "ReleaseV060PortfolioJournalProjectionRunner"
require_file_contains "$SOURCE" "ReleaseV050PortfolioRunJournalProjection"
require_file_contains "$SOURCE" "ReleaseV060LocalRunJournalWriter"
require_file_contains "$SOURCE" "projectionJSON"
require_file_contains "$SOURCE" "ReleaseV050DurableLocalRunJournal"
require_file_contains "Sources/Database/ReleaseV060LocalRunJournalWriter.swift" "projectionJSON: String? = nil"
require_file_contains "Package.swift" "\"ReleaseV060PortfolioJournalProjectionRunner.swift\""
require_file_contains "Package.swift" "\"Portfolio/ReleaseV060PortfolioJournalProjectionRunner.swift\""

require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "V060-009-PORTFOLIO-JOURNAL-PROJECTION"
require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "V060-009-JOURNAL-REPLAY-TO-PROJECTION-JSON"
require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "V060-009-FIXED-POINT-EXPOSURE-NOTIONAL-QUANTITY"
require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "V060-009-MANIFEST-VALIDATED-PROJECTION-ARTIFACT"
require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "V060-009-NO-BROKER-ACCOUNT-PAYLOAD"
require_file_contains "docs/contracts/release-v0.6.0-portfolio-journal-projection-contract.md" "$TVM763"
require_file_contains "docs/validation/trading-validation-matrix.md" "$TVM763"
require_file_contains "docs/validation/validation-plan.md" "GH-763 Release v0.6.0 Portfolio Journal Projection Validation"
require_file_contains "docs/validation/validation-plan.md" "$GH763"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 Portfolio journal projection anchor"
require_file_contains "checks/automation-readiness.sh" "$GH763"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0-portfolio-journal-projection.sh"

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "/api/v3/account"
reject_file_contains "$SOURCE" "/api/v3/order"
reject_file_contains "$SOURCE" "/api/v3/userDataStream"
reject_file_contains "$SOURCE" "listenKey"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"

echo "MTPRO release v0.6.0 Portfolio journal projection verification passed."
