#!/usr/bin/env bash
set -euo pipefail

# GH-835-V081-V080-ACTUAL-GITHUB-RELEASE
# V081-001-V080-PUBLICATION-DOCS-ALIGNMENT
# V081-001-NO-PRODUCTION-CUTOVER
# TVM-RELEASE-V081-V080-PUBLICATION-DOCS-ALIGNMENT

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.8.1 v0.8.0 publication docs verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.8.1 v0.8.0 publication docs verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md"
AUDIT="docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0"
RELEASE_COMMIT="d83b3b564096a5427db15a437921fc797b22564d"

for file in \
  "README.md" \
  "$POLICY" \
  "$NOTES" \
  "$AUDIT" \
  "$VALIDATION_PLAN" \
  "$TRADING_MATRIX" \
  "$AUTOMATION_DOC"; do
  require_file_contains "$file" "$RELEASE_URL"
done

require_file_contains "$POLICY" "GH-835-V081-V080-ACTUAL-GITHUB-RELEASE"
require_file_contains "$POLICY" 'release tag：`v0.8.0`'
require_file_contains "$POLICY" "release type：stable release；非 draft；非 prerelease"
require_file_contains "$POLICY" "tag peeled commit：\`$RELEASE_COMMIT\`"
require_file_contains "$POLICY" 'publication timestamp：`2026-06-16T11:56:09Z`'
require_file_contains "$POLICY" "publication pending"
require_file_contains "$POLICY" "不得把 GitHub Release publication 当作 production cutover authorization"

require_file_contains "README.md" "v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release"
require_file_contains "README.md" "v0.9.0 construction closeout 和 public GitHub Release publication 已分别完成，production cutover 仍是独立 gate"
require_file_contains "$NOTES" "v0.8.0 后续已通过独立 release publication gate 发布 stable GitHub Release"
require_file_contains "$AUDIT" "v0.8.0 was later published through a separate stable GitHub Release gate"
require_file_contains "$VALIDATION_PLAN" "GH-835 Release v0.8.0 Public GitHub Release Docs Alignment Validation"
require_file_contains "$TRADING_MATRIX" "TVM-RELEASE-V081-V080-PUBLICATION-DOCS-ALIGNMENT"
require_file_contains "$AUTOMATION_DOC" "Release v0.8.1 v0.8.0 publication docs alignment anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.8.1-v080-release-publication-docs.sh"

for forbidden in \
  "v0.8.0 public release publication remains a separate gate" \
  "v0.8.0 public GitHub Release publication remains a separate gate" \
  "v0.8.0 public release publication 仍然必须走独立 release publication gate" \
  "v0.8.0 public release publication remains separate" \
  "v0.8.0 public release publication remains pending" \
  "v0.8.0 public GitHub Release publication remains pending" \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true"; do
  reject_file_contains "README.md" "$forbidden"
  reject_file_contains "$NOTES" "$forbidden"
  reject_file_contains "$AUDIT" "$forbidden"
  reject_file_contains "$VALIDATION_PLAN" "$forbidden"
  reject_file_contains "$TRADING_MATRIX" "$forbidden"
done

echo "MTPRO release v0.8.1 v0.8.0 publication docs verification passed."
