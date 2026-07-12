#!/usr/bin/env bash
set -euo pipefail

# GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT
# GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE
# GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE
# GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT
# GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
# GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE
# GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION
# GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN
# GH-1478-VERIFY-V0301-V0300-PUBLICATION-FACTS
# GH-1479-VERIFY-V0301-DETERMINISTIC-FIXTURE-FAIL-CLOSED
# GH-1480-VERIFY-V0301-ARTIFACT-INTEGRITY-ACCEPTANCE
# GH-1481-VERIFY-V0301-CLI-EXPLICIT-ARTIFACT-INPUT
# GH-1482-VERIFY-V0301-HUMAN-APPROVED-OBSERVED-BUNDLE
# GH-1483-VERIFY-V0301-PREPUBLICATION-MATRIX-GATE
# GH-1484-VERIFY-V0301-DEDUPE-VALIDATION-ORCHESTRATION
# GH-1485-VERIFY-V0301-BINANCE-ONLY-ROOT-DOCS-MILESTONES
# GH-1486-VERIFY-V0301-STAGE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0301-OBSERVED-SHADOW-INTEGRITY-REPAIR
# V0300-001-OBSERVED-RUN-LIFECYCLE
# V0300-001-NO-SUBMIT-CONTRACT
# V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE
# V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE
# V0300-003-IMMUTABLE-MANIFEST-PROVENANCE
# V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT
# V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
# V0300-006-DASHBOARD-CLI-READONLY-SURFACE
# V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION
# V0300-008-STAGE-AUDIT-RELEASE-DOCS

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    printf 'release v0.30.0 validation failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq -- "$forbidden" "$file"; then
    printf 'release v0.30.0 validation failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

FILES=(
  "Sources/ExecutionClient/FutureGate/ReleaseV0300ObservedProductionShadowRun.swift"
  "Sources/Dashboard/Report/ReleaseV0300DashboardCLIObservedShadowRunSurface.swift"
  "Sources/MTPROCLI/main.swift"
  "docs/audit/mtpro-release-v0.30.0-observed-production-shadow-run-stage-code-audit.md"
  "docs/release/mtpro-release-v0.30.0-observed-production-shadow-run-notes.md"
  "docs/automation/automation-readiness.md"
  "docs/validation/latest-verification-summary.md"
  "docs/validation/validation-plan.md"
  "docs/validation/trading-validation-matrix.md"
  "docs/roadmap.md"
  "README.md"
  "GOAL.md"
  "BLUEPRINT.md"
  "verification.md"
  "checks/verify-v0.30.0.sh"
  "checks/run.sh"
  "checks/automation-readiness.sh"
  "Tests/TargetGraphTests/TargetGraphTests.swift"
)

ANCHORS=(
  "GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT"
  "GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE"
  "GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE"
  "GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT"
  "GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT"
  "GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE"
  "GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION"
  "GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS"
  "TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN"
  "V0300-001-OBSERVED-RUN-LIFECYCLE"
  "V0300-001-NO-SUBMIT-CONTRACT"
  "V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE"
  "V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE"
  "V0300-003-IMMUTABLE-MANIFEST-PROVENANCE"
  "V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT"
  "V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT"
  "V0300-006-DASHBOARD-CLI-READONLY-SURFACE"
  "V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION"
  "V0300-008-STAGE-AUDIT-RELEASE-DOCS"
)

if [[ "${MTPRO_SKIP_FOCUSED_SWIFT_TEST:-0}" != "1" ]]; then
  swift test --filter TargetGraphTests/testGH1468To1475ReleaseV0300ObservedProductionShadowRun
fi

CLI_STATUS="$(swift run mtpro observed-production-shadow status)"
for expected in \
  "release=v0.30.0" \
  "observedShadowRun=true" \
  "evidenceOrigin=deterministic-fixture" \
  "acceptanceDecision=blocked" \
  "artifactValidationPassed=false" \
  "observedRunAccepted=false" \
  "productionTradingEnabledByDefault=false" \
  "productionCutoverAuthorized=false" \
  "productionSecretAutoReadEnabled=false" \
  "automaticBrokerConnectionEnabled=false" \
  "productionSubmitCancelReplaceEnabled=false" \
  "noSubmitTransportMode=true" \
  "noMutationTransportMode=true" \
  "boundaryHeld=true"; do
  if ! grep -Fq -- "$expected" <<<"$CLI_STATUS"; then
    printf 'release v0.30.0 validation failed: CLI status must contain: %s\n' "$expected" >&2
    exit 1
  fi
done

for file in "${FILES[@]}"; do
  for anchor in "${ANCHORS[@]}"; do
    require_file_contains "$file" "$anchor"
  done
done

for file in \
  "README.md" \
  "GOAL.md" \
  "BLUEPRINT.md" \
  "docs/roadmap.md" \
  "docs/validation/latest-verification-summary.md" \
  "verification.md" \
  "docs/release/mtpro-release-v0.30.0-observed-production-shadow-run-notes.md"; do
  for expected in \
    "observedShadowRun=true" \
    "observedRunAccepted=false" \
    "productionTradingEnabledByDefault=false" \
    "productionCutoverAuthorized=false" \
    "productionSecretAutoReadEnabled=false" \
    "automaticBrokerConnectionEnabled=false" \
    "productionSubmitCancelReplaceEnabled=false" \
    "noSubmitTransportMode=true" \
    "noMutationTransportMode=true"; do
    require_file_contains "$file" "$expected"
  done
  reject_file_contains "$file" "production cutover authorized"
  reject_file_contains "$file" "production trading enabled by default"
  reject_file_contains "$file" "automatic broker connection enabled"
  reject_file_contains "$file" "real order mutation enabled"
  reject_file_contains "$file" "OKX active runtime enabled"
done

require_file_contains "checks/run.sh" "MTPRO_SKIP_FOCUSED_SWIFT_TEST=1 bash checks/verify-v0.30.0.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.30.0.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1468To1475ReleaseV0300ObservedProductionShadowRun"

printf 'MTPRO v0.30.0 observed production shadow run checks passed.\n'
