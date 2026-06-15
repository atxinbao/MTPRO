#!/usr/bin/env bash
set -euo pipefail

# GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW
# TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 Portfolio reconciliation review verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 Portfolio reconciliation review verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/Portfolio/ReleaseV080PortfolioReconciliationReviewWorkflow.swift"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH817PortfolioReconciliationReviewWorkflowRequiresAuditOnlyAcknowledgement

require_file_contains "$SOURCE" "ReleaseV080PortfolioReconciliationReviewWorkflow"
require_file_contains "$SOURCE" "ReleaseV080PortfolioReconciliationReviewStatus"
require_file_contains "$SOURCE" "ReleaseV080PortfolioReconciliationOperatorAcknowledgement"
require_file_contains "$SOURCE" "ReleaseV080PortfolioReconciliationReviewAuditArtifact"
require_file_contains "$SOURCE" "ReleaseV080PortfolioReconciliationReviewEvidence"
require_file_contains "$SOURCE" "reviewRequired"
require_file_contains "$SOURCE" "operatorNote"
require_file_contains "$SOURCE" "acknowledgedAt"
require_file_contains "$SOURCE" "acknowledgedBy"
require_file_contains "$SOURCE" "staleObservedState"
require_file_contains "$SOURCE" "auditTrailArtifacts"
require_file_contains "$TESTS" "testGH817PortfolioReconciliationReviewWorkflowRequiresAuditOnlyAcknowledgement"
require_file_contains "Package.swift" "\"ReleaseV080PortfolioReconciliationReviewWorkflow.swift\""
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-portfolio-reconciliation-review.sh"
require_file_contains "docs/validation/validation-plan.md" \
  "GH-817 Release v0.8.0 Portfolio Reconciliation Review Workflow Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" \
  "TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW"
require_file_contains "docs/automation/automation-readiness.md" \
  "Release v0.8.0 Portfolio reconciliation review workflow anchor"
require_file_contains "checks/automation-readiness.sh" \
  "GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW"

for anchor in \
  "GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW" \
  "TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW" \
  "V080-011-RECONCILIATION-STATUS-MATCHED-DELTA-MISSING-STALE" \
  "V080-011-REVIEW-REQUIRED-OPERATOR-NOTE-ACK" \
  "V080-011-STALE-OBSERVED-STATE" \
  "V080-011-AUDIT-TRAIL-ARTIFACTS" \
  "V080-011-NO-CORRECTION-COMMAND-BROKER-WRITE" \
  "V080-011-PORTFOLIO-REVIEW-WORKFLOW"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "$SOURCE" "URLSession"
reject_file_contains "$SOURCE" "URLRequest"
reject_file_contains "$SOURCE" "api.binance.com"
reject_file_contains "$SOURCE" "fapi.binance.com"
reject_file_contains "$SOURCE" "/api/v3/order"
reject_file_contains "$SOURCE" "/api/v3/userDataStream"
reject_file_contains "$SOURCE" "submitOrder"
reject_file_contains "$SOURCE" "cancelOrder"
reject_file_contains "$SOURCE" "replaceOrder"
reject_file_contains "$SOURCE" "HMAC<"
reject_file_contains "$SOURCE" "productionCutoverAuthorized = true"

echo "MTPRO release v0.8.0 Portfolio reconciliation review workflow verification passed."
