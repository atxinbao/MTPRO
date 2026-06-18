#!/usr/bin/env bash
set -euo pipefail

# GH-910-VERIFY-V0101-READINESS-CLI-HELP
# TVM-RELEASE-V0101-READINESS-CLI-HELP
# V0101-005-READINESS-CLI-HELP-PLACEHOLDER
# V0101-005-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS
# V0101-005-NON-MUTATING-NO-ARTIFACT-WRITE
# V0101-005-NO-PRODUCTION-CUTOVER
# V0101-005-NO-PRODUCTION-SECRET-ENDPOINT-ORDER
# V0101-005-NO-READINESS-ARTIFACT-RUNTIME

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_contains() {
  local haystack="$1"
  local expected="$2"
  local context="$3"

  if [[ "$haystack" != *"$expected"* ]]; then
    printf 'release v0.10.1 readiness CLI help guard failed: %s must contain: %s\n' "$context" "$expected" >&2
    exit 1
  fi
}

reject_contains() {
  local haystack="$1"
  local forbidden="$2"
  local context="$3"

  if [[ "$haystack" == *"$forbidden"* ]]; then
    printf 'release v0.10.1 readiness CLI help guard failed: %s must not contain: %s\n' "$context" "$forbidden" >&2
    exit 1
  fi
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.10.1 readiness CLI help guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_command_fails_with() {
  local expected="$1"
  shift
  local output

  if output="$("$@" 2>&1)"; then
    printf 'release v0.10.1 readiness CLI help guard failed: command unexpectedly succeeded: %s\n' "$*" >&2
    exit 1
  fi

  require_contains "$output" "$expected" "$* failure output"
}

HELP_OUTPUT="$(swift run mtpro help)"

for required in \
  "commands=help,run,status,stop,recover,risk-policy,readiness,monitor,verify" \
  "readinessPlaceholderContract=v0.10.1" \
  "readinessActions=readiness help,readiness build,readiness status,readiness validate,readiness export,readiness approval-status" \
  "readinessPlaceholderOnly=true" \
  "readinessArtifactRuntimeImplemented=false" \
  "productionTradingEnabledByDefault=false" \
  "productionSecretRead=false" \
  "productionEndpointConnected=false" \
  "productionOrderSubmitted=false" \
  "productionCutoverAuthorized=false" \
  "boundaryHeld=true"; do
  require_contains "$HELP_OUTPUT" "$required" "mtpro help output"
done

for action in help build status validate export approval-status; do
  OUTPUT="$(swift run mtpro readiness "$action")"
  for required in \
    "mtpro readiness $action v0.10.1" \
    "issue=GH-910" \
    "validationAnchor=TVM-RELEASE-V0101-READINESS-CLI-HELP" \
    "verificationAnchor=GH-910-VERIFY-V0101-READINESS-CLI-HELP" \
    "readinessPlaceholderContract=v0.10.1" \
    "futureReadinessRuntime=v0.11.0" \
    "action=$action" \
    "supportedActions=readiness help,readiness build,readiness status,readiness validate,readiness export,readiness approval-status" \
    "placeholderOnly=true" \
    "noOp=true" \
    "mutationApplied=false" \
    "artifactWritten=false" \
    "readinessBundleWritten=false" \
    "readinessArtifactRuntimeImplemented=false" \
    "productionReadinessArtifactStoreImplemented=false" \
    "operatorApprovalStatus=not-requested" \
    "productionTradingEnabledByDefault=false" \
    "productionSecretRead=false" \
    "productionEndpointConnected=false" \
    "brokerEndpointConnected=false" \
    "productionOrderSubmitted=false" \
    "productionCutoverAuthorized=false" \
    "boundaryHeld=true"; do
    require_contains "$OUTPUT" "$required" "mtpro readiness $action output"
  done

  for anchor in \
    "V0101-005-READINESS-CLI-HELP-PLACEHOLDER" \
    "V0101-005-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS" \
    "V0101-005-NON-MUTATING-NO-ARTIFACT-WRITE" \
    "V0101-005-NO-PRODUCTION-CUTOVER" \
    "V0101-005-NO-PRODUCTION-SECRET-ENDPOINT-ORDER" \
    "V0101-005-NO-READINESS-ARTIFACT-RUNTIME"; do
    require_contains "$OUTPUT" "$anchor" "mtpro readiness $action output"
  done

  for forbidden in \
    "mutationApplied=true" \
    "artifactWritten=true" \
    "readinessBundleWritten=true" \
    "readinessArtifactRuntimeImplemented=true" \
    "productionReadinessArtifactStoreImplemented=true" \
    "productionTradingEnabledByDefault=true" \
    "productionSecretRead=true" \
    "productionEndpointConnected=true" \
    "brokerEndpointConnected=true" \
    "productionOrderSubmitted=true" \
    "productionCutoverAuthorized=true"; do
    reject_contains "$OUTPUT" "$forbidden" "mtpro readiness $action output"
  done
done

require_command_fails_with "mtpro.readiness.action" swift run mtpro readiness write
require_command_fails_with "mtpro.readiness.arguments" swift run mtpro readiness build --write
require_command_fails_with "mtpro.readiness.arguments" swift run mtpro readiness export ./readiness.json

for anchor in \
  "GH-910-VERIFY-V0101-READINESS-CLI-HELP" \
  "TVM-RELEASE-V0101-READINESS-CLI-HELP" \
  "V0101-005-READINESS-CLI-HELP-PLACEHOLDER" \
  "V0101-005-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS" \
  "V0101-005-NON-MUTATING-NO-ARTIFACT-WRITE" \
  "V0101-005-NO-PRODUCTION-CUTOVER" \
  "V0101-005-NO-PRODUCTION-SECRET-ENDPOINT-ORDER" \
  "V0101-005-NO-READINESS-ARTIFACT-RUNTIME"; do
  require_file_contains "Sources/MTPROCLI/main.swift" "$anchor"
  require_file_contains "docs/automation/automation-readiness.md" "$anchor"
  require_file_contains "docs/validation/validation-plan.md" "$anchor"
  require_file_contains "docs/validation/trading-validation-matrix.md" "$anchor"
  require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "$anchor"
done

require_file_contains "checks/run.sh" "bash checks/verify-v0.10.1-readiness-cli-help.sh"
require_file_contains "checks/verify-v0.10.0.sh" "bash checks/verify-v0.10.1-readiness-cli-help.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.10.1-readiness-cli-help.sh"
require_file_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH910ReadinessCLIHelpPlaceholderIsNonMutatingAndFailsClosed"

echo "MTPRO release v0.10.1 readiness CLI help placeholder verification passed."
