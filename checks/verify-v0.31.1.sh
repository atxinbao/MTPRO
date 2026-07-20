#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || {
    echo "verify-v0.31.1 failed: $file must contain: $expected" >&2
    exit 1
  }
}

# GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE
# GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH
# GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY
# GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY
# GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION
# GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS
# GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX
# GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS
# GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR
# V0311-001-RELEASE-PUBLICATION-AFTER-FULL-MATRIX
# V0311-002-ENDPOINT-METHOD-HOST-PATH-PRODUCT-FAMILY
# V0311-003-APPROVAL-SCOPE-EXPIRY-SOURCE-POLICY
# V0311-004-PERSISTENT-RUN-LOCK-REPLAY-PROTECTION
# V0311-005-EVIDENCE-ROOT-ARTIFACT-VALIDATION
# V0311-006-RISK-GATE-NEGATIVE-INPUTS
# V0311-007-NEGATIVE-REGRESSION-MATRIX
# V0311-008-V0310-PUBLICATION-FACTS
# V0311-009-STAGE-AUDIT-RELEASE-NOTES

swift test --filter TargetGraphTests/testGH1499To1507ReleaseV0311ControlledEnablementIntegrityRepair

swift run mtpro controlled-enablement-integrity status | grep -F "boundaryHeld=true"
swift run mtpro controlled-enablement-integrity publication | grep -F "releaseCreatedAfterFullMatrix=true"
swift run mtpro controlled-enablement-integrity endpoints | grep -F "allow=method:GET;product:spot"
swift run mtpro controlled-enablement-integrity negative-cases | grep -F "negativeRiskRejected=true"

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0311ControlledEnablementIntegrityRepair.swift \
  Sources/MTPROCLI/main.swift \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  docs/audit/mtpro-release-v0.31.1-controlled-enablement-integrity-publication-gate-repair-stage-code-audit.md \
  docs/release/mtpro-release-v0.31.1-controlled-enablement-integrity-publication-gate-repair-notes.md \
  docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md \
  docs/validation/trading-validation-matrix.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/README.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md \
  docs/history/validation-pre-canonicalization-2026-07-20/verification.md; do
  require_contains "$file" "GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE"
  require_contains "$file" "GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH"
  require_contains "$file" "GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY"
  require_contains "$file" "GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY"
  require_contains "$file" "GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION"
  require_contains "$file" "GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS"
  require_contains "$file" "GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX"
  require_contains "$file" "GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS"
  require_contains "$file" "GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES"
  require_contains "$file" "TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR"
done

require_contains .github/workflows/checks.yml "release_publication_checks:"
require_contains .github/workflows/checks.yml "linux_checks"
require_contains .github/workflows/checks.yml "dashboard_macos"
require_contains .github/workflows/checks.yml "GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE"

echo "verify-v0.31.1 passed"
