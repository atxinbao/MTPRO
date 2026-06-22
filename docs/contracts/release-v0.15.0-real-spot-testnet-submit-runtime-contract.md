# Release v0.15.0 Real Spot Testnet Submit Runtime Contract

日期：2026-06-22  
执行者：Codex

## Evidence Anchors

- `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`
- `TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT`
- `V0150-003-ORDERINTENT-TO-SIGNED-SUBMIT`
- `V0150-003-REDACTED-RESPONSE-EVIDENCE`
- `V0150-003-TESTNET-NETWORK-SUBMIT-PERFORMED`
- `V0150-003-PRODUCTION-ENDPOINT-BLOCKED`
- `V0150-003-NO-PRODUCTION-CUTOVER`

## Goal

GH-1068 adds the first guarded Binance Spot Testnet submit runtime path for `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`.

The contract binds `OrderIntent -> ExecutionContractRequestMapping -> ReleaseV0150BinanceSpotTestnetSignedRequestBuilder -> ReleaseV0150BinanceSpotTestnetSubmitTransport -> redacted response evidence`. It allows `testnetNetworkSubmitPerformed=true` only for Binance Spot Testnet after explicit operator confirmation.

## Scope

- Add `ReleaseV0150BinanceSpotTestnetSubmitOperatorGate` for explicit operator confirmation.
- Add `ReleaseV0150BinanceSpotTestnetSubmitTransport` as an injected Spot Testnet transport boundary.
- Add `ReleaseV0150BinanceSpotTestnetSubmitTransportResult` for redacted HTTP status and response digest evidence.
- Add `ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence` for append-only runtime evidence.
- Add `ReleaseV0150BinanceSpotTestnetSubmitRuntime` to execute the guarded submit path with injected credential material and transport.

## Boundary

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `endpointHost == testnet.binance.vision`
- `endpointPath == /api/v3/order`
- `testnetNetworkSubmitPerformed=true`
- `appendOnlyEvidenceCreated=true`
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
- No Futures / USDⓈ-M Perpetual execution in v0.15.0 MVP.
- No Dashboard trading button, live command, or order form.
- No cancel / replace runtime; those remain downstream issue scope.

## Acceptance Criteria

- Submit runtime rejects non-Spot product types.
- Submit runtime requires `riskAccepted` Binance Testnet submit mapping.
- Signed request evidence is produced by the #1067 signed request builder.
- Operator confirmation is bound to strategy run, credential reference and signed request identity.
- Transport result stores only redacted response digest, redacted exchange order identity and status code.
- Runtime evidence records `testnetNetworkSubmitPerformed=true` while all production flags remain false.
- Production hosts, production credentials and production order paths remain blocked fail-closed.

## Validation

- `swift test --filter TargetGraphTests/testGH1068ReleaseV0150SpotTestnetSubmitRuntimeProducesRedactedNetworkEvidence`
- `bash checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-1068 only authorizes guarded Binance Spot Testnet submit. GH-1069 and later issues must separately authorize cancel, cancel-replace, append-only execution journal integration, OMS reconciliation, CLI flow, Dashboard status, failure simulation and final release audit. This contract does not create a release tag and does not publish v0.15.0.
