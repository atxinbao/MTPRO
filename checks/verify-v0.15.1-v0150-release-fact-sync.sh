#!/usr/bin/env bash
set -euo pipefail

# GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC
# V0151-001-V0150-RELEASE-FACT-SYNC-GUARD
# TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 v0.15.0 release fact sync guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 v0.15.0 release fact sync guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

reject_unqualified_stale_v0150_wording() {
  local file="$1"
  local forbidden_regex="$2"

  local matches
  matches="$(grep -En "$forbidden_regex" "$file" \
    | grep -Fv '#1076' \
    | grep -Fv 'GH-1076' \
    | grep -Fv 'V0150-011' \
    | grep -Fv 'reject_unqualified_stale_v0150_wording' \
    || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.15.1 v0.15.0 release fact sync guard failed: %s contains unqualified stale v0.15.0 publication wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
NOTES="docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md"

V0150_RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0"
V0150_TARGET_COMMIT="1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece"
V0150_PUBLICATION_TIMESTAMP="2026-06-23T01:26:30Z"
STALE_V0150_WORDING='v0[.]15[.]0.{0,240}(publication pending|release pending|tag pending|release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失)|(publication pending|release pending|tag pending|release not created|not a Git tag publication|not a GitHub Release publication|no public tag|no GitHub Release|construction closeout only|construction closeout final state|PR pending|不创建 tag|不创建 public tag|不创建 GitHub Release|不发布 GitHub Release|没有 tag|没有 GitHub Release|仍需创建 release|未创建 release|待发布|release artifact 缺失).{0,240}v0[.]15[.]0'

for file in "$POLICY" "$PLAN" "$MATRIX" "$READINESS" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$NOTES"; do
  require_file_contains "$file" "v0.15.0"
  require_file_contains "$file" "$V0150_RELEASE_URL"
  require_file_contains "$file" "$V0150_TARGET_COMMIT"
  require_file_contains "$file" "$V0150_PUBLICATION_TIMESTAMP"
  reject_unqualified_stale_v0150_wording "$file" "$STALE_V0150_WORDING"
done

for anchor in \
  "GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC" \
  "V0151-001-V0150-RELEASE-FACT-SYNC-GUARD" \
  "TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC"; do
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "$anchor"
done

require_file_contains "$POLICY" "v0.15.0 release publication、v0.15.1 release fact sync / stale wording guard、后续 hardening patch 和 production cutover 仍是独立 gate"
require_file_contains "$PLAN" "GH-1094 Release v0.15.1 v0.15.0 Release Fact Sync / Stale Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC"
require_file_contains "$READINESS" "Release v0.15.1 v0.15.0 release fact sync stale wording guard anchor"
require_file_contains "$LATEST" "v0.15.0 release publication fact"
require_file_contains "checks/automation-readiness.sh" "GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-v0150-release-fact-sync.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-v0150-release-fact-sync.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1094ReleaseV0151V0150ReleaseFactSyncGuardRejectsStalePublicationWording"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_absent "$file" 'Current GitHub fallback queue: `MTPRO Release v0.15.0'
  require_file_absent "$file" '当前 GitHub fallback queue 为 `release/v0.15.0`'
  require_file_absent "$file" 'current issue `#1073`'
  require_file_absent "$file" 'current issue #1076 is release CI'
done

for forbidden in \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true"; do
  reject_unqualified_stale_v0150_wording "$POLICY" "$forbidden"
  reject_unqualified_stale_v0150_wording "$READINESS" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1094ReleaseV0151V0150ReleaseFactSyncGuardRejectsStalePublicationWording

echo "MTPRO release v0.15.1 v0.15.0 release fact sync stale wording guard verification passed."
