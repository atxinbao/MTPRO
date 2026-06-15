#!/usr/bin/env bash
set -euo pipefail

# GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION
# TVM-RELEASE-V070-PORTFOLIO-READONLY-RECONCILIATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 Portfolio read-only reconciliation verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 Portfolio read-only reconciliation verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Portfolio/ReleaseV070PortfolioReadOnlyReconciliationProjection.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH790PortfolioReadOnlyReconciliationExplainsExpectedVsObservedWithoutCommands

require_file_contains "$SOURCE" "ReleaseV070PortfolioReadOnlyReconciliationProjection"
require_file_contains "$SOURCE" "ReleaseV070PortfolioReadOnlyObservedState"
require_file_contains "$SOURCE" "ReleaseV070PortfolioReadOnlyReconciliationDiffRecord"
require_file_contains "$SOURCE" "ReleaseV070PortfolioReadOnlyReconciliationEvidence"
require_file_contains "$SOURCE" "diffArtifactsExplainOnly"
require_file_contains "$SOURCE" "correctionCommandCreated"
require_file_contains "$SOURCE" "brokerWritePathCreated"
require_file_contains "$SOURCE" "productionAccountReadRequired"
require_file_contains "$TESTS" "testGH790PortfolioReadOnlyReconciliationExplainsExpectedVsObservedWithoutCommands"
require_file_contains "Package.swift" "\"ReleaseV070PortfolioReadOnlyReconciliationProjection.swift\""
require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0-portfolio-readonly-reconciliation.sh"
require_file_contains "docs/validation/validation-plan.md" \
  "GH-790 Release v0.7.0 Portfolio Read-only Reconciliation Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V070-PORTFOLIO-READONLY-RECONCILIATION"
require_file_contains "docs/automation/automation-readiness.md" \
  "Release v0.7.0 Portfolio read-only reconciliation anchor"
require_file_contains "checks/automation-readiness.sh" \
  "GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION"

for anchor in \
  "GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION" \
  "TVM-RELEASE-V070-PORTFOLIO-READONLY-RECONCILIATION" \
  "V070-012-JOURNAL-EXPECTED-VS-TESTNET-OBSERVED" \
  "V070-012-DIFF-ARTIFACTS-EXPLAIN-ONLY" \
  "V070-012-NO-CORRECTION-COMMAND" \
  "V070-012-NO-PRODUCTION-ACCOUNT-READ" \
  "V070-012-READONLY-RECONCILIATION-PROJECTION"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

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
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"

echo "MTPRO release v0.7.0 Portfolio read-only reconciliation verification passed."
