# MTPRO v0.32.3 Controlled Canary Persistent Evidence Integrity Repair Contract

日期：2026-07-16  
执行者：Codex

Anchors: `GH-1535-DEFINE-V0323-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT`, `TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR`, `V0323-001-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR-CONTRACT`.

## Goal

v0.32.3 is a patch-only integrity repair. It must replace self-reported evidence with verifiable provenance, durable locking, independently linked artifacts, real-path containment, and negative validation before any observed canary or backend closure can start.

## Required Repair Areas

1. `trusted-github-provenance`: derive workflow and artifact provenance from trusted GitHub data rather than manifest booleans.
2. `atomic-persistent-run-lock`: acquire a durable lock atomically, persist the nonce registry, support replay queries, and audit stale recovery.
3. `independent-artifact-graph`: persist independent OMS, reconciliation, rollback, and incident artifacts with bidirectional identity and checksum linkage.
4. `realpath-containment`: resolve symlinks and reject every artifact whose real path escapes the evidence root.
5. `complete-negative-matrix`: cover concurrent acquire, corruption, wrong ownership, replay, path escape, and missing or mismatched linked artifacts.
6. `binance-only-documentation`: keep the active runtime scope limited to Binance Spot and USD-M Futures.

## Gate

Until every required repair area is implemented and verified:

- `backendClosureDecision=blocked`
- `observedProductionCanaryAuthorized=false`
- `productionCutoverAuthorized=false`
- `selfReportedManifestTrusted=false`
- `defaultProductionTradingEnabled=false`
- `v0.33.0` remains blocked

## Non-goals

- No observed production canary execution.
- No backend closure acceptance.
- No unrestricted or default production trading.
- No automatic production secret read or broker connection.
- No OKX active runtime.
- No Dashboard trading button, order form, or live command.

This contract defines the repair sequence; it does not claim that later v0.32.3 implementation issues are complete.
