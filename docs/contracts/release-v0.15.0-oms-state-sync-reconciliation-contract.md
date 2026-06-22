# Release v0.15.0 OMS State Sync + Reconciliation Contract

日期：2026-06-23

执行者：Codex

## Evidence Anchors

- `GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION`
- `TVM-RELEASE-V0150-OMS-STATE-SYNC-RECONCILIATION`
- `V0150-007-CONSUMES-NETWORK-EVENT-LOG`
- `V0150-007-OMS-STATE-SYNC-FROM-APPEND-ONLY-EVIDENCE`
- `V0150-007-EXPECTED-OBSERVED-RECONCILIATION`
- `V0150-007-MISMATCH-FAIL-CLOSED`
- `V0150-007-SUBMIT-CANCEL-CANCEL-REPLACE-COVERAGE`
- `V0150-007-NO-PRODUCTION-CUTOVER`

## Goal

GH-1072 consumes the v0.15.0 append-only Binance Spot Testnet network execution event log and derives auditable local OMS state plus expected / observed reconciliation evidence.

The state sync layer is local and deterministic: `derivedFromNetworkEventLogOnly=true`, `appendOnlyNetworkExecutionEventLog=true`, and every report remains `mismatchesFailClosed=true`.

## Scope

- Add `ReleaseV0150BinanceSpotTestnetOMSStateRecord`.
- Add `ReleaseV0150BinanceSpotTestnetOMSStateSnapshot`.
- Add `ReleaseV0150BinanceSpotTestnetOMSObservedStateEvidence`.
- Add `ReleaseV0150BinanceSpotTestnetOMSReconciliationReport`.
- Add `ReleaseV0150BinanceSpotTestnetOMSStateReconciliationEngine`.
- Consume #1071 `ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog`.
- Produce state and reconciliation evidence for submit, cancel and cancel-replace artifacts.

## Boundary

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `derivedFromNetworkEventLogOnly=true`
- `appendOnlyNetworkExecutionEventLog=true`
- `expectedObservedReconciliation=true`
- `mismatchesFailClosed=true`
- `submitCancelCancelReplaceCoverage=true`
- `rawBrokerPayloadIncluded=false`
- `brokerFillIncluded=false`
- `networkOrderActionPerformed=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## Non-goals

- No new signed request construction.
- No new submit / cancel / replace network action.
- No production cutover.
- No production secret auto-read.
- No production endpoint or broker endpoint connection.
- No real-money order.
- No non-Binance venue.
- No Futures / USD-M Perpetual execution in v0.15.0 MVP.
- No raw broker payload.
- No broker fill runtime.
- No Dashboard trading button, live command, or order form.

## Acceptance Criteria

- OMS state sync accepts only boundary-held append-only network event logs.
- State records are grouped by intent ID and derived only from event artifacts.
- Snapshot coverage exactly matches source event artifact IDs.
- Reconciliation compares snapshot, source event log and observations.
- Missing observations, lifecycle drift, identity drift or evidence mismatch produce failed reports with fail-closed failures.
- Submit, cancel and cancel-replace coverage is testable through the focused verifier.
- Production hosts, production credentials and production order paths remain blocked fail-closed.

## Validation

- `swift test --filter TargetGraphTests/testGH1072ReleaseV0150OMSStateReconciliationConsumesNetworkEventLog`
- `bash checks/verify-v0.15.0-oms-state-sync-reconciliation.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-1072 only authorizes local OMS state sync and expected / observed reconciliation from existing v0.15.0 Spot Testnet network event artifacts. It does not create new network actions, does not add broker fills, does not publish a release tag, and does not authorize production cutover. GH-1073 and later issues must separately authorize CLI operator flow, Dashboard status, failure simulation and final release audit.
