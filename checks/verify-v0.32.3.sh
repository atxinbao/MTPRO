#!/usr/bin/env bash
set -euo pipefail

# GH-1541-CLOSE-V0323-STAGE-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR
# V0323-007-STAGE-AUDIT-RELEASE-NOTES
# V0323-007-BACKEND-CLOSURE-BLOCKED
# V0323-007-BINANCE-SPOT-USDM-FUTURES-ONLY
# V0323-007-V0330-BLOCKED-UNTIL-V0323-PUBLISHED
# V0323-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'verify-v0.32.3 failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "$file must contain: $expected"
}

if [[ "${MTPRO_SKIP_V0323_NEGATIVE_MATRIX:-0}" != "1" ]]; then
  bash checks/verify-v0.32.3-negative-matrix.sh
fi
swift test --filter TargetGraphTests/testGH1541ReleaseV0323StageAuditReleaseDocsCloseout

for file in \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  checks/verify-v0.32.3.sh \
  checks/run.sh \
  checks/automation-readiness.sh \
  .github/workflows/checks.yml \
  docs/audit/mtpro-release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-stage-code-audit.md \
  docs/release/mtpro-release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-notes.md \
  docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md \
  docs/validation/trading-validation-matrix.md \
  docs/validation/validation-plan.md \
  docs/automation/automation-readiness.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/README.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md \
  docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md \
  docs/history/validation-pre-canonicalization-2026-07-20/verification.md
do
  require_contains "$file" "GH-1541-CLOSE-V0323-STAGE-AUDIT-RELEASE-NOTES"
  require_contains "$file" "TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR"
  require_contains "$file" "V0323-007-STAGE-AUDIT-RELEASE-NOTES"
  require_contains "$file" "V0323-007-BACKEND-CLOSURE-BLOCKED"
  require_contains "$file" "V0323-007-BINANCE-SPOT-USDM-FUTURES-ONLY"
  require_contains "$file" "V0323-007-V0330-BLOCKED-UNTIL-V0323-PUBLISHED"
  require_contains "$file" "V0323-007-NO-PRODUCTION-CUTOVER"
done

require_contains ".github/workflows/checks.yml" "Publish v0.32.3 release after full matrix"
require_contains ".github/workflows/checks.yml" "refs/tags/v0.32.3"
require_contains "checks/run.sh" "MTPRO_SKIP_V0323_NEGATIVE_MATRIX=1 bash checks/verify-v0.32.3.sh"
require_contains "docs/release/mtpro-release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-notes.md" "backendClosureDecision=blocked"
require_contains "docs/audit/mtpro-release-v0.32.3-controlled-canary-persistent-evidence-integrity-repair-stage-code-audit.md" "observedProductionCanary=false"
require_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/README.md" "activeVenue=Binance"
require_contains "docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md" "okxActiveRuntime=false"

echo "MTPRO release v0.32.3 verification passed."
