#!/usr/bin/env bash
set -euo pipefail

# GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK
# GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK
# TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK
# V080-014-VALIDATION-SUMMARY
# V080-014-STAGE-CODE-AUDIT
# V080-014-RELEASE-NOTES
# V080-014-OPERATOR-RUNBOOK
# V080-014-ROOT-DOCS-REFRESH
# V080-014-AGGREGATE-VERIFY
# V080-014-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.8.0-contract.sh
bash checks/verify-v0.8.0-release-publication-policy.sh
bash checks/verify-v0.8.0-run-registry-store.sh
bash checks/verify-v0.8.0-cli-local-session.sh
bash checks/verify-v0.8.0-operational-session-store.sh
bash checks/verify-v0.8.0-event-log-writer-crash-recovery.sh
bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh
bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh
bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh
bash checks/verify-v0.8.0-risk-policy-profiles.sh
bash checks/verify-v0.8.0-portfolio-reconciliation-review.sh
bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh
bash checks/verify-v0.8.0-validation-lanes.sh
swift test --filter TargetGraphTests/testGH820ReleaseV080FinalAuditDocsRunbookCloseCompletedFactsOnly

AUDIT="docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md"
RUNBOOK="docs/operators/release-v0.8.0-operator-persistent-runtime-testnet-readonly-monitoring-runbook.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0.sh"
require_file_contains "$AUDIT" "GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUDIT" "V080-014-STAGE-CODE-AUDIT"
require_file_contains "$AUDIT" "MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring"
require_file_contains "$AUDIT" 'Project Closure Count to `42 / 42 (100%)`'
require_file_contains "$NOTES" "MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring Notes"
require_file_contains "$RUNBOOK" "V080-014-VALIDATION-SUMMARY"
require_file_contains "$RUNBOOK" "TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "README.md" "MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring"
require_file_contains "README.md" "bash checks/verify-v0.8.0.sh"
require_file_contains "GOAL.md" "MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring"
require_file_contains "BLUEPRINT.md" "v0.8.0 persistent operator runtime + testnet read-only monitoring"
require_file_contains "docs/roadmap.md" "GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "docs/roadmap.md" "Project Closure Count: 42 / 42 (100%)"
require_file_contains "docs/validation/latest-verification-summary.md" "Release v0.8.0 Closure Snapshot"
require_file_contains "docs/validation/latest-verification-summary.md" "$AUDIT"
require_file_contains "$VALIDATION_PLAN" "GH-820 Release v0.8.0 Final Audit / Docs / Runbook Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.0 final audit / docs / runbook anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$TESTS" "testGH820ReleaseV080FinalAuditDocsRunbookCloseCompletedFactsOnly"

for script in \
  "bash checks/verify-v0.8.0-contract.sh" \
  "bash checks/verify-v0.8.0-release-publication-policy.sh" \
  "bash checks/verify-v0.8.0-run-registry-store.sh" \
  "bash checks/verify-v0.8.0-cli-local-session.sh" \
  "bash checks/verify-v0.8.0-operational-session-store.sh" \
  "bash checks/verify-v0.8.0-event-log-writer-crash-recovery.sh" \
  "bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh" \
  "bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh" \
  "bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh" \
  "bash checks/verify-v0.8.0-risk-policy-profiles.sh" \
  "bash checks/verify-v0.8.0-portfolio-reconciliation-review.sh" \
  "bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh" \
  "bash checks/verify-v0.8.0-validation-lanes.sh"; do
  require_file_contains "checks/run.sh" "$script"
  require_file_contains "checks/verify-v0.8.0.sh" "$script"
done

for anchor in \
  "GH-807-VERIFY-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT" \
  "GH-808-RELEASE-PUBLICATION-POLICY" \
  "GH-809-VERIFY-V080-RUN-REGISTRY-STORE" \
  "GH-810-VERIFY-V080-CLI-LOCAL-SESSION" \
  "GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE" \
  "GH-812-VERIFY-V080-EVENT-LOG-WRITER-CRASH-RECOVERY" \
  "GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF" \
  "GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING" \
  "GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR" \
  "GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT" \
  "GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW" \
  "GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS" \
  "GH-819-VERIFY-V080-VALIDATION-LANES" \
  "GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK"; do
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
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$RUNBOOK" "$forbidden"
done

echo "MTPRO release v0.8.0 aggregate final audit / docs / runbook validation passed."
