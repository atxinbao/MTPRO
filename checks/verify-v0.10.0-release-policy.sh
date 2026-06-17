#!/usr/bin/env bash
set -euo pipefail

# GH-879-VERIFY-V0100-V091-PUBLICATION-POLICY
# TVM-RELEASE-V0100-V091-PUBLICATION-POLICY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.0 publication policy verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.10.0 publication policy verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.9.1-v090-audit-hardening-notes.md"
AUDIT="docs/audit/mtpro-release-v0.9.1-v090-audit-hardening-stage-code-audit.md"
LATEST="docs/validation/latest-verification-summary.md"
MATRIX="docs/validation/trading-validation-matrix.md"
PLAN="docs/validation/validation-plan.md"
READINESS="docs/automation/automation-readiness.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

for anchor in \
  "GH-879-VERIFY-V0100-V091-PUBLICATION-POLICY" \
  "GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE" \
  "V0100-002-V091-PUBLICATION-FACT" \
  "V0100-002-V0100-RELEASE-POLICY-ANCHOR" \
  "TVM-RELEASE-V0100-V091-PUBLICATION-POLICY"; do
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
done

for file in README.md "$POLICY" "$NOTES" "$AUDIT" "$LATEST" "$MATRIX" "$PLAN" "$READINESS"; do
  require_file_contains "$file" "https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1"
  require_file_contains "$file" "d041f0dd304075562a85e494695697290972288f"
done

require_file_contains "$POLICY" "publication timestamp：\`2026-06-17T19:45:42Z\`"
require_file_contains "$NOTES" "publication timestamp：\`2026-06-17T19:45:42Z\`"
require_file_contains "$AUDIT" "publication timestamp \`2026-06-17T19:45:42Z\`"
require_file_contains "$LATEST" "publication timestamp \`2026-06-17T19:45:42Z\`"
require_file_contains "$POLICY" "construction / readiness closeout gate"
require_file_contains "$POLICY" "public release publication gate"
require_file_contains "$POLICY" "production cutover gate"
require_file_contains "$POLICY" "不得再把 v0.9.1 描述成 tagless patch、没有 tag 或没有 GitHub Release"
require_file_contains "$PLAN" "GH-879 Release v0.10.0 v0.9.1 Publication Policy Validation"
require_file_contains "$MATRIX" "TVM-RELEASE-V0100-V091-PUBLICATION-POLICY"
require_file_contains "$READINESS" "Release v0.10.0 v0.9.1 publication policy anchor"
require_file_contains "$TESTS" "testGH879ReleaseV0100V091PublicationPolicyRecordsPublishedTagAndCutoverSeparation"
require_file_contains "checks/run.sh" "bash checks/verify-v0.10.0-release-policy.sh"

for file in README.md "$NOTES" "$AUDIT" "$LATEST"; do
  reject_file_contains "$file" "v0.9.1 不发布 tag"
  reject_file_contains "$file" "v0.9.1 不创建 GitHub Release"
done

for forbidden in \
  "productionTradingEnabledByDefault == true" \
  "productionCutoverAuthorized=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true"; do
  reject_file_contains "$POLICY" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$AUDIT" "$forbidden"
done

echo "MTPRO release v0.10.0 v0.9.1 publication policy verification passed."
