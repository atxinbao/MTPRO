#!/usr/bin/env bash
set -euo pipefail

# GH-791-VERIFY-V070-CI-RELEASE-VALIDATION-GATE
# TVM-RELEASE-V070-CI-RELEASE-VALIDATION-GATE
# V070-013-AGGREGATE-FOCUSED-GUARDS
# V070-013-CHECKS-RUN-V070-GATE
# V070-013-PRODUCTION-DISABLED-DEFAULTS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.7.0 aggregate validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.7.0 aggregate validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

bash checks/verify-v0.7.0-contract.sh
bash checks/verify-v0.7.0-testnet-endpoint-policy.sh
bash checks/verify-v0.7.0-cli.sh
bash checks/verify-v0.7.0-dashboard-macos-guards.sh
bash checks/verify-v0.7.0-operational-run-session.sh
bash checks/verify-v0.7.0-event-log-writer-recovery.sh
bash checks/verify-v0.7.0-run-registry-supervisor.sh
bash checks/verify-v0.7.0-testnet-signed-account-readonly-probe.sh
bash checks/verify-v0.7.0-testnet-private-stream-readonly-probe.sh
bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh
bash checks/verify-v0.7.0-local-risk-policy-config.sh
bash checks/verify-v0.7.0-portfolio-readonly-reconciliation.sh

require_file_contains "checks/run.sh" "bash checks/verify-v0.7.0.sh"
require_file_contains "checks/automation-readiness.sh" "GH-791-VERIFY-V070-CI-RELEASE-VALIDATION-GATE"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.7.0 CI / release validation gate anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-791 Release v0.7.0 CI / Release Validation Gate"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V070-CI-RELEASE-VALIDATION-GATE"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH791ReleaseV070AggregateValidationGateCoversFocusedGuardsAndProductionDisabledDefaults"

for script in \
  "bash checks/verify-v0.7.0-contract.sh" \
  "bash checks/verify-v0.7.0-testnet-endpoint-policy.sh" \
  "bash checks/verify-v0.7.0-cli.sh" \
  "bash checks/verify-v0.7.0-dashboard-macos-guards.sh" \
  "bash checks/verify-v0.7.0-operational-run-session.sh" \
  "bash checks/verify-v0.7.0-event-log-writer-recovery.sh" \
  "bash checks/verify-v0.7.0-run-registry-supervisor.sh" \
  "bash checks/verify-v0.7.0-testnet-signed-account-readonly-probe.sh" \
  "bash checks/verify-v0.7.0-testnet-private-stream-readonly-probe.sh" \
  "bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh" \
  "bash checks/verify-v0.7.0-local-risk-policy-config.sh" \
  "bash checks/verify-v0.7.0-portfolio-readonly-reconciliation.sh"; do
  if [[ "$script" != "bash checks/verify-v0.7.0-dashboard-macos-guards.sh" ]]; then
    require_file_contains "checks/run.sh" "$script"
  fi
  require_file_contains "checks/verify-v0.7.0.sh" "$script"
done
require_file_contains ".github/workflows/checks.yml" "bash checks/verify-v0.7.0-dashboard-macos-guards.sh"

for anchor in \
  "GH-779-VERIFY-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT" \
  "GH-780-VERIFY-V070-TESTNET-ENDPOINT-POLICY" \
  "GH-781-VERIFY-V070-CLI-RUNTIME-SESSION-SURFACE" \
  "GH-782-VERIFY-V070-DASHBOARD-MACOS-GUARDS" \
  "GH-783-VERIFY-V070-OPERATIONAL-RUN-SESSION" \
  "GH-784-VERIFY-V070-EVENT-LOG-WRITER-RECOVERY" \
  "GH-785-VERIFY-V070-RUN-REGISTRY-SUPERVISOR" \
  "GH-786-VERIFY-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE" \
  "GH-787-VERIFY-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE" \
  "GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS" \
  "GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG" \
  "GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION" \
  "GH-791-VERIFY-V070-CI-RELEASE-VALIDATION-GATE"; do
  require_file_contains "checks/automation-readiness.sh" "$anchor"
done

reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionTradingEnabledByDefault=true"
reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionSecretRead=true"
reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionEndpointConnected=true"
reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionBrokerConnected=true"
reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionOrderSubmitted=true"
reject_file_contains "docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md" "productionCutoverAuthorized=true"

echo "MTPRO release v0.7.0 aggregate CI / release validation gate passed."
