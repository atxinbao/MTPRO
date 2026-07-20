#!/usr/bin/env bash
set -euo pipefail

# GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION
# TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION
# V0210-005-LIVE-ACCOUNT-SNAPSHOT-REDACTION
# V0210-005-CONSUMES-SIGNED-ACCOUNT-PREFLIGHT
# V0210-005-ALLOWED-READINESS-FIELDS
# V0210-005-FRESHNESS-STALE-FAIL-CLOSED
# V0210-005-NO-RAW-BALANCE-ACCOUNT-ID
# V0210-005-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.21.0 live account snapshot redaction guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.21.0 live account snapshot redaction guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

SNAPSHOT_SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionArtifact.swift"
SNAPSHOT_DOC="docs/contracts/release-v0.21.0-binance-spot-live-account-snapshot-redaction.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

swift test --filter TargetGraphTests/testGH1277ReleaseV0210LiveAccountSnapshotRedactionArtifact

for file in \
  "$SNAPSHOT_SOURCE" \
  "$SNAPSHOT_DOC" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$LATEST" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION"
  require_file_contains "$file" "TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION"
  require_file_contains "$file" "V0210-005-LIVE-ACCOUNT-SNAPSHOT-REDACTION"
  require_file_contains "$file" "V0210-005-CONSUMES-SIGNED-ACCOUNT-PREFLIGHT"
  require_file_contains "$file" "V0210-005-ALLOWED-READINESS-FIELDS"
  require_file_contains "$file" "V0210-005-FRESHNESS-STALE-FAIL-CLOSED"
  require_file_contains "$file" "V0210-005-NO-RAW-BALANCE-ACCOUNT-ID"
  require_file_contains "$file" "V0210-005-NO-PRODUCTION-CUTOVER"
done

require_file_contains "$SNAPSHOT_SOURCE" "ReleaseV0210SpotCanaryLiveAccountSnapshotRedactionEvidence"
require_file_contains "$SNAPSHOT_SOURCE" "ReleaseV0210SpotCanaryLiveAccountSnapshotRedactedArtifact"
require_file_contains "$SNAPSHOT_SOURCE" "GH-1277"
require_file_contains "$SNAPSHOT_SOURCE" "GH-1276"
require_file_contains "$SNAPSHOT_SOURCE" "GH-1278"
require_file_contains "$SNAPSHOT_SOURCE" "GH-1273..GH-1286"
require_file_contains "$SNAPSHOT_SOURCE" "ReleaseV0181TradingEnvironment.productionLive"
require_file_contains "$SNAPSHOT_SOURCE" "artifacts/release-v0.21.0/account-snapshot/binance-spot-canary/<redacted-snapshot-id>.json"
require_file_contains "$SNAPSHOT_SOURCE" "redactedSnapshotArtifactCaptured"
require_file_contains "$SNAPSHOT_SOURCE" "freshnessEvidenceCaptured"
require_file_contains "$SNAPSHOT_SOURCE" "staleSnapshotRejected"
require_file_contains "$SNAPSHOT_SOURCE" "malformedSnapshotRejected"
require_file_contains "$SNAPSHOT_SOURCE" "rawBalancesPersisted == false"
require_file_contains "$SNAPSHOT_SOURCE" "accountIdentifiersPersisted == false"
require_file_contains "$SNAPSHOT_SOURCE" "rawAccountPayloadPersisted == false"
require_file_contains "$SNAPSHOT_SOURCE" "orderEndpointTouched == false"
require_file_contains "$SNAPSHOT_SOURCE" "submitCancelReplaceEnabled == false"
require_file_contains "$SNAPSHOT_SOURCE" "productionCutoverAuthorized == false"

require_file_contains "$SNAPSHOT_DOC" "GH-1277"
require_file_contains "$SNAPSHOT_DOC" "GH-1276"
require_file_contains "$SNAPSHOT_DOC" "GH-1278"
require_file_contains "$SNAPSHOT_DOC" "redacted live account snapshot artifact"
require_file_contains "$SNAPSHOT_DOC" "freshness / staleness evidence"
require_file_contains "$SNAPSHOT_DOC" "rejects stale or malformed snapshots"
require_file_contains "$SNAPSHOT_DOC" "does not persist raw balances"
require_file_contains "$READINESS" "Release v0.21.0 live account snapshot redaction anchor"
require_file_contains "$PLAN" "GH-1277 Release v0.21.0 Live Account Snapshot Redaction"
require_file_contains "$MATRIX" "TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION"
require_file_contains "$LATEST" "v0.21.0 live account snapshot redaction"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.21.0-live-account-snapshot-redaction.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.21.0-live-account-snapshot-redaction.sh"
require_file_contains "$TESTS" "testGH1277ReleaseV0210LiveAccountSnapshotRedactionArtifact"

for file in "$SNAPSHOT_SOURCE" "$SNAPSHOT_DOC" "$READINESS" "$PLAN" "$MATRIX" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionSecretValueRead=true"
  reject_file_contains "$file" "credentialSecretValuePersisted=true"
  reject_file_contains "$file" "rawBalancesPersisted=true"
  reject_file_contains "$file" "accountIdentifiersPersisted=true"
  reject_file_contains "$file" "rawAccountPayloadPersisted=true"
  reject_file_contains "$file" "endpointResponseBodyPersisted=true"
  reject_file_contains "$file" "orderEndpointTouched=true"
  reject_file_contains "$file" "submitCancelReplaceEnabled=true"
  reject_file_contains "$file" "privateStreamRuntimeEnabled=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "API Key:"
  reject_file_contains "$file" "Secret Key:"
done

echo "MTPRO release v0.21.0 live account snapshot redaction verification passed."
