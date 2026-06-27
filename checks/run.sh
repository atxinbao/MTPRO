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
# CI-PR-FAST-LANE-RELEASE-MATRIX
# CI-PR-FAST-LANE-REQUIRED-CHECKS
# CI-RELEASE-FULL-LINUX-MACOS-MATRIX
# CI-NO-PRODUCTION-CUTOVER
bash checks/verify-ci-pr-fast-lane-release-matrix.sh
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
bash checks/verify-v0.10.1-readiness-cli-help.sh
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
bash checks/verify-v0.10.1.sh
bash checks/verify-v0.11.0.sh
bash checks/verify-v0.11.1.sh
bash checks/verify-v0.12.0.sh
bash checks/verify-v0.12.1-release-fact-sync.sh
bash checks/verify-v0.12.1-sourcecommit-provenance.sh
bash checks/verify-v0.12.1-local-evidence-metadata.sh
bash checks/verify-v0.12.1-compare-fail-closed.sh
bash checks/verify-v0.12.1-json-inspection-guards.sh
bash checks/verify-v0.12.1-patch-audit-release-notes.sh
bash checks/verify-v0.12.0-dashboard-macos-guards.sh
bash checks/verify-v0.13.0.sh
bash checks/verify-v0.14.0.sh
bash checks/verify-v0.14.0-order-lifecycle.sh
bash checks/verify-v0.14.0-execution-contract.sh
bash checks/verify-v0.14.0-binance-testnet-adapter-boundary.sh
bash checks/verify-v0.14.0-binance-testnet-submit.sh
bash checks/verify-v0.14.0-binance-testnet-cancel-replace.sh
bash checks/verify-v0.14.0-oms-local-order-store.sh
bash checks/verify-v0.14.0-order-event-sourcing.sh
bash checks/verify-v0.14.0-oms-state-sync-engine.sh
bash checks/verify-v0.14.0-pretrade-risk-engine-gate.sh
bash checks/verify-v0.14.0-global-kill-switch.sh
bash checks/verify-v0.14.0-reconciliation-engine.sh
bash checks/verify-v0.14.0-signal-to-execution-pipeline.sh
bash checks/verify-v0.14.0-full-e2e-testnet-suite.sh
bash checks/verify-v0.14.0-failure-simulation-suite.sh
bash checks/verify-v0.14.0-execution-event-log.sh
bash checks/verify-v0.14.0-read-only-execution-dashboard.sh
bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh
bash checks/verify-v0.14.1-codable-decode-validation.sh
bash checks/verify-v0.14.1-submit-evidence-network-guards.sh
bash checks/verify-v0.14.1-golden-json-contracts.sh
bash checks/verify-v0.14.1-dashboard-local-artifacts.sh
bash checks/verify-v0.14.1-patch-audit-release-notes.sh
bash checks/verify-v0.15.0-contract-preflight.sh
bash checks/verify-v0.15.0-testnet-credential-signed-request.sh
bash checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh
bash checks/verify-v0.15.0-network-execution-event-log.sh
bash checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh
bash checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh
bash checks/verify-v0.15.0-oms-state-sync-reconciliation.sh
bash checks/verify-v0.15.0-cli-operator-flow.sh
bash checks/verify-v0.15.0-dashboard-testnet-execution-status.sh
bash checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh
bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
bash checks/verify-v0.15.1-v0150-release-fact-sync.sh
bash checks/verify-v0.15.1-transport-wording.sh
bash checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh
bash checks/verify-v0.15.1-cli-testnet-execution-runtime.sh
bash checks/verify-v0.15.1-runtime-internal-gates.sh
bash checks/verify-v0.15.1-client-order-identity-chain.sh
bash checks/verify-v0.15.1-codable-decode-closeout.sh
bash checks/verify-v0.16.0-operator-beta-contract.sh
bash checks/verify-v0.16.0-operator-run-model.sh
bash checks/verify-v0.16.0-cli-submit-flow.sh
bash checks/verify-v0.16.0-cli-cancel-flow.sh
bash checks/verify-v0.16.0-order-status-query.sh
bash checks/verify-v0.16.0-local-execution-artifact-store.sh
bash checks/verify-v0.16.0-oms-observed-status-reconciliation.sh
bash checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh
bash checks/verify-v0.16.0-failure-recovery-workflow.sh
bash checks/verify-v0.16.0-beta-safety-guards.sh
bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh
# GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS
# V0160-012-STAGE-CODE-AUDIT
# V0160-012-RELEASE-NOTES
# V0160-012-OPERATOR-RUNBOOK
# V0160-012-VALIDATION-MATRIX
# V0160-012-STALE-WORDING-GUARD
# V0160-012-NO-PRODUCTION-CUTOVER
# V0160-012-NO-TAG-OR-RELEASE-PUBLICATION
bash checks/verify-v0.16.0-stage-audit-release-docs.sh
# GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC
# V0161-001-V0160-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC
# V0161-001-V0160-TAG-FIXED
# V0161-001-PATCH-QUEUE-NOT-PUBLICATION
# V0161-001-NO-PRODUCTION-CUTOVER
# v0.16.0 stable release: https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0
# v0.16.0 tag peeled commit: 28779236262bd7ffaf71e286b27b95854c5cd3e1
# v0.16.0 publication timestamp: 2026-06-26T01:29:21Z
bash checks/verify-v0.16.1-release-fact-sync.sh
# GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT
# TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT
# V0161-002-BUNDLE-SCHEMA-PARSED
# V0161-002-ACTION-SEQUENCE-CHECKED
# V0161-002-CHECKSUM-REFERENCES-CHECKED
# V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS
# V0161-002-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.16.1-manual-evidence-bundle-content.sh
# GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
# TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
# V0161-003-SHARED-REDACTION-POLICY-SOURCE
# V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE
# V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE
# V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE
# V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS
# V0161-003-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.16.1-central-artifact-redaction-policy.sh
# GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE
# TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE
# V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS
# V0161-004-SIGNED-QUERY-MARKERS
# V0161-004-PRODUCTION-HOST-MARKERS
# V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS
# V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE
bash checks/verify-v0.16.1-redaction-regression-coverage.sh
# GH-1137-VERIFY-V0161-STATUS-QUERY-TRANSPORT-WORDING
# TVM-RELEASE-V0161-STATUS-QUERY-TRANSPORT-WORDING
# V0161-005-REQUEST-EVIDENCE-FLAG-CLARIFIED
# V0161-005-TRANSPORT-RESULT-EVIDENCE-CLARIFIED
# V0161-005-NO-FAKE-STATUS-QUERY-WORDING
# V0161-005-NO-PRODUCTION-READINESS-OVERSTATEMENT
bash checks/verify-v0.16.1-status-query-transport-wording.sh
# GH-1138-VERIFY-V0161-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES
# V0161-006-PATCH-AUDIT
# V0161-006-RELEASE-NOTES
# V0161-006-VALIDATION-MATRIX
# V0161-006-PUBLICATION-GUIDANCE
# V0161-006-NO-PRODUCTION-CUTOVER
# V0161-006-NO-TAG-OR-RELEASE-PUBLICATION
bash checks/verify-v0.16.1-patch-audit-release-notes.sh
# GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT
# TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT
# V0170-001-V0161-PREFLIGHT-GATE
# V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE
# V0170-001-BINANCE-SPOT-TESTNET-ONLY
# V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED
# V0170-001-QUEUE-ORDER
# V0170-001-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-operator-beta-runtime-hardening-contract.sh
# GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR
# V0170-002-REAL-ARTIFACT-BUNDLE-INGEST
# V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION
# V0170-002-ACTION-SEQUENCE-VALIDATION
# V0170-002-RECONCILIATION-ARTIFACT-REQUIRED
# V0170-002-DETERMINISTIC-PASS-FAIL-RESULT
# V0170-002-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-artifact-bundle-replay-validator.sh
# GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
# TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL
# V0170-003-BOUNDED-STATUS-QUERY-RETRY
# V0170-003-PER-ATTEMPT-TIMEOUT
# V0170-003-CLASSIFIED-FAILURE-EVIDENCE
# V0170-003-RETRY-LIMIT-FAIL-CLOSED
# V0170-003-REDACTED-FAILURE-EVIDENCE
# V0170-003-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-signed-status-query-retry-timeout-failure-model.sh
# GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE
# TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE
# V0170-004-LOCAL-ARTIFACT-STORE-RESUME
# V0170-004-REPLAY-VALIDATION-REQUIRED
# V0170-004-AUDIT-CONTINUITY-PRESERVED
# V0170-004-NO-RESUBMIT-ON-RESUME
# V0170-004-REDACTED-RESUME-EVIDENCE
# V0170-004-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-operator-run-resume-from-artifact-store.sh
# GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH
# TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH
# V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION
# V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY
# V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED
# V0170-005-STATUS-COMPENSATION-REQUIRED
# V0170-005-NO-AUTOMATIC-ORDER-RETRY
# V0170-005-REDACTED-RECOVERY-EVIDENCE
# V0170-005-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-cancel-status-reconciliation-recovery-path.sh
# GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE
# TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE
# V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE
# V0170-006-FAILURE-REASONS-VISIBLE
# V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE
# V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS
# V0170-006-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-dashboard-artifact-validation-error-surface.sh
# GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND
# TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND
# V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY
# V0170-007-LOCAL-ONLY-NO-NETWORK
# V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT
# V0170-007-REDACTED-OUTPUT
# V0170-007-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-cli-artifact-verify-command.sh
# GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
# TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION
# V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION
# V0170-008-SHARED-RUNTIME-VALIDATOR-PATH
# V0170-008-UPLOADED-BUNDLE-VALIDATED
# V0170-008-DOWNLOADED-BUNDLE-VALIDATED
# V0170-008-LOCAL-ONLY-NO-NETWORK
# V0170-008-REDACTED-EVIDENCE-RECORDED
# V0170-008-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-manual-workflow-artifact-validation.sh
# GH-1147-VERIFY-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE
# TVM-RELEASE-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE
# V0170-009-ACTIVE-SAFETY-POLICY-PROFILE
# V0170-009-VENUE-PRODUCT-SYMBOL-LIMITS
# V0170-009-NOTIONAL-LIMIT-EVIDENCE
# V0170-009-ORDER-COUNT-LIMIT-EVIDENCE
# V0170-009-PRODUCTION-GUARD-STATE
# V0170-009-REDACTED-POLICY-EVIDENCE
# V0170-009-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.0-beta-safety-policy-profile-evidence.sh
# GH-1148-VERIFY-V0170-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0170-STAGE-AUDIT-RELEASE-DOCS
# V0170-010-STAGE-CODE-AUDIT
# V0170-010-RELEASE-NOTES
# V0170-010-VALIDATION-MATRIX
# V0170-010-ROOT-DOCS-REFRESH
# V0170-010-STALE-WORDING-GUARD
# V0170-010-NO-PRODUCTION-CUTOVER
# V0170-010-NO-TAG-OR-RELEASE-PUBLICATION
bash checks/verify-v0.17.0-stage-audit-release-docs.sh
# GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED
# TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED
# V0171-001-FAILED-VALIDATION-NONZERO-EXIT
# V0171-001-VALID-BUNDLE-EXIT-ZERO
# V0171-001-LOCAL-REPORTING-PATH-REDACTED
# V0171-001-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh
# GH-1167-VERIFY-V0171-MANUAL-WORKFLOW-FAIL-CLOSED
# TVM-RELEASE-V0171-MANUAL-WORKFLOW-FAIL-CLOSED
# V0171-002-UPLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW
# V0171-002-DOWNLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW
# V0171-002-REQUIRE-PASSED-STATUS
# V0171-002-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.1-manual-workflow-fail-closed.sh
# GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
# TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
# V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED
# V0171-003-MISSING-ARTIFACT-FAILS-CLOSED
# V0171-003-MISSING-MANIFEST-FAILS-CLOSED
# V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED
# V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE
# V0171-003-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.17.1-artifact-negative-regressions.sh
# GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC
# V0171-004-V0170-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC
# V0171-004-V0170-TAG-FIXED
# V0171-004-PATCH-QUEUE-NOT-PUBLICATION
# V0171-004-NO-PRODUCTION-CUTOVER
# https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0
# c83879f80a525665c3484878d7071b1f5214da20
# 2026-06-27T06:37:33Z
bash checks/verify-v0.17.1-release-fact-sync.sh
# GH-1171-VERIFY-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES
# V0171-006-AGGREGATE-GUARD
# V0171-006-PATCH-AUDIT
# V0171-006-RELEASE-NOTES
# V0171-006-VALIDATION-MATRIX
# V0171-006-V0180-HANDOFF
# V0171-006-NO-PRODUCTION-CUTOVER
# V0171-006-NO-TAG-OR-RELEASE-PUBLICATION
bash checks/verify-v0.17.1.sh
# GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT
# TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT
# V0180-001-DEPENDENCIES-CLOSED-DONE
# V0180-001-NAMESPACE-CONTRACT
# V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE
# V0180-001-ARTIFACT-LIFECYCLE-SCOPE
# V0180-001-STATUS-RESUME-RECONCILIATION
# V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN
# V0180-001-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.18.0-venue-product-aware-lifecycle-recovery-contract.sh
# GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
# TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE
# V0180-002-DEPENDENCY-GH1176-DONE
# V0180-002-LIFECYCLE-MANIFEST-SCHEMA
# V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
# V0180-002-ACCOUNT-RUNID-BINDING
# V0180-002-BOUNDARY-REUSE-REJECTION
# V0180-002-LOCAL-EVIDENCE-ONLY
# V0180-002-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.18.0-run-artifact-lifecycle-manifest-namespace.sh
# GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
# TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE
# V0180-003-DEPENDENCY-GH1177-DONE
# V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED
# V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE
# V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION
# V0180-003-REDACTION-STATUS-PERSISTED
# V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE
# V0180-003-LOCAL-ARTIFACT-STORE-REPLAY
# V0180-003-NO-PRODUCTION-CUTOVER
bash checks/verify-v0.18.0-status-query-retry-artifact-persistence.sh
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
