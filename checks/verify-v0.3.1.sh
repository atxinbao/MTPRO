#!/usr/bin/env bash
set -euo pipefail

# GH-688-VERIFY-V031-REHEARSAL-EVIDENCE-HARDENING-PATCH

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.3.1 hardening verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_tree_pattern() {
  local pattern="$1"
  local description="$2"
  shift 2

  if grep -R -n -E "$pattern" "$@"; then
    printf 'release v0.3.1 hardening verification failed: forbidden %s found.\n' "$description" >&2
    exit 1
  fi
}

reject_tree_pattern_except_gh694_contract() {
  local pattern="$1"
  local description="$2"
  shift 2

  local matches
  matches="$(grep -R -n -E "$pattern" "$@" || true)"
  matches="$(
    printf '%s\n' "$matches" \
      | grep -Ev '^Sources/ExecutionClient/FutureGate/ReleaseV040UnifiedRuntimeRehearsalPipelineContract\.swift:' \
      | grep -Ev '^Sources/DomainModel/ReleaseV040RehearsalRunContext\.swift:' \
      | grep -Ev '^Sources/ExecutionClient/FutureGate/ReleaseV040RuntimeKernelDryRunOrchestrator\.swift:' \
      | grep -Ev '^Sources/DataEngine/ReleaseV040DataEngineMessageBusRuntimeStep\.swift:' \
      | grep -Ev '^Sources/Trader/Runtime/ReleaseV040TraderStrategyActorsRuntimeStep\.swift:' \
      | grep -Ev '^Sources/RiskEngine/LiveGate/ReleaseV040RiskEnginePreTradeRehearsalGate\.swift:' \
      | grep -Ev '^Sources/ExecutionEngine/OMSFutureGate/ReleaseV040ExecutionOMSDryRunLifecycle\.swift:' \
      | grep -Ev '^Sources/ExecutionClient/FutureGate/ReleaseV040BinanceDryRunExecutionClientAdapterBoundary\.swift:' \
      | grep -Ev '^Sources/ExecutionClient/FutureGate/ReleaseV040BinanceTestnetModeBoundary\.swift:' \
      | grep -Ev '^Sources/Database/ReleaseV040EventStoreRunJournal\.swift:' \
      | grep -Ev '^Sources/Portfolio/ReleaseV040PortfolioReplayProjection\.swift:' \
      | grep -Ev '^Sources/Portfolio/ReleaseV040UnifiedRunSurface\.swift:' \
      | grep -Ev '^Sources/Dashboard/Report/ReleaseV040DashboardUnifiedRunSurface\.swift:' \
      | grep -Ev '^Sources/ExecutionClient/FutureGate/ReleaseV040ShadowReplayMode\.swift:' \
      | grep -Ev '^Sources/MTPROCLI/main\.swift:' \
      | grep -Ev '^Package\.swift:[0-9]+:                "ReleaseV040RehearsalRunContext\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "ReleaseV040EventStoreRunJournal\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "Database/ReleaseV040EventStoreRunJournal\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "ReleaseV040PortfolioReplayProjection\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "Portfolio/ReleaseV040PortfolioReplayProjection\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "ReleaseV040UnifiedRunSurface\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "Portfolio/ReleaseV040UnifiedRunSurface\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "DomainModel/ReleaseV040RehearsalRunContext\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "DataEngine/ReleaseV040DataEngineMessageBusRuntimeStep\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "ReleaseV040DataEngineMessageBusRuntimeStep\.swift",$' \
      | grep -Ev '^Package\.swift:[0-9]+:                "Runtime/ReleaseV040TraderStrategyActorsRuntimeStep\.swift",$' \
      | grep -Ev '^Tests/TargetGraphTests/TargetGraphTests\.swift:' \
      || true
  )"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches"
    printf 'release v0.3.1 hardening verification failed: forbidden %s found.\n' "$description" >&2
    exit 1
  fi
}

require_file_contains \
  "Sources/Database/ReleaseV030CLIRehearsalSurface.swift" \
  'GH-685 固定 `mtpro rehearsal-status` 的 v0.3.x product boundary'
require_file_contains \
  "Sources/Database/ReleaseV030CLIRehearsalSurface.swift" \
  "public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]"
require_file_contains \
  "Sources/Database/ReleaseV030CLIRehearsalSurface.swift" \
  "public static let requiredStrategies: [ReleaseV030CLIRehearsalStrategyKind] = [.ema, .rsi]"
require_file_contains \
  "Sources/Portfolio/ReleaseV030RehearsalSurface.swift" \
  "GH-685 固定 v0.3.x Dashboard / CLI rehearsal product boundary"
require_file_contains \
  "Sources/Portfolio/ReleaseV030PortfolioProjectionRehearsal.swift" \
  "GH-685 固定 v0.3.x rehearsal product boundary 为显式 release 常量"

require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift" \
  "private static func validateTestnetBaseURL"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift" \
  "releaseV030BinanceAdapter.nonHTTPSBaseURL"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift" \
  "releaseV030BinanceAdapter.baseURLUserInfo"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift" \
  "releaseV030BinanceAdapter.baseURLPath"
require_file_contains \
  "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift" \
  "releaseV030BinanceAdapter.baseURLQuery"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "GH-686 testnet URL policy"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "https://api.binance.com"
require_file_contains \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "https://user:pass@testnet.binance.vision"

require_file_contains \
  "docs/roadmap.md" \
  "GH-687-RELEASE-V031-REHEARSAL-EVIDENCE-DOCS-HANDOFF"
require_file_contains \
  "docs/validation/latest-verification-summary.md" \
  '`v0.3.x` 不表示 real testnet / shadow runtime runner 已存在'
require_file_contains \
  "docs/operators/release-v0.3.0-operator-rehearsal-runbook.md" \
  "v0.3.x 不是 real testnet / shadow runtime runner"

require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "v0.3.1 是 rehearsal evidence hardening patch"
require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "production trading remains disabled by default"
require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "no production secret auto-read"
require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "no production endpoint auto-connect"
require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "no production order authorization"
require_file_contains \
  "docs/release/mtpro-release-v0.3.1-rehearsal-evidence-hardening-patch-notes.md" \
  "no v0.4.0 runtime pipeline is implemented"

reject_tree_pattern_except_gh694_contract \
  "v0\\.4\\.0|V040|ReleaseV040|releaseV040" \
  "v0.4.0 runtime/source marker outside the GH-694/GH-695/GH-696/GH-697/GH-698/GH-699/GH-700/GH-701/GH-702/GH-703/GH-704/GH-705/GH-706 contract boundary" \
  Sources Tests Package.swift

echo "MTPRO release v0.3.1 rehearsal evidence hardening guard passed."
