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

### Trusted GitHub provenance export (V0323-002)

`GH-1536-FETCH-TRUSTED-GITHUB-RUN-ARTIFACT-PROVENANCE` requires provenance to be loaded
through `ReleaseV0323TrustedGitHubProvenanceLoader`. The caller must obtain the export SHA256,
run and artifact identity, artifact archive SHA256, and operation bundle SHA256 from a trusted
GitHub API, attestation, or protected workflow channel. The export file cannot establish its own trust.

`TVM-RELEASE-V0323-TRUSTED-GITHUB-PROVENANCE` and
`V0323-002-TRUSTED-GITHUB-PROVENANCE` require exact repository, workflow, run ID, run attempt,
actor, source commit, required job, artifact identity, and checksum matches. Observed canary evidence
is derived only from the checksum-bound complete Spot and USD-M Futures submit/status/cancel set.
Any self-reported observed-canary boolean in the export is rejected.

### Atomic persistent run lock (V0323-003)

`GH-1537-IMPLEMENT-ATOMIC-PERSISTENT-RUN-LOCK-REGISTRY`,
`TVM-RELEASE-V0323-PERSISTENT-RUN-LOCK-REGISTRY`, and
`V0323-003-PERSISTENT-RUN-LOCK-REGISTRY` require the lock decision to come from filesystem state.
`ReleaseV0323PersistentRunLockStore` atomically creates the run lock directory, persists owner and
nonce metadata, writes a checksum-protected registry, and permanently retains consumed run IDs and
nonces for replay queries. Release and stale recovery verify owner/nonce identity and update the
registry; missing or corrupted registry data fails closed. Manifest booleans do not participate.

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
