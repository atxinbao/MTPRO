#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISSUE_ID="MTP-123"
RUN_ID="${MTPRO_BETA_ACCEPTANCE_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
DEFAULT_EVIDENCE_ROOT="$ROOT/.codex/beta-acceptance"
EVIDENCE_ROOT="${MTPRO_BETA_ACCEPTANCE_EVIDENCE_DIR:-$DEFAULT_EVIDENCE_ROOT}"
EVIDENCE_DIR="$EVIDENCE_ROOT/$RUN_ID"

cd "$ROOT"
mkdir -p "$EVIDENCE_DIR"

log() {
  printf '[%s beta acceptance] %s\n' "$ISSUE_ID" "$*" | tee -a "$EVIDENCE_DIR/summary.log"
}

run_and_capture() {
  local label="$1"
  shift

  log "running ${label}: $*"
  "$@" 2>&1 | tee "$EVIDENCE_DIR/${label}.log"
}

require_smoke_handle() {
  local handle="$1"

  if ! grep -Fq "$handle" "$EVIDENCE_DIR/dashboard-smoke.log"; then
    log "missing expected Dashboard smoke handle: ${handle}"
    log "see ${EVIDENCE_DIR}/dashboard-smoke.log"
    exit 1
  fi
}

log "MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW"
log "evidence directory: ${EVIDENCE_DIR}"

os_name="$(uname -s | tee "$EVIDENCE_DIR/uname.log")"
if [[ "$os_name" != "Darwin" ]]; then
  log "MTP-123 requires local macOS Workbench acceptance; got uname -s=${os_name}"
  exit 1
fi

run_and_capture swift-version swift --version
run_and_capture swift-package-resolve swift package resolve
run_and_capture dashboard-smoke env DASHBOARD_SMOKE=1 swift run Dashboard

require_smoke_handle "Dashboard smoke:"
require_smoke_handle "sections=8"
require_smoke_handle "readModelOnly=true"
require_smoke_handle "workbenchReadModelOnly=true"
require_smoke_handle "controls=start,pause,close,reset"
require_smoke_handle "scenarioReplayEvidence=1"
require_smoke_handle "scenarioQualityGates=6"
require_smoke_handle "simulatedParityEvidence=1"
require_smoke_handle "defaultDemoState=default demo"
require_smoke_handle "defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario"
require_smoke_handle "betaFirstRunFallbacks=3"
require_smoke_handle "betaAcceptancePaths=1"
require_smoke_handle "betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario"
require_smoke_handle "betaAcceptanceTrace=5"
require_smoke_handle "liveBlockedGates=6"
require_smoke_handle "liveExecutionControlGates=7"
require_smoke_handle "liveRiskGates=6"
require_smoke_handle "liveIncidentStopGates=5"
require_smoke_handle "liveMonitoringHealth=blocked"
require_smoke_handle "sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events"

log "MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS matched Dashboard smoke handles."
run_and_capture mtpro-checks bash checks/run.sh

log "MTP-123-BETA-ACCEPTANCE-SCRIPT-VALIDATION passed."
log "MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE stored in ${EVIDENCE_DIR}"
