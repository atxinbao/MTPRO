# Release v0.15.0 Real Spot Testnet Cancel Runtime Contract

日期：2026-06-23

执行者：Codex

## Evidence Anchors

- `GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME`
- `TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL`
- `V0150-004-CANCEL-REQUEST-CONSTRUCTION`
- `V0150-004-SIGNED-TESTNET-TRANSPORT`
- `V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE`
- `V0150-004-OMS-CANCEL-STATE-TRANSITION`
- `V0150-004-APPEND-ONLY-CANCEL-EVENT`
- `V0150-004-PRODUCTION-ENDPOINT-BLOCKED`
- `V0150-004-NO-PRODUCTION-CUTOVER`

## Goal

GH-1069 adds the guarded Binance Spot Testnet cancel runtime for orders created by the v0.15.0 submit runtime.

The contract binds prior #1068 submit runtime evidence, redacted testnet order identity reference, signed cancel request construction, injected Spot Testnet cancel transport, redacted response evidence, local OMS cancel transition evidence, and #1071 append-only network event log append.

## Scope

- Add `ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference`.
- Add short-lived non-Codable `ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial`.
- Add `ReleaseV0150BinanceSpotTestnetSignedCancelOrderRequestEvidence`.
- Extend `ReleaseV0150BinanceSpotTestnetSignedRequestBuilder` with cancel request construction.
- Add `ReleaseV0150BinanceSpotTestnetCancelOperatorGate`.
- Add `ReleaseV0150BinanceSpotTestnetCancelTransport`.
- Add `ReleaseV0150BinanceSpotTestnetCancelTransportResult`.
- Add `ReleaseV0150BinanceSpotTestnetCancelOMSStateTransitionEvidence`.
- Add `ReleaseV0150BinanceSpotTestnetCancelRuntimeEvidence`.
- Add `ReleaseV0150BinanceSpotTestnetCancelRuntime`.
- Extend #1071 event log with `fromCancelRuntimeEvidence(...)`.

## Boundary

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `endpointHost == testnet.binance.vision`
- `endpointPath == /api/v3/order`
- `httpMethod=DELETE`
- `testnetNetworkCancelPerformed=true`
- `appendOnlyCancelEvidenceCreated=true`
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
- No cancel-replace runtime; that remains downstream issue scope.
- No OMS reconciliation or broker fill runtime.

## Acceptance Criteria

- Cancel runtime requires boundary-held #1068 submit runtime evidence.
- Cancel runtime requires an existing #1071 network event log containing the prior submit event.
- Cancel runtime requires a Binance Testnet cancel mapping from `accepted`, `partiallyFilled`, or `replaced`.
- Cancel request evidence uses `DELETE` and records only redacted query identity plus signature evidence.
- Raw original client order ID enters only short-lived non-Codable material and is not persisted.
- Transport result stores only redacted response digest, redacted exchange order identity and status code.
- OMS transition evidence validates `accepted|partiallyFilled|replaced -> cancelRequested -> cancelled`.
- Network event log appends a `.cancel` artifact with previous checksum equal to the prior latest checksum.
- Production hosts, production credentials and production order paths remain blocked fail-closed.

## Validation

- `swift test --filter TargetGraphTests/testGH1069ReleaseV0150SpotTestnetCancelRuntimeAppendsRedactedCancelEvidence`
- `bash checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-1069 only authorizes guarded Binance Spot Testnet cancel for orders already represented by v0.15.0 submit runtime evidence. GH-1070 and later issues must separately authorize cancel-replace, release journal integration, OMS reconciliation, CLI flow, Dashboard status, failure simulation and final release audit. This contract does not create a release tag and does not publish v0.15.0.
