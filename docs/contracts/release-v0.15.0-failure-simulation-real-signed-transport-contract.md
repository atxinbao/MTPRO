# Release v0.15.0 Failure Simulation for Real Signed Transport Contract

日期：2026-06-23

执行者：Codex

## Scope

GH-1075 adds local deterministic failure simulation for v0.15.0 Binance Spot Testnet signed transport and execution state handling.

- `GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT`
- `TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT`
- `V0150-010-REJECTED-TIMEOUT-RATELIMIT`
- `V0150-010-CREDENTIAL-SIGNATURE-FAILURES`
- `V0150-010-CANCEL-NOT-FOUND`
- `V0150-010-RECONCILIATION-MISMATCH`
- `V0150-010-APPEND-ONLY-REDACTED-FAILURE-EVIDENCE`
- `V0150-010-NO-PRODUCTION-CUTOVER`

## Evidence Surface

- `ReleaseV0150BinanceSpotTestnetFailureSimulationCase`
- `ReleaseV0150BinanceSpotTestnetFailureSimulationEvidence`
- `ReleaseV0150BinanceSpotTestnetFailureSimulationReport`
- `ReleaseV0150BinanceSpotTestnetFailureSimulationSuite`

The simulation covers:

- rejected request
- timeout
- rate-limit
- stale credential
- bad signature
- cancel-not-found
- reconciliation mismatch

Required static boundary:

- `failureSimulationOnly=true`
- `deterministicFailureSimulation=true`
- `appendOnlyFailureEvidence=true`
- `redactedRequestIdentity=true`
- `redactedResponseIdentity=true`
- `omsStateExplainable=true`
- `reconciliationMismatchFailClosed=true`
- `rawSecretPersisted=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## Non-goals

- No production trading.
- No production cutover.
- No production secret auto-read.
- No production endpoint or broker endpoint connection.
- No real-money order.
- No non-Binance venue.
- No Futures / USDⓈ-M Perpetual execution in v0.15.0 MVP.
- No Dashboard trading button, live command, or order form.
- No network action execution from the simulation suite.

## Failure State Contract

- `rejectedRequest` records HTTP 400 and expected OMS state `rejected`.
- `timeout` records no HTTP status and expected OMS state `failedClosed`.
- `rateLimit` records HTTP 429 and expected OMS state `failedClosed`.
- `staleCredential` records HTTP 401 and expected OMS state `failedClosed`.
- `badSignature` records HTTP 400 and expected OMS state `rejected`.
- `cancelNotFound` records HTTP 404, action kind `cancel`, and expected OMS state `failedClosed`.
- `reconciliationMismatch` records action kind `cancelReplace`, expected OMS state `failedClosed`, and reconciliation reason `lifecycleStateMismatch`.

All evidence is deterministic, redacted, append-only and checksummed. The suite does not call `URLSession`, construct `URLRequest`, read credential material from environment variables, or connect to production / broker endpoints.

## Validation

- `swift test --filter TargetGraphTests/testGH1075ReleaseV0150FailureSimulationCoversSignedTransportAndReconciliationFailures`
- `bash checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
