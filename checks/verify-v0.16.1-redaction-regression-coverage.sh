#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

require_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  if ! grep -Fq "$needle" "$path"; then
    echo "missing '$needle' in $path" >&2
    exit 1
  fi
}

POLICY="Sources/DomainModel/ReleaseV0161OperatorBetaArtifactRedactionPolicy.swift"
ARTIFACT_STORE="Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift"
WORKFLOW="Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift"
DASHBOARD="Sources/Dashboard/Report/ReleaseV0160DashboardArtifactBackedExecutionView.swift"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
NOTES="docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md"

anchors=(
  "GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE"
  "TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE"
  "V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS"
  "V0161-004-SIGNED-QUERY-MARKERS"
  "V0161-004-PRODUCTION-HOST-MARKERS"
  "V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS"
  "V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE"
)

for path in \
  "$POLICY" \
  "$ARTIFACT_STORE" \
  "$WORKFLOW" \
  "$DASHBOARD" \
  "$TARGET_TESTS" \
  "$NOTES" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/run.sh" \
  "checks/automation-readiness.sh"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

markers=(
  "x-mbx-apikey"
  "signature="
  "signature%3d"
  "listenkey="
  "listen-key"
  "secret="
  "api-secret"
  "api.binance.com"
  "api1.binance.com"
  "api2.binance.com"
  "api3.binance.com"
  "api4.binance.com"
  "fapi.binance.com"
  "dapi.binance.com"
  "stream.binance.com"
  "fstream.binance.com"
  "dstream.binance.com"
  "raw order payload"
  "raw_order"
  "raw_order_payload"
  "raw broker payload"
  "raw_broker"
  "raw_broker_payload"
  "broker_payload"
  "raw execution report"
)

for marker in "${markers[@]}"; do
  require_file_contains "$POLICY" "\"$marker\""
done

swift test --filter TargetGraphTests/testGH1136ReleaseV0161RedactionRegressionCoverageRejectsSensitiveMarkers

echo "MTPRO release v0.16.1 redaction regression coverage verification passed."
