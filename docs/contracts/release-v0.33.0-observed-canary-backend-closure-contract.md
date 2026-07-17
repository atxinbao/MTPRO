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
