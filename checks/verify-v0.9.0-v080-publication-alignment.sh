#!/usr/bin/env bash
set -euo pipefail

# GH-844-VERIFY-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD
# V090-002-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD
# TVM-RELEASE-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.9.0 v0.8.0 publication alignment verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.9.0 v0.8.0 publication alignment verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

CONTRACT="docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md"
V081_VERIFIER="checks/verify-v0.8.1-v080-release-publication-docs.sh"
V090_VERIFIER="checks/verify-v0.9.0-v080-publication-alignment.sh"
VALIDATION_PLAN="docs/validation/validation-plan.md"
TRADING_MATRIX="docs/validation/trading-validation-matrix.md"
AUTOMATION_DOC="docs/automation/automation-readiness.md"
RELEASE_URL="https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0"
RELEASE_COMMIT="d83b3b564096a5427db15a437921fc797b22564d"

bash "$V081_VERIFIER"

for file in \
  "$CONTRACT" \
  "$V090_VERIFIER" \
  "$VALIDATION_PLAN" \
  "$TRADING_MATRIX" \
  "$AUTOMATION_DOC"; do
  require_file_contains "$file" "GH-844-VERIFY-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD"
  require_file_contains "$file" "V090-002-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD"
  require_file_contains "$file" "TVM-RELEASE-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD"
done

require_file_contains "$CONTRACT" "GH-835-V081-V080-ACTUAL-GITHUB-RELEASE"
require_file_contains "$CONTRACT" "V081-001-V080-PUBLICATION-DOCS-ALIGNMENT"
require_file_contains "$CONTRACT" "$RELEASE_URL"
require_file_contains "$CONTRACT" "$RELEASE_COMMIT"
require_file_contains "$CONTRACT" "v0.9.0 只继承已完成 publication evidence"
require_file_contains "$CONTRACT" "不得把 v0.8.0 stable GitHub Release publication 当作 production cutover authorization"
require_file_contains "$CONTRACT" "construction closeout、public GitHub Release publication 和 production cutover 仍是三个独立 gate"

require_file_contains "$VALIDATION_PLAN" "GH-844 Release v0.9.0 v0.8.0 Publication Alignment Carry-forward Validation"
require_file_contains "$VALIDATION_PLAN" "Required command: \`bash checks/verify-v0.9.0-v080-publication-alignment.sh\`"
require_file_contains "$TRADING_MATRIX" "v0.8.0 stable GitHub Release exists at \`$RELEASE_URL\` and points to peeled commit \`$RELEASE_COMMIT\`"
require_file_contains "$AUTOMATION_DOC" "Release v0.9.0 v0.8.0 publication alignment carry-forward anchor"
require_file_contains "checks/run.sh" "bash checks/verify-v0.9.0-v080-publication-alignment.sh"

for forbidden in \
  "productionTradingEnabledByDefault=true" \
  "productionSecretRead=true" \
  "productionEndpointConnected=true" \
  "productionBrokerConnected=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true" \
  "testnetOrderSubmissionAllowed=true" \
  "testnetOrderRoutingAllowed=true" \
  "testnetCancelReplaceAllowed=true"; do
  reject_file_contains "$CONTRACT" "$forbidden"
  reject_file_contains "$VALIDATION_PLAN" "$forbidden"
  reject_file_contains "$TRADING_MATRIX" "$forbidden"
done

echo "MTPRO release v0.9.0 v0.8.0 publication alignment carry-forward verification passed."
