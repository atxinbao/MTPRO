# MTPRO v0.33.0 Observed Controlled Production Canary / Backend Closure Contract

日期：2026-07-17  
执行者：Codex

Anchors: `GH-1542-DEFINE-V0330-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT`, `TVM-RELEASE-V0330-OBSERVED-CONTROLLED-PRODUCTION-CANARY`, `V0330-001-OBSERVED-CANARY-BACKEND-CLOSURE-CONTRACT`.

## Goal

v0.33.0 defines the final backend-closure evidence contract for a Human-approved observed Binance canary. The contract fixes the prerequisite order, approval boundary, product/action scope, trusted evidence requirements, and fail-closed outcomes before any canary operation can be considered.

## Hard Prerequisites

1. `v0.32.3` must exist as a published stable GitHub Release created after its hosted full matrix succeeds.
2. A separate, explicit Human approval must be recorded before approval-packet preparation can become eligible.
3. Contract completion, issue promotion, CI success, and release publication are not observed-canary execution authorization.

The queue decision is ordered and fail-closed:

- missing published v0.32.3 -> `blocked-v0.32.3-not-published`
- published v0.32.3 but missing Human approval -> `blocked-human-approval-missing`
- both present -> `approval-packet-preparation-eligible`

The eligible state only permits preparation and validation of the approval packet. It does not authorize submit, status, cancel, secret access, broker connection, backend closure acceptance, or production cutover.

## Required Scope

- Venue: Binance only.
- Products: Spot and USD-M Futures only.
- Observed actions: submit, status, and cancel for each product.
- Approval: operator identity, source commit, expiry, product/symbol allowlist, strict notional caps, order types, kill-switch/no-trade state, and rollback owner.
- Evidence: trusted GitHub provenance, persistent run lock/nonce registry, complete observed lifecycle, independent OMS/reconciliation/rollback/incident artifacts, checksums, reverse references, redaction, freshness, and fail-closed decision derivation.

## Decision Separation

`backendClosureDecision` may only be derived later from verified observed evidence. `productionCutoverAuthorized` remains a separate Human decision and is never implied by an accepted backend-closure decision.

## Current Boundary

- `requiresExplicitHumanApproval=true`
- `observedCanaryExecutionAuthorized=false`
- `productionCutoverAuthorized=false`
- `defaultProductionTradingEnabled=false`
- `okxActiveRuntimeEnabled=false`
- `dashboardTradingControlsEnabled=false`

This issue fixes the contract only. It does not execute an observed canary and does not claim backend closure.

## Human Approval Packet (V0330-002)

Anchors: `GH-1543-PREPARE-V0330-HUMAN-APPROVED-CANARY-PACKET`, `TVM-RELEASE-V0330-HUMAN-APPROVAL-PACKET`, `V0330-002-HUMAN-APPROVED-CANARY-PACKET`.

`ReleaseV0330CanaryApprovalPacket` records the operator, source commit, validity window, Spot and USD-M Futures symbol allowlists, positive notional caps, LIMIT-only order scope, conservative leverage caps, kill-switch/no-trade evidence references, rollback owner, and an external Human approval attestation reference.

The validator fails closed for missing or expired approval, wrong commit, wrong product scope, empty or duplicate symbols, invalid caps, missing safety evidence, fixture-origin approval evidence, malformed attestation checksums, or a packet that already claims production cutover/default production trading. Canonical JSON can be persisted as the approval packet artifact, but the code does not create or sign a Human approval.

`approvalPacketRecorded=true` is necessary but not sufficient. The report always keeps `observedCanaryExecutionAuthorized=false` and `productionCutoverAuthorized=false`; later runtime gates must independently verify the external approval artifact and every operational safety condition.

## Approval-bound Runner Boundary (V0330-002A)

Anchors: `GH-1559-ADD-APPROVAL-BOUND-OBSERVED-CANARY-RUNNER`, `TVM-RELEASE-V0330-APPROVAL-BOUND-OBSERVED-CANARY-RUNNER`, `V0330-002A-APPROVAL-BOUND-FAIL-CLOSED-RUNNER`.

`ReleaseV0330ObservedCanaryRunner` separates packet validation from execution authorization. A valid packet cannot invoke a transport by itself. Every run also requires a human-recorded, one-shot execution authorization bound to the exact packet, source commit, product, symbol, issue, validity window and external attestation checksum.

Before invoking an injected transport, the runner checks the packet scope, LIMIT-only order type, notional and leverage caps, exact HTTPS Binance product endpoint, credential reference, RiskEngine result, kill-switch state, no-trade state, rollback evidence and the v0.32.3 persistent run lock. Submit, status and cancel observations must remain redacted, carry safe relative artifact references, and bind back to the same run/product/action.

The default transport always rejects with `transportNotConfigured`. V0330-002A does not read environment secrets, connect a broker, submit an order or authorize an observed canary. Concrete credential loading and transport activation remain part of V0330-003/V0330-004 and require a separate Human approval at execution time.

## Exact Order Plan Activation Boundary (V0330-002B)

Anchors: `GH-1561-ADD-EXACT-OBSERVED-CANARY-ORDER-PLAN`, `TVM-RELEASE-V0330-EXACT-ORDER-PLAN-ACTIVATION-BOUNDARY`, `V0330-002B-EXACT-ORDER-PLAN-FAIL-CLOSED-ACTIVATION`.

`ReleaseV0330ObservedCanaryOrderPlan` removes transport-time discretion from an approved run. The immutable plan binds the approval packet and source commit to the exact product, canonical execution issue, symbol, side, LIMIT order type, GTC time-in-force, integer-scaled price, integer-scaled quantity, derived notional, leverage and deterministic client order identity.

The separate Human execution authorization must contain the SHA-256 of that exact canonical plan. The runner rejects any plan/digest mismatch, price/quantity/notional inconsistency, unsupported side or time-in-force, non-deterministic client identity, cap overflow or cross-product scope before acquiring transport evidence. Only the validated plan is propagated to submit/status/cancel transport calls.

V0330-002B remains implementation prerequisite work. Its default transport is still rejecting, its tests use only an injected fake transport, and it does not read a secret, instantiate `URLSession`, connect Binance or authorize #1544/#1545. Those canonical execution issues still require a separate, explicit Human authorization at execution time.

## Externally Activated Canary Transport Boundary (V0330-002C)

Anchors: `GH-1563-ADD-EXTERNALLY-ACTIVATED-PRODUCTION-CANARY-TRANSPORT`, `TVM-RELEASE-V0330-EXTERNALLY-ACTIVATED-CANARY-TRANSPORT`, `V0330-002C-NO-DEFAULT-CREDENTIAL-OR-NETWORK-ACTIVATION`.

`ReleaseV0330ExternallyActivatedCanaryTransport` maps a validated exact order plan to the Binance Spot `/api/v3/order` or USD-M Futures `/fapi/v1/order` submit, status and cancel request shapes. It creates HMAC signatures only in memory and converts the response into checksum-backed, redacted operation evidence without persisting raw credential material, signatures, request payloads or response bodies.

The transport has no automatic activation path. Credential material, network loading, clock and artifact persistence are separate injected protocols, and every default implementation rejects. The repository provides an optional URLSession loader with its own exact HTTPS host/path/method allowlist, but V0330-002C tests use only an injected fake network loader and do not contact Binance.

V0330-002C does not authorize #1544/#1545, discover environment secrets, enable default production trading or approve production cutover. A canonical observed canary still requires an external Human-recorded packet and separate one-shot execution authorization bound to the exact plan and current source commit.
