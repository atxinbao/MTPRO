# Release v0.15.0 Real Spot Testnet Cancel-Replace Runtime Contract

日期：2026-06-23

执行者：Codex

## Evidence Anchors

- `GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME`
- `TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE`
- `V0150-005-CANCEL-REPLACE-EMULATION`
- `V0150-005-CANCEL-THEN-NEW-SUBMIT`
- `V0150-005-OMS-REPLACE-STATE-TRANSITION`
- `V0150-005-APPEND-ONLY-CANCEL-REPLACE-EVENT`
- `V0150-005-UNSUPPORTED-NATIVE-REPLACE-FAIL-CLOSED`
- `V0150-005-PRODUCTION-ENDPOINT-BLOCKED`
- `V0150-005-NO-PRODUCTION-CUTOVER`

## Goal

GH-1070 adds the guarded Binance Spot Testnet cancel-replace runtime for orders created by the v0.15.0 submit runtime.

Native Spot Testnet cancel-replace is not enabled in this MVP. The runtime records `nativeCancelReplaceSupported=false` and `nativeReplaceRejectedFailClosed=true`, then executes deterministic cancel + new submit emulation using the existing #1069 cancel runtime and #1068 submit runtime.

## Scope

- Add `ReleaseV0150BinanceSpotTestnetCancelReplaceOperatorGate`.
- Add `ReleaseV0150BinanceSpotTestnetCancelReplaceOMSStateTransitionEvidence`.
- Add `ReleaseV0150BinanceSpotTestnetCancelReplaceRuntimeEvidence`.
- Add `ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime`.
- Extend #1071 event log with `fromCancelReplaceRuntimeEvidence(...)`.
- Append the aggregate `.cancelReplace` event after original submit, cancel, and replacement submit events.

## Boundary

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `endpointHost == testnet.binance.vision`
- `endpointPath == /api/v3/order`
- `nativeCancelReplaceSupported=false`
- `nativeReplaceRejectedFailClosed=true`
- `cancelThenNewSubmitEmulationUsed=true`
- `testnetNetworkCancelPerformed=true`
- `testnetNetworkSubmitPerformed=true`
- `appendOnlyCancelReplaceEvidenceCreated=true`
- `omsStateTransitionIntegrated=true`
- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## Non-goals

- No production cutover.
- No production secret auto-read.
- No production endpoint or broker endpoint connection.
- No real-money order.
- No non-Binance venue.
- No Futures / USD-M Perpetual execution in v0.15.0 MVP.
- No Dashboard trading button, live command, or order form.
- No native `/api/v3/order/cancelReplace` execution path.
- No OMS reconciliation or broker fill runtime.

## Acceptance Criteria

- Cancel-replace runtime requires boundary-held #1068 source submit runtime evidence.
- Cancel-replace runtime requires boundary-held #1069 cancel identity material.
- Cancel-replace runtime requires an existing #1071 event log containing the source submit event.
- Cancel-replace runtime rejects native replace enablement and records fail-closed evidence.
- Cancel-replace runtime executes cancel + replacement submit in sequence.
- OMS transition evidence validates `accepted|partiallyFilled|replaced -> replaceRequested -> replaced`.
- Network event log appends `.cancel`, replacement `.submit`, and aggregate `.cancelReplace` artifacts with checksum continuity.
- Production hosts, production credentials and production order paths remain blocked fail-closed.

## Validation

- `swift test --filter TargetGraphTests/testGH1070ReleaseV0150SpotTestnetCancelReplaceRuntimeEmulatesCancelThenSubmit`
- `bash checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-1070 only authorizes guarded Binance Spot Testnet cancel-replace emulation for orders already represented by v0.15.0 submit runtime evidence. GH-1072 and later issues must separately authorize release journal integration, OMS reconciliation, CLI flow, Dashboard status, failure simulation and final release audit. This contract does not create a release tag and does not publish v0.15.0.
