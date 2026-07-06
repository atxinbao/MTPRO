#!/usr/bin/env bash
set -euo pipefail

# GH-1340-VERIFY-V0221-PATCH-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0221-PATCH-AUDIT-RELEASE-NOTES
# V0221-004-PATCH-AUDIT
# V0221-004-RELEASE-NOTES
# V0221-004-NO-CAPABILITY-CHANGE
# V0221-004-NO-PRODUCTION-CUTOVER
# V0221-004-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.22.1 publication fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.22.1 publication fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

AUDIT="docs/audit/mtpro-release-v0.22.1-publication-fact-sync-patch-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.22.1-publication-fact-sync-patch-notes.md"
README="README.md"
GOAL="GOAL.md"
BLUEPRINT="BLUEPRINT.md"
ROADMAP="docs/roadmap.md"
LATEST="docs/validation/latest-verification-summary.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
POLICY="docs/release/release-publication-policy.md"
VERIFICATION="verification.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
V0220_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.22.0"
V0220_TARGET_COMMIT="1589492558fa55aad3424e5727415c2f8f453ed8"
V0220_PUBLICATION_TIMESTAMP="2026-07-06T11:16:35Z"

swift test --filter TargetGraphTests/testGH1337To1340ReleaseV0221PublicationFactSyncPatch

for file in \
  "$AUDIT" \
  "$NOTES" \
  "$README" \
  "$GOAL" \
  "$BLUEPRINT" \
  "$ROADMAP" \
  "$LATEST" \
  "$READINESS" \
  "$PLAN" \
  "$MATRIX" \
  "$POLICY" \
  "$VERIFICATION" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1337-VERIFY-V0221-V0220-RELEASE-FACT-SYNC"
  require_file_contains "$file" "TVM-RELEASE-V0221-V0220-RELEASE-FACT-SYNC"
  require_file_contains "$file" "V0221-001-V0220-RELEASE-FACT-SYNC"
  require_file_contains "$file" "GH-1338-VERIFY-V0221-V0220-STALE-WORDING-GUARD"
  require_file_contains "$file" "V0221-002-V0220-STALE-WORDING-GUARD"
  require_file_contains "$file" "GH-1339-VERIFY-V0221-VERSION-ROADMAP-CORRECTION"
  require_file_contains "$file" "V0221-003-V0220-SPOT-LIVE-CANARY-TRANSPORT"
  require_file_contains "$file" "V0221-003-V0230-FUTURES-READONLY-NEXT"
  require_file_contains "$file" "GH-1340-VERIFY-V0221-PATCH-AUDIT-RELEASE-NOTES"
  require_file_contains "$file" "V0221-004-NO-CAPABILITY-CHANGE"
done

for file in "$AUDIT" "$NOTES" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$POLICY" "$VERIFICATION"; do
  require_file_contains "$file" "$V0220_RELEASE_URL"
  require_file_contains "$file" "$V0220_TARGET_COMMIT"
  require_file_contains "$file" "$V0220_PUBLICATION_TIMESTAMP"
  require_file_contains "$file" "v0.22.0 is Binance Spot live canary transport completion"
  require_file_contains "$file" "v0.23.0 is Binance USD-M Futures read-only foundation"
  require_file_contains "$file" "production cutover not authorized"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.22.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.22.1.sh"
require_file_contains "$READINESS" "Release v0.22.1 publication fact sync patch anchor"
require_file_contains "$PLAN" "GH-1340 Release v0.22.1 Patch Audit / Release Notes Closeout"
require_file_contains "$MATRIX" "TVM-RELEASE-V0221-PATCH-AUDIT-RELEASE-NOTES"
require_file_contains "$VERIFICATION" "MTPRO Release v0.22.1 Publication Fact Sync Patch"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES" "$AUDIT" "$POLICY"; do
  reject_file_contains "$file" "v0.22.0 | Binance USD"
  reject_file_contains "$file" "v0.22.0 is Binance USD-M Futures read-only foundation"
  reject_file_contains "$file" "v0.22.0 尚未发布"
  reject_file_contains "$file" "If Human wants to publish \`v0.22.0\`"
  reject_file_contains "$file" "does not enable Futures, OKX, Dashboard trading controls, production cutover, tag publication or GitHub Release publication"
done

for file in "$AUDIT" "$NOTES" "$POLICY" "$LATEST" "$VERIFICATION"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault=true"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "brokerEndpointConnected=true"
  reject_file_contains "$file" "futuresOrderExecutionEnabled=true"
  reject_file_contains "$file" "okxEnabled=true"
done

echo "MTPRO release v0.22.1 publication fact sync patch verification passed."
