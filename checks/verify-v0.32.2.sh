#!/usr/bin/env bash
set -euo pipefail

# GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX
# GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY
# GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS
# GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY
# GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE
# GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT
# TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH
# V0322-001-RELEASE-CREATION-BEHIND-FULL-MATRIX
# V0322-002-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY
# V0322-003-COMMIT-CLOCK-APPROVAL-FRESHNESS
# V0322-004-ATOMIC-RUN-LOCK-REPLAY-REGISTRY
# V0322-005-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE
# V0322-006-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'verify-v0.32.2 failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "$file must contain: $expected"
}

swift test --filter TargetGraphTests/testGH1528To1533ReleaseV0322ControlledCanaryIntegrityClosurePatch

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0322ControlledCanaryIntegrityClosurePatch.swift \
  Sources/MTPROCLI/main.swift \
  Tests/TargetGraphTests/TargetGraphTests.swift \
  checks/verify-v0.32.2.sh \
  checks/run.sh \
  checks/automation-readiness.sh \
  .github/workflows/checks.yml \
  docs/audit/mtpro-release-v0.32.2-controlled-canary-integrity-closure-patch-stage-code-audit.md \
  docs/release/mtpro-release-v0.32.2-controlled-canary-integrity-closure-patch-notes.md \
  docs/validation/latest-verification-summary.md \
  docs/validation/trading-validation-matrix.md \
  README.md \
  GOAL.md \
  verification.md
do
  require_contains "$file" "GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX"
  require_contains "$file" "GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY"
  require_contains "$file" "GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS"
  require_contains "$file" "GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY"
  require_contains "$file" "GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE"
  require_contains "$file" "GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT"
  require_contains "$file" "TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH"
  require_contains "$file" "V0322-001-RELEASE-CREATION-BEHIND-FULL-MATRIX"
  require_contains "$file" "V0322-002-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY"
  require_contains "$file" "V0322-003-COMMIT-CLOCK-APPROVAL-FRESHNESS"
  require_contains "$file" "V0322-004-ATOMIC-RUN-LOCK-REPLAY-REGISTRY"
  require_contains "$file" "V0322-005-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE"
  require_contains "$file" "V0322-006-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT"
done

require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0322ControlledCanaryIntegrityClosurePatch.cliCommand"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0322ControlledCanaryIntegrityClosurePatch.commandLineOutput"
require_contains ".github/workflows/checks.yml" "Publish v0.32.2 release after full matrix"
require_contains ".github/workflows/checks.yml" "GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX"
require_contains "verification.md" "bash checks/verify-v0.32.2.sh"
require_contains "docs/release/mtpro-release-v0.32.2-controlled-canary-integrity-closure-patch-notes.md" "observedProductionCanary=false"
require_contains "docs/audit/mtpro-release-v0.32.2-controlled-canary-integrity-closure-patch-stage-code-audit.md" "backendClosureDecision=blocked"

echo "verify-v0.32.2 passed"
