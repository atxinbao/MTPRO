#!/usr/bin/env bash
set -euo pipefail

# GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
# TVM-RELEASE-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
# V0190-009-CLI-REGISTRY-LIST
# V0190-009-CLI-CAPABILITIES-INSPECT
# V0190-009-CLI-EXPLAIN-UNSUPPORTED
# V0190-009-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED
# V0190-009-READ-ONLY-NO-COMMANDS
# V0190-009-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'v0.19.0 CLI venue/product registry inspect verification failed: %s\n' "$1" >&2
  exit 1
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_contains() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

require_output_contains() {
  local output="$1"
  local expected="$2"
  grep -Fq "$expected" <<<"$output" || fail "command output must contain: $expected"
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" \
  "Sources/MTPROCLI/main.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.19.0-cli-venue-product-registry-inspect.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_contains "$file" "GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT"
  require_contains "$file" "TVM-RELEASE-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT"
  require_contains "$file" "V0190-009-CLI-REGISTRY-LIST"
  require_contains "$file" "V0190-009-CLI-CAPABILITIES-INSPECT"
  require_contains "$file" "V0190-009-CLI-EXPLAIN-UNSUPPORTED"
  require_contains "$file" "V0190-009-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED"
  require_contains "$file" "V0190-009-READ-ONLY-NO-COMMANDS"
  require_contains "$file" "V0190-009-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "public enum ReleaseV0190CLIVenueProductRegistryInspect"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "public static let cliCommand = \"venue-product\""
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "listOutput()"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "capabilitiesOutput"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "explainOutput"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "ReleaseV0190VenueProductCapabilityMatrix.profile"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "ReleaseV0190VenueProductRuntimeRegistry.registration"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "commandPathIntroduced=false"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0190CLIVenueProductRegistryInspect.cliCommand"
require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0190CLIVenueProductRegistryInspect.commandLineOutput"
require_contains "Tests/TargetGraphTests/TargetGraphTests.swift" "testGH1214CLIVenueProductRegistryInspectShowsReadOnlyRegistryState"
require_contains "docs/validation/validation-plan.md" "GH-1214 Release v0.19.0 CLI Venue/Product Registry Inspect"

reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "productionCutoverAuthorized=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "productionSecretRead=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "productionEndpointConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "brokerEndpointConnected=true"
reject_contains "Sources/ExecutionClient/FutureGate/ReleaseV0190CLIVenueProductRegistryInspect.swift" "submitCancelReplaceEnabled=true"

list_output="$(swift run mtpro venue-product list)"
require_output_contains "$list_output" "mtpro venue-product list"
require_output_contains "$list_output" "registryRows=4"
require_output_contains "$list_output" "row=binance/spot"
require_output_contains "$list_output" "status=active"
require_output_contains "$list_output" "row=binance/usdmFutures"
require_output_contains "$list_output" "status=future-gated"
require_output_contains "$list_output" "row=okx/spot"
require_output_contains "$list_output" "status=placeholder"
require_output_contains "$list_output" "row=okx/swap"
require_output_contains "$list_output" "futureGated=submit,cancel,reconcile,reduceOnly,leverage,marginType"
require_output_contains "$list_output" "boundaryHeld=true"

capabilities_output="$(swift run mtpro venue-product capabilities --venue binance --product spot)"
require_output_contains "$capabilities_output" "mtpro venue-product capabilities"
require_output_contains "$capabilities_output" "target=binance/spot"
require_output_contains "$capabilities_output" "capability.submit=active"
require_output_contains "$capabilities_output" "capability.reduceOnly=forbidden"
require_output_contains "$capabilities_output" "readOnlyInspectOnly=true"
require_output_contains "$capabilities_output" "productionCutoverAuthorized=false"

explain_output="$(swift run mtpro venue-product explain --venue okx --product spot)"
require_output_contains "$explain_output" "mtpro venue-product explain"
require_output_contains "$explain_output" "target=okx/spot"
require_output_contains "$explain_output" "status=placeholder"
require_output_contains "$explain_output" "runtime=unsupported:"
require_output_contains "$explain_output" "OKX runtime"
require_output_contains "$explain_output" "commandPathIntroduced=false"
require_output_contains "$explain_output" "submitCancelReplaceCommandPath=false"

if swift run mtpro venue-product capabilities --venue binance --product swap >/tmp/mtpro-v0190-cli-unsupported.out 2>&1; then
  fail "unsupported binance/swap command must fail closed"
fi
require_contains "/tmp/mtpro-v0190-cli-unsupported.out" "unsupported venue/product"
require_contains "/tmp/mtpro-v0190-cli-unsupported.out" "binance/swap"

if swift run mtpro venue-product explain --venue coinbase --product spot >/tmp/mtpro-v0190-cli-unknown.out 2>&1; then
  fail "unknown venue command must fail closed"
fi
require_contains "/tmp/mtpro-v0190-cli-unknown.out" "mtpro.venueProduct.venue"
require_contains "/tmp/mtpro-v0190-cli-unknown.out" "coinbase"

swift test --filter TargetGraphTests/testGH1214CLIVenueProductRegistryInspectShowsReadOnlyRegistryState

printf 'MTPRO v0.19.0 CLI venue/product registry inspect verification passed.\n'
