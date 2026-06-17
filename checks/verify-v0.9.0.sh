#!/usr/bin/env bash
set -euo pipefail

# GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK
# GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK
# TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK
# V090-014-VALIDATION-SUMMARY
# V090-014-STAGE-CODE-AUDIT
# V090-014-RELEASE-NOTES
# V090-014-OPERATOR-RUNBOOK
# V090-014-ROOT-DOCS-REFRESH
# V090-014-AGGREGATE-VERIFY
# V090-014-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.9.0-contract.sh
bash checks/verify-v0.9.0-v080-publication-alignment.sh
bash checks/verify-v0.9.0-monitor-session-store.sh
bash checks/verify-v0.9.0-snapshot-freshness-monitor.sh
bash checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh
bash checks/verify-v0.9.0-monitor-recovery-workflow.sh
bash checks/verify-v0.9.0-dashboard-observability-timeline.sh
bash checks/verify-v0.9.0-alert-read-model.sh
bash checks/verify-v0.9.0-portfolio-reconciliation-timeline.sh
bash checks/verify-v0.9.0-risk-policy-application-audit.sh
bash checks/verify-v0.9.0-run-monitor-export-bundle.sh
bash checks/verify-v0.9.0-validation-lanes.sh
bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh
swift test --filter TargetGraphTests/testGH856ReleaseV090FinalAuditDocsRunbookCloseCompletedFactsOnly

AUDIT="docs/audit/mtpro-release-v0.9.0-testnet-no-order-observability-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.9.0-testnet-no-order-observability-notes.md"
RUNBOOK="docs/operators/release-v0.9.0-testnet-no-order-observability-runbook.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0.sh"
require_file_contains "$AUDIT" "GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "V090-014-STAGE-CODE-AUDIT"
require_file_contains "$AUDIT" "MTPRO Release v0.9.0 Testnet No-order Observability"
require_file_contains "$AUDIT" 'Project Closure Count to `43 / 43 (100%)`'
require_file_contains "$NOTES" "MTPRO Release v0.9.0 Testnet No-order Observability Notes"
require_file_contains "$RUNBOOK" "V090-014-VALIDATION-SUMMARY"
require_file_contains "$RUNBOOK" "TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "README.md" "MTPRO Release v0.9.0 Testnet No-order Observability"
require_file_contains "README.md" "bash checks/verify-v0.9.0.sh"
require_file_contains "GOAL.md" "MTPRO Release v0.9.0 Testnet No-order Observability"
require_file_contains "BLUEPRINT.md" "v0.9.0 testnet no-order observability"
require_file_contains "docs/roadmap.md" "GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "docs/roadmap.md" "Project Closure Count: 43 / 43 (100%)"
require_file_contains "docs/validation/latest-verification-summary.md" "Release v0.9.0 Closure Snapshot"
require_file_contains "docs/validation/latest-verification-summary.md" "$AUDIT"
require_file_contains "$VALIDATION_PLAN" "GH-856 Release v0.9.0 Final Audit / Docs / Runbook Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 final audit / docs / runbook anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$TESTS" "testGH856ReleaseV090FinalAuditDocsRunbookCloseCompletedFactsOnly"

for script in \
  "bash checks/verify-v0.9.0-contract.sh" \
  "bash checks/verify-v0.9.0-v080-publication-alignment.sh" \
  "bash checks/verify-v0.9.0-monitor-session-store.sh" \
  "bash checks/verify-v0.9.0-snapshot-freshness-monitor.sh" \
  "bash checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh" \
  "bash checks/verify-v0.9.0-monitor-recovery-workflow.sh" \
  "bash checks/verify-v0.9.0-dashboard-observability-timeline.sh" \
  "bash checks/verify-v0.9.0-alert-read-model.sh" \
  "bash checks/verify-v0.9.0-portfolio-reconciliation-timeline.sh" \
  "bash checks/verify-v0.9.0-risk-policy-application-audit.sh" \
  "bash checks/verify-v0.9.0-run-monitor-export-bundle.sh" \
  "bash checks/verify-v0.9.0-validation-lanes.sh" \
  "bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh"; do
  require_file_contains "checks/run.sh" "$script"
  require_file_contains "checks/verify-v0.9.0.sh" "$script"
done

for anchor in \
  "GH-843-VERIFY-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT" \
  "GH-844-VERIFY-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD" \
  "GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE" \
  "GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS" \
  "GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS" \
  "GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW" \
  "GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE" \
  "GH-850-VERIFY-V090-ALERT-READ-MODEL" \
  "GH-851-VERIFY-V090-PORTFOLIO-RECONCILIATION-TIMELINE" \
  "GH-852-VERIFY-V090-RISK-POLICY-APPLICATION-AUDIT" \
  "GH-853-VERIFY-V090-RUN-MONITOR-EXPORT-BUNDLE" \
  "GH-854-VERIFY-V090-VALIDATION-LANES" \
  "GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX" \
  "GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK"; do
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "ordersSubmitted=true" \
  "testnetOrderRoutingAllowed=true" \
  "testnetOrderSubmissionAllowed=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$RUNBOOK" "$forbidden"
done

echo "MTPRO release v0.9.0 aggregate final audit / docs / runbook validation passed."
