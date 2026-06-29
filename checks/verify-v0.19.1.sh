#!/usr/bin/env bash
set -euo pipefail

# GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR
# TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR
# V0191-005-AGGREGATE-GUARD
# V0191-005-FOCUSED-GUARDS-COVERED
# V0191-005-PUBLICATION-FACTS-COVERED
# V0191-005-RUN-AUTOMATION-WIRING
# V0191-005-NO-PRODUCTION-CUTOVER
# V0191-005-NO-TAG-OR-RELEASE-PUBLICATION

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.19.1 aggregate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.19.1 aggregate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

NOTES="docs/release/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-notes.md"
AUDIT="docs/audit/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-stage-code-audit.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"

bash checks/verify-v0.19.1-v0190-release-fact-sync.sh
bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh
bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh
swift test --filter TargetGraphTests/testGH1236ReleaseV0191AggregateVerificationAnchor

for file in \
  "$NOTES" \
  "$AUDIT" \
  "$READINESS" \
  "$LATEST" \
  "$PLAN" \
  "$MATRIX" \
  "$TESTS" \
  "$RUN_SCRIPT" \
  "$AUTOMATION_SCRIPT" \
  "$0"; do
  require_file_contains "$file" "GH-1236-VERIFY-V0191-AGGREGATE-VERIFICATION-ANCHOR"
  require_file_contains "$file" "TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR"
  require_file_contains "$file" "V0191-005-AGGREGATE-GUARD"
  require_file_contains "$file" "V0191-005-FOCUSED-GUARDS-COVERED"
  require_file_contains "$file" "V0191-005-PUBLICATION-FACTS-COVERED"
  require_file_contains "$file" "V0191-005-RUN-AUTOMATION-WIRING"
  require_file_contains "$file" "V0191-005-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "V0191-005-NO-TAG-OR-RELEASE-PUBLICATION"
done

for verifier in \
  "bash checks/verify-v0.19.1-v0190-release-fact-sync.sh" \
  "bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh" \
  "bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh" \
  "testGH1236ReleaseV0191AggregateVerificationAnchor"; do
  require_file_contains "$0" "$verifier"
done

for file in "$NOTES" "$AUDIT"; do
  require_file_contains "$file" "V0191-004-V0190-RELEASE-NOTES-PUBLICATION-FACTS"
  require_file_contains "$file" "V0191-004-V0190-STAGE-AUDIT-PUBLICATION-FACTS"
  require_file_contains "$file" "V0191-004-V0190-STABLE-RELEASE-FACT"
  require_file_contains "$file" "V0191-004-NO-PRODUCTION-CUTOVER"
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0"
  require_file_contains "$file" "53e9b1e81db075ef464b74f8f35c66ebd61ea03c"
  require_file_contains "$file" "2026-06-29T13:42:34Z"
  require_file_contains "$file" "production cutover not authorized"
  reject_file_contains "$file" "productionCutoverAuthorized=true"
  reject_file_contains "$file" "productionSecretRead=true"
  reject_file_contains "$file" "productionEndpointConnected=true"
  reject_file_contains "$file" "productionBrokerConnected=true"
  reject_file_contains "$file" "productionOrderSubmitted=true"
done

require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.19.1.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.19.1.sh"
require_file_contains "$READINESS" "Release v0.19.1 aggregate verification anchor"
require_file_contains "$LATEST" "v0.19.1 aggregate verification anchor"
require_file_contains "$PLAN" "GH-1236 Release v0.19.1 Aggregate Verification Anchor"
require_file_contains "$MATRIX" "TVM-RELEASE-V0191-AGGREGATE-VERIFICATION-ANCHOR"
require_file_contains "$TESTS" "testGH1236ReleaseV0191AggregateVerificationAnchor"

echo "MTPRO release v0.19.1 aggregate verification anchor passed."
