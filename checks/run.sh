#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_command() {
  local command_name="$1"
  local setup_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "MTPRO setup hint: missing required command '$command_name'."
    echo "$setup_hint"
    exit 1
  fi
}

require_sqlite_pkg_config() {
  require_command "pkg-config" "Install pkg-config before running SwiftPM checks. On Ubuntu: sudo apt-get install -y pkg-config libsqlite3-dev. On macOS with Homebrew: brew install pkg-config sqlite."

  if ! pkg-config --exists sqlite3; then
    echo "MTPRO setup hint: sqlite3 pkg-config metadata is unavailable."
    echo "Install sqlite development headers before running SwiftPM checks. On Ubuntu: sudo apt-get install -y libsqlite3-dev. On macOS with Homebrew: brew install sqlite pkg-config."
    exit 1
  fi
}

require_swift_toolchain() {
  require_command "swift" "Install Swift 6.3.x or newer before running checks/run.sh. GitHub Actions pins ubuntu-24.04 and verifies the runner Swift 6.3.x toolchain."

  local swift_version_output
  swift_version_output="$(swift --version 2>&1)"

  local swift_version
  swift_version="$(printf '%s\n' "$swift_version_output" | grep -m 1 -Eo "(Apple )?Swift version [0-9]+\\.[0-9]+([^[:space:]]*)?( \\([^)]*\\))?" || true)"

  local parsed_version
  parsed_version="$(printf '%s\n' "$swift_version" | sed -nE 's/.*Swift version ([0-9]+)\.([0-9]+)([ .].*)?/\1 \2/p' | head -n 1)"

  if [[ -z "$parsed_version" ]]; then
    echo "MTPRO setup hint: unable to parse Swift toolchain version."
    echo "Observed:"
    printf '%s\n' "$swift_version_output"
    echo "Install Swift 6.3.x or newer before running checks/run.sh."
    exit 1
  fi

  local swift_major swift_minor
  read -r swift_major swift_minor <<< "$parsed_version"

  if (( swift_major < 6 || (swift_major == 6 && swift_minor < 3) )); then
    echo "MTPRO setup hint: Swift 6.3.x or newer is required for reproducible local checks."
    echo "Observed: $swift_version"
    echo "GitHub Actions pins ubuntu-24.04 and verifies the runner Swift 6.3.x toolchain; local validation must match that baseline or newer."
    exit 1
  fi

  echo "MTPRO local Swift toolchain accepted: $swift_version"
}

require_swift_toolchain
require_sqlite_pkg_config

git diff --check
bash checks/automation-readiness.sh
bash checks/release-v0.1.0-dryrun-testnet.sh
bash checks/verify-v0.3.0.sh
bash checks/verify-v0.3.1.sh
bash checks/verify-v0.4.0.sh
bash checks/verify-v0.5.0-preflight.sh
bash checks/verify-v0.5.0-ci-hardening.sh
bash checks/verify-v0.5.0-cli.sh
bash checks/verify-v0.5.0-environment.sh
bash checks/verify-v0.5.0-instrument-catalog.sh
bash checks/verify-v0.5.0-messagebus.sh
bash checks/verify-v0.5.0-run-journal.sh
bash checks/verify-v0.5.0-dataengine.sh
bash checks/verify-v0.5.0-testnet-readonly.sh
bash checks/verify-v0.5.0-riskengine.sh
bash checks/verify-v0.5.0-oms.sh
bash checks/verify-v0.5.0-portfolio.sh
bash checks/verify-v0.5.0-observer.sh
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
bash checks/verify-v0.6.0.sh
bash checks/verify-v0.7.0-contract.sh
bash checks/verify-v0.7.0-testnet-endpoint-policy.sh
bash checks/verify-v0.7.0-cli.sh
bash checks/verify-v0.7.0-operational-run-session.sh
bash checks/verify-v0.7.0-event-log-writer-recovery.sh
bash checks/verify-v0.7.0-run-registry-supervisor.sh
bash checks/verify-v0.7.0-testnet-signed-account-readonly-probe.sh
bash checks/verify-v0.7.0-testnet-private-stream-readonly-probe.sh
bash checks/verify-v0.7.0-dashboard-readonly-run-operations.sh
bash checks/verify-v0.7.0-local-risk-policy-config.sh
bash checks/verify-v0.7.0-portfolio-readonly-reconciliation.sh
bash checks/verify-v0.7.0.sh
bash checks/verify-v0.8.0-contract.sh
bash checks/verify-v0.8.0-release-publication-policy.sh
bash checks/verify-v0.8.1-v080-release-publication-docs.sh
bash checks/verify-v0.8.1-cli-verify-v080-wording.sh
bash checks/verify-v0.8.1-local-vs-broker-session.sh
bash checks/verify-v0.8.1-status-artifact-role.sh
bash checks/verify-v0.8.1-private-stream-redaction.sh
bash checks/verify-v0.8.1.sh
bash checks/verify-v0.9.0-contract.sh
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
bash checks/verify-v0.10.0.sh
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
bash checks/verify-v0.9.0.sh
bash checks/verify-v0.9.1.sh
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
bash checks/verify-v0.8.0.sh
if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard build and smoke run: SwiftUI shell is macOS-only."
fi
swift test

echo "MTPRO checks passed."
