# Release v0.15.0 Testnet Credential Provider / Signed Request Builder Contract

日期：2026-06-22  
执行者：Codex

## Evidence Anchors

- `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`
- `TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`
- `V0150-002-CREDENTIAL-REFERENCE`
- `V0150-002-HMAC-SHA256-SIGNED-REQUEST`
- `V0150-002-BINANCE-SPOT-TESTNET-ONLY`
- `V0150-002-NO-PRODUCTION-SECRET-AUTO-READ`
- `V0150-002-PRODUCTION-ENDPOINT-BLOCKED`
- `V0150-002-REDACTED-EVIDENCE`
- `V0150-002-NO-NETWORK-ACTION`

## Goal

GH-1067 adds the v0.15.0 Binance Spot Testnet credential identity and HMAC signed request construction gate. It is the second executable child of `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`, after GH-1066.

The contract proves that MTPRO can construct deterministic signed Spot Testnet order request evidence using an injected short-lived testnet credential material while keeping production trading disabled by default.

## Scope

- Add `ReleaseV0150BinanceSpotTestnetCredentialReference` as the redacted credential identity contract.
- Add `ReleaseV0150BinanceSpotTestnetCredentialMaterial` for short-lived testnet API key / secret material injected by the caller.
- Add `ReleaseV0150BinanceSpotTestnetSignedRequestBuilder` for canonical Spot Testnet signed request evidence.
- Add `ReleaseV0150BinanceSpotTestnetSignedOrderRequestEvidence` for redacted append-only request construction evidence.
- Add focused tests and automation readiness guards for deterministic HMAC-SHA256 signing.

## Boundary

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `endpointHost == testnet.binance.vision`
- `endpointPath == /api/v3/order`
- `httpMethod == POST`
- `apiKeyHeaderName == X-MBX-APIKEY`
- `redactionPolicy == redactedIdentifierOnly`
- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

## Non-goals

- No production cutover.
- No production secret auto-read.
- No production endpoint or broker endpoint connection.
- No real-money order.
- No USDⓈ-M Perpetual execution in v0.15.0 MVP.
- No Dashboard trading button, live command, or order form.
- No URLRequest, URLSession, network submit, cancel, or replace action.

## Acceptance Criteria

- Credential reference stores only `referenceID`, provider kind and redaction policy.
- Credential material is not Codable and does not write API key / secret into evidence.
- Signed request evidence includes deterministic unsigned query string, HMAC-SHA256 signature, signed query string, canonical host and path.
- Evidence description and tests prove API key / secret values remain redacted.
- Production hosts `api.binance.com`, `fapi.binance.com`, and `dapi.binance.com` fail closed.
- Non-Spot product type fails closed for this v0.15.0 MVP gate.
- Verification is wired through `checks/verify-v0.15.0-testnet-credential-signed-request.sh`, `checks/automation-readiness.sh`, and `checks/run.sh`.

## Validation

- `swift test --filter TargetGraphTests/testGH1067ReleaseV0150SpotTestnetSignedRequestBuilderIsRedactedAndDeterministic`
- `bash checks/verify-v0.15.0-testnet-credential-signed-request.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-1067 only produces signed request construction evidence. GH-1068 and later issues must separately authorize any runtime handoff, append-only evidence journal, network transport, order submission, cancel / replace handling, or operator confirmation flow. This contract does not create a release tag and does not publish v0.15.0.
