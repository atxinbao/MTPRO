# MTPRO v0.25.0 Production Environment Isolation / Credential Reference Policy

Date: 2026-07-07  
Author: Codex

## Scope

This document records the `V0250-002` production environment isolation and credential reference policy.

The policy is an evidence contract only. It does not read production secrets, open broker endpoints, connect signed account endpoints, enable order mutation, or authorize production cutover.

## Validation Anchors

- `GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY`
- `TVM-RELEASE-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY`
- `V0250-002-PRODUCTION-ENVIRONMENT-ISOLATION`
- `V0250-002-CREDENTIAL-REFERENCE-ONLY`
- `V0250-002-MISMATCH-FAILS-CLOSED`
- `V0250-002-MISSING-APPROVAL-FAILS-CLOSED`
- `V0250-002-NO-SECRET-READ`

## Required Profiles

- `sandbox-dry-run`: Binance Spot sandbox evidence; no live endpoint.
- `spot-canary-readiness`: Binance Spot production-live identity; manual approval required; reference-only credential evidence.
- `futures-readonly-readiness`: Binance USDⓈ-M Futures production-shadow read-only evidence; no execution.
- `blocked-production-live-default`: Binance USDⓈ-M Futures production-live blocked by default.

## Fail-closed Rules

- Credential namespace mismatch must produce blocked evidence.
- Environment profile mismatch must produce blocked evidence.
- Venue/product profile mismatch must produce blocked evidence.
- Missing manual approval must produce blocked evidence.
- Missing redacted credential reference must produce blocked evidence.

## Explicit Non-goals

- No production secret read.
- No fallback credential provider.
- No production endpoint connection.
- No broker endpoint connection.
- No signed account endpoint runtime.
- No private stream runtime.
- No submit / cancel / replace.
- No Futures execution.
- No OKX active runtime.
- No Dashboard trading controls.
- No production cutover.
