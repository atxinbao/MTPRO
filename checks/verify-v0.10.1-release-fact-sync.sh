#!/usr/bin/env bash
set -euo pipefail

# GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD
# V0101-002-RELEASE-FACT-SYNC-GUARD
# V0101-002-FOUR-GATE-RELEASE-FLOW
# TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.1 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_matches() {
  local file="$1"
  local forbidden_regex="$2"

  local matches
  matches="$(grep -En "$forbidden_regex" "$file" || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.1 release fact sync guard failed: %s contains stale v0.10.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
AUDIT="docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md"
NOTES="docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md"
RUNBOOK="docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md"
VERIFICATION="docs/history/validation-pre-canonicalization-2026-07-20/verification.md"

V0100_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0"
V0100_TARGET_COMMIT="7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4"
STALE_V0100_WORDING='v0[.]10[.]0.{0,240}(publication pending|release pending|tag pending|release not created|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|release artifact 缺失).{0,240}v0[.]10[.]0'

for file in "$POLICY" "$PLAN" "$MATRIX" "$READINESS" "$README" "$ROADMAP" "$LATEST" "$AUDIT" "$NOTES" "$RUNBOOK" "$VERIFICATION"; do
  require_file_contains "$file" "v0.10.0"
  require_file_contains "$file" "$V0100_RELEASE_URL"
  reject_file_matches "$file" "$STALE_V0100_WORDING"
done

for file in "$POLICY" "$README" "$ROADMAP" "$LATEST" "$AUDIT" "$NOTES" "$RUNBOOK" "$VERIFICATION" "$READINESS"; do
  require_file_contains "$file" "$V0100_TARGET_COMMIT"
done

for anchor in \
  "GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD" \
  "V0101-002-RELEASE-FACT-SYNC-GUARD" \
  "V0101-002-FOUR-GATE-RELEASE-FLOW" \
  "TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD"; do
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
done

require_file_contains "$POLICY" "construction closeout gate"
require_file_contains "$POLICY" "release publication gate"
require_file_contains "$POLICY" "release fact sync gate"
require_file_contains "$POLICY" "stale wording guard gate"
require_file_contains "$POLICY" "Production cutover remains a separate non-release gate"
require_file_contains "$POLICY" "不读取 production secret"
require_file_contains "$POLICY" "不连接 production endpoint / broker"
require_file_contains "$POLICY" "不提交 testnet 或 production order"
require_file_contains "$PLAN" "GH-907 Release v0.10.1 Release Fact Sync / Stale Wording Guard Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD"
require_file_contains "$READINESS" "Release v0.10.1 release fact sync stale wording guard anchor"
require_file_contains "checks/automation-readiness.sh" "GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD"
require_file_contains "checks/verify-v0.10.0.sh" "bash checks/verify-v0.10.1-release-fact-sync.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.1-release-fact-sync.sh"

for forbidden in \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true"; do
  reject_file_matches "$POLICY" "$forbidden"
  reject_file_matches "$READINESS" "$forbidden"
done

echo "MTPRO release v0.10.1 release fact sync stale wording guard verification passed."
