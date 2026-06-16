#!/usr/bin/env bash
set -euo pipefail

# GH-808-RELEASE-PUBLICATION-POLICY
# TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.0 publication policy verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.0 publication policy verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
V070_NOTES="docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md"
V070_AUDIT="docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md"

require_file_contains "$POLICY" "GH-808-RELEASE-PUBLICATION-POLICY"
require_file_contains "$POLICY" "V080-002-V070-ACTUAL-GITHUB-RELEASE"
require_file_contains "$POLICY" "V080-002-V080-CONSTRUCTION-VS-PUBLICATION"
require_file_contains "$POLICY" "GH-835-V081-V080-ACTUAL-GITHUB-RELEASE"
require_file_contains "$POLICY" "V080-002-TAG-NAMING-RULES"
require_file_contains "$POLICY" "V080-002-GITHUB-RELEASE-CHECKLIST"
require_file_contains "$POLICY" "V080-002-SOURCE-CHECKSUM-EXPECTATIONS"
require_file_contains "$POLICY" "V080-002-RELEASE-NOTES-PUBLISHING-GATE"
require_file_contains "$POLICY" "TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY"
require_file_contains "$POLICY" "https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0"
require_file_contains "$POLICY" "https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0"
require_file_contains "$POLICY" 'tag peeled commit：`79bd7309b5d644599b6879e615489562455cd3fe`'
require_file_contains "$POLICY" 'tag peeled commit：`d83b3b564096a5427db15a437921fc797b22564d`'
require_file_contains "$POLICY" "git archive --format=tar --prefix=MTPRO-v0.8.0/ v0.8.0 | shasum -a 256"
require_file_contains "$POLICY" "construction closeout 不等于 public release publication"
require_file_contains "$POLICY" "public release publication 也不等于 production cutover"

require_file_contains "README.md" "v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release"
require_file_contains "README.md" "https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0"
require_file_contains "README.md" "docs/release/release-publication-policy.md"
require_file_contains "$V070_NOTES" "v0.7.0 后续已通过独立 release publication gate 发布 stable GitHub Release"
require_file_contains "$V070_NOTES" "https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0"
require_file_contains "$V070_AUDIT" "v0.7.0 was later published through a separate stable GitHub Release gate"
require_file_contains "docs/automation/automation-readiness.md" "Release v0.8.0 publication policy anchor"
require_file_contains "docs/validation/validation-plan.md" "GH-808 Release v0.7.0 / v0.8.0 Publication Policy Validation"
require_file_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.0-release-publication-policy.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH808ReleasePublicationPolicySeparatesConstructionCloseoutFromGitHubRelease"

reject_file_contains "README.md" "不是 GitHub Release 发布动作"
reject_file_contains "$V070_NOTES" "不是 GitHub Release 发布动作"
reject_file_contains "$V070_NOTES" "不创建 tag，不移动 tag"
reject_file_contains "$V070_AUDIT" "explicitly does not publish a GitHub Release tag"
reject_file_contains "$POLICY" "productionTradingEnabledByDefault=true"
reject_file_contains "$POLICY" "productionSecretRead=true"
reject_file_contains "$POLICY" "productionEndpointConnected=true"
reject_file_contains "$POLICY" "productionBrokerConnected=true"
reject_file_contains "$POLICY" "productionOrderSubmitted=true"
reject_file_contains "$POLICY" "productionCutoverAuthorized=true"
reject_file_contains "$POLICY" "testnetOrderSubmissionAllowed=true"
reject_file_contains "$POLICY" "testnetOrderRoutingAllowed=true"

echo "MTPRO release v0.8.0 publication policy verification passed."
