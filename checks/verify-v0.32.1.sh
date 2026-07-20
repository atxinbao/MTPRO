#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || {
    echo "verify-v0.32.1 failed: $file must contain: $expected" >&2
    exit 1
  }
}

sha256_value() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print "sha256:" $1}'
  else
    shasum -a 256 "$file" | awk '{print "sha256:" $1}'
  fi
}

byte_count() {
  local file="$1"
  wc -c < "$file" | tr -d '[:space:]'
}

write_artifact() {
  local root="$1"
  local relative_path="$2"
  local content="$3"
  mkdir -p "$(dirname "$root/$relative_path")"
  printf '%s' "$content" > "$root/$relative_path"
}

artifact_record() {
  local root="$1"
  local relative_path="$2"
  local kind="$3"
  local product="$4"
  local action="$5"
  local sequence="$6"
  local idempotency_key="$7"
  local sha byte_count_value
  sha="$(sha256_value "$root/$relative_path")"
  byte_count_value="$(byte_count "$root/$relative_path")"

  if [[ -n "$product" ]]; then
    cat <<JSON
{"action":"$action","byteCount":$byte_count_value,"idempotencyKey":"$idempotency_key","kind":"$kind","product":"$product","relativePath":"$relative_path","sequence":$sequence,"sha256":"$sha"}
JSON
  else
    cat <<JSON
{"byteCount":$byte_count_value,"kind":"$kind","relativePath":"$relative_path","sha256":"$sha"}
JSON
  fi
}

fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT

write_artifact "$fixture_root" "operations/spot-submit.json" '{"product":"spot","action":"submit","redacted":true}'
write_artifact "$fixture_root" "operations/spot-status.json" '{"product":"spot","action":"status","redacted":true}'
write_artifact "$fixture_root" "operations/spot-cancel.json" '{"product":"spot","action":"cancel","redacted":true}'
write_artifact "$fixture_root" "operations/futures-submit.json" '{"product":"usdsPerpetual","action":"submit","redacted":true}'
write_artifact "$fixture_root" "operations/futures-status.json" '{"product":"usdsPerpetual","action":"status","redacted":true}'
write_artifact "$fixture_root" "operations/futures-cancel.json" '{"product":"usdsPerpetual","action":"cancel","redacted":true}'
write_artifact "$fixture_root" "oms/reconciliation.json" '{"oms":"reconciled"}'
write_artifact "$fixture_root" "rollback/rollback.json" '{"rollback":"linked"}'
write_artifact "$fixture_root" "incident/incident-stop.json" '{"incident":"linked"}'
write_artifact "$fixture_root" "publication/full-matrix.json" '{"fullMatrix":"passed"}'

spot_submit_record="$(artifact_record "$fixture_root" "operations/spot-submit.json" "operation" "spot" "submit" "1" "v0321-canary-spot-submit-idempotency")"
spot_status_record="$(artifact_record "$fixture_root" "operations/spot-status.json" "operation" "spot" "status" "2" "v0321-canary-spot-status-idempotency")"
spot_cancel_record="$(artifact_record "$fixture_root" "operations/spot-cancel.json" "operation" "spot" "cancel" "3" "v0321-canary-spot-cancel-idempotency")"
futures_submit_record="$(artifact_record "$fixture_root" "operations/futures-submit.json" "operation" "usdsPerpetual" "submit" "4" "v0321-canary-usdsPerpetual-submit-idempotency")"
futures_status_record="$(artifact_record "$fixture_root" "operations/futures-status.json" "operation" "usdsPerpetual" "status" "5" "v0321-canary-usdsPerpetual-status-idempotency")"
futures_cancel_record="$(artifact_record "$fixture_root" "operations/futures-cancel.json" "operation" "usdsPerpetual" "cancel" "6" "v0321-canary-usdsPerpetual-cancel-idempotency")"
oms_record="$(artifact_record "$fixture_root" "oms/reconciliation.json" "oms" "" "" "" "")"
rollback_record="$(artifact_record "$fixture_root" "rollback/rollback.json" "rollback" "" "" "" "")"
incident_record="$(artifact_record "$fixture_root" "incident/incident-stop.json" "incident" "" "" "" "")"
publication_record="$(artifact_record "$fixture_root" "publication/full-matrix.json" "publication" "" "" "" "")"

cat > "$fixture_root/manifest.json" <<JSON
{
  "approval": {
    "actionScope": ["submit", "status", "cancel"],
    "approvalID": "human_v0321_controlled_canary_integrity",
    "evaluatedAtEpochSeconds": 1786000000,
    "expiresAtEpochSeconds": 1786003600,
    "issuedAtEpochSeconds": 1785999000,
    "operatorIdentity": "operator-redacted",
    "policyVersion": "v0321-controlled-canary-integrity-repair",
    "productScope": ["spot", "usdsPerpetual"],
    "scope": "controlled-production-canary-integrity-repair",
    "sourceCommit": "febb7447fbad22937e2c9f0393d2a6bc53f25fbd"
  },
  "artifacts": [
    $spot_submit_record,
    $spot_status_record,
    $spot_cancel_record,
    $futures_submit_record,
    $futures_status_record,
    $futures_cancel_record,
    $oms_record,
    $rollback_record,
    $incident_record,
    $publication_record
  ],
  "caps": [
    {
      "currentExposureUSDT": 10,
      "currentLeverage": 1,
      "currentNotionalUSDT": 10,
      "freshnessSeconds": 8,
      "maxActionsPerRun": 3,
      "maxExposureUSDT": 50,
      "maxFreshnessSeconds": 15,
      "maxLeverage": 1,
      "maxNotionalUSDT": 25,
      "plannedActions": 3,
      "policyScope": "v0.32.1-controlled-canary-integrity",
      "product": "spot"
    },
    {
      "currentExposureUSDT": 20,
      "currentLeverage": 2,
      "currentNotionalUSDT": 10,
      "freshnessSeconds": 9,
      "maxActionsPerRun": 3,
      "maxExposureUSDT": 50,
      "maxFreshnessSeconds": 15,
      "maxLeverage": 2,
      "maxNotionalUSDT": 20,
      "plannedActions": 3,
      "policyScope": "v0.32.1-controlled-canary-integrity",
      "product": "usdsPerpetual"
    }
  ],
  "evidenceMode": "explicit-artifact-root",
  "manifestCreatedAtEpochSeconds": 1786000000,
  "observedProductionCanary": false,
  "oms": {
    "eventLogAppendOnly": true,
    "incidentStopLinked": true,
    "killSwitchNoTradeLinked": true,
    "monotonicEventIdentity": true,
    "reconciliationReplayMatched": true,
    "rollbackArtifactLinked": true,
    "sameRunID": true,
    "sequenceGapRejected": true
  },
  "policyVersion": "v0321-controlled-canary-integrity-repair",
  "publication": {
    "dashboardMacOS": "passed",
    "linuxChecks": "passed",
    "previousV0320EarlyPublicationFindingRecorded": true,
    "prFastChecks": "passed",
    "releaseCreatedAfterFullMatrix": true,
    "releasePublicationChecks": "passed"
  },
  "release": "v0.32.1",
  "runID": "v0321-run-controlled-canary-integrity",
  "runLock": {
    "duplicateRunRejected": true,
    "lockBoundToRun": true,
    "nonce": "redacted-nonce",
    "policyVersion": "v0321-controlled-canary-integrity-repair",
    "replayAttemptRejected": true,
    "runID": "v0321-run-controlled-canary-integrity",
    "runLockID": "v0321-run-lock-controlled-canary-integrity",
    "sourceCommit": "febb7447fbad22937e2c9f0393d2a6bc53f25fbd",
    "staleLockRecoveryValidated": true
  },
  "sourceCommit": "febb7447fbad22937e2c9f0393d2a6bc53f25fbd"
}
JSON

# GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
# GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256
# GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK
# GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX
# GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
# GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
# GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE
# GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR
# V0321-001-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
# V0321-002-EVIDENCE-ROOT-MANIFEST-SHA256
# V0321-003-APPROVAL-SCOPE-RUN-LOCK
# V0321-004-CAP-VALIDATION-NEGATIVE-MATRIX
# V0321-005-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
# V0321-006-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
# V0321-007-FULL-MATRIX-BEFORE-RELEASE
# V0321-008-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS

swift test --filter TargetGraphTests/testGH1519To1526ReleaseV0321ControlledCanaryIntegrityRepair

status_output="$(swift run mtpro controlled-canary-integrity-repair status --artifact-root "$fixture_root")"
printf '%s\n' "$status_output" | grep -F "release=v0.32.1"
printf '%s\n' "$status_output" | grep -F "artifactIntegrityHeld=true"
printf '%s\n' "$status_output" | grep -F "approvalScopeHeld=true"
printf '%s\n' "$status_output" | grep -F "runLockHeld=true"
printf '%s\n' "$status_output" | grep -F "capValidationHeld=true"
printf '%s\n' "$status_output" | grep -F "uniqueOperationArtifactsHeld=true"
printf '%s\n' "$status_output" | grep -F "omsLinkageHeld=true"
printf '%s\n' "$status_output" | grep -F "publicationGateHeld=true"
printf '%s\n' "$status_output" | grep -F "observedProductionCanary=false"
printf '%s\n' "$status_output" | grep -F "acceptanceDecision=blocked-observed-production-canary-missing"
printf '%s\n' "$status_output" | grep -F "productionCutoverAuthorized=false"
printf '%s\n' "$status_output" | grep -F "boundaryHeld=true"

publication_output="$(swift run mtpro controlled-canary-integrity-repair publication --artifact-root "$fixture_root")"
printf '%s\n' "$publication_output" | grep -F "releaseCreatedAfterFullMatrix=true"
printf '%s\n' "$publication_output" | grep -F "v0320EarlyPublicationFindingRecorded=true"

if swift run mtpro controlled-canary-integrity-repair status >/tmp/mtpro-v0321-missing-root.out 2>&1; then
  echo "verify-v0.32.1 failed: CLI without --artifact-root must fail" >&2
  exit 1
fi

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0321ControlledCanaryIntegrityRepair.swift \
  Sources/MTPROCLI/main.swift \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  checks/verify-v0.32.1.sh \
  checks/run.sh \
  checks/automation-readiness.sh \
  .github/workflows/checks.yml \
  docs/audit/mtpro-release-v0.32.1-controlled-canary-integrity-publication-gate-repair-stage-code-audit.md \
  docs/release/mtpro-release-v0.32.1-controlled-canary-integrity-publication-gate-repair-notes.md \
  docs/validation/latest-verification-summary.md \
  docs/validation/trading-validation-matrix.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/README.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md \
  verification.md; do
  require_contains "$file" "GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS"
  require_contains "$file" "GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256"
  require_contains "$file" "GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK"
  require_contains "$file" "GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX"
  require_contains "$file" "GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS"
  require_contains "$file" "GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE"
  require_contains "$file" "GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE"
  require_contains "$file" "GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS"
  require_contains "$file" "TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR"
done

echo "verify-v0.32.1 passed"
