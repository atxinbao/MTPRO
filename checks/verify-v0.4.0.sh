#!/usr/bin/env bash
set -euo pipefail

# GH-707-VERIFY-V040-RELEASE-VALIDATION-SUITE
# TVM-RELEASE-V040-VERIFY-VALIDATION-SUITE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.4.0 verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.4.0 verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

release_v040_filter='TargetGraphTests/testGH694ReleaseV040UnifiedRuntimeRehearsalPipelineContractRequiresOneRunID|TargetGraphTests/testGH695ReleaseV040RehearsalRunContextAndEnvelopeShareOneRunID|TargetGraphTests/testGH696RuntimeKernelDryRunOrchestratorDrivesLocalRunWithoutNetworkOrSecrets|TargetGraphTests/testGH697DataEngineRuntimeStepPublishesRunScopedMarketEventsIntoMessageBus|TargetGraphTests/testGH698TraderStrategyActorsConsumeMessageBusMarketEventsAndEmitRunScopedIntents|TargetGraphTests/testGH699RiskEnginePreTradeRehearsalGateAllowsRejectsAndBlocksRunScopedIntents|TargetGraphTests/testGH700ExecutionOMSDryRunLifecycleConsumesRiskApprovedDecisionAndReplaysRunScopedEvents|TargetGraphTests/testGH701BinanceDryRunExecutionClientAdapterMapsLifecycleRequestsWithoutNetworkCalls|TargetGraphTests/testGH702BinanceTestnetModeBoundaryRequiresExplicitOperatorConfirmation|TargetGraphTests/testGH703EventStoreRunJournalAppendsAndReplaysOneRunIDChain|TargetGraphTests/testGH704PortfolioReplayProjectionDerivesReadModelFromEventStoreRunJournal|TargetGraphTests/testGH705DashboardCLIUnifiedRunSurfaceConsumesPortfolioProjectionByRunID|TargetGraphTests/testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls'

swift test --filter "$release_v040_filter"

cli_output="$(swift run mtpro unified-run-status)"
printf '%s\n' "$cli_output"

require_cli_output() {
  local expected="$1"
  if ! grep -Fq "$expected" <<< "$cli_output"; then
    printf 'release v0.4.0 verification failed: mtpro unified-run-status must contain: %s\n' "$expected" >&2
    exit 1
  fi
}

require_cli_output "mtpro unified-run-status blocked"
require_cli_output "issue=GH-705"
require_cli_output "validationAnchor=TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE"
require_cli_output "productTypes=spot,usdsPerpetual"
require_cli_output "strategies=EMA,RSI"
require_cli_output "adapterEvidenceVisible=true"
require_cli_output "portfolioProjectionVisible=true"
require_cli_output "blockedStatesExplained=true"
require_cli_output "rejectedStatesExplained=true"
require_cli_output "dashboardConsumesProjectionByRunID=true"
require_cli_output "cliConsumesProjectionByRunID=true"
require_cli_output "productionTradingEnabledByDefault=false"
require_cli_output "productionEndpointConnected=false"
require_cli_output "productionSecretRead=false"
require_cli_output "productionOrderSubmitted=false"
require_cli_output "productionCutoverAuthorized=false"
require_cli_output "boundaryHeld=true"

require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040RuntimeKernelDryRunOrchestrator.swift" \
  "networkCallsPerformed: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040RuntimeKernelDryRunOrchestrator.swift" \
  "productionEndpointConnected: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040RuntimeKernelDryRunOrchestrator.swift" \
  "productionOrderSubmitted: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040BinanceTestnetModeBoundary.swift" \
  "defaultMode: ReleaseV040RehearsalRunMode = .dryRun"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040BinanceTestnetModeBoundary.swift" \
  "requestedMode: ReleaseV040RehearsalRunMode = .testnetGuarded"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040BinanceTestnetModeBoundary.swift" \
  "productionEndpointConnected: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040BinanceTestnetModeBoundary.swift" \
  "productionOrderSubmitted: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040ShadowReplayMode.swift" \
  "testnetConnected: Bool = false"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV040ShadowReplayMode.swift" \
  "shadowSuccessTreatedAsProductionApproval: Bool = false"

reject_file_contains "checks/verify-v0.4.0.sh" "api.binance.com"
reject_file_contains "checks/verify-v0.4.0.sh" "fapi.binance.com"
reject_file_contains "checks/verify-v0.4.0.sh" "productionTradingEnabledByDefault=true"
reject_file_contains "checks/verify-v0.4.0.sh" "productionEndpointConnected=true"
reject_file_contains "checks/verify-v0.4.0.sh" "productionOrderSubmitted=true"
reject_file_contains "checks/verify-v0.4.0.sh" "productionCutoverAuthorized=true"

echo "MTPRO release v0.4.0 unified runtime rehearsal validation suite passed."
