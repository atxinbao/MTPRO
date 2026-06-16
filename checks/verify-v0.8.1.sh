#!/usr/bin/env bash
set -euo pipefail

# GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES
# GH-841-RELEASE-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES
# TVM-RELEASE-V081-PATCH-CLOSEOUT
# V081-007-PATCH-EVIDENCE-CHAIN
# V081-007-PATCH-AUDIT
# V081-007-PATCH-RELEASE-NOTES
# V081-007-QUEUE-CLOSURE-STATE
# V081-007-NO-RELEASE-TAG-CREATION
# V081-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 patch closeout validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.1 patch closeout validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.8.1-v080-release-publication-docs.sh
bash checks/verify-v0.8.1-dashboard-macos-v080-guards.sh
bash checks/verify-v0.8.1-cli-verify-v080-wording.sh
bash checks/verify-v0.8.1-local-vs-broker-session.sh
bash checks/verify-v0.8.1-status-artifact-role.sh
bash checks/verify-v0.8.1-private-stream-redaction.sh

AUDIT="docs/audit/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-notes.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
LATEST_SUMMARY="docs/validation/latest-verification-summary.md"

require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1.sh"
require_file_contains "$AUDIT" "GH-841-RELEASE-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES"
require_file_contains "$AUDIT" "GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES"
require_file_contains "$AUDIT" "TVM-RELEASE-V081-PATCH-CLOSEOUT"
require_file_contains "$AUDIT" 'PR `#842`'
require_file_contains "$AUDIT" 'PR `#857`'
require_file_contains "$AUDIT" 'PR `#858`'
require_file_contains "$AUDIT" 'PR `#859`'
require_file_contains "$AUDIT" 'PR `#860`'
require_file_contains "$AUDIT" 'PR `#861`'
require_file_contains "$AUDIT" "open PR before #841 preflight | 0"
require_file_contains "$AUDIT" "v0.8.1 release tag is not created by this closeout"
require_file_contains "$NOTES" "MTPRO Release v0.8.1 Release Publication + Dashboard Guard Patch Notes"
require_file_contains "$NOTES" "v0.8.1 是 v0.8.0 public release publication 后的 patch evidence closeout"
require_file_contains "$NOTES" "Do not create the release tag unless explicitly requested after merge"
require_file_contains "README.md" "v0.8.1 patch evidence"
require_file_contains "$LATEST_SUMMARY" "Release v0.8.1 Patch Closeout Snapshot"
require_file_contains "$LATEST_SUMMARY" "$AUDIT"
require_file_contains "$VALIDATION_PLAN" "GH-841 Release v0.8.1 Patch Audit / Docs / Release Notes Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V081-PATCH-CLOSEOUT"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.1 patch audit / docs / release notes anchor"
require_file_contains "$AUTOMATION_SCRIPT" "GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES"

for anchor in \
  "GH-835-V081-V080-ACTUAL-GITHUB-RELEASE" \
  "GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS" \
  "GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING" \
  "GH-838-VERIFY-V081-LOCAL-VS-BROKER-SESSION" \
  "GH-839-VERIFY-V081-STATUS-ARTIFACT-ROLE" \
  "GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION" \
  "GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES"; do
  require_file_contains "$AUDIT" "$anchor"
  require_file_contains "$NOTES" "$anchor"
  require_file_contains "$AUTOMATION_SCRIPT" "$anchor"
done

for script in \
  "bash checks/verify-v0.8.1-v080-release-publication-docs.sh" \
  "bash checks/verify-v0.8.1-dashboard-macos-v080-guards.sh" \
  "bash checks/verify-v0.8.1-cli-verify-v080-wording.sh" \
  "bash checks/verify-v0.8.1-local-vs-broker-session.sh" \
  "bash checks/verify-v0.8.1-status-artifact-role.sh" \
  "bash checks/verify-v0.8.1-private-stream-redaction.sh"; do
  require_file_contains "checks/verify-v0.8.1.sh" "$script"
done

for script in \
  "bash checks/verify-v0.8.1-v080-release-publication-docs.sh" \
  "bash checks/verify-v0.8.1-cli-verify-v080-wording.sh" \
  "bash checks/verify-v0.8.1-local-vs-broker-session.sh" \
  "bash checks/verify-v0.8.1-status-artifact-role.sh" \
  "bash checks/verify-v0.8.1-private-stream-redaction.sh"; do
  require_file_contains "checks/run.sh" "$script"
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
done

echo "MTPRO release v0.8.1 patch audit / docs / release notes validation passed."
