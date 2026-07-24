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

reject_file_contains() {
  local path="$1"
  local needle="$2"
  require_file "$path"
  local matches
  matches="$(grep -F -- "$needle" "$path" | grep -Fv 'reject_file_contains' || true)"
  if [[ -n "$matches" ]]; then
    echo "forbidden '$needle' in $path" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift"
CLI="Sources/MTPROCLI/main.swift"
WORKFLOW="docs/history/workflows/release-v0.16.0-manual-testnet-validation.yml"
CONTRACT="docs/contracts/release-v0.16.0-manual-testnet-validation-workflow-contract.md"
RUNBOOK="docs/operators/release-v0.16.0-manual-testnet-validation-workflow-runbook.md"
TARGET_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

anchors=(
  "GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT"
  "TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT"
  "V0161-002-BUNDLE-SCHEMA-PARSED"
  "V0161-002-ACTION-SEQUENCE-CHECKED"
  "V0161-002-CHECKSUM-REFERENCES-CHECKED"
  "V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS"
  "V0161-002-NO-PRODUCTION-CUTOVER"
)

for path in \
  "$SOURCE" \
  "$CLI" \
  "$WORKFLOW" \
  "$CONTRACT" \
  "$RUNBOOK" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "$TARGET_TESTS"; do
  for anchor in "${anchors[@]}"; do
    require_file_contains "$path" "$anchor"
  done
done

require_file_contains "$SOURCE" "ReleaseV0161ManualTestnetValidationEvidenceBundle"
require_file_contains "$SOURCE" "workflowReadsEvidenceBundleContent=true"
require_file_contains "$SOURCE" "decodeAndValidate(filePath:"
require_file_contains "$SOURCE" "forbiddenContentMarkers(in:"
require_file_contains "$SOURCE" "bundleSchemaValidated=true"
require_file_contains "$SOURCE" "actionSequenceValidated=true"
require_file_contains "$SOURCE" "checksumReferencesValidated=true"
require_file_contains "$SOURCE" "reconciliationValidated=true"
require_file_contains "$SOURCE" "noSecretMarkersDetected=true"
require_file_contains "$SOURCE" "noProductionMarkersDetected=true"
require_file_contains "$CLI" "validate-manual-evidence-bundle"
require_file_contains "$CLI" "ReleaseV0160ManualTestnetValidationWorkflow.contentValidationCommandOutput"
require_file_contains "$WORKFLOW" "swift run mtpro validate-manual-evidence-bundle"
require_file_contains "$WORKFLOW" "Validate redacted evidence bundle content"
require_file_contains "$WORKFLOW" '${{ inputs.evidence_bundle_path }}'
require_file_contains "$CONTRACT" "GH-1134 / V0161-002"
require_file_contains "$RUNBOOK" "读取 redacted evidence bundle JSON 内容"
require_file_contains "$TARGET_TESTS" "testGH1134ReleaseV0161ManualEvidenceBundleContentValidationReadsBundle"
require_file_contains "checks/run.sh" "bash checks/verify-v0.16.1-manual-evidence-bundle-content.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.16.1-manual-evidence-bundle-content.sh"
reject_file_contains "$WORKFLOW" "secrets."
reject_file_contains "$WORKFLOW" "api.binance.com/api"

swift test --filter TargetGraphTests/testGH1134ReleaseV0161ManualEvidenceBundleContentValidationReadsBundle

echo "MTPRO release v0.16.1 manual evidence bundle content verification passed."
