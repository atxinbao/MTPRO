#!/usr/bin/env bash
set -euo pipefail

# GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK
# GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK
# TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK
# V0100-014-VALIDATION-SUMMARY
# V0100-014-STAGE-CODE-AUDIT
# V0100-014-RELEASE-NOTES
# V0100-014-OPERATOR-RUNBOOK
# V0100-014-ROOT-DOCS-REFRESH
# V0100-014-AGGREGATE-VERIFY
# V0100-014-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.10.0-contract.sh
bash checks/verify-v0.10.0-release-policy.sh
bash checks/verify-v0.10.1-release-fact-sync.sh
bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh
bash checks/verify-v0.10.0-production-environment-profile.sh
bash checks/verify-v0.10.0-secret-provider-readiness-gate.sh
bash checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh
bash checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh
bash checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh
bash checks/verify-v0.10.0-command-surface-disabled.sh
bash checks/verify-v0.10.0-shadow-dry-run-parity.sh
bash checks/verify-v0.10.0-production-readiness-bundle.sh
bash checks/verify-v0.10.0-cutover-approval-workflow.sh
bash checks/verify-v0.10.0-incident-rollback-runbook.sh
bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh
bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh

AUDIT="docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md"
RUNBOOK="docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
LATEST="docs/validation/latest-verification-summary.md"

for file in "$AUDIT" "$NOTES" "$RUNBOOK" "$VALIDATION_PLAN" "$TRADING_MATRIX" "$AUTOMATION_DOC" "$AUTOMATION_SCRIPT" "$LATEST"; do
  require_file_contains "$file" "v0.10.0"
done

for anchor in \
  "GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK" \
  "GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK" \
  "TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK" \
  "V0100-014-VALIDATION-SUMMARY" \
  "V0100-014-STAGE-CODE-AUDIT" \
  "V0100-014-RELEASE-NOTES" \
  "V0100-014-OPERATOR-RUNBOOK" \
  "V0100-014-ROOT-DOCS-REFRESH" \
  "V0100-014-AGGREGATE-VERIFY" \
  "V0100-014-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$RUNBOOK" "$anchor"
  require_file_contains "$TRADING_MATRIX" "$anchor"
  require_file_contains "$VALIDATION_PLAN" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0.sh"
require_file_contains "$AUDIT" "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
require_file_contains "$AUDIT" "Project Closure Count to \`44 / 44 (100%)\`"
require_file_contains "$NOTES" "MTPRO Release v0.10.0 Production Cutover Readiness Gate Notes"
require_file_contains "$RUNBOOK" "MTPRO Release v0.10.0 Production Cutover Readiness Gate Runbook"
require_file_contains "README.md" "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
require_file_contains "README.md" "bash checks/verify-v0.10.0.sh"
require_file_contains "GOAL.md" "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
require_file_contains "BLUEPRINT.md" "v0.10.0 production cutover readiness gate"
require_file_contains "docs/roadmap.md" "GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "docs/roadmap.md" "Project Closure Count: 44 / 44 (100%)"
require_file_contains "$LATEST" "Release v0.10.0 Closure Snapshot"
require_file_contains "$LATEST" "$AUDIT"
require_file_contains "$VALIDATION_PLAN" "GH-891 Release v0.10.0 Final Audit / Docs / Runbook Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK"
require_file_contains "$AUTOMATION_DOC" "Release v0.10.0 final audit / docs / runbook anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK"

for script in \
  "bash checks/verify-v0.10.0-contract.sh" \
  "bash checks/verify-v0.10.0-release-policy.sh" \
  "bash checks/verify-v0.10.1-release-fact-sync.sh" \
  "bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh" \
  "bash checks/verify-v0.10.0-production-environment-profile.sh" \
  "bash checks/verify-v0.10.0-secret-provider-readiness-gate.sh" \
  "bash checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh" \
  "bash checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh" \
  "bash checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh" \
  "bash checks/verify-v0.10.0-command-surface-disabled.sh" \
  "bash checks/verify-v0.10.0-shadow-dry-run-parity.sh" \
  "bash checks/verify-v0.10.0-production-readiness-bundle.sh" \
  "bash checks/verify-v0.10.0-cutover-approval-workflow.sh" \
  "bash checks/verify-v0.10.0-incident-rollback-runbook.sh" \
  "bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh" \
  "bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh"; do
  require_file_contains "checks/run.sh" "$script"
  require_file_contains "checks/verify-v0.10.0.sh" "$script"
done

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "brokerEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "realOrderSubmissionEnabled=true" \
  "testnetOrderRoutingAllowed=true" \
  "testnetOrderSubmissionAllowed=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$RUNBOOK" "$forbidden"
done

echo "MTPRO release v0.10.0 aggregate final audit / docs / runbook validation passed."
