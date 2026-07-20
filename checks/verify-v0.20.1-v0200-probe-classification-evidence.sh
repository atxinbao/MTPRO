#!/usr/bin/env bash
set -euo pipefail

# GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE
# TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE
# V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE
# V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE
# V0201-003-NOT-LIVE-TRANSPORT-PROOF
# V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL
# V0201-003-NO-ENDPOINT-CONNECTION
# V0201-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.20.1 probe classification evidence guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.20.1 probe classification evidence guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-notes.md"
AUDIT="docs/audit/mtpro-release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-stage-code-audit.md"
PROBE_CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-public-market-readonly-probe.md"
SIGNED_CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-signed-account-readonly-readiness.md"
READINESS_CONTRACT="docs/contracts/release-v0.20.0-binance-spot-production-shadow-read-only-live-readiness-contract.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

ANCHORS=(
  "GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE"
  "TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE"
  "V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE"
  "V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE"
  "V0201-003-NOT-LIVE-TRANSPORT-PROOF"
  "V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL"
  "V0201-003-NO-ENDPOINT-CONNECTION"
  "V0201-003-NO-PRODUCTION-CUTOVER"
)

for file in \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$NOTES" \
  "$AUDIT" \
  "$PROBE_CONTRACT" \
  "$SIGNED_CONTRACT" \
  "$READINESS_CONTRACT" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  for anchor in "${ANCHORS[@]}"; do
    require_file_contains "$file" "$anchor"
  done
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$POLICY" "$NOTES" "$AUDIT" "$PROBE_CONTRACT" "$SIGNED_CONTRACT" "$READINESS_CONTRACT" "$VERIFICATION"; do
  require_file_contains "$file" "classification evidence"
  require_file_contains "$file" "live transport proof"
  require_file_contains "$file" "account access proof"
  require_file_contains "$file" "account payload retrieval"
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "GH-1243 is live transport proof"
  reject_file_contains "$file" "public-market probe is live transport proof"
  reject_file_contains "$file" "GH-1244 is account access proof"
  reject_file_contains "$file" "signed-account readiness is account access proof"
  reject_file_contains "$file" "proves live transport"
  reject_file_contains "$file" "proves account access"
  reject_file_contains "$file" "account payload retrieved"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
done

require_file_contains "$PROBE_CONTRACT" "public-market response classification / readiness evidence"
require_file_contains "$SIGNED_CONTRACT" "signed account read-only intent evidence"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.20.1-v0200-probe-classification-evidence.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.20.1-v0200-probe-classification-evidence.sh"
require_file_contains "$TESTS" "testGH1271ReleaseV0201PublicProbeClassificationEvidenceGuard"

swift test --filter TargetGraphTests/testGH1271ReleaseV0201PublicProbeClassificationEvidenceGuard

echo "MTPRO release v0.20.1 public probe classification evidence verification passed."
