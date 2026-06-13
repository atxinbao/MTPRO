#!/usr/bin/env bash
set -euo pipefail

# GH-668-VERIFY-V030-RELEASE-VALIDATION-SUITE
# TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

release_v030_filter='TargetGraphTests/testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary|TargetGraphTests/testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions|TargetGraphTests/testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity|TargetGraphTests/testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus|TargetGraphTests/testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents|TargetGraphTests/testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState|TargetGraphTests/testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace|TargetGraphTests/testGH664EventStoreReplayReconstructsRehearsalCausalityChain|TargetGraphTests/testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence|TargetGraphTests/testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute|TargetGraphTests/testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace'

swift test --filter "$release_v030_filter"

cli_output="$(swift run mtpro rehearsal-status)"
printf '%s\n' "$cli_output"

require_cli_output() {
  local expected="$1"
  if ! grep -Fq "$expected" <<< "$cli_output"; then
    printf 'release v0.3.0 verification failed: mtpro rehearsal-status must contain: %s\n' "$expected" >&2
    exit 1
  fi
}

require_cli_output "mtpro rehearsal-status blocked"
require_cli_output "issue=GH-666"
require_cli_output "validationAnchor=TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"
require_cli_output "productTypes=spot,usdsPerpetual"
require_cli_output "strategies=ema,rsi"
require_cli_output "commandGateway=required"
require_cli_output "killSwitchStatus=blocked"
require_cli_output "noTradeStatus=blocked"
require_cli_output "commandsRouteThroughCommandGateway=true"
require_cli_output "productionTradingEnabledByDefault=false"
require_cli_output "productionEndpointAutoConnect=false"
require_cli_output "productionSecretAutoRead=false"
require_cli_output "productionOrderSubmission=false"
require_cli_output "productionCutoverAuthorized=false"
require_cli_output "boundaryHeld=true"

echo "MTPRO release v0.3.0 rehearsal validation suite passed."
