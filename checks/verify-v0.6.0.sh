#!/usr/bin/env bash
set -euo pipefail

# GH-766-VERIFY-V060-FINAL-AUDIT-ROOT-DOCS
# TVM-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS

require_file_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.6.0 final verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.6.0 final verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

bash checks/verify-v0.6.0-boundary.sh
bash checks/verify-v0.6.0-run-journal-writer.sh
bash checks/verify-v0.6.0-run-manifest-checksum.sh
bash checks/verify-v0.6.0-runtime-sha256-checksum.sh
bash checks/verify-v0.6.0-dataengine-local-dry-run-runner.sh
bash checks/verify-v0.6.0-strategy-runtime-runner.sh
bash checks/verify-v0.6.0-riskengine-runtime-runner.sh
bash checks/verify-v0.6.0-execution-oms-dry-run-runner.sh
bash checks/verify-v0.6.0-portfolio-journal-projection.sh
bash checks/verify-v0.6.0-run-detail-observer.sh
bash checks/verify-v0.6.0-testnet-readonly-probe.sh

require_file_contains "docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md" "GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md" "TVM-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "docs/release/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-notes.md" "Release v0.6.0"
require_file_contains "docs/operators/release-v0.6.0-operator-local-operational-runtime-testnet-readonly-probe-runbook.md" "V060-12-VALIDATION-SUMMARY"
require_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" "MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening"
require_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" "MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening"
require_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md" "MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening"
require_file_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md" "GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "docs/validation/latest-verification-summary.md" "GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "docs/validation/validation-plan.md" "GH-766 Release v0.6.0 Final Audit Root Docs Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.6.0 final audit / root docs anchor"
require_file_contains "checks/automation-readiness.sh" "GH-766-VERIFY-V060-FINAL-AUDIT-ROOT-DOCS"
require_file_contains "checks/run.sh" "bash checks/verify-v0.6.0.sh"

reject_file_contains "docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md" "productionTradingEnabledByDefault == true"
reject_file_contains "docs/release/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-notes.md" "productionCutoverAuthorized=true"
reject_file_contains "docs/operators/release-v0.6.0-operator-local-operational-runtime-testnet-readonly-probe-runbook.md" "productionOrderSubmitted=true"

echo "MTPRO release v0.6.0 final audit / root docs verification passed."
